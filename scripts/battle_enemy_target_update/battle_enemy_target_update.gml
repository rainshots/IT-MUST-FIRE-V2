/// @description Selects a local defensive target and alerts nearby allies, with a leash to the starting position.
function battle_enemy_target_update(_unit)
{
	if (!instance_exists(_unit)) return;
	var _leash = BALANCE_BATTLE_DEFENSE_RADIUS;
	var _target = _unit.find_nearest_player_unit_target(_unit.target_detection_radius);
	if (!instance_exists(_target) && _unit.target_can_be_attacked(_unit.alert_target))
	{
		_target = _unit.alert_target;
	}
	if (instance_exists(_target)
		&& (!variable_instance_exists(_target, "unit_faction")
			|| _target.unit_faction != UNIT_FACTION.FRIENDLY
			|| point_distance(_unit.battle_home_x, _unit.battle_home_y, _target.x, _target.y) > _leash))
	{
		_target = noone;
	}
	_unit.target_instance = _target;
	if (!instance_exists(_target) || !instance_exists(_unit.battle_controller)) return;

	// Share a spotted threat at most once per second; alerts do not release timed attack waves.
	var _elapsed = _unit.battle_controller.battle_elapsed_seconds;
	if (_elapsed < _unit.battle_help_next_seconds) return;
	_unit.battle_help_next_seconds = _elapsed + BALANCE_BATTLE_HELP_COOLDOWN_SECONDS;
	var _help_radius_squared = sqr(BALANCE_BATTLE_HELP_RADIUS);
	var _count = instance_number(o_units_parent);
	for (var _index = 0; _index < _count; ++_index)
	{
		var _ally = instance_find(o_units_parent, _index);
		if (!instance_exists(_ally) || _ally == _unit
			|| _ally.unit_faction != UNIT_FACTION.ENEMY || _ally.hp <= 0) continue;
		var _distance_squared = sqr(_ally.x - _unit.x) + sqr(_ally.y - _unit.y);
		if (_distance_squared > _help_radius_squared || !_ally.target_can_be_attacked(_target)) continue;
		_ally.alert_target = _target;
		_ally.alert_target_timer = _ally.alert_target_time;
	}
}
