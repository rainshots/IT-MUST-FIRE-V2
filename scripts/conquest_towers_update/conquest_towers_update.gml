/// @description Updates defensive tower fire and its short-lived visual tracers.
function conquest_towers_update(_controller, _seconds)
{
	if (!instance_exists(_controller)) return;
	var _nodes = _controller.nodes;
	var _node_count = array_length(_nodes);
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

}
