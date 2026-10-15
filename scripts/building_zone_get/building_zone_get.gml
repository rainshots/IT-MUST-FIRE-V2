/// @description Returns the Cannon-relative construction zone in world coordinates.
function building_zone_get()
{
	var _x = o_cannon.x + BALANCE_BUILDING_ZONE_OFFSET_X;
	var _expansions = instance_exists(o_game_controller) ? o_game_controller.building_zone_expansions : 0;
	return {left: _x - BALANCE_BUILDING_ZONE_WIDTH * 0.5 - _expansions * BALANCE_SHOP_ZONE_LEFT_INCREASE, right: _x + BALANCE_BUILDING_ZONE_WIDTH * 0.5,
		top: o_cannon.y - BALANCE_BUILDING_ZONE_HEIGHT * 0.5 - _expansions * BALANCE_SHOP_ZONE_VERTICAL_INCREASE, bottom: o_cannon.y + BALANCE_BUILDING_ZONE_HEIGHT * 0.5 + _expansions * BALANCE_SHOP_ZONE_VERTICAL_INCREASE};
}
