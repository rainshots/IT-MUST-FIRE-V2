/// @description Returns the shared faction color for flags, orders and counters.
function conquest_owner_color_get(_owner)
{
	switch (_owner)
	{
		case CONQUEST_OWNER.PLAYER: return COLOR_CONQUEST_PLAYER;
		case CONQUEST_OWNER.ENEMY: return COLOR_CONQUEST_ENEMY;
	}
	return COLOR_CONQUEST_NEUTRAL;
}
