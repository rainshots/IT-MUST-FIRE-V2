// Initialize shared map object state.
event_inherited();

// Graveyard durability.
max_hp = 100;
hp = max_hp;
max_corruption = 100;
corruption = 0;

// Graveyard corrupts nearby ground when it appears.
spawn_corruption_radius_in_cells = 3;
spawn_corruption_radius = spawn_corruption_radius_in_cells * 100;
spawn_corruption_amount = 1;
corrupt_circle(x, y, spawn_corruption_radius, spawn_corruption_amount);

// Tooltip lines describe projectile reactions for player targeting.
tooltip_lines = [
	"Damage: +1 Soul",
	"Corruption: +33 Corruption, Graveyard Lv2 at max",
	"Summon: Create 5 Skeletons"
];

// Graveyard projectile reactions.
on_damage_projectile_hit = function()
{
	var _souls_reward = 1;

	global.resources[RESOURCES.SOULS] += _souls_reward;
	resource_popup_create(x, y - bar_offset_y, RESOURCES.SOULS, _souls_reward);
};

on_corruption_projectile_hit = function()
{
	var _corruption_amount = 33;

	corruption = min(corruption + _corruption_amount, max_corruption);

	if (corruption >= max_corruption)
	{
		transform_into(o_graveyard_lvl2);
	}
};

on_summon_projectile_hit = function()
{
	var _skeleton_count = 5;
	var _spawn_radius = 48;

	for (var _skeleton_index = 0; _skeleton_index < _skeleton_count; ++_skeleton_index)
	{
		var _spawn_direction = random(360);
		var _spawn_distance = random(_spawn_radius);
		var _spawn_x = x + lengthdir_x(_spawn_distance, _spawn_direction);
		var _spawn_y = y + lengthdir_y(_spawn_distance, _spawn_direction);

		instance_create_layer(_spawn_x, _spawn_y, "Instances", o_skeleton);
	}
};
