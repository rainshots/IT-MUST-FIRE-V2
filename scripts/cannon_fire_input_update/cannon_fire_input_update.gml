/// @description Owns clicks while manually aiming; returns whether to consume controller input.
function cannon_fire_input_update()
{
	if (global.pause || fight_state != FIGHT_STATE.ACTIVE || global.focus_window != FOCUS_WINDOW.NOONE || debug_menu_open)
	{
		cannon_aiming = false;
		return false;
	}
	var _ready = fight_charge >= BALANCE_FIGHT_CHARGE_MAX && array_length(cannon_ammo) > 0;
	if (!_ready || !instance_exists(o_camera_controller))
	{
		cannon_aiming = false;
		return false;
	}
	var _mx = device_mouse_x_to_gui(0);
	var _my = device_mouse_y_to_gui(0);
	if (cannon_aiming)
	{
		if (mouse_check_button_pressed(mb_right) || keyboard_check_pressed(vk_escape)) cannon_aiming = false;
		else if (mouse_check_button_pressed(mb_left))
		{
			var _camera = o_camera_controller.camera_id;
			var _x = camera_get_view_x(_camera) + _mx * camera_get_view_width(_camera) / display_get_gui_width();
			var _y = camera_get_view_y(_camera) + _my * camera_get_view_height(_camera) / display_get_gui_height();
			cannon_volley_fire(_x, _y);
		}
		return true;
	}
	var _rect = cannon_fire_rect_get();
	if (!instance_exists(worker_dragged) && mouse_check_button_pressed(mb_left)
		&& point_in_rectangle(_mx, _my, _rect.x, _rect.y, _rect.x + _rect.width, _rect.y + _rect.height))
	{
		cannon_aiming = true;
		worker_hovered = noone;
		if (worker_cursor_hidden) window_set_cursor(cr_default);
		worker_cursor_hidden = false;
		return true;
	}
	return false;
}
