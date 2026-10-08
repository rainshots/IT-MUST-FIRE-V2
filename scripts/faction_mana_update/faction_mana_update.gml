/// @description Pays independent faction incomes every five simulation seconds; pauses with gameplay.
function faction_mana_update()
{
	if (global.pause || !faction_match_started || faction_match_finished) return;
	faction_mana_timer += global.gameplay_time_scale / max(1, room_speed);
	var _ticks = floor((faction_mana_timer + 0.000001) / BALANCE_MANA_INCOME_SECONDS);
	if (_ticks <= 0) return;
	faction_mana_timer = max(0, faction_mana_timer - _ticks * BALANCE_MANA_INCOME_SECONDS);
	for (var _faction = FACTION.ORDER; _faction <= FACTION.WILDLINGS; ++_faction)
	{
		global.faction_mana[_faction] += faction_mana_income_get(_faction) * _ticks;
	}
}
