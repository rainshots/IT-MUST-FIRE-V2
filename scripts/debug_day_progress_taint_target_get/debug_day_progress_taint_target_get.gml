/// @description Finds the nearest unclaimed construction point along the selected attack direction.
function debug_day_progress_taint_target_get(_cannon, _direction)
{
	if (!instance_exists(_cannon))
	{
		return noone;
	}

	// Prefer the closest point inside the lane; fall back to the closest angle if the lane is empty.
	var _lane_target = noone;
	var _lane_distance = infinity;
	var _fallback_target = noone;
	var _fallback_angle = infinity;
	var _fallback_distance = infinity;
	var _point_count = instance_number(o_cursed_point);
	for (var _point_index = 0; _point_index < _point_count; ++_point_index)
	{
		// GameMaker includes inherited Trap Points and Habitat Points in this lookup.
		var _point = instance_find(o_cursed_point, _point_index);
		if (!instance_exists(_point)
			|| _point.is_captured
			|| _point.cursed_point_interaction_is_blocked()
			|| _point.ground_area_is_tainted(_point.x, _point.y, _point.capture_ground_radius))
		{
			continue;
		}
		var _point_direction = point_direction(_cannon.x, _cannon.y, _point.x, _point.y);
		var _angle = abs(angle_difference(_direction, _point_direction));
		var _distance = point_distance(_cannon.x, _cannon.y, _point.x, _point.y);
		if (_angle <= BALANCE_DEBUG_DAY_PROGRESS_DIRECTION_HALF_ANGLE && _distance < _lane_distance)
		{
			_lane_target = _point;
			_lane_distance = _distance;
		}
		if (_angle < _fallback_angle || (_angle == _fallback_angle && _distance < _fallback_distance))
		{
			_fallback_target = _point;
			_fallback_angle = _angle;
			_fallback_distance = _distance;
		}
	}
	return instance_exists(_lane_target) ? _lane_target : _fallback_target;
}
