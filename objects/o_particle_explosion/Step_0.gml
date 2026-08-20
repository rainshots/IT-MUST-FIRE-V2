// Pause freezes particle animation and lifetime.
if (global.pause)
{
	exit;
}

// Update explosion progress.
var _time_scale = variable_global_exists("gameplay_time_scale") ? global.gameplay_time_scale : 1;
life_timer += _time_scale;

var _life_progress = clamp(life_timer / life_time, 0, 1);

current_radius = lerp(start_radius, end_radius, _life_progress);
current_alpha = lerp(start_alpha, 0, _life_progress);

if (_life_progress >= 1)
{
	instance_destroy();
}
