// Inherit the parent event
event_inherited();
faction = FACTION.DEMONS;
// Succubus is a very fast melee hunter of ranged enemies.
max_hp = BALANCE_ENEMY_HERO_HP;
hp = max_hp;
armor = BALANCE_SUCCUBUS_ARMOR;
magic_resistance = BALANCE_SUCCUBUS_MAGIC_RESISTANCE;
damage = BALANCE_ENEMY_HERO_DAMAGE;
magic_damage = 0;
reload_time = BALANCE_SUCCUBUS_RELOAD_TIME * room_speed;
attack_radius = BALANCE_SUCCUBUS_ATTACK_RADIUS;
move_speed = BALANCE_SUCCUBUS_MOVE_SPEED;

// Draw health and status bars directly below the unit's feet.
bar_offset_y = -2;
