/// @description Summons one random base squad using an empty Squad Point and the current day limit.
function debug_day_progress_squad_create()
{
	squad_limit_current_day_update();
	if (!squad_slot_is_available())
	{
		return "skipped (squad limit)";
	}

	// Only the choices actually offered by free Squad Points are eligible.
	var _candidates = [];
	var _point_count = instance_number(o_squad_point);
	for (var _point_index = 0; _point_index < _point_count; ++_point_index)
	{
		var _point = instance_find(o_squad_point, _point_index);
		if (!instance_exists(_point)
			|| is_struct(_point.assigned_squad)
			|| _point.squad_point_pending_event_is_active())
		{
			continue;
		}
		var _available_choices = [];
		var _choice_count = array_length(_point.squad_point_choices);
		for (var _choice_index = 0; _choice_index < _choice_count; ++_choice_index)
		{
			var _choice = _point.squad_point_choices[_choice_index];
			if (squad_slot_is_available(_choice.squad_type))
			{
				array_push(_available_choices, _choice);
			}
		}
		if (array_length(_available_choices) > 0)
		{
			array_push(_candidates, { point: _point, choices: _available_choices });
		}
	}

	if (array_length(_candidates) <= 0)
	{
		return "skipped (no available Squad Point)";
	}
	var _selected = _candidates[irandom(array_length(_candidates) - 1)];
	// Roll the composition independently of the spawn point: neither roster uses its default index.
	var _selected_choice_count = array_length(_selected.choices);
	var _selected_choice = _selected.choices[irandom(_selected_choice_count - 1)];
	var _squad = squad_create(_selected_choice.squad_type, _selected_choice.unit_object,
		_selected_choice.unit_count, _selected.point);
	if (!is_struct(_squad))
	{
		return "skipped (summoning failed)";
	}
	array_push(global.day_event_executed_log_lines, "[Auto] Summon " + _selected_choice.squad_name);
	return _selected_choice.squad_name;
}
