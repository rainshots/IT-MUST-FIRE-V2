// Pause freezes forest corruption spread.
if (global.pause)
{
	exit;
}

if (!instance_exists(o_corruption_grid))
{
	exit;
}

var _corruption_grid = instance_find(o_corruption_grid, 0);
var _cell_x = clamp(floor(x / _corruption_grid.cell_size), 0, _corruption_grid.grid_width - 1);
var _cell_y = clamp(floor(y / _corruption_grid.cell_size), 0, _corruption_grid.grid_height - 1);
var _current_cell_corruption = ds_grid_get(_corruption_grid.corruption_grid, _cell_x, _cell_y);
var _spread_corruption = spread_corruption_per_second / room_speed;

// Forest starts spreading only when the ground under it is fully corrupted.
if (_current_cell_corruption < full_corruption_value)
{
	exit;
}

// Switch forest visual state when its ground cell is fully corrupted.
if (!is_fully_corrupted)
{
	is_fully_corrupted = true;

	if (cursed_sprite_index != -1)
	{
		sprite_index = cursed_sprite_index;
	}
}

// Corrupt left neighbor cell.
corrupt_neighbor_cell(_corruption_grid, _cell_x, _cell_y, spread_offset_left_x, 0, _spread_corruption);

// Corrupt right neighbor cell.
corrupt_neighbor_cell(_corruption_grid, _cell_x, _cell_y, spread_offset_right_x, 0, _spread_corruption);

// Corrupt upper neighbor cell.
corrupt_neighbor_cell(_corruption_grid, _cell_x, _cell_y, 0, spread_offset_up_y, _spread_corruption);

// Corrupt lower neighbor cell.
corrupt_neighbor_cell(_corruption_grid, _cell_x, _cell_y, 0, spread_offset_down_y, _spread_corruption);

// Corrupt diagonal neighbor cells.
corrupt_neighbor_cell(_corruption_grid, _cell_x, _cell_y, spread_offset_left_x, spread_offset_up_y, _spread_corruption);
corrupt_neighbor_cell(_corruption_grid, _cell_x, _cell_y, spread_offset_right_x, spread_offset_up_y, _spread_corruption);
corrupt_neighbor_cell(_corruption_grid, _cell_x, _cell_y, spread_offset_left_x, spread_offset_down_y, _spread_corruption);
corrupt_neighbor_cell(_corruption_grid, _cell_x, _cell_y, spread_offset_right_x, spread_offset_down_y, _spread_corruption);
