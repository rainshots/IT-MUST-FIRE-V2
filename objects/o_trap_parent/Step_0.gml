// Pause freezes both enemy detection and the activation countdown.
if (global.pause)
{
	exit;
}

var _time_scale = variable_global_exists("gameplay_time_scale")
	? global.gameplay_time_scale
	: 1;

// Once armed, a trap always completes its countdown.
if (is_armed)
{
	activation_timer = max(activation_timer - _time_scale, 0);

	if (activation_timer <= 0 && !is_activated)
	{
		is_activated = true;
		trap_activate();
	}

	exit;
}

// Scan for the minimum enemy group on a short fixed update interval.
detection_timer += _time_scale;

if (detection_timer < detection_interval)
{
	exit;
}

detection_timer = 0;

if (trap_enemy_count_get(minimum_enemy_count) >= minimum_enemy_count)
{
	is_armed = true;
	activation_timer = activation_delay;
}
