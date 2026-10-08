event_inherited();
if (global.pause || is_recovering || faction_is_defeated(faction)) exit;
if (!house_garrison_initialized)
{
	house_garrison_initialized = true;
	house_guards_spawn(house_unit_limit);
	house_spawn_timer = BALANCE_HOUSE_COMBAT_SPAWN_INTERVAL;
}
house_spawn_timer -= global.gameplay_time_scale / max(1, room_speed);
if (house_spawn_timer <= 0)
{
	house_spawn_timer = BALANCE_HOUSE_COMBAT_SPAWN_INTERVAL;
	var _hostile_nearby = false;
	with (o_units_parent)
	{
		if (hp > 0 && faction_target_is_hostile(other.faction, id)
			&& point_distance(x, y, other.x, other.y) <= BALANCE_HOUSE_COMBAT_SPAWN_RADIUS) _hostile_nearby = true;
	}
	if (_hostile_nearby) house_guards_spawn(max(1, floor(house_unit_limit / BALANCE_HOUSE_COMBAT_SPAWN_LIMIT_PER_UNIT)));
}
