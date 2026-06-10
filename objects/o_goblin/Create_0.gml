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

// Goblin health and lifetime markers sit near the sprite pivot.
bar_offset_y = -2;
summon_nights_remaining = BALANCE_GOBLIN_DAY_LIFE;
summon_life_label = "Days left";

// Worker buildings read this fixed multiplier.
worker_speed_multiplier = BALANCE_GOBLIN_WORK_SPEED_MULTIPLIER;
