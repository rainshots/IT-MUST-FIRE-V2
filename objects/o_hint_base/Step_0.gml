// Convert the GUI cursor to world coordinates so closing works at every camera zoom.
if (!mouse_check_button_pressed(mb_left) || !instance_exists(o_camera_controller)) exit;
var _camera = o_camera_controller.camera_id;
var _mouse_x = camera_get_view_x(_camera) + device_mouse_x_to_gui(0) * camera_get_view_width(_camera) / display_get_gui_width();
var _mouse_y = camera_get_view_y(_camera) + device_mouse_y_to_gui(0) * camera_get_view_height(_camera) / display_get_gui_height();
var _layout = hint_layout_get();
if (point_in_rectangle(_mouse_x, _mouse_y, _layout.close_left, _layout.close_top,
	_layout.close_left + hint_close_size, _layout.close_top + hint_close_size)) instance_destroy();
