/// @description Covers the Building Grid and adds a narrow, randomized fringe around its edges.
function heart_corruption_seed()
{
	if (!instance_exists(o_heart)) return;
	if (!instance_exists(o_corruption_grid)) instance_create_layer(0, 0, "Instances", o_corruption_grid);
	var _terrain = instance_find(o_corruption_grid, 0);
	var _bounds = building_grid_bounds_get();
	var _size = _terrain.cell_size;
	// Keep the interior solid so random edges never leave construction cells uncovered.
	var _left = max(0, floor(_bounds.left / _size));
	var _right = min(_terrain.grid_width - 1, ceil(_bounds.right / _size) - 1);
	var _top = max(0, floor(_bounds.top / _size));
	var _bottom = min(_terrain.grid_height - 1, ceil(_bounds.bottom / _size) - 1);
	for (var _cx = _left; _cx <= _right; ++_cx)
	{
		var _edge_top = max(0, _top - irandom(BALANCE_HEART_CORRUPTION_EDGE_CELLS));
		var _edge_bottom = min(_terrain.grid_height - 1, _bottom + irandom(BALANCE_HEART_CORRUPTION_EDGE_CELLS));
		for (var _cy = _edge_top; _cy <= _edge_bottom; ++_cy)
			_terrain.corruption_cell_apply(_cx, _cy, 1, FACTION.UNDEAD);
	}
	// Side protrusions attach directly to the filled interior, without detached speckles.
	for (var _cy = _top; _cy <= _bottom; ++_cy)
	{
		var _edge_left = max(0, _left - irandom(BALANCE_HEART_CORRUPTION_EDGE_CELLS));
		var _edge_right = min(_terrain.grid_width - 1, _right + irandom(BALANCE_HEART_CORRUPTION_EDGE_CELLS));
		for (var _cx = _edge_left; _cx < _left; ++_cx)
			_terrain.corruption_cell_apply(_cx, _cy, 1, FACTION.UNDEAD);
		for (var _cx = _right + 1; _cx <= _edge_right; ++_cx)
			_terrain.corruption_cell_apply(_cx, _cy, 1, FACTION.UNDEAD);
	}

	// Trim approximately five percent of the seeded area from its fringe only.
	var _fringe = [];
	var _total = 0;
	var _edge = BALANCE_HEART_CORRUPTION_EDGE_CELLS;
	for (var _cx = max(0, _left - _edge); _cx <= min(_terrain.grid_width - 1, _right + _edge); ++_cx)
	{
		for (var _cy = max(0, _top - _edge); _cy <= min(_terrain.grid_height - 1, _bottom + _edge); ++_cy)
		{
			if (ds_grid_get(_terrain.corruption_grid, _cx, _cy) <= 0) continue;
			_total++;
			if (_cx < _left || _cx > _right || _cy < _top || _cy > _bottom)
				array_push(_fringe, {x: _cx, y: _cy});
		}
	}
	var _remove = min(array_length(_fringe), round(_total * BALANCE_START_CORRUPTION_REDUCTION));
	for (var _i = 0; _i < _remove; ++_i)
	{
		var _pick = irandom_range(_i, array_length(_fringe) - 1);
		var _cell = _fringe[_pick];
		_fringe[_pick] = _fringe[_i];
		ds_grid_set(_terrain.corruption_grid, _cell.x, _cell.y, 0);
		ds_grid_set(_terrain.corruption_faction_grid, _cell.x, _cell.y, FACTION.NONE);
	}
}
