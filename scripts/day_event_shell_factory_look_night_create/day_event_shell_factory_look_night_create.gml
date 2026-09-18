/// @description Offers CANNON_2 a permanent nighttime unlock for Look Over There without granting charges.
/// @param {Id.Instance} _shell_factory Factory offering the Rite.
function day_event_shell_factory_look_night_create(_shell_factory)
{
	if (!instance_exists(_shell_factory) || _shell_factory.object_index != o_shell_factory
		|| !instance_exists(o_cannon) || !cannon_shot_is_available(PROJECTILE_TYPE.LOOK_OVER_THERE))
	{
		return noone;
	}
	var _cannon = instance_find(o_cannon, 0);
	if (_cannon.look_over_there_night_unlocked)
	{
		return noone;
	}
	var _event = new day_event_constructor(
		"shell_factory_look_night_" + string(_shell_factory), "Look Over There: Night Watch",
		"Permanently allows Look Over There to be used at night. Shares its existing daily charges; this upgrade does not restore charges.",
		BALANCE_SHELL_FACTORY_UPGRADE_CULTIST_COUNT, 1,
		[new event_action_constructor("unlock_look_night", day_event_shell_factory_look_night_execute,
			{ hp_cost: BALANCE_SHELL_FACTORY_UPGRADE_CULTIST_HP_COST })]
	);
	_event.source_building = _shell_factory;
	_event.reroll_is_available = false;
	return _event;
}
