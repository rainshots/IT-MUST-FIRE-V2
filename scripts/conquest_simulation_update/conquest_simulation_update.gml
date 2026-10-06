/// @description Advances recruitment, moving armies, defensive fire, AI and battle results in seconds.
function conquest_simulation_update(_controller, _seconds)
{
	if (!instance_exists(_controller)) return;
	if (_controller.paused || _controller.phase != BATTLE_PHASE.BATTLE) return;
	if (_controller.tactical_mode)
	{
		conquest_road_simulation_update(_controller, _seconds);
		return;
	}
	_controller.elapsed_seconds += _seconds;
	_controller.feedback_timer = max(0, _controller.feedback_timer - _seconds);
	var _nodes = _controller.nodes;
	var _node_count = array_length(_nodes);
	var _growth_rates = BALANCE_CONQUEST_GROWTH;
	var _capacities = BALANCE_CONQUEST_CAPACITY;
	for (var _index = 0; _index < _node_count; ++_index)
	{
		var _node = _nodes[_index];
		_node.capture_flash = max(0, _node.capture_flash - _seconds);
		if (_node.owner == CONQUEST_OWNER.NEUTRAL) continue;
		if (_node.upgrade_remaining > 0)
		{
			_node.upgrade_remaining = max(0, _node.upgrade_remaining - _seconds);
			if (_node.upgrade_remaining == 0) _node.level = min(BALANCE_CONQUEST_MAX_LEVEL, _node.level + 1);
		}
		else if (_node.kind == CONQUEST_BUILDING.SETTLEMENT)
		{
			var _capacity = _capacities[_node.level - 1];
			if (_node.garrison < _capacity) _node.garrison = min(_capacity, _node.garrison + _growth_rates[_node.level - 1] * _seconds);
		}
	}

	conquest_towers_update(_controller, _seconds);
	var _army_count = array_length(_controller.armies);

	// Reverse removal preserves every surviving order and never skips an arriving group.
	for (var _index = _army_count - 1; _index >= 0; --_index)
	{
		var _army = _controller.armies[_index];
		if (_army.count <= 0)
		{
			array_delete(_controller.armies, _index, 1);
			continue;
		}
		_army.progress = min(1, _army.progress + BALANCE_CONQUEST_MARCH_SPEED * _seconds / _army.distance);
		var _target = _nodes[_army.target];
		_army.x = lerp(_army.start_x, _target.x, _army.progress);
		_army.y = lerp(_army.start_y, _target.y, _army.progress);
		if (_army.progress >= 1)
		{
			conquest_arrival_resolve(_controller, _army);
			array_delete(_controller.armies, _index, 1);
		}
	}
	conquest_result_update(_controller);
	if (_controller.phase != BATTLE_PHASE.BATTLE) return;
	_controller.ai_timer -= _seconds;
	if (_controller.ai_timer <= 0)
	{
		_controller.ai_timer = _controller.ai_interval_seconds;
		conquest_ai_update(_controller);
	}
}
