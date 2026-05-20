// Draw expanding explosion flash.
draw_set_alpha(current_alpha);
draw_set_color(outer_color);
draw_circle(x, y, current_radius, false);

draw_set_alpha(current_alpha * 0.85);
draw_set_color(inner_color);
draw_circle(x, y, current_radius * 0.52, false);

// Restore default draw state.
draw_set_color(c_white);
draw_set_alpha(1);
