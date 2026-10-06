/// @description Finds the closest building under the pointer, including its sprite and garrison label.
function conquest_node_at_position(_controller, _x, _y)
{
	if (!instance_exists(_controller)) return -1;
	if (_y < _controller.field_top || _y >= _controller.field_bottom) return -1;
	var _closest = -1;
	var _distance = BALANCE_CONQUEST_HIT_RADIUS;
	var _count = array_length(_controller.nodes);
	for (var _index = 0; _index < _count; ++_index)
	{
		var _node = _controller.nodes[_index];
		var _test_distance = point_distance(_x, _y, _node.x, _node.y - 25);
		if (_test_distance < _distance)
		{
			_closest = _index;
			_distance = _test_distance;
		}
	}
	return _closest;
}
