/// @description Returns the original grid, or the nearest unlocked grid when world coordinates are supplied.
function building_grid_bounds_get(_x = undefined, _y = undefined)
{
	if (!is_undefined(_x) && instance_exists(o_building_grid))
	{
		var _grids = o_building_grid.building_grids;
		var _nearest = _grids[0];
		var _distance = infinity;
		for (var _i = 0; _i < array_length(_grids); ++_i)
		{
			var _grid = _grids[_i];
			var _candidate = point_distance(_x, _y, clamp(_x, _grid.left, _grid.right), clamp(_y, _grid.top, _grid.bottom));
			if (_candidate < _distance) { _nearest = _grid; _distance = _candidate; }
		}
		return _nearest;
	}
	var _half_width = BALANCE_BUILDING_GRID_COLUMNS * BALANCE_BUILDING_GRID_CELL_SIZE * 0.5;
	var _half_height = BALANCE_BUILDING_GRID_ROWS * BALANCE_BUILDING_GRID_CELL_SIZE * 0.5;
	return {left: BALANCE_BUILDING_GRID_CENTER_X - _half_width, right: BALANCE_BUILDING_GRID_CENTER_X + _half_width,
		top: BALANCE_BUILDING_GRID_CENTER_Y - _half_height, bottom: BALANCE_BUILDING_GRID_CENTER_Y + _half_height};
}
