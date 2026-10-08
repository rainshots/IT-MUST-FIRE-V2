/// @description Counts living squads and reserved hero respawns for one faction.
function faction_squad_count_get(_faction)
{
	var _count = 0;
	for (var _index = 0; _index < array_length(global.squads); ++_index)
	{
		var _squad = global.squads[_index];
		if (_squad.faction == _faction && (squad_living_unit_count_get(_squad) > 0
			|| (_squad.is_hero && _squad.hero_respawn_enabled))) _count++;
	}
	return _count;
}
