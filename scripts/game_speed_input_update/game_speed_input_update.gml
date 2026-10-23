/// @description Toggles the existing simulation time scale and consumes button clicks; controller context.
function game_speed_input_update()
{
	if (fight_state != FIGHT_STATE.ACTIVE || global.focus_window != FOCUS_WINDOW.NOONE || debug_menu_open) return false;
	var _r = game_speed_button_rect();
	var _hover = point_in_rectangle(device_mouse_x_to_gui(0), device_mouse_y_to_gui(0),
		_r.x, _r.y, _r.x + _r.width, _r.y + _r.height);
	if (!instance_exists(worker_dragged) && !instance_exists(shop_preview) && (keyboard_check_pressed(vk_lcontrol) || (_hover && mouse_check_button_pressed(mb_left))))
		global.gameplay_time_scale = global.gameplay_time_scale == BALANCE_SIMULATION_SPEED_FAST
			? BALANCE_SIMULATION_SPEED_NORMAL : BALANCE_SIMULATION_SPEED_FAST;
	return _hover && (mouse_check_button(mb_left) || mouse_check_button(mb_right));
}
