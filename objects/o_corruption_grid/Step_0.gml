// Pause freezes passive ground corruption spread.
if (global.pause)
{
	exit;
}

passive_spread_update_timer++;

if (passive_spread_update_timer mod passive_spread_update_interval != 0)
{
	exit;
}

var _spread_corruption = passive_spread_per_second * (passive_spread_update_interval / room_speed);

// Fully corrupted cells slowly infect all 8 neighbor cells up to passive_spread_limit.
for (var _cell_x = 0; _cell_x < grid_width; ++_cell_x)
{
	for (var _cell_y = 0; _cell_y < grid_height; ++_cell_y)
	{
		var _corruption = ds_grid_get(corruption_grid, _cell_x, _cell_y);

		if (_corruption >= full_corruption_value)
		{
			for (var _offset_x = neighbor_offset_min; _offset_x <= neighbor_offset_max; ++_offset_x)
			{
				for (var _offset_y = neighbor_offset_min; _offset_y <= neighbor_offset_max; ++_offset_y)
				{
					var _is_current_cell = (_offset_x == 0 && _offset_y == 0);

					if (!_is_current_cell)
					{
						var _target_cell_x = _cell_x + _offset_x;
						var _target_cell_y = _cell_y + _offset_y;
						var _is_inside_grid = (
							_target_cell_x >= 0
							&& _target_cell_x < grid_width
							&& _target_cell_y >= 0
							&& _target_cell_y < grid_height
						);

						if (_is_inside_grid)
						{
							var _holy_count = ds_grid_get(holy_grid, _target_cell_x, _target_cell_y);

							if (_holy_count <= 0)
							{
								var _target_corruption = ds_grid_get(corruption_grid, _target_cell_x, _target_cell_y);

								if (_target_corruption < passive_spread_limit)
								{
									var _new_corruption = min(_target_corruption + _spread_corruption, passive_spread_limit);
									ds_grid_set(corruption_grid, _target_cell_x, _target_cell_y, _new_corruption);
								}
							}
						}
					}
				}
			}
		}
	}
}
