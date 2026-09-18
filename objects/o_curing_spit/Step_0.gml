// Cancel fields at dawn and freeze both duration and pulse clocks while paused.
if (global.day_phase != DAY_PHASE.NIGHT)
{
	instance_destroy();
	exit;
}
if (global.pause)
{
	exit;
}
// Every pulse uses the current Gaze, including permanent radius increases.
if (instance_exists(source_cannon))
{
	x = source_cannon.gaze_x;
	y = source_cannon.gaze_y;
	effect_radius = source_cannon.gaze_radius;
}
var _time_step = min(life_remaining, global.gameplay_time_scale);
life_remaining = max(0, life_remaining - _time_step);
pulse_elapsed += _time_step;
// Catch up crossed pulse boundaries without adding an extra pulse at impact or expiry.
var _pulse_count = floor(pulse_elapsed / pulse_interval);
for (var _pulse_index = 0; _pulse_index < _pulse_count; ++_pulse_index)
{
	curing_spit_pulse(id);
}
pulse_elapsed -= _pulse_count * pulse_interval;
if (life_remaining <= 0)
{
	instance_destroy();
}
