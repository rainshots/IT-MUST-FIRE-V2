/// @description Sends reserve-preserving waves and pauses cut routes until a friendly road opens again.
function conquest_routes_update(_controller, _seconds)
{
	if (!instance_exists(_controller)) return;
	_controller.route_refresh_remaining -= _seconds;
	if (_controller.route_refresh_remaining > 0) return;
	_controller.route_refresh_remaining = BALANCE_CONQUEST_ROUTE_REFRESH_SECONDS;
	var _count = array_length(_controller.nodes);
	for (var _index = 0; _index < _count; ++_index)
	{
		var _node = _controller.nodes[_index];
		if (_node.owner == CONQUEST_OWNER.NEUTRAL || _node.route_target < 0) continue;
		var _path = conquest_path_get(_controller, _index, _node.route_target, _node.owner);
		_node.route_blocked = array_length(_path) < 2;
		if (_node.route_blocked) continue;
		_node.route_path = _path;
		if (_node.dispatch_remaining > 0 || _node.upgrade_remaining > 0 || _node.under_siege) continue;
		var _available = floor(_node.garrison);
		var _send_count = _available - _node.reserve;
		if (_send_count < BALANCE_CONQUEST_ROUTE_MIN_BATCH) continue;
		// The small epsilon only protects integer division from rounding one soldier down.
		var _rounding_margin = 0.000001;
		conquest_order_send(_controller, _index, _node.route_target, (_send_count + _rounding_margin) / _available, _node.owner);
	}
}
