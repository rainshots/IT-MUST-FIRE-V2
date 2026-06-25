// Initialize shared friendly state.
event_inherited();

// Goblins are worker summons and do not fight.
sprite_index = s_goblin;
max_hp = BALANCE_GOBLIN_HP;
hp = max_hp;
ignored_by_enemies = true;
damage = 0;
magic_damage = 0;
reload_time = room_speed;
attack_radius = 0;
move_speed = BALANCE_GOBLIN_MOVE_SPEED;
unit_can_attack_cannon = false;
target_detection_radius = 0;
vision_radius = 0;

// Spawned goblins return to their own pit at night when it still exists.
owner_goblins_pit = noone;
home_offset_x = 0;
home_offset_y = 0;

// Goblin health and lifetime markers sit near the sprite pivot.
bar_offset_y = -2;
stamina_bar_gap = 2;
stamina_bar_height = 3;
summon_nights_remaining = irandom_range(BALANCE_GOBLIN_DAY_LIFE_MIN, BALANCE_GOBLIN_DAY_LIFE_MAX);
summon_life_label = "Days left";

// Worker buildings read this fixed multiplier.
worker_speed_multiplier = BALANCE_GOBLIN_WORK_SPEED_MULTIPLIER;

// Goblins spend stamina while working and recover every morning.
stamina_max = BALANCE_GOBLIN_STAMINA_MAX;
stamina_amount = BALANCE_GOBLIN_STAMINA_MAX;
