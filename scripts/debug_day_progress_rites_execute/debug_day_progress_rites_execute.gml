/// @description Completes up to Cultist count minus one offered Rites, excluding Cannon, personal, Blood Bath and construction/recruitment cards.
function debug_day_progress_rites_execute()
{
	// Reduce the automatic daily Rite budget by one; worker and Spirit rules stay unchanged.
	var _rite_limit_reduction = 1;
	var _rite_limit = max(0, day_event_cultist_count_get() - _rite_limit_reduction);
	if (_rite_limit <= 0)
	{
		return 0;
	}

	// Snapshot today's cards after construction; never generate a replacement or a full catalog.
	var _candidates = [];
	var _event_count = array_length(global.day_events);
	for (var _event_index = 0; _event_index < _event_count; ++_event_index)
	{
		var _event = global.day_events[_event_index];
		if (!is_struct(_event)
			|| _event.is_resolved
			|| variable_struct_exists(_event, "construction_site")
			|| (variable_struct_exists(_event, "reserves_squad_slot") && _event.reserves_squad_slot)
			|| (variable_struct_exists(_event, "is_cannon_demand") && _event.is_cannon_demand)
			|| variable_struct_exists(_event, "required_cultist")
			|| (variable_struct_exists(_event, "is_cultist_mastery") && _event.is_cultist_mastery))
		{
			continue;
		}

		// Personal offers (including Mastery) and Cannon demands remain manual-only during the cheat.
		var _is_excluded_rite = variable_struct_exists(_event, "source_building")
			&& instance_exists(_event.source_building)
			&& (_event.source_building.object_index == o_meat_bath
				|| _event.source_building.object_index == o_cannon
				|| _event.source_building.object_index == o_cultist);
		var _action_count = array_length(_event.actions);
		for (var _action_index = 0; _action_index < _action_count; ++_action_index)
		{
			if (_event.actions[_action_index].action_type == "blood_bath")
			{
				_is_excluded_rite = true;
				break;
			}
		}
		if (!_is_excluded_rite)
		{
			array_push(_candidates, _event);
		}
	}

	// Shuffle each bounded pass; a completed card may enable a previously unavailable recipient.
	var _completed_count = 0;
	var _candidate_count = array_length(_candidates);
	for (var _rite_index = 0; _rite_index < _rite_limit; ++_rite_index)
	{
		for (var _shuffle_index = _candidate_count - 1; _shuffle_index > 0; --_shuffle_index)
		{
			var _swap_index = irandom(_shuffle_index);
			var _swap_event = _candidates[_swap_index];
			_candidates[_swap_index] = _candidates[_shuffle_index];
			_candidates[_shuffle_index] = _swap_event;
		}
		var _completed = false;
		for (var _candidate_index = 0; _candidate_index < _candidate_count; ++_candidate_index)
		{
			if (debug_day_progress_rite_execute(_candidates[_candidate_index]))
			{
				_completed_count++;
				_completed = true;
				break;
			}
		}
		if (!_completed)
		{
			break;
		}
	}
	return _completed_count;
}
