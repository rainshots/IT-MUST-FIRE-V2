// Draw the empty building slot and highlight it when it can open construction.
draw_self();

if (global.focus_window == FOCUS_WINDOW.NOONE
	&& !global.pause
	&& (!variable_instance_exists(id, "construction_event_pending") || !construction_event_pending)
	&& (!variable_global_exists("tutorial_popup_active") || !global.tutorial_popup_active)
	&& instance_exists(o_camera_controller))
{
	var _camera_controller = instance_find(o_camera_controller, 0);
	var _mouse_gui_x = device_mouse_x_to_gui(0);
	var _mouse_gui_y = device_mouse_y_to_gui(0);
	var _camera_x = camera_get_view_x(_camera_controller.camera_id);
	var _camera_y = camera_get_view_y(_camera_controller.camera_id);
	var _camera_width = camera_get_view_width(_camera_controller.camera_id);
	var _camera_height = camera_get_view_height(_camera_controller.camera_id);
	var _mouse_world_x = _camera_x + ((_mouse_gui_x / _camera_controller.base_view_width) * _camera_width);
	var _mouse_world_y = _camera_y + ((_mouse_gui_y / _camera_controller.base_view_height) * _camera_height);
	var _is_hovered = _mouse_world_x >= bbox_left
		&& _mouse_world_x <= bbox_right
		&& _mouse_world_y >= bbox_top
		&& _mouse_world_y <= bbox_bottom;

	if (_is_hovered)
	{
		var _highlight_padding = 8;

		draw_set_alpha(0.24);
		draw_set_color(COLOR_HUD_IRON);
		draw_rectangle(
			bbox_left - _highlight_padding,
			bbox_top - _highlight_padding,
			bbox_right + _highlight_padding,
			bbox_bottom + _highlight_padding,
			false
		);

		draw_set_alpha(1);
		draw_set_color(c_white);
		draw_rectangle(
			bbox_left - _highlight_padding,
			bbox_top - _highlight_padding,
			bbox_right + _highlight_padding,
			bbox_bottom + _highlight_padding,
			true
		);
	}
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);
