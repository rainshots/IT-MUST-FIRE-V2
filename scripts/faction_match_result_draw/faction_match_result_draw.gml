/// @description Draws the finished match result; called by o_game_controller.
function faction_match_result_draw()
{
	var _previous_font = draw_get_font();
	var _width = display_get_gui_width();
	var _height = display_get_gui_height();
	var _title = faction_match_winner == global.player_faction ? "Victory" : "Defeat";
	var _message = faction_match_winner_name + " is the last faction standing.";
	if (faction_match_winner == FACTION.NONE)
	{
		_title = "Draw";
		_message = "No faction remains.";
	}

	draw_set_alpha(0.9);
	draw_set_color(COLOR_HUD_BACKGROUND);
	draw_rectangle(0, 0, _width, _height, false);
	draw_set_alpha(1);
	draw_set_color(COLOR_HUD_TEXT);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_set_font(global.ui_heading_font);
	var _line_gap = 64;
	draw_text(_width * 0.5, _height * 0.5 - _line_gap, _title);
	draw_set_font(global.ui_font);
	draw_text(_width * 0.5, _height * 0.5, _message);
	draw_text(_width * 0.5, _height * 0.5 + _line_gap, "Press Enter to start a new match");
	draw_set_font(_previous_font);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
	draw_set_alpha(1);
}
