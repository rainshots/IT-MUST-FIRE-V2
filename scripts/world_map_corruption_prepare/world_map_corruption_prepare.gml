/// @description Restores the map's ground grid and its persistent uneven frontier after room instances are ready.
function world_map_corruption_prepare(_map)
{
	if (!instance_exists(_map)) return;
	var _grid = instance_find(o_corruption_grid, 0);
	if (!instance_exists(_grid))
	{
		var _ground_layer = layer_get_id(_map.taint_layer_name);
		if (_ground_layer == -1) return;
		_grid = instance_create_layer(0, 0, _ground_layer, o_corruption_grid);
	}
	_map.taint_grid_instance = _grid;
	_map.taint_applied_column = -1;
	_map.taint_row_columns = array_create(_grid.grid_height, 0);
	ds_grid_clear(_grid.corruption_grid, 0);
	ds_grid_clear(_grid.saint_grid, 0);
	ds_grid_clear(_grid.saint_source_grid, 0);

	// Keep the same small row offsets across battles, and reroll only if the room height changes.
	var _row_count = _grid.grid_height;
	if (array_length(_map.taint_row_offsets) != _row_count)
	{
		_map.taint_row_offsets = array_create(_row_count, 0);
		var _offset = 0;
		var _rows_until_change = 0;
		for (var _row = 0; _row < _row_count; ++_row)
		{
			if (_rows_until_change <= 0)
			{
				var _direction = choose(-1, 1);
				if (abs(_offset + _direction) > _map.taint_edge_variation_cells) _direction = -_direction;
				_offset += _direction;
				_rows_until_change = irandom_range(_map.taint_edge_min_band_rows, _map.taint_edge_max_band_rows);
			}
			_map.taint_row_offsets[_row] = _offset;
			_rows_until_change--;
		}
	}
	world_map_corruption_update(_map);

	// Trees already inside captured territory use their corrupted sprite on the first visible frame.
	with (o_tree) tree_corruption_update();
}
