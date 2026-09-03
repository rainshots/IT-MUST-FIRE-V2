// Sticky Trail covers the same full corridor shown while aiming HellCow.
trail_owner = noone;
trail_start_x = x;
trail_start_y = y;
trail_end_x = x;
trail_end_y = y;
trail_direction = 0;
trail_length = 0;
trail_width = BALANCE_PROJECTILE_HELLCOW_STICKY_TRAIL_WIDTH;
trail_finished = false;
lifetime_duration = max(1, BALANCE_PROJECTILE_HELLCOW_STICKY_TRAIL_LIFETIME * room_speed);
lifetime_timer = lifetime_duration;
slow_scan_interval = max(1, BALANCE_PROJECTILE_HELLCOW_STICKY_TRAIL_SCAN_INTERVAL * room_speed);
slow_scan_timer = 0;
gameplay_time_scale = 1;

hellcow_sticky_trail_corridor_set = function(_start_x, _start_y, _direction)
{
	trail_start_x = _start_x;
	trail_start_y = _start_y;
	trail_direction = _direction;
	trail_length = BALANCE_PROJECTILE_HELLCOW_CHARGE_DISTANCE;
	trail_end_x = trail_start_x + lengthdir_x(trail_length, trail_direction);
	trail_end_y = trail_start_y + lengthdir_y(trail_length, trail_direction);
};

hellcow_sticky_trail_finish = function()
{
	if (trail_finished)
	{
		return false;
	}

	trail_finished = true;
	lifetime_timer = lifetime_duration;
	return true;
};

hellcow_sticky_trail_enemy_is_inside = function(_enemy)
{
	if (!instance_exists(_enemy) || trail_length <= 0)
	{
		return false;
	}

	var _direction_x = lengthdir_x(1, trail_direction);
	var _direction_y = lengthdir_y(1, trail_direction);
	var _side_x = -_direction_y;
	var _side_y = _direction_x;
	var _offset_x = _enemy.x - trail_start_x;
	var _offset_y = _enemy.y - trail_start_y;
	var _forward_distance = (_offset_x * _direction_x) + (_offset_y * _direction_y);
	var _side_distance = (_offset_x * _side_x) + (_offset_y * _side_y);

	return _forward_distance >= 0
		&& _forward_distance <= trail_length
		&& abs(_side_distance) <= trail_width * 0.5;
};

hellcow_sticky_trail_slow_apply = function()
{
	var _enemy_count = instance_number(o_enemy_units);

	for (var _enemy_index = 0; _enemy_index < _enemy_count; ++_enemy_index)
	{
		var _enemy = instance_find(o_enemy_units, _enemy_index);

		if (!instance_exists(_enemy)
			|| _enemy.hp <= 0
			|| !hellcow_sticky_trail_enemy_is_inside(_enemy)
			|| !variable_instance_exists(_enemy, "status_effect_apply"))
		{
			continue;
		}

		_enemy.status_effect_apply(
			STATUS_EFFECT.SLOW,
			BALANCE_PROJECTILE_HELLCOW_STICKY_TRAIL_SLOW_REFRESH_TIME,
			BALANCE_PROJECTILE_HELLCOW_STICKY_TRAIL_SLOW_AMOUNT,
			0,
			0,
			UNIT_FACTION.FRIENDLY
		);
	}
};
