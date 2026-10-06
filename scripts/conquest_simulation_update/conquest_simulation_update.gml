/// @description Advances recruitment, moving armies, defensive fire, AI and battle results in seconds.
function conquest_simulation_update(_controller, _seconds)
{
	if (!instance_exists(_controller)) return;
	if (_controller.paused || _controller.phase != BATTLE_PHASE.BATTLE) return;
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

	// Tracers are visual only; damage is applied exactly once when a tower fires.
	for (var _index = array_length(_controller.shots) - 1; _index >= 0; --_index)
	{
		_controller.shots[_index].remaining -= _seconds;
		if (_controller.shots[_index].remaining <= 0) array_delete(_controller.shots, _index, 1);
	}
	var _army_count = array_length(_controller.armies);
	for (var _index = 0; _index < _node_count; ++_index)
	{
		var _tower = _nodes[_index];
		if (_tower.kind != CONQUEST_BUILDING.TOWER || _tower.owner == CONQUEST_OWNER.NEUTRAL || _tower.upgrade_remaining > 0) continue;
		_tower.shot_timer = max(0, _tower.shot_timer - _seconds);
		if (_tower.shot_timer > 0) continue;
		var _nearest = -1;
		var _nearest_distance = BALANCE_CONQUEST_TOWER_RANGE;
		for (var _army_index = 0; _army_index < _army_count; ++_army_index)
		{
			var _army = _controller.armies[_army_index];
			if (_army.owner == _tower.owner || _army.count <= 0) continue;
			var _distance = point_distance(_tower.x, _tower.y, _army.x, _army.y);
			if (_distance < _nearest_distance)
			{
				_nearest = _army_index;
				_nearest_distance = _distance;
			}
		}
		if (_nearest >= 0)
		{
			var _army = _controller.armies[_nearest];
			_army.count = max(0, _army.count - _tower.level);
			_tower.shot_timer = BALANCE_CONQUEST_TOWER_INTERVAL;
			array_push(_controller.shots, { x: _tower.x, y: _tower.y - 65, target_x: _army.x,
				target_y: _army.y, owner: _tower.owner, remaining: 0.18 });
		}
	}

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
