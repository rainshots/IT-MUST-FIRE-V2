// Show the area that receives each healing pulse.
draw_set_color(COLOR_PROJECTILE_HEAL);
draw_set_alpha(radius_outline_alpha);
draw_circle(x, y, heal_radius, true);

// Draw the landed meat at full opacity.
draw_set_color(c_white);
draw_set_alpha(1);
draw_self();

// Restore the project's default draw state.
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);
