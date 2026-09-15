// Shared trigger settings are configured by each child trap after this event.
trap_radius = 0;
minimum_enemy_count = BALANCE_TRAP_MINIMUM_ENEMY_COUNT;
activation_delay = BALANCE_TRAP_ACTIVATION_DELAY * room_speed;
activation_timer = 0;
is_armed = false;
is_activated = false;
// Consumed traps remain hidden while their independent respawn timer runs.
respawn_duration = BALANCE_TRAP_RESPAWN_TIME * room_speed;
respawn_timer = 0;
is_respawning = false;

// Stagger detection checks so many traps do not scan on the same frame.
detection_interval = max(1, round(BALANCE_TRAP_DETECTION_INTERVAL * room_speed));
detection_timer = irandom(detection_interval - 1);

// Armed traps show their exact effect area until they activate.
warning_color = c_white;
warning_fill_alpha = BALANCE_TRAP_WARNING_FILL_ALPHA;
warning_outline_alpha = BALANCE_TRAP_WARNING_OUTLINE_ALPHA;
y_sort_enabled = true;
image_speed = 0;

// Trap Points use this optional owner link for automatic morning restoration.
owner_trap_point = noone;
trap_point_slot_index = -1;

trap_enemy_is_valid = function(_enemy)
{
	return instance_exists(_enemy)
		&& _enemy.visible
		&& variable_instance_exists(_enemy, "hp")
		&& _enemy.hp > 0
		&& (!variable_instance_exists(_enemy, "is_being_dragged")
			|| !_enemy.is_being_dragged);
};

trap_enemy_count_get = function(_stop_after_count)
{
	var _enemy_list = ds_list_create();
	var _collision_count = collision_circle_list(
		x,
		y,
		trap_radius,
		o_enemy_units,
		false,
		true,
		_enemy_list,
		false
	);
	var _valid_enemy_count = 0;

	// Stop as soon as the trigger threshold is reached.
	for (var _enemy_index = 0; _enemy_index < _collision_count; ++_enemy_index)
	{
		var _enemy = _enemy_list[| _enemy_index];

		if (trap_enemy_is_valid(_enemy))
		{
			_valid_enemy_count++;

			if (_valid_enemy_count >= _stop_after_count)
			{
				break;
			}
		}
	}

	ds_list_destroy(_enemy_list);
	return _valid_enemy_count;
};

// Keep the instance and owner slot while temporarily removing the trap from play.
trap_respawn_start = function()
{
	is_respawning = true;
	respawn_timer = respawn_duration;
	is_armed = false;
	is_activated = false;
	activation_timer = 0;
	visible = false;
};

// Child traps replace this with their gameplay effect, then start their respawn timer.
trap_activate = function()
{
	trap_respawn_start();
};
