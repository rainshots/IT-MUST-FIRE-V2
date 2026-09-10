/// @description Completes a legal construction immediately without assigning or charging workers.
function debug_day_progress_construction_execute(_site, _choice, _is_special_point = false)
{
	if (!instance_exists(_site)
		|| (variable_instance_exists(_site, "construction_event_pending")
			&& _site.construction_event_pending))
	{
		return false;
	}

	// The regular order function enforces daily and duplicate limits and reserves the site.
	var _event = day_event_building_construction_create(_site, _choice, _is_special_point);
	if (!is_struct(_event))
	{
		return false;
	}

	// Use the normal completion callback for garrisons, captured towers and trap formations.
	var _action = _event.actions[0];
	var _completed = _action.execute(_event, []);
	if (_completed)
	{
		_event.is_resolved = true;
		_event.activation_count = 1;
		array_push(global.day_event_completed_events, _event);
		array_push(global.day_event_executed_log_lines, "[Auto] " + _event.title);
	}
	else
	{
		if (instance_exists(_site))
		{
			_site.construction_event_pending = false;
		}
		if (!_is_special_point)
		{
			global.building_construction_count_today = max(0, global.building_construction_count_today - 1);
		}
	}

	// Do not leave a completed order counting as a second building or an unfinished assignment.
	var _event_count = array_length(global.day_events);
	for (var _event_index = 0; _event_index < _event_count; ++_event_index)
	{
		if (global.day_events[_event_index] == _event)
		{
			array_delete(global.day_events, _event_index, 1);
			break;
		}
	}
	return _completed;
}
