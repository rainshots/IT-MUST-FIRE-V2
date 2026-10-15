/// @description Commits placement and charges Mana only after success.
function shop_place(_x,_y)
{
	if(!instance_exists(shop_preview) || global.faction_mana[global.player_faction]<shop_cost) return false;
	if(!building_commit(shop_preview,_x,_y)) return false;
	global.faction_mana[global.player_faction]-=shop_cost;
	shop_offer_replace(shop_purchase_index);
	shop_purchase_index = -1;
	shop_preview=noone;shop_cost=0;global.pause=shop_previous_pause;
	return true;
}
