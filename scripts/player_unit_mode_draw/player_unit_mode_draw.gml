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
	draw_text(_r.x + _r.width * 0.5, _r.y + _r.height * 0.5,
		player_unit_mode == PLAYER_UNIT_MODE.DEFEND ? "Defend" : "Attack");
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
	draw_set_alpha(1);
}
