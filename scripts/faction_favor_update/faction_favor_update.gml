/// @description Eliminates every surviving faction tied for lowest cumulative Favor every five simulation minutes; controller context.
function faction_favor_update()
{
	if (global.pause || !faction_match_started || faction_match_finished) return;
	faction_favor_seconds_remaining = max(0, faction_favor_seconds_remaining - global.gameplay_time_scale / max(1, room_speed));
	if (faction_favor_seconds_remaining > 0.000001) return;
	var _lowest = infinity;
	var _losers = [];
	for (var _index = 0; _index < array_length(faction_match_states); ++_index)
	{
		var _state = faction_match_states[_index];
		if (_state.defeated || !instance_exists(_state.base) || _state.base.hp <= 0) continue;
		var _favor = global.faction_favor[_state.faction];
		if (_favor < _lowest)
		{
			_lowest = _favor;
			_losers = [];
		}
		if (_favor == _lowest) array_push(_losers, _state.base);
	}
	// Mark every tied base before resolving defeat, so ties cannot choose an arbitrary winner.
	for (var _index = 0; _index < array_length(_losers); ++_index)
	{
		var _base = _losers[_index];
		_base.hp = 0;
		_base.player_building_destroyed_visual_set(true);
		_base.building_workers_release();
	}
	faction_favor_seconds_remaining = BALANCE_FAVOR_ROUND_SECONDS;
	faction_match_update();
}
