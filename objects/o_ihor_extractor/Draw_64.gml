// Draw inherited tooltip, then show current production speed while hovered.
event_inherited();

if (!map_object_is_hovered() || !instance_exists(o_camera_controller))
{
	exit;
}

var _camera_controller = instance_find(o_camera_controller, 0);
var _camera_x = camera_get_view_x(_camera_controller.camera_id);
var _camera_y = camera_get_view_y(_camera_controller.camera_id);
var _camera_width = camera_get_view_width(_camera_controller.camera_id);
var _camera_height = camera_get_view_height(_camera_controller.camera_id);
var _gui_width = _camera_controller.base_view_width;
var _gui_height = _camera_controller.base_view_height;
var _object_gui_x = ((x - _camera_x) / _camera_width) * _gui_width;
var _object_gui_y = ((y - _camera_y) / _camera_height) * _gui_height;
var _text = "Morning Ihor: +" + string(ihor_morning_income);
var _padding_x = 10;
var _padding_y = 6;
var _text_width = string_width(_text) + (_padding_x * 2);
var _text_height = 26;
var _text_x = clamp(_object_gui_x - (_text_width * 0.5), _padding_x, _gui_width - _text_width - _padding_x);
var _text_y = clamp(_object_gui_y + 34, _padding_y, _gui_height - _text_height - _padding_y);

draw_set_alpha(0.9);
draw_set_color(COLOR_HUD_BACKGROUND);
draw_rectangle(_text_x, _text_y, _text_x + _text_width, _text_y + _text_height, false);

draw_set_alpha(1);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(COLOR_HUD_IHOR);
draw_text(_text_x + (_text_width * 0.5), _text_y + (_text_height * 0.5), _text);

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);
