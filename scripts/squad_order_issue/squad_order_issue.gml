/// @description Gives the squad a move or attack-move destination, preserving the world flag on its members.
function squad_order_issue(_squad, _x, _y, _mode)
{
	if (!is_struct(_squad) || global.day_phase != DAY_PHASE.NIGHT
		|| (_mode != SQUAD_ORDER.MOVE && _mode != SQUAD_ORDER.MOVE_AND_ATTACK))
	{
		return false;
	}

	// Stop a legacy march before taking ownership of movement.
	squad_march_end(_squad);
	var _properties = _squad.properties;
	_properties.marker_is_dragged = false;
	_properties.order_mode = _mode;
	_properties.order_serial++;
	_properties.order_x = clamp(_x, 0, room_width);
	_properties.order_y = clamp(_y, 0, room_height);
	_properties.march_enemy_check_timer = BALANCE_SQUAD_MARCH_ENEMY_CHECK_TIME * room_speed;
	_properties.march_pace_update_timer = 0;
	_properties.combat_guide_unit = noone;
	var _unit_count = array_length(_squad.units);

	// New commands interrupt combat and movement-owning abilities immediately.
	for (var _index = 0; _index < _unit_count; ++_index)
	{
		var _unit = _squad.units[_index];
		if (!instance_exists(_unit) || !variable_instance_exists(_unit, "squad_order_serial"))
		{
			continue;
		}
		_unit.squad_order_serial = -1;
		_unit.squad_order_in_combat = false;
		_unit.squad_order_arrived = false;
		_unit.target_instance = noone;
		_unit.alert_target = noone;
		_unit.forced_attack_target = noone;
		_unit.manual_structure_target = noone;
		_unit.is_attacking_target = false;
		_unit.regroup_is_active = false;
		_unit.rally_is_active = false;
		if (variable_instance_exists(_unit, "unholy_savage_leap_cancel_for_march"))
		{
			_unit.unholy_savage_leap_cancel_for_march();
		}
		if (variable_instance_exists(_unit, "imp_active_ability_cancel_for_order"))
		{
			_unit.imp_active_ability_cancel_for_order();
		}
	}
	squad_march_pace_update(_squad);
	return true;
}
