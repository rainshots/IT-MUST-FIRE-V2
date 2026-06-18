// Receive a freshly selected target from the game controller.
if (global.cannon_target_exists && target_version != global.cannon_target_version)
{
	target_exists = true;
	target_x = global.cannon_target_x;
	target_y = global.cannon_target_y;
	target_projectile_type = global.cannon_target_projectile_type;
	target_version = global.cannon_target_version;

	// Fire once at the freshly selected target, including player-paused target selection.
	var _can_fire_selected_target = !global.pause || global.focus_window == FOCUS_WINDOW.NOONE;

	if (_can_fire_selected_target)
	{
		var _projectile_queue_count = array_length(global.cannon_projectile_queue);
		var _target_projectile_queue_index = 0;
		var _fired_projectile_count = volley_projectile_count;
		var _projectile_payload = noone;
		var _remaining_cultist_projectile_count = 0;

		if (variable_global_exists("cannon_target_projectile_queue_index"))
		{
			_target_projectile_queue_index = clamp(global.cannon_target_projectile_queue_index, 0, max(0, _projectile_queue_count - 1));
		}

		if (_projectile_queue_count > 0
			&& _target_projectile_queue_index < array_length(global.cannon_projectile_payload_queue))
		{
			_projectile_payload = global.cannon_projectile_payload_queue[_target_projectile_queue_index];
		}

		if (target_projectile_type == PROJECTILE_TYPE.CULTIST)
		{
			for (var _cultist_queue_index = 0; _cultist_queue_index < _projectile_queue_count; ++_cultist_queue_index)
			{
				if (global.cannon_projectile_queue[_cultist_queue_index] == PROJECTILE_TYPE.CULTIST)
				{
					_remaining_cultist_projectile_count++;
				}
			}
		}

		global.cannon_fire_version++;
		global.sound_play_random(global.cannon_shot_sounds);

		if (instance_exists(o_camera_controller))
		{
			var _camera_controller = instance_find(o_camera_controller, 0);
			_camera_controller.camera_shake_start(BALANCE_CANNON_SHOT_SHAKE_TIME, BALANCE_CANNON_SHOT_SHAKE_STRENGTH);
		}

		if (target_projectile_type == PROJECTILE_TYPE.RALLY
			|| target_projectile_type == PROJECTILE_TYPE.CULTIST)
		{
			_fired_projectile_count = 1;
		}
		else if (target_projectile_type == PROJECTILE_TYPE.FEAST)
		{
			_fired_projectile_count = cannon_feast_projectile_count_get();
		}

		for (var _projectile_index = 0; _projectile_index < _fired_projectile_count; ++_projectile_index)
		{
			var _spread_direction = random(360);
			var _spread_radius = volley_spread_radius;

			if (target_projectile_type == PROJECTILE_TYPE.FEAST)
			{
				_spread_radius = cannon_feast_radius_get();
			}

			var _spread_distance = sqrt(random(1)) * _spread_radius;
			var _spread_target_x = target_x + lengthdir_x(_spread_distance, _spread_direction);
			var _spread_target_y = target_y + lengthdir_y(_spread_distance, _spread_direction);
			var _launch_delay_seconds = random_range(volley_launch_delay_min, volley_launch_delay_max);
			var _projectile_x = x;
			var _projectile_y = y + projectile_spawn_offset_y;
			var _projectile = instance_create_layer(_projectile_x, _projectile_y, projectile_layer_name, o_projectile);

			if (target_projectile_type == PROJECTILE_TYPE.RALLY
				|| target_projectile_type == PROJECTILE_TYPE.CULTIST)
			{
				_spread_target_x = target_x;
				_spread_target_y = target_y;
				_launch_delay_seconds = 0;
			}
			else if (target_projectile_type == PROJECTILE_TYPE.FEAST)
			{
				_launch_delay_seconds = random(BALANCE_CANNON_FEAST_PROJECTILE_LAUNCH_TIME);
			}

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
			_projectile.cultist_payload = _projectile_payload;
			_projectile.ignore_pause = global.pause;
			_projectile.launch_delay_timer = _launch_delay_seconds * room_speed;
			_projectile.flight_time = _flight_time_seconds * room_speed;

			if (target_projectile_type == PROJECTILE_TYPE.CULTIST)
			{
				global.first_night_cultist_projectile_fired = true;
				_projectile.effect_radius = BALANCE_CULTIST_PROJECTILE_EFFECT_RADIUS;
				_projectile.damage_amount = BALANCE_CULTIST_PROJECTILE_DAMAGE_AMOUNT;
				_projectile.ground_corruption_amount = BALANCE_CULTIST_PROJECTILE_CORRUPTION_AMOUNT;
				_projectile.ground_corruption_radius = BALANCE_CULTIST_PROJECTILE_CORRUPTION_RADIUS;

				if (instance_exists(o_game_controller))
				{
					var _game_controller = instance_find(o_game_controller, 0);
					_projectile.cultist_deploy_units = _game_controller.cultist_projectile_deploy_units_take(_remaining_cultist_projectile_count);
				}
			}
			else if (target_projectile_type == PROJECTILE_TYPE.FEAST)
			{
				_projectile.effect_radius = BALANCE_CANNON_FEAST_PROJECTILE_VISUAL_RADIUS;
				_projectile.damage_amount = BALANCE_CANNON_FEAST_DAMAGE_AMOUNT;
				_projectile.ground_corruption_amount = BALANCE_CANNON_FEAST_CORRUPTION_AMOUNT;
				_projectile.ground_corruption_radius = BALANCE_CANNON_FEAST_PROJECTILE_CORRUPTION_RADIUS;
			}
			else if (target_projectile_type == PROJECTILE_TYPE.HEAL)
			{
				_projectile.effect_radius = BALANCE_PROJECTILE_HEAL_RADIUS;
				_projectile.damage_amount = cannon_projectile_heal_amount_get();
			}
			else if (target_projectile_type == PROJECTILE_TYPE.BOMB)
			{
				_projectile.effect_radius = BALANCE_PROJECTILE_BOMB_RADIUS;
				_projectile.damage_amount = cannon_projectile_bomb_damage_get();
			}
			else if (target_projectile_type == PROJECTILE_TYPE.SKELETONS)
			{
				_projectile.effect_radius = BALANCE_PROJECTILE_SKELETON_RADIUS;
				_projectile.summon_count = cannon_projectile_skeleton_count_get();
			}
		}

		// Remove the fired projectile from its selected queue slot when the target consumed it.
		if (_projectile_queue_count > 0
			&& (!variable_global_exists("cannon_target_consumes_projectile_queue") || global.cannon_target_consumes_projectile_queue))
		{
			var _updated_projectile_queue = array_create(_projectile_queue_count - 1);
			var _updated_projectile_payload_queue = array_create(_projectile_queue_count - 1);
			var _payload_queue_count = array_length(global.cannon_projectile_payload_queue);
			var _write_queue_index = 0;

			for (var _queue_index = 0; _queue_index < _projectile_queue_count; ++_queue_index)
			{
				if (_queue_index == _target_projectile_queue_index)
				{
					continue;
				}

				_updated_projectile_queue[_write_queue_index] = global.cannon_projectile_queue[_queue_index];

				if (_queue_index < _payload_queue_count)
				{
					_updated_projectile_payload_queue[_write_queue_index] = global.cannon_projectile_payload_queue[_queue_index];
				}
				else
				{
					_updated_projectile_payload_queue[_write_queue_index] = noone;
				}

				_write_queue_index++;
			}

			global.cannon_projectile_queue = _updated_projectile_queue;
			global.cannon_projectile_payload_queue = _updated_projectile_payload_queue;
			global.cannon_selected_projectile_index = clamp(_target_projectile_queue_index, 0, max(0, array_length(global.cannon_projectile_queue) - 1));
		}
	}
}
