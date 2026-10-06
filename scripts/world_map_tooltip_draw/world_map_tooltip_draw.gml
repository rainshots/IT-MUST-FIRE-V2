/// @description Draws an item or unit tooltip outside the information panel's clipped contents.
function world_map_tooltip_draw(_map, _title, _description, _mouse_x, _mouse_y)
{
	var _padding = 14;
	var _width = 360;
	var _line_height = 26;
	draw_set_font(_map.map_font);
	var _text_width = _width - _padding * 2;
	var _title_height = string_height_ext(_title, _line_height, _text_width);
	var _description_height = _description == "" ? 0 : string_height_ext(_description, _line_height, _text_width) + 10;
	var _height = _padding * 2 + _title_height + _description_height;
	var _x = clamp(_mouse_x - _width - 18, 8, _map.gui_width - _width - 8);
	var _y = clamp(_mouse_y + 16, 8, _map.gui_height - _height - 8);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(COLOR_HUD_BACKGROUND);
	draw_rectangle(_x, _y, _x + _width, _y + _height, false);
	draw_set_color(COLOR_PROJECTILE_SUMMON);
	draw_rectangle(_x, _y, _x + _width, _y + _height, true);
	draw_set_color(COLOR_CULTIST_COUNTER_TEXT);
	draw_text_ext(_x + _padding, _y + _padding, _title, _line_height, _text_width);
	draw_set_color(COLOR_HUD_TEXT);
	draw_text_ext(_x + _padding, _y + _padding + _title_height + 10, _description, _line_height, _text_width);
	draw_set_color(c_white);
	draw_set_alpha(1);
}
