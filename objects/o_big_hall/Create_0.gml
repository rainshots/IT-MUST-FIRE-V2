// Passive housing adds capacity only while placed on the grid.
event_inherited();
building_label = "Big Hall";
building_accepts_workers = false;
worker_max = 0;
grid_columns = BALANCE_HALL_GRID_SLOTS;
grid_rows = BALANCE_HALL_GRID_SLOTS;
placement_size = BALANCE_HALL_GRID_SLOTS * BALANCE_BUILDING_GRID_CELL_SIZE;
unit_capacity_bonus = BALANCE_BIG_HALL_CAPACITY;
upgrade_object = noone;
image_speed = 0;
image_blend = COLOR_BIG_HALL;
