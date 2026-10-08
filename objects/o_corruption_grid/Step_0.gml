corruption_protection_timer += 1;
if (corruption_protection_timer >= max(1, room_speed * 0.25))
{
	corruption_protection_timer = 0;
	corruption_protection_dirty = true;
}
// Seed after room creation, including while the faction chooser pauses simulation.
if (!base_corruption_initialized)
{
	base_corruption_initialized = true;
	with (o_faction_base_parent)
	{
		if (hp > 0) other.corrupt_circle(x, y, BALANCE_FACTION_BASE_CORRUPTION_RADIUS, 1, faction);
	}
}
if (global.pause) exit;
var _time_scale = variable_global_exists("gameplay_time_scale") ? global.gameplay_time_scale : 1;
passive_spread_update_timer += _time_scale;
if (passive_spread_update_timer < passive_spread_update_interval) exit;
passive_spread_update_timer -= passive_spread_update_interval;
var _amount = passive_spread_per_second * passive_spread_update_interval / room_speed;

// Snapshot sources so replacing a neighbor cannot change this tick's source order.
var _sources = [];
for (var _cx = 0; _cx < grid_width; ++_cx)
{
	for (var _cy = 0; _cy < grid_height; ++_cy)
	{
		if (ds_grid_get(corruption_grid, _cx, _cy) >= full_corruption_value)
			array_push(_sources, {cell_x: _cx, cell_y: _cy, faction: ds_grid_get(corruption_faction_grid, _cx, _cy)});
	}
}
var _count = array_length(_sources);
for (var _index = 0; _index < _count; ++_index)
{
	var _source = _sources[_index];
	for (var _dx = -1; _dx <= 1; ++_dx)
	{
		for (var _dy = -1; _dy <= 1; ++_dy)
		{
			if (_dx == 0 && _dy == 0) continue;
			var _tx = _source.cell_x + _dx;
			var _ty = _source.cell_y + _dy;
			if (_tx < 0 || _ty < 0 || _tx >= grid_width || _ty >= grid_height) continue;
			corruption_cell_apply(_tx, _ty, _amount, _source.faction, passive_spread_limit);
		}
	}
}
