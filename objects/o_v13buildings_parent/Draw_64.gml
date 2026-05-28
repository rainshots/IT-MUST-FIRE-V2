// Draw the building tooltip while hovering a worker building.
if (!building_accepts_workers
	|| global.focus_window != FOCUS_WINDOW.NOONE
	|| !instance_exists(o_camera_controller))
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

// Convert object world position back to GUI coordinates for stable tooltip placement.
var _object_gui_x = ((x - _camera_x) / _camera_width) * _gui_width;
var _object_gui_y = ((y - _camera_y) / _camera_height) * _gui_height;
var _tooltip_height = (production_tooltip_padding * 2) + (production_tooltip_line_height * 3);
var _tooltip_x = clamp(_object_gui_x - (production_tooltip_width * 0.5), production_tooltip_padding, _gui_width - production_tooltip_width - production_tooltip_padding);
var _tooltip_y = max(production_tooltip_padding, _object_gui_y - production_tooltip_offset_y - _tooltip_height);

draw_set_alpha(0.86);
draw_set_color(COLOR_HUD_BACKGROUND);
draw_rectangle(_tooltip_x, _tooltip_y, _tooltip_x + production_tooltip_width, _tooltip_y + _tooltip_height, false);

draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(COLOR_HUD_TEXT);
draw_text(_tooltip_x + production_tooltip_padding, _tooltip_y + production_tooltip_padding, building_tooltip_title);
draw_text(_tooltip_x + production_tooltip_padding, _tooltip_y + production_tooltip_padding + production_tooltip_line_height, building_tooltip_description);

draw_set_color(building_tooltip_detail_color);
draw_text(_tooltip_x + production_tooltip_padding, _tooltip_y + production_tooltip_padding + (production_tooltip_line_height * 2), building_tooltip_detail);

// Restore default draw state.
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);
