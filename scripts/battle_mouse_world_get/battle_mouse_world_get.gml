/// @description Converts the GUI pointer to world coordinates using the active strategy camera.
function battle_mouse_world_get()
{
	var _camera = view_camera[0];
	return {
		x: camera_get_view_x(_camera) + device_mouse_x_to_gui(0) * camera_get_view_width(_camera) / display_get_gui_width(),
		y: camera_get_view_y(_camera) + device_mouse_y_to_gui(0) * camera_get_view_height(_camera) / display_get_gui_height()
	};
}
