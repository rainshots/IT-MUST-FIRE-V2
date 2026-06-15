// Initialize shared enemy unit state.
event_inherited();

// Archer is a ranged physical enemy.
max_hp = BALANCE_ENEMY_ARCHER_HP;
hp = max_hp;
armor = BALANCE_ENEMY_ARCHER_ARMOR;
magic_resistance = BALANCE_ENEMY_ARCHER_MAGIC_RESISTANCE;
damage = BALANCE_ENEMY_ARCHER_DAMAGE;
magic_damage = BALANCE_ENEMY_ARCHER_MAGIC_DAMAGE;
reload_time = BALANCE_ENEMY_ARCHER_RELOAD_TIME * room_speed;
attack_radius = BALANCE_ENEMY_ARCHER_ATTACK_RADIUS;
cannon_attack_radius = BALANCE_ENEMY_ARCHER_CANNON_ATTACK_RADIUS;
move_speed = BALANCE_ENEMY_ARCHER_MOVE_SPEED;
