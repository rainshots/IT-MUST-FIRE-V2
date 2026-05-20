// Pause freezes particle movement and lifetime.
if (global.pause)
{
	exit;
}

// Update lifetime progress.
life_timer++;

var _life_progress = clamp(life_timer / life_time, 0, 1);

// Drift upward and fade out.
x += move_speed_x;
y += move_speed_y;
current_radius = lerp(start_radius, end_radius, _life_progress);
current_alpha = lerp(start_alpha, 0, _life_progress);

if (_life_progress >= 1)
{
	instance_destroy();
}
