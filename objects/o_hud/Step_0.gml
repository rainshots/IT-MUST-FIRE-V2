// Open or close squad information from the roster cards before throttled HUD updates.
if (global.focus_window != FOCUS_WINDOW.NOONE)
{
	squad_info_squad = noone;
}
else
{
	if (mouse_check_button_pressed(mb_right))
	{
		var _mouse_x = device_mouse_x_to_gui(0);
		var _mouse_y = device_mouse_y_to_gui(0);
		var _hovered_squad = hud_squad_at_gui_position(_mouse_x, _mouse_y);

		if (is_struct(_hovered_squad) && squad_info_squad != _hovered_squad)
		{
			squad_info_squad = _hovered_squad;
		}
		else
		{
			squad_info_squad = noone;
		}
	}
}

global.squad_info_window_open = is_struct(squad_info_squad);

// Update minimap ground cache outside Draw GUI to keep HUD rendering cheap.
minimap_ground_update_timer++;

if (minimap_ground_update_timer >= minimap_ground_update_interval)
{
	minimap_ground_update_timer = 0;
	minimap_ground_cache_update();
}

// Update derived corruption counter at a small fixed interval.
corruption_update_timer++;

if (corruption_update_timer < corruption_update_interval)
{
	exit;
}

corruption_update_timer = 0;

if (!instance_exists(o_corruption_grid))
{
	corruption_display_value = 0;
	corruption_display_percent = 0;
	corruption_display_total_cells = 0;
	exit;
}

var _corruption_grid = instance_find(o_corruption_grid, 0);
var _total_corruption = 0;
var _total_cells = _corruption_grid.grid_width * _corruption_grid.grid_height;
var _has_saint_grid = variable_instance_exists(_corruption_grid, "saint_grid");

// Sum all cell values. A fully corrupted cell contributes 1.
for (var _cell_x = 0; _cell_x < _corruption_grid.grid_width; ++_cell_x)
{
	for (var _cell_y = 0; _cell_y < _corruption_grid.grid_height; ++_cell_y)
	{
		var _saint = 0;

		if (_has_saint_grid)
		{
			_saint = ds_grid_get(_corruption_grid.saint_grid, _cell_x, _cell_y);
		}

		if (_saint <= 0)
		{
			_total_corruption += ds_grid_get(_corruption_grid.corruption_grid, _cell_x, _cell_y);
		}
	}
}

corruption_display_value = _total_corruption;
corruption_display_total_cells = _total_cells;
corruption_display_percent = (_total_corruption / max(1, _total_cells)) * 100;
