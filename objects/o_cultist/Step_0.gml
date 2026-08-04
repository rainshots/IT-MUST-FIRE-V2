// Cultists die as soon as any source reduces their HP to zero.
if (hp <= 0)
{
	day_event_cultist_death_remove(id);
	exit;
}

// Pause and a missing home anchor stop regular cultist movement.
if (global.pause || !instance_exists(o_cannon))
{
	exit;
}

// The game controller owns the position while the cultist follows the cursor.
if (is_being_dragged)
{
	exit;
}

// Cursed Point construction workers return home and remain there during the night.
if (global.day_phase == DAY_PHASE.NIGHT)
{
	if (return_to_cannon_at_night)
	{
		var _home_cannon = instance_find(o_cannon, 0);
		var _home_x = _home_cannon.x + home_offset_x;
		var _home_y = _home_cannon.y + home_offset_y;
		var _home_distance = point_distance(x, y, _home_x, _home_y);

		if (_home_distance <= move_speed)
		{
			x = _home_x;
			y = _home_y;
		}
		else
		{
			var _home_direction = point_direction(x, y, _home_x, _home_y);
			x += lengthdir_x(move_speed, _home_direction);
			y += lengthdir_y(move_speed, _home_direction);
			image_xscale = abs(image_xscale) * (_home_x >= x ? 1 : -1);
		}

		drag_drop_x = x;
		drag_drop_y = y;
	}

	exit;
}

// Regular cultists wander and work only during the day.
if (global.day_phase != DAY_PHASE.DAY)
{
	exit;
}

// The retreat request lasts only through the night after construction.
return_to_cannon_at_night = false;

// Jobs assignments replace random wandering with movement to the event's world anchor.
if (is_struct(assigned_event) && instance_exists(o_game_controller))
{
	var _game_controller = instance_find(o_game_controller, 0);

	if (variable_instance_exists(_game_controller, "day_event_worker_position_update"))
	{
		_game_controller.day_event_worker_position_update(id);
	}

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
