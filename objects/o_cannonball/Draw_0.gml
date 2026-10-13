var _colors = [COLOR_CANNON_NORMAL, COLOR_CANNON_POISON, COLOR_CANNON_NECRO, COLOR_CANNON_FIRE];
draw_set_color(_colors[ball_type]);
draw_circle(x, y, 9, false);
draw_set_color(c_white);
draw_circle(x, y, 9, true);
