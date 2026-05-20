// Initialize shared map object state.
event_inherited();

// Upgraded graveyard durability.
max_hp = 100;
hp = max_hp;
max_corruption = 100;
corruption = max_corruption;

// Upgraded graveyard projectile reactions.
on_damage_projectile_hit = function()
{
	var _souls_reward = 2;

	global.resources[RESOURCES.SOULS] += _souls_reward;
};

on_corruption_projectile_hit = function()
{
	var _souls_reward = 2;

	global.resources[RESOURCES.SOULS] += _souls_reward;
};

on_summon_projectile_hit = function()
{
	var _skeleton_count = 8;
	var _spawn_radius = 64;

	for (var _skeleton_index = 0; _skeleton_index < _skeleton_count; ++_skeleton_index)
	{
		var _spawn_direction = random(360);
		var _spawn_distance = random(_spawn_radius);
		var _spawn_x = x + lengthdir_x(_spawn_distance, _spawn_direction);
		var _spawn_y = y + lengthdir_y(_spawn_distance, _spawn_direction);

		instance_create_layer(_spawn_x, _spawn_y, "Instances", o_skeleton);
	}
};
