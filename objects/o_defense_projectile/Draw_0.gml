if (exploded)
{
	var _progress = 1 - remaining_seconds / BALANCE_DEFENSE_BLAST_VISUAL_SECONDS;
	draw_set_alpha(1 - _progress);
	draw_set_color(COLOR_PUMPKIN_PATCH);
	draw_circle(x, y, blast_radius * _progress, true);
	draw_set_alpha(1);
	draw_set_color(c_white);
	exit;
}
draw_set_color(blast_radius > 0 ? COLOR_PUMPKIN_PATCH : COLOR_HUD_TEXT);
draw_circle(x, y, blast_radius > 0 ? 6 : 3, false);
draw_set_color(c_white);
