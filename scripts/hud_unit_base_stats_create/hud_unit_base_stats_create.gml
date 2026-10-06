/// @description Shared unit information used by the battle HUD and world map.
function hud_unit_base_stats_create(
	_max_hp,
	_armor,
	_magic_resistance,
	_damage,
	_magic_damage,
	_reload_time,
	_attack_radius,
	_move_speed
)
{
	return {
		max_hp: _max_hp,
		armor: _armor,
		magic_resistance: _magic_resistance,
		damage: _damage,
		magic_damage: _magic_damage,
		reload_time: _reload_time * room_speed,
		attack_radius: _attack_radius,
		move_speed: _move_speed
	};
}
