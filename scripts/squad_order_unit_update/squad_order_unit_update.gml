/// @description Runs a unit's direct movement order, or prepares a nearby enemy for its normal combat AI.
/// @param {Id.Instance} unit Combat member after status, stun and loading checks in o_units_parent Step.
/// @returns {Bool} Whether direct movement owns this frame.
function squad_order_unit_update(_unit)
{
	_unit.squad_order_in_combat = false;
	if (_unit.unit_faction != UNIT_FACTION.FRIENDLY || global.day_phase != DAY_PHASE.NIGHT
		|| !squad_order_is_active(_unit.squad))
	{
		return false;
	}

	var _properties = _unit.squad.properties;
	if (_unit.squad_order_serial != _properties.order_serial)
	{
		_unit.squad_order_serial = _properties.order_serial;
		_unit.squad_order_arrived = false;
		_unit.squad_order_search_timer = 0;
		_unit.navigation_path_state_clear();
	}
	if (_unit.squad_order_arrived)
	{
		return false;
	}

	// Arrival is per member and permanent for this order, even if combat later draws it away.
	var _arrive_radius = _properties.order_mode == SQUAD_ORDER.MOVE_AND_ATTACK
		? BALANCE_SQUAD_ORDER_ATTACK_MOVE_ARRIVE_RADIUS
		: BALANCE_SQUAD_ORDER_MOVE_ARRIVE_RADIUS;
	var _distance_x = _properties.order_x - _unit.x;
	var _distance_y = _properties.order_y - _unit.y;
	if (_distance_x * _distance_x + _distance_y * _distance_y
		<= sqr(_arrive_radius))
	{
		_unit.squad_order_arrived = true;
		_unit.target_search_update_timer = _unit.target_search_update_interval;
		_unit.navigation_path_state_clear();
		return false;
	}

	if (_properties.order_mode == SQUAD_ORDER.MOVE_AND_ATTACK)
	{
		var _target = _unit.target_instance;
		var _had_target = _target != noone;
		var _target_is_nearby_enemy = instance_exists(_target)
			&& (_target.object_index == o_enemy_units || object_is_ancestor(_target.object_index, o_enemy_units))
			&& point_distance(_unit.x, _unit.y, _target.x, _target.y) <= BALANCE_SQUAD_ORDER_ATTACK_RADIUS
			&& _unit.target_can_be_attacked(_target);
		_unit.squad_order_search_timer -= _unit.gameplay_time_scale;

		// Search at the existing AI cadence; a lost combat target triggers an immediate recheck.
		if (_unit.squad_order_search_timer <= 0 || (_had_target && !_target_is_nearby_enemy))
		{
			_unit.squad_order_search_timer = _unit.target_search_update_interval;
			_unit.target_instance = _target_is_nearby_enemy ? _target : noone;
			_target = _unit.find_nearest_enemy_unit_target(BALANCE_SQUAD_ORDER_ATTACK_RADIUS);
			_target_is_nearby_enemy = instance_exists(_target)
				&& _unit.navigation_target_prepare(_target, _unit.attack_radius);
		}
		if (_target_is_nearby_enemy)
		{
			_unit.target_instance = _target;
			_unit.squad_order_in_combat = true;
			return false;
		}
	}

	// Pure movement ignores threats. Attack-move resumes this route whenever no nearby enemy remains.
	_unit.target_instance = noone;
	_unit.alert_target = noone;
	_unit.alert_target_timer = 0;
	_unit.forced_attack_target = noone;
	_unit.forced_attack_target_timer = 0;
	_unit.cached_follow_target = noone;
	_unit.is_attacking_target = false;
	_unit.visual_attack_offset_x = 0;
	_unit.visual_attack_offset_y = 0;
	_unit.update_separation_push();
	_unit.move_towards_world_point(_properties.order_x, _properties.order_y, squad_march_unit_speed_get(_unit));
	_unit.apply_separation_push();
	return true;
}
