/// @description Expands corruption with tapered diamond growth and lightly randomized outer tips.
function corruption_wave_spread()
{
	if (!instance_exists(o_corruption_grid)) return;
	var _terrain = instance_find(o_corruption_grid, 0);
	var _sources = [];
	var _width = _terrain.grid_width;
	var _height = _terrain.grid_height;
	var _candidates = ds_grid_create(_width, _height);
	ds_grid_clear(_candidates, 0);
	// Snapshot existing patches so growth never cascades within a wave.
	for (var _cx = 0; _cx < _width; ++_cx)
		for (var _cy = 0; _cy < _height; ++_cy)
			if (ds_grid_get(_terrain.corruption_grid, _cx, _cy) >= _terrain.minimum_draw_corruption)
				array_push(_sources, {x: _cx, y: _cy});
	var _count = array_length(_sources);
	for (var _i = 0; _i < _count; ++_i)
	{
		var _source = _sources[_i];
		for (var _dx = -BALANCE_CORRUPTION_WAVE_SPREAD_X; _dx <= BALANCE_CORRUPTION_WAVE_SPREAD_X; ++_dx)
		{
			for (var _dy = -BALANCE_CORRUPTION_WAVE_SPREAD_Y; _dy <= BALANCE_CORRUPTION_WAVE_SPREAD_Y; ++_dy)
			{
				// Weighted Manhattan distance creates sloping sides instead of rectangular corners.
				var _distance = abs(_dx) / BALANCE_CORRUPTION_WAVE_SPREAD_X
					+ abs(_dy) / BALANCE_CORRUPTION_WAVE_SPREAD_Y;
				if (_distance > 1) continue;
				var _x = _source.x + _dx;
				var _y = _source.y + _dy;
				if (_x < 0 || _y < 0 || _x >= _width || _y >= _height) continue;
				var _chance = _distance < 1 ? 1 : BALANCE_CORRUPTION_WAVE_EDGE_CHANCE;
				ds_grid_set(_candidates, _x, _y, max(_chance, ds_grid_get(_candidates, _x, _y)));
			}
		}
	}
	// Roll once per destination, avoiding extra growth where many source cells overlap.
	for (var _cx = 0; _cx < _width; ++_cx)
	{
		for (var _cy = 0; _cy < _height; ++_cy)
		{
			var _chance = ds_grid_get(_candidates, _cx, _cy);
			if (_chance > 0 && random(1) < _chance)
				_terrain.corruption_cell_apply(_cx, _cy, 1, FACTION.UNDEAD);
		}
	}
	ds_grid_destroy(_candidates);
}
