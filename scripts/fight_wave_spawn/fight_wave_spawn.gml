/// @description Spawns a budgeted wave on the right edge of the battlefield; controller context.
function fight_wave_spawn()
{
	if (!instance_exists(o_cannon) || fight_wave_index >= fight_wave_count) return;
	var _cannon = instance_find(o_cannon, 0);
	var _remaining_waves = fight_wave_count - fight_wave_index;
	var _type_count = array_length(fight_enemy_types);
	var _half_height = BALANCE_FIGHT_BATTLEFIELD_HEIGHT * 0.5;
	for (var _type_index = 0; _type_index < _type_count; ++_type_index)
	{
		var _enemy_object = fight_enemy_types[_type_index];
		var _cost = fight_enemy_difficulty_get(_enemy_object);
		var _budget = fight_enemy_remaining_budgets[_type_index];
		// Match the old night-wave rounding, spending each type's budget across remaining waves.
		var _unit_count = round(max(0, _budget) / max(1, _remaining_waves) / _cost);
		if (_budget > 0 && _unit_count <= 0) _unit_count = 1;
		fight_enemy_remaining_budgets[_type_index] = max(0, _budget - _unit_count * _cost);
		// Scale the final headcount without spending later waves' budgets or changing unit stats.
		_unit_count = ceil(_unit_count * BALANCE_FIGHT_ENEMY_COUNT_MULTIPLIER);
		for (var _unit_index = 0; _unit_index < _unit_count; ++_unit_index)
		{
			var _spawn_x = _cannon.x + BALANCE_FIGHT_ENEMY_OFFSET_X;
			var _spawn_y = _cannon.y + random_range(-_half_height, _half_height);
			var _enemy = instance_create_layer(_spawn_x, _spawn_y, "Instances", _enemy_object);
			_enemy.max_hp *= fight_enemy_hp_multiplier;
			_enemy.hp = _enemy.max_hp;
			_enemy.damage *= fight_enemy_damage_multiplier;
			_enemy.magic_damage *= fight_enemy_damage_multiplier;
			_enemy.unit_can_attack_cannon = true;
			_enemy.target_instance = _cannon;
		}
	}
	fight_wave_index++;
}
