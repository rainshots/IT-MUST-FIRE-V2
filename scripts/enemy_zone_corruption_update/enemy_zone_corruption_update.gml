/// @description Seeds 80 percent of a territory once its enemy buildings are destroyed.
function enemy_zone_corruption_update()
{
	if (!instance_exists(o_building_grid) || !instance_exists(o_corruption_grid)) return;
	var _grid = instance_find(o_building_grid, 0);
	var _terrain = instance_find(o_corruption_grid, 0);
	var _size = _terrain.cell_size;
	for (var _i = 0; _i < array_length(_grid.enemy_zones); ++_i)
	{
		if (_grid.enemy_zone_corrupted[_i]) continue;
		var _zone = _grid.enemy_zones[_i];
		var _occupied = false;
		with (o_living_house)
			if (hp > 0 && point_in_rectangle(x, y, _zone.left, _zone.top, _zone.right, _zone.bottom)) _occupied = true;
		with (o_base_tower)
			if (hp > 0 && point_in_rectangle(x, y, _zone.left, _zone.top, _zone.right, _zone.bottom)) _occupied = true;
		if (_occupied) continue;
		_grid.enemy_zone_corrupted[_i] = true;
		var _cells = [];
		for (var _cx = max(0, ceil(_zone.left / _size - 0.5)); _cx < min(_terrain.grid_width, ceil(_zone.right / _size - 0.5)); ++_cx)
			for (var _cy = max(0, ceil(_zone.top / _size - 0.5)); _cy < min(_terrain.grid_height, ceil(_zone.bottom / _size - 0.5)); ++_cy)
				array_push(_cells, {x: _cx, y: _cy});
		var _count = array_length(_cells);
		var _fill = round(_count * BALANCE_CLEARED_ZONE_CORRUPTION_SHARE);
		// Partial shuffle chooses unique random cells without repeated rolls.
		for (var _n = 0; _n < _fill; ++_n)
		{
			var _pick = irandom_range(_n, _count - 1);
			var _cell = _cells[_pick];
			_cells[_pick] = _cells[_n];
			_cells[_n] = _cell;
			_terrain.corruption_cell_apply(_cell.x, _cell.y, 1, FACTION.UNDEAD);
		}
	}
}
