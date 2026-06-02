// Draw soft smoke sprite using the configured tint and fade.
draw_sprite_ext(
	sprite_index,
	image_index,
	x,
	y,
	current_scale,
	current_scale,
	image_angle,
	smoke_color,
	current_alpha
);

// Restore default draw state.
draw_set_color(c_white);
draw_set_alpha(1);
