// Draw base combat visuals.
event_inherited();

// Draw a small clone label for readability while testing.
if (variable_global_exists("ui_font") && font_exists(global.ui_font))
{
	draw_set_font(global.ui_font);
}

draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(COLOR_IMP_BLOOD_FRENZY);
draw_set_alpha(0.85 * image_alpha);
draw_text(x, y - 42, "Clone");

// Restore default draw state.
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);
