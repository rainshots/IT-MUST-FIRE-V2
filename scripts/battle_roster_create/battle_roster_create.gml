/// @description Creates the three ready squads for a new battler campaign, without spawning units.
function battle_roster_create()
{
	var _first_skeletons = new squad_constructor(SQUAD_TYPE.UNDEAD, o_skeleton, BALANCE_BATTLE_STARTING_SKELETON_COUNT);
	var _second_skeletons = new squad_constructor(SQUAD_TYPE.UNDEAD, o_skeleton, BALANCE_BATTLE_STARTING_SKELETON_COUNT);
	var _mawlings = new squad_constructor(SQUAD_TYPE.DEMON, o_mawling, BALANCE_BATTLE_STARTING_MAWLING_COUNT);
	_first_skeletons.name = "Skeletons I";
	_second_skeletons.name = "Skeletons II";
	_mawlings.name = "Mawlings";
	return [_first_skeletons, _second_skeletons, _mawlings];
}
