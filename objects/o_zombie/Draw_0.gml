// Draw base combat visuals.
event_inherited();

// Draw the cultist name above the demon.
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(COLOR_HUD_TEXT);
draw_text(x, y - 42, cultist_name);

// Draw active ability cooldown below the health bar.
if (ability_cooldown > 0)
{
	var _bar_width = 34;
	var _bar_height = 3;
	var _bar_x = x - (_bar_width * 0.5);
	var _bar_y = y + 32;
	var _progress = 1 - clamp(ability_timer / max(ability_cooldown, 1), 0, 1);

	draw_set_alpha(0.75);
	draw_set_color(COLOR_HUD_BACKGROUND);
	draw_rectangle(_bar_x, _bar_y, _bar_x + _bar_width, _bar_y + _bar_height, false);

	draw_set_alpha(1);
	draw_set_color(COLOR_ABILITY_BAR);
	draw_rectangle(_bar_x, _bar_y, _bar_x + (_bar_width * _progress), _bar_y + _bar_height, false);
}

// Restore default draw state.
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);

