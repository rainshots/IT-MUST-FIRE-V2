/// @description Returns the ground color for a faction; Undead retain the original taint color.
function corruption_color_get(_faction)
{
	switch (_faction)
	{
		case FACTION.ORDER: return COLOR_CORRUPTION_ORDER;
		case FACTION.DEMONS: return COLOR_CORRUPTION_DEMONS;
		case FACTION.WILDLINGS: return COLOR_CORRUPTION_WILDLINGS;
	}
	return COLOR_CORRUPTION_MAX;
}
