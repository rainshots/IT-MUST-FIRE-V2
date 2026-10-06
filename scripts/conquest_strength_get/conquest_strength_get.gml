/// @description Calculates a faction's current forge bonus for attack and defense.
function conquest_strength_get(_controller, _owner)
{
	if (!instance_exists(_controller)) return 1;
	var _strength = 1;
	if (_owner == CONQUEST_OWNER.NEUTRAL) return _strength;
	var _count = array_length(_controller.nodes);
	for (var _index = 0; _index < _count; ++_index)
	{
		var _node = _controller.nodes[_index];
		if (_node.owner == _owner && _node.kind == CONQUEST_BUILDING.FORGE)
		{
			_strength += _node.level * BALANCE_CONQUEST_FORGE_BONUS;
		}
	}
	return _strength;
}
