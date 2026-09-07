/// @description Spawns morning Tainted Gifts mines on infected ground outside the Cannon's safe radius.
function daybreak_tainted_gifts_spawn()
{
	if (!instance_exists(o_game_controller) || !instance_exists(o_cannon)
		|| !instance_exists(o_corruption_grid))
	{
		return 0;
	}

	var _game_controller = instance_find(o_game_controller, 0);
	if (!_game_controller.tainted_gifts_active)
	{
		return 0;
	}

	var _cannon = instance_find(o_cannon, 0);
	var _ground = instance_find(o_corruption_grid, 0);
	var _cell_size = _ground.cell_size;
	var _grid_width = _ground.grid_width;
	var _grid_height = _ground.grid_height;
	var _minimum_distance = BALANCE_TAINTED_GIFTS_CANNON_MIN_DISTANCE;
	var _minimum_distance_squared = _minimum_distance * _minimum_distance;
	var _candidate_cells = [];

	// Collect cells once per morning; Saint-protected ground is never eligible.
	for (var _cell_y = 0; _cell_y < _grid_height; ++_cell_y)
	{
		for (var _cell_x = 0; _cell_x < _grid_width; ++_cell_x)
		{
			if (ds_grid_get(_ground.corruption_grid, _cell_x, _cell_y) <= 0
				|| ds_grid_get(_ground.saint_grid, _cell_x, _cell_y) > 0)
			{
				continue;
			}

			var _center_x = min(room_width - 1, (_cell_x + 0.5) * _cell_size);
			var _center_y = min(room_height - 1, (_cell_y + 0.5) * _cell_size);
			var _distance_x = _center_x - _cannon.x;
			var _distance_y = _center_y - _cannon.y;
			if ((_distance_x * _distance_x) + (_distance_y * _distance_y) >= _minimum_distance_squared)
			{
				array_push(_candidate_cells, [_cell_x, _cell_y]);
			}
		}
	}

	var _candidate_count = array_length(_candidate_cells);
	if (_candidate_count <= 0)
	{
		return 0;
	}

	var _available_count = _candidate_count;
	var _spawned_count = 0;
	var _mine_count = BALANCE_TAINTED_GIFTS_MINE_COUNT;

	// Spread mines over different cells before reusing a small infected patch.
	for (var _mine_index = 0; _mine_index < _mine_count; ++_mine_index)
	{
		var _candidate_index = irandom(_available_count - 1);
		var _cell = _candidate_cells[_candidate_index];
		var _left = _cell[0] * _cell_size;
		var _top = _cell[1] * _cell_size;
		var _right = min(room_width, _left + _cell_size) - 1;
		var _bottom = min(room_height, _top + _cell_size) - 1;
		var _mine_x = random_range(_left, _right);
		var _mine_y = random_range(_top, _bottom);
		var _distance_x = _mine_x - _cannon.x;
		var _distance_y = _mine_y - _cannon.y;

		// An offset too close to the Cannon falls back to the verified cell center.
		if ((_distance_x * _distance_x) + (_distance_y * _distance_y) < _minimum_distance_squared)
		{
			_mine_x = min(room_width - 1, (_cell[0] + 0.5) * _cell_size);
			_mine_y = min(room_height - 1, (_cell[1] + 0.5) * _cell_size);
		}

		var _mine = instance_create_layer(_mine_x, _mine_y, "Instances", o_pumpkin_mine);
		if (instance_exists(_mine))
		{
			_spawned_count++;
		}

		_available_count--;
		_candidate_cells[_candidate_index] = _candidate_cells[_available_count];
		_candidate_cells[_available_count] = _cell;
		if (_available_count <= 0)
		{
			_available_count = _candidate_count;
		}
	}

	return _spawned_count;
}
