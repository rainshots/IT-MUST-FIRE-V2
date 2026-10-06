/// @description Moves columns along their current road; hostile waypoints stop them instead of allowing passage.
function conquest_road_armies_update(_controller, _seconds)
{
	if (!instance_exists(_controller)) return;
	var _count = array_length(_controller.armies);
	for (var _index = 0; _index < _count; ++_index)
	{
		var _army = _controller.armies[_index];
		_army.engaged = false;
		_army.pending_damage = 0;
		_army.engaged_enemy_count = 0;
		_army.previous_progress = _army.progress;
		if (_army.count <= 0 || _army.besieging) continue;
		var _target = _controller.nodes[_army.segment_target];
		_army.progress = min(1, _army.progress + _controller.march_speed * _seconds / _army.distance);
		_army.x = lerp(_army.start_x, _target.x, _army.progress);
		_army.y = lerp(_army.start_y, _target.y, _army.progress);
		// Finish waypoints after interception, so arriving columns cannot skip a road fight.
	}
}
