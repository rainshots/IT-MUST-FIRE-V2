/// @description Sends the selected share from every selected player building to one destination.
function conquest_selection_send(_controller, _target)
{
	if (!instance_exists(_controller)) return;
	var _count = array_length(_controller.selected_nodes);
	var _sent = 0;
	for (var _index = 0; _index < _count; ++_index)
	{
		_sent += conquest_order_send(_controller, _controller.selected_nodes[_index], _target,
			_controller.send_fraction, CONQUEST_OWNER.PLAYER);
	}
	_controller.feedback = _sent > 0 ? string(_sent) + " troops dispatched." : "No troops ready. Upgrading buildings cannot send troops.";
	_controller.feedback_timer = 3;
}
