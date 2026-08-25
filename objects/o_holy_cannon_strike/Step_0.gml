if (global.pause)
{
	exit;
}

// An unfinished warning cannot survive the end of its combat night.
if (global.day_phase != DAY_PHASE.NIGHT)
{
	instance_destroy();
	exit;
}

var _time_scale = variable_global_exists("gameplay_time_scale")
	? global.gameplay_time_scale
	: 1;

impact_timer = max(impact_timer - _time_scale, 0);

if (impact_timer <= 0)
{
	holy_cannon_strike_impact();
}
