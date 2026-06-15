// Base production building state.
production_resource = noone;
production_resource_name = "";
production_resource_icon = noone;
production_resource_color = c_white;
production_bonus_stat = noone;
production_bonus_stat_name = "";
production_bonus_stat_color = COLOR_HUD_TEXT;
production_progress = 0;
production_duration = BALANCE_RESOURCE_BUILDING_PRODUCTION_TIME;
production_amount = BALANCE_RESOURCE_BUILDING_PRODUCTION_AMOUNT;
production_speed_multiplier = 0;
production_speed_upgrade_index = 0;
building_accepts_workers = false;
summon_unit_object = noone;
summon_resource = RESOURCES.SOULS;
summon_resource_name = "Souls";
summon_resource_icon = s_soul_icon;
summon_resource_color = COLOR_HUD_SOULS;
summon_resource_cost = 0;
summon_double_unit_chance = 0;
summon_extra_life_bonus = 0;
summon_progress = 0;
summon_duration = 0;
summon_has_paid_cost = false;
worker_cultists = array_create(0);
worker_max = BALANCE_RESOURCE_BUILDING_WORKER_MAX;
worker_stand_offset_y = 12;
worker_stand_spacing = 36;
y_sort_enabled = true;

// Resource warning shown by assigned cultists when this building cannot work.
missing_work_resource = noone;
missing_work_resource_name = "";
missing_work_resource_color = c_white;
building_warning_text = "";
building_warning_color = COLOR_STATUS_NEGATIVE_RED;
building_warning_timer = 0;
building_warning_time = 0.35 * room_speed;
building_warning_offset_y = 148;
building_warning_padding_x = 7;
building_warning_padding_y = 4;
building_warning_background_alpha = 0.84;

// Production bar visual settings.
production_bar_width = 62;
production_bar_height = 6;
production_bar_offset_y = 125;
production_bar_outline_alpha = 0.85;
production_bar_background_alpha = 0.72;
production_icon_size = 18;
production_icon_gap = 8;
production_multiplier_gap = 10;
assignment_preview_padding = 5;
assignment_preview_alpha = 0.22;
assignment_preview_outline_alpha = 0.95;
production_tooltip_padding = 8;
production_tooltip_line_height = 16;
production_tooltip_width = 270;
production_tooltip_offset_y = 148;
building_tooltip_title = "";
building_tooltip_description = "";
building_tooltip_detail = "";
building_tooltip_detail_color = COLOR_HUD_TEXT;
upgrade_prompt_text = "G - UPGRADE";
upgrade_prompt_offset_y = 24;
upgrade_prompt_padding_x = 7;
upgrade_prompt_padding_y = 4;
upgrade_prompt_background_alpha = 0.78;
demolish_prompt_text = "T - DEMOLISH";
demolish_prompt_offset_y = 50;
demolish_prompt_padding_x = 7;
demolish_prompt_padding_y = 4;
demolish_prompt_background_alpha = 0.78;
building_upgrade_flags = [false, false];
building_upgrade_names = ["", ""];
building_upgrade_descriptions = ["", ""];
building_upgrade_costs = [BALANCE_BUILDING_UPGRADE_IRON_COST, BALANCE_BUILDING_UPGRADE_IRON_COST];
building_has_upgrades = false;
secondary_effect_progress = 0;

// Meat Bath stores paid healing here so one Flesh restores a fixed amount over time.
meat_bath_heal_pool = 0;

// Ritual Circle stores base XP here before applying XP Gain to workers.
ritual_circle_exp_pool = 0;

// Workshop stores paid repair here before applying it to the cannon wall.
workshop_repair_pool = 0;

// Configure the first resource production buildings by object type.
if (object_index == o_slaughter_table)
{
	building_accepts_workers = true;
	production_resource = RESOURCES.FLESH;
	production_resource_name = "Flesh";
	production_resource_icon = s_flesh_icon;
	production_resource_color = COLOR_HUD_FLESH;
	production_bonus_stat = CULTIST_STAT.FERVOR;
	production_bonus_stat_name = "FERVOR";
	production_bonus_stat_color = COLOR_CULTIST_FERVOR;
	building_tooltip_title = "Production";
	building_tooltip_description = "Produces Flesh";
	building_tooltip_detail = "Bonus: " + production_bonus_stat_name + " +" + string(BALANCE_RESOURCE_BUILDING_STAT_SPEED_BONUS) + "x per point";
	building_tooltip_detail_color = production_bonus_stat_color;
	building_has_upgrades = true;
	building_upgrade_names[0] = "Faster Butchery";
	building_upgrade_descriptions[0] = "+0.5x Flesh production while staffed.";
	building_upgrade_names[1] = "Blood Poultice";
	building_upgrade_descriptions[1] = "Slowly heals workers for free.";
}
else if (object_index == o_quarry)
{
	building_accepts_workers = true;
	production_resource = RESOURCES.IRON;
	production_resource_name = "Iron";
	production_resource_icon = s_iron_icon;
	production_resource_color = COLOR_HUD_IRON;
	production_bonus_stat = CULTIST_STAT.BODY;
	production_bonus_stat_name = "BODY";
	production_bonus_stat_color = COLOR_CULTIST_BODY;
	building_tooltip_title = "Production";
	building_tooltip_description = "Produces Iron";
	building_tooltip_detail = "Bonus: " + production_bonus_stat_name + " +" + string(BALANCE_RESOURCE_BUILDING_STAT_SPEED_BONUS) + "x per point";
	building_tooltip_detail_color = production_bonus_stat_color;
	building_has_upgrades = true;
	building_upgrade_names[0] = "Reinforced Tools";
	building_upgrade_descriptions[0] = "+0.5x Iron production while staffed.";
	building_upgrade_names[1] = "Stone Stockpile";
	building_upgrade_descriptions[1] = "Slowly repairs the wall for free.";
}
else if (object_index == o_souls_well)
{
	building_accepts_workers = true;
	production_resource = RESOURCES.SOULS;
	production_resource_name = "Souls";
	production_resource_icon = s_soul_icon;
	production_resource_color = COLOR_HUD_SOULS;
	production_bonus_stat = CULTIST_STAT.SPIRIT;
	production_bonus_stat_name = "SPIRIT";
	production_bonus_stat_color = COLOR_CULTIST_SPIRIT;
	building_tooltip_title = "Production";
	building_tooltip_description = "Produces Souls";
	building_tooltip_detail = "Bonus: " + production_bonus_stat_name + " +" + string(BALANCE_RESOURCE_BUILDING_STAT_SPEED_BONUS) + "x per point";
	building_tooltip_detail_color = production_bonus_stat_color;
	building_has_upgrades = true;
	building_upgrade_names[0] = "Deeper Echo";
	building_upgrade_descriptions[0] = "+0.5x Souls production while staffed.";
	building_upgrade_names[1] = "Bone Whisper";
	building_upgrade_descriptions[1] = "Slowly summons Skeletons for free.";
}
else if (object_index == o_meat_bath)
{
	building_accepts_workers = true;
	production_resource_icon = s_flesh_icon;
	production_resource_color = COLOR_HUD_FLESH;
	building_tooltip_title = "Healing";
	building_tooltip_description = "Heals assigned cultists";
	building_tooltip_detail = "Uses " + string(BALANCE_MEAT_BATH_FLESH_COST) + " Flesh for " + string(BALANCE_MEAT_BATH_FLESH_HEAL_AMOUNT) + " HP";
	building_tooltip_detail_color = COLOR_HUD_FLESH;
}
else if (object_index == o_ritual_circle)
{
	building_accepts_workers = true;
	production_resource_icon = noone;
	production_resource_color = COLOR_CULTIST_SPIRIT;
	building_tooltip_title = "Training";
	building_tooltip_description = "Gives assigned cultists XP";
	building_tooltip_detail = "Gives " + string(BALANCE_RITUAL_CIRCLE_SOUL_EXP_AMOUNT) + " XP over time";
	building_tooltip_detail_color = COLOR_CULTIST_SPIRIT;
}
else if (object_index == o_workshop)
{
	building_accepts_workers = true;
	production_resource_icon = s_iron_icon;
	production_resource_color = COLOR_HUD_IRON;
	production_bonus_stat = CULTIST_STAT.BODY;
	production_bonus_stat_name = "BODY";
	production_bonus_stat_color = COLOR_CULTIST_BODY;
	building_tooltip_title = "Repair";
	building_tooltip_description = "Repairs the cannon wall";
	building_tooltip_detail = "Uses " + string(BALANCE_WORKSHOP_IRON_COST) + " Iron for " + string(BALANCE_WORKSHOP_IRON_REPAIR_AMOUNT) + " HP. Bonus: " + production_bonus_stat_name + " +" + string(BALANCE_RESOURCE_BUILDING_STAT_SPEED_BONUS) + "x per point";
	building_tooltip_detail_color = production_bonus_stat_color;
}
else if (object_index == o_graveyardv13)
{
	building_accepts_workers = true;
	production_resource_icon = s_soul_icon;
	production_resource_color = COLOR_HUD_SOULS;
	production_bonus_stat = CULTIST_STAT.SPIRIT;
	production_bonus_stat_name = "SPIRIT";
	production_bonus_stat_color = COLOR_CULTIST_SPIRIT;
	summon_unit_object = o_skeleton;
	summon_resource_cost = BALANCE_SKELETON_SUMMON_SOUL_COST;
	summon_double_unit_chance = BALANCE_SUMMON_BUILDING_DOUBLE_UNIT_CHANCE;
	summon_duration = BALANCE_GRAVEYARD_SKELETON_PRODUCTION_TIME;
	building_tooltip_title = "Summoning";
	building_tooltip_description = "Summons Skeletons";
	building_tooltip_detail = "Uses " + string(summon_resource_cost) + " " + summon_resource_name + ". Bonus: " + production_bonus_stat_name + " +" + string(BALANCE_RESOURCE_BUILDING_STAT_SPEED_BONUS) + "x per point";
	building_tooltip_detail_color = production_bonus_stat_color;
	building_has_upgrades = true;
	production_speed_upgrade_index = 1;
	building_upgrade_names[0] = "Bone Twins";
	building_upgrade_descriptions[0] = string(BALANCE_SUMMON_BUILDING_DOUBLE_UNIT_CHANCE * 100) + "% chance to summon 2 Skeletons at once.";
	building_upgrade_names[1] = "Restless Spades";
	building_upgrade_descriptions[1] = "+" + string(BALANCE_RESOURCE_BUILDING_SPEED_UPGRADE_BONUS) + "x Skeleton production while staffed.";
}
else if (object_index == o_hell_pit)
{
	building_accepts_workers = true;
	production_resource_icon = s_soul_icon;
	production_resource_color = COLOR_HUD_SOULS;
	production_bonus_stat = CULTIST_STAT.FERVOR;
	production_bonus_stat_name = "FERVOR";
	production_bonus_stat_color = COLOR_CULTIST_FERVOR;
	summon_unit_object = o_pitling;
	summon_resource_cost = BALANCE_PITLING_SUMMON_SOUL_COST;
	summon_double_unit_chance = BALANCE_SUMMON_BUILDING_DOUBLE_UNIT_CHANCE;
	summon_duration = BALANCE_HELL_PIT_PITLING_PRODUCTION_TIME;
	building_tooltip_title = "Summoning";
	building_tooltip_description = "Summons Pitlings";
	building_tooltip_detail = "Uses " + string(summon_resource_cost) + " " + summon_resource_name + ". Bonus: " + production_bonus_stat_name + " +" + string(BALANCE_RESOURCE_BUILDING_STAT_SPEED_BONUS) + "x per point";
	building_tooltip_detail_color = production_bonus_stat_color;
	building_has_upgrades = true;
	production_speed_upgrade_index = 1;
	building_upgrade_names[0] = "Twin Hatch";
	building_upgrade_descriptions[0] = string(BALANCE_SUMMON_BUILDING_DOUBLE_UNIT_CHANCE * 100) + "% chance to summon 2 Pitlings at once.";
	building_upgrade_names[1] = "Hotter Coals";
	building_upgrade_descriptions[1] = "+" + string(BALANCE_RESOURCE_BUILDING_SPEED_UPGRADE_BONUS) + "x Pitling production while staffed.";
}
else if (object_index == o_goblins_pit)
{
	building_accepts_workers = true;
	production_resource_icon = s_flesh_icon;
	production_resource_color = COLOR_HUD_FLESH;
	summon_unit_object = o_goblin;
	summon_resource = RESOURCES.FLESH;
	summon_resource_name = "Flesh";
	summon_resource_icon = s_flesh_icon;
	summon_resource_color = COLOR_HUD_FLESH;
	summon_resource_cost = BALANCE_GOBLIN_SUMMON_FLESH_COST;
	summon_extra_life_bonus = BALANCE_GOBLIN_UPGRADE_DAY_LIFE_BONUS;
	summon_duration = BALANCE_GOBLINS_PIT_GOBLIN_PRODUCTION_TIME;
	building_tooltip_title = "Summoning";
	building_tooltip_description = "Summons Goblins";
	building_tooltip_detail = "Uses " + string(summon_resource_cost) + " " + summon_resource_name + ". Adds +" + string(BALANCE_GOBLINS_PER_PIT_LIMIT) + " Goblin limit. Goblins work +" + string(BALANCE_GOBLIN_WORK_SPEED_MULTIPLIER) + "x";
	building_tooltip_detail_color = summon_resource_color;
	building_has_upgrades = true;
	production_speed_upgrade_index = noone;
	building_upgrade_names[0] = "Crowded Den";
	building_upgrade_descriptions[0] = "Increases this pit's Goblin limit to " + string(BALANCE_GOBLINS_PER_UPGRADED_PIT_LIMIT) + ".";
	building_upgrade_names[1] = "Stubborn Workers";
	building_upgrade_descriptions[1] = "New Goblins from this pit live +" + string(BALANCE_GOBLIN_UPGRADE_DAY_LIFE_BONUS) + " days longer.";
}

recalculate_production_speed_multiplier = function()
{
	var _total_speed_multiplier = 0;
	var _worker_count = array_length(worker_cultists);

	for (var _worker_index = 0; _worker_index < _worker_count; ++_worker_index)
	{
		var _worker = worker_cultists[_worker_index];

		if (!instance_exists(_worker))
		{
			continue;
		}

		var _worker_speed_multiplier = 1;

		if (variable_instance_exists(_worker, "worker_speed_multiplier"))
		{
			_worker_speed_multiplier = _worker.worker_speed_multiplier;
		}
		else if (production_bonus_stat != noone && variable_instance_exists(_worker, "cultist_points"))
		{
			var _stat_points = _worker.cultist_points[production_bonus_stat];
			_worker_speed_multiplier += _stat_points * BALANCE_RESOURCE_BUILDING_STAT_SPEED_BONUS;
		}

		if (variable_instance_exists(_worker, "whip_timer") && _worker.whip_timer > 0)
		{
			_worker_speed_multiplier *= _worker.whip_work_multiplier;
		}

		_worker_speed_multiplier *= building_worker_fatigue_multiplier_get(_worker);
		_total_speed_multiplier += _worker_speed_multiplier;
	}

	if (production_speed_upgrade_index != noone
		&& building_upgrade_flags[production_speed_upgrade_index]
		&& _total_speed_multiplier > 0)
	{
		_total_speed_multiplier += BALANCE_RESOURCE_BUILDING_SPEED_UPGRADE_BONUS;
	}

	production_speed_multiplier = _total_speed_multiplier * BALANCE_RESOURCE_BUILDING_PRODUCTION_SPEED_MULTIPLIER;
};

building_worker_fatigue_multiplier_get = function(_worker)
{
	if (!instance_exists(_worker)
		|| _worker.object_index != o_cultist
		|| !variable_instance_exists(_worker, "fatigue_amount"))
	{
		return 1;
	}

	if (_worker.fatigue_amount >= BALANCE_CULTIST_FATIGUE_MAX)
	{
		return BALANCE_CULTIST_FATIGUE_EXHAUSTED_EFFICIENCY;
	}

	return 1;
};

building_adds_cultist_fatigue = function()
{
	return object_index == o_quarry
		|| object_index == o_slaughter_table
		|| object_index == o_souls_well;
};

building_recovers_cultist_fatigue = function()
{
	return object_index == o_ritual_circle;
};

building_cultist_fatigue_update = function()
{
	if (global.day_phase != DAY_PHASE.DAY
		|| (!building_adds_cultist_fatigue() && !building_recovers_cultist_fatigue()))
	{
		return;
	}

	var _fatigue_delta = BALANCE_CULTIST_FATIGUE_GAIN_PER_SECOND / max(1, room_speed);

	if (building_recovers_cultist_fatigue())
	{
		_fatigue_delta = -BALANCE_CULTIST_FATIGUE_RECOVERY_PER_SECOND / max(1, room_speed);
	}

	var _worker_count = array_length(worker_cultists);

	for (var _worker_index = 0; _worker_index < _worker_count; ++_worker_index)
	{
		var _worker = worker_cultists[_worker_index];

		if (instance_exists(_worker)
			&& _worker.object_index == o_cultist
			&& variable_instance_exists(_worker, "fatigue_amount"))
		{
			_worker.fatigue_amount = clamp(_worker.fatigue_amount + _fatigue_delta, 0, BALANCE_CULTIST_FATIGUE_MAX);
		}
	}
};

building_upgrade_can_buy = function(_upgrade_index)
{
	return building_has_upgrades
		&& _upgrade_index >= 0
		&& _upgrade_index < array_length(building_upgrade_flags)
		&& !building_upgrade_flags[_upgrade_index]
		&& global.resources[RESOURCES.IRON] >= building_upgrade_costs[_upgrade_index];
};

building_upgrade_buy = function(_upgrade_index)
{
	if (!building_upgrade_can_buy(_upgrade_index))
	{
		if (_upgrade_index >= 0 && _upgrade_index < array_length(building_upgrade_costs))
		{
			building_warning_show("Need " + string(building_upgrade_costs[_upgrade_index]) + " Iron", COLOR_STATUS_NEGATIVE_RED);
		}

		return false;
	}

	var _upgrade_cost = building_upgrade_costs[_upgrade_index];
	global.resources[RESOURCES.IRON] -= _upgrade_cost;
	resource_popup_create(x, y - production_bar_offset_y, RESOURCES.IRON, -_upgrade_cost);
	building_upgrade_flags[_upgrade_index] = true;
	recalculate_production_speed_multiplier();
	return true;
};

goblins_pit_goblin_limit_get = function()
{
	var _total_limit = 0;
	var _pit_count = instance_number(o_goblins_pit);

	for (var _pit_index = 0; _pit_index < _pit_count; ++_pit_index)
	{
		var _pit = instance_find(o_goblins_pit, _pit_index);
		var _pit_limit = BALANCE_GOBLINS_PER_PIT_LIMIT;

		if (instance_exists(_pit)
			&& variable_instance_exists(_pit, "building_upgrade_flags")
			&& _pit.building_upgrade_flags[0])
		{
			_pit_limit = BALANCE_GOBLINS_PER_UPGRADED_PIT_LIMIT;
		}

		_total_limit += _pit_limit;
	}

	return _total_limit;
};

goblins_pit_goblin_count_get = function()
{
	return instance_number(o_goblin);
};

goblins_pit_can_summon_goblin = function()
{
	return goblins_pit_goblin_count_get() < goblins_pit_goblin_limit_get();
};

building_warning_show = function(_text, _color)
{
	building_warning_text = _text;
	building_warning_color = _color;
	building_warning_timer = building_warning_time;
};

building_is_mouse_hovered = function()
{
	if (!instance_exists(o_camera_controller))
	{
		return false;
	}

	var _camera_controller = instance_find(o_camera_controller, 0);
	var _mouse_gui_x = device_mouse_x_to_gui(0);
	var _mouse_gui_y = device_mouse_y_to_gui(0);
	var _camera_x = camera_get_view_x(_camera_controller.camera_id);
	var _camera_y = camera_get_view_y(_camera_controller.camera_id);
	var _camera_width = camera_get_view_width(_camera_controller.camera_id);
	var _camera_height = camera_get_view_height(_camera_controller.camera_id);
	var _gui_width = _camera_controller.base_view_width;
	var _gui_height = _camera_controller.base_view_height;
	var _mouse_world_x = _camera_x + ((_mouse_gui_x / _gui_width) * _camera_width);
	var _mouse_world_y = _camera_y + ((_mouse_gui_y / _gui_height) * _camera_height);

	return _mouse_world_x >= bbox_left
		&& _mouse_world_x <= bbox_right
		&& _mouse_world_y >= bbox_top
		&& _mouse_world_y <= bbox_bottom;
};

building_demolish = function()
{
	// Release assigned workers before replacing the building with an empty slot.
	if (instance_exists(o_game_controller))
	{
		var _game_controller = instance_find(o_game_controller, 0);
		var _worker_count = array_length(worker_cultists);
		var _workers = worker_cultists;

		for (var _worker_index = 0; _worker_index < _worker_count; ++_worker_index)
		{
			var _worker = _workers[_worker_index];

			if (instance_exists(_worker)
				&& variable_instance_exists(_game_controller, "clear_cultist_building_assignment"))
			{
				_game_controller.clear_cultist_building_assignment(_worker);
			}
		}
	}

	var _slot = instance_create_layer(x, y, "Instances", o_building_slot);

	if (instance_exists(_slot))
	{
		_slot.depth = depth;
	}

	if (variable_global_exists("construction_sounds"))
	{
		global.sound_play_random(global.construction_sounds);
	}

	if (variable_global_exists("cultist_assignment_preview_building")
		&& global.cultist_assignment_preview_building == id)
	{
		global.cultist_assignment_preview_building = noone;
	}

	instance_destroy();
};
