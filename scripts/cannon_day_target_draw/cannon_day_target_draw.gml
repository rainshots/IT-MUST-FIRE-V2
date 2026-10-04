/// @description Draws a daytime cannon landing reticle and restores the project draw defaults.
/// @param {real} target_x World-space horizontal landing position.
/// @param {real} target_y World-space vertical landing position.
/// @param {real} radius Projectile effect radius in world pixels.
function cannon_day_target_draw(_target_x, _target_y, _radius)
{
	// A light fill and an outlined circle show the full impact radius.
	var _fill_alpha = 0.12;
	var _cross_half_size = 12;
	var _line_width = 2;
	draw_set_color(COLOR_CANNON_DAY_TARGET);
	draw_set_alpha(_fill_alpha);
	draw_circle(_target_x, _target_y, _radius, false);
	draw_set_alpha(1);
	draw_circle(_target_x, _target_y, _radius, true);
	draw_line_width(_target_x - _cross_half_size, _target_y, _target_x + _cross_half_size, _target_y, _line_width);
	draw_line_width(_target_x, _target_y - _cross_half_size, _target_x, _target_y + _cross_half_size, _line_width);

	// Restore the project defaults for subsequent world drawing.
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
	draw_set_alpha(1);
}
