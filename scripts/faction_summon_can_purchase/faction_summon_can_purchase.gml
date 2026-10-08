/// @description Revalidates a faction purchase against its live base, Mana and squad cap; controller context.
function faction_summon_can_purchase(_faction, _choice_index)
{
	if (!faction_match_started || faction_match_finished || global.pause
		|| _faction < FACTION.ORDER || _faction > FACTION.WILDLINGS) return false;
	var _choices = faction_summon_options[_faction];
	if (_choice_index < 0 || _choice_index >= array_length(_choices)) return false;
	var _alive = false;
	for (var _index = 0; _index < array_length(faction_match_states); ++_index)
	{
		var _state = faction_match_states[_index];
		if (_state.faction == _faction)
		{
			_alive = !_state.defeated && instance_exists(_state.base) && _state.base.hp > 0;
			break;
		}
	}
	return _alive && instance_exists(o_cannon)
		&& faction_squad_count_get(_faction) < BALANCE_SQUAD_LIMIT
		&& global.faction_mana[_faction] >= _choices[_choice_index].cost;
}
