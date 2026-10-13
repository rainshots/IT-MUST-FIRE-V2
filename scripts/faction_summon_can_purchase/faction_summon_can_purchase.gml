/// @description Validates an immediate player purchase; called in controller context.
function faction_summon_can_purchase(_faction, _choice_index)
{
	if (fight_state != FIGHT_STATE.ACTIVE || global.pause || _faction != global.player_faction) return false;
	if (!instance_exists(o_cannon) || o_cannon.hp <= 0) return false;
	var _choices = faction_summon_options[_faction];
	if (_choice_index < 0 || _choice_index >= array_length(_choices)) return false;
	return squad_slot_is_available(SQUAD_TYPE.ARMY)
		&& global.faction_mana[_faction] >= _choices[_choice_index].cost;
}
