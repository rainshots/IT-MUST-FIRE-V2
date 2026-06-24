// Graves are passive map objects used by Grave Spires.
var _grave_sprites = [s_grave_01, s_grave_02, s_grave_03, s_grave_04, s_grave_05];
sprite_index = _grave_sprites[irandom(array_length(_grave_sprites) - 1)];
image_speed = 0;
y_sort_enabled = true;
assigned_grave_spire = noone;

// Tooltip visual settings.
tooltip_text = "Grave\nGives +1 Skeleton each morning if a Grave Spire is nearby.\nA Grave can feed only one Grave Spire.";
tooltip_width = 330;
tooltip_padding = 10;
tooltip_line_height = 18;
tooltip_offset_y = 72;

grave_is_hovered = function()
{
	if (!instance_exists(o_camera_controller)
		|| (variable_global_exists("tutorial_popup_active") && global.tutorial_popup_active)
		|| (variable_global_exists("focus_window") && global.focus_window != FOCUS_WINDOW.NOONE))
	{
		return false;
	}

	var _camera_controller = instance_find(o_camera_controller, 0);
	var _mouse_gui_x = device_mouse_x_to_gui(0);
	var _mouse_gui_y = device_mouse_y_to_gui(0);
	var _camera_x = camera_get_view_x(_camera_controller.camera_id);
	var _camera_y = camera_get_view_y(_camera_controller.camera_id);
	var _camera_width = camera_get_view_width(_camera_controller.camera_id);
	var _camera_height = camera_get_view_height(_camera_controller.camera_id);
	var _mouse_world_x = _camera_x + ((_mouse_gui_x / _camera_controller.base_view_width) * _camera_width);
	var _mouse_world_y = _camera_y + ((_mouse_gui_y / _camera_controller.base_view_height) * _camera_height);

	return _mouse_world_x >= bbox_left
		&& _mouse_world_x <= bbox_right
		&& _mouse_world_y >= bbox_top
		&& _mouse_world_y <= bbox_bottom;
};
