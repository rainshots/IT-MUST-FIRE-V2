/// @description Sends the selected share from every selected player building to one destination.
function conquest_selection_send(_controller, _target)
{
	if (!instance_exists(_controller)) return;
	var _count = array_length(_controller.selected_nodes);
	if (_controller.tactical_mode && _controller.auto_orders)
	{
		var _routes = 0;
		for (var _index = 0; _index < _count; ++_index)
		{
			if (conquest_route_set(_controller, _controller.selected_nodes[_index], _target, CONQUEST_OWNER.PLAYER)) _routes++;
		}
		_controller.feedback = _routes > 0 ? string(_routes) + " automatic route(s) set. Reserves stay at home. X stops selected routes."
			: "No route: capture the intervening buildings first. Supply routes cannot form a loop.";
		_controller.feedback_timer = 6;
		return;
	}
	var _sent = 0;
	for (var _index = 0; _index < _count; ++_index)
	{
		var _source_index = _controller.selected_nodes[_index];
		var _departed = conquest_order_send(_controller, _source_index, _target,
			_controller.send_fraction, CONQUEST_OWNER.PLAYER);
		_sent += _departed;
		if (_controller.tactical_mode && _departed > 0)
		{
			_controller.nodes[_source_index].route_target = -1;
			_controller.nodes[_source_index].route_path = [];
		}
	}
	_controller.feedback = _sent > 0 ? string(_sent) + " troops dispatched." : "No troops ready. Upgrading buildings cannot send troops.";
	_controller.feedback_timer = 3;
	if (_controller.tactical_mode && _sent == 0) _controller.feedback = "No wave ready: check the road, dispatch cooldown and siege status.";
}
