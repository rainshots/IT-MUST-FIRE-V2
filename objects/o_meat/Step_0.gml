// Meat waits on the ground until morning cleanup begins.
if (!is_fading_out)
{
	exit;
}

var _time_scale = variable_global_exists("gameplay_time_scale") ? global.gameplay_time_scale : 1;
fade_timer += _time_scale;

var _fade_progress = clamp(fade_timer / max(1, fade_time), 0, 1);
image_alpha = 1 - _fade_progress;

if (_fade_progress >= 1)
{
	instance_destroy();
}
