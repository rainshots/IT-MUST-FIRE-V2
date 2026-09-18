/// @description Corrupts a share of a circle's grid cells by growing from existing Taint.
/// @param {Real} _center_x World-space circle center X.
/// @param {Real} _center_y World-space circle center Y.
/// @param {Real} _radius Radius in pixels; cells are included by their centers.
/// @param {Real} _share Fraction of total in-bounds circle cells to newly corrupt.
function corruption_connected_circle_apply(_center_x, _center_y, _radius, _share)
{
	if (_radius <= 0 || _share <= 0 || !instance_exists(o_corruption_grid))
	{
		return 0;
	}

	var _ground = instance_find(o_corruption_grid, 0);
	var _walls = _ground.wall_block_grid_get();
	var _cell_size = _ground.cell_size;
	var _left = max(0, floor((_center_x - _radius) / _cell_size));
	var _right = min(_ground.grid_width - 1, floor((_center_x + _radius) / _cell_size));
	var _top = max(0, floor((_center_y - _radius) / _cell_size));
	var _bottom = min(_ground.grid_height - 1, floor((_center_y + _radius) / _cell_size));

	if (_left > _right || _top > _bottom)
	{
		return 0;
	}

	// Temporary eligibility is limited to the circle's bounding box.
	var _eligible = ds_grid_create(_right - _left + 1, _bottom - _top + 1);
	ds_grid_clear(_eligible, false);
	var _frontier = ds_list_create();
	var _circle_cell_count = 0;
	var _offset_x = [-1, 1, 0, 0];
	var _offset_y = [0, 0, -1, 1];
	var _neighbor_count = array_length(_offset_x);

	// Existing corruption is never counted as new growth; holy ground and walls block it.
	for (var _cell_x = _left; _cell_x <= _right; ++_cell_x)
	{
		for (var _cell_y = _top; _cell_y <= _bottom; ++_cell_y)
		{
			var _world_x = (_cell_x + 0.5) * _cell_size;
			var _world_y = (_cell_y + 0.5) * _cell_size;
			if (point_distance(_center_x, _center_y, _world_x, _world_y) > _radius)
			{
				continue;
			}

			_circle_cell_count++;
			var _can_corrupt = !ds_grid_get(_walls, _cell_x, _cell_y)
				&& ds_grid_get(_ground.saint_grid, _cell_x, _cell_y) <= 0
				&& ds_grid_get(_ground.corruption_grid, _cell_x, _cell_y) < _ground.minimum_draw_corruption;
			ds_grid_set(_eligible, _cell_x - _left, _cell_y - _top, _can_corrupt);
		}
	}

	// Seed the frontier only beside visible Taint, including Taint just outside the ring.
	for (var _cell_x = _left; _cell_x <= _right; ++_cell_x)
	{
		for (var _cell_y = _top; _cell_y <= _bottom; ++_cell_y)
		{
			if (!ds_grid_get(_eligible, _cell_x - _left, _cell_y - _top))
			{
				continue;
			}

			for (var _neighbor_index = 0; _neighbor_index < _neighbor_count; ++_neighbor_index)
			{
				var _neighbor_x = _cell_x + _offset_x[_neighbor_index];
				var _neighbor_y = _cell_y + _offset_y[_neighbor_index];
				if (_neighbor_x < 0 || _neighbor_x >= _ground.grid_width
					|| _neighbor_y < 0 || _neighbor_y >= _ground.grid_height)
				{
					continue;
				}

				if (!ds_grid_get(_walls, _neighbor_x, _neighbor_y)
					&& ds_grid_get(_ground.saint_grid, _neighbor_x, _neighbor_y) <= 0
					&& ds_grid_get(_ground.corruption_grid, _neighbor_x, _neighbor_y) >= _ground.minimum_draw_corruption)
				{
					ds_list_add(_frontier, _cell_y * _ground.grid_width + _cell_x);
					ds_grid_set(_eligible, _cell_x - _left, _cell_y - _top, false);
					break;
				}
			}
		}
	}

	// Each selected cell is edge-connected to Taint before it can add new frontier cells.
	var _target_count = round(_circle_cell_count * clamp(_share, 0, 1));
	var _corrupted_count = 0;
	for (var _growth_index = 0; _growth_index < _target_count; ++_growth_index)
	{
		var _frontier_count = ds_list_size(_frontier);
		if (_frontier_count <= 0)
		{
			break;
		}

		// Swap with the last entry so random removal does not shift the whole list.
		var _selected_index = irandom(_frontier_count - 1);
		var _cell_key = _frontier[| _selected_index];
		_frontier[| _selected_index] = _frontier[| _frontier_count - 1];
		ds_list_delete(_frontier, _frontier_count - 1);
		var _cell_x = _cell_key mod _ground.grid_width;
		var _cell_y = floor(_cell_key / _ground.grid_width);
		ds_grid_set(_ground.corruption_grid, _cell_x, _cell_y, _ground.full_corruption_value);
		_corrupted_count++;

		for (var _neighbor_index = 0; _neighbor_index < _neighbor_count; ++_neighbor_index)
		{
			var _neighbor_x = _cell_x + _offset_x[_neighbor_index];
			var _neighbor_y = _cell_y + _offset_y[_neighbor_index];
			if (_neighbor_x < _left || _neighbor_x > _right
				|| _neighbor_y < _top || _neighbor_y > _bottom)
			{
				continue;
			}

			if (ds_grid_get(_eligible, _neighbor_x - _left, _neighbor_y - _top))
			{
				ds_list_add(_frontier, _neighbor_y * _ground.grid_width + _neighbor_x);
				ds_grid_set(_eligible, _neighbor_x - _left, _neighbor_y - _top, false);
			}
		}
	}

	// These scratch structures exist only for this night-end operation.
	ds_list_destroy(_frontier);
	ds_grid_destroy(_eligible);
	return _corrupted_count;
}
