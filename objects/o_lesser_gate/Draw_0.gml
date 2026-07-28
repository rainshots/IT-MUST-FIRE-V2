var _pulse = 0.85 + (sin(current_time / 180) * 0.15);

draw_set_alpha(0.72);
draw_set_color(COLOR_PROJECTILE_CORRUPTION);
draw_circle(x, y, 78 * _pulse, false);
draw_set_alpha(0.9);
draw_set_color(c_white);
draw_sprite_ext(
	sprite_index,
	0,
	x,
	y,
	image_xscale * _pulse,
	image_yscale * _pulse,
	image_angle,
	c_white,
	0.9
);
draw_set_alpha(1);
draw_set_color(c_white);
