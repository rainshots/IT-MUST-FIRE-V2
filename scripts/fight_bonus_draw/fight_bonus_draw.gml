/// @description Draws the three permanent bonus choices above every gameplay HUD.
function fight_bonus_draw()
{
	if (!fight_bonus_open) return;
	var _titles = ["Larger Army", "Bigger Magazine", "New Forge", "New Furnace", "New Cauldron", "New Cultist", "Unlock Necro Shot"];
	var _descriptions = ["+1 maximum squad", "+1 maximum cannonball", "Another building to forge\ncannonballs", "Another building to charge\nthe Cannon", "Another building to generate\nMana and Cannon charge", "+1 randomized Cultist", "Forges can create Necro balls.\nEach raises 3 Bonelets."];
	var _first = fight_bonus_rect_get(0);
	if (font_exists(global.ui_font)) draw_set_font(global.ui_font);
	draw_set_alpha(0.92);
	draw_set_color(COLOR_HUD_BACKGROUND);
	draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
	draw_set_alpha(1);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_set_color(COLOR_HUD_TEXT);
	draw_text_transformed(display_get_gui_width() * 0.5, _first.y - 75 * _first.scale,
		"FIGHT " + string(fight_number) + " - CHOOSE A BONUS", _first.scale, _first.scale, 0);
	for (var _index = 0; _index < array_length(fight_bonus_options); ++_index)
	{
		var _rect = fight_bonus_rect_get(_index);
		var _bonus = fight_bonus_options[_index];
		var _hover = point_in_rectangle(device_mouse_x_to_gui(0), device_mouse_y_to_gui(0), _rect.x, _rect.y, _rect.x + _rect.width, _rect.y + _rect.height);
		draw_set_color(_hover ? COLOR_PROJECTILE_SUMMON : COLOR_HUD_TEXT);
		draw_rectangle(_rect.x, _rect.y, _rect.x + _rect.width, _rect.y + _rect.height, true);
		draw_text_transformed(_rect.x + _rect.width * 0.5, _rect.y + 55 * _rect.scale, _titles[_bonus], 0.85 * _rect.scale, 0.85 * _rect.scale, 0);
		draw_set_color(COLOR_HUD_TEXT);
		draw_text_transformed(_rect.x + _rect.width * 0.5, _rect.y + 125 * _rect.scale, _descriptions[_bonus], 0.65 * _rect.scale, 0.65 * _rect.scale, 0);
	}
	draw_text_transformed(display_get_gui_width() * 0.5, _first.y + _first.height + 45 * _first.scale,
		fight_bonus_notice == "" ? "Pick one. Bonuses last for the entire run." : fight_bonus_notice,
		0.7 * _first.scale, 0.7 * _first.scale, 0);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
	draw_set_alpha(1);
}
