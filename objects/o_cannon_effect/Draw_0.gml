// Clouds cover their damage area; flames visibly follow burning targets.
if (effect_type == CANNONBALL_TYPE.POISON)
{
	draw_set_color(COLOR_CANNON_POISON);
	draw_set_alpha(0.3);
	draw_circle(x, y, BALANCE_CANNON_BLAST_RADIUS, false);
}
else
{
	draw_set_color(COLOR_CANNON_FIRE);
	draw_set_alpha(0.8);
	var _flame_height = 28 + 5 * sin(current_time / 100);
	draw_triangle(x - 12, y, x, y - _flame_height, x + 12, y, false);
}
draw_set_alpha(1);
draw_set_color(c_white);
