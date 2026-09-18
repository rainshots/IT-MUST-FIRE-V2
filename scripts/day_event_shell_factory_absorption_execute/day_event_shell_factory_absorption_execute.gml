/// @description Applies one valid Absorption upgrade and pays the standard Factory enchantment cost.
function day_event_shell_factory_absorption_execute(_event, _assigned_cultists, _data)
{
	if (!instance_exists(o_cannon) || !cannon_shot_is_available(PROJECTILE_TYPE.ABSORPTION)
		|| !is_struct(_event) || !variable_struct_exists(_event, "source_building")
		|| !instance_exists(_event.source_building) || _event.source_building.object_index != o_shell_factory
		|| !variable_struct_exists(_event, "unit_choice_options") || !is_array(_event.unit_choice_options)
		|| !variable_struct_exists(_event, "selected_unit_choice_index"))
	{
		return false;
	}
	var _cannon = instance_find(o_cannon, 0);
	var _choice_index = floor(_event.selected_unit_choice_index);
	if (_cannon.absorption_upgrade != ABSORPTION_UPGRADE.NONE
		|| _choice_index < 0 || _choice_index >= array_length(_event.unit_choice_options))
	{
		return false;
	}
	var _choice = _event.unit_choice_options[_choice_index];
	if (!is_struct(_choice) || !variable_struct_exists(_choice, "shell_enchantment")
		|| (_choice.shell_enchantment != ABSORPTION_UPGRADE.HEALING
			&& _choice.shell_enchantment != ABSORPTION_UPGRADE.COOLDOWN))
	{
		return false;
	}
	_cannon.absorption_upgrade = _choice.shell_enchantment;
	day_event_cultist_hp_cost_apply(_assigned_cultists, _data.hp_cost);
	return true;
}
