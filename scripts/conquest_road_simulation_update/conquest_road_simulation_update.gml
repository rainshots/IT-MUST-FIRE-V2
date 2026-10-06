/// @description Advances road warfare in seconds, including standing orders, interception and contested buildings.
function conquest_road_simulation_update(_controller, _seconds)
{
	if (!instance_exists(_controller)) return;
	_controller.elapsed_seconds += _seconds;
	_controller.feedback_timer = max(0, _controller.feedback_timer - _seconds);
	var _nodes = _controller.nodes;
	var _node_count = array_length(_nodes);
	var _army_count = array_length(_controller.armies);
	var _growth_rates = BALANCE_CONQUEST_GROWTH;
	var _capacities = BALANCE_CONQUEST_CAPACITY;
	for (var _index = 0; _index < _node_count; ++_index) _nodes[_index].under_siege = false;
	for (var _index = 0; _index < _army_count; ++_index)
	{
		var _army = _controller.armies[_index];
		if (_army.besieging && _army.count > 0 && _nodes[_army.segment_target].owner != _army.owner)
		{
			_nodes[_army.segment_target].under_siege = true;
		}
	}

	// Empty roads give players time to plan; besieged settlements cannot recruit through an attack.
	for (var _index = 0; _index < _node_count; ++_index)
	{
		var _node = _nodes[_index];
		_node.capture_flash = max(0, _node.capture_flash - _seconds);
		_node.dispatch_remaining = max(0, _node.dispatch_remaining - _seconds);
		if (_node.owner == CONQUEST_OWNER.NEUTRAL) continue;
		if (_node.upgrade_remaining > 0)
		{
			_node.upgrade_remaining = max(0, _node.upgrade_remaining - _seconds);
			if (_node.upgrade_remaining == 0) _node.level = min(BALANCE_CONQUEST_MAX_LEVEL, _node.level + 1);
		}
		else if (!_node.under_siege && _node.kind == CONQUEST_BUILDING.SETTLEMENT)
		{
			var _capacity = _capacities[_node.level - 1];
			var _growth = _growth_rates[_node.level - 1] * BALANCE_CONQUEST_ROAD_GROWTH_MULTIPLIER;
			if (_node.garrison < _capacity) _node.garrison = min(_capacity, _node.garrison + _growth * _seconds);
		}
	}
	conquest_road_armies_update(_controller, _seconds);
	conquest_road_clashes_update(_controller, _seconds);
	conquest_towers_update(_controller, _seconds);
	conquest_road_sieges_update(_controller, _seconds);

	// Removal is deferred until all simultaneous combat has read the same set of armies.
	for (var _index = _army_count - 1; _index >= 0; --_index)
	{
		if (_controller.armies[_index].count < BALANCE_CONQUEST_ROAD_MIN_SURVIVORS) array_delete(_controller.armies, _index, 1);
	}
	conquest_result_update(_controller);
	if (_controller.phase != BATTLE_PHASE.BATTLE) return;
	conquest_routes_update(_controller, _seconds);
	_controller.ai_timer -= _seconds;
	if (_controller.ai_timer <= 0)
	{
		_controller.ai_timer = _controller.ai_interval_seconds;
		conquest_ai_update(_controller);
	}
}
