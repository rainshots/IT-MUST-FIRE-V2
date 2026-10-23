/// @description Selects a living Idol on the route toward The Heart, or The Heart itself.
function player_objective_target_get(_unit)
{
	var _target = instance_find(o_heart, 0);
	var _distance = instance_exists(_target) ? point_distance(_unit.x, _unit.y, _target.x, _target.y) : infinity;
	with (o_new_idol)
	{
		if (hp <= 0) continue;
		var _candidate = point_distance(_unit.x, _unit.y, x, y);
		if (_candidate < _distance) { _target = id; _distance = _candidate; }
	}
	return _target;
}
