/// @description Advances scattered avatar parts and rebuilds the skeleton after collection. Call from o_player Step.
/// @param {real} step_seconds Elapsed active avatar time in seconds.
/// @param {bool} can_collect Whether the initial death movement lock has expired.
function player_body_parts_update(_step_seconds, _can_collect)
{
	var _part_count = array_length(body_parts);
	var _flight_duration = BALANCE_PLAYER_PART_FLIGHT_SECONDS;
	var _pulse_cycle = 2 * pi;
	var _pulse_period = max(_step_seconds, BALANCE_PLAYER_PART_PULSE_PERIOD_SECONDS);
	var _pulse_step = _pulse_cycle * _step_seconds / _pulse_period;
	for (var _index = 0; _index < _part_count; ++_index)
	{
		var _part = body_parts[_index];
		if (_part.collected)
		{
			continue;
		}

		// A piece must land before approaching the landing point can collect it.
		// Grounded pieces pulse in active gameplay time, so the effect freezes on pause.
		if (_part.flight_elapsed >= _flight_duration)
		{
			_part.pulse_phase = (_part.pulse_phase + _pulse_step) mod _pulse_cycle;
		}

		_part.flight_elapsed = min(_flight_duration, _part.flight_elapsed + _step_seconds);
		if (_can_collect && _part.flight_elapsed >= _flight_duration
			&& point_distance(x, y, _part.target_x, _part.target_y) <= BALANCE_PLAYER_PART_PICKUP_RADIUS)
		{
			_part.collected = true;
			body_parts_collected++;
		}
	}

	// Reconstruction restores exactly the configured health share and clears the carried parts.
	if (_part_count > 0 && body_parts_collected == _part_count)
	{
		is_disassembled = false;
		sprite_index = s_skeleton;
		image_index = 0;
		image_angle = 0;
		hp = max_hp * BALANCE_PLAYER_REASSEMBLE_HP_SHARE;
		death_lock_remaining = 0;
		corruption_slow_remaining = 0;
		taint_run_elapsed = 0;
		body_parts = [];
		body_parts_collected = 0;
		walk_sway_timer = 0;
		walk_sway_direction = 1;
	}
}
