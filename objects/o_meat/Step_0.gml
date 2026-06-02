// Meat waits on the ground until morning cleanup begins.
if (!is_fading_out)
{
	exit;
}

fade_timer++;

var _fade_progress = clamp(fade_timer / max(1, fade_time), 0, 1);
image_alpha = 1 - _fade_progress;

if (_fade_progress >= 1)
{
	instance_destroy();
}
