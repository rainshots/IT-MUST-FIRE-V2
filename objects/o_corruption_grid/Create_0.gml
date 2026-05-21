// Ground corruption grid settings.
map_assets_depth = 100;
ground_background_depth = 300;
draw_depth_between_ground_and_assets = (map_assets_depth + ground_background_depth) * 0.5;
depth = draw_depth_between_ground_and_assets;
cell_size = BALANCE_GRID_CELL_SIZE;
grid_width = ceil(room_width / cell_size);
grid_height = ceil(room_height / cell_size);

// Corruption values are stored from 0 to 1.
corruption_grid = ds_grid_create(grid_width, grid_height);
ds_grid_clear(corruption_grid, 0);

// Holy cells block corruption and cannot be corrupted at the same time.
holy_grid = ds_grid_create(grid_width, grid_height);
ds_grid_clear(holy_grid, 0);

// Passive spread makes fully corrupted cells infect their neighbors up to a limit.
full_corruption_value = 1;
passive_spread_limit = 0.5;
passive_spread_per_second = BALANCE_CORRUPTION_NEIGHBOR_SPREAD_PER_SECOND;
passive_spread_update_interval = BALANCE_CORRUPTION_NEIGHBOR_SPREAD_UPDATE_INTERVAL;
passive_spread_update_timer = 0;
neighbor_offset_min = -1;
neighbor_offset_max = 1;

// Visual settings for corrupted ground cells.
minimum_draw_corruption = 0.01;
minimum_corruption_alpha = 0.18;
maximum_corruption_alpha = 0.72;
uncorrupted_color = c_black;
maximum_corruption_color = COLOR_CORRUPTION_MAX;
holy_cell_alpha = 0.32;
holy_cell_color = COLOR_HOLY_GROUND;

change_circle_holy = function(_center_x, _center_y, _radius, _holy_delta)
{
	var _safe_radius = max(_radius, 1);
	var _center_cell_x = clamp(floor(_center_x / cell_size), 0, grid_width - 1);
	var _center_cell_y = clamp(floor(_center_y / cell_size), 0, grid_height - 1);
	var _left_cell = clamp(floor((_center_x - _safe_radius) / cell_size), 0, grid_width - 1);
	var _right_cell = clamp(floor((_center_x + _safe_radius) / cell_size), 0, grid_width - 1);
	var _top_cell = clamp(floor((_center_y - _safe_radius) / cell_size), 0, grid_height - 1);
	var _bottom_cell = clamp(floor((_center_y + _safe_radius) / cell_size), 0, grid_height - 1);

	for (var _cell_x = _left_cell; _cell_x <= _right_cell; ++_cell_x)
	{
		for (var _cell_y = _top_cell; _cell_y <= _bottom_cell; ++_cell_y)
		{
			var _cell_center_x = (_cell_x * cell_size) + (cell_size * 0.5);
			var _cell_center_y = (_cell_y * cell_size) + (cell_size * 0.5);
			var _cell_distance = point_distance(_center_x, _center_y, _cell_center_x, _cell_center_y);
			var _is_center_cell = (_cell_x == _center_cell_x && _cell_y == _center_cell_y);

			if (_cell_distance <= _safe_radius || _is_center_cell)
			{
				var _holy_count = ds_grid_get(holy_grid, _cell_x, _cell_y);
				var _new_holy_count = max(_holy_count + _holy_delta, 0);

				ds_grid_set(holy_grid, _cell_x, _cell_y, _new_holy_count);

				if (_new_holy_count > 0)
				{
					ds_grid_set(corruption_grid, _cell_x, _cell_y, 0);
				}
			}
		}
	}
};

make_circle_holy = function(_center_x, _center_y, _radius)
{
	var _holy_delta = 1;
	change_circle_holy(_center_x, _center_y, _radius, _holy_delta);
};

remove_circle_holy_and_corrupt = function(_center_x, _center_y, _radius, _corruption)
{
	var _safe_radius = max(_radius, 1);
	var _center_cell_x = clamp(floor(_center_x / cell_size), 0, grid_width - 1);
	var _center_cell_y = clamp(floor(_center_y / cell_size), 0, grid_height - 1);
	var _left_cell = clamp(floor((_center_x - _safe_radius) / cell_size), 0, grid_width - 1);
	var _right_cell = clamp(floor((_center_x + _safe_radius) / cell_size), 0, grid_width - 1);
	var _top_cell = clamp(floor((_center_y - _safe_radius) / cell_size), 0, grid_height - 1);
	var _bottom_cell = clamp(floor((_center_y + _safe_radius) / cell_size), 0, grid_height - 1);

	for (var _cell_x = _left_cell; _cell_x <= _right_cell; ++_cell_x)
	{
		for (var _cell_y = _top_cell; _cell_y <= _bottom_cell; ++_cell_y)
		{
			var _cell_center_x = (_cell_x * cell_size) + (cell_size * 0.5);
			var _cell_center_y = (_cell_y * cell_size) + (cell_size * 0.5);
			var _cell_distance = point_distance(_center_x, _center_y, _cell_center_x, _cell_center_y);
			var _is_center_cell = (_cell_x == _center_cell_x && _cell_y == _center_cell_y);

			if (_cell_distance <= _safe_radius || _is_center_cell)
			{
				var _holy_count = ds_grid_get(holy_grid, _cell_x, _cell_y);
				var _new_holy_count = max(_holy_count - 1, 0);

				ds_grid_set(holy_grid, _cell_x, _cell_y, _new_holy_count);

				if (_new_holy_count <= 0)
				{
					ds_grid_set(corruption_grid, _cell_x, _cell_y, clamp(_corruption, 0, 1));
				}
			}
		}
	}
};

// Adds corruption to cells inside a world-space circle.
corrupt_circle = function(_center_x, _center_y, _radius, _corruption)
{
	var _safe_radius = max(_radius, 1);
	var _center_cell_x = clamp(floor(_center_x / cell_size), 0, grid_width - 1);
	var _center_cell_y = clamp(floor(_center_y / cell_size), 0, grid_height - 1);
	var _left_cell = clamp(floor((_center_x - _safe_radius) / cell_size), 0, grid_width - 1);
	var _right_cell = clamp(floor((_center_x + _safe_radius) / cell_size), 0, grid_width - 1);
	var _top_cell = clamp(floor((_center_y - _safe_radius) / cell_size), 0, grid_height - 1);
	var _bottom_cell = clamp(floor((_center_y + _safe_radius) / cell_size), 0, grid_height - 1);

	for (var _cell_x = _left_cell; _cell_x <= _right_cell; ++_cell_x)
	{
		for (var _cell_y = _top_cell; _cell_y <= _bottom_cell; ++_cell_y)
		{
			var _cell_center_x = (_cell_x * cell_size) + (cell_size * 0.5);
			var _cell_center_y = (_cell_y * cell_size) + (cell_size * 0.5);
			var _cell_distance = point_distance(_center_x, _center_y, _cell_center_x, _cell_center_y);
			var _is_center_cell = (_cell_x == _center_cell_x && _cell_y == _center_cell_y);

			if (_cell_distance <= _safe_radius || _is_center_cell)
			{
				var _holy_count = ds_grid_get(holy_grid, _cell_x, _cell_y);

				if (_holy_count <= 0)
				{
					var _current_corruption = ds_grid_get(corruption_grid, _cell_x, _cell_y);
					var _new_corruption = clamp(_current_corruption + _corruption, 0, 1);

					ds_grid_set(corruption_grid, _cell_x, _cell_y, _new_corruption);
				}
			}
		}
	}
};
