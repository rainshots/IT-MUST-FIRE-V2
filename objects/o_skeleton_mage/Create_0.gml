// Initialize shared friendly unit state.
event_inherited();

// Skeleton Mage is ranged, magic-resistant poorly, and armored against physical hits.
max_hp = BALANCE_SKELETON_MAGE_HP;
hp = max_hp;
armor = BALANCE_SKELETON_MAGE_ARMOR;
magic_resistance = BALANCE_SKELETON_MAGE_MAGIC_RESISTANCE;
damage = 0;
magic_damage = BALANCE_SKELETON_MAGE_MAGIC_DAMAGE;
reload_time = BALANCE_SKELETON_MAGE_RELOAD_TIME * room_speed;
attack_radius = BALANCE_SKELETON_MAGE_ATTACK_RADIUS;
move_speed = BALANCE_SKELETON_MAGE_MOVE_SPEED;

// Draw health and status bars directly below the unit's feet.
bar_offset_y = -2;

// Use the requested sprite when it is imported into the project.
var _unit_sprite = asset_get_index("s_skeleton_mage");

if (_unit_sprite != -1)
{
	sprite_index = _unit_sprite;
}

// Melee damage periodically makes the Skeleton Mage disengage from its attacker.
unit_damage_received = function(_source_instance, _source_faction, _applied_damage)
{
	ranged_unit_melee_flee_on_damage(_source_instance);
};
