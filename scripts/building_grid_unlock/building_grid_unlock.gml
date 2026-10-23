/// @description Creates a ten-by-ten outpost halfway from the previous grid to the next enemy zone.
function building_grid_unlock(_zone_index)
{
	var _manager = instance_find(o_building_grid, 0);
	var _previous = building_grid_latest_get();
	var _next = _manager.enemy_zones[_zone_index + 1];
	var _center_x = (_previous.left + _previous.right + _next.left + _next.right) * 0.25;
	var _center_y = (_previous.top + _previous.bottom + _next.top + _next.bottom) * 0.25;
	var _half = BALANCE_EXTRA_GRID_SLOTS * BALANCE_BUILDING_GRID_CELL_SIZE * 0.5;
	var _grid = {left: _center_x - _half, right: _center_x + _half,
		top: _center_y - _half, bottom: _center_y + _half, idol: noone};
	array_push(_manager.building_grids, _grid);
	_grid.idol = instance_create_layer(_center_x, _center_y, "Instances", o_new_idol);
	building_grid_trash_spawn(_grid, BALANCE_EXTRA_GRID_TRASH_SHARE);
	return _grid;
}
