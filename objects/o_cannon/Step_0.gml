// Receive a freshly selected target from the game controller.
if (global.cannon_target_exists && target_version != global.cannon_target_version)
{
	target_exists = true;
	target_x = global.cannon_target_x;
	target_y = global.cannon_target_y;
	target_projectile_type = global.cannon_target_projectile_type;
	target_version = global.cannon_target_version;

	// Fire once at the freshly selected target.
	if (!global.pause)
	{
		for (var _projectile_index = 0; _projectile_index < volley_projectile_count; ++_projectile_index)
		{
			var _spread_direction = random(360);
			var _spread_distance = sqrt(random(1)) * volley_spread_radius;
			var _spread_target_x = target_x + lengthdir_x(_spread_distance, _spread_direction);
			var _spread_target_y = target_y + lengthdir_y(_spread_distance, _spread_direction);
			var _launch_delay_seconds = random_range(volley_launch_delay_min, volley_launch_delay_max);
			var _projectile_x = x;
			var _projectile_y = y + projectile_spawn_offset_y;
			var _projectile = instance_create_layer(_projectile_x, _projectile_y, projectile_layer_name, o_projectile);
			var _projectile_distance = point_distance(_projectile_x, _projectile_y, _spread_target_x, _spread_target_y);
			var _flight_time_seconds = clamp(
				_projectile_distance / _projectile.projectile_speed,
				_projectile.minimum_flight_time,
				_projectile.maximum_flight_time
			);

			_projectile.start_x = _projectile_x;
			_projectile.start_y = _projectile_y;
			_projectile.target_x = _spread_target_x;
			_projectile.target_y = _spread_target_y;
			_projectile.projectile_type = target_projectile_type;
			_projectile.effect_radius = projectile_effect_radius;
			_projectile.launch_delay_timer = _launch_delay_seconds * room_speed;
			_projectile.flight_time = _flight_time_seconds * room_speed;
		}
	}
}
