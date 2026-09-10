/// @description Auto-staffs and immediately completes one offered Rite without spending Cultist HP.
function debug_day_progress_rite_execute(_event)
{
	if (!is_struct(_event) || _event.is_resolved)
	{
		return false;
	}
	var _event_index = -1;
	var _event_count = array_length(global.day_events);
	for (var _search_index = 0; _search_index < _event_count; ++_search_index)
	{
		if (global.day_events[_search_index] == _event)
		{
			_event_index = _search_index;
			break;
		}
	}
	if (_event_index < 0)
	{
		return false;
	}

	// A new automatic squad may have consumed the slot reserved conceptually by a world Job.
	var _action_count = array_length(_event.actions);
	for (var _action_index = 0; _action_index < _action_count; ++_action_index)
	{
		var _action = _event.actions[_action_index];
		if (_action.action_type == "summon_archdemon"
			&& !day_event_world_archdemon_job_is_available(_action.data.archdemon_number))
		{
			return false;
		}
	}

	// Recruitments and earlier upgrades may have changed which squads can receive this Rite.
	day_event_squad_selection_refresh(_event);
	var _requires_squad = variable_struct_exists(_event, "requires_squad_selection")
		&& _event.requires_squad_selection;
	if (_requires_squad && array_length(_event.eligible_squads) <= 0)
	{
		return false;
	}
	if (variable_struct_exists(_event, "is_cultist_mastery")
		&& _event.is_cultist_mastery
		&& !day_event_cultist_mastery_request_is_valid(_event.mastery_request))
	{
		return false;
	}

	// Keep manual assignments intact and add only available, eligible workers with Spirit.
	var _stored_slot_count = array_length(_event.assigned_cultists);
	var _assigned_count = day_event_assigned_cultist_count_get(_event);
	for (var _assigned_index = 0; _assigned_index < _stored_slot_count; ++_assigned_index)
	{
		var _assigned_cultist = _event.assigned_cultists[_assigned_index];
		if (!instance_exists(_assigned_cultist))
		{
			continue;
		}
		if (_assigned_cultist.hp <= 0
			|| !_event.cultist_is_eligible_check(_assigned_cultist))
		{
			return false;
		}
	}
	var _required_count = max(_event.cultist_cost, _event.execution_cultist_minimum);
	var _missing_count = max(0, _required_count - _assigned_count);
	var _available_cultists = [];
	var _cultist_count = array_length(global.event_cultists);
	for (var _cultist_index = 0; _cultist_index < _cultist_count; ++_cultist_index)
	{
		var _cultist = global.event_cultists[_cultist_index];
		if (_event.cultist_can_assign(_cultist))
		{
			array_push(_available_cultists, _cultist);
		}
	}
	if (array_length(_available_cultists) < _missing_count)
	{
		return false;
	}

	// Auto-progress rolls every choice, including default selections on already staffed cards.
	if (_requires_squad)
	{
		var _squad_choice_count = array_length(_event.eligible_squads);
		_event.selected_squad = _event.eligible_squads[irandom(_squad_choice_count - 1)];
	}
	if (variable_struct_exists(_event, "unit_choice_options")
		&& is_array(_event.unit_choice_options))
	{
		var _unit_choice_count = array_length(_event.unit_choice_options);
		if (_unit_choice_count > 0)
		{
			_event.selected_unit_choice_index = irandom(_unit_choice_count - 1);
		}
	}
	var _added_cultists = [];
	for (var _worker_index = 0; _worker_index < _missing_count; ++_worker_index)
	{
		var _random_index = irandom(array_length(_available_cultists) - 1);
		var _added_cultist = _available_cultists[_random_index];
		if (_event.cultist_assign(_added_cultist))
		{
			array_push(_added_cultists, _added_cultist);
		}
		array_delete(_available_cultists, _random_index, 1);
	}

	// Suppress only HP payment inside normal execution, retaining Spirit, Mastery and all rewards.
	var _workers = _event.assigned_cultists;
	var _worker_count = array_length(_workers);
	var _previous_protection = array_create(_worker_count, false);
	for (var _protect_index = 0; _protect_index < _worker_count; ++_protect_index)
	{
		var _worker = _workers[_protect_index];
		if (!instance_exists(_worker))
		{
			continue;
		}
		_previous_protection[_protect_index] = _worker.debug_day_progress_hp_cost_ignored;
		_worker.debug_day_progress_hp_cost_ignored = true;
	}
	var _completed = false;
	try
	{
		// An already invoked card is also completed immediately by the cheat.
		if (day_event_execution_is_active(_event) || day_event_execution_start(_event))
		{
			_completed = day_event_execution_complete(_event_index);
		}
	}
	finally
	{
		for (var _restore_index = 0; _restore_index < _worker_count; ++_restore_index)
		{
			var _worker_to_restore = _workers[_restore_index];
			if (instance_exists(_worker_to_restore))
			{
				_worker_to_restore.debug_day_progress_hp_cost_ignored = _previous_protection[_restore_index];
			}
		}
	}

	if (_completed)
	{
		// The normal executor already stores history and logs; skip only the card's fade-out delay.
		array_delete(global.day_events, _event_index, 1);
	}
	else
	{
		// A failed invocation must not retain workers assigned only by the cheat.
		var _added_count = array_length(_added_cultists);
		for (var _release_index = 0; _release_index < _added_count; ++_release_index)
		{
			_event.cultist_unassign(_added_cultists[_release_index]);
		}
	}
	return _completed;
}
