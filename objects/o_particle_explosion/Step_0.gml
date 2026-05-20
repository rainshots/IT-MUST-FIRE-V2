// Pause freezes particle animation and lifetime.
if (global.pause)
{
	exit;
}

// Update explosion progress.
life_timer++;

var _life_progress = clamp(life_timer / life_time, 0, 1);

current_radius = lerp(start_radius, end_radius, _life_progress);
current_alpha = lerp(start_alpha, 0, _life_progress);

if (_life_progress >= 1)
{
	instance_destroy();
}
