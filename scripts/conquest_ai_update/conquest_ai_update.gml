/// @description Chooses one affordable capture, reinforcement, or upgrade using the same rules as the player.
function conquest_ai_update(_controller)
{
	if (!instance_exists(_controller)) return;
	var _nodes = _controller.nodes;
	var _count = array_length(_nodes);
	var _best_score = -1;
	var _best_source = -1;
	var _best_target = -1;
	var _attack = conquest_strength_get(_controller, CONQUEST_OWNER.ENEMY);
	var _growth_rates = BALANCE_CONQUEST_GROWTH;
	_controller.ai_turn++;
	for (var _source_index = 0; _source_index < _count; ++_source_index)
	{
		var _source = _nodes[_source_index];
		if (_source.owner != CONQUEST_OWNER.ENEMY || _source.upgrade_remaining > 0) continue;
		var _available = floor(_source.garrison * 0.75);
		if (_available < 8) continue;
		for (var _target_index = 0; _target_index < _count; ++_target_index)
		{
			var _target = _nodes[_target_index];
			if (_target.owner == CONQUEST_OWNER.ENEMY) continue;
			var _distance = point_distance(_source.x, _source.y, _target.x, _target.y);
			var _defense = conquest_strength_get(_controller, _target.owner);
			if (_target.kind == CONQUEST_BUILDING.TOWER) _defense *= 1 + _target.level * 0.15;
			var _expected = _target.garrison;
			if (_target.owner == CONQUEST_OWNER.PLAYER && _target.kind == CONQUEST_BUILDING.SETTLEMENT)
			{
				_expected += _distance / BALANCE_CONQUEST_MARCH_SPEED * _growth_rates[_target.level - 1];
			}
			var _incoming = 0;
			var _army_count = array_length(_controller.armies);
			for (var _army_index = 0; _army_index < _army_count; ++_army_index)
			{
				var _army = _controller.armies[_army_index];
				if (_army.owner == CONQUEST_OWNER.ENEMY && _army.target == _target_index) _incoming += _army.count;
			}
			var _required = (_expected * _defense / _attack) + 5;
			if (_incoming >= _required || _available + _incoming < _required) continue;
			var _value = _target.kind == CONQUEST_BUILDING.SETTLEMENT ? 1500 : 1100;
			if (_target.owner == CONQUEST_OWNER.PLAYER) _value += 350;
			var _score = _value / (_distance + _required * 8);
			if (_score > _best_score)
			{
				_best_score = _score;
				_best_source = _source_index;
				_best_target = _target_index;
			}
		}
	}
	if (_best_source >= 0)
	{
		conquest_order_send(_controller, _best_source, _best_target, 0.75, CONQUEST_OWNER.ENEMY);
		return;
	}

	// Build economy when no attack is affordable, then pool rear garrisons at the front.
	var _front = -1;
	var _front_distance = 1000000;
	for (var _index = 0; _index < _count; ++_index)
	{
		var _node = _nodes[_index];
		if (_node.owner != CONQUEST_OWNER.ENEMY) continue;
		if (_node.kind == CONQUEST_BUILDING.SETTLEMENT && _node.garrison >= 35
			&& conquest_upgrade_start(_controller, _index, CONQUEST_OWNER.ENEMY)) return;
		for (var _target_index = 0; _target_index < _count; ++_target_index)
		{
			var _target = _nodes[_target_index];
			if (_target.owner != CONQUEST_OWNER.PLAYER) continue;
			var _distance = point_distance(_node.x, _node.y, _target.x, _target.y);
			if (_distance < _front_distance)
			{
				_front = _index;
				_front_distance = _distance;
			}
		}
	}
	if (_front < 0) return;
	for (var _index = 0; _index < _count; ++_index)
	{
		if (_index != _front && _nodes[_index].owner == CONQUEST_OWNER.ENEMY && _nodes[_index].garrison >= 25)
		{
			if (conquest_order_send(_controller, _index, _front, 0.75, CONQUEST_OWNER.ENEMY) > 0) return;
		}
	}
}
