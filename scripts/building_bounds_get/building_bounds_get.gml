/// @description Returns the building's occupied grid footprint in world coordinates.
function building_bounds_get(_b, _x, _y)
{
	var _half_width = _b.grid_columns * BALANCE_BUILDING_GRID_CELL_SIZE * 0.5;
	var _half_height = _b.grid_rows * BALANCE_BUILDING_GRID_CELL_SIZE * 0.5;
	return {left: _x - _half_width, right: _x + _half_width, top: _y - _half_height, bottom: _y + _half_height};
}
