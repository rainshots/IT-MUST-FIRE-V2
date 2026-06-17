// Cannon target selected by the player.
max_hp = BALANCE_CANNON_MAX_HP;
hp = max_hp;
global.cannon_fire_version = 0;
y_sort_enabled = true;

// Night damage tracking plays agony sounds at each 10 percent damage threshold.
night_damage_start_hp = max_hp;
night_damage_agony_threshold_index = 0;
night_damage_agony_step_share = 0.1;

// Cannon accepts a small crew of daytime corpse haulers.
building_accepts_workers = true;
worker_cultists = [];
worker_max = BALANCE_RESOURCE_BUILDING_WORKER_MAX;

// Assigned cannon worker indicator is shown under the cannon once it has workers.
worker_indicator_label = "Cannon workers";
worker_indicator_offset_y = 30;
worker_indicator_padding_x = 8;
worker_indicator_padding_y = 5;
worker_indicator_line_gap = 16;
worker_indicator_icon_size = 20;
worker_indicator_icon_gap = 5;
worker_indicator_background_alpha = 0.78;

// Cannon upgrade branches use the shared building upgrade window.
building_has_upgrades = true;
building_tooltip_description = "Improves cannon Taint, corpse revival, and Taint Shell volleys.";
building_upgrade_levels = array_create(CANNON_UPGRADE.COUNT, 0);
building_upgrade_names = [
	"Tainted Ground",
	"Morning Rising",
	"Taint Barrage"
];
building_upgrade_costs = [
	BALANCE_CANNON_UPGRADE_COST_LEVEL_1,
	BALANCE_CANNON_UPGRADE_COST_LEVEL_1,
	BALANCE_CANNON_UPGRADE_COST_LEVEL_1
];
building_warning_show = function(_text, _color)
{
};

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

// Cannon fades when a worker is hidden by the upper part of its sprite.
hidden_worker_alpha = BALANCE_CANNON_HIDDEN_WORKER_ALPHA;
hidden_worker_front_offset_y = BALANCE_CANNON_HIDDEN_WORKER_FRONT_OFFSET_Y;
hauler_prompt_text = "Assign workers to the cannon to carry the corpses. \n(Drag any worker right on cannon)";
hauler_prompt_offset_y = BALANCE_CANNON_HAULER_PROMPT_OFFSET_Y;
hauler_prompt_padding_x = BALANCE_CANNON_HAULER_PROMPT_PADDING_X;
hauler_prompt_padding_y = BALANCE_CANNON_HAULER_PROMPT_PADDING_Y;
hauler_prompt_background_alpha = BALANCE_CANNON_HAULER_PROMPT_BACKGROUND_ALPHA;
hauler_prompt_shake_interval = BALANCE_CANNON_HAULER_PROMPT_SHAKE_INTERVAL;
hauler_prompt_shake_time = BALANCE_CANNON_HAULER_PROMPT_SHAKE_TIME;
hauler_prompt_shake_strength = BALANCE_CANNON_HAULER_PROMPT_SHAKE_STRENGTH;

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

cannon_damage_sound_play = function()
{
	if (variable_global_exists("cannon_damage_sounds") && variable_global_exists("sound_play_random"))
	{
		global.sound_play_random(global.cannon_damage_sounds);
	}
};

cannon_agony_sound_play = function()
{
	if (variable_global_exists("cannon_agony_sounds") && variable_global_exists("sound_play_random"))
	{
		global.sound_play_random(global.cannon_agony_sounds);
	}
};

cannon_night_damage_tracking_start = function()
{
	night_damage_start_hp = max(hp, 1);
	night_damage_agony_threshold_index = 0;
};

cannon_night_damage_agony_update = function()
{
	if (!variable_global_exists("day_phase")
		|| global.day_phase != DAY_PHASE.NIGHT
		|| night_damage_start_hp <= 0
		|| night_damage_agony_step_share <= 0)
	{
		return;
	}

	var _damage_share = clamp((night_damage_start_hp - hp) / night_damage_start_hp, 0, 1);
	var _current_threshold_index = floor(_damage_share / night_damage_agony_step_share);
	var _previous_threshold_index = night_damage_agony_threshold_index;

	if (_current_threshold_index <= _previous_threshold_index)
	{
		return;
	}

	for (var _threshold_index = _previous_threshold_index + 1; _threshold_index <= _current_threshold_index; ++_threshold_index)
	{
		cannon_agony_sound_play();
	}

	night_damage_agony_threshold_index = _current_threshold_index;
};

unit_damage_receive = function(_damage_amount, _source_faction = UNIT_FACTION.NOONE, _is_critical = false, _can_trigger_soul_chain = true)
{
	if (hp <= 0 || _damage_amount <= 0)
	{
		return 0;
	}

	var _applied_damage = min(_damage_amount, hp);
	hp = max(hp - _damage_amount, 0);

	if (_applied_damage > 0)
	{
		cannon_damage_sound_play();
		cannon_night_damage_agony_update();
	}

	return _applied_damage;
};

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

		return "Enemies on fully tainted ground take " + string(_damage) + " damage/sec.";
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

		return "Taint Shell radius and shell count become " + string(round(_multiplier * 100)) + "%.";
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

cannon_worker_is_behind_sprite = function(_worker)
{
	if (!instance_exists(_worker)
		|| (_worker.object_index != o_cultist && _worker.object_index != o_goblin)
		|| !variable_instance_exists(_worker, "hp")
		|| _worker.hp <= 0)
	{
		return false;
	}

	if ((variable_instance_exists(_worker, "cannon_loading") && _worker.cannon_loading)
		|| (variable_instance_exists(_worker, "cannon_loaded") && _worker.cannon_loaded))
	{
		return false;
	}

	return _worker.x >= bbox_left
		&& _worker.x <= bbox_right
		&& _worker.y >= bbox_top
		&& _worker.y <= y + hidden_worker_front_offset_y;
};

cannon_has_worker_behind_sprite = function()
{
	if (!variable_global_exists("cultists"))
	{
		return false;
	}

	var _cultist_count = array_length(global.cultists);

	for (var _cultist_index = 0; _cultist_index < _cultist_count; ++_cultist_index)
	{
		if (cannon_worker_is_behind_sprite(global.cultists[_cultist_index]))
		{
			return true;
		}
	}

	var _goblin_count = instance_number(o_goblin);

	for (var _goblin_index = 0; _goblin_index < _goblin_count; ++_goblin_index)
	{
		if (cannon_worker_is_behind_sprite(instance_find(o_goblin, _goblin_index)))
		{
			return true;
		}
	}

	return false;
};

cannon_assigned_worker_exists = function()
{
	var _worker_count = array_length(worker_cultists);

	for (var _worker_index = 0; _worker_index < _worker_count; ++_worker_index)
	{
		var _worker = worker_cultists[_worker_index];

		if (instance_exists(_worker)
			&& variable_instance_exists(_worker, "assigned_building")
			&& _worker.assigned_building == id
			&& variable_instance_exists(_worker, "hp")
			&& _worker.hp > 0)
		{
			return true;
		}
	}

	return false;
};

cannon_should_show_hauler_prompt = function()
{
	if (global.day_phase != DAY_PHASE.DAY
		|| !instance_exists(o_game_controller)
		|| cannon_assigned_worker_exists())
	{
		return false;
	}

	var _game_controller = instance_find(o_game_controller, 0);

	return variable_instance_exists(_game_controller, "night_attack_night_index")
		&& _game_controller.night_attack_night_index >= 2
		&& variable_instance_exists(_game_controller, "corpse_available_for_hauling_exists")
		&& _game_controller.corpse_available_for_hauling_exists();
};
