/// @description Draws a rectangular campaign-style button; input is handled outside drawing.
function conquest_button_draw(_controller, _x, _y, _width, _height, _label, _selected = false, _enabled = true)
{
	if (!instance_exists(_controller)) return;
	var _hovered = point_in_rectangle(device_mouse_x_to_gui(0), device_mouse_y_to_gui(0), _x, _y, _x + _width, _y + _height);
	draw_set_alpha(1);
	draw_set_color(_enabled ? ((_selected || _hovered) ? COLOR_WORLD_MAP_ATTACK_HOVER : COLOR_WORLD_MAP_ATTACK) : COLOR_SQUAD_CARD_BACKGROUND);
	draw_rectangle(_x, _y, _x + _width, _y + _height, false);
	draw_set_color(_selected ? COLOR_CULTIST_COUNTER_TEXT : COLOR_WORLD_MAP_ATTACK_BORDER);
	draw_rectangle(_x, _y, _x + _width, _y + _height, true);
	draw_set_font(_controller.ui_font);
	draw_set_color(_enabled ? COLOR_CULTIST_COUNTER_TEXT : COLOR_SQUAD_CARD_TYPE);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_text(_x + _width * 0.5, _y + _height * 0.5, _label);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
	draw_set_alpha(1);
}
