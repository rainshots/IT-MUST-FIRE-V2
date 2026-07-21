// Initialize shared friendly unit state.
event_inherited();

// Skeleton Archer is a fragile ranged physical attacker.
max_hp = BALANCE_SKELETON_ARCHER_HP;
hp = max_hp;
armor = BALANCE_SKELETON_ARCHER_ARMOR;
magic_resistance = BALANCE_SKELETON_ARCHER_MAGIC_RESISTANCE;
damage = BALANCE_SKELETON_ARCHER_DAMAGE;
magic_damage = 0;
reload_time = BALANCE_SKELETON_ARCHER_RELOAD_TIME * room_speed;
attack_radius = BALANCE_SKELETON_ARCHER_ATTACK_RADIUS;
move_speed = BALANCE_SKELETON_ARCHER_MOVE_SPEED;

// Draw health and status bars directly below the unit's feet.
bar_offset_y = -2;

// Use the requested sprite when it is imported into the project.
var _unit_sprite = asset_get_index("s_skeleton_archer");

if (_unit_sprite != -1)
{
	sprite_index = _unit_sprite;
}

// Melee damage periodically makes the Skeleton Archer disengage from its attacker.
unit_damage_received = function(_source_instance, _source_faction, _applied_damage)
{
	ranged_unit_melee_flee_on_damage(_source_instance);
};
