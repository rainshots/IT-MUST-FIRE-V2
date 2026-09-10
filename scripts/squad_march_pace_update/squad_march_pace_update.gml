/// @description Periodically caches the living main formation's base speed and distance to the march destination.
/// @param {Struct} squad Marching squad initialized by squad_march_begin.
function squad_march_pace_update(_squad)
{
	if (!squad_is_marching(_squad))
	{
		return;
	}

	// Use gameplay time so pace sampling follows pauses, time scaling, and room speed.
	var _properties = _squad.properties;
	var _time_scale = global.gameplay_time_scale;
	_properties.march_pace_update_timer -= _time_scale;

	if (_properties.march_pace_update_timer > 0)
	{
		return;
	}

	_properties.march_pace_update_timer = max(1, BALANCE_SQUAD_MARCH_PACE_UPDATE_TIME * room_speed);
	var _main_unit_count = 0;
	var _move_speed_sum = 0;
	var _destination_distance_sum = 0;
	var _unit_count = min(array_length(_squad.units), array_length(_squad.unit_objects));

	// Roster slots retain main-unit membership through temporary combat transformations.
	for (var _unit_index = 0; _unit_index < _unit_count; ++_unit_index)
	{
		if (_squad.unit_objects[_unit_index] != _squad.primary_unit_object)
		{
			continue;
		}

		var _unit = _squad.units[_unit_index];

		if (!instance_exists(_unit)
			|| !_unit.visible
			|| _unit.hp <= 0
			|| _unit.move_speed <= 0)
		{
			continue;
		}

		// Sample base stats; each reinforcement applies its own status and terrain modifiers later.
		_move_speed_sum += _unit.move_speed;
		_destination_distance_sum += point_distance(
			_unit.x,
			_unit.y,
			_properties.marker_x,
			_properties.marker_y
		);
		_main_unit_count++;
	}

	// Without surviving main units, remaining specialists keep their individual movement speeds.
	_properties.march_pace_move_speed = 0;
	_properties.march_pace_destination_distance = 0;

	if (_main_unit_count > 0)
	{
		_properties.march_pace_move_speed = _move_speed_sum / _main_unit_count;
		_properties.march_pace_destination_distance = _destination_distance_sum / _main_unit_count;
	}
}
