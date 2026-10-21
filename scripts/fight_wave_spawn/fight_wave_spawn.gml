/// @description Spawns the next endless wave and schedules its random successor; controller context.
function fight_wave_spawn()
{
	if (!BALANCE_ENEMY_SPAWNS_ENABLED || fight_state != FIGHT_STATE.ACTIVE) return;
	if (!instance_exists(o_building_grid)) return;
	// The first territory with any surviving enemy building supplies this wave.
	var _zones = o_building_grid.enemy_zones;
	var _spawn_zone = undefined;
	for (var _zone_index = 0; _zone_index < array_length(_zones); ++_zone_index)
	{
		var _zone = _zones[_zone_index];
		var _occupied = false;
		with (o_living_house)
		{
			if (hp > 0 && point_in_rectangle(x, y, _zone.left, _zone.top, _zone.right, _zone.bottom)) _occupied = true;
		}
		with (o_base_tower)
		{
			if (hp > 0 && point_in_rectangle(x, y, _zone.left, _zone.top, _zone.right, _zone.bottom)) _occupied = true;
		}
		if (_occupied) { _spawn_zone = _zone; break; }
	}
	if (is_undefined(_spawn_zone)) return;
	var _spawn_x = _spawn_zone.left - BALANCE_ENEMY_ZONE_SPAWN_OFFSET;
	var _spawn_y = (_spawn_zone.top + _spawn_zone.bottom) * 0.5;
	var _types = [o_enemy_peasant, o_enemy_archer, o_enemy_knight, o_enemy_mage, o_enemy_catapult];
	var _counts = fight_wave_counts_get(fight_wave_index + 1);
	var _half_height = BALANCE_FIGHT_BATTLEFIELD_HEIGHT * 0.5;
	for (var _i = 0; _i < array_length(_types); ++_i)
	{
		for (var _unit = 0; _unit < _counts[_i]; ++_unit)
		{
			var _enemy = instance_create_layer(_spawn_x,
				_spawn_y + random_range(-_half_height, _half_height), "Instances", _types[_i]);
			_enemy.unit_can_attack_cannon = true;
			_enemy.target_instance = instance_find(o_heart, 0);
		}
	}
	fight_wave_index++;
	fight_next_wave_seconds = fight_elapsed_seconds + random_range(BALANCE_WAVE_INTERVAL_MIN, BALANCE_WAVE_INTERVAL_MAX);
}
