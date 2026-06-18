// Initialize shared unit state.
event_inherited();

// Skeleton combat stats.
max_hp = BALANCE_SKELETON_HP;
hp = max_hp;
damage = 0;
magic_damage = BALANCE_SKELETON_DAMAGE;
reload_time = BALANCE_SKELETON_RELOAD_TIME * room_speed;
attack_radius = BALANCE_SKELETON_ATTACK_RADIUS;
move_speed = 1.35;

// Skeleton health is drawn near the sprite pivot instead of above the head.
bar_offset_y = -2;

// Summoned skeletons survive long enough to regroup at the cannon during daytime.
summon_nights_remaining = BALANCE_SKELETON_NIGHT_LIFE;
