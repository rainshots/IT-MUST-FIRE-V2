/// @description Records permanent faction defeats and resolves the last surviving faction; called by o_game_controller.
function faction_match_update()
{
	if (!faction_match_started || faction_match_finished || global.pause)
	{
		return;
	}

	var _remaining_count = 0;
	var _survivor = noone;
	var _faction_count = array_length(faction_match_states);
	for (var _index = 0; _index < _faction_count; ++_index)
	{
		var _state = faction_match_states[_index];
		if (!_state.defeated)
		{
			_state.defeated = !instance_exists(_state.base) || _state.base.hp <= 0;
		}
		if (_state.defeated)
		{
			if (!_state.defeat_cleanup_done)
			{
				_state.defeat_cleanup_done = true;
				faction_defeat_cleanup(_state.faction);
			}
			if (_state.faction == global.player_faction) player_faction_defeated = true;
			continue;
		}
		_remaining_count++;
		_survivor = _state;
	}

	// Resolve all bases together so simultaneous destruction cannot choose a dead winner.
	if (_remaining_count <= 1)
	{
		faction_match_finished = true;
		faction_match_winner = _remaining_count == 1 ? _survivor.faction : FACTION.NONE;
		faction_match_winner_name = _remaining_count == 1 ? _survivor.name : "";
		global.pause = true;
		global.focus_window = FOCUS_WINDOW.GAME_COMPLETION;
		squad_control_selection_clear();
		global.dragged_squad = noone;
	}
}
