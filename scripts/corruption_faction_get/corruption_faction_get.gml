/// @description Resolves a corruption source's faction, retaining Undead for legacy unowned taint sources.
function corruption_faction_get(_source, _fallback = FACTION.UNDEAD)
{
	if (instance_exists(_source) && variable_instance_exists(_source, "faction"))
	{
		var _faction = _source.faction;
		if (_faction >= FACTION.ORDER && _faction <= FACTION.WILDLINGS) return _faction;
	}
	return _fallback;
}
