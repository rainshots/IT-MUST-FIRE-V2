// Initialize shared map object state.
event_inherited();

// Cursed town durability.
max_hp = 100;
hp = max_hp;
max_corruption = 100;
corruption = max_corruption;

// Cursed town corrupts nearby ground when it appears.
spawn_corruption_radius_in_cells = 3;
spawn_corruption_radius = spawn_corruption_radius_in_cells * 100;
spawn_corruption_amount = 1;
corrupt_circle(x, y, spawn_corruption_radius, spawn_corruption_amount);

// Tooltip lines describe projectile reactions for player targeting.
tooltip_lines = [
	"Damage: -20 HP, +3 Souls, Graveyard at 0 HP",
	"Corruption: +3 Souls",
	"Summon: +3 Flesh"
];

// Cursed town projectile reactions.
on_damage_projectile_hit = function()
{
	var _damage_amount = 20;
	var _souls_reward = 3;

	hp = max(hp - _damage_amount, 0);
	global.resources[RESOURCES.SOULS] += _souls_reward;
	resource_popup_create(x, y - bar_offset_y, RESOURCES.SOULS, _souls_reward);

	if (hp <= 0)
	{
		transform_into(o_graveyard);
	}
};

on_corruption_projectile_hit = function()
{
	var _souls_reward = 3;

	global.resources[RESOURCES.SOULS] += _souls_reward;
	resource_popup_create(x, y - bar_offset_y, RESOURCES.SOULS, _souls_reward);
};

on_summon_projectile_hit = function()
{
	var _flesh_reward = 3;

	global.resources[RESOURCES.FLESH] += _flesh_reward;
	resource_popup_create(x, y - bar_offset_y, RESOURCES.FLESH, _flesh_reward);
};
