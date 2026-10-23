// Each outpost has an immovable 2x2 Idol with half the Heart's health on spawn.
event_inherited();
grid_columns = BALANCE_BUILDING_GRID_DEFAULT_SLOTS;
grid_rows = BALANCE_BUILDING_GRID_DEFAULT_SLOTS;
placement_size = BALANCE_BUILDING_GRID_DEFAULT_SLOTS * BALANCE_BUILDING_GRID_CELL_SIZE;
building_label = "New Idol";
building_can_move = false;
building_accepts_workers = false;
worker_max = 1;
worker_uses_speed_multiplier = false;
production_interval = BALANCE_IDOL_REPAIR_SECONDS;
custom_work_status = "Repairing Idol";
smoke_seconds = 0;
is_attackable = true;
unit_faction = UNIT_FACTION.FRIENDLY;
faction = global.player_faction;
max_hp = BALANCE_HEART_MAX_HP * BALANCE_IDOL_HEALTH_SHARE;
hp = max_hp;
armor = 100;
magic_resistance = 100;
combat_radius = placement_size * 0.5;
image_speed = 0;
image_xscale = placement_size / max(sprite_get_width(sprite_index), sprite_get_height(sprite_index));
image_yscale = image_xscale;
unit_damage_receive = function(_amount, _source_faction = UNIT_FACTION.NOONE, _critical = false, _chain = true, _source = noone, _favor = FACTION.NONE)
{
	if (hp <= 0 || _amount <= 0 || _source_faction == unit_faction) return 0;
	var _applied = min(hp, _amount);
	hp -= _applied;
	damage_popup_create(x, y, _applied, unit_faction, _critical);
	if (hp <= 0) idol_break();
	return _applied;
};

// Edge-distance support makes the Idol a standard attackable player structure.
player_building_distance_to_point = function(_x, _y)
{
	var _bounds = building_bounds_get(id, x, y);
	return point_distance(_x, _y, clamp(_x, _bounds.left, _bounds.right), clamp(_y, _bounds.top, _bounds.bottom));
};
idol_break = function()
{
	hp = 0;
	is_attackable = false;
	building_accepts_workers = true;
	production_seconds = 0;
	smoke_seconds = 0;
	// Immediately release workers across this outpost, while keeping production progress.
	var _grid = building_grid_bounds_get(x, y);
	with (o_worker_building_parent)
	{
		if (id == other.id || !point_in_rectangle(x, y, _grid.left, _grid.top, _grid.right, _grid.bottom)) continue;
		for (var _i = array_length(worker_cultists) - 1; _i >= 0; --_i) worker_release(worker_cultists[_i]);
	}
};
worker_work_update = function(_seconds)
{
	if (hp > 0) return;
	production_seconds += _seconds;
	if (production_seconds + 0.000001 < production_interval) return;
	hp = max_hp;
	is_attackable = true;
	building_accepts_workers = false;
	production_seconds = 0;
	for (var _i = array_length(worker_cultists) - 1; _i >= 0; --_i) worker_release(worker_cultists[_i]);
};
