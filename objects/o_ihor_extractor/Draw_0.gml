// Draw inherited map object visuals.
event_inherited();

// Show extractor radius while hovered.
tower_range_draw(effect_radius, COLOR_IHOR_EXTRACTOR_RADIUS);

// Draw production speed and progress while the extractor can work.
var _production_speed = ihor_production_speed;
var _bar_width = 78;
var _bar_height = 7;
var _bar_x = x - (_bar_width * 0.5);
var _bar_y = y - 76;
var _label_text = "Ihor speed: " + string_format(_production_speed, 1, 1) + "x";

draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_alpha(1);
draw_set_color(_production_speed > 0 && is_captured ? COLOR_HUD_IHOR : COLOR_HUD_PROJECTILE_DESCRIPTION);
draw_text(x, _bar_y - 14, _label_text);

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_alpha(0.75);
draw_set_color(c_black);
draw_rectangle(_bar_x, _bar_y, _bar_x + _bar_width, _bar_y + _bar_height, false);

draw_set_alpha(1);
draw_set_color(COLOR_HUD_IHOR);
draw_rectangle(_bar_x, _bar_y, _bar_x + (_bar_width * clamp(ihor_production_progress, 0, 1)), _bar_y + _bar_height, false);

if (sprite_exists(s_ihor_icon))
{
	var _icon_size = 16;
	draw_sprite_stretched_ext(s_ihor_icon, 0, x + (_bar_width * 0.5) + 6, _bar_y - 5, _icon_size, _icon_size, c_white, 1);
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);
