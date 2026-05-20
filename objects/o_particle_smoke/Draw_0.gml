// Draw soft circular smoke.
draw_set_color(smoke_color);
draw_set_alpha(current_alpha);
draw_circle(x, y, current_radius, false);

// Restore default draw state.
draw_set_color(c_white);
draw_set_alpha(1);
