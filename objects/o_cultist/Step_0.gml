// Regular cultists wander near the cannon only during the day.
if (global.pause || global.day_phase != DAY_PHASE.DAY || hp <= 0 || !instance_exists(o_cannon))
{
	exit;
}

var _cannon = instance_find(o_cannon, 0);
wander_timer--;

if (wander_timer <= 0 || point_distance(x, y, wander_target_x, wander_target_y) <= move_speed)
{
	// Positive Y keeps cultists visibly in front of the cannon.
	wander_target_x = _cannon.x + random_range(
		-BALANCE_EVENT_CULTIST_WANDER_HORIZONTAL_DISTANCE,
		BALANCE_EVENT_CULTIST_WANDER_HORIZONTAL_DISTANCE
	);
	wander_target_y = _cannon.y + random_range(
		BALANCE_EVENT_CULTIST_WANDER_VERTICAL_DISTANCE_MIN,
		BALANCE_EVENT_CULTIST_WANDER_VERTICAL_DISTANCE_MAX
	);
	wander_timer = BALANCE_EVENT_CULTIST_WANDER_DELAY;
}

var _move_direction = point_direction(x, y, wander_target_x, wander_target_y);
x += lengthdir_x(move_speed, _move_direction);
y += lengthdir_y(move_speed, _move_direction);
