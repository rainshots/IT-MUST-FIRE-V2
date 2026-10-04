// Activation follows simulation time and stops while gameplay is paused.
if (!is_infected || (variable_global_exists("pause") && global.pause))
{
	exit;
}

var _time_scale = variable_global_exists("gameplay_time_scale") ? global.gameplay_time_scale : 1;
activation_timer_seconds += _time_scale / max(1, room_speed);
if (activation_timer_seconds < activation_interval_seconds)
{
	exit;
}
activation_timer_seconds = 0;

// Activate at most one surviving inactive grave per interval.
var _linked_count = array_length(linked_graves);
for (var _grave_index = 0; _grave_index < _linked_count; ++_grave_index)
{
	var _grave = linked_graves[_grave_index];
	if (instance_exists(_grave) && !_grave.is_active)
	{
		_grave.is_active = true;
		_grave.sprite_index = s_grave_a_active;
		break;
	}
}
