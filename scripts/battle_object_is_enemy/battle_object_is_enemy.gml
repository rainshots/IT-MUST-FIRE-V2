/// @description Classifies enemy troop/building assets without creating instances or running their events.
function battle_object_is_enemy(_object)
{
	if (!object_exists(_object)) return false;
	var _parents = [o_enemy_units, o_holy_tower, o_house, o_wall_enemy, o_shrine];
	var _count = array_length(_parents);
	for (var _index = 0; _index < _count; ++_index)
	{
		var _parent = _parents[_index];
		if (_object == _parent || object_is_ancestor(_object, _parent)) return true;
	}
	return false;
}
