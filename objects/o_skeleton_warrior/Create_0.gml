// Initialize shared friendly unit state.
event_inherited();

// Skeleton Warrior is a sturdier physical version of the basic skeleton.
max_hp = BALANCE_SKELETON_WARRIOR_HP;
hp = max_hp;
armor = BALANCE_SKELETON_WARRIOR_ARMOR;
magic_resistance = BALANCE_SKELETON_WARRIOR_MAGIC_RESISTANCE;
damage = BALANCE_SKELETON_WARRIOR_DAMAGE;
magic_damage = 0;
reload_time = BALANCE_SKELETON_WARRIOR_RELOAD_TIME * room_speed;
attack_radius = BALANCE_SKELETON_WARRIOR_ATTACK_RADIUS;
move_speed = BALANCE_SKELETON_WARRIOR_MOVE_SPEED;

// Use the requested sprite when it is imported into the project.
var _unit_sprite = asset_get_index("s_skeleton_warrior");

if (_unit_sprite != -1)
{
	sprite_index = _unit_sprite;
}
