/// @description Returns all currently purchasable Shop options.
function shop_offer_pool_get()
{
	return [
		{kind: SHOP_OFFER_KIND.BUILDING, object: o_demolition_bomb, icon: s_taint_spreader, name: "Demolition Bomb", description: "Occupies 1x1 slot. After 60 seconds of Cultist work, destroys itself and all trash touching its eight neighboring tiles. Workers survive.\nNot upgradeable.", cost: BALANCE_DEMOLITION_BOMB_COST},
		{kind: SHOP_OFFER_KIND.BUILDING, object: o_unholy_well, icon: s_souls_well, name: "Unholy Well", description: "Occupies 3x3 slots. A working Cultist generates 1 Mana every 10 seconds.\nUpgrade: merge two Unholy Wells into a purple Witch Well, generating 1 Mana every 5 seconds.", cost: BALANCE_UNHOLY_WELL_COST},
		{kind: SHOP_OFFER_KIND.BUILDING, object: o_machine_furnace, icon: s_workshop, name: "Machine Furnace", description: "Occupies 3x3 slots. A working Cultist produces a Ripcage Cannon every 40 seconds. Each cannon uses 2 unit-cap slots.\nNot upgradeable.", cost: BALANCE_MACHINE_FURNACE_COST},
		{kind: SHOP_OFFER_KIND.BUILDING, object: o_worker_graveyard, icon: s_graveyardv3_b, name: "Graveyard", description: "A working Cultist summons Skeleton Archers.\nUpgrade: merge two Graveyards into a Super Graveyard, which summons Skeleton Mages.", cost: BALANCE_SHOP_BUILDING_COST},
		{kind: SHOP_OFFER_KIND.BUILDING, object: o_goblin_pit, icon: s_goblins_pit, name: "Goblin Pit", description: "A working Cultist summons Goblins that run into enemies and explode.\nNot upgradeable.", cost: BALANCE_SHOP_BUILDING_COST},
		{kind: SHOP_OFFER_KIND.BUILDING, object: o_spike_tower, icon: s_damage_tower_b, name: "Spike Tower", description: "Fires at enemies while a Cultist works here.\nUpgrade: merge two Spike Towers into a Bomb Tower with explosive area damage.", cost: BALANCE_SPIKE_TOWER_COST},
		{kind: SHOP_OFFER_KIND.BUILDING, object: o_pumpkin_patch, icon: -1, name: "Pumpkin Patch", description: "Starts with 2 mines. A working Cultist grows more, up to 6 mines.\nNot upgradeable.", cost: BALANCE_PUMPKIN_PATCH_COST},
		{kind: SHOP_OFFER_KIND.BUILDING, object: o_kitchen, icon: s_meat_bath, name: "Kitchen", description: "A working Cultist heals all idling player units.\nUpgrade: merge two Kitchens into a Feast Table for 50% more healing.", cost: BALANCE_SHOP_BUILDING_COST},
		{kind: SHOP_OFFER_KIND.BUILDING, object: o_summon_circle, icon: s_ritual_circle, name: "Summon Circle", description: "A working Cultist summons Mawlings.\nUpgrade: merge two Summon Circles into an Unholy Shrine, which summons Balgors.", cost: BALANCE_SHOP_BUILDING_COST},
		{kind: SHOP_OFFER_KIND.CULTIST, object: noone, icon: s_cultist_03, name: "+1 Cultist", description: "Adds one Cultist to assign to buildings or clearing trash.", cost: BALANCE_SHOP_CULTIST_COST},
		{kind: SHOP_OFFER_KIND.BUILDING, object: o_dead_hall, icon: s_pitlings_house, name: "Dead Hall", description: "Occupies 3x3 slots. Adds +3 unit capacity while placed on the Grid. No worker required.\nUpgrade: merge two Dead Halls into a Big Hall that adds +5 capacity.", cost: BALANCE_DEAD_HALL_COST}
	];
}
