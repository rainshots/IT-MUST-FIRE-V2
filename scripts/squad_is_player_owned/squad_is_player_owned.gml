/// @description Only the selected faction's squads accept player orders and appear in the squad HUD.
function squad_is_player_owned(_squad)
{
	return is_struct(_squad) && variable_struct_exists(_squad, "faction")
		&& global.player_faction != FACTION.NONE && _squad.faction == global.player_faction;
}
