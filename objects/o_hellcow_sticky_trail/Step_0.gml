// Pause freezes both the zone lifetime and status refreshes.
if (global.pause)
{
	exit;
}

gameplay_time_scale = variable_global_exists("gameplay_time_scale")
	? global.gameplay_time_scale
	: 1;

// An unexpectedly removed owner still leaves behind a complete timed trail.
if (!trail_finished && !instance_exists(trail_owner))
{
	hellcow_sticky_trail_finish();
}

if (trail_finished)
{
	lifetime_timer -= gameplay_time_scale;

	if (lifetime_timer <= 0)
	{
		instance_destroy();
		exit;
	}
}

slow_scan_timer -= gameplay_time_scale;

if (slow_scan_timer <= 0)
{
	slow_scan_timer = slow_scan_interval;
	hellcow_sticky_trail_slow_apply();
}
