// Tester should not spawn objects while gameplay input is focused elsewhere.
if (global.pause || global.focus_window != FOCUS_WINDOW.NOONE)
{
	exit;
}

// Spawn the test object at the mouse world position by right mouse click.
if (mouse_check_button_pressed(mb_right) && instance_exists(o_camera_controller))
{
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

	instance_create_layer(_mouse_world_x, _mouse_world_y, spawn_layer_name, spawn_object);
}
