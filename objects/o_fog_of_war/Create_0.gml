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
cannon_starting_reveal_radius = BALANCE_CANNON_STARTING_FOG_REVEAL_RADIUS;
demon_reveal_radius_in_pixels = BALANCE_DEMON_FOG_REVEAL_RADIUS_IN_PIXELS;
demon_reveal_radius_in_cells = ceil(demon_reveal_radius_in_pixels / cell_size);
enemy_tower_reveal_radius = BALANCE_ENEMY_TOWER_FOG_REVEAL_RADIUS;
neighbor_offset_min = -1;
neighbor_offset_max = 1;

// Fog is recalculated periodically because corruption does not need instant visual updates every frame.
update_interval = BALANCE_FOG_UPDATE_INTERVAL;
update_timer = update_interval;
taint_scan_cells_per_step = BALANCE_FOG_TAINT_SCAN_CELLS_PER_STEP;
taint_scan_cell_index = 0;
taint_reveal_sample_step = max(1, BALANCE_FOG_TAINT_REVEAL_SAMPLE_STEP);
taint_reveal_block_width = ceil(grid_width / taint_reveal_sample_step);
taint_reveal_block_height = ceil(grid_height / taint_reveal_sample_step);
taint_reveal_block_grid = ds_grid_create(taint_reveal_block_width, taint_reveal_block_height);
ds_grid_clear(taint_reveal_block_grid, false);
taint_reveal_cell_xs = [];
taint_reveal_cell_ys = [];
taint_reveal_pending_cell_xs = [];
taint_reveal_pending_cell_ys = [];
revealed_cell_xs = [];
revealed_cell_ys = [];

// Starting Taint is cached immediately so the first visible area does not wait for the full-map scanner.
starting_taint_reveal_cache_ready = false;

fog_cell_reveal = function(_cell_x, _cell_y)
{
	if (ds_grid_get(fog_grid, _cell_x, _cell_y) == revealed_alpha)
	{
		return;
	}

	ds_grid_set(fog_grid, _cell_x, _cell_y, revealed_alpha);
	array_push(revealed_cell_xs, _cell_x);
	array_push(revealed_cell_ys, _cell_y);
};

// Reveal a circular area in fog grid cell coordinates.
fog_circle_reveal = function(_center_cell_x, _center_cell_y, _radius_in_cells)
{
	var _left_cell = clamp(_center_cell_x - _radius_in_cells, 0, grid_width - 1);
	var _right_cell = clamp(_center_cell_x + _radius_in_cells, 0, grid_width - 1);
	var _top_cell = clamp(_center_cell_y - _radius_in_cells, 0, grid_height - 1);
	var _bottom_cell = clamp(_center_cell_y + _radius_in_cells, 0, grid_height - 1);
	var _radius_squared = _radius_in_cells * _radius_in_cells;

	for (var _reveal_cell_x = _left_cell; _reveal_cell_x <= _right_cell; ++_reveal_cell_x)
	{
		for (var _reveal_cell_y = _top_cell; _reveal_cell_y <= _bottom_cell; ++_reveal_cell_y)
		{
			var _distance_x = _reveal_cell_x - _center_cell_x;
			var _distance_y = _reveal_cell_y - _center_cell_y;
			var _distance_squared = (_distance_x * _distance_x) + (_distance_y * _distance_y);

			if (_distance_squared <= _radius_squared)
			{
				fog_cell_reveal(_reveal_cell_x, _reveal_cell_y);
			}
		}
	}
};

// Reveal a small world-space circle around a discovered object.
fog_world_circle_reveal = function(_world_x, _world_y, _radius)
{
	var _radius_in_cells = ceil(_radius / cell_size);
	var _center_cell_x = floor(_world_x / cell_size);
	var _center_cell_y = floor(_world_y / cell_size);
	var _left_cell = clamp(_center_cell_x - _radius_in_cells, 0, grid_width - 1);
	var _right_cell = clamp(_center_cell_x + _radius_in_cells, 0, grid_width - 1);
	var _top_cell = clamp(_center_cell_y - _radius_in_cells, 0, grid_height - 1);
	var _bottom_cell = clamp(_center_cell_y + _radius_in_cells, 0, grid_height - 1);
	var _radius_squared = _radius * _radius;

	for (var _reveal_cell_x = _left_cell; _reveal_cell_x <= _right_cell; ++_reveal_cell_x)
	{
		for (var _reveal_cell_y = _top_cell; _reveal_cell_y <= _bottom_cell; ++_reveal_cell_y)
		{
			var _cell_center_x = (_reveal_cell_x * cell_size) + (cell_size * 0.5);
			var _cell_center_y = (_reveal_cell_y * cell_size) + (cell_size * 0.5);
			var _distance_x = _cell_center_x - _world_x;
			var _distance_y = _cell_center_y - _world_y;
			var _distance_squared = (_distance_x * _distance_x) + (_distance_y * _distance_y);
			var _is_center_cell = (_reveal_cell_x == _center_cell_x && _reveal_cell_y == _center_cell_y);

			if (_distance_squared <= _radius_squared || _is_center_cell)
			{
				fog_cell_reveal(_reveal_cell_x, _reveal_cell_y);
			}
		}
	}
};

fog_cell_is_seen = function(_world_x, _world_y)
{
	var _cell_x = floor(_world_x / cell_size);
	var _cell_y = floor(_world_y / cell_size);
	var _is_inside_grid = _cell_x >= 0
		&& _cell_x < grid_width
		&& _cell_y >= 0
		&& _cell_y < grid_height;

	if (!_is_inside_grid)
	{
		return false;
	}

	return ds_grid_get(fog_grid, _cell_x, _cell_y) < hidden_alpha;
};

fog_taint_reveal_cache_scan_update = function()
{
	if (!instance_exists(o_corruption_grid))
	{
		taint_scan_cell_index = 0;
		taint_reveal_cell_xs = [];
		taint_reveal_cell_ys = [];
		taint_reveal_pending_cell_xs = [];
		taint_reveal_pending_cell_ys = [];
		ds_grid_clear(taint_reveal_block_grid, false);
		return;
	}

	var _corruption_grid_object = instance_find(o_corruption_grid, 0);
	var _has_saint_grid = variable_instance_exists(_corruption_grid_object, "saint_grid");
	var _total_cells = grid_width * grid_height;
	var _scan_cell_count = min(taint_scan_cells_per_step, _total_cells);

	for (var _scan_index = 0; _scan_index < _scan_cell_count; ++_scan_index)
	{
		var _cell_x = taint_scan_cell_index mod grid_width;
		var _cell_y = floor(taint_scan_cell_index / grid_width);
		var _corruption = ds_grid_get(_corruption_grid_object.corruption_grid, _cell_x, _cell_y);
		var _saint = 0;

		if (_corruption >= full_corruption_value && _has_saint_grid)
		{
			_saint = ds_grid_get(_corruption_grid_object.saint_grid, _cell_x, _cell_y);
		}

		if (_saint <= 0 && _corruption >= full_corruption_value)
		{
			var _block_x = floor(_cell_x / taint_reveal_sample_step);
			var _block_y = floor(_cell_y / taint_reveal_sample_step);
			var _block_has_reveal_source = ds_grid_get(taint_reveal_block_grid, _block_x, _block_y);

			if (!_block_has_reveal_source)
			{
				ds_grid_set(taint_reveal_block_grid, _block_x, _block_y, true);
				array_push(taint_reveal_pending_cell_xs, _cell_x);
				array_push(taint_reveal_pending_cell_ys, _cell_y);
			}
		}

		taint_scan_cell_index++;

		if (taint_scan_cell_index >= _total_cells)
		{
			taint_reveal_cell_xs = taint_reveal_pending_cell_xs;
			taint_reveal_cell_ys = taint_reveal_pending_cell_ys;
			taint_reveal_pending_cell_xs = [];
			taint_reveal_pending_cell_ys = [];
			ds_grid_clear(taint_reveal_block_grid, false);
			taint_scan_cell_index = 0;
		}
	}
};

// Cache only the cannon's starting Taint area before the slower background scanner reaches it.
fog_starting_taint_reveal_cache_update = function()
{
	if (starting_taint_reveal_cache_ready
		|| !instance_exists(o_cannon)
		|| !instance_exists(o_corruption_grid))
	{
		return;
	}

	var _cannon = instance_find(o_cannon, 0);
	var _corruption_grid_object = instance_find(o_corruption_grid, 0);
	var _start_radius = BALANCE_CANNON_STARTING_CORRUPTION_RADIUS_IN_CELLS * cell_size;

	if (variable_instance_exists(_cannon, "starting_corruption_radius"))
	{
		_start_radius = _cannon.starting_corruption_radius;
	}

	var _safe_radius = max(_start_radius, 1);
	var _center_cell_x = clamp(floor(_cannon.x / cell_size), 0, grid_width - 1);
	var _center_cell_y = clamp(floor(_cannon.y / cell_size), 0, grid_height - 1);
	var _left_cell = clamp(floor((_cannon.x - _safe_radius) / cell_size), 0, grid_width - 1);
	var _right_cell = clamp(floor((_cannon.x + _safe_radius) / cell_size), 0, grid_width - 1);
	var _top_cell = clamp(floor((_cannon.y - _safe_radius) / cell_size), 0, grid_height - 1);
	var _bottom_cell = clamp(floor((_cannon.y + _safe_radius) / cell_size), 0, grid_height - 1);
	var _sample_step = max(1, taint_reveal_sample_step);
	var _has_saint_grid = variable_instance_exists(_corruption_grid_object, "saint_grid");

	for (var _cell_x = _left_cell; _cell_x <= _right_cell; ++_cell_x)
	{
		for (var _cell_y = _top_cell; _cell_y <= _bottom_cell; ++_cell_y)
		{
			var _is_center_cell = (_cell_x == _center_cell_x && _cell_y == _center_cell_y);
			var _is_sample_cell = ((_cell_x - _left_cell) mod _sample_step == 0)
				&& ((_cell_y - _top_cell) mod _sample_step == 0);

			if (!_is_center_cell && !_is_sample_cell)
			{
				continue;
			}

			var _corruption = ds_grid_get(_corruption_grid_object.corruption_grid, _cell_x, _cell_y);
			var _saint = 0;

			if (_has_saint_grid)
			{
				_saint = ds_grid_get(_corruption_grid_object.saint_grid, _cell_x, _cell_y);
			}

			if (_saint <= 0 && _corruption >= full_corruption_value)
			{
				array_push(taint_reveal_cell_xs, _cell_x);
				array_push(taint_reveal_cell_ys, _cell_y);
			}
		}
	}

	starting_taint_reveal_cache_ready = true;
};
