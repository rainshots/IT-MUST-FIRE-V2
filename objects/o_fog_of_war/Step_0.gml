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
			fog_circle_reveal(_cell_x, _cell_y, reveal_radius_in_cells);
		}
	}
}

// Combat demons reveal nearby fog during the night.
if (global.day_phase == DAY_PHASE.NIGHT && demon_reveal_radius_in_cells > 0)
{
	var _friendly_count = instance_number(o_friendly_units);

	for (var _friendly_index = 0; _friendly_index < _friendly_count; ++_friendly_index)
	{
		var _friendly_unit = instance_find(o_friendly_units, _friendly_index);
		var _is_combat_demon = instance_exists(_friendly_unit)
			&& variable_instance_exists(_friendly_unit, "demon_type")
			&& _friendly_unit.demon_type != DEMON_TYPE.NONE
			&& (!variable_instance_exists(_friendly_unit, "hp") || _friendly_unit.hp > 0);

		if (_is_combat_demon)
		{
			var _demon_cell_x = floor(_friendly_unit.x / cell_size);
			var _demon_cell_y = floor(_friendly_unit.y / cell_size);
			var _is_inside_grid = _demon_cell_x >= 0
				&& _demon_cell_x < grid_width
				&& _demon_cell_y >= 0
				&& _demon_cell_y < grid_height;

			if (_is_inside_grid)
			{
				fog_circle_reveal(_demon_cell_x, _demon_cell_y, demon_reveal_radius_in_cells);
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
