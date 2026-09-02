// Initialize shared map object state.
event_inherited();

// Iron mine durability.
max_hp = 1000;
hp = max_hp;
max_corruption = 100;
corruption = 0;

// Tooltip lines describe projectile reactions for player targeting.
tooltip_lines = [
	//"Damage: +3 Iron",
	"Taint: becomes tainted on tainted ground",
	"When tainted, produces iron every day",
	//"Summon: No effect yet"
];

give_iron_reward = function(_iron_reward)
{
	global.resources[RESOURCES.IRON] += _iron_reward;
	resource_popup_create(x, y - bar_offset_y, RESOURCES.IRON, _iron_reward);
};

spawn_gatherable_ore = function(_amount = BALANCE_GOLD_MINE_GATHERABLE_ORE_COUNT)
{
	var _spawned_ore = [];
	var _ore_count = max(0, floor(_amount));

	for (var _ore_index = 0; _ore_index < _ore_count; ++_ore_index)
	{
		var _direction = random(360);
		var _distance = random_range(10, 50);
		var _ore = instance_create_layer(
			x + lengthdir_x(_distance, _direction),
			y + lengthdir_y(_distance, _direction),
			"Instances",
			o_gatherable_ore
		);

		array_push(_spawned_ore, _ore);
	}

	return _spawned_ore;
};

is_on_corrupted_ground = function()
{
	if (!instance_exists(o_corruption_grid))
	{
		return false;
	}

	var _corruption_grid = instance_find(o_corruption_grid, 0);
	var _cell_x = clamp(floor(x / _corruption_grid.cell_size), 0, _corruption_grid.grid_width - 1);
	var _cell_y = clamp(floor(y / _corruption_grid.cell_size), 0, _corruption_grid.grid_height - 1);
	var _cell_saint = 0;
	var _cell_corruption = ds_grid_get(_corruption_grid.corruption_grid, _cell_x, _cell_y);

	if (variable_instance_exists(_corruption_grid, "saint_grid"))
	{
		_cell_saint = ds_grid_get(_corruption_grid.saint_grid, _cell_x, _cell_y);
	}

	return _cell_saint <= 0 && _cell_corruption > 0;
};

on_damage_projectile_hit = function()
{
	var _iron_reward = BALANCE_GOLD_MINE_DAMAGE_IRON_REWARD;

	give_iron_reward(_iron_reward);
};
