// A soft green field and expanding ring show the one-second pulse cadence.
draw_set_color(COLOR_CURING_SPIT);
draw_set_alpha(0.1);
draw_circle(x, y, effect_radius, false);
draw_set_alpha(0.65);
draw_circle(x, y, effect_radius, true);
draw_circle(x, y, effect_radius * (pulse_elapsed / pulse_interval), true);
draw_set_color(c_white);
draw_set_alpha(1);
