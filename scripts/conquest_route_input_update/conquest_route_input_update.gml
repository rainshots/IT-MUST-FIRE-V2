/// @description Handles standing-order mode, reserve adjustment and route cancellation; returns whether it consumed input.
function conquest_route_input_update(_controller)
{
	if (!instance_exists(_controller) || !_controller.tactical_mode) return false;
	var _x = device_mouse_x_to_gui(0);
	var _y = device_mouse_y_to_gui(0);
	var _pressed = mouse_check_button_pressed(mb_left);
	if (keyboard_check_pressed(ord("T")) || (_pressed && point_in_rectangle(_x, _y, 1150, 949, 1395, 1014)))
	{
		_controller.auto_orders = !_controller.auto_orders;
		_controller.feedback = _controller.auto_orders ? "AUTO: orders establish a route that keeps your reserve at home."
			: "ONE WAVE: send the selected share once. This replaces the source's automatic route.";
		_controller.feedback_timer = 5;
		return true;
	}
	var _less = keyboard_check_pressed(ord("Z"));
	var _more = keyboard_check_pressed(ord("C"));
	var _stop = keyboard_check_pressed(ord("X"));
	if (_pressed && _controller.auto_orders)
	{
		_less = _less || point_in_rectangle(_x, _y, 700, 960, 792, 1012);
		_more = _more || point_in_rectangle(_x, _y, 910, 960, 1002, 1012);
		_stop = _stop || point_in_rectangle(_x, _y, 1015, 960, 1107, 1012);
	}
	if (!_less && !_more && !_stop) return false;
	var _count = array_length(_controller.selected_nodes);
	for (var _index = 0; _index < _count; ++_index)
	{
		var _node = _controller.nodes[_controller.selected_nodes[_index]];
		if (_node.owner != CONQUEST_OWNER.PLAYER) continue;
		if (_stop)
		{
			_node.route_target = -1;
			_node.route_path = [];
			_node.route_blocked = false;
		}
		else
		{
			var _change = (_more ? 1 : -1) * BALANCE_CONQUEST_ROUTE_RESERVE_STEP;
			_node.reserve = clamp(_node.reserve + _change, 0, BALANCE_CONQUEST_ROUTE_RESERVE_MAX);
		}
	}
	_controller.feedback = _stop ? "Selected routes stopped. Troops already on the road finish their orders."
		: "Reserve changed for future waves. Troops already marching are not recalled.";
	_controller.feedback_timer = 5;
	_controller.route_refresh_remaining = 0;
	return true;
}
