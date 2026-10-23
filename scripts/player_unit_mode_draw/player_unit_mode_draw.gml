/// @description Draws the current player stance; controller context.
function player_unit_mode_draw()
{
	if (fight_state == FIGHT_STATE.LOST || fight_state == FIGHT_STATE.WON) return;
	var _r = player_unit_mode_rect();
	if (font_exists(global.ui_font)) draw_set_font(global.ui_font);
	draw_set_alpha(1);
	draw_set_color(COLOR_HUD_BACKGROUND);
	draw_rectangle(_r.x, _r.y, _r.x + _r.width, _r.y + _r.height, false);
	draw_set_color(COLOR_HUD_TEXT);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	var _label = player_unit_mode == PLAYER_UNIT_MODE.DEFEND ? "Defense Mode" : "Attack Mode";
	// Preserve label sizes independently of the enlarged button bounds.
	var _label_scale = min(BALANCE_CONTROL_TEXT_HEIGHT * 0.48 / max(1, string_height(_label)), BALANCE_CONTROL_TEXT_WIDTH * 0.9 / max(1, string_width(_label)));
	var _hint = "Left Shift";
	var _hint_scale = min(_label_scale * 0.75, BALANCE_CONTROL_TEXT_WIDTH * 0.9 / max(1, string_width(_hint)));
	draw_text_transformed(_r.x + _r.width * 0.5, _r.y + _r.height * 0.3, _label, _label_scale, _label_scale, 0);
	draw_text_transformed(_r.x + _r.width * 0.5, _r.y + _r.height * 0.76, _hint, _hint_scale, _hint_scale, 0);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
	draw_set_alpha(1);
}
