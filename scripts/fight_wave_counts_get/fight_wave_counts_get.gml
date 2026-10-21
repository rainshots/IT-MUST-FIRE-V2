/// @description Returns counts in peasant, archer, knight, mage, catapult order for a one-based wave.
function fight_wave_counts_get(_wave)
{
	if (_wave <= 1) return [round(BALANCE_WAVE_START_PEASANTS * BALANCE_WAVE_STRENGTH_MULTIPLIER), 0, 0, 0, 0];
	if (_wave == 2) return [round(BALANCE_WAVE_START_PEASANTS * BALANCE_WAVE_STRENGTH_MULTIPLIER), round(BALANCE_WAVE_SECOND_ARCHERS * BALANCE_WAVE_STRENGTH_MULTIPLIER), 0, 0, 0];
	var _types = [o_enemy_peasant, o_enemy_archer, o_enemy_knight, o_enemy_mage, o_enemy_catapult];
	var _unlocks = [1, 2, BALANCE_WAVE_KNIGHT_UNLOCK, BALANCE_WAVE_MAGE_UNLOCK, BALANCE_WAVE_CATAPULT_UNLOCK];
	var _base_budget = BALANCE_WAVE_START_PEASANTS * fight_enemy_difficulty_get(o_enemy_peasant)
		+ BALANCE_WAVE_SECOND_ARCHERS * fight_enemy_difficulty_get(o_enemy_archer);
	var _budget = _base_budget * BALANCE_WAVE_STRENGTH_MULTIPLIER * power(BALANCE_WAVE_GROWTH, _wave - 2);
	var _special_types = 0;
	for (var _i = 1; _i < array_length(_types); ++_i) if (_wave >= _unlocks[_i]) _special_types++;
	var _counts = [0, 0, 0, 0, 0];
	var _remaining = _budget;
	for (var _i = 1; _i < array_length(_types); ++_i)
	{
		if (_wave < _unlocks[_i]) continue;
		var _cost = fight_enemy_difficulty_get(_types[_i]);
		_counts[_i] = max(1, floor(_budget * BALANCE_WAVE_SPECIAL_BUDGET_SHARE / _special_types / _cost));
		_remaining -= _counts[_i] * _cost;
	}
	// Peasants spend the remainder; whole-unit rounding stays within one peasant of the budget.
	_counts[0] = max(0, floor(_remaining / fight_enemy_difficulty_get(o_enemy_peasant)));
	return _counts;
}
