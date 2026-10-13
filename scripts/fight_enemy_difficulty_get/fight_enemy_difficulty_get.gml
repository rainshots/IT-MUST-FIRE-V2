/// @description Gets the original night-wave difficulty cost for an enemy.
function fight_enemy_difficulty_get(_enemy_object)
{
	if (_enemy_object == o_enemy_peasant)
	{
		return BALANCE_ENEMY_PEASANT_DIFFICULTY;
	}
	else if (_enemy_object == o_enemy_archer)
	{
		return BALANCE_ENEMY_ARCHER_DIFFICULTY;
	}
	else if (_enemy_object == o_enemy_knight)
	{
		return BALANCE_ENEMY_KNIGHT_DIFFICULTY;
	}
	else if (_enemy_object == o_enemy_mage)
	{
		return BALANCE_ENEMY_MAGE_DIFFICULTY;
	}
	else if (_enemy_object == o_enemy_catapult)
	{
		return BALANCE_ENEMY_CATAPULT_DIFFICULTY;
	}

	return 1;
}
