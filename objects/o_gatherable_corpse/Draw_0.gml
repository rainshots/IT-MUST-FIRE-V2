if (sprite_exists(corpse_sprite_index))
{
	draw_sprite_ext(
		corpse_sprite_index,
		corpse_image_index,
		x,
		y,
		corpse_image_xscale,
		corpse_image_yscale,
		corpse_image_angle,
		corpse_image_blend,
		corpse_image_alpha
	);
}
