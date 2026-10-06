/// @description Resolves friendly waypoints and sustained sieges; capturing needs three uncontested seconds.
function conquest_road_sieges_update(_controller, _seconds)
{
	if (!instance_exists(_controller)) return;
	var _armies = _controller.armies;
	var _army_count = array_length(_armies);
	var _nodes = _controller.nodes;
	var _node_count = array_length(_nodes);
	for (var _index = 0; _index < _army_count; ++_index)
	{
		var _army = _armies[_index];
		if (_army.count < BALANCE_CONQUEST_ROAD_MIN_SURVIVORS || _army.engaged || _army.progress < 1) continue;
		var _target = _nodes[_army.segment_target];
		if (_target.owner != _army.owner)
		{
			_army.target = _army.segment_target;
			_army.besieging = true;
			_target.under_siege = true;
			continue;
		}
		if (_army.besieging || _army.path_step == array_length(_army.path) - 1)
		{
			_target.garrison += _army.count;
			_army.count = 0;
			continue;
		}
		// Keep a committed path. A newly hostile intermediate stop becomes a siege destination.
		_army.segment_source = _army.segment_target;
		_army.path_step++;
		_army.segment_target = _army.path[_army.path_step];
		_army.start_x = _target.x;
		_army.start_y = _target.y;
		var _next = _nodes[_army.segment_target];
		_army.distance = max(1, point_distance(_target.x, _target.y, _next.x, _next.y));
		_army.progress = 0;
		_army.previous_progress = 0;
	}

	// Group the attackers so splitting an order into many packets cannot multiply defender damage.
	for (var _node_index = 0; _node_index < _node_count; ++_node_index)
	{
		var _node = _nodes[_node_index];
		var _attackers = 0;
		var _owner = CONQUEST_OWNER.NEUTRAL;
		var _contested = false;
		for (var _index = 0; _index < _army_count; ++_index)
		{
			var _army = _armies[_index];
			if (!_army.besieging || _army.segment_target != _node_index || _army.count < BALANCE_CONQUEST_ROAD_MIN_SURVIVORS) continue;
			if (_owner != CONQUEST_OWNER.NEUTRAL && _owner != _army.owner) _contested = true;
			_owner = _army.owner;
			_attackers += _army.count;
		}
		if (_attackers <= 0 || _contested)
		{
			_node.capture_remaining = BALANCE_CONQUEST_ROAD_CAPTURE_SECONDS;
			continue;
		}
		_node.under_siege = true;
		if (_node.siege_owner != _owner)
		{
			_node.siege_owner = _owner;
			_node.capture_remaining = BALANCE_CONQUEST_ROAD_CAPTURE_SECONDS;
		}
		var _attack_strength = conquest_strength_get(_controller, _owner);
		var _defense_strength = conquest_strength_get(_controller, _node.owner);
		if (_node.kind == CONQUEST_BUILDING.TOWER) _defense_strength *= 1 + _node.level * 0.15;
		if (_node.garrison > 0)
		{
			var _defender_damage = _attackers * _attack_strength / _defense_strength * BALANCE_CONQUEST_ROAD_COMBAT_RATE * _seconds;
			var _attacker_damage = _node.garrison * _defense_strength / _attack_strength * BALANCE_CONQUEST_ROAD_COMBAT_RATE * _seconds;
			_node.garrison = max(0, _node.garrison - _defender_damage);
			_node.capture_remaining = BALANCE_CONQUEST_ROAD_CAPTURE_SECONDS;
			for (var _index = 0; _index < _army_count; ++_index)
			{
				var _army = _armies[_index];
				if (_army.besieging && _army.segment_target == _node_index)
				{
					_army.count = max(0, _army.count - _attacker_damage * _army.count / _attackers);
				}
			}
		}
		else
		{
			_node.capture_remaining = max(0, _node.capture_remaining - _seconds);
			if (_node.capture_remaining > 0) continue;
			conquest_arrival_resolve(_controller, { target: _node_index, owner: _owner, count: _attackers });
			for (var _index = 0; _index < _army_count; ++_index)
			{
				var _army = _armies[_index];
				if (_army.besieging && _army.segment_target == _node_index) _army.count = 0;
			}
		}
	}
}
