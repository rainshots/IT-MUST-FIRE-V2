// Armed traps reveal the full area that will be affected.
if (is_armed)
{
	draw_set_color(warning_color);
	draw_set_alpha(warning_fill_alpha);
	draw_circle(x, y, trap_radius, false);

	draw_set_alpha(warning_outline_alpha);
	draw_circle(x, y, trap_radius, true);
}

// Draw the trap above its translucent warning area.
draw_set_color(c_white);
draw_set_alpha(1);
draw_self();

// Restore the project's default draw state.
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);
