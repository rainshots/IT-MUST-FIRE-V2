if (!is_sucked || (variable_global_exists("pause") && global.pause))
{
	exit;
}

if (!instance_exists(o_cannon))
{
	exit;
}

var _cannon = instance_find(o_cannon, 0);
var _distance_to_cannon = point_distance(x, y, _cannon.x, _cannon.y);
var _time_scale = variable_global_exists("gameplay_time_scale")
	? global.gameplay_time_scale
	: 1;
var _move_distance = BALANCE_GATHERABLE_MOVE_SPEED * _time_scale;

if (_distance_to_cannon <= max(BALANCE_GATHERABLE_CANNON_REACH_DISTANCE, _move_distance))
{
	on_gather();
	instance_destroy();
	exit;
}

var _direction_to_cannon = point_direction(x, y, _cannon.x, _cannon.y);
x += lengthdir_x(min(_move_distance, _distance_to_cannon), _direction_to_cannon);
y += lengthdir_y(min(_move_distance, _distance_to_cannon), _direction_to_cannon);
