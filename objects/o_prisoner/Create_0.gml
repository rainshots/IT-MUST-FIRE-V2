event_inherited();

// Prisoners are draggable captives, not combat participants.
max_hp = BALANCE_PRISONER_HP;
hp = max_hp;
damage = 0;
magic_damage = 0;
reload_time = room_speed;
move_speed = BALANCE_PRISONER_MOVE_SPEED;
unit_faction = UNIT_FACTION.FRIENDLY;
ignored_by_enemies = true;
unit_can_attack_cannon = false;
target_detection_radius = 0;
attack_radius = 0;
bar_width = 34;
bar_height = 4;
bar_offset_y = 42;

// Assignment state keeps prisoners tied to their prison cell unless consumed by a building.
home_prison_cell = noone;
assigned_prisoner_building = noone;
prisoner_locked = false;
is_being_dragged = false;
drag_drop_x = x;
drag_drop_y = y;
idle_wander_target_x = x;
idle_wander_target_y = y;
idle_wander_wait_timer = irandom(room_speed);
idle_wander_arrive_distance = 6;
