/// @description Fills about half the grid with mixed trash, with a mild outer bias and random placement throughout.
function building_grid_trash_spawn()
{
	var _grid = building_grid_bounds_get();
	var _columns = BALANCE_BUILDING_GRID_COLUMNS;
	var _rows = BALANCE_BUILDING_GRID_ROWS;
	var _size = BALANCE_BUILDING_GRID_CELL_SIZE;
	var _occupied = array_create(_columns * _rows, false);
	// Reserve The Heart and any other pre-existing buildings before sampling trash positions.
	with (o_worker_building_parent)
	{
		var _bounds = building_bounds_get(id, x, y);
		var _left = max(0, round((_bounds.left - _grid.left) / _size));
		var _top = max(0, round((_bounds.top - _grid.top) / _size));
		var _right = min(_columns, round((_bounds.right - _grid.left) / _size));
		var _bottom = min(_rows, round((_bounds.bottom - _grid.top) / _size));
		for (var _row = _top; _row < _bottom; ++_row)
			for (var _column = _left; _column < _right; ++_column) _occupied[_row * _columns + _column] = true;
	}
	var _types = [o_trash_big_rock, o_trash_house_rubble, o_trash_dead_tree];
	var _widths = [2, 3, 1];
	var _heights = [2, 1, 1];
	var _target_cells = round(_columns * _rows * BALANCE_GRID_TRASH_FILL_SHARE);
	var _filled = 0;
	var _first_type = irandom(array_length(_types) - 1);
	// At most one object per target cell; larger pieces alternate with trees to maintain variety.
	for (var _piece = 0; _piece < _target_cells && _filled < _target_cells; ++_piece)
	{
		var _placed = false;
		for (var _try = 0; _try < array_length(_types); ++_try)
		{
			var _type = (_first_type + _piece + _try) mod array_length(_types);
			var _width = _widths[_type];
			var _height = _heights[_type];
			if (_filled + _width * _height > _target_cells) continue;
			var _best_score = -infinity;
			var _best_column = -1;
			var _best_row = -1;
			for (var _row = 0; _row <= _rows - _height; ++_row)
			{
				for (var _column = 0; _column <= _columns - _width; ++_column)
				{
					var _free = true;
					for (var _dy = 0; _dy < _height && _free; ++_dy)
					{
						for (var _dx = 0; _dx < _width; ++_dx)
						{
							if (_occupied[(_row + _dy) * _columns + _column + _dx]) { _free = false; break; }
						}
					}
					if (!_free) continue;
					var _cx = _column + _width * 0.5 - _columns * 0.5;
					var _cy = _row + _height * 0.5 - _rows * 0.5;
					// Weighted random sampling keeps central cells eligible; outer cells are only up to twice as likely.
					var _maximum_distance_squared = (_columns * _columns + _rows * _rows) * 0.25;
					var _weight = 1 + BALANCE_GRID_TRASH_OUTER_WEIGHT_BONUS * (_cx * _cx + _cy * _cy) / _maximum_distance_squared;
					var _score = power(random(1), 1 / _weight);
					if (_score > _best_score) { _best_score = _score; _best_column = _column; _best_row = _row; }
				}
			}
			if (_best_column < 0) continue;
			instance_create_layer(_grid.left + (_best_column + _width * 0.5) * _size,
				_grid.top + (_best_row + _height * 0.5) * _size, "Instances", _types[_type]);
			for (var _dy = 0; _dy < _height; ++_dy)
				for (var _dx = 0; _dx < _width; ++_dx) _occupied[(_best_row + _dy) * _columns + _best_column + _dx] = true;
			_filled += _width * _height;
			_placed = true;
			break;
		}
		if (!_placed) break;
	}
}
