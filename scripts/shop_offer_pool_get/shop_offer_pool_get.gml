/// @description Returns all currently purchasable Shop options.
function shop_offer_pool_get()
{
	return [
		{kind: SHOP_OFFER_KIND.BUILDING, object: o_worker_graveyard, icon: s_graveyardv3_b, name: "Graveyard", cost: BALANCE_SHOP_BUILDING_COST},
		{kind: SHOP_OFFER_KIND.BUILDING, object: o_goblin_pit, icon: s_goblins_pit, name: "Goblin Pit", cost: BALANCE_SHOP_BUILDING_COST},
		{kind: SHOP_OFFER_KIND.BUILDING, object: o_corruptor, icon: s_watchtower, name: "Corruptor", cost: BALANCE_SHOP_BUILDING_COST},
		{kind: SHOP_OFFER_KIND.BUILDING, object: o_spike_tower, icon: s_damage_tower_b, name: "Spike Tower", cost: BALANCE_SPIKE_TOWER_COST},
		{kind: SHOP_OFFER_KIND.BUILDING, object: o_pumpkin_patch, icon: -1, name: "Pumpkin Patch", cost: BALANCE_PUMPKIN_PATCH_COST},
		{kind: SHOP_OFFER_KIND.BUILDING, object: o_kitchen, icon: s_meat_bath, name: "Kitchen", cost: BALANCE_SHOP_BUILDING_COST},
		{kind: SHOP_OFFER_KIND.BUILDING, object: o_warehouse, icon: -1, name: "Warehouse", cost: BALANCE_WAREHOUSE_COST},
		{kind: SHOP_OFFER_KIND.BUILDING, object: o_sulfur_quarry, icon: s_quarry, name: "Sulfur Quarry", cost: BALANCE_SHOP_BUILDING_COST},
		{kind: SHOP_OFFER_KIND.BUILDING, object: o_summon_circle, icon: s_ritual_circle, name: "Summon Circle", cost: BALANCE_SHOP_BUILDING_COST},
		{kind: SHOP_OFFER_KIND.CULTIST, object: noone, icon: s_cultist_03, name: "+1 Cultist", cost: BALANCE_SHOP_CULTIST_COST},
		{kind: SHOP_OFFER_KIND.UNIT_CAP, object: noone, icon: s_skeleton, name: "+5 Unit Cap", cost: BALANCE_SHOP_UPGRADE_COST},
		{kind: SHOP_OFFER_KIND.BUILDING_ZONE, object: noone, icon: -1, name: "Expand Zone", cost: BALANCE_SHOP_UPGRADE_COST}
	];
}
