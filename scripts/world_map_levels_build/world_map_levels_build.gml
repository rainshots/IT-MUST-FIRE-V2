/// @description Resolves the placed level objects' previous and next links into a directed graph.
function world_map_levels_build(_map)
{
	if (!instance_exists(_map)) return;
	_map.levels = [];
	var _count = instance_number(o_level_parent);
	for (var _index = 0; _index < _count; ++_index)
	{
		var _point = instance_find(o_level_parent, _index);
		if (!instance_exists(_point)) continue;
		var _next = [];
		array_copy(_next, 0, _point.next_levels, 0, array_length(_point.next_levels));
		array_push(_map.levels, { point: _point, level_object: _point.object_index, next_levels: _next });
		_point.enemy_forces = world_map_enemy_forces_get(_point.battle_room);
	}

	// A link may be declared at either end; matching entries are drawn only once.
	var _levels = _map.levels;
	var _level_count = array_length(_levels);
	for (var _target_index = 0; _target_index < _level_count; ++_target_index)
	{
		var _target = _levels[_target_index];
		var _previous = _target.point.previous_levels;
		var _previous_count = array_length(_previous);
		for (var _previous_index = 0; _previous_index < _previous_count; ++_previous_index)
		{
			for (var _source_index = 0; _source_index < _level_count; ++_source_index)
			{
				var _source = _levels[_source_index];
				if (_source.level_object != _previous[_previous_index]) continue;
				if (!array_contains(_source.next_levels, _target.level_object))
				{
					array_push(_source.next_levels, _target.level_object);
				}
				break;
			}
		}
	}
	world_map_states_refresh(_map);
}
