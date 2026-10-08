/// @description Draws the faction chooser above all other GUI; called by the game controller.
function faction_selection_draw()
{
	var _previous_font = draw_get_font();
	var _gui_width = display_get_gui_width();
	var _gui_height = display_get_gui_height();
	var _mouse_x = device_mouse_x_to_gui(0);
	var _mouse_y = device_mouse_y_to_gui(0);
	var _first_rect = faction_selection_rect_get(0);
	var _count = array_length(faction_choices);
	draw_set_alpha(1);
	draw_set_color(COLOR_HUD_BACKGROUND);
	draw_rectangle(0, 0, _gui_width, _gui_height, false);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_set_font(global.ui_heading_font);
	draw_set_color(COLOR_HUD_TEXT);
	draw_text(_gui_width * 0.5, _first_rect.y - 72, "Choose your faction");
	for (var _index = 0; _index < _count; ++_index)
	{
		var _rect = faction_selection_rect_get(_index);
		var _choice = faction_choices[_index];
		var _hovered = point_in_rectangle(_mouse_x, _mouse_y, _rect.x, _rect.y,
			_rect.x + _rect.width, _rect.y + _rect.height);
		draw_set_color(_hovered ? COLOR_HUD_PROJECTILE_SELECTED : COLOR_SQUAD_CARD_BACKGROUND);
		draw_rectangle(_rect.x, _rect.y, _rect.x + _rect.width, _rect.y + _rect.height, false);
		draw_set_color(_hovered ? COLOR_HUD_TEXT : COLOR_SQUAD_CARD_BORDER);
		draw_rectangle(_rect.x, _rect.y, _rect.x + _rect.width, _rect.y + _rect.height, true);
		draw_set_color(COLOR_HUD_TEXT);
		draw_set_font(global.ui_heading_font);
		draw_text(_gui_width * 0.5, _rect.y + _rect.height * 0.32, _choice.name);
		draw_set_font(global.ui_font);
		draw_set_color(COLOR_HUD_PROJECTILE_DESCRIPTION);
		draw_text(_gui_width * 0.5, _rect.y + _rect.height * 0.7, _choice.description);
	}
	draw_set_font(_previous_font);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
	draw_set_alpha(1);
}
