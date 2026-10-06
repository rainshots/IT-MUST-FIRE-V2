/// @description Counts every living enemy faction unit and resolves a battle only after combat has started.
function battle_result_update(_controller)
{
	if (!instance_exists(_controller)) return;
	var _living_enemies = 0;
	var _count = instance_number(o_units_parent);
	for (var _index = 0; _index < _count; ++_index)
	{
		var _unit = instance_find(o_units_parent, _index);
		if (instance_exists(_unit) && _unit.unit_faction == UNIT_FACTION.ENEMY && _unit.hp > 0)
		{
			_living_enemies++;
		}
	}
	_controller.battle_enemy_count = _living_enemies;
	if (_controller.battle_phase != BATTLE_PHASE.BATTLE) return;

	var _cannon = instance_find(o_cannon, 0);
	if (!instance_exists(_cannon) || _cannon.hp <= 0)
	{
		_controller.battle_phase = BATTLE_PHASE.DEFEAT;
	}
	else if (_living_enemies == 0)
	{
		_controller.battle_phase = BATTLE_PHASE.VICTORY;
	}
	else return;

	// Freeze the result and capture the selected world-map point only on victory.
	global.pause = true;
	global.focus_window = FOCUS_WINDOW.NOONE;
	global.cannon_target_exists = false;
	_controller.night_fast_forward_set(false);
	_controller.holy_cannon_night_end();
	var _map = instance_find(o_world_map, 0);
	if (instance_exists(_map) && _controller.battle_phase == BATTLE_PHASE.VICTORY
		&& object_exists(_map.active_level))
	{
		world_map_level_capture(_map, _map.active_level);
	}
}
