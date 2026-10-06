/// @description Captures a level object asset after victory or F8 and advances the campaign route.
function world_map_level_capture(_map, _level_object)
{
	if (!instance_exists(_map) || !object_exists(_level_object)) return;
	if (!array_contains(_map.captured_levels, _level_object)) array_push(_map.captured_levels, _level_object);
	_map.last_captured_level = _level_object;
	if (room == r_world_map) world_map_states_refresh(_map);
}
