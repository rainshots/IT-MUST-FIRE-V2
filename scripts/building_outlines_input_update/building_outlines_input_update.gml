/// @description Toggles persistent construction grids and consumes button clicks; controller context.
function building_outlines_input_update()
{
	if (fight_state != FIGHT_STATE.ACTIVE || global.focus_window != FOCUS_WINDOW.NOONE || debug_menu_open) return false;
	var _r = building_outlines_button_rect();
	var _hover = point_in_rectangle(device_mouse_x_to_gui(0), device_mouse_y_to_gui(0),
		_r.x, _r.y, _r.x + _r.width, _r.y + _r.height);
	if (!instance_exists(worker_dragged) && !instance_exists(shop_preview) && (keyboard_check_pressed(vk_lalt) || (_hover && mouse_check_button_pressed(mb_left))))
		show_building_grid = !show_building_grid;
	return _hover && (mouse_check_button(mb_left) || mouse_check_button(mb_right));
}
