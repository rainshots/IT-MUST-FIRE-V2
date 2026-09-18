/// @description Offers CANNON_2 a once-per-run choice of permanent Absorption upgrade.
/// @param {Id.Instance} _shell_factory Factory offering the Rite.
function day_event_shell_factory_absorption_create(_shell_factory)
{
	if (!instance_exists(_shell_factory) || _shell_factory.object_index != o_shell_factory
		|| !instance_exists(o_cannon) || !cannon_shot_is_available(PROJECTILE_TYPE.ABSORPTION))
	{
		return noone;
	}
	var _cannon = instance_find(o_cannon, 0);
	if (_cannon.absorption_upgrade != ABSORPTION_UPGRADE.NONE)
	{
		return noone;
	}
	var _event = new day_event_constructor(
		"shell_factory_absorption_" + string(_shell_factory), "Absorption Upgrade",
		"Choose one permanent upgrade for Absorption: heal the Cannon or reduce its next cooldown per absorbed corpse.",
		BALANCE_SHELL_FACTORY_ENCHANTMENT_CULTIST_COUNT, 1,
		[new event_action_constructor("upgrade_absorption", day_event_shell_factory_absorption_execute,
			{ hp_cost: BALANCE_SHELL_FACTORY_ENCHANTMENT_CULTIST_HP_COST })]
	);
	_event.source_building = _shell_factory;
	_event.unit_choice_options = [
		{
			title: "Restorative Absorption", label: "Healing", icon_sprite: s_cannon_face,
			shell_enchantment: ABSORPTION_UPGRADE.HEALING,
			description: "Every absorbed enemy corpse also restores 1% of the Cannon's maximum HP."
		},
		{
			title: "Rapid Absorption", label: "Cooldown", icon_sprite: s_cannon_face,
			shell_enchantment: ABSORPTION_UPGRADE.COOLDOWN,
			description: "Every corpse absorbed in a use reduces the following cooldown by 10%, up to 100%."
		}
	];
	_event.selected_unit_choice_index = 0;
	_event.reroll_is_available = false;
	return _event;
}
