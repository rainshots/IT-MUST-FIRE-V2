// Initialize shared enemy unit state.
event_inherited();

// Peasant is a weak melee enemy without armor bonuses.
max_hp = BALANCE_ENEMY_PEASANT_HP;
hp = max_hp;
armor = BALANCE_ENEMY_PEASANT_ARMOR;
magic_resistance = BALANCE_ENEMY_PEASANT_MAGIC_RESISTANCE;
damage = BALANCE_ENEMY_PEASANT_DAMAGE;
magic_damage = BALANCE_ENEMY_PEASANT_MAGIC_DAMAGE;
reload_time = BALANCE_ENEMY_PEASANT_RELOAD_TIME * room_speed;
attack_radius = BALANCE_ENEMY_PEASANT_ATTACK_RADIUS;
move_speed = BALANCE_ENEMY_PEASANT_MOVE_SPEED;
