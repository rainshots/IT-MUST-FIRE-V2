// Initialize shared enemy unit state.
event_inherited();

// Crusaders are durable melee enemies that can independently attack the cannon.
max_hp = BALANCE_CRUSADER_HP;
hp = max_hp;
armor = BALANCE_CRUSADER_ARMOR;
magic_resistance = BALANCE_CRUSADER_MAGIC_RESISTANCE;
damage = BALANCE_CRUSADER_DAMAGE;
magic_damage = BALANCE_CRUSADER_MAGIC_DAMAGE;
reload_time = BALANCE_CRUSADER_RELOAD_TIME * room_speed;
attack_radius = BALANCE_CRUSADER_ATTACK_RADIUS;
move_speed = BALANCE_CRUSADER_MOVE_SPEED;
target_detection_radius = BALANCE_CRUSADER_DANGER_SEARCH_RADIUS;
vision_radius = BALANCE_CRUSADER_DANGER_SEARCH_RADIUS;
