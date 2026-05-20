// Pause freezes popup movement and lifetime.
if (global.pause)
{
	exit;
}

// Move upward and fade out over lifetime.
life_timer++;
y += move_speed_y;

var _life_progress = clamp(life_timer / life_time, 0, 1);
current_alpha = lerp(start_alpha, 0, _life_progress);

if (_life_progress >= 1)
{
	instance_destroy();
}
