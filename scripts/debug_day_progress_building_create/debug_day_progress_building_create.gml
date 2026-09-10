/// @description Builds a random available settlement building in a random unreserved slot.
function debug_day_progress_building_create(_controller)
{
	if (!instance_exists(_controller) || !day_event_building_construction_can_start())
	{
		return "skipped (daily limit)";
	}

	// Pending player orders reserve both their slot and their building type.
	var _slots = [];
	var _slot_count = instance_number(o_building_slot);
	for (var _slot_index = 0; _slot_index < _slot_count; ++_slot_index)
	{
		var _slot = instance_find(o_building_slot, _slot_index);
		if (instance_exists(_slot)
			&& (!variable_instance_exists(_slot, "construction_event_pending")
				|| !_slot.construction_event_pending))
		{
			array_push(_slots, _slot);
		}
	}

	var _choices = [];
	var _choice_count = array_length(_controller.building_choices);
	for (var _choice_index = 0; _choice_index < _choice_count; ++_choice_index)
	{
		var _choice = _controller.building_choices[_choice_index];
		if (!BALANCE_BUILDING_DUPLICATE_LIMIT_ENABLED
			|| day_event_building_construction_type_count_get(_choice.building_object) < BALANCE_BUILDING_DEFAULT_LIMIT)
		{
			array_push(_choices, _choice);
		}
	}

	if (array_length(_slots) <= 0 || array_length(_choices) <= 0)
	{
		return "skipped (no available slot or building)";
	}
	var _selected_slot = _slots[irandom(array_length(_slots) - 1)];
	var _selected_choice = _choices[irandom(array_length(_choices) - 1)];
	return debug_day_progress_construction_execute(_selected_slot, _selected_choice)
		? _selected_choice.building_name
		: "skipped (construction failed)";
}
