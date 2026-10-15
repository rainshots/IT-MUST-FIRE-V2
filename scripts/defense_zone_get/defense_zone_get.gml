/// @description Returns the Cannon-relative Defense Zone bounds.
function defense_zone_get()
{
	var _x = o_cannon.x + BALANCE_DEFENSE_ZONE_OFFSET_X;
	return {left: _x - BALANCE_DEFENSE_ZONE_WIDTH * 0.5, right: _x + BALANCE_DEFENSE_ZONE_WIDTH * 0.5,
		top: o_cannon.y - BALANCE_DEFENSE_ZONE_HEIGHT * 0.5, bottom: o_cannon.y + BALANCE_DEFENSE_ZONE_HEIGHT * 0.5};
}
