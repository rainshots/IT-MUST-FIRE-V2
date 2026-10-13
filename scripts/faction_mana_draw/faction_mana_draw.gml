/// @description Displays the player's Mana balance above the squad cards.
function faction_mana_draw()
{
	if (global.player_faction == FACTION.NONE) return;
	var _scale = clamp(display_get_gui_height() / 1080, 0.6, 1);
	draw_set_halign(fa_center);
	draw_set_valign(fa_top);
	draw_set_color(COLOR_HUD_TEXT);
	draw_set_alpha(1);
	draw_text(display_get_gui_width() * 0.5, 12 * _scale,
		"Mana: " + string(global.faction_mana[global.player_faction]));
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
}
