// Inherit the parent event
event_inherited();
faction = FACTION.UNDEAD;
// Ripcage Cannon is a slow, durable physical artillery unit.
max_hp = BALANCE_ENEMY_HERO_HP;
hp = max_hp;
armor = BALANCE_SKELETON_MAGE_ARMOR;
magic_resistance = BALANCE_SKELETON_MAGE_MAGIC_RESISTANCE;
damage = 0;
magic_damage = BALANCE_ENEMY_HERO_MAGIC_DAMAGE;
reload_time = BALANCE_SKELETON_MAGE_RELOAD_TIME * room_speed;
attack_radius = BALANCE_SKELETON_MAGE_ATTACK_RADIUS;
move_speed = BALANCE_SKELETON_MAGE_MOVE_SPEED;