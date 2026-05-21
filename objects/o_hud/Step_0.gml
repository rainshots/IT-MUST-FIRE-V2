// Update derived corruption counter at a small fixed interval.
corruption_update_timer++;

if (corruption_update_timer < corruption_update_interval)
{
	exit;
}

corruption_update_timer = 0;

if (!instance_exists(o_corruption_grid))
{
	corruption_display_value = 0;
	exit;
}

var _corruption_grid = instance_find(o_corruption_grid, 0);
var _total_corruption = 0;

// Sum all cell values. A fully corrupted cell contributes 1.
for (var _cell_x = 0; _cell_x < _corruption_grid.grid_width; ++_cell_x)
{
	for (var _cell_y = 0; _cell_y < _corruption_grid.grid_height; ++_cell_y)
	{
		_total_corruption += ds_grid_get(_corruption_grid.corruption_grid, _cell_x, _cell_y);
	}
}

corruption_display_value = _total_corruption;
