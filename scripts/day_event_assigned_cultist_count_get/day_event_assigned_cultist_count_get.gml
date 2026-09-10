/// @description Counts occupied Rite slots without counting empty positions between Cultists.
function day_event_assigned_cultist_count_get(_event)
{
	if (!is_struct(_event) || !variable_struct_exists(_event, "assigned_cultists"))
	{
		return 0;
	}

	var _assigned_count = 0;
	var _slot_count = array_length(_event.assigned_cultists);

	// Slot indices are stable, so array length is not the number of assigned workers.
	for (var _slot_index = 0; _slot_index < _slot_count; ++_slot_index)
	{
		if (instance_exists(_event.assigned_cultists[_slot_index]))
		{
			_assigned_count++;
		}
	}

	return _assigned_count;
}
