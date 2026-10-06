/// @description Measures an already resolved path in battlefield pixels.
function conquest_path_length_get(_controller, _path)
{
	if (!instance_exists(_controller)) return 0;
	var _length = 0;
	var _count = array_length(_path);
	for (var _index = 1; _index < _count; ++_index)
	{
		var _from = _controller.nodes[_path[_index - 1]];
		var _to = _controller.nodes[_path[_index]];
		_length += point_distance(_from.x, _from.y, _to.x, _to.y);
	}
	return _length;
}
