/// @description Finds the shortest road path using friendly intermediate buildings; the destination may be hostile.
function conquest_path_get(_controller, _source, _target, _owner)
{
	if (!instance_exists(_controller)) return [];
	var _nodes = _controller.nodes;
	var _count = array_length(_nodes);
	if (_source < 0 || _target < 0 || _source >= _count || _target >= _count || _source == _target) return [];
	if (!_controller.tactical_mode) return [_source, _target];
	var _unreachable = 1000000;
	var _distances = array_create(_count, _unreachable);
	var _previous = array_create(_count, -1);
	var _visited = array_create(_count, false);
	_distances[_source] = 0;
	var _road_count = array_length(_controller.roads);

	// Dijkstra is bounded by the small fixed building count; no dynamic pathfinding instances.
	for (var _iteration = 0; _iteration < _count; ++_iteration)
	{
		var _current = -1;
		var _distance = _unreachable;
		for (var _index = 0; _index < _count; ++_index)
		{
			if (!_visited[_index] && _distances[_index] < _distance)
			{
				_current = _index;
				_distance = _distances[_index];
			}
		}
		if (_current < 0 || _current == _target) break;
		_visited[_current] = true;
		if (_current != _source && _nodes[_current].owner != _owner) continue;
		for (var _road_index = 0; _road_index < _road_count; ++_road_index)
		{
			var _road = _controller.roads[_road_index];
			var _next = _road[0] == _current ? _road[1] : (_road[1] == _current ? _road[0] : -1);
			if (_next < 0 || _visited[_next]) continue;
			var _from = _nodes[_current];
			var _to = _nodes[_next];
			var _candidate = _distance + point_distance(_from.x, _from.y, _to.x, _to.y);
			if (_candidate < _distances[_next])
			{
				_distances[_next] = _candidate;
				_previous[_next] = _current;
			}
		}
	}
	if (_previous[_target] < 0) return [];
	var _path = [_target];
	var _current = _target;
	for (var _index = 0; _index < _count; ++_index)
	{
		_current = _previous[_current];
		if (_current < 0) return [];
		array_insert(_path, 0, _current);
		if (_current == _source) return _path;
	}
	return [];
}
