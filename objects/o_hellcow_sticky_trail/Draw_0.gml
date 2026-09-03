if (trail_length <= 0)
{
	exit;
}

var _direction_x = lengthdir_x(1, trail_direction);
var _direction_y = lengthdir_y(1, trail_direction);
var _side_x = -_direction_y;
var _side_y = _direction_x;
var _half_width = trail_width * 0.5;
var _start_left_x = trail_start_x + (_side_x * _half_width);
var _start_left_y = trail_start_y + (_side_y * _half_width);
var _start_right_x = trail_start_x - (_side_x * _half_width);
var _start_right_y = trail_start_y - (_side_y * _half_width);
var _end_left_x = trail_end_x + (_side_x * _half_width);
var _end_left_y = trail_end_y + (_side_y * _half_width);
var _end_right_x = trail_end_x - (_side_x * _half_width);
var _end_right_y = trail_end_y - (_side_y * _half_width);

// Use the same two triangles as the aiming preview so the visible zones match exactly.
draw_set_color(COLOR_HELLCOW_STICKY_TRAIL);
draw_set_alpha(BALANCE_PROJECTILE_HELLCOW_STICKY_TRAIL_FILL_ALPHA);
draw_triangle(
	_start_left_x,
	_start_left_y,
	_start_right_x,
	_start_right_y,
	_end_left_x,
	_end_left_y,
	false
);
draw_triangle(
	_start_right_x,
	_start_right_y,
	_end_right_x,
	_end_right_y,
	_end_left_x,
	_end_left_y,
	false
);

draw_set_color(COLOR_HELLCOW_STICKY_TRAIL);
draw_set_alpha(BALANCE_PROJECTILE_HELLCOW_STICKY_TRAIL_OUTLINE_ALPHA);
draw_line_width(
	_start_left_x,
	_start_left_y,
	_end_left_x,
	_end_left_y,
	BALANCE_PROJECTILE_HELLCOW_STICKY_TRAIL_OUTLINE_WIDTH
);
draw_line_width(
	_start_right_x,
	_start_right_y,
	_end_right_x,
	_end_right_y,
	BALANCE_PROJECTILE_HELLCOW_STICKY_TRAIL_OUTLINE_WIDTH
);
draw_line_width(
	_start_left_x,
	_start_left_y,
	_start_right_x,
	_start_right_y,
	BALANCE_PROJECTILE_HELLCOW_STICKY_TRAIL_OUTLINE_WIDTH
);
draw_line_width(
	_end_left_x,
	_end_left_y,
	_end_right_x,
	_end_right_y,
	BALANCE_PROJECTILE_HELLCOW_STICKY_TRAIL_OUTLINE_WIDTH
);

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);
