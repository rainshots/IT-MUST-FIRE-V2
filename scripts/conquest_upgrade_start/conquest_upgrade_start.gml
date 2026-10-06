/// @description Spends a building's own troops on its next level; recruitment pauses while upgrading.
function conquest_upgrade_start(_controller, _index, _owner)
{
	if (!instance_exists(_controller)) return false;
	if (_index < 0 || _index >= array_length(_controller.nodes)) return false;
	var _node = _controller.nodes[_index];
	if (_node.owner != _owner || _node.level >= BALANCE_CONQUEST_MAX_LEVEL
		|| _node.upgrade_remaining > 0 || _controller.phase != BATTLE_PHASE.BATTLE) return false;
	var _costs = BALANCE_CONQUEST_UPGRADE_COST;
	var _cost = _costs[_node.level - 1];
	if (_node.garrison < _cost + 1) return false;
	_node.garrison -= _cost;
	_node.upgrade_remaining = BALANCE_CONQUEST_UPGRADE_SECONDS;
	return true;
}
