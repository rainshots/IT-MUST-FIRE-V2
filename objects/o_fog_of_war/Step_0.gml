// Pause freezes fog updates together with gameplay state changes.
if (global.pause)
{
	exit;
}

update_timer++;

if (update_timer < update_interval)
{
	exit;
}

update_timer = 0;

// Fog depends on the corruption grid, so keep all cells hidden until the grid exists.
ds_grid_clear(fog_grid, hidden_alpha);

if (!instance_exists(o_corruption_grid))
{
	exit;
}

var _corruption_grid_object = instance_find(o_corruption_grid, 0);

// Fully corrupted cells reveal nearby fog in a circular cell radius.
for (var _cell_x = 0; _cell_x < grid_width; ++_cell_x)
{
	for (var _cell_y = 0; _cell_y < grid_height; ++_cell_y)
	{
		var _corruption = ds_grid_get(_corruption_grid_object.corruption_grid, _cell_x, _cell_y);

		if (_corruption >= full_corruption_value)
		{
			var _left_cell = clamp(_cell_x - reveal_radius_in_cells, 0, grid_width - 1);
			var _right_cell = clamp(_cell_x + reveal_radius_in_cells, 0, grid_width - 1);
			var _top_cell = clamp(_cell_y - reveal_radius_in_cells, 0, grid_height - 1);
			var _bottom_cell = clamp(_cell_y + reveal_radius_in_cells, 0, grid_height - 1);

			for (var _reveal_cell_x = _left_cell; _reveal_cell_x <= _right_cell; ++_reveal_cell_x)
			{
				for (var _reveal_cell_y = _top_cell; _reveal_cell_y <= _bottom_cell; ++_reveal_cell_y)
				{
					var _distance_x = _reveal_cell_x - _cell_x;
					var _distance_y = _reveal_cell_y - _cell_y;
					var _cell_distance = point_distance(0, 0, _distance_x, _distance_y);

					if (_cell_distance <= reveal_radius_in_cells)
					{
						ds_grid_set(fog_grid, _reveal_cell_x, _reveal_cell_y, revealed_alpha);
					}
				}
			}
		}
	}
}

// Revealed cells soften the edge by turning directly neighboring hidden cells into half-transparent fog.
for (var _cell_x = 0; _cell_x < grid_width; ++_cell_x)
{
	for (var _cell_y = 0; _cell_y < grid_height; ++_cell_y)
	{
		var _fog_alpha = ds_grid_get(fog_grid, _cell_x, _cell_y);

		if (_fog_alpha == revealed_alpha)
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
							var _target_fog_alpha = ds_grid_get(fog_grid, _target_cell_x, _target_cell_y);

							if (_target_fog_alpha == hidden_alpha)
							{
								ds_grid_set(fog_grid, _target_cell_x, _target_cell_y, edge_alpha);
							}
						}
					}
				}
			}
		}
	}
}
