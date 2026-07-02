// Draw Griffith's active area so the player can read the melee splash.
draw_set_color(COLOR_PROJECTILE_CLEANSE);
draw_set_alpha(0.18);
draw_circle(x, y, aoe_radius, false);
draw_set_alpha(0.55);
draw_circle(x, y, aoe_radius, true);

// Draw lingering leap trails before the sprite.
for (var _segment_index = 0; _segment_index < array_length(griffith_leap_visual_segments); ++_segment_index)
{
	var _segment = griffith_leap_visual_segments[_segment_index];
	var _segment_progress = clamp(_segment.timer / max(1, _segment.duration), 0, 1);
	var _segment_alpha = 0.7 * _segment_progress;
	var _segment_direction = point_direction(_segment.start_x, _segment.start_y, _segment.end_x, _segment.end_y);
	var _middle_x = (_segment.start_x + _segment.end_x) * 0.5 + lengthdir_x(10, _segment_direction + 90);
	var _middle_y = (_segment.start_y + _segment.end_y) * 0.5 + lengthdir_y(10, _segment_direction + 90);

	draw_set_color(COLOR_PROJECTILE_CLEANSE);
	draw_set_alpha(_segment_alpha * 0.55);
	draw_line_width(_segment.start_x, _segment.start_y - 16, _middle_x, _middle_y - 16, 11);
	draw_line_width(_middle_x, _middle_y - 16, _segment.end_x, _segment.end_y - 16, 11);
	draw_set_alpha(_segment_alpha);
	draw_line_width(_segment.start_x, _segment.start_y - 16, _middle_x, _middle_y - 16, 4);
	draw_line_width(_middle_x, _middle_y - 16, _segment.end_x, _segment.end_y - 16, 4);
}

draw_set_color(c_white);
draw_set_alpha(1);

// Draw base combat visuals.
event_inherited();
