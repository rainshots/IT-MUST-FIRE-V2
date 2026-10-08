/// @description Each AI faction selects a random roster entry and saves until it can afford that squad. Controller context.
function faction_summon_ai_update()
{
	if (global.pause || !faction_match_started || faction_match_finished) return;
	faction_summon_ai_timer -= global.gameplay_time_scale / max(1, room_speed);
	if (faction_summon_ai_timer > 0) return;
	faction_summon_ai_timer = BALANCE_SUMMON_AI_INTERVAL;
	for (var _faction = FACTION.ORDER; _faction <= FACTION.WILDLINGS; ++_faction)
	{
		if (_faction == global.player_faction || faction_squad_count_get(_faction) >= BALANCE_SQUAD_LIMIT) continue;
		if (faction_summon_ai_choices[_faction] < 0)
			faction_summon_ai_choices[_faction] = irandom(array_length(faction_summon_options[_faction]) - 1);
		var _choice = faction_summon_ai_choices[_faction];
		if (is_struct(faction_summon_purchase(_faction, _choice))) faction_summon_ai_choices[_faction] = -1;
	}
}
