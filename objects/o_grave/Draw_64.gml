// Draw a small Grave tooltip in GUI space.
if (!grave_is_hovered())
{
	exit;
}

var _camera_controller = instance_find(o_camera_controller, 0);
var _camera_x = camera_get_view_x(_camera_controller.camera_id);
var _camera_y = camera_get_view_y(_camera_controller.camera_id);
var _camera_width = camera_get_view_width(_camera_controller.camera_id);
var _camera_height = camera_get_view_height(_camera_controller.camera_id);
var _gui_width = _camera_controller.base_view_width;
var _object_gui_x = ((x - _camera_x) / _camera_width) * _gui_width;
var _object_gui_y = ((y - _camera_y) / _camera_height) * _camera_controller.base_view_height;
var _tooltip_height = (tooltip_padding * 2) + (tooltip_line_height * 3);
var _tooltip_x = clamp(_object_gui_x - (tooltip_width * 0.5), tooltip_padding, _gui_width - tooltip_width - tooltip_padding);
var _tooltip_y = max(tooltip_padding, _object_gui_y - tooltip_offset_y - _tooltip_height);

draw_set_alpha(0.86);
draw_set_color(COLOR_HUD_BACKGROUND);
draw_rectangle(_tooltip_x, _tooltip_y, _tooltip_x + tooltip_width, _tooltip_y + _tooltip_height, false);

draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(COLOR_HUD_TEXT);
draw_text_ext(_tooltip_x + tooltip_padding, _tooltip_y + tooltip_padding, tooltip_text, tooltip_line_height, tooltip_width - (tooltip_padding * 2));

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);
