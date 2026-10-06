/// @description Sets a persistent route if the destination is reachable and the route does not create a supply loop.
function conquest_route_set(_controller, _source_index, _target_index, _owner)
{
	if (!instance_exists(_controller) || !_controller.tactical_mode) return false;
	var _count = array_length(_controller.nodes);
	if (_source_index < 0 || _target_index < 0 || _source_index >= _count || _target_index >= _count) return false;
	var _source = _controller.nodes[_source_index];
	if (_source.owner != _owner || _source_index == _target_index) return false;
	var _path = conquest_path_get(_controller, _source_index, _target_index, _owner);
	if (array_length(_path) < 2) return false;

	// Follow the destination chain so two rear settlements cannot endlessly exchange their troops.
	var _next = _target_index;
	for (var _index = 0; _index < _count; ++_index)
	{
		if (_next == _source_index) return false;
		var _node = _controller.nodes[_next];
		if (_node.owner != _owner || _node.route_target < 0) break;
		_next = _node.route_target;
		if (_index == _count - 1) return false;
	}
	_source.route_target = _target_index;
	_source.route_path = _path;
	_source.route_blocked = false;
	_controller.route_refresh_remaining = 0;
	return true;
}
