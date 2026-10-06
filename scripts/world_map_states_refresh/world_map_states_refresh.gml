/// @description Marks captured history, immediate choices, reachable future points, and abandoned branches.
function world_map_states_refresh(_map)
{
	if (!instance_exists(_map)) return;
	var _levels = _map.levels;
	var _count = array_length(_levels);
	var _available = [];
	if (_map.last_captured_level == noone)
	{
		array_push(_available, _map.start_level);
	}
	else
	{
		for (var _index = 0; _index < _count; ++_index)
		{
			if (_levels[_index].level_object != _map.last_captured_level) continue;
			var _next = _levels[_index].next_levels;
			array_copy(_available, 0, _next, 0, array_length(_next));
			break;
		}
	}

	// Visit each reachable object once, so an accidental cyclic link cannot hang the map.
	var _reachable = [];
	array_copy(_reachable, 0, _available, 0, array_length(_available));
	var _queue_count = array_length(_reachable);
	for (var _queue_index = 0; _queue_index < _queue_count; ++_queue_index)
	{
		var _object = _reachable[_queue_index];
		if (array_contains(_map.captured_levels, _object)) continue;
		for (var _level_index = 0; _level_index < _count; ++_level_index)
		{
			if (_levels[_level_index].level_object != _object) continue;
			var _successors = _levels[_level_index].next_levels;
			var _successor_count = array_length(_successors);
			for (var _next_index = 0; _next_index < _successor_count; ++_next_index)
			{
				var _successor = _successors[_next_index];
				if (!array_contains(_reachable, _successor))
				{
					array_push(_reachable, _successor);
					_queue_count++;
				}
			}
			break;
		}
	}

	// Before the first capture, the gray ground stops just before the starting point.
	var _taint_target = _map.taint_boundary_target_x;
	var _start_point = instance_find(_map.start_level, 0);
	if (instance_exists(_start_point))
	{
		var _start_half_width = sprite_get_width(_start_point.sprite_index) * abs(_start_point.image_xscale) * 0.5;
		_taint_target = max(_taint_target, _start_point.x - _start_half_width - _map.taint_boundary_padding);
	}

	// Captured points retain their fill and advance the ground frontier only to the right.
	for (var _index = 0; _index < _count; ++_index)
	{
		var _entry = _levels[_index];
		var _point = _entry.point;
		if (!instance_exists(_point)) continue;
		var _object = _entry.level_object;
		if (array_contains(_map.captured_levels, _object))
		{
			_point.level_state = WORLD_MAP_LEVEL_STATE.CAPTURED;
			_point.sprite_index = s_map_point_01;
			var _point_half_width = sprite_get_width(_point.sprite_index) * abs(_point.image_xscale) * 0.5;
			_taint_target = max(_taint_target, _point.x + _point_half_width + _map.taint_boundary_padding);
		}
		else if (array_contains(_available, _object))
		{
			_point.level_state = WORLD_MAP_LEVEL_STATE.AVAILABLE;
			_point.sprite_index = s_map_point_04;
		}
		else if (array_contains(_reachable, _object))
		{
			_point.level_state = WORLD_MAP_LEVEL_STATE.FUTURE;
			_point.sprite_index = s_map_point_03;
		}
		else
		{
			_point.level_state = WORLD_MAP_LEVEL_STATE.BEHIND;
			_point.sprite_index = s_map_point_02;
		}
	}

	// Only the initial map snaps into place; later victories animate from the previous frontier.
	_map.taint_boundary_target_x = clamp(_taint_target, 0, _map.gui_width);
	if (_map.taint_boundary_x < 0) _map.taint_boundary_x = _map.taint_boundary_target_x;
}
