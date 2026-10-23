/// @description Broken outpost Idols block all work in their grid except their own repair.
function building_grid_work_enabled(_building)
{
	if (_building.object_index == o_new_idol) return _building.hp <= 0;
	var _grid = building_grid_bounds_get(_building.x, _building.y);
	return !variable_struct_exists(_grid, "idol") || (instance_exists(_grid.idol) && _grid.idol.hp > 0);
}
