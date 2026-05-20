// Initialize shared map object state.
event_inherited();

// Cursed town durability.
max_hp = 100;
hp = max_hp;
max_corruption = 100;
corruption = max_corruption;

// Cursed town projectile reactions.
on_damage_projectile_hit = function()
{
	var _damage_amount = 20;
	var _souls_reward = 3;

	hp = max(hp - _damage_amount, 0);
	global.resources[RESOURCES.SOULS] += _souls_reward;

	if (hp <= 0)
	{
		transform_into(o_graveyard);
	}
};

on_corruption_projectile_hit = function()
{
	var _souls_reward = 3;

	global.resources[RESOURCES.SOULS] += _souls_reward;
};

on_summon_projectile_hit = function()
{
	var _cultists_reward = 3;

	global.resources[RESOURCES.CULTISTS] += _cultists_reward;
};
