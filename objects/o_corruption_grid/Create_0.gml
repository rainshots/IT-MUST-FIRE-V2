// Ground corruption grid settings.
depth = BALANCE_CAPTURED_BUILDING_RIFT_DEPTH;
cell_size = BALANCE_GRID_CELL_SIZE;
grid_width = ceil(room_width / cell_size);
grid_height = ceil(room_height / cell_size);

// Draw Taint under map assets but above roads, using current room layer depths.
var _map_assets_layer = layer_get_id("Assets_1");
var _roads_layer = layer_get_id("Roads");

if (_map_assets_layer != -1 && _roads_layer != -1)
{
	var _map_assets_depth = layer_get_depth(_map_assets_layer);
	var _roads_depth = layer_get_depth(_roads_layer);
	depth = (_map_assets_depth + _roads_depth) * 0.5;
}

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

captured_building_rift_noise_get = function(_source_seed, _segment_index)
{
	var _noise_seed = (_source_seed * 12.9898) + (_segment_index * 78.233);
	var _noise_value = abs(sin(_noise_seed) * 43758.5453);
	return _noise_value - floor(_noise_value);
};

captured_building_rift_line_draw = function(_start_x, _start_y, _end_x, _end_y, _source_seed, _line_width, _line_alpha)
{
	var _distance = point_distance(_start_x, _start_y, _end_x, _end_y);

	if (_distance <= 1)
	{
		return;
	}

	var _segment_count = max(2, ceil(_distance / BALANCE_CAPTURED_BUILDING_RIFT_SEGMENT_LENGTH));
	var _line_direction = point_direction(_start_x, _start_y, _end_x, _end_y);
	var _normal_direction = _line_direction + 90;
	var _previous_x = _start_x;
	var _previous_y = _start_y;

	draw_set_alpha(_line_alpha);
	draw_set_color(COLOR_CAPTURED_BUILDING_RIFT);

	for (var _segment_index = 1; _segment_index <= _segment_count; ++_segment_index)
	{
		var _progress = _segment_index / _segment_count;
		var _segment_x = lerp(_start_x, _end_x, _progress);
		var _segment_y = lerp(_start_y, _end_y, _progress);

		if (_segment_index < _segment_count)
		{
			var _noise = captured_building_rift_noise_get(_source_seed, _segment_index);
			var _offset = ((_noise * 2) - 1) * BALANCE_CAPTURED_BUILDING_RIFT_JITTER;

			_segment_x += lengthdir_x(_offset, _normal_direction);
			_segment_y += lengthdir_y(_offset, _normal_direction);
		}

		draw_line_width(_previous_x, _previous_y, _segment_x, _segment_y, _line_width);

		_previous_x = _segment_x;
		_previous_y = _segment_y;
	}
};

captured_building_rifts_draw = function()
{
	if (!instance_exists(o_cannon))
	{
		return;
	}

	var _cannon = instance_find(o_cannon, 0);
	var _map_object_count = instance_number(o_map_objects_parent);

	for (var _map_object_index = 0; _map_object_index < _map_object_count; ++_map_object_index)
	{
		var _map_object = instance_find(o_map_objects_parent, _map_object_index);

		if (!instance_exists(_map_object)
			|| !variable_instance_exists(_map_object, "tower_capture_enabled")
			|| !_map_object.tower_capture_enabled
			|| !variable_instance_exists(_map_object, "is_captured")
			|| !_map_object.is_captured)
		{
			continue;
		}

		captured_building_rift_line_draw(
			_map_object.x,
			_map_object.y,
			_cannon.x,
			_cannon.y,
			_map_object.x + (_map_object.y * 13),
			BALANCE_CAPTURED_BUILDING_RIFT_WIDTH,
			BALANCE_CAPTURED_BUILDING_RIFT_ALPHA
		);
		captured_building_rift_line_draw(
			_map_object.x,
			_map_object.y,
			_cannon.x,
			_cannon.y,
			_map_object.x + (_map_object.y * 13),
			BALANCE_CAPTURED_BUILDING_RIFT_CORE_WIDTH,
			BALANCE_CAPTURED_BUILDING_RIFT_CORE_ALPHA
		);
	}
};

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

// Checks whether a world-space circle touches at least one fully corrupted cell.
circle_has_full_corruption = function(_center_x, _center_y, _radius)
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
				var _corruption = ds_grid_get(corruption_grid, _cell_x, _cell_y);

				if (_corruption >= full_corruption_value)
				{
					return true;
				}
			}
		}
	}

	return false;
};
