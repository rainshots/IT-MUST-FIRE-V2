/// @description Returns the fixed construction grid's world bounds.
function building_grid_bounds_get()
{
	var _half_width = BALANCE_BUILDING_GRID_COLUMNS * BALANCE_BUILDING_GRID_CELL_SIZE * 0.5;
	var _half_height = BALANCE_BUILDING_GRID_ROWS * BALANCE_BUILDING_GRID_CELL_SIZE * 0.5;
	return {left: BALANCE_BUILDING_GRID_CENTER_X - _half_width, right: BALANCE_BUILDING_GRID_CENTER_X + _half_width,
		top: BALANCE_BUILDING_GRID_CENTER_Y - _half_height, bottom: BALANCE_BUILDING_GRID_CENTER_Y + _half_height};
}
