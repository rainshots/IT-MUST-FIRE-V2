// Initialize shared map object state.
event_inherited();

// Town durability.
max_hp = 100;
hp = max_hp;
max_corruption = 100;
corruption = 0;

// Town projectile reactions.
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
	var _corruption_amount = 33;

	corruption = min(corruption + _corruption_amount, max_corruption);

	if (corruption >= max_corruption)
	{
		transform_into(o_town_cursed);
	}
};

on_summon_projectile_hit = function()
{
	var _cultists_reward = 2;

	global.resources[RESOURCES.CULTISTS] += _cultists_reward;
};
