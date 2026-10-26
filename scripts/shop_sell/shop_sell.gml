/// @description Sells a relocated purchased building for half its cumulative cost; controller context.
function shop_sell()
{
	if (!instance_exists(shop_preview) || shop_preview.placement_preview
		|| !shop_preview.is_being_dragged || shop_preview.purchase_value <= 0) return false;
	global.faction_mana[global.player_faction] += shop_preview.purchase_value * BALANCE_BUILDING_SELL_SHARE;
	building_workers_release(shop_preview);
	instance_destroy(shop_preview);
	shop_preview = noone;
	shop_cost = 0;
	shop_purchase_index = -1;
	shop_wait_release = false;
	global.pause = shop_previous_pause;
	global.sound_play_random(global.construction_sounds);
	return true;
}
