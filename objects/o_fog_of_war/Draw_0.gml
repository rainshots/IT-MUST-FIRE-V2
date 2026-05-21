// F3 cheat can hide the whole fog layer for testing.
if (!global.fog_of_war_visible)
{
	exit;
}

// Skip drawing until the camera is ready.
if (!instance_exists(o_camera_controller))
{
	exit;
}

var _camera_controller = instance_find(o_camera_controller, 0);
var _camera_x = camera_get_view_x(_camera_controller.camera_id);
var _camera_y = camera_get_view_y(_camera_controller.camera_id);
var _camera_width = camera_get_view_width(_camera_controller.camera_id);
var _camera_height = camera_get_view_height(_camera_controller.camera_id);
var _left_cell = clamp(floor(_camera_x / cell_size), 0, grid_width - 1);
var _right_cell = clamp(floor((_camera_x + _camera_width) / cell_size), 0, grid_width - 1);
var _top_cell = clamp(floor(_camera_y / cell_size), 0, grid_height - 1);
var _bottom_cell = clamp(floor((_camera_y + _camera_height) / cell_size), 0, grid_height - 1);

// Draw only visible fog cells.
draw_set_color(fog_color);

for (var _cell_x = _left_cell; _cell_x <= _right_cell; ++_cell_x)
{
	for (var _cell_y = _top_cell; _cell_y <= _bottom_cell; ++_cell_y)
	{
		var _fog_alpha = ds_grid_get(fog_grid, _cell_x, _cell_y);

		if (_fog_alpha > revealed_alpha)
		{
			var _draw_x = _cell_x * cell_size;
			var _draw_y = _cell_y * cell_size;

			draw_set_alpha(_fog_alpha);
			draw_rectangle(_draw_x, _draw_y, _draw_x + cell_size, _draw_y + cell_size, false);
		}
	}
}

// Restore default draw state.
draw_set_color(c_white);
draw_set_alpha(1);
