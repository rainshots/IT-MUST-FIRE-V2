/// @description Returns base capacity plus passive bonuses from placed grid buildings.
function player_unit_cap_get()
{
	var _capacity = BALANCE_PLAYER_UNIT_CAP;
	var _grid = building_grid_bounds_get();
	with (o_worker_building_parent)
	{
		if (unit_capacity_bonus <= 0 || placement_preview || is_being_dragged) continue;
		var _bounds = building_bounds_get(id, x, y);
		if (_bounds.left >= _grid.left && _bounds.right <= _grid.right
			&& _bounds.top >= _grid.top && _bounds.bottom <= _grid.bottom)
			_capacity += unit_capacity_bonus;
	}
	return _capacity;
}
