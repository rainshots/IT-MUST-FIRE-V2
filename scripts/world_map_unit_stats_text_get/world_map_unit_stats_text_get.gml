/// @description Formats the existing unit balance data for reserve members without spawning preview units.
function world_map_unit_stats_text_get(_unit_object)
{
	var _stats = hud_unit_base_stats_get(_unit_object);
	if (!is_struct(_stats)) return "";
	var _text = "Base stats"
		+ "\nHP: " + string_format(_stats.max_hp, 0, 1)
		+ "\nDamage: " + string_format(_stats.damage, 0, 1);
	if (_stats.magic_damage > 0) _text += "\nMagic damage: " + string_format(_stats.magic_damage, 0, 1);
	_text += "\nAttack speed: " + string_format(room_speed / max(1, _stats.reload_time), 0, 2)
		+ "\nAttack radius: " + string_format(_stats.attack_radius, 0, 0)
		+ "\nMove speed: " + string_format(_stats.move_speed, 0, 2)
		+ "\nArmor: " + string_format(_stats.armor - 100, 0, 1) + "%"
		+ "\nMagic resistance: " + string_format(_stats.magic_resistance - 100, 0, 1) + "%";
	return _text;
}
