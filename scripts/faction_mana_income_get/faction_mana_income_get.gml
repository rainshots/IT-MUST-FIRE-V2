/// @description Gets base income plus active captured-building income, paid every five seconds.
function faction_mana_income_get(_faction)
{
	if (_faction < FACTION.ORDER || _faction > FACTION.WILDLINGS || faction_is_defeated(_faction)) return 0;
	var _income = global.faction_mana_income[_faction];
	with (o_neutral_building_parent)
	{
		if (faction == _faction && !is_recovering && hp > 0) _income += mana_income_bonus;
	}
	return _income;
}
