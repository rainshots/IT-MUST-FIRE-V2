/// @description Returns the farthest unlocked construction grid toward the enemy base.
function building_grid_latest_get()
{
	var _grids = building_grids_get();
	var _latest = _grids[0];
	for (var _i = 1; _i < array_length(_grids); ++_i)
		if (_grids[_i].right > _latest.right) _latest = _grids[_i];
	return _latest;
}
