event_inherited();
is_defense_building = true;
placement_size = BALANCE_DEFENSE_BUILDING_SIZE;
worker_max = 1;
worker_uses_speed_multiplier = false;
image_speed = 0;
production_interval = BALANCE_DEFENSE_TOWER_SECONDS;
worker_work_update = function(_seconds) { defense_work_update(_seconds); };
building_label = "Spike Tower";
upgrade_object = o_bomb_tower;

// Keep selection bounds proportional to the displayed tower.
image_xscale = placement_size / max(sprite_get_width(sprite_index), sprite_get_height(sprite_index));
image_yscale = image_xscale;
