// Draw damage text in GUI space so it appears above world objects.
if (!instance_exists(o_camera_controller))
{
	exit;
}

var _camera_controller = instance_find(o_camera_controller, 0);
var _camera_x = camera_get_view_x(_camera_controller.camera_id);
var _camera_y = camera_get_view_y(_camera_controller.camera_id);
var _camera_width = camera_get_view_width(_camera_controller.camera_id);
var _camera_height = camera_get_view_height(_camera_controller.camera_id);
var _gui_width = display_get_gui_width();
var _gui_height = display_get_gui_height();
var _draw_x = ((x - _camera_x) / _camera_width) * _gui_width;
var _draw_y = ((y + text_offset_y - _camera_y) / _camera_height) * _gui_height;
var _text_scale = 1.5;

if (is_critical)
{
	_text_scale *= 1.5;
}

draw_set_alpha(current_alpha);
draw_set_color(popup_color);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text_transformed(_draw_x, _draw_y, popup_text, _text_scale, _text_scale, 0);

// Restore default draw state.
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);
