// Override these settings in each child Create event after event_inherited().
previous_levels = []; // Level object assets leading into this point.
next_levels = []; // Level object assets reachable after capturing this point.
battle_room = Battle_room; // Room loaded by the Info panel's ATTACK button.
level_title = "Unclaimed land";
level_description = "Defeat the defenders to claim this land.";
reward = ""; // Reserved for a future reward system; currently empty.

// Calculated by the map on entry and after each capture.
level_state = WORLD_MAP_LEVEL_STATE.FUTURE;
enemy_forces = []; // Editor-placed troops and buildings in battle_room.
image_speed = 0;
sprite_index = s_map_point_03;
