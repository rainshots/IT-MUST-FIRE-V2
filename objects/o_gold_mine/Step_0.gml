// Transform into a cursed mine when the ground under it is infected.
if (global.pause)
{
	exit;
}

// V13 keeps legacy economy building conditions disabled for now.
if (variable_global_exists("legacy_building_logic_enabled") && !global.legacy_building_logic_enabled)
{
	exit;
}

if (is_on_corrupted_ground())
{
	transform_into(o_gold_mine_cursed);
}
