/// @description Unlocks nighttime aiming once per run without altering charges or their morning recovery.
function day_event_shell_factory_look_night_execute(_event, _assigned_cultists, _data)
{
	if (!instance_exists(o_cannon) || !cannon_shot_is_available(PROJECTILE_TYPE.LOOK_OVER_THERE)
		|| !is_struct(_event) || !variable_struct_exists(_event, "source_building")
		|| !instance_exists(_event.source_building) || _event.source_building.object_index != o_shell_factory)
	{
		return false;
	}
	var _cannon = instance_find(o_cannon, 0);
	if (_cannon.look_over_there_night_unlocked)
	{
		return false;
	}
	_cannon.look_over_there_night_unlocked = true;
	day_event_cultist_hp_cost_apply(_assigned_cultists, _data.hp_cost);
	return true;
}
