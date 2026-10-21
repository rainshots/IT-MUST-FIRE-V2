/// @description Rerolls unique offers at the current escalating cost without pausing or altering placement state.
function shop_refresh()
{
	if(fight_state!=FIGHT_STATE.ACTIVE || instance_exists(shop_preview)
		|| global.faction_mana[global.player_faction]<shop_refresh_cost) return false;
	global.faction_mana[global.player_faction]-=shop_refresh_cost;
	shop_begin();
	shop_refresh_cost *= BALANCE_SHOP_REFRESH_COST_MULTIPLIER;
	return true;
}
