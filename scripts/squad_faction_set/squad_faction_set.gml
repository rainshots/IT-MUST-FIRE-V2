/// @description Assigns ownership consistently to a squad and its members, cancelling previous commands.
function squad_faction_set(_squad, _faction)
{
	if (!is_struct(_squad)) return;
	_squad.faction = _faction;
	_squad.ai_target = noone;
	_squad.ai_target_retry_timer = 0;
	_squad.properties.is_selected = false;
	squad_order_clear(_squad);
	squad_march_end(_squad);
	var _count = array_length(_squad.units);
	for (var _index = 0; _index < _count; ++_index)
	{
		var _unit = _squad.units[_index];
		if (!instance_exists(_unit)) continue;
		_unit.faction = _faction;
		_unit.target_instance = noone;
		_unit.alert_target = noone;
		_unit.forced_attack_target = noone;
		_unit.target_search_update_timer = _unit.target_search_update_interval;
	}
}
