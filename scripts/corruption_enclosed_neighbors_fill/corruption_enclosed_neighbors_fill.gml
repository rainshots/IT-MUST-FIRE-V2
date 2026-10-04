/// @description Fills empty cardinal neighbors enclosed by Taint. Call only when a cell changes from zero to positive corruption.
/// @param {Id.Instance} ground Corruption-grid controller owning the changed cell.
/// @param {real} new_cell_x Newly infected grid column.
/// @param {real} new_cell_y Newly infected grid row.
function corruption_enclosed_neighbors_fill(_ground, _new_cell_x, _new_cell_y)
{
	if (!instance_exists(_ground))
	{
		return;
	}

	// Reuse wall occupancy; a geometry rebuild occurs only when the existing cache is dirty.
	var _walls = _ground.wall_block_grid_get();
	var _taint = _ground.corruption_grid;
	var _saint = _ground.saint_grid;
	var _width = _ground.grid_width;
	var _height = _ground.grid_height;
	if (_new_cell_x < 0 || _new_cell_x >= _width || _new_cell_y < 0 || _new_cell_y >= _height
		|| ds_grid_get(_taint, _new_cell_x, _new_cell_y) <= 0
		|| ds_grid_get(_saint, _new_cell_x, _new_cell_y) > 0
		|| ds_grid_get(_walls, _new_cell_x, _new_cell_y))
	{
		return;
	}

	var _offsets = _ground.enclosure_neighbor_offsets;
	var _neighbor_count = array_length(_offsets);
	var _fill_amount = clamp(BALANCE_CORRUPTION_ENCLOSED_CELL_AMOUNT, 0, _ground.full_corruption_value);
	for (var _index = 0; _index < _neighbor_count; ++_index)
	{
		var _cell_x = _new_cell_x + _offsets[_index][0];
		var _cell_y = _new_cell_y + _offsets[_index][1];

		// Border cells cannot have all four neighbors. Existing Taint, walls, and Saint are excluded.
		if (_cell_x <= 0 || _cell_x >= _width - 1 || _cell_y <= 0 || _cell_y >= _height - 1
			|| ds_grid_get(_taint, _cell_x, _cell_y) > 0
			|| ds_grid_get(_walls, _cell_x, _cell_y)
			|| ds_grid_get(_saint, _cell_x, _cell_y) > 0)
		{
			continue;
		}

		var _enclosed = true;
		for (var _side = 0; _side < _neighbor_count; ++_side)
		{
			var _neighbor_x = _cell_x + _offsets[_side][0];
			var _neighbor_y = _cell_y + _offsets[_side][1];
			if (ds_grid_get(_taint, _neighbor_x, _neighbor_y) <= 0
				|| ds_grid_get(_saint, _neighbor_x, _neighbor_y) > 0
				|| ds_grid_get(_walls, _neighbor_x, _neighbor_y))
			{
				_enclosed = false;
				break;
			}
		}

		if (_enclosed)
		{
			// All four neighbors are already infected, so this fill cannot create another empty candidate.
			ds_grid_set(_taint, _cell_x, _cell_y, _fill_amount);
		}
	}
}
