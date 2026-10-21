event_inherited();
worker_max = 1;
worker_uses_speed_multiplier = false;
image_speed = 0;
image_xscale = min(1, 180 / max(sprite_get_width(sprite_index), sprite_get_height(sprite_index)));
image_yscale = image_xscale;
worker_work_update = function(_seconds) { building_production_update(_seconds); };
building_label = "Machine Furnace";
upgrade_object = noone;
production_kind = 2;
production_interval = BALANCE_MACHINE_FURNACE_SECONDS;
production_unit = o_ripcage_cannon;

grid_columns = BALANCE_MACHINE_FURNACE_SLOTS;
grid_rows = BALANCE_MACHINE_FURNACE_SLOTS;
placement_size = BALANCE_MACHINE_FURNACE_SLOTS * BALANCE_BUILDING_GRID_CELL_SIZE;
