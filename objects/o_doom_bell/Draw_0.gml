// Dead Silence shows its active zone beneath the physical bell.
if (effect_is_active && doom_bell_enchantment == DOOM_BELL_ENCHANTMENT.DEAD_SILENCE)
{
	draw_set_color(COLOR_DOOM_BELL_SILENCE);
	draw_set_alpha(BALANCE_DOOM_BELL_ZONE_FILL_ALPHA);
	draw_circle(x, y, effect_radius, false);
	draw_set_alpha(BALANCE_DOOM_BELL_ZONE_OUTLINE_ALPHA);
	draw_circle(x, y, effect_radius, true);
	draw_set_color(c_white);
	draw_set_alpha(1);
}

event_inherited();

// A bright tint makes the clickable bell obvious under the cursor.
if (effect_is_active && map_object_is_hovered())
{
	draw_sprite_ext(
		sprite_index,
		image_index,
		x,
		y,
		image_xscale,
		image_yscale,
		image_angle,
		COLOR_DOOM_BELL_STASIS,
		BALANCE_DOOM_BELL_HOVER_ALPHA
	);
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);
