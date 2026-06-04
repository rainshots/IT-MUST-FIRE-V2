// Fog of war draws above the world and hides unexplored map cells.
draw_above_world_depth = BALANCE_FOG_OF_WAR_DEPTH;
depth = draw_above_world_depth;

// Fog grid uses the same 100x100 cell size as ground corruption.
cell_size = BALANCE_GRID_CELL_SIZE;
grid_width = ceil(room_width / cell_size);
grid_height = ceil(room_height / cell_size);
fog_grid = ds_grid_create(grid_width, grid_height);
ds_grid_clear(fog_grid, 1);

// Fog alpha values: hidden, edge transition, and revealed.
hidden_alpha = 1;
edge_alpha = 0.5;
revealed_alpha = 0;
fog_color = c_black;

// Fully corrupted ground reveals fog nearby.
full_corruption_value = 1;
reveal_radius_in_cells = BALANCE_FOG_REVEAL_RADIUS_IN_CELLS;
demon_reveal_radius_in_pixels = BALANCE_DEMON_FOG_REVEAL_RADIUS_IN_PIXELS;
demon_reveal_radius_in_cells = ceil(demon_reveal_radius_in_pixels / cell_size);
neighbor_offset_min = -1;
neighbor_offset_max = 1;

// Fog is recalculated periodically because corruption does not need instant visual updates every frame.
update_interval = BALANCE_FOG_UPDATE_INTERVAL;
update_timer = update_interval;

// Reveal a circular area in fog grid cell coordinates.
fog_circle_reveal = function(_center_cell_x, _center_cell_y, _radius_in_cells)
{
	var _left_cell = clamp(_center_cell_x - _radius_in_cells, 0, grid_width - 1);
	var _right_cell = clamp(_center_cell_x + _radius_in_cells, 0, grid_width - 1);
	var _top_cell = clamp(_center_cell_y - _radius_in_cells, 0, grid_height - 1);
	var _bottom_cell = clamp(_center_cell_y + _radius_in_cells, 0, grid_height - 1);

	for (var _reveal_cell_x = _left_cell; _reveal_cell_x <= _right_cell; ++_reveal_cell_x)
	{
		for (var _reveal_cell_y = _top_cell; _reveal_cell_y <= _bottom_cell; ++_reveal_cell_y)
		{
			var _distance_x = _reveal_cell_x - _center_cell_x;
			var _distance_y = _reveal_cell_y - _center_cell_y;
			var _cell_distance = point_distance(0, 0, _distance_x, _distance_y);

			if (_cell_distance <= _radius_in_cells)
			{
				ds_grid_set(fog_grid, _reveal_cell_x, _reveal_cell_y, revealed_alpha);
			}
		}
	}
};
