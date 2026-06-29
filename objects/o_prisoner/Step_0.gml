if (global.pause)
{
	exit;
}

if (hp <= 0)
{
	instance_destroy();
	exit;
}

if (is_being_dragged)
{
	exit;
}

// Locked prisoners have already been committed to a building and no longer wander.
if (prisoner_locked)
{
	if (instance_exists(assigned_prisoner_building))
	{
		x = assigned_prisoner_building.x;
		y = assigned_prisoner_building.y + 18;
	}

	exit;
}

// Free prisoners return to the prison cell and idle around it.
var _home = home_prison_cell;

if (!instance_exists(_home))
{
	exit;
}

assigned_prisoner_building = _home;

if (idle_wander_wait_timer > 0)
{
	idle_wander_wait_timer--;
}

var _distance_to_target = point_distance(x, y, idle_wander_target_x, idle_wander_target_y);

if (_distance_to_target <= idle_wander_arrive_distance && idle_wander_wait_timer <= 0)
{
	var _wander_direction = random(360);
	var _wander_distance = random_range(12, 46);
	idle_wander_target_x = _home.x + lengthdir_x(_wander_distance, _wander_direction);
	idle_wander_target_y = _home.y + lengthdir_y(_wander_distance, _wander_direction);
	idle_wander_wait_timer = irandom_range(round(0.5 * room_speed), round(1.8 * room_speed));
}

var _distance_to_home = point_distance(x, y, _home.x, _home.y);

if (_distance_to_home > 120)
{
	idle_wander_target_x = _home.x;
	idle_wander_target_y = _home.y;
}

var _move_direction = point_direction(x, y, idle_wander_target_x, idle_wander_target_y);
var _move_step = min(move_speed, point_distance(x, y, idle_wander_target_x, idle_wander_target_y));
x += lengthdir_x(_move_step, _move_direction);
y += lengthdir_y(_move_step, _move_direction);
drag_drop_x = x;
drag_drop_y = y;
