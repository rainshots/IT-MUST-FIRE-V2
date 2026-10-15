/// @description Rerolls all offers for 10 Mana without pausing or altering placement state.
function shop_refresh()
{
	if(fight_state!=FIGHT_STATE.ACTIVE || instance_exists(shop_preview)
		|| global.faction_mana[global.player_faction]<BALANCE_SHOP_REFRESH_COST) return false;
	global.faction_mana[global.player_faction]-=BALANCE_SHOP_REFRESH_COST;
	shop_begin();
	return true;
}
