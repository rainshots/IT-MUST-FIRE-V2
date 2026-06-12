// Cannon target selected by the player.
max_hp = BALANCE_CANNON_MAX_HP;
hp = max_hp;
global.cannon_fire_version = 0;
y_sort_enabled = true;

// Cannon accepts any number of daytime corpse haulers.
building_accepts_workers = true;
worker_cultists = [];
worker_max = 1000000;

// Cannon upgrade branches use the shared building upgrade window.
building_has_upgrades = true;
building_tooltip_description = "Improves cannon corruption, corpse revival, and Feast volleys.";
building_upgrade_levels = array_create(CANNON_UPGRADE.COUNT, 0);
building_upgrade_names = [
	"Blighted Ground",
	"Morning Rising",
	"Feast Barrage"
];
building_upgrade_costs = [
	BALANCE_CANNON_UPGRADE_COST_LEVEL_1,
	BALANCE_CANNON_UPGRADE_COST_LEVEL_1,
	BALANCE_CANNON_UPGRADE_COST_LEVEL_1
];
building_warning_show = function(_text, _color)
{
};

// Cannon health bar visual settings.
bar_width = 84;
bar_height = 7;
bar_offset_y = 58;
upgrade_prompt_text = "G - UPGRADE";
upgrade_prompt_offset_y = 82;
upgrade_prompt_padding_x = 7;
upgrade_prompt_padding_y = 4;
upgrade_prompt_background_alpha = 0.78;

target_exists = false;
target_x = x;
target_y = y;
target_projectile_type = PROJECTILE_TYPE.DAMAGE;
target_version = -1;

// Projectile settings passed to created projectile instances.
projectile_effect_radius = BALANCE_PROJECTILE_EFFECT_RADIUS;
volley_projectile_count = BALANCE_CANNON_VOLLEY_PROJECTILE_COUNT;
volley_spread_radius = BALANCE_CANNON_VOLLEY_SPREAD_RADIUS;
volley_launch_delay_min = BALANCE_CANNON_VOLLEY_LAUNCH_DELAY_MIN;
volley_launch_delay_max = BALANCE_CANNON_VOLLEY_LAUNCH_DELAY_MAX;
projectile_spawn_offset_y = -20;
projectile_layer_name = "Instances";

// Cannon starts with corrupted ground around it.
starting_corruption_radius_in_cells = BALANCE_CANNON_STARTING_CORRUPTION_RADIUS_IN_CELLS;
starting_corruption_radius = starting_corruption_radius_in_cells * BALANCE_GRID_CELL_SIZE;
starting_corruption_amount = BALANCE_CANNON_STARTING_CORRUPTION_AMOUNT;

corrupt_circle(x, y, starting_corruption_radius, starting_corruption_amount);

cannon_upgrade_next_cost_get = function(_upgrade_index)
{
	var _level = building_upgrade_levels[_upgrade_index];

	if (_level <= 0)
	{
		return BALANCE_CANNON_UPGRADE_COST_LEVEL_1;
	}
	else if (_level == 1)
	{
		return BALANCE_CANNON_UPGRADE_COST_LEVEL_2;
	}

	return BALANCE_CANNON_UPGRADE_COST_LEVEL_3;
};

cannon_corrupted_ground_damage_get = function()
{
	var _level = building_upgrade_levels[CANNON_UPGRADE.CORRUPTED_GROUND_DAMAGE];

	if (_level == 1)
	{
		return BALANCE_CANNON_CORRUPTED_GROUND_DAMAGE_LEVEL_1;
	}
	else if (_level == 2)
	{
		return BALANCE_CANNON_CORRUPTED_GROUND_DAMAGE_LEVEL_2;
	}
	else if (_level >= 3)
	{
		return BALANCE_CANNON_CORRUPTED_GROUND_DAMAGE_LEVEL_3;
	}

	return 0;
};

cannon_morning_skeleton_count_range_get = function()
{
	var _level = building_upgrade_levels[CANNON_UPGRADE.MORNING_SKELETONS];

	if (_level == 1)
	{
		return [BALANCE_CANNON_MORNING_SKELETONS_LEVEL_1_MIN, BALANCE_CANNON_MORNING_SKELETONS_LEVEL_1_MAX];
	}
	else if (_level == 2)
	{
		return [BALANCE_CANNON_MORNING_SKELETONS_LEVEL_2_MIN, BALANCE_CANNON_MORNING_SKELETONS_LEVEL_2_MAX];
	}
	else if (_level >= 3)
	{
		return [BALANCE_CANNON_MORNING_SKELETONS_LEVEL_3_MIN, BALANCE_CANNON_MORNING_SKELETONS_LEVEL_3_MAX];
	}

	return [0, 0];
};

cannon_feast_upgrade_multiplier_get = function()
{
	var _level = building_upgrade_levels[CANNON_UPGRADE.FEAST_VOLLEY];

	if (_level == 1)
	{
		return BALANCE_CANNON_FEAST_UPGRADE_LEVEL_1_MULTIPLIER;
	}
	else if (_level == 2)
	{
		return BALANCE_CANNON_FEAST_UPGRADE_LEVEL_2_MULTIPLIER;
	}
	else if (_level >= 3)
	{
		return BALANCE_CANNON_FEAST_UPGRADE_LEVEL_3_MULTIPLIER;
	}

	return 1;
};

cannon_feast_radius_get = function()
{
	return BALANCE_CANNON_FEAST_RADIUS * cannon_feast_upgrade_multiplier_get();
};

cannon_feast_projectile_count_get = function()
{
	return ceil(BALANCE_CANNON_FEAST_PROJECTILE_COUNT * cannon_feast_upgrade_multiplier_get());
};

building_upgrade_description_get = function(_upgrade_index)
{
	var _level = building_upgrade_levels[_upgrade_index];
	var _next_level = min(_level + 1, BALANCE_CANNON_UPGRADE_LEVEL_MAX);

	if (_upgrade_index == CANNON_UPGRADE.CORRUPTED_GROUND_DAMAGE)
	{
		var _damage = 0;

		if (_next_level == 1)
		{
			_damage = BALANCE_CANNON_CORRUPTED_GROUND_DAMAGE_LEVEL_1;
		}
		else if (_next_level == 2)
		{
			_damage = BALANCE_CANNON_CORRUPTED_GROUND_DAMAGE_LEVEL_2;
		}
		else
		{
			_damage = BALANCE_CANNON_CORRUPTED_GROUND_DAMAGE_LEVEL_3;
		}

		return "Enemies on fully corrupted ground take " + string(_damage) + " damage/sec.";
	}
	else if (_upgrade_index == CANNON_UPGRADE.MORNING_SKELETONS)
	{
		var _range = [0, 0];

		if (_next_level == 1)
		{
			_range = [BALANCE_CANNON_MORNING_SKELETONS_LEVEL_1_MIN, BALANCE_CANNON_MORNING_SKELETONS_LEVEL_1_MAX];
		}
		else if (_next_level == 2)
		{
			_range = [BALANCE_CANNON_MORNING_SKELETONS_LEVEL_2_MIN, BALANCE_CANNON_MORNING_SKELETONS_LEVEL_2_MAX];
		}
		else
		{
			_range = [BALANCE_CANNON_MORNING_SKELETONS_LEVEL_3_MIN, BALANCE_CANNON_MORNING_SKELETONS_LEVEL_3_MAX];
		}

		return "At morning, corpses can rise as " + string(_range[0]) + "-" + string(_range[1]) + " Skeletons.";
	}
	else if (_upgrade_index == CANNON_UPGRADE.FEAST_VOLLEY)
	{
		var _multiplier = 1;

		if (_next_level == 1)
		{
			_multiplier = BALANCE_CANNON_FEAST_UPGRADE_LEVEL_1_MULTIPLIER;
		}
		else if (_next_level == 2)
		{
			_multiplier = BALANCE_CANNON_FEAST_UPGRADE_LEVEL_2_MULTIPLIER;
		}
		else
		{
			_multiplier = BALANCE_CANNON_FEAST_UPGRADE_LEVEL_3_MULTIPLIER;
		}

		return "Feast radius and shell count become " + string(round(_multiplier * 100)) + "%.";
	}

	return "";
};

building_upgrade_can_buy = function(_upgrade_index)
{
	if (_upgrade_index < 0 || _upgrade_index >= array_length(building_upgrade_levels))
	{
		return false;
	}

	return building_upgrade_levels[_upgrade_index] < BALANCE_CANNON_UPGRADE_LEVEL_MAX
		&& global.resources[RESOURCES.IRON] >= cannon_upgrade_next_cost_get(_upgrade_index);
};

building_upgrade_buy = function(_upgrade_index)
{
	if (_upgrade_index < 0 || _upgrade_index >= array_length(building_upgrade_levels))
	{
		return false;
	}

	if (!building_upgrade_can_buy(_upgrade_index))
	{
		if (building_upgrade_levels[_upgrade_index] < BALANCE_CANNON_UPGRADE_LEVEL_MAX)
		{
			building_warning_show("Need " + string(cannon_upgrade_next_cost_get(_upgrade_index)) + " Iron", COLOR_STATUS_NEGATIVE_RED);
		}

		return false;
	}

	var _upgrade_cost = cannon_upgrade_next_cost_get(_upgrade_index);
	global.resources[RESOURCES.IRON] -= _upgrade_cost;
	resource_popup_create(x, y - upgrade_prompt_offset_y, RESOURCES.IRON, -_upgrade_cost);
	building_upgrade_levels[_upgrade_index]++;
	building_upgrade_costs[_upgrade_index] = cannon_upgrade_next_cost_get(_upgrade_index);

	return true;
};
