// Inactive spreaders use staggered checks to remain cheap when many are placed.
if (global.pause)
{
	exit;
}

var _time_scale = variable_global_exists("gameplay_time_scale") ? global.gameplay_time_scale : 1;

// Keep the activated object alive briefly so its exact effect radius can fade out.
if (is_activated)
{
	activation_effect_timer -= _time_scale;

	if (activation_effect_timer <= 0)
	{
		instance_destroy();
	}

	exit;
}

corruption_check_timer += _time_scale;

if (corruption_check_timer < corruption_check_interval)
{
	exit;
}

corruption_check_timer = 0;
taint_spreader_corruption_update();
