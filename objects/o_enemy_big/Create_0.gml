// Initialize shared enemy unit state.
event_inherited();

// Big enemy combat stats.
max_hp = BALANCE_ENEMY_BIG_HP;
hp = max_hp;
damage = BALANCE_ENEMY_BIG_DAMAGE;
reload_time = BALANCE_ENEMY_BIG_RELOAD_TIME * room_speed;
attack_radius = 38;
move_speed = BALANCE_ENEMY_BIG_MOVE_SPEED;
