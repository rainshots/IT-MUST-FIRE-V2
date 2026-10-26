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
// Initial mines are planted once after actual placement, never in the Shop preview.
starting_mines_planted = false;
