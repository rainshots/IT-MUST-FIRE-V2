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
building_tooltip_description = "Expands the settlement and improves cannon Taint, corpse revival, and special projectile payloads.";
building_upgrade_levels = array_create(CANNON_UPGRADE.COUNT, 0);
building_upgrade_names = [
	"Settlement Expansion",
	"Tainted Ground",
	"Morning Rising",
	"Payload Mastery"
];
building_upgrade_costs = [
	BALANCE_CANNON_UPGRADE_COST_LEVEL_1,
	BALANCE_CANNON_UPGRADE_COST_LEVEL_1,
	BALANCE_CANNON_UPGRADE_COST_LEVEL_1,
	BALANCE_CANNON_UPGRADE_COST_LEVEL_1
];

// Settlement expansion levels unlock the hidden building slots placed around the cannon.
settlement_expansion_slots_by_level = [
	[
		{ slot_x: 7268, slot_y: 7224 },
		{ slot_x: 8447, slot_y: 7234 },
		{ slot_x: 8619, slot_y: 8022 },
		{ slot_x: 7200, slot_y: 8000 },
		{ slot_x: 7892, slot_y: 8252 }
	],
	[
		{ slot_x: 7025, slot_y: 7607 },
		{ slot_x: 8680, slot_y: 7596 },
		{ slot_x: 7510, slot_y: 8207 },
		{ slot_x: 8324, slot_y: 8197 }
	]
];
settlement_expansion_slot_layer_name = "Instances";

// Settlement wall graphics are runtime-created so upgrades can swap editor asset variants.
settlement_expansion_visual_layer_name = "Assets_1";
settlement_expansion_visual_element = noone;
settlement_expansion_visuals = [
	{
		visual_x: 7865.34,
		visual_y: 7595,
		visual_scale_x: 1.32,
		visual_scale_y: 1.7
	},
	{
		visual_x: 7867,
		visual_y: 7613,
		visual_scale_x: 1.55,
		visual_scale_y: 2
	},
	{
		visual_x: 7865,
		visual_y: 7601,
		visual_scale_x: 1.8,
		visual_scale_y: 2.25
	}
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
agony_radial_bomb_count = BALANCE_CANNON_AGONY_RADIAL_BOMB_COUNT;
agony_radial_bomb_radius = BALANCE_CANNON_AGONY_RADIAL_BOMB_RADIUS;
agony_radial_bomb_jitter = BALANCE_CANNON_AGONY_RADIAL_BOMB_JITTER;
agony_enemy_bomb_count = BALANCE_CANNON_AGONY_ENEMY_BOMB_COUNT;
agony_enemy_skeleton_count = BALANCE_CANNON_AGONY_ENEMY_SKELETON_COUNT;
agony_enemy_target_jitter = BALANCE_CANNON_AGONY_ENEMY_TARGET_JITTER;
agony_launch_time = BALANCE_CANNON_AGONY_LAUNCH_TIME;

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

cannon_agony_projectile_create = function(_target_x, _target_y, _projectile_type, _launch_delay_seconds)
{
	var _projectile_x = x;
	var _projectile_y = y + projectile_spawn_offset_y;
	var _projectile = instance_create_layer(_projectile_x, _projectile_y, projectile_layer_name, o_projectile);
	var _projectile_distance = point_distance(_projectile_x, _projectile_y, _target_x, _target_y);
	var _flight_time_seconds = clamp(
		_projectile_distance / _projectile.projectile_speed,
		_projectile.minimum_flight_time,
		_projectile.maximum_flight_time
	);

	_projectile.start_x = _projectile_x;
	_projectile.start_y = _projectile_y;
	_projectile.target_x = _target_x;
	_projectile.target_y = _target_y;
	_projectile.projectile_type = _projectile_type;
	_projectile.ignore_pause = global.pause;
	_projectile.launch_delay_timer = _launch_delay_seconds * room_speed;
	_projectile.flight_time = _flight_time_seconds * room_speed;

	if (_projectile_type == PROJECTILE_TYPE.BOMB)
	{
		_projectile.effect_radius = BALANCE_PROJECTILE_BOMB_RADIUS;
		_projectile.damage_amount = cannon_projectile_bomb_damage_get();
	}
	else if (_projectile_type == PROJECTILE_TYPE.SKELETONS)
	{
		_projectile.effect_radius = BALANCE_PROJECTILE_SKELETON_RADIUS;
		_projectile.summon_count = cannon_projectile_skeleton_count_get();
	}

	return _projectile;
};

cannon_alive_enemy_targets_get = function()
{
	var _targets = [];
	var _enemy_count = instance_number(o_enemy_units);

	for (var _enemy_index = 0; _enemy_index < _enemy_count; ++_enemy_index)
	{
		var _enemy = instance_find(o_enemy_units, _enemy_index);

		if (!instance_exists(_enemy)
			|| (variable_instance_exists(_enemy, "hp") && _enemy.hp <= 0))
		{
			continue;
		}

		array_push(_targets, _enemy);
	}

	return _targets;
};

cannon_agony_radial_bomb_volley_fire = function()
{
	var _angle_offset = random(360);
	var _safe_count = max(1, agony_radial_bomb_count);

	for (var _bomb_index = 0; _bomb_index < agony_radial_bomb_count; ++_bomb_index)
	{
		var _direction = _angle_offset + (360 * (_bomb_index / _safe_count));
		var _distance_offset = random_range(-agony_radial_bomb_jitter, agony_radial_bomb_jitter);
		var _distance = max(0, agony_radial_bomb_radius + _distance_offset);
		var _target_x = x + lengthdir_x(_distance, _direction);
		var _target_y = y + lengthdir_y(_distance, _direction);
		var _launch_delay_seconds = random(agony_launch_time);

		cannon_agony_projectile_create(_target_x, _target_y, PROJECTILE_TYPE.BOMB, _launch_delay_seconds);
	}
};

cannon_agony_enemy_volley_fire = function(_projectile_type, _projectile_count)
{
	var _enemy_targets = cannon_alive_enemy_targets_get();
	var _enemy_count = array_length(_enemy_targets);

	if (_enemy_count <= 0)
	{
		return;
	}

	for (var _projectile_index = 0; _projectile_index < _projectile_count; ++_projectile_index)
	{
		var _enemy = _enemy_targets[_projectile_index mod _enemy_count];

		if (!instance_exists(_enemy))
		{
			continue;
		}

		var _target_direction = random(360);
		var _target_distance = sqrt(random(1)) * agony_enemy_target_jitter;
		var _target_x = _enemy.x + lengthdir_x(_target_distance, _target_direction);
		var _target_y = _enemy.y + lengthdir_y(_target_distance, _target_direction);
		var _launch_delay_seconds = random(agony_launch_time);

		cannon_agony_projectile_create(_target_x, _target_y, _projectile_type, _launch_delay_seconds);
	}
};

cannon_agony_projectile_volley_fire = function()
{
	if (agony_radial_bomb_count > 0)
	{
		cannon_agony_radial_bomb_volley_fire();
	}

	if (agony_enemy_bomb_count > 0)
	{
		cannon_agony_enemy_volley_fire(PROJECTILE_TYPE.BOMB, agony_enemy_bomb_count);
	}

	if (agony_enemy_skeleton_count > 0)
	{
		cannon_agony_enemy_volley_fire(PROJECTILE_TYPE.SKELETONS, agony_enemy_skeleton_count);
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
		cannon_agony_projectile_volley_fire();
	}

	night_damage_agony_threshold_index = _current_threshold_index;
};

unit_damage_receive = function(_damage_amount, _source_faction = UNIT_FACTION.NOONE, _is_critical = false, _can_trigger_soul_chain = true, _source_instance = noone)
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

cannon_upgrade_level_max_get = function(_upgrade_index)
{
	if (_upgrade_index == CANNON_UPGRADE.SETTLEMENT_EXPANSION)
	{
		return 2;
	}

	return BALANCE_CANNON_UPGRADE_LEVEL_MAX;
};

settlement_expansion_slot_exists = function(_slot_x, _slot_y)
{
	var _slot_count = instance_number(o_building_slot);

	for (var _slot_index = 0; _slot_index < _slot_count; ++_slot_index)
	{
		var _slot = instance_find(o_building_slot, _slot_index);

		if (instance_exists(_slot)
			&& point_distance(_slot.x, _slot.y, _slot_x, _slot_y) <= 1)
		{
			return true;
		}
	}

	return false;
};

settlement_expansion_position_has_building = function(_slot_x, _slot_y)
{
	var _building_count = instance_number(o_v13buildings_parent);

	for (var _building_index = 0; _building_index < _building_count; ++_building_index)
	{
		var _building = instance_find(o_v13buildings_parent, _building_index);

		if (instance_exists(_building)
			&& point_distance(_building.x, _building.y, _slot_x, _slot_y) <= 1)
		{
			return true;
		}
	}

	return false;
};

settlement_expansion_slot_create = function(_slot_data)
{
	if (!is_struct(_slot_data)
		|| !variable_struct_exists(_slot_data, "slot_x")
		|| !variable_struct_exists(_slot_data, "slot_y"))
	{
		return noone;
	}

	var _slot_x = _slot_data.slot_x;
	var _slot_y = _slot_data.slot_y;

	if (settlement_expansion_slot_exists(_slot_x, _slot_y)
		|| settlement_expansion_position_has_building(_slot_x, _slot_y))
	{
		return noone;
	}

	return instance_create_layer(_slot_x, _slot_y, settlement_expansion_slot_layer_name, o_building_slot);
};

settlement_expansion_slots_unlock = function(_target_level)
{
	var _level_count = min(_target_level, array_length(settlement_expansion_slots_by_level));

	for (var _level_index = 0; _level_index < _level_count; ++_level_index)
	{
		var _slots = settlement_expansion_slots_by_level[_level_index];
		var _slot_count = array_length(_slots);

		for (var _slot_index = 0; _slot_index < _slot_count; ++_slot_index)
		{
			settlement_expansion_slot_create(_slots[_slot_index]);
		}
	}
};

settlement_expansion_visual_update = function()
{
	var _visual_level = clamp(building_upgrade_levels[CANNON_UPGRADE.SETTLEMENT_EXPANSION], 0, array_length(settlement_expansion_visuals) - 1);
	var _visual_data = settlement_expansion_visuals[_visual_level];
	var _layer_id = layer_get_id(settlement_expansion_visual_layer_name);

	if (_layer_id == -1)
	{
		return;
	}

	if (settlement_expansion_visual_element != noone)
	{
		layer_sprite_destroy(settlement_expansion_visual_element);
		settlement_expansion_visual_element = noone;
	}

	settlement_expansion_visual_element = layer_sprite_create(_layer_id, _visual_data.visual_x, _visual_data.visual_y, s_wall2);
	layer_sprite_xscale(settlement_expansion_visual_element, _visual_data.visual_scale_x);
	layer_sprite_yscale(settlement_expansion_visual_element, _visual_data.visual_scale_y);
};

cannon_upgrade_display_level_get = function(_upgrade_index)
{
	if (_upgrade_index == CANNON_UPGRADE.PAYLOAD_MASTERY)
	{
		return building_upgrade_levels[_upgrade_index] + 1;
	}

	return building_upgrade_levels[_upgrade_index];
};

cannon_upgrade_next_display_level_get = function(_upgrade_index)
{
	if (_upgrade_index == CANNON_UPGRADE.PAYLOAD_MASTERY)
	{
		return min(building_upgrade_levels[_upgrade_index] + 2, 4);
	}

	return building_upgrade_levels[_upgrade_index] + 1;
};

cannon_upgrade_display_level_max_get = function(_upgrade_index)
{
	if (_upgrade_index == CANNON_UPGRADE.PAYLOAD_MASTERY)
	{
		return 4;
	}

	return cannon_upgrade_level_max_get(_upgrade_index);
};

cannon_upgrade_resource_get = function(_upgrade_index)
{
	if (_upgrade_index == CANNON_UPGRADE.MORNING_SKELETONS)
	{
		return RESOURCES.SOULS;
	}

	return RESOURCES.FLESH;
};

resource_name_get = function(_resource)
{
	if (_resource == RESOURCES.FLESH)
	{
		return "Flesh";
	}
	else if (_resource == RESOURCES.SOULS)
	{
		return "Souls";
	}
	else if (_resource == RESOURCES.IRON)
	{
		return "Iron";
	}
	else if (_resource == RESOURCES.IHOR)
	{
		return "Ihor";
	}

	return "Resource";
};

resource_color_get = function(_resource)
{
	if (_resource == RESOURCES.FLESH)
	{
		return COLOR_HUD_FLESH;
	}
	else if (_resource == RESOURCES.SOULS)
	{
		return COLOR_HUD_SOULS;
	}
	else if (_resource == RESOURCES.IRON)
	{
		return COLOR_HUD_IRON;
	}
	else if (_resource == RESOURCES.IHOR)
	{
		return COLOR_HUD_IHOR;
	}

	return COLOR_HUD_TEXT;
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

cannon_upgrade_costs_get = function(_upgrade_index)
{
	var _upgrade_cost = cannon_upgrade_next_cost_get(_upgrade_index);

	if (_upgrade_index == CANNON_UPGRADE.SETTLEMENT_EXPANSION)
	{
		var _level = building_upgrade_levels[_upgrade_index];

		if (_level <= 0)
		{
			_upgrade_cost = BALANCE_SETTLEMENT_EXPANSION_LEVEL_1_COST;
		}
		else
		{
			_upgrade_cost = BALANCE_SETTLEMENT_EXPANSION_LEVEL_2_COST;
		}

		return [
			{
				resource: RESOURCES.FLESH,
				cost: _upgrade_cost
			},
			{
				resource: RESOURCES.SOULS,
				cost: _upgrade_cost
			},
			{
				resource: RESOURCES.IRON,
				cost: _upgrade_cost
			}
		];
	}

	return [
		{
			resource: cannon_upgrade_resource_get(_upgrade_index),
			cost: _upgrade_cost
		}
	];
};

cannon_upgrade_cost_text_get = function(_upgrade_index)
{
	var _costs = cannon_upgrade_costs_get(_upgrade_index);
	var _cost_count = array_length(_costs);
	var _cost_text = "";

	for (var _cost_index = 0; _cost_index < _cost_count; ++_cost_index)
	{
		var _cost_data = _costs[_cost_index];

		if (_cost_index > 0)
		{
			_cost_text += ", ";
		}

		_cost_text += string(_cost_data.cost) + " " + resource_name_get(_cost_data.resource);
	}

	return _cost_text;
};

cannon_upgrade_missing_cost_get = function(_upgrade_index)
{
	var _costs = cannon_upgrade_costs_get(_upgrade_index);
	var _cost_count = array_length(_costs);

	for (var _cost_index = 0; _cost_index < _cost_count; ++_cost_index)
	{
		var _cost_data = _costs[_cost_index];

		if (global.resources[_cost_data.resource] < _cost_data.cost)
		{
			return _cost_data;
		}
	}

	return noone;
};

cannon_upgrade_costs_pay = function(_upgrade_index)
{
	var _costs = cannon_upgrade_costs_get(_upgrade_index);
	var _cost_count = array_length(_costs);
	var _popup_gap = 46;
	var _popup_start_x = x - ((_cost_count - 1) * _popup_gap * 0.5);

	for (var _cost_index = 0; _cost_index < _cost_count; ++_cost_index)
	{
		var _cost_data = _costs[_cost_index];
		var _cost_popup_x = _popup_start_x + (_cost_index * _popup_gap);

		global.resources[_cost_data.resource] -= _cost_data.cost;
		resource_popup_create(_cost_popup_x, y - upgrade_prompt_offset_y, _cost_data.resource, -_cost_data.cost);
	}
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

	return BALANCE_CANNON_CORRUPTED_GROUND_DAMAGE_BASE;
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

cannon_feast_radius_get = function()
{
	return round(BALANCE_CANNON_FEAST_RADIUS * cannon_payload_mastery_taint_multiplier_get());
};

cannon_feast_projectile_count_get = function()
{
	return max(1, ceil(BALANCE_CANNON_FEAST_PROJECTILE_COUNT * cannon_payload_mastery_taint_multiplier_get()));
};

cannon_feast_projectile_visual_radius_get = function()
{
	return round(BALANCE_CANNON_FEAST_PROJECTILE_VISUAL_RADIUS * cannon_payload_mastery_taint_multiplier_get());
};

cannon_feast_projectile_corruption_radius_get = function()
{
	return round(BALANCE_CANNON_FEAST_PROJECTILE_CORRUPTION_RADIUS * cannon_payload_mastery_taint_multiplier_get());
};

cannon_payload_upgrade_level_get = function()
{
	return building_upgrade_levels[CANNON_UPGRADE.PAYLOAD_MASTERY];
};

cannon_payload_mastery_taint_multiplier_get = function()
{
	var _level = cannon_payload_upgrade_level_get();
	return 1 + (_level * BALANCE_CANNON_PAYLOAD_MASTERY_TAINT_BONUS_PER_LEVEL);
};

cannon_projectile_bomb_damage_get = function()
{
	var _level = cannon_payload_upgrade_level_get();

	if (_level >= 3)
	{
		return BALANCE_PROJECTILE_BOMB_DAMAGE_AMOUNT_LEVEL_4;
	}
	else if (_level == 2)
	{
		return BALANCE_PROJECTILE_BOMB_DAMAGE_AMOUNT_LEVEL_3;
	}
	else if (_level == 1)
	{
		return BALANCE_PROJECTILE_BOMB_DAMAGE_AMOUNT_LEVEL_2;
	}

	return BALANCE_PROJECTILE_BOMB_DAMAGE_AMOUNT;
};

cannon_projectile_skeleton_count_get = function()
{
	var _level = cannon_payload_upgrade_level_get();

	if (_level >= 3)
	{
		return BALANCE_PROJECTILE_SKELETON_COUNT_LEVEL_4;
	}
	else if (_level == 2)
	{
		return BALANCE_PROJECTILE_SKELETON_COUNT_LEVEL_3;
	}
	else if (_level == 1)
	{
		return BALANCE_PROJECTILE_SKELETON_COUNT_LEVEL_2;
	}

	return BALANCE_PROJECTILE_SKELETON_COUNT;
};

cannon_projectile_heal_amount_get = function()
{
	var _level = cannon_payload_upgrade_level_get();

	if (_level >= 3)
	{
		return BALANCE_PROJECTILE_HEAL_AMOUNT_LEVEL_4;
	}
	else if (_level == 2)
	{
		return BALANCE_PROJECTILE_HEAL_AMOUNT_LEVEL_3;
	}
	else if (_level == 1)
	{
		return BALANCE_PROJECTILE_HEAL_AMOUNT_LEVEL_2;
	}

	return BALANCE_PROJECTILE_HEAL_AMOUNT;
};

building_upgrade_description_get = function(_upgrade_index)
{
	var _level = building_upgrade_levels[_upgrade_index];
	var _next_level = min(_level + 1, cannon_upgrade_level_max_get(_upgrade_index));

	if (_upgrade_index == CANNON_UPGRADE.CORRUPTED_GROUND_DAMAGE)
	{
		var _damage = BALANCE_CANNON_CORRUPTED_GROUND_DAMAGE_BASE;

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

		return "Enemies on tainted ground always take " + string(BALANCE_CANNON_CORRUPTED_GROUND_DAMAGE_BASE)
			+ " damage/sec. Upgrade: " + string(_damage) + " damage/sec.";
	}
	else if (_upgrade_index == CANNON_UPGRADE.SETTLEMENT_EXPANSION)
	{
		var _slot_count = 5;

		if (_next_level >= 2)
		{
			_slot_count = 4;
		}

		return "Unlocks " + string(_slot_count) + " new building summon slots around the settlement.";
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
	else if (_upgrade_index == CANNON_UPGRADE.PAYLOAD_MASTERY)
	{
		var _payload_level = min(_level + 2, 4);
		var _bomb_damage = BALANCE_PROJECTILE_BOMB_DAMAGE_AMOUNT;
		var _skeleton_count = BALANCE_PROJECTILE_SKELETON_COUNT;
		var _heal_amount = BALANCE_PROJECTILE_HEAL_AMOUNT;
		var _taint_bonus_percent = round(BALANCE_CANNON_PAYLOAD_MASTERY_TAINT_BONUS_PER_LEVEL * 100 * (_level + 1));

		if (_payload_level >= 4)
		{
			_bomb_damage = BALANCE_PROJECTILE_BOMB_DAMAGE_AMOUNT_LEVEL_4;
			_skeleton_count = BALANCE_PROJECTILE_SKELETON_COUNT_LEVEL_4;
			_heal_amount = BALANCE_PROJECTILE_HEAL_AMOUNT_LEVEL_4;
		}
		else if (_payload_level == 3)
		{
			_bomb_damage = BALANCE_PROJECTILE_BOMB_DAMAGE_AMOUNT_LEVEL_3;
			_skeleton_count = BALANCE_PROJECTILE_SKELETON_COUNT_LEVEL_3;
			_heal_amount = BALANCE_PROJECTILE_HEAL_AMOUNT_LEVEL_3;
		}
		else if (_payload_level == 2)
		{
			_bomb_damage = BALANCE_PROJECTILE_BOMB_DAMAGE_AMOUNT_LEVEL_2;
			_skeleton_count = BALANCE_PROJECTILE_SKELETON_COUNT_LEVEL_2;
			_heal_amount = BALANCE_PROJECTILE_HEAL_AMOUNT_LEVEL_2;
		}

		return "Bomb " + string(_bomb_damage) + " damage, Skeletons x" + string(_skeleton_count) + ", Heal " + string(_heal_amount) + " HP, Taint +" + string(_taint_bonus_percent) + "% radius and impacts.";
	}

	return "";
};

building_upgrade_can_buy = function(_upgrade_index)
{
	if (_upgrade_index < 0 || _upgrade_index >= array_length(building_upgrade_levels))
	{
		return false;
	}

	return building_upgrade_levels[_upgrade_index] < cannon_upgrade_level_max_get(_upgrade_index)
		&& cannon_upgrade_missing_cost_get(_upgrade_index) == noone;
};

building_upgrade_buy = function(_upgrade_index)
{
	if (_upgrade_index < 0 || _upgrade_index >= array_length(building_upgrade_levels))
	{
		return false;
	}

	if (!building_upgrade_can_buy(_upgrade_index))
	{
		if (building_upgrade_levels[_upgrade_index] < cannon_upgrade_level_max_get(_upgrade_index))
		{
			var _missing_cost = cannon_upgrade_missing_cost_get(_upgrade_index);

			if (is_struct(_missing_cost))
			{
				building_warning_show("Need " + string(_missing_cost.cost) + " " + resource_name_get(_missing_cost.resource), COLOR_STATUS_NEGATIVE_RED);
			}
		}

		return false;
	}

	cannon_upgrade_costs_pay(_upgrade_index);
	building_upgrade_levels[_upgrade_index]++;
	building_upgrade_costs[_upgrade_index] = cannon_upgrade_next_cost_get(_upgrade_index);

	if (_upgrade_index == CANNON_UPGRADE.SETTLEMENT_EXPANSION)
	{
		settlement_expansion_slots_unlock(building_upgrade_levels[_upgrade_index]);
		settlement_expansion_visual_update();
	}

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

settlement_expansion_visual_update();
