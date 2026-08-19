// Pause freezes popup movement and lifetime.
if (global.pause)
{
	exit;
}

// Move upward and fade out over lifetime.
var _time_scale = variable_global_exists("gameplay_time_scale") ? global.gameplay_time_scale : 1;
life_timer += _time_scale;
y += move_speed_y * _time_scale;

var _life_progress = clamp(life_timer / life_time, 0, 1);
current_alpha = lerp(start_alpha, 0, _life_progress);

if (_life_progress >= 1)
{
	instance_destroy();
}
