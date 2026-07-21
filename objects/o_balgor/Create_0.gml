// Initialize shared friendly unit state.
event_inherited();

// Balgor is a slow heavy demon whose melee hit damages enemies around its target.
max_hp = BALANCE_BALGOR_HP;
hp = max_hp;
armor = BALANCE_BALGOR_ARMOR;
magic_resistance = BALANCE_BALGOR_MAGIC_RESISTANCE;
damage = BALANCE_BALGOR_DAMAGE;
magic_damage = 0;
reload_time = BALANCE_BALGOR_RELOAD_TIME * room_speed;
attack_radius = BALANCE_BALGOR_ATTACK_RADIUS;
aoe_radius = BALANCE_BALGOR_AOE_RADIUS;
attack_target_count = BALANCE_BALGOR_TARGET_COUNT;
move_speed = BALANCE_BALGOR_MOVE_SPEED;

// The sprite origin is at the feet.
bar_offset_y = -2;
