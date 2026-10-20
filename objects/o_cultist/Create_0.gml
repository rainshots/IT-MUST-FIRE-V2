// Workers are civilians; their state is separate from event participants and combat squads.
var _names = ["Abel", "Mara", "Silas", "Vera", "Oren", "Nera", "Ezra", "Iris", "Rook", "Seth"];
cultist_name = _names[irandom(array_length(_names) - 1)];
worker_speed_multiplier = random_range(BALANCE_WORKER_SPEED_MIN, BALANCE_WORKER_SPEED_MAX);
max_hp = BALANCE_EVENT_CULTIST_MAX_HP;
hp = max_hp;
assigned_building = noone;
is_assigned_to_building = false;
is_being_dragged = false;
is_walking = false;
drag_drop_x = x;
drag_drop_y = y;
move_speed = BALANCE_EVENT_CULTIST_MOVE_SPEED;
y_sort_enabled = true;
depth = BALANCE_BUILDING_GRID_ACTOR_DEPTH - floor(y);
is_attackable = false;

// Use the historical cultist appearances, randomized for each worker.
var _sprites = [s_cultist_01, s_cultist_02, s_cultist_03, s_cultist_04];
sprite_index = _sprites[irandom(array_length(_sprites) - 1)];
image_xscale = BALANCE_EVENT_CULTIST_SPRITE_SCALE;
image_yscale = image_xscale;
image_speed = 0;
idle_wander_target_x = x;
idle_wander_target_y = y;
idle_wander_wait_timer = 0;
if (instance_exists(o_game_controller)) o_game_controller.worker_idle_wander_target_pick(id);
