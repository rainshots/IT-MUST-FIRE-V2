// Passive summoning continues while regular movement may be paused by leap movement.
if (!global.pause)
{
	griffith_summon_update();
}

if (!griffith_leap_is_active)
{
	event_inherited();
}
else if (global.pause)
{
	exit;
}
else if (hp <= 0)
{
	unit_death_process();
	exit;
}

// Update leap cooldown and retry when the boss has valid targets.
if (!global.pause && hp > 0)
{
	for (var _segment_index = array_length(griffith_leap_visual_segments) - 1; _segment_index >= 0; --_segment_index)
	{
		var _segment = griffith_leap_visual_segments[_segment_index];
		_segment.timer--;

		if (_segment.timer <= 0)
		{
			array_delete(griffith_leap_visual_segments, _segment_index, 1);
		}
		else
		{
			griffith_leap_visual_segments[_segment_index] = _segment;
		}
	}

	if (griffith_leap_timer > 0)
	{
		griffith_leap_timer--;
	}

	if (griffith_leap_retry_timer > 0)
	{
		griffith_leap_retry_timer--;
	}

	if (griffith_leap_is_active)
	{
		griffith_leap_update();
	}
	else if (griffith_leap_timer <= 0 && griffith_leap_retry_timer <= 0)
	{
		if (griffith_leap_use())
		{
			griffith_leap_timer = BALANCE_BOSS_GRIFFITH_LEAP_COOLDOWN * room_speed;
		}
		else
		{
			griffith_leap_retry_timer = BALANCE_ABILITY_FAILED_RETRY_TIME * room_speed;
		}
	}
}
