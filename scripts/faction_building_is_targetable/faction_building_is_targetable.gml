/// @description Tests whether a living opposing building can be a squad's strategic objective.
function faction_building_is_targetable(_faction, _target)
{
	if (!faction_target_is_hostile(_faction, _target) || _target.object_index == o_cannon) return false;
	if (!variable_instance_exists(_target, "hp") || _target.hp <= 0) return false;
	if (variable_instance_exists(_target, "is_attackable") && !_target.is_attackable) return false;
	if (variable_instance_exists(_target, "is_destroyed") && _target.is_destroyed) return false;
	return _target.object_index == o_v13buildings_parent
		|| object_is_ancestor(_target.object_index, o_v13buildings_parent)
		|| _target.object_index == o_map_objects_parent
		|| object_is_ancestor(_target.object_index, o_map_objects_parent);
}
