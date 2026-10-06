/// @description Adds actual enemy HP loss to a squad's campaign total after damage mitigation.
function squad_damage_record(_squad, _target_faction, _applied_damage)
{
	if (_target_faction != UNIT_FACTION.ENEMY || _applied_damage <= 0 || !is_struct(_squad))
	{
		return;
	}
	if (!variable_struct_exists(_squad, "damage_dealt_total"))
	{
		_squad.damage_dealt_total = 0;
	}
	_squad.damage_dealt_total += _applied_damage;
}
