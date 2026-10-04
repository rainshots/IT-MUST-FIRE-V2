/// @description Updates gathering and night marching in an army archer instance's context.
function army_unit_ai_update()
{
	// Army orders replace automatic combat targeting.
	target_instance = noone;
	alert_target = noone;
	is_attacking_target = false;
	is_walking = false;

	// Only units that have reached their gathering point can join the night march.
	if (global.day_phase != DAY_PHASE.NIGHT)
	{
		army_night_march_active = false;
	}
	else if (!army_night_march_active && instance_exists(army_point))
	{
		army_night_march_active = point_distance(x, y, army_point.x, army_point.y)
			<= army_point.gather_radius;
	}

	// Keep marching after leaving the point; late reinforcements gather first.
	if (army_night_march_active)
	{
		var _march_target_x = min(room_width - BALANCE_ARMY_UNIT_ARRIVE_RADIUS,
			x + BALANCE_ARMY_UNIT_MARCH_LOOKAHEAD);
		if (_march_target_x > x)
		{
			move_towards_world_point(_march_target_x, y);
		}
		update_walk_sway();
		return;
	}

	// Missing or removed gathering points are searched for at a limited frequency.
	if (!instance_exists(army_point))
	{
		army_point_search_timer_seconds -= gameplay_time_scale / max(1, room_speed);
		if (army_point_search_timer_seconds <= 0)
		{
			army_point_search_timer_seconds = BALANCE_ARMY_POINT_SEARCH_INTERVAL_SECONDS;
			army_point = instance_nearest(x, y, o_army_point);
			if (instance_exists(army_point))
			{
				var _full_circle = 360;
				var _angle = random(_full_circle);
				var _radius = sqrt(random(1)) * max(0,
					army_point.gather_radius - BALANCE_ARMY_UNIT_ARRIVE_RADIUS);
				army_wait_offset_x = lengthdir_x(_radius, _angle);
				army_wait_offset_y = lengthdir_y(_radius, _angle);
			}
		}
	}

	// Keep the chosen offset so waiting units do not continuously pick new destinations.
	if (instance_exists(army_point))
	{
		var _wait_x = army_point.x + army_wait_offset_x;
		var _wait_y = army_point.y + army_wait_offset_y;
		if (point_distance(x, y, _wait_x, _wait_y) > BALANCE_ARMY_UNIT_ARRIVE_RADIUS)
		{
			move_towards_world_point(_wait_x, _wait_y);
		}
	}
	update_walk_sway();
}
