// Initialize shared friendly combat state without Imp passive or active hooks.
event_inherited();

// Clone stats are overwritten by the original Imp right after creation.
sprite_index = s_imp;
image_xscale = 1;
image_yscale = 1;
image_alpha = 0.72;
image_speed = 0;
max_hp = 1;
hp = max_hp;
damage = 1;
magic_damage = 0;
armor = 100;
crit_chance = 0;
reload_time = room_speed;
attack_radius = BALANCE_IMP_ATTACK_RADIUS;
move_speed = BALANCE_IMP_MOVE_SPEED;
bar_offset_y = 28;
life_timer = BALANCE_IMP_BLOODY_CLONE_LIFE_TIME * room_speed;
clone_fade_start_share = 0.35;
