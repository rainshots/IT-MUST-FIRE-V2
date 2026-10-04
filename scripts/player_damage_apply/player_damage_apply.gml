/// @description Applies avatar damage and scatters its body on death. Call only from o_player.
/// @param {real} amount Incoming damage before health is clamped to zero.
function player_damage_apply(_amount)
{
	// The skull cannot take damage until all three body parts have been recovered.
	if (is_disassembled || _amount <= 0)
	{
		return;
	}

	hp = max(0, hp - _amount);
	if (hp > 0)
	{
		return;
	}

	// Change form in place without replacing the instance followed by the camera.
	is_disassembled = true;
	death_lock_remaining = BALANCE_PLAYER_DEATH_LOCK_SECONDS;
	corruption_slow_remaining = 0;
	taint_run_elapsed = 0;
	sprite_index = s_avatar_head;
	image_angle = 0;
	image_index = 0;
	walk_sway_timer = 0;
	walk_sway_direction = 1;
	body_parts_collected = 0;
	body_parts = [];

	// Reflect out-of-room throws inward, preserving each random travel distance.
	var _sprites = [s_avatar_right_hand, s_avatar_left_hand, s_avatar_legs];
	var _part_count = array_length(_sprites);
	var _full_circle = 360;
	for (var _index = 0; _index < _part_count; ++_index)
	{
		var _sprite = _sprites[_index];
		var _direction = random(_full_circle);
		var _distance = random_range(BALANCE_PLAYER_PART_MIN_DISTANCE, BALANCE_PLAYER_PART_MAX_DISTANCE);
		var _offset_x = lengthdir_x(_distance, _direction);
		var _offset_y = lengthdir_y(_distance, _direction);
		var _margin = max(sprite_get_width(_sprite), sprite_get_height(_sprite)) * 0.5;
		if (x + _offset_x < _margin || x + _offset_x > room_width - _margin)
		{
			_offset_x = -_offset_x;
		}
		if (y + _offset_y < _margin || y + _offset_y > room_height - _margin)
		{
			_offset_y = -_offset_y;
		}

		array_push(body_parts,
		{
			sprite: _sprite,
			start_x: x,
			start_y: y,
			target_x: x + _offset_x,
			target_y: y + _offset_y,
			flight_elapsed: 0,
			pulse_phase: 0,
			collected: false
		});
	}
}
