// Initialize shared enemy unit state.
event_inherited();

// Mage is a ranged magic enemy that checks magic resistance instead of armor.
max_hp = BALANCE_ENEMY_MAGE_HP;
hp = max_hp;
armor = BALANCE_ENEMY_MAGE_ARMOR;
magic_resistance = BALANCE_ENEMY_MAGE_MAGIC_RESISTANCE;
damage = BALANCE_ENEMY_MAGE_DAMAGE;
magic_damage = BALANCE_ENEMY_MAGE_MAGIC_DAMAGE;
reload_time = BALANCE_ENEMY_MAGE_RELOAD_TIME * room_speed;
attack_radius = BALANCE_ENEMY_MAGE_ATTACK_RADIUS;
move_speed = BALANCE_ENEMY_MAGE_MOVE_SPEED;

// Melee damage periodically makes the Mage disengage from its attacker.
unit_damage_received = function(_source_instance, _source_faction, _applied_damage)
{
	ranged_unit_melee_flee_on_damage(_source_instance);
};
