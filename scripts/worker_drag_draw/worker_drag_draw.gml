/// @description Draws the restored big hand and civilian work information; controller context.
function worker_drag_draw()
{
	if (global.pause || global.focus_window != FOCUS_WINDOW.NOONE) return;
	var _worker = instance_exists(worker_dragged) ? worker_dragged : worker_hovered;
	var _x = device_mouse_x_to_gui(0);
	var _y = device_mouse_y_to_gui(0);
	if (font_exists(global.ui_font)) draw_set_font(global.ui_font);
	draw_set_alpha(1);
	draw_set_color(c_white);
	draw_set_halign(fa_center);
	draw_set_valign(fa_top);
	if (instance_exists(_worker))
	{
		draw_sprite_ext(s_hand, 0, _x, _y, BALANCE_WORKER_HAND_SCALE, BALANCE_WORKER_HAND_SCALE, 0, c_white, 1);
		var _text = instance_exists(worker_dragged) ? "Release over a building to work" : "Hold LMB to pick up";
		if (instance_exists(worker_drop_building))
		{
			_text = "Workers: " + string(array_length(worker_drop_building.worker_cultists)) + " / " + string(worker_drop_building.worker_max);
		}
		_text += "\nWork speed: " + string(round(_worker.worker_speed_multiplier * 100)) + "%";
		draw_text_transformed(_x, _y + 64, _text, 0.65, 0.65, 0);
	}
	if (worker_notice_timer > 0)
	{
		draw_set_color(COLOR_STATUS_NEGATIVE_RED);
		draw_text_transformed(display_get_gui_width() * 0.5, display_get_gui_height() * 0.7, worker_notice, 0.8, 0.8, 0);
	}
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
	draw_set_alpha(1);
}
