// Initialize shared unit state.
event_inherited();

// Skeleton combat stats.
max_hp = 5;
hp = max_hp;
damage = 1;
reload_time = 1 * room_speed;
attack_radius = 34;
move_speed = 1.35;

// Skeleton health is drawn near the sprite pivot instead of above the head.
bar_offset_y = -2;

// Summoned skeletons survive until the next morning.
summon_nights_remaining = 1;
