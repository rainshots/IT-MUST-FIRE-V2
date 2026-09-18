/// @description Offers CANNON_2 a once-per-run choice of permanent Quicksand Shot upgrade.
/// @param {Id.Instance} _shell_factory Factory offering the Rite.
function day_event_shell_factory_quicksand_create(_shell_factory)
{
	if (!instance_exists(_shell_factory) || _shell_factory.object_index != o_shell_factory
		|| !instance_exists(o_cannon) || !cannon_shot_is_available(PROJECTILE_TYPE.QUICKSAND))
	{
		return noone;
	}
	var _cannon = instance_find(o_cannon, 0);
	if (_cannon.quicksand_upgrade != QUICKSAND_UPGRADE.NONE)
	{
		return noone;
	}
	var _event = new day_event_constructor(
		"shell_factory_quicksand_" + string(_shell_factory), "Quicksand Shot Upgrade",
		"Choose one permanent upgrade for Quicksand Shot: devour enemies near the center or confuse enemies when the effect ends.",
		BALANCE_SHELL_FACTORY_ENCHANTMENT_CULTIST_COUNT, 1,
		[new event_action_constructor("upgrade_quicksand", day_event_shell_factory_quicksand_execute,
			{ hp_cost: BALANCE_SHELL_FACTORY_ENCHANTMENT_CULTIST_HP_COST })]
	);
	_event.source_building = _shell_factory;
	_event.unit_choice_options = [
		{
			title: "Devouring Quicksand", label: "Devour", icon_sprite: s_cannon_face,
			shell_enchantment: QUICKSAND_UPGRADE.DEVOUR,
			description: "When Quicksand ends, enemies within the inner 10% of the Gaze radius are swallowed and killed without leaving corpses."
		},
		{
			title: "Disorienting Quicksand", label: "Confusion", icon_sprite: s_cannon_face,
			shell_enchantment: QUICKSAND_UPGRADE.CONFUSION,
			description: "When Quicksand ends, enemies inside the Gaze walk in a random direction for 1 second at its edge, increasing to 5 seconds at its center."
		}
	];
	_event.selected_unit_choice_index = 0;
	_event.reroll_is_available = false;
	return _event;
}
