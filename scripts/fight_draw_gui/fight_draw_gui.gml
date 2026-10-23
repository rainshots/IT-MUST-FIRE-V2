/// @description Draws fight progression and match results; controller context.
function fight_draw_gui()
{
	if (font_exists(global.ui_font)) draw_set_font(global.ui_font);
	var _gui_width = display_get_gui_width();
	var _gui_height = display_get_gui_height();
	var _scale = clamp(_gui_height / 1080, 0.6, 1);
	var _margin = 28 * _scale;
	var _width = 300 * _scale;
	var _height = 28 * _scale;
	var _left = _gui_width - _width - _margin;
	var _top = 64 * _scale;
	draw_set_alpha(1);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(COLOR_HUD_TEXT);
	if (fight_state == FIGHT_STATE.ACTIVE)
	{
		var _remaining = ceil(max(0, fight_next_wave_seconds - fight_elapsed_seconds));
		var _minutes = floor(_remaining / 60);
		var _seconds = _remaining mod 60;
		var _label = "Wave " + string(fight_wave_index + 1) + " in "
			+ string(_minutes) + ":" + (_seconds < 10 ? "0" : "") + string(_seconds);
		draw_text_transformed(_left, _margin, _label, _scale, _scale, 0);
	}
	if (fight_state == FIGHT_STATE.CLEARED && global.focus_window == FOCUS_WINDOW.NOONE)
	{
		var _rect = fight_move_on_rect_get();
		draw_set_color(COLOR_HUD_BACKGROUND);
		draw_rectangle(_rect.x, _rect.y, _rect.x + _rect.width, _rect.y + _rect.height, false);
		draw_set_color(COLOR_PROJECTILE_SUMMON);
		draw_rectangle(_rect.x, _rect.y, _rect.x + _rect.width, _rect.y + _rect.height, true);
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		draw_text_transformed(_rect.x + _rect.width * 0.5, _rect.y + _rect.height * 0.5, "MOVE ON", _scale, _scale, 0);
	}
	if (fight_state == FIGHT_STATE.LOST || fight_state == FIGHT_STATE.WON)
	{
		draw_set_alpha(0.88);
		draw_set_color(COLOR_HUD_BACKGROUND);
		draw_rectangle(0, 0, _gui_width, _gui_height, false);
		draw_set_alpha(1);
		draw_set_color(COLOR_HUD_TEXT);
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		var _message = fight_state == FIGHT_STATE.WON ? "VICTORY - BASE TOWER DESTROYED" : "GAME OVER - THE HEART DESTROYED";
		draw_text(_gui_width * 0.5, _gui_height * 0.5, _message);
		draw_text(_gui_width * 0.5, _gui_height * 0.5 + 56 * _scale, "Press Enter to restart");
	}
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
	draw_set_alpha(1);
}
