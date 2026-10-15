/// @description Spawns the next endless wave and schedules its random successor; controller context.
function fight_wave_spawn()
{
	if (!BALANCE_ENEMY_SPAWNS_ENABLED || fight_state != FIGHT_STATE.ACTIVE || !instance_exists(o_cannon)) return;
	var _cannon = instance_find(o_cannon, 0);
	var _types = [o_enemy_peasant, o_enemy_archer, o_enemy_knight, o_enemy_mage, o_enemy_catapult];
	var _counts = fight_wave_counts_get(fight_wave_index + 1);
	var _half_height = BALANCE_FIGHT_BATTLEFIELD_HEIGHT * 0.5;
	for (var _i = 0; _i < array_length(_types); ++_i)
	{
		for (var _unit = 0; _unit < _counts[_i]; ++_unit)
		{
			var _enemy = instance_create_layer(_cannon.x + BALANCE_FIGHT_ENEMY_OFFSET_X,
				_cannon.y + random_range(-_half_height, _half_height), "Instances", _types[_i]);
			_enemy.unit_can_attack_cannon = true;
			_enemy.target_instance = _cannon;
		}
	}
	fight_wave_index++;
	fight_next_wave_seconds = fight_elapsed_seconds + random_range(BALANCE_WAVE_INTERVAL_MIN, BALANCE_WAVE_INTERVAL_MAX);
}
