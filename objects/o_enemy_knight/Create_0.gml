// Initialize shared enemy unit state.
event_inherited();

// Knight is a slow melee enemy with heavy armor.
max_hp = BALANCE_ENEMY_KNIGHT_HP;
hp = max_hp;
armor = BALANCE_ENEMY_KNIGHT_ARMOR;
magic_resistance = BALANCE_ENEMY_KNIGHT_MAGIC_RESISTANCE;
damage = BALANCE_ENEMY_KNIGHT_DAMAGE;
magic_damage = BALANCE_ENEMY_KNIGHT_MAGIC_DAMAGE;
reload_time = BALANCE_ENEMY_KNIGHT_RELOAD_TIME * room_speed;
attack_radius = BALANCE_ENEMY_KNIGHT_ATTACK_RADIUS;
move_speed = BALANCE_ENEMY_KNIGHT_MOVE_SPEED;
