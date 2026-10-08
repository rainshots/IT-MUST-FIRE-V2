/// @description Tests ownership independently of old friendly/enemy object groups. Unassigned objects are not combatants.
function faction_target_is_hostile(_faction, _target)
{
	return _faction != FACTION.NONE && instance_exists(_target)
		&& variable_instance_exists(_target, "faction")
		&& _target.faction != FACTION.NONE && _target.faction != _faction;
}
