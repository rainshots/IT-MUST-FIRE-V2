// Draw projectile reaction tooltip while hovering this map object.
if (!instance_exists(o_camera_controller))
{
	exit;
}

var _camera_controller = instance_find(o_camera_controller, 0);
var _mouse_gui_x = device_mouse_x_to_gui(0);
var _mouse_gui_y = device_mouse_y_to_gui(0);
var _camera_x = camera_get_view_x(_camera_controller.camera_id);
var _camera_y = camera_get_view_y(_camera_controller.camera_id);
var _camera_width = camera_get_view_width(_camera_controller.camera_id);
var _camera_height = camera_get_view_height(_camera_controller.camera_id);
var _gui_width = _camera_controller.base_view_width;
var _gui_height = _camera_controller.base_view_height;
var _mouse_world_x = _camera_x + ((_mouse_gui_x / _gui_width) * _camera_width);
var _mouse_world_y = _camera_y + ((_mouse_gui_y / _gui_height) * _camera_height);
var _is_hovered = (
	_mouse_world_x >= bbox_left
	&& _mouse_world_x <= bbox_right
	&& _mouse_world_y >= bbox_top
	&& _mouse_world_y <= bbox_bottom
);

if (!_is_hovered)
{
	exit;
}

// Convert object world position back to GUI coordinates for the tooltip.
var _object_gui_x = ((x - _camera_x) / _camera_width) * _gui_width;
var _object_gui_y = ((y - _camera_y) / _camera_height) * _gui_height;
var _line_count = array_length(tooltip_lines);
var _tooltip_height = (tooltip_padding * 2) + (tooltip_line_height * _line_count);
var _tooltip_x = clamp(_object_gui_x - (tooltip_width * 0.5), tooltip_padding, _gui_width - tooltip_width - tooltip_padding);
var _tooltip_y = max(tooltip_padding, _object_gui_y - tooltip_offset_y - _tooltip_height);

// Draw tooltip background.
draw_set_alpha(0.86);
draw_set_color(COLOR_HUD_BACKGROUND);
draw_rectangle(_tooltip_x, _tooltip_y, _tooltip_x + tooltip_width, _tooltip_y + _tooltip_height, false);

// Draw tooltip text.
draw_set_alpha(1);
draw_set_color(COLOR_HUD_TEXT);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

for (var _line_index = 0; _line_index < _line_count; ++_line_index)
{
	var _line_x = _tooltip_x + tooltip_padding;
	var _line_y = _tooltip_y + tooltip_padding + (tooltip_line_height * _line_index);

	draw_text(_line_x, _line_y, tooltip_lines[_line_index]);
}

// Restore default draw state.
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);
