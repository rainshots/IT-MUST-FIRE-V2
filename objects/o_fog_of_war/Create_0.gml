// Fog of war draws above the world and hides unexplored map cells.
draw_above_world_depth = -1000;
depth = draw_above_world_depth;

// Fog grid uses the same 100x100 cell size as ground corruption.
cell_size = BALANCE_GRID_CELL_SIZE;
grid_width = ceil(room_width / cell_size);
grid_height = ceil(room_height / cell_size);
fog_grid = ds_grid_create(grid_width, grid_height);
ds_grid_clear(fog_grid, 1);

// Fog alpha values: hidden, edge transition, and revealed.
hidden_alpha = 1;
edge_alpha = 0.5;
revealed_alpha = 0;
fog_color = c_black;

// Fully corrupted ground reveals fog nearby.
full_corruption_value = 1;
reveal_radius_in_cells = BALANCE_FOG_REVEAL_RADIUS_IN_CELLS;
neighbor_offset_min = -1;
neighbor_offset_max = 1;

// Fog is recalculated periodically because corruption does not need instant visual updates every frame.
update_interval = BALANCE_FOG_UPDATE_INTERVAL;
update_timer = update_interval;
