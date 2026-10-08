/// @description Reports permanent defeat for playable factions; neutral buildings remain active.
function faction_is_defeated(_faction)
{
	if (_faction < FACTION.ORDER || _faction > FACTION.WILDLINGS) return false;
	if (!instance_exists(o_game_controller)) return false;
	var _controller = instance_find(o_game_controller, 0);
	if (!_controller.faction_match_started) return false;
	for (var _i = 0; _i < array_length(_controller.faction_match_states); ++_i)
	{
		var _state = _controller.faction_match_states[_i];
		if (_state.faction == _faction) return _state.defeated || !instance_exists(_state.base) || _state.base.hp <= 0;
	}
	return false;
}
