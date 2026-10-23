/// @description Returns the grid and enemy-zone envelope plus margin, clipped to the room.
function camera_play_bounds_get()
{
	if (!instance_exists(o_building_grid)) return {left: 0, top: 0, right: room_width, bottom: room_height};
	var _bounds = building_grid_bounds_get();
	var _zones = o_building_grid.enemy_zones;
	for (var _i = 0; _i < array_length(_zones); ++_i)
	{
		_bounds.left = min(_bounds.left, _zones[_i].left);
		_bounds.right = max(_bounds.right, _zones[_i].right);
		_bounds.top = min(_bounds.top, _zones[_i].top);
		_bounds.bottom = max(_bounds.bottom, _zones[_i].bottom);
	}
	_bounds.left = max(0, _bounds.left - BALANCE_CAMERA_PLAY_AREA_MARGIN);
	_bounds.right = min(room_width, _bounds.right + BALANCE_CAMERA_PLAY_AREA_MARGIN);
	_bounds.top = max(0, _bounds.top - BALANCE_CAMERA_PLAY_AREA_MARGIN);
	_bounds.bottom = min(room_height, _bounds.bottom + BALANCE_CAMERA_PLAY_AREA_MARGIN);
	return _bounds;
}
