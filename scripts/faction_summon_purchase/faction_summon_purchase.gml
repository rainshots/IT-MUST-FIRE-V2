/// @description Spawns one paid squad at its base's forward spawn point; player purchases receive attack-move orders. Controller context.
function faction_summon_purchase(_faction, _choice_index, _target_x = undefined, _target_y = undefined)
{
	if (!faction_summon_can_purchase(_faction, _choice_index)) return noone;
	var _is_player = _faction == global.player_faction;
	if (_is_player && (is_undefined(_target_x) || is_undefined(_target_y)
		|| _target_x < 0 || _target_y < 0 || _target_x >= room_width || _target_y >= room_height)) return noone;
	var _choice = faction_summon_options[_faction][_choice_index];
	var _squad = squad_create(SQUAD_TYPE.ARMY, _choice.unit_object, _choice.count, noone, noone, _faction);
	if (!is_struct(_squad)) return noone;
	_squad.name = _choice.name;
	global.faction_mana[_faction] -= _choice.cost;
	if (_is_player) squad_order_issue(_squad, _target_x, _target_y, SQUAD_ORDER.MOVE_AND_ATTACK);
	else squad_ai_update(_squad);
	return _squad;
}
