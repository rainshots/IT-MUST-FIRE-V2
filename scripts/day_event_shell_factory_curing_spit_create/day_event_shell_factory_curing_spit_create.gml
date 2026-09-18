/// @description Offers CANNON_2 a once-per-run choice of permanent Curing Spit upgrade.
/// @param {Id.Instance} _shell_factory Factory offering the Rite.
function day_event_shell_factory_curing_spit_create(_shell_factory)
{
	if (!instance_exists(_shell_factory) || _shell_factory.object_index != o_shell_factory
		|| !instance_exists(o_cannon) || !cannon_shot_is_available(PROJECTILE_TYPE.CURING_SPIT))
	{
		return noone;
	}
	var _cannon = instance_find(o_cannon, 0);
	if (_cannon.curing_spit_upgrade != CURING_SPIT_UPGRADE.NONE)
	{
		return noone;
	}
	var _event = new day_event_constructor(
		"shell_factory_curing_spit_" + string(_shell_factory), "Curing Spit Upgrade",
		"Choose one permanent upgrade for Curing Spit: slow enemy attacks with Rotten Breath or raise Bonelets with Cure The Dead.",
		BALANCE_SHELL_FACTORY_ENCHANTMENT_CULTIST_COUNT, 1,
		[new event_action_constructor("upgrade_curing_spit", day_event_shell_factory_curing_spit_execute,
			{ hp_cost: BALANCE_SHELL_FACTORY_ENCHANTMENT_CULTIST_HP_COST })]
	);
	_event.source_building = _shell_factory;
	_event.unit_choice_options = [
		{
			title: "Rotten Breath", label: "Rotten Breath", icon_sprite: s_cannon_face,
			shell_enchantment: CURING_SPIT_UPGRADE.ROTTEN_BREATH,
			description: "Every pulse reduces enemy attack speed inside the Gaze by 50% for 5 seconds. Further pulses refresh the debuff."
		},
		{
			title: "Cure The Dead", label: "Cure The Dead", icon_sprite: s_cannon_face,
			shell_enchantment: CURING_SPIT_UPGRADE.CURE_THE_DEAD,
			description: "Every pulse raises one allied Bonelet at a random point inside the Gaze. Summoned Bonelets disappear at dawn."
		}
	];
	_event.selected_unit_choice_index = 0;
	_event.reroll_is_available = false;
	return _event;
}
