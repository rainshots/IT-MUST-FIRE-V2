/// @description Purchases a squad immediately beside the Cannon; called in controller context.
function faction_summon_purchase(_faction, _choice_index, _target_x = undefined, _target_y = undefined)
{
	if (!faction_summon_can_purchase(_faction, _choice_index)) return noone;
	var _choice = faction_summon_options[_faction][_choice_index];
	var _squad = squad_create(SQUAD_TYPE.ARMY, _choice.unit_object, _choice.count);
	if (!is_struct(_squad)) return noone;
	_squad.name = _choice.name;
	global.faction_mana[_faction] -= _choice.cost;
	return _squad;
}
