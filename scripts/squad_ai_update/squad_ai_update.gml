/// @description Keeps one random hostile building objective per non-player squad; retries when none exist.
function squad_ai_update(_squad)
{
	if (global.pause || !is_struct(_squad) || squad_is_player_owned(_squad)
		|| _squad.faction == FACTION.NONE || squad_living_unit_count_get(_squad) <= 0) return;
	if (faction_building_is_targetable(_squad.faction, _squad.ai_target)) return;
	var _lost_target = _squad.ai_target != noone;
	_squad.ai_target = noone;
	_squad.ai_target_retry_timer -= global.gameplay_time_scale / max(1, room_speed);
	if (!_lost_target && _squad.ai_target_retry_timer > 0) return;
	_squad.ai_target_retry_timer = BALANCE_SQUAD_AI_RETRY_SECONDS;
	var _candidates = [];
	var _parents = [o_v13buildings_parent, o_map_objects_parent];
	for (var _group = 0; _group < array_length(_parents); ++_group)
	{
		var _count = instance_number(_parents[_group]);
		for (var _index = 0; _index < _count; ++_index)
		{
			var _building = instance_find(_parents[_group], _index);
			if (faction_building_is_targetable(_squad.faction, _building)) array_push(_candidates, _building);
		}
	}
	var _count = array_length(_candidates);
	if (_count > 0) _squad.ai_target = _candidates[irandom(_count - 1)];
}
