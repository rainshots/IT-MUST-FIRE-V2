// Inherit house durability, enemy spawning, damage handling, and destruction cleanup.
event_inherited();

// Each destroyed vault grants its charges once, including when the regular queue is full.
holy_shower_reward_charges = 3;
holy_shower_reward_granted = false;
tooltip_lines = [
	"Spawns enemy units.",
	"Destroy to gain " + string(holy_shower_reward_charges) + " Holy Shower charges."
];

house_destruction_reward = function()
{
	if (holy_shower_reward_granted || !instance_exists(o_game_controller))
	{
		return;
	}
	var _controller = instance_find(o_game_controller, 0);
	holy_shower_reward_granted = true;
	for (var _charge_index = 0; _charge_index < holy_shower_reward_charges; ++_charge_index)
	{
		_controller.cannon_projectile_queue_add(PROJECTILE_TYPE.HOLY_SHOWER, noone, true);
	}
};
