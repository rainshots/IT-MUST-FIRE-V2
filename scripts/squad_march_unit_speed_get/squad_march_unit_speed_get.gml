/// @description Returns a reinforcement's formation-adjusted march base speed without changing its combat stats.
/// @param {Id.Instance} unit Friendly unit whose march movement is being calculated.
function squad_march_unit_speed_get(_unit)
{
	if (!instance_exists(_unit))
	{
		return 0;
	}

	var _base_move_speed = _unit.move_speed;
	var _squad = _unit.squad;

	if (global.day_phase != DAY_PHASE.NIGHT
		|| _unit.unit_faction != UNIT_FACTION.FRIENDLY
		|| !squad_is_marching(_squad))
	{
		return _base_move_speed;
	}

	// Main roster members keep their own pace; only attached specialists match the formation.
	var _unit_index = _unit.squad_unit_index;
	var _roster_count = array_length(_squad.unit_objects);

	if (_unit_index < 0
		|| _unit_index >= _roster_count
		|| _squad.unit_objects[_unit_index] == _squad.primary_unit_object)
	{
		return _base_move_speed;
	}

	var _properties = _squad.properties;

	if (_properties.march_pace_move_speed <= 0)
	{
		return _base_move_speed;
	}

	// Compare progress toward the shared destination in any march direction.
	var _destination_distance = point_distance(_unit.x, _unit.y, _properties.marker_x, _properties.marker_y);
	var _distance_gap = _destination_distance - _properties.march_pace_destination_distance;
	var _correction_distance = max(0, abs(_distance_gap) - BALANCE_SQUAD_MARCH_PACE_DISTANCE_TOLERANCE);
	var _correction_share = clamp(_correction_distance / BALANCE_SQUAD_MARCH_PACE_CORRECTION_DISTANCE, 0, 1);
	var _maximum_multiplier = _distance_gap > 0
		? BALANCE_SQUAD_MARCH_PACE_CATCH_UP_MULTIPLIER
		: BALANCE_SQUAD_MARCH_PACE_AHEAD_MULTIPLIER;
	var _correction_multiplier = lerp(1, _maximum_multiplier, _correction_share);

	return _properties.march_pace_move_speed * _correction_multiplier;
}
