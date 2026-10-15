event_inherited();
is_defense_building = true;
placement_size = BALANCE_DEFENSE_BUILDING_SIZE;
worker_max = 1;
worker_uses_speed_multiplier = false;
image_speed = 0;
production_interval = BALANCE_DEFENSE_TOWER_SECONDS;
worker_work_update = function(_seconds) { defense_work_update(_seconds); };
building_label = "Pumpkin Patch";
production_interval = BALANCE_PUMPKIN_WORK_SECONDS;
// Local positions keep planted mines with the patch during relocation.
mines = [];
var _limit = placement_size * 0.5 - BALANCE_PUMPKIN_MINE_INSET;
for (var _i = 0; _i < BALANCE_PUMPKIN_START_MINES; ++_i)
{
	array_push(mines, {x: random_range(-_limit, _limit), y: random_range(-_limit, _limit)});
}
