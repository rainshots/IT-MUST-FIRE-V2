/// @description Returns all unlocked construction grids, including the original grid.
function building_grids_get()
{
	if (instance_exists(o_building_grid)) return o_building_grid.building_grids;
	return [building_grid_bounds_get()];
}
