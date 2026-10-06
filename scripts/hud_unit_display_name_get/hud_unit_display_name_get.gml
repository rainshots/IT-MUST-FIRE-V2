/// @description Shared unit information used by the battle HUD and world map.
function hud_unit_display_name_get(_unit_object)
{
	if (_unit_object == o_skeleton_bonelet)
	{
		return "Skeleton Bonelet";
	}

	if (_unit_object == o_skeleton_warrior)
	{
		return "Bone Warrior";
	}

	if (_unit_object == o_skeleton_archer)
	{
		return "Bone Archer";
	}

	if (_unit_object == o_skeleton_mage)
	{
		return "Bone Mage";
	}

	if (_unit_object == o_skeleton_healer)
	{
		return "Skeleton Healer";
	}

	if (_unit_object == o_skeleton)
	{
		return "Skeleton";
	}

	if (_unit_object == o_ripcage_cannon)
	{
		return "Ripcage Cannon";
	}

	if (_unit_object == o_bone_bannerman)
	{
		return "Bone Bannerman";
	}

	if (_unit_object == o_provocateur)
	{
		return "Provocateur";
	}

	if (_unit_object == o_mawling)
	{
		return "Mawling";
	}

	if (_unit_object == o_pitling)
	{
		return "Pitling";
	}

	if (_unit_object == o_succubus)
	{
		return "Succubus";
	}

	if (_unit_object == o_balgor)
	{
		return "Balgor";
	}

	if (_unit_object == o_demon_wizard)
	{
		return "Demon Wizard";
	}

	if (_unit_object == o_imp)
	{
		return "Imp";
	}

	if (_unit_object == o_brute)
	{
		return "Brute";
	}

	if (_unit_object == o_warlock)
	{
		return "Warlock";
	}

	if (_unit_object == o_archdemon)
	{
		return "Archdemon";
	}

	return object_get_name(_unit_object);
}
