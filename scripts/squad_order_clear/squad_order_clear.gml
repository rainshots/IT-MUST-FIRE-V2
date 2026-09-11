/// @description Cancels a squad's direct order without changing its selection or position.
function squad_order_clear(_squad)
{
	if (!is_struct(_squad))
	{
		return;
	}

	_squad.properties.order_mode = SQUAD_ORDER.NONE;
	_squad.properties.march_speed_bonus_active = false;
	var _unit_count = array_length(_squad.units);

	// Return every existing combat member to ordinary AI.
	for (var _index = 0; _index < _unit_count; ++_index)
	{
		var _unit = _squad.units[_index];
		if (!instance_exists(_unit) || !variable_instance_exists(_unit, "squad_order_arrived"))
		{
			continue;
		}
		_unit.squad_order_arrived = false;
		_unit.squad_order_in_combat = false;
		_unit.target_search_update_timer = _unit.target_search_update_interval;
		_unit.navigation_path_state_clear();
	}
}
