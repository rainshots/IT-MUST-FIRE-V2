// Initialize shared friendly combat state.
event_inherited();


// Pitling combat stats.
max_hp = BALANCE_PITLING_HP;
hp = max_hp;
armor = BALANCE_PITLING_ARMOR;
magic_resistance = BALANCE_PITLING_MAGIC_RESISTANCE;
damage = BALANCE_PITLING_DAMAGE;
magic_damage = 0;
reload_time = BALANCE_PITLING_RELOAD_TIME * room_speed;
attack_radius = BALANCE_PITLING_ATTACK_RADIUS;
move_speed = BALANCE_PITLING_MOVE_SPEED;

// Pitling health is drawn near the sprite pivot instead of above the head.
bar_offset_y = -2;
