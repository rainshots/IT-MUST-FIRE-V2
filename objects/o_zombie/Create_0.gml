// Initialize shared friendly unit state.
event_inherited();

// Zombie is a slow tank with strong physical armor and weak magic resistance.
max_hp = BALANCE_ZOMBIE_HP;
hp = max_hp;
armor = BALANCE_ZOMBIE_ARMOR;
magic_resistance = BALANCE_ZOMBIE_MAGIC_RESISTANCE;
damage = BALANCE_ZOMBIE_DAMAGE;
magic_damage = 0;
reload_time = BALANCE_ZOMBIE_RELOAD_TIME * room_speed;
attack_radius = BALANCE_ZOMBIE_ATTACK_RADIUS;
move_speed = BALANCE_ZOMBIE_MOVE_SPEED;

// Draw health and status bars directly below the unit's feet.
bar_offset_y = -2;

// Use the requested sprite when it is imported into the project.
var _unit_sprite = asset_get_index("s_zombie_regular");

if (_unit_sprite != -1)
{
	sprite_index = _unit_sprite;
}
