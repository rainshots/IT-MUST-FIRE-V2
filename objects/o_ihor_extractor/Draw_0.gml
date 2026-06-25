// Draw inherited map object visuals.
event_inherited();

// Show extractor radius while hovered.
tower_range_draw(effect_radius, COLOR_IHOR_EXTRACTOR_RADIUS);

// Draw current morning income while the extractor can work.
var _morning_income = ihor_morning_income;
var _bar_y = y - 76;
var _label_text = "Morning Ihor: +" + string(_morning_income);

draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_alpha(1);
draw_set_color(_morning_income > 0 && is_captured ? COLOR_HUD_IHOR : COLOR_HUD_PROJECTILE_DESCRIPTION);
draw_text(x, _bar_y - 14, _label_text);

if (sprite_exists(s_ihor_icon))
{
	var _icon_size = 16;
	draw_sprite_stretched_ext(s_ihor_icon, 0, x + (string_width(_label_text) * 0.5) + 8, _bar_y - 22, _icon_size, _icon_size, c_white, 1);
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);
