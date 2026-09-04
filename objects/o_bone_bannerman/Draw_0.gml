// The banner's active radius remains visible for as long as its bearer is alive.
if (hp > 0)
{
	draw_set_color(COLOR_BONE_BANNERMAN_AURA);
	draw_set_alpha(BALANCE_BONE_BANNERMAN_RADIUS_FILL_ALPHA);
	draw_circle(x, y, BALANCE_BONE_BANNERMAN_EFFECT_RADIUS, false);
	draw_set_alpha(BALANCE_BONE_BANNERMAN_RADIUS_OUTLINE_ALPHA);
	draw_circle(x, y, BALANCE_BONE_BANNERMAN_EFFECT_RADIUS, true);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
	draw_set_alpha(1);
}

event_inherited();
