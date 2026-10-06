/// @description Stops hostile columns meeting on the same road and applies simultaneous proportional casualties.
function conquest_road_clashes_update(_controller, _seconds)
{
	if (!instance_exists(_controller)) return;
	var _armies = _controller.armies;
	var _count = array_length(_armies);
	var _contacts = [];
	var _strength = [1, conquest_strength_get(_controller, CONQUEST_OWNER.PLAYER), conquest_strength_get(_controller, CONQUEST_OWNER.ENEMY)];
	for (var _index = 0; _index < _count; ++_index)
	{
		var _first = _armies[_index];
		if (_first.count <= 0) continue;
		for (var _other = _index + 1; _other < _count; ++_other)
		{
			var _second = _armies[_other];
			if (_first.owner == _second.owner || _second.count <= 0) continue;
			var _opposed = !_first.besieging && !_second.besieging
				&& _first.segment_source == _second.segment_target && _first.segment_target == _second.segment_source;
			var _contested_siege = _first.besieging && _second.besieging && _first.segment_target == _second.segment_target;
			if (!_contested_siege && (!_opposed || _first.progress + _second.progress < 1)) continue;
			if (_opposed)
			{
				// Sweep the previous positions so even a long simulation frame cannot tunnel through an enemy.
				var _meeting = clamp((_first.previous_progress + 1 - _second.previous_progress) * 0.5, 0, 1);
				_first.progress = _meeting;
				_second.progress = 1 - _meeting;
				var _target = _controller.nodes[_first.segment_target];
				_first.x = lerp(_first.start_x, _target.x, _meeting);
				_first.y = lerp(_first.start_y, _target.y, _meeting);
				_second.x = _first.x;
				_second.y = _first.y;
			}
			_first.engaged = true;
			_second.engaged = true;
			_first.engaged_enemy_count += _second.count;
			_second.engaged_enemy_count += _first.count;
			array_push(_contacts, [_index, _other]);
		}
	}

	// Divide each column's damage among its contacts so packet splitting cannot multiply firepower.
	var _contact_count = array_length(_contacts);
	for (var _index = 0; _index < _contact_count; ++_index)
	{
		var _contact = _contacts[_index];
		var _first = _armies[_contact[0]];
		var _second = _armies[_contact[1]];
		_first.pending_damage += _second.count * _strength[_second.owner] / _strength[_first.owner]
			* BALANCE_CONQUEST_ROAD_COMBAT_RATE * _seconds * _first.count / _second.engaged_enemy_count;
		_second.pending_damage += _first.count * _strength[_first.owner] / _strength[_second.owner]
			* BALANCE_CONQUEST_ROAD_COMBAT_RATE * _seconds * _second.count / _first.engaged_enemy_count;
	}
	for (var _index = 0; _index < _count; ++_index)
	{
		var _army = _armies[_index];
		_army.count = max(0, _army.count - _army.pending_damage);
	}
}
