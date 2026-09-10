/// @description Checks the fixed worker slots belonging to one Rite activation.
/// @param {Real} _activation_index Zero-based activation group, not an occupied-worker count.
function day_event_activation_staffing_is_ready(_event, _activation_index)
{
	var _first_slot_index = _activation_index * _event.cultist_cost;
	var _end_slot_index = _first_slot_index + _event.cultist_cost;

	if (_activation_index < 0
		|| _activation_index >= _event.activation_limit
		|| _end_slot_index > array_length(_event.assigned_cultists))
	{
		return false;
	}

	// Missing or unavailable workers cannot fund a group, even when later slots are occupied.
	for (var _slot_index = _first_slot_index; _slot_index < _end_slot_index; ++_slot_index)
	{
		var _cultist = _event.assigned_cultists[_slot_index];

		if (!instance_exists(_cultist)
			|| _cultist.hp <= 0
			|| _cultist.spirit <= 0
			|| (variable_instance_exists(_cultist, "is_unconscious") && _cultist.is_unconscious))
		{
			return false;
		}
	}

	return true;
}
