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
summon_resource_costs = [];
summon_double_unit_chance = 0;
summon_extra_life_bonus = 0;
summon_progress = 0;
summon_duration = 0;
summon_has_paid_cost = false;
worker_cultists = array_create(0);
worker_max = BALANCE_RESOURCE_BUILDING_WORKER_MAX;
worker_stand_offset_y = 12;
worker_stand_spacing = BALANCE_RESOURCE_BUILDING_WORKER_STAND_SPACING;
y_sort_enabled = true;

// Resource warning shown by assigned cultists when this building cannot work.
missing_work_resource = noone;
missing_work_resource_name = "";
missing_work_resource_amount = 0;
missing_work_resource_color = c_white;
building_warning_text = "";
building_warning_color = COLOR_STATUS_NEGATIVE_RED;
building_warning_timer = 0;
building_warning_time = 0.35 * room_speed;
building_warning_offset_y = 148;
building_warning_padding_x = 7;
building_warning_padding_y = 4;
building_warning_background_alpha = 0.84;
goblin_status_offset_y = 166;
goblin_status_line_height = 14;

// Production bar visual settings.
production_bar_width = 62;
production_bar_height = 6;
production_bar_offset_y = 125;
production_bar_outline_alpha = 0.85;
production_bar_background_alpha = 0.72;
production_icon_size = 18;
production_icon_gap = 8;
production_multiplier_bar_gap_y = 4;
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
building_upgrade_resources = [RESOURCES.IRON, RESOURCES.IRON];
building_has_upgrades = false;
secondary_effect_progress = 0;

// Meat Bath stores paid healing here so one Flesh restores a fixed amount over time.
meat_bath_heal_pool = 0;

// Ritual Circle stores base XP here before applying XP Gain to workers.
ritual_circle_exp_pool = 0;
ritual_circle_exp_pool_amount = BALANCE_RITUAL_CIRCLE_SOUL_EXP_AMOUNT;
ritual_circle_daily_exp_remaining = BALANCE_RITUAL_CIRCLE_DAILY_EXP_LIMIT;

// Workshop stores paid repair here before applying it to the cannon wall.
workshop_repair_pool = 0;

resource_name_get = function(_resource)
{
	if (_resource == RESOURCES.FLESH)
	{
		return "Flesh";
	}

	if (_resource == RESOURCES.SOULS)
	{
		return "Souls";
	}

	if (_resource == RESOURCES.IRON)
	{
		return "Iron";
	}

	return "";
};

resource_icon_get = function(_resource)
{
	if (_resource == RESOURCES.FLESH)
	{
		return s_flesh_icon;
	}

	if (_resource == RESOURCES.SOULS)
	{
		return s_soul_icon;
	}

	if (_resource == RESOURCES.IRON)
	{
		return s_iron_icon;
	}

	return noone;
};

resource_color_get = function(_resource)
{
	if (_resource == RESOURCES.FLESH)
	{
		return COLOR_HUD_FLESH;
	}

	if (_resource == RESOURCES.SOULS)
	{
		return COLOR_HUD_SOULS;
	}

	if (_resource == RESOURCES.IRON)
	{
		return COLOR_HUD_IRON;
	}

	return c_white;
};

summon_cost_add = function(_resource, _cost)
{
	var _cost_data = {
		resource: _resource,
		cost: _cost,
		name: resource_name_get(_resource),
		icon: resource_icon_get(_resource),
		color: resource_color_get(_resource)
	};

	array_push(summon_resource_costs, _cost_data);

	// Keep legacy single-cost fields pointed at the first cost for UI defaults.
	if (array_length(summon_resource_costs) == 1)
	{
		summon_resource = _cost_data.resource;
		summon_resource_name = _cost_data.name;
		summon_resource_icon = _cost_data.icon;
		summon_resource_color = _cost_data.color;
		summon_resource_cost = _cost_data.cost;
	}
};

summon_cost_text_get = function()
{
	var _cost_count = array_length(summon_resource_costs);
	var _cost_text = "";

	for (var _cost_index = 0; _cost_index < _cost_count; ++_cost_index)
	{
		var _cost_data = summon_resource_costs[_cost_index];

		if (_cost_index > 0)
		{
			_cost_text += " + ";
		}

		_cost_text += string(_cost_data.cost) + " " + _cost_data.name;
	}

	return _cost_text;
};

summon_costs_can_pay = function()
{
	var _cost_count = array_length(summon_resource_costs);

	for (var _cost_index = 0; _cost_index < _cost_count; ++_cost_index)
	{
		var _cost_data = summon_resource_costs[_cost_index];

		if (global.resources[_cost_data.resource] < _cost_data.cost)
		{
			return false;
		}
	}

	return true;
};

summon_missing_cost_get = function()
{
	var _cost_count = array_length(summon_resource_costs);

	for (var _cost_index = 0; _cost_index < _cost_count; ++_cost_index)
	{
		var _cost_data = summon_resource_costs[_cost_index];

		if (global.resources[_cost_data.resource] < _cost_data.cost)
		{
			return _cost_data;
		}
	}

	return noone;
};

summon_costs_pay = function()
{
	var _cost_count = array_length(summon_resource_costs);
	var _popup_gap = 46;
	var _popup_start_x = x - ((_cost_count - 1) * _popup_gap * 0.5);

	for (var _cost_index = 0; _cost_index < _cost_count; ++_cost_index)
	{
		var _cost_data = summon_resource_costs[_cost_index];
		var _popup_x = _popup_start_x + (_cost_index * _popup_gap);

		global.resources[_cost_data.resource] -= _cost_data.cost;
		resource_popup_create(_popup_x, y - production_bar_offset_y, _cost_data.resource, -_cost_data.cost);
	}
};

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
	building_upgrade_descriptions[0] = "+0.5x Flesh production while at least one worker assigned.";
	building_upgrade_names[1] = "Blood Poultice";
	building_upgrade_descriptions[1] = "Slowly heals workers who assigned on this building.";
	building_upgrade_resources[1] = RESOURCES.SOULS;
	building_upgrade_costs[1] = BALANCE_BLOOD_POULTICE_UPGRADE_SOUL_COST;
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
	building_upgrade_flags = [false];
	building_upgrade_names = [""];
	building_upgrade_descriptions = [""];
	building_upgrade_costs = [BALANCE_BUILDING_UPGRADE_IRON_COST];
	building_upgrade_resources = [RESOURCES.IRON];
	building_upgrade_names[0] = "Reinforced Tools";
	building_upgrade_descriptions[0] = "+0.5x Iron production while at least one worker assigned.";
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
	building_upgrade_descriptions[0] = "+0.5x Souls production while at least one worker assigned.";
	building_upgrade_names[1] = "Bone Whisper";
	building_upgrade_descriptions[1] = "Slowly summons Skeletons while at least one worker assigned.";
	building_upgrade_resources[1] = RESOURCES.SOULS;
	building_upgrade_costs[1] = BALANCE_BONE_WHISPER_UPGRADE_SOUL_COST;
}
else if (object_index == o_meat_bath)
{
	building_accepts_workers = true;
	production_resource_icon = s_flesh_icon;
	production_resource_color = COLOR_HUD_FLESH;
	building_tooltip_title = "Healing";
	building_tooltip_description = "Heals assigned workers";
	building_tooltip_detail = "Uses " + string(BALANCE_MEAT_BATH_FLESH_COST) + " Flesh for " + string(BALANCE_MEAT_BATH_FLESH_HEAL_AMOUNT) + " HP";
	building_tooltip_detail_color = COLOR_HUD_FLESH;
}
else if (object_index == o_ritual_circle)
{
	building_accepts_workers = true;
	production_resource_icon = noone;
	production_resource_color = COLOR_CULTIST_SPIRIT;
	building_tooltip_title = "Training";
	building_tooltip_description = "Restores Stamina and gives assigned workers XP";
	building_tooltip_detail = "Restores Stamina. Gives " + string(BALANCE_RITUAL_CIRCLE_SOUL_EXP_AMOUNT) + " XP chunks. Daily reserve: " + string(BALANCE_RITUAL_CIRCLE_DAILY_EXP_LIMIT) + " XP";
	building_tooltip_detail_color = COLOR_CULTIST_SPIRIT;
	building_has_upgrades = true;
	building_upgrade_names[0] = "Deeper Rest";
	building_upgrade_descriptions[0] = "Workers recover Stamina " + string(BALANCE_RITUAL_CIRCLE_REST_UPGRADE_MULTIPLIER) + "x faster.";
	building_upgrade_names[1] = "Endless Chant";
	building_upgrade_descriptions[1] = "Daily XP reserve is increased " + string(BALANCE_RITUAL_CIRCLE_DAILY_EXP_UPGRADE_MULTIPLIER) + "x.";
	building_upgrade_resources[1] = RESOURCES.SOULS;
	building_upgrade_costs[1] = BALANCE_ENDLESS_CHANT_UPGRADE_SOUL_COST;
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
	summon_cost_add(RESOURCES.IRON, BALANCE_SKELETON_SUMMON_IRON_COST);
	summon_cost_add(RESOURCES.SOULS, BALANCE_SKELETON_SUMMON_SOUL_COST);
	summon_double_unit_chance = BALANCE_SUMMON_BUILDING_DOUBLE_UNIT_CHANCE;
	summon_duration = BALANCE_GRAVEYARD_SKELETON_PRODUCTION_TIME;
	building_tooltip_title = "Summoning";
	building_tooltip_description = "Summons Skeletons";
	building_tooltip_detail = "Uses " + summon_cost_text_get() + ". Bonus: " + production_bonus_stat_name + " +" + string(BALANCE_RESOURCE_BUILDING_STAT_SPEED_BONUS) + "x per point";
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
	production_resource_icon = s_flesh_icon;
	production_resource_color = COLOR_HUD_FLESH;
	production_bonus_stat = CULTIST_STAT.FERVOR;
	production_bonus_stat_name = "FERVOR";
	production_bonus_stat_color = COLOR_CULTIST_FERVOR;
	summon_unit_object = o_pitling;
	summon_cost_add(RESOURCES.FLESH, BALANCE_PITLING_SUMMON_FLESH_COST);
	summon_cost_add(RESOURCES.IRON, BALANCE_PITLING_SUMMON_IRON_COST);
	summon_double_unit_chance = BALANCE_SUMMON_BUILDING_DOUBLE_UNIT_CHANCE;
	summon_duration = BALANCE_HELL_PIT_PITLING_PRODUCTION_TIME;
	building_tooltip_title = "Summoning";
	building_tooltip_description = "Summons Pitlings";
	building_tooltip_detail = "Uses " + summon_cost_text_get() + ". Bonus: " + production_bonus_stat_name + " +" + string(BALANCE_RESOURCE_BUILDING_STAT_SPEED_BONUS) + "x per point";
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
	summon_cost_add(RESOURCES.FLESH, BALANCE_GOBLIN_SUMMON_FLESH_COST);
	summon_duration = BALANCE_GOBLINS_PIT_GOBLIN_PRODUCTION_TIME;
	building_tooltip_title = "Summoning";
	building_tooltip_description = "Summons Goblins";
	building_tooltip_detail = "Uses " + summon_cost_text_get() + ". Adds +" + string(BALANCE_GOBLINS_PER_PIT_LIMIT) + " Goblin limit. Goblins work +" + string(BALANCE_GOBLIN_WORK_SPEED_MULTIPLIER) + "x";
	building_tooltip_detail_color = summon_resource_color;
	building_has_upgrades = true;
	production_speed_upgrade_index = noone;
	building_upgrade_names[0] = "Crowded Den";
	building_upgrade_descriptions[0] = "Increases this pit's Goblin limit to " + string(BALANCE_GOBLINS_PER_UPGRADED_PIT_LIMIT) + ".";
	building_upgrade_resources[0] = RESOURCES.SOULS;
	building_upgrade_costs[0] = BALANCE_CROWDED_DEN_UPGRADE_SOUL_COST;
	building_upgrade_names[1] = "Stubborn Workers";
	building_upgrade_descriptions[1] = "New Goblins from this pit live " + string(BALANCE_GOBLIN_UPGRADED_DAY_LIFE_MIN) + "-" + string(BALANCE_GOBLIN_UPGRADED_DAY_LIFE_MAX) + " days.";
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

		_worker_speed_multiplier *= building_worker_stamina_multiplier_get(_worker);
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

production_speed_multiplier_draw = function(_text_x, _text_y)
{
	var _multiplier_text = string_format(production_speed_multiplier, 0, 1) + "x";

	if (variable_global_exists("building_speed_font") && font_exists(global.building_speed_font))
	{
		draw_set_font(global.building_speed_font);
	}

	draw_set_alpha(1);
	draw_set_halign(fa_center);
	draw_set_valign(fa_bottom);
	draw_set_color(c_black);
	draw_text(_text_x - 2, _text_y, _multiplier_text);
	draw_text(_text_x + 2, _text_y, _multiplier_text);
	draw_text(_text_x, _text_y - 2, _multiplier_text);
	draw_text(_text_x, _text_y + 2, _multiplier_text);
	draw_text(_text_x - 2, _text_y + 2, _multiplier_text);
	draw_text(_text_x + 2, _text_y + 2, _multiplier_text);
	draw_set_color(production_bonus_stat_color);
	draw_text(_text_x - 1, _text_y, _multiplier_text);
	draw_text(_text_x + 1, _text_y, _multiplier_text);
	draw_text(_text_x, _text_y, _multiplier_text);

	if (variable_global_exists("ui_font") && font_exists(global.ui_font))
	{
		draw_set_font(global.ui_font);
	}

	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
	draw_set_alpha(1);
};

building_worker_stamina_multiplier_get = function(_worker)
{
	if (!instance_exists(_worker)
		|| _worker.object_index != o_cultist
		|| !variable_instance_exists(_worker, "stamina_amount"))
	{
		return 1;
	}

	if (_worker.stamina_amount <= 0)
	{
		return BALANCE_CULTIST_STAMINA_EMPTY_EFFICIENCY;
	}

	return 1;
};

building_spends_cultist_stamina = function()
{
	return object_index == o_quarry
		|| object_index == o_slaughter_table
		|| object_index == o_souls_well
		|| object_index == o_workshop
		|| summon_unit_object != noone;
};

building_stamina_drain_multiplier_get = function()
{
	if (summon_unit_object != noone)
	{
		return BALANCE_CULTIST_SUMMON_STAMINA_DRAIN_MULTIPLIER;
	}

	return 1;
};

building_recovers_cultist_stamina = function()
{
	return object_index == o_ritual_circle;
};

ritual_circle_daily_exp_limit_get = function()
{
	var _daily_exp_limit = BALANCE_RITUAL_CIRCLE_DAILY_EXP_LIMIT;

	if (array_length(building_upgrade_flags) > 1 && building_upgrade_flags[1])
	{
		_daily_exp_limit *= BALANCE_RITUAL_CIRCLE_DAILY_EXP_UPGRADE_MULTIPLIER;
	}

	return _daily_exp_limit;
};

building_cultist_stamina_update = function()
{
	if (global.day_phase != DAY_PHASE.DAY
		|| (!building_spends_cultist_stamina() && !building_recovers_cultist_stamina()))
	{
		return;
	}

	var _stamina_delta = -BALANCE_CULTIST_STAMINA_DRAIN_PER_SECOND
		* building_stamina_drain_multiplier_get()
		/ max(1, room_speed);

	if (building_recovers_cultist_stamina())
	{
		_stamina_delta = BALANCE_CULTIST_STAMINA_RECOVERY_PER_SECOND / max(1, room_speed);

		if (building_upgrade_flags[0])
		{
			_stamina_delta *= BALANCE_RITUAL_CIRCLE_REST_UPGRADE_MULTIPLIER;
		}
	}

	var _worker_count = array_length(worker_cultists);

	for (var _worker_index = 0; _worker_index < _worker_count; ++_worker_index)
	{
		var _worker = worker_cultists[_worker_index];

		if (instance_exists(_worker)
			&& _worker.object_index == o_cultist
			&& variable_instance_exists(_worker, "stamina_amount"))
		{
			var _worker_stamina_delta = _stamina_delta;

			if (_worker_stamina_delta < 0
				&& variable_instance_exists(_worker, "whip_timer")
				&& _worker.whip_timer > 0
				&& variable_instance_exists(_worker, "whip_work_multiplier"))
			{
				_worker_stamina_delta *= _worker.whip_work_multiplier;
			}

			var _stamina_before = _worker.stamina_amount;
			_worker.stamina_amount = clamp(_worker.stamina_amount + _worker_stamina_delta, 0, BALANCE_CULTIST_STAMINA_MAX);

			if (_stamina_before > 0
				&& _worker.stamina_amount <= 0
				&& variable_global_exists("tutorial_hint_trigger"))
			{
				global.tutorial_hint_trigger("stamina");
			}
		}
	}
};

building_upgrade_can_buy = function(_upgrade_index)
{
	if (_upgrade_index < 0 || _upgrade_index >= array_length(building_upgrade_flags))
	{
		return false;
	}

	var _upgrade_resource = building_upgrade_resources[_upgrade_index];

	return building_has_upgrades
		&& !building_upgrade_flags[_upgrade_index]
		&& global.resources[_upgrade_resource] >= building_upgrade_costs[_upgrade_index];
};

building_upgrade_buy = function(_upgrade_index)
{
	if (!building_upgrade_can_buy(_upgrade_index))
	{
		if (_upgrade_index >= 0 && _upgrade_index < array_length(building_upgrade_costs))
		{
			var _missing_resource = building_upgrade_resources[_upgrade_index];
			building_warning_show("Need " + string(building_upgrade_costs[_upgrade_index]) + " " + resource_name_get(_missing_resource), COLOR_STATUS_NEGATIVE_RED);
		}

		return false;
	}

	var _upgrade_cost = building_upgrade_costs[_upgrade_index];
	var _upgrade_resource = building_upgrade_resources[_upgrade_index];
	global.resources[_upgrade_resource] -= _upgrade_cost;
	resource_popup_create(x, y - production_bar_offset_y, _upgrade_resource, -_upgrade_cost);
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

goblins_pit_release_workers_if_limit_full = function()
{
	if (object_index != o_goblins_pit || goblins_pit_can_summon_goblin())
	{
		return false;
	}

	if (instance_exists(o_game_controller))
	{
		var _game_controller = instance_find(o_game_controller, 0);
		var _worker_count = array_length(worker_cultists);
		var _workers = array_create(_worker_count);

		for (var _copy_index = 0; _copy_index < _worker_count; ++_copy_index)
		{
			_workers[_copy_index] = worker_cultists[_copy_index];
		}

		// Release every assigned worker because the pit cannot produce another goblin.
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
	else
	{
		worker_cultists = array_create(0);
	}

	return true;
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
		var _workers = array_create(_worker_count);

		for (var _copy_index = 0; _copy_index < _worker_count; ++_copy_index)
		{
			_workers[_copy_index] = worker_cultists[_copy_index];
		}

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

	if (variable_global_exists("construction_sound_play"))
	{
		global.construction_sound_play();
	}

	if (variable_global_exists("cultist_assignment_preview_building")
		&& global.cultist_assignment_preview_building == id)
	{
		global.cultist_assignment_preview_building = noone;
	}

	instance_destroy();
};
