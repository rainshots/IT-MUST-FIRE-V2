/// @description Returns the nearest grid-aligned building center without clamping invalid placements.
function building_grid_snap(_building, _x, _y)
{
	var _grid = building_grid_bounds_get(_x, _y);
	var _size = BALANCE_BUILDING_GRID_CELL_SIZE;
	var _half_width = _building.grid_columns * _size * 0.5;
	var _half_height = _building.grid_rows * _size * 0.5;
	return {x: _grid.left + round((_x - _grid.left - _half_width) / _size) * _size + _half_width,
		y: _grid.top + round((_y - _grid.top - _half_height) / _size) * _size + _half_height};
}
