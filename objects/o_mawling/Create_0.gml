// Initialize shared friendly unit state.
event_inherited();

// Mawling is a melee demon worth roughly two basic skeletons.
max_hp = BALANCE_MAWLING_HP;
hp = max_hp;
armor = BALANCE_MAWLING_ARMOR;
magic_resistance = BALANCE_MAWLING_MAGIC_RESISTANCE;
damage = BALANCE_MAWLING_DAMAGE;
magic_damage = 0;
reload_time = BALANCE_MAWLING_RELOAD_TIME * room_speed;
attack_radius = BALANCE_MAWLING_ATTACK_RADIUS;
move_speed = BALANCE_MAWLING_MOVE_SPEED;

// The sprite origin is at the feet.
bar_offset_y = -2;
