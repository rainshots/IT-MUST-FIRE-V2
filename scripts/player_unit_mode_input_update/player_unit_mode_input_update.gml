/// @description Handles stance shortcuts and consumes button clicks; controller context.
function player_unit_mode_input_update()
{
	if (fight_state != FIGHT_STATE.ACTIVE || global.focus_window != FOCUS_WINDOW.NOONE) return false;
	var _r = player_unit_mode_rect();
	var _hover = point_in_rectangle(device_mouse_x_to_gui(0), device_mouse_y_to_gui(0),
		_r.x, _r.y, _r.x + _r.width, _r.y + _r.height);
	var _available = !global.pause && !instance_exists(worker_dragged) && !instance_exists(shop_preview);
	if (_available && (keyboard_check_pressed(vk_lshift) || (_hover && mouse_check_button_pressed(mb_left))))
	{
		player_unit_mode = player_unit_mode == PLAYER_UNIT_MODE.DEFEND ? PLAYER_UNIT_MODE.ATTACK : PLAYER_UNIT_MODE.DEFEND;
		with (o_friendly_units)
		{
			cargo_launched = other.player_unit_mode == PLAYER_UNIT_MODE.ATTACK;
			defense_returning = false;
			target_instance = noone;
			alert_target = noone;
		}
	}
	return _hover && (mouse_check_button(mb_left) || mouse_check_button(mb_right));
}
