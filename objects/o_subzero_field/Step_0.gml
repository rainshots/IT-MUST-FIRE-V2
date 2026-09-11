// Gameplay pause and time scaling also control the field's lifetime and pulses.
if (global.pause)
{
	exit;
}

life_timer = min(life_duration, life_timer + global.gameplay_time_scale);
var _due_pulse_count = floor(life_timer / pulse_interval);

// Catch up all due pulses even if accelerated gameplay crosses several intervals.
for (var _pulse_index = pulse_count; _pulse_index < _due_pulse_count; ++_pulse_index)
{
	subzero_field_pulse();
}
pulse_count = _due_pulse_count;

// Apply the final pulse before removing the expired field.
if (life_timer >= life_duration)
{
	instance_destroy();
}