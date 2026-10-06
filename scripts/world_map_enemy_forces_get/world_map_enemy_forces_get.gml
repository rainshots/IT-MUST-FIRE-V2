/// @description Counts editor-placed enemy troops and buildings once on map entry, without loading the battle room.
function world_map_enemy_forces_get(_battle_room)
{
	var _forces = [];
	if (!room_exists(_battle_room)) return _forces;
	var _room_info = room_get_info(_battle_room, false, true, false, false, false);
	var _instances = _room_info.instances;
	if (!is_array(_instances)) return _forces;
	var _instance_count = array_length(_instances);
	for (var _index = 0; _index < _instance_count; ++_index)
	{
		var _object = asset_get_index(_instances[_index].object_index);
		if (!battle_object_is_enemy(_object)) continue;
		var _found = false;
		var _force_count = array_length(_forces);
		for (var _force_index = 0; _force_index < _force_count; ++_force_index)
		{
			if (_forces[_force_index].unit_object != _object) continue;
			_forces[_force_index].count++;
			_found = true;
			break;
		}
		if (!_found) array_push(_forces, { unit_object: _object, count: 1 });
	}
	return _forces;
}
