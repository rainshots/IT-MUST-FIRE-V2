/// @description Returns the corridor ahead of a patch's grid, ending at the nearest grid to its right.
function pumpkin_mine_area_get(_patch)
{
	var _home = building_grid_bounds_get(_patch.x, _patch.y);
	var _right = room_width;
	var _grids = building_grids_get();
	for (var _i = 0; _i < array_length(_grids); ++_i)
		if (_grids[_i].left >= _home.right) _right = min(_right, _grids[_i].left);
	if (instance_exists(o_building_grid))
	{
		var _zones = o_building_grid.enemy_zones;
		for (var _i = 0; _i < array_length(_zones); ++_i)
			if (_zones[_i].left >= _home.right) _right = min(_right, _zones[_i].left);
	}
	var _inset = BALANCE_PUMPKIN_DRAW_SIZE * 0.5;
	if (_right - _home.right <= _inset * 2) return undefined;
	var _center_y = (_home.top + _home.bottom) * 0.5;
	return {left: _home.right + _inset, right: _right - _inset,
		top: max(_inset, _center_y - BALANCE_PUMPKIN_SPAWN_HALF_HEIGHT),
		bottom: min(room_height - _inset, _center_y + BALANCE_PUMPKIN_SPAWN_HALF_HEIGHT)};
}
