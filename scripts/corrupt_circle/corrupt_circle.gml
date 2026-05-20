/// @description Adds corruption to ground cells inside a circle.
/// @param {real} center_x World X coordinate.
/// @param {real} center_y World Y coordinate.
/// @param {real} rad Radius in pixels. A radius of 1 corrupts only the cell containing the center.
/// @param {real} corruption Corruption amount to add, clamped by the grid to 0..1.
function corrupt_circle(center_x, center_y, rad, corruption)
{
	if (!instance_exists(o_corruption_grid))
	{
		return;
	}

	var _corruption_grid = instance_find(o_corruption_grid, 0);
	_corruption_grid.corrupt_circle(center_x, center_y, rad, corruption);
}
