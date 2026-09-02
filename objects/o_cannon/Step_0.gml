// Receive a freshly selected target from the game controller.
if (global.cannon_target_exists && target_version != global.cannon_target_version)
{
	target_exists = true;
	target_x = global.cannon_target_x;
	target_y = global.cannon_target_y;
	target_projectile_type = global.cannon_target_projectile_type;
	target_direction = global.cannon_target_direction;
	target_version = global.cannon_target_version;

	// Fire once at the freshly selected target, including player-paused target selection.
	var _can_fire_selected_target = (!global.pause || global.focus_window == FOCUS_WINDOW.NOONE)
		&& cannon_reload_is_ready();

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
		cannon_reload_start(target_projectile_type);
		global.sound_play_random(global.cannon_shot_sounds);

		if (instance_exists(o_camera_controller))
		{
			var _camera_controller = instance_find(o_camera_controller, 0);
			_camera_controller.camera_shake_start(BALANCE_CANNON_SHOT_SHAKE_TIME, BALANCE_CANNON_SHOT_SHAKE_STRENGTH);
		}

		if (target_projectile_type == PROJECTILE_TYPE.RALLY
			|| target_projectile_type == PROJECTILE_TYPE.CULTIST
			|| target_projectile_type == PROJECTILE_TYPE.HEAL
			|| target_projectile_type == PROJECTILE_TYPE.BOMB
			|| target_projectile_type == PROJECTILE_TYPE.BUILDING_SHELL
			|| target_projectile_type == PROJECTILE_TYPE.DOOM_BELL)
		{
			_fired_projectile_count = 1;
		}
		else if (target_projectile_type == PROJECTILE_TYPE.CORRUPTION)
		{
			_fired_projectile_count = cannon_taint_compost_projectile_count_get();
		}

		for (var _projectile_index = 0; _projectile_index < _fired_projectile_count; ++_projectile_index)
		{
			var _spread_direction = random(360);
			var _spread_radius = volley_spread_radius;

			var _spread_distance = sqrt(random(1)) * _spread_radius;
			var _spread_target_x = target_x + lengthdir_x(_spread_distance, _spread_direction);
			var _spread_target_y = target_y + lengthdir_y(_spread_distance, _spread_direction);
			var _launch_delay_seconds = random_range(volley_launch_delay_min, volley_launch_delay_max);
			var _projectile_x = x;
			var _projectile_y = y + projectile_spawn_offset_y;
			var _projectile = instance_create_layer(_projectile_x, _projectile_y, projectile_layer_name, o_projectile);

			if (target_projectile_type == PROJECTILE_TYPE.RALLY
				|| target_projectile_type == PROJECTILE_TYPE.CULTIST
				|| target_projectile_type == PROJECTILE_TYPE.HEAL
				|| target_projectile_type == PROJECTILE_TYPE.BOMB
				|| target_projectile_type == PROJECTILE_TYPE.BUILDING_SHELL
				|| target_projectile_type == PROJECTILE_TYPE.DOOM_BELL)
			{
				_spread_target_x = target_x;
				_spread_target_y = target_y;
				_launch_delay_seconds = 0;
			}
			else if (target_projectile_type == PROJECTILE_TYPE.CORRUPTION && _projectile_index == 0)
			{
				// One primary Compost projectile carries the volley enchantment at the selected center.
				_spread_target_x = target_x;
				_spread_target_y = target_y;
				_launch_delay_seconds = 0;
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
			_projectile.hellcow_charge_direction = target_direction;
			_projectile.effect_radius = projectile_effect_radius;
			_projectile.cultist_payload = _projectile_payload;
			_projectile.building_payload = _projectile_payload;
			_projectile.source_instance = id;
			_projectile.smoke_trail_enabled = true;
			_projectile.damage_faction = UNIT_FACTION.FRIENDLY;
			_projectile.ignore_pause = global.pause;
			_projectile.launch_delay_timer = _launch_delay_seconds * room_speed;
			_projectile.flight_time = _flight_time_seconds * room_speed;

			if (target_projectile_type == PROJECTILE_TYPE.CULTIST)
			{
				global.first_night_cultist_projectile_fired = true;
				_projectile.effect_radius = BALANCE_CULTIST_PROJECTILE_EFFECT_RADIUS;
				_projectile.damage_amount = BALANCE_CULTIST_PROJECTILE_DAMAGE_AMOUNT;
				_projectile.ground_corruption_amount = 0;
				_projectile.ground_corruption_radius = 0;

				if (instance_exists(_projectile_payload))
				{
					_projectile_payload.cannon_loading = false;
					_projectile_payload.cannon_loaded = true;
					_projectile_payload.visible = false;

					if (variable_instance_exists(_projectile_payload, "cultist_projectile_deploy_assigned"))
					{
						_projectile_payload.cultist_projectile_deploy_assigned = true;
						_projectile_payload.cultist_projectile_deploy_waiting = false;
					}
				}

				if (instance_exists(o_game_controller))
				{
					var _game_controller = instance_find(o_game_controller, 0);
					_projectile.cultist_deploy_units = _game_controller.squad_projectile_deploy_units_take(_projectile_payload);
				}
			}
			else if (target_projectile_type == PROJECTILE_TYPE.HEAL)
			{
				_projectile.effect_radius = cannon_projectile_heal_radius_get();
				_projectile.damage_amount = cannon_projectile_heal_amount_get();
				_projectile.projectile_sprite = s_heal_meat;
				_projectile.first_aid_meat_enchantment = global.shell_factory_first_aid_enchantment;
			}
			else if (target_projectile_type == PROJECTILE_TYPE.BOMB)
			{
				_projectile.effect_radius = BALANCE_PROJECTILE_HELLCOW_RADIUS;
				_projectile.damage_amount = cannon_projectile_bomb_damage_get();
				_projectile.projectile_sprite = s_cow;
			}
			else if (target_projectile_type == PROJECTILE_TYPE.CORRUPTION)
			{
				_projectile.effect_radius = cannon_taint_compost_radius_get();
				_projectile.projectile_sprite = s_taint_shell;
				_projectile.taint_compost_enchantment = global.shell_factory_taint_enchantment;
				_projectile.taint_compost_enchantment_primary = _projectile_index == 0;
				_projectile.taint_compost_enchantment_x = target_x;
				_projectile.taint_compost_enchantment_y = target_y;
			}
			else if (target_projectile_type == PROJECTILE_TYPE.DOOM_BELL)
			{
				_projectile.effect_radius = BALANCE_PROJECTILE_DOOM_BELL_RADIUS;
				_projectile.projectile_sprite = s_mega_bell;
				_projectile.projectile_sprite_scale *= BALANCE_PROJECTILE_DOOM_BELL_VISUAL_SCALE_MULTIPLIER;
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

			var _next_selected_projectile_index = clamp(_target_projectile_queue_index, 0, max(0, array_length(global.cannon_projectile_queue) - 1));
			var _fired_type_can_stack = target_projectile_type != PROJECTILE_TYPE.CULTIST
				&& target_projectile_type != PROJECTILE_TYPE.BUILDING_SHELL;

			if (_fired_type_can_stack)
			{
				var _remaining_projectile_count = array_length(global.cannon_projectile_queue);

				for (var _remaining_index = 0; _remaining_index < _remaining_projectile_count; ++_remaining_index)
				{
					if (global.cannon_projectile_queue[_remaining_index] == target_projectile_type)
					{
						_next_selected_projectile_index = _remaining_index;
						break;
					}
				}
			}

			global.cannon_selected_projectile_index = _next_selected_projectile_index;
		}
	}
}

// Reload progress follows gameplay time and pauses with the simulation.
if (!global.pause && cannon_reload_timer > 0)
{
	cannon_reload_timer = max(cannon_reload_timer - global.gameplay_time_scale, 0);
}

// Maximum Satisfaction periodically produces a free shot during combat.
cannon_satisfaction_auto_fire_update();
