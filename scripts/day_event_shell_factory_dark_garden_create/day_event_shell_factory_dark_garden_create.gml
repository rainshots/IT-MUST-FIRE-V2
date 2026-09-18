/// @description Offers CANNON_2 a once-per-run choice of permanent Dark Garden upgrade.
/// @param {Id.Instance} _shell_factory Factory offering the Rite.
function day_event_shell_factory_dark_garden_create(_shell_factory)
{
	if (!instance_exists(_shell_factory) || _shell_factory.object_index != o_shell_factory
		|| !instance_exists(o_cannon) || !cannon_shot_is_available(PROJECTILE_TYPE.DARK_GARDEN))
	{
		return noone;
	}
	var _cannon = instance_find(o_cannon, 0);
	if (_cannon.dark_garden_upgrade != DARK_GARDEN_UPGRADE.NONE)
	{
		return noone;
	}
	var _event = new day_event_constructor(
		"shell_factory_dark_garden_" + string(_shell_factory), "Dark Garden Upgrade",
		"Choose one permanent upgrade for Dark Garden: grow additional seeds or corrupt the ground beneath surviving trees at dawn.",
		BALANCE_SHELL_FACTORY_ENCHANTMENT_CULTIST_COUNT, 1,
		[new event_action_constructor("upgrade_dark_garden", day_event_shell_factory_dark_garden_execute,
			{ hp_cost: BALANCE_SHELL_FACTORY_ENCHANTMENT_CULTIST_HP_COST })]
	);
	_event.source_building = _shell_factory;
	_event.unit_choice_options = [
		{
			title: "Spreading Roots", label: "Propagation", icon_sprite: s_cannon_face,
			shell_enchantment: DARK_GARDEN_UPGRADE.PROPAGATION,
			description: "Every 40 to 60 seconds, each mature tree has a 25% chance to plant a seed within 150 px. The seed grows after 60 seconds."
		},
		{
			title: "Tainted Roots", label: "Corruption", icon_sprite: s_cannon_face,
			shell_enchantment: DARK_GARDEN_UPGRADE.CORRUPTION,
			description: "Surviving trees add 25% corruption within 100 px of their roots at the end of the night, before disappearing."
		}
	];
	_event.selected_unit_choice_index = 0;
	_event.reroll_is_available = false;
	return _event;
}
