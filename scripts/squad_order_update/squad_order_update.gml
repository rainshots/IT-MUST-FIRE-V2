/// @description Refreshes shared march pace and retires an order after its last living deployed member arrives.
function squad_order_update(_squad)
{
	if (!squad_order_is_active(_squad) || global.pause)
	{
		return;
	}
	if (global.day_phase != DAY_PHASE.NIGHT)
	{
		squad_order_clear(_squad);
		return;
	}

	var _properties = _squad.properties;
	var _unit_count = array_length(_squad.units);
	var _has_pending_member = false;
	for (var _index = 0; _index < _unit_count; ++_index)
	{
		var _unit = _squad.units[_index];
		if (!instance_exists(_unit) || !_unit.visible || _unit.hp <= 0
			|| !variable_instance_exists(_unit, "squad_order_serial"))
		{
			continue;
		}
		if (_unit.squad_order_serial != _properties.order_serial || !_unit.squad_order_arrived)
		{
			_has_pending_member = true;
			break;
		}
	}
	if (!_has_pending_member)
	{
		squad_order_clear(_squad);
		return;
	}

	// Reuse the periodic shared formation checks instead of scanning allies from each member.
	squad_march_speed_bonus_update(_squad);
	squad_march_pace_update(_squad);
}
