// Initialize shared enemy unit state.
event_inherited();

// Small enemy combat stats.
max_hp = BALANCE_ENEMY_SMALL_HP;
hp = max_hp;
damage = BALANCE_ENEMY_SMALL_DAMAGE;
reload_time = BALANCE_ENEMY_SMALL_RELOAD_TIME * room_speed;
attack_radius = 34;
move_speed = BALANCE_ENEMY_SMALL_MOVE_SPEED;
