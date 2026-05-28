// Initialize shared friendly combat state.
event_inherited();

// Pitling combat stats.
max_hp = BALANCE_PITLING_HP;
hp = max_hp;
damage = BALANCE_PITLING_DAMAGE;
reload_time = BALANCE_PITLING_RELOAD_TIME * room_speed;
attack_radius = BALANCE_PITLING_ATTACK_RADIUS;
move_speed = BALANCE_PITLING_MOVE_SPEED;

// Pitling health is drawn near the sprite pivot instead of above the head.
bar_offset_y = -2;

// Pitlings survive several completed nights.
summon_nights_remaining = BALANCE_PITLING_NIGHT_LIFE;
