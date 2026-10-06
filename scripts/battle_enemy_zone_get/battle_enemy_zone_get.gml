/// @description Classifies a starting X coordinate into the rightmost three enemy zones, front to rear.
function battle_enemy_zone_get(_start_x, _room_width)
{
	// The rear defense zone is wider than either of the two attacking zones.
	var _defense_start_x = _room_width - BALANCE_BATTLE_DEFENSE_ZONE_WIDTH;
	var _second_attack_start_x = _defense_start_x - BALANCE_BATTLE_ATTACK_ZONE_WIDTH;
	if (_start_x >= _defense_start_x)
	{
		return BATTLE_ZONE.DEFENSE;
	}
	if (_start_x >= _second_attack_start_x)
	{
		return BATTLE_ZONE.SECOND_ATTACK;
	}

	// Enemies placed farther forward still join the first attack.
	return BATTLE_ZONE.FIRST_ATTACK;
}
