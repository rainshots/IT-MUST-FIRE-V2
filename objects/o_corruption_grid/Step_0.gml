// Pause freezes passive ground corruption spread.
if (global.pause)
{
	exit;
}

passive_spread_update_timer++;
saint_update_timer++;

var _should_update_passive_spread = passive_spread_update_timer mod passive_spread_update_interval == 0;
var _should_update_saint = saint_update_timer mod saint_update_interval == 0;

if (!_should_update_passive_spread && !_should_update_saint)
{
	exit;
}

var _spread_corruption = passive_spread_per_second * (passive_spread_update_interval / room_speed);
var _saint_change = saint_change_per_second * (saint_update_interval / room_speed);

// Saint cells grow from linked sources and fade after their last source disappears.
if (_should_update_saint)
{
	for (var _saint_cell_x = 0; _saint_cell_x < grid_width; ++_saint_cell_x)
	{
		for (var _saint_cell_y = 0; _saint_cell_y < grid_height; ++_saint_cell_y)
		{
			var _saint = ds_grid_get(saint_grid, _saint_cell_x, _saint_cell_y);
			var _saint_source_count = ds_grid_get(saint_source_grid, _saint_cell_x, _saint_cell_y);

			if (_saint_source_count > 0)
			{
				var _new_saint = min(_saint + _saint_change, full_saint_value);
				var _corruption = ds_grid_get(corruption_grid, _saint_cell_x, _saint_cell_y);

				ds_grid_set(saint_grid, _saint_cell_x, _saint_cell_y, _new_saint);
				ds_grid_set(corruption_grid, _saint_cell_x, _saint_cell_y, max(0, _corruption - _saint_change));
			}
			else if (_saint > 0)
			{
				ds_grid_set(saint_grid, _saint_cell_x, _saint_cell_y, max(0, _saint - _saint_change));
			}
		}
	}
}

if (!_should_update_passive_spread)
{
	exit;
}

// Fully corrupted cells slowly infect all 8 neighbor cells up to passive_spread_limit.
for (var _cell_x = 0; _cell_x < grid_width; ++_cell_x)
{
	for (var _cell_y = 0; _cell_y < grid_height; ++_cell_y)
	{
		var _corruption = ds_grid_get(corruption_grid, _cell_x, _cell_y);
		var _saint = ds_grid_get(saint_grid, _cell_x, _cell_y);

		if (_saint <= 0 && _corruption >= full_corruption_value)
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
							var _target_saint = ds_grid_get(saint_grid, _target_cell_x, _target_cell_y);

							if (_target_saint > 0)
							{
								continue;
							}

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
