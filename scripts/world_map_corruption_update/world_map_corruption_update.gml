/// @description Fills newly captured ground cells using stable row offsets and the animated campaign frontier.
function world_map_corruption_update(_map)
{
	if (!instance_exists(_map)) return;
	var _grid = _map.taint_grid_instance;
	if (!instance_exists(_grid)) return;
	var _world_boundary = _map.taint_boundary_x * room_width / _map.gui_width;
	var _base_column = clamp(floor(_world_boundary / _grid.cell_size), 0, _grid.grid_width);
	if (_base_column == _map.taint_applied_column) return;
	_map.taint_applied_column = _base_column;

	// Extend each row only into new cells; decorative trees read this same grid at their trunks.
	var _row_count = _grid.grid_height;
	for (var _row = 0; _row < _row_count; ++_row)
	{
		var _column_count = _base_column > 0
			? clamp(_base_column + _map.taint_row_offsets[_row], 0, _grid.grid_width)
			: 0;
		var _previous_count = _map.taint_row_columns[_row];
		if (_column_count <= _previous_count) continue;
		ds_grid_set_region(_grid.corruption_grid, _previous_count, _row,
			_column_count - 1, _row, _grid.full_corruption_value);
		_map.taint_row_columns[_row] = _column_count;
	}
}
