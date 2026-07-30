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
production_daily_base_limit = 0;
production_daily_limit = 0;
production_daily_remaining = 0;
production_speed_multiplier = 0;
production_speed_upgrade_index = 0;
production_daily_limit_upgrade_index = noone;
production_secondary_effect_upgrade_index = noone;
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
garrison_unit_object = noone;
garrison_unit_base_limit = 0;
garrison_unit_spawn_bonus_per_upgrade = 0;
worker_cultists = array_create(0);
worker_max = BALANCE_RESOURCE_BUILDING_WORKER_MAX;
worker_stand_offset_y = 12;
worker_stand_spacing = BALANCE_RESOURCE_BUILDING_WORKER_STAND_SPACING;
y_sort_enabled = true;
corruption_bar_visible = false;

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
production_daily_bar_height = 9;
production_daily_bar_gap = 4;
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
building_display_name = "";
building_tooltip_title = "";
building_tooltip_description = "";
building_tooltip_detail = "";
building_tooltip_detail_color = COLOR_HUD_TEXT;
events_prompt_text = "LMB - EVENTS";
events_prompt_offset_y = 24;
events_prompt_padding_x = 7;
events_prompt_padding_y = 4;
events_prompt_background_alpha = 0.78;
demolish_prompt_text = "T - DEMOLISH";
demolish_prompt_offset_y = 50;
demolish_prompt_padding_x = 7;
demolish_prompt_padding_y = 4;
demolish_prompt_background_alpha = 0.78;
foundry_click_icon_size = 68;
foundry_click_icon_offset_y = 28;
foundry_click_icon_alpha = 0.95;
foundry_click_icon_pulse_scale = 0.08;
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

// Shell Factory stores paid resource work here before producing a random shell.
shell_factory_progress = 0;
shell_factory_has_paid_cost = false;

// Foundry stores the selected structure shell before producing a cannon projectile.
foundry_selected_shell = noone;
foundry_shell_progress = 0;
foundry_shell_duration = BALANCE_FOUNDRY_SHELL_PRODUCTION_TIME;
foundry_prompt_text = "Choose Structure";
foundry_product_offset_y = 176;

// World event cards keep their hover while the cursor moves between the building and card.
world_event_hover_active = false;
world_event_hover_keeps_selector_area = false;

// Daily event generation avoids IDs selected for this building on the previous day.
previous_day_event_ids = [];

world_event_current_get = function()
{
	if (!variable_global_exists("day_events"))
	{
		return noone;
	}

	for (var _event_index = 0; _event_index < array_length(global.day_events); ++_event_index)
	{
		var _event = global.day_events[_event_index];
		var _resolved_event_is_visible = is_struct(_event)
			&& global.day_phase == DAY_PHASE.NIGHT
			&& _event.is_resolved;

		if (is_struct(_event)
			&& (!_event.is_resolved || _resolved_event_is_visible)
			&& variable_struct_exists(_event, "source_building")
			&& _event.source_building == id)
		{
			return _event;
		}
	}

	return noone;
};

world_event_layout_get = function(_event, _include_selector_options = false)
{
	if (!is_struct(_event) || !instance_exists(o_camera_controller))
	{
		return noone;
	}

	var _camera_controller = instance_find(o_camera_controller, 0);
	var _camera_x = camera_get_view_x(_camera_controller.camera_id);
	var _camera_y = camera_get_view_y(_camera_controller.camera_id);
	var _camera_width = camera_get_view_width(_camera_controller.camera_id);
	var _camera_height = camera_get_view_height(_camera_controller.camera_id);
	var _gui_width = _camera_controller.base_view_width;
	var _gui_height = _camera_controller.base_view_height;
	var _world_to_gui_x = _gui_width / _camera_width;
	var _world_to_gui_y = _gui_height / _camera_height;
	var _building_left = (bbox_left - _camera_x) * _world_to_gui_x;
	var _building_right = (bbox_right - _camera_x) * _world_to_gui_x;
	var _building_top = (bbox_top - _camera_y) * _world_to_gui_y;
	var _building_bottom = (bbox_bottom - _camera_y) * _world_to_gui_y;
	var _building_center_x = (x - _camera_x) * _world_to_gui_x;
	var _has_selector = variable_struct_exists(_event, "requires_squad_selection")
		&& _event.requires_squad_selection
		&& variable_struct_exists(_event, "eligible_squads")
		&& array_length(_event.eligible_squads) > 0;
	var _event_is_ready = _event.activation_ready_count_get() > 0;
	var _description_width = BALANCE_WORLD_EVENT_CARD_WIDTH
		- (BALANCE_WORLD_EVENT_CARD_PADDING_X * 2)
		- (_event_is_ready ? BALANCE_WORLD_EVENT_READY_ICON_WIDTH : 0);
	var _previous_font = draw_get_font();

	if (instance_exists(o_jobs_ui))
	{
		var _jobs_ui = instance_find(o_jobs_ui, 0);

		if (font_exists(_jobs_ui.jobs_description_font))
		{
			draw_set_font(_jobs_ui.jobs_description_font);
		}
	}

	var _description_height = string_height_ext(
		_event.description,
		BALANCE_WORLD_EVENT_DESCRIPTION_LINE_SEPARATION,
		_description_width
	);
	draw_set_font(_previous_font);

	var _card_content_height = BALANCE_WORLD_EVENT_CARD_PADDING_Y
		+ BALANCE_WORLD_EVENT_DESCRIPTION_OFFSET_Y
		+ _description_height
		+ BALANCE_WORLD_EVENT_CARD_PADDING_Y;
	var _card_body_height = max(BALANCE_WORLD_EVENT_CARD_HEIGHT, _card_content_height);
	var _card_height = _card_body_height
		+ (_has_selector ? BALANCE_WORLD_EVENT_SELECTOR_SECTION_HEIGHT : 0);
	var _card_x = clamp(
		_building_center_x - (BALANCE_WORLD_EVENT_CARD_WIDTH * 0.5),
		BALANCE_WORLD_EVENT_CARD_GAP,
		_gui_width - BALANCE_WORLD_EVENT_CARD_WIDTH - BALANCE_WORLD_EVENT_CARD_GAP
	);
	var _card_y = max(
		BALANCE_WORLD_EVENT_CARD_GAP,
		_building_top - _card_height - BALANCE_WORLD_EVENT_CARD_GAP
	);
	var _selector_x = _card_x + BALANCE_WORLD_EVENT_CARD_PADDING_X;
	var _selector_y = _card_y
		+ _card_height
		- BALANCE_WORLD_EVENT_CARD_PADDING_Y
		- BALANCE_WORLD_EVENT_SELECTOR_HEIGHT;
	var _option_count = _has_selector ? array_length(_event.eligible_squads) : 0;
	var _options_height = _option_count * BALANCE_WORLD_EVENT_SELECTOR_OPTION_HEIGHT;
	var _options_y = _selector_y + BALANCE_WORLD_EVENT_SELECTOR_HEIGHT;

	if (_options_y + _options_height > _gui_height - BALANCE_WORLD_EVENT_CARD_GAP)
	{
		_options_y = _selector_y - _options_height;
	}

	_options_y = clamp(
		_options_y,
		BALANCE_WORLD_EVENT_CARD_GAP,
		max(
			BALANCE_WORLD_EVENT_CARD_GAP,
			_gui_height - BALANCE_WORLD_EVENT_CARD_GAP - _options_height
		)
	);

	var _action_extra_height = day_event_building_action_is_available(_event)
		? BALANCE_WORLD_EVENT_PIN_ICON_GAP + BALANCE_WORLD_EVENT_PIN_ICON_HEIGHT
		: 0;
	var _content_left = min(_building_left, _card_x);
	var _content_top = min(_building_top, _card_y);
	var _content_right = max(_building_right, _card_x + BALANCE_WORLD_EVENT_CARD_WIDTH);
	var _content_bottom = max(
		_building_bottom,
		_card_y + _card_height + _action_extra_height
	);

	if (_include_selector_options && _has_selector)
	{
		_content_left = min(_content_left, _selector_x);
		_content_top = min(_content_top, _options_y);
		_content_right = max(_content_right, _selector_x + BALANCE_WORLD_EVENT_SELECTOR_WIDTH);
		_content_bottom = max(_content_bottom, _options_y + _options_height);
	}

	return {
		camera_x: _camera_x,
		camera_y: _camera_y,
		camera_width: _camera_width,
		camera_height: _camera_height,
		gui_width: _gui_width,
		gui_height: _gui_height,
		world_to_gui_x: _world_to_gui_x,
		world_to_gui_y: _world_to_gui_y,
		building_left: _building_left,
		building_right: _building_right,
		building_top: _building_top,
		building_bottom: _building_bottom,
		building_center_x: _building_center_x,
		has_selector: _has_selector,
		card_x: _card_x,
		card_y: _card_y,
		card_width: BALANCE_WORLD_EVENT_CARD_WIDTH,
		card_body_height: _card_body_height,
		card_height: _card_height,
		selector_x: _selector_x,
		selector_y: _selector_y,
		selector_width: BALANCE_WORLD_EVENT_SELECTOR_WIDTH,
		selector_height: BALANCE_WORLD_EVENT_SELECTOR_HEIGHT,
		options_y: _options_y,
		option_height: BALANCE_WORLD_EVENT_SELECTOR_OPTION_HEIGHT,
		option_count: _option_count,
		hover_left: _content_left - BALANCE_WORLD_EVENT_HOVER_MARGIN,
		hover_top: _content_top - BALANCE_WORLD_EVENT_HOVER_MARGIN,
		hover_right: _content_right + BALANCE_WORLD_EVENT_HOVER_MARGIN,
		hover_bottom: _content_bottom + BALANCE_WORLD_EVENT_HOVER_MARGIN
	};
};

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

	if (_resource == RESOURCES.IHOR)
	{
		return "Ihor";
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

	if (_resource == RESOURCES.IHOR)
	{
		return s_ihor_icon;
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

	if (_resource == RESOURCES.IHOR)
	{
		return COLOR_HUD_IHOR;
	}

	return c_white;
};

settlement_expansion_is_purchased = function()
{
	if (!instance_exists(o_cannon))
	{
		return false;
	}

	var _cannon = instance_find(o_cannon, 0);

	return variable_instance_exists(_cannon, "building_upgrade_levels")
		&& array_length(_cannon.building_upgrade_levels) > CANNON_UPGRADE.SETTLEMENT_EXPANSION
		&& _cannon.building_upgrade_levels[CANNON_UPGRADE.SETTLEMENT_EXPANSION] > 0;
};

building_upgrade_requires_settlement_expansion = function(_upgrade_index)
{
	return object_index == o_slaughter_table
		&& _upgrade_index == 1;
};

building_upgrade_requirement_met = function(_upgrade_index)
{
	if (building_upgrade_requires_settlement_expansion(_upgrade_index)
		&& !settlement_expansion_is_purchased())
	{
		return false;
	}

	return true;
};

building_display_name_get = function()
{
	if (object_index == o_souls_well)
	{
		return "Souls Well";
	}

	if (object_index == o_slaughter_table)
	{
		return "Slaughter Table";
	}

	if (object_index == o_quarry)
	{
		return "Quarry";
	}

	if (object_index == o_goblins_pit)
	{
		return "Goblins Pit";
	}

	if (object_index == o_pitlings_pit2)
	{
		return "Demons Pit";
	}

	if (object_index == o_graveyard2)
	{
		return "Graveyard";
	}

	if (object_index == o_meat_bath)
	{
		return "Blood Bath";
	}

	if (object_index == o_ritual_circle)
	{
		return "Ritual Circle";
	}

	if (object_index == o_workshop)
	{
		return "Workshop";
	}

	if (object_index == o_shell_factory)
	{
		return "Shell Factory";
	}

	if (object_index == o_foundry)
	{
		return "Foundry";
	}

	if (object_index == o_graveyardv13)
	{
		return "Graveyard";
	}

	if (object_index == o_hell_pit)
	{
		return "Hell Pit";
	}

	return building_tooltip_title;
};

building_display_name = building_display_name_get();

building_missing_resource_show = function(_resource, _cost)
{
	missing_work_resource = _resource;
	missing_work_resource_name = resource_name_get(_resource);
	missing_work_resource_amount = _cost;
	missing_work_resource_color = resource_color_get(_resource);
	building_warning_show("Need " + string(_cost) + " " + missing_work_resource_name, COLOR_STATUS_NEGATIVE_RED);
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

production_daily_limit_upgrade_level_get = function()
{
	if (production_daily_limit_upgrade_index == noone
		|| !variable_instance_exists(id, "building_upgrade_levels")
		|| production_daily_limit_upgrade_index < 0
		|| production_daily_limit_upgrade_index >= array_length(building_upgrade_levels))
	{
		return 0;
	}

	return building_upgrade_levels[production_daily_limit_upgrade_index];
};

production_daily_limit_get = function()
{
	var _upgrade_level = production_daily_limit_upgrade_level_get();
	var _limit_multiplier = 1 + (_upgrade_level * BALANCE_RESOURCE_BUILDING_DAILY_LIMIT_UPGRADE_BONUS);

	return floor(production_daily_base_limit * _limit_multiplier);
};

production_daily_limit_refresh = function(_add_new_capacity = false)
{
	if (production_daily_base_limit <= 0)
	{
		return;
	}

	var _old_limit = production_daily_limit;
	production_daily_limit = production_daily_limit_get();

	if (_add_new_capacity)
	{
		production_daily_remaining = min(
			production_daily_limit,
			production_daily_remaining + max(0, production_daily_limit - _old_limit)
		);
	}
	else
	{
		production_daily_remaining = min(production_daily_remaining, production_daily_limit);
	}

	if (production_bonus_stat_name != "")
	{
		building_tooltip_detail = "Daily limit: " + string(production_daily_limit) + ". Bonus: "
			+ production_bonus_stat_name + " +" + string(BALANCE_RESOURCE_BUILDING_STAT_SPEED_BONUS) + "x per point";
	}
};

production_daily_limit_upgrade_resource_get = function()
{
	if (object_index == o_quarry)
	{
		return RESOURCES.FLESH;
	}

	if (object_index == o_souls_well)
	{
		return RESOURCES.IRON;
	}

	return RESOURCES.SOULS;
};

production_daily_limit_upgrade_next_cost_get = function()
{
	var _next_level = min(
		production_daily_limit_upgrade_level_get() + 1,
		BALANCE_RESOURCE_BUILDING_DAILY_LIMIT_UPGRADE_MAX
	);

	return BALANCE_RESOURCE_BUILDING_DAILY_LIMIT_UPGRADE_BASE_COST
		+ ((_next_level - 1) * BALANCE_RESOURCE_BUILDING_DAILY_LIMIT_UPGRADE_COST_GAIN);
};

production_daily_limit_upgrade_description_get = function()
{
	var _next_level = min(
		production_daily_limit_upgrade_level_get() + 1,
		BALANCE_RESOURCE_BUILDING_DAILY_LIMIT_UPGRADE_MAX
	);
	var _bonus_percent = round(BALANCE_RESOURCE_BUILDING_DAILY_LIMIT_UPGRADE_BONUS * 100);
	var _next_limit = floor(production_daily_base_limit * (1 + (_next_level * BALANCE_RESOURCE_BUILDING_DAILY_LIMIT_UPGRADE_BONUS)));

	return "+" + string(_bonus_percent) + "% daily resource limit. Next limit: " + string(_next_limit) + ".";
};

// Configure the first resource production buildings by object type.
if (object_index == o_slaughter_table)
{
	building_accepts_workers = true;
	production_resource = RESOURCES.FLESH;
	production_resource_name = "Flesh";
	production_resource_icon = s_flesh_icon;
	production_resource_color = COLOR_HUD_FLESH;
	production_daily_base_limit = BALANCE_RESOURCE_BUILDING_DAILY_LIMIT;
	production_daily_limit = production_daily_base_limit;
	production_daily_remaining = production_daily_limit;
	production_bonus_stat = CULTIST_STAT.FERVOR;
	production_bonus_stat_name = "FERVOR";
	production_bonus_stat_color = COLOR_CULTIST_FERVOR;
	building_tooltip_title = "Production";
	building_tooltip_description = "Produces Flesh";
	building_tooltip_detail = "Daily limit: " + string(BALANCE_RESOURCE_BUILDING_DAILY_LIMIT) + ". Bonus: " + production_bonus_stat_name + " +" + string(BALANCE_RESOURCE_BUILDING_STAT_SPEED_BONUS) + "x per point";
	building_tooltip_detail_color = production_bonus_stat_color;
	building_has_upgrades = true;
	building_upgrade_levels = [0, 0, 0];
	building_upgrade_flags = [false, false, false];
	building_upgrade_names = ["", "", ""];
	building_upgrade_descriptions = ["", "", ""];
	building_upgrade_costs = [BALANCE_BUILDING_UPGRADE_IRON_COST, BALANCE_BLOOD_POULTICE_UPGRADE_SOUL_COST, 0];
	building_upgrade_resources = [RESOURCES.IRON, RESOURCES.SOULS, RESOURCES.SOULS];
	production_daily_limit_upgrade_index = 2;
	building_upgrade_names[0] = "Faster Butchery";
	building_upgrade_descriptions[0] = "+0.5x Flesh production while at least one worker assigned.";
	building_upgrade_names[1] = "Blood Poultice";
	building_upgrade_descriptions[1] = "Slowly heals workers who assigned on this building.";
	production_secondary_effect_upgrade_index = 1;
	building_upgrade_names[2] = "Expanded Stores";
	building_upgrade_descriptions[2] = production_daily_limit_upgrade_description_get();
}
else if (object_index == o_quarry)
{
	building_accepts_workers = true;
	production_resource = RESOURCES.IRON;
	production_resource_name = "Iron";
	production_resource_icon = s_iron_icon;
	production_resource_color = COLOR_HUD_IRON;
	production_daily_base_limit = BALANCE_RESOURCE_BUILDING_DAILY_LIMIT;
	production_daily_limit = production_daily_base_limit;
	production_daily_remaining = production_daily_limit;
	production_bonus_stat = CULTIST_STAT.BODY;
	production_bonus_stat_name = "BODY";
	production_bonus_stat_color = COLOR_CULTIST_BODY;
	building_tooltip_title = "Production";
	building_tooltip_description = "Produces Iron";
	building_tooltip_detail = "Daily limit: " + string(BALANCE_RESOURCE_BUILDING_DAILY_LIMIT) + ". Bonus: " + production_bonus_stat_name + " +" + string(BALANCE_RESOURCE_BUILDING_STAT_SPEED_BONUS) + "x per point";
	building_tooltip_detail_color = production_bonus_stat_color;
	building_has_upgrades = true;
	building_upgrade_levels = [0, 0];
	building_upgrade_flags = [false, false];
	building_upgrade_names = ["", ""];
	building_upgrade_descriptions = ["", ""];
	building_upgrade_costs = [BALANCE_BUILDING_UPGRADE_IRON_COST, 0];
	building_upgrade_resources = [RESOURCES.IRON, RESOURCES.FLESH];
	production_daily_limit_upgrade_index = 1;
	building_upgrade_names[0] = "Reinforced Tools";
	building_upgrade_descriptions[0] = "+0.5x Iron production while at least one worker assigned.";
	building_upgrade_names[1] = "Expanded Stores";
	building_upgrade_descriptions[1] = production_daily_limit_upgrade_description_get();
}
else if (object_index == o_souls_well)
{
	building_accepts_workers = true;
	production_resource = RESOURCES.SOULS;
	production_resource_name = "Souls";
	production_resource_icon = s_soul_icon;
	production_resource_color = COLOR_HUD_SOULS;
	production_daily_base_limit = BALANCE_RESOURCE_BUILDING_DAILY_LIMIT;
	production_daily_limit = production_daily_base_limit;
	production_daily_remaining = production_daily_limit;
	production_bonus_stat = CULTIST_STAT.SPIRIT;
	production_bonus_stat_name = "SPIRIT";
	production_bonus_stat_color = COLOR_CULTIST_SPIRIT;
	building_tooltip_title = "Production";
	building_tooltip_description = "Produces Souls";
	building_tooltip_detail = "Daily limit: " + string(BALANCE_RESOURCE_BUILDING_DAILY_LIMIT) + ". Bonus: " + production_bonus_stat_name + " +" + string(BALANCE_RESOURCE_BUILDING_STAT_SPEED_BONUS) + "x per point";
	building_tooltip_detail_color = production_bonus_stat_color;
	building_has_upgrades = true;
	building_upgrade_levels = [0, 0, 0];
	building_upgrade_flags = [false, false, false];
	building_upgrade_names = ["", "", ""];
	building_upgrade_descriptions = ["", "", ""];
	building_upgrade_costs = [BALANCE_BUILDING_UPGRADE_IRON_COST, BALANCE_BONE_WHISPER_UPGRADE_SOUL_COST, 0];
	building_upgrade_resources = [RESOURCES.IRON, RESOURCES.SOULS, RESOURCES.IRON];
	production_daily_limit_upgrade_index = 2;
	building_upgrade_names[0] = "Deeper Echo";
	building_upgrade_descriptions[0] = "+0.5x Souls production while at least one worker assigned.";
	building_upgrade_names[1] = "Bone Whisper";
	building_upgrade_descriptions[1] = "Slowly summons Skeletons while at least one worker assigned.";
	production_secondary_effect_upgrade_index = 1;
	building_upgrade_names[2] = "Expanded Stores";
	building_upgrade_descriptions[2] = production_daily_limit_upgrade_description_get();
}
else if (object_index == o_meat_bath)
{
	building_accepts_workers = true;
	production_resource_icon = s_flesh_icon;
	production_resource_color = COLOR_HUD_FLESH;
	building_tooltip_title = "Healing";
	building_tooltip_description = "Allows performing operations with blood.";
	building_tooltip_detail = "Uses " + string(BALANCE_MEAT_BATH_FLESH_COST) + " Flesh for " + string(BALANCE_MEAT_BATH_FLESH_HEAL_AMOUNT) + " HP";
	building_tooltip_detail_color = COLOR_HUD_FLESH;
}
else if (object_index == o_ritual_circle)
{
	building_accepts_workers = true;
	production_resource_icon = noone;
	production_resource_color = COLOR_CULTIST_SPIRIT;
	building_tooltip_title = "Training";
	building_tooltip_description = "Allows performing rituals that affect the next night.";
	building_tooltip_detail = "Gives " + string(BALANCE_RITUAL_CIRCLE_SOUL_EXP_AMOUNT) + " XP chunks. Also restores stamina while cultists work here.";
	building_tooltip_detail_color = COLOR_CULTIST_SPIRIT;
	building_has_upgrades = true;
	building_upgrade_names[0] = "Focused Chant";
	building_upgrade_descriptions[0] = "Ritual Circle gives XP " + string(BALANCE_RITUAL_CIRCLE_EXP_UPGRADE_MULTIPLIER) + "x faster.";
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
	building_tooltip_description = "Repairs the cannon wall and damaged structures";
	building_tooltip_detail = "Structures receive " + string(BALANCE_WORKSHOP_BUILDING_REPAIR_MULTIPLIER * 100) + "% repair. Bonus: " + production_bonus_stat_name + " +" + string(BALANCE_RESOURCE_BUILDING_STAT_SPEED_BONUS) + "x per point";
	building_tooltip_detail_color = production_bonus_stat_color;
}
else if (object_index == o_shell_factory)
{
	// Day events permanently increase this factory's contribution to each morning stockpile limit.
	shell_factory_hellcow_morning_limit_bonus = 0;
	shell_factory_first_aid_morning_limit_bonus = 0;
	shell_factory_taint_compost_morning_limit_bonus = 0;

	building_accepts_workers = true;
	production_resource_icon = s_shell_factory;
	production_resource_color = COLOR_PROJECTILE_BUILDING_SHELL;
	production_bonus_stat = CULTIST_STAT.BODY;
	production_bonus_stat_name = "BODY";
	production_bonus_stat_color = COLOR_CULTIST_BODY;
	building_tooltip_title = "Shell Production";
	building_tooltip_description = "Produces special shells while staffed and refills shell stockpiles every morning.";
	building_tooltip_detail = "Uses " + string(BALANCE_SHELL_FACTORY_SOUL_COST) + " Souls + "
		+ string(BALANCE_SHELL_FACTORY_IRON_COST) + " Iron while staffed. Morning stockpile: "
		+ string(BALANCE_SHELL_FACTORY_MORNING_HELLCOW_LIMIT) + " Hellcow, "
		+ string(BALANCE_SHELL_FACTORY_MORNING_FIRST_AID_LIMIT) + " First Aid Meat, "
		+ string(BALANCE_SHELL_FACTORY_MORNING_TAINT_COMPOST_LIMIT) + " Taint Compost. Bonus: "
		+ production_bonus_stat_name + " +" + string(BALANCE_RESOURCE_BUILDING_STAT_SPEED_BONUS) + "x per point";
	building_tooltip_detail_color = production_bonus_stat_color;
	building_has_upgrades = true;
	building_upgrade_levels = [0];
	building_upgrade_names = ["Emergency Shell"];
}
else if (object_index == o_foundry)
{
	building_accepts_workers = true;
	production_resource_icon = s_foundry;
	production_resource_color = COLOR_PROJECTILE_BUILDING_SHELL;
	production_bonus_stat = CULTIST_STAT.BODY;
	production_bonus_stat_name = "BODY";
	production_bonus_stat_color = COLOR_CULTIST_BODY;
	building_tooltip_title = "Foundry";
	building_tooltip_description = "Allows upgrading archdemons, demons, and undead.";
	building_tooltip_detail = "Click Foundry, choose a structure, then assign workers to forge its shell. Bonus: " + production_bonus_stat_name + " +" + string(BALANCE_RESOURCE_BUILDING_STAT_SPEED_BONUS) + "x per point";
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
else if (object_index == o_graveyard2)
{
	building_accepts_workers = true;
	production_resource_icon = s_soul_icon;
	production_resource_color = COLOR_HUD_SOULS;
	production_bonus_stat = CULTIST_STAT.SPIRIT;
	production_bonus_stat_name = "SPIRIT";
	production_bonus_stat_color = COLOR_CULTIST_SPIRIT;
	garrison_unit_object = o_skeleton;
	garrison_unit_base_limit = BALANCE_GRAVEYARD2_BASE_SKELETON_LIMIT;
	garrison_unit_spawn_bonus_per_upgrade = BALANCE_GRAVEYARD2_SKELETONS_PER_SUMMON_UPGRADE;
	summon_unit_object = o_skeleton;
	summon_cost_add(RESOURCES.IRON, BALANCE_SKELETON_SUMMON_IRON_COST);
	summon_cost_add(RESOURCES.SOULS, BALANCE_SKELETON_SUMMON_SOUL_COST);
	summon_duration = BALANCE_GRAVEYARD2_SKELETON_PRODUCTION_TIME;
	building_tooltip_title = "Garrison";
	building_tooltip_description = "Allows raising and upgrading undead.";
	building_tooltip_detail = "Each morning spawns: " + string(BALANCE_GRAVEYARD2_BASE_SKELETON_LIMIT) + " Skeletons. Workers make extra Skeletons with " + summon_cost_text_get() + ".";
	building_tooltip_detail_color = production_bonus_stat_color;
	building_has_upgrades = true;
	production_speed_upgrade_index = noone;
	building_upgrade_levels = array_create(3, 0);
	building_upgrade_names = ["Graves", "Bone Armor", "Bone Blades"];
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
else if (object_index == o_pitlings_pit2)
{
	building_accepts_workers = true;
	production_resource_icon = s_flesh_icon;
	production_resource_color = COLOR_HUD_FLESH;
	production_bonus_stat = CULTIST_STAT.FERVOR;
	production_bonus_stat_name = "FERVOR";
	production_bonus_stat_color = COLOR_CULTIST_FERVOR;
	garrison_unit_object = o_pitling;
	garrison_unit_base_limit = BALANCE_PITLINGS_PIT2_BASE_PITLING_LIMIT;
	garrison_unit_spawn_bonus_per_upgrade = BALANCE_PITLINGS_PIT2_PITLINGS_PER_SUMMON_UPGRADE;
	summon_unit_object = o_pitling;
	summon_cost_add(RESOURCES.FLESH, BALANCE_PITLING_SUMMON_FLESH_COST);
	summon_cost_add(RESOURCES.IRON, BALANCE_PITLING_SUMMON_IRON_COST);
	summon_duration = BALANCE_PITLINGS_PIT2_PITLING_PRODUCTION_TIME;
	building_tooltip_title = "Demon Events";
	building_tooltip_description = "Allows summoning and upgrading demons.";
	building_tooltip_detail = "Summon Mawlings, transform them, or reinforce existing demon squads.";
	building_tooltip_detail_color = production_bonus_stat_color;
	building_has_upgrades = true;
	production_speed_upgrade_index = noone;
	building_upgrade_levels = array_create(3, 0);
	building_upgrade_names = ["Brood", "Hide Wards", "Hellfire Claws"];
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
	building_tooltip_detail = "Uses " + summon_cost_text_get() + ". Keeps up to " + string(BALANCE_GOBLINS_PER_PIT_LIMIT) + " own Goblins. Goblins work +" + string(BALANCE_GOBLIN_WORK_SPEED_MULTIPLIER) + "x";
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
	if (object_index == o_ritual_circle
		|| object_index == o_meat_bath)
	{
		return 1;
	}

	if (!instance_exists(_worker)
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

building_spends_worker_stamina = function()
{
	return object_index == o_quarry
		|| object_index == o_slaughter_table
		|| object_index == o_souls_well
		|| object_index == o_workshop
		|| object_index == o_shell_factory
		|| (object_index == o_foundry && is_struct(foundry_selected_shell))
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

foundry_shell_select = function(_choice)
{
	if (object_index != o_foundry)
	{
		return false;
	}

	var _construction_costs = [];

	if (variable_struct_exists(_choice, "construction_costs"))
	{
		_construction_costs = _choice.construction_costs;
	}

	foundry_selected_shell = {
		building_object: _choice.building_object,
		building_sprite: _choice.building_sprite,
		building_name: _choice.building_name,
		construction_costs: _construction_costs
	};
	foundry_shell_progress = 0;
	building_warning_show("Selected " + _choice.building_name, COLOR_PROJECTILE_BUILDING_SHELL);

	return true;
};

foundry_shell_cancel = function(_refund_resources = true)
{
	if (object_index != o_foundry
		|| !is_struct(foundry_selected_shell))
	{
		return false;
	}

	if (_refund_resources
		&& variable_struct_exists(foundry_selected_shell, "construction_costs"))
	{
		var _costs = foundry_selected_shell.construction_costs;
		var _cost_count = array_length(_costs);
		var _popup_gap = 46;
		var _popup_start_x = x - ((_cost_count - 1) * _popup_gap * 0.5);

		for (var _cost_index = 0; _cost_index < _cost_count; ++_cost_index)
		{
			var _cost_data = _costs[_cost_index];
			var _resource = _cost_data.resource;
			var _cost = _cost_data.cost;
			var _cost_popup_x = _popup_start_x + (_cost_index * _popup_gap);

			global.resources[_resource] += _cost;
			resource_popup_create(_cost_popup_x, y - 40, _resource, _cost);
		}
	}

	building_warning_show("Forging canceled", COLOR_PROJECTILE_BUILDING_SHELL);
	foundry_selected_shell = noone;
	foundry_shell_progress = 0;
	return true;
};

foundry_workers_release = function()
{
	if (object_index != o_foundry)
	{
		return;
	}

	var _worker_count = array_length(worker_cultists);

	if (_worker_count <= 0)
	{
		return;
	}

	var _workers = array_create(_worker_count);

	for (var _copy_index = 0; _copy_index < _worker_count; ++_copy_index)
	{
		_workers[_copy_index] = worker_cultists[_copy_index];
	}

	if (instance_exists(o_game_controller))
	{
		var _game_controller = instance_find(o_game_controller, 0);

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

	worker_cultists = array_create(0);
	recalculate_production_speed_multiplier();
};

ritual_circle_workers_release = function()
{
	if (object_index != o_ritual_circle)
	{
		return;
	}

	var _worker_count = array_length(worker_cultists);

	if (_worker_count <= 0)
	{
		return;
	}

	var _workers = array_create(_worker_count);

	for (var _copy_index = 0; _copy_index < _worker_count; ++_copy_index)
	{
		_workers[_copy_index] = worker_cultists[_copy_index];
	}

	if (instance_exists(o_game_controller))
	{
		var _game_controller = instance_find(o_game_controller, 0);

		// Clear assignments through the controller so cultist state and UI stay in sync.
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

	worker_cultists = array_create(0);
	recalculate_production_speed_multiplier();
};

building_workers_release = function()
{
	var _worker_count = array_length(worker_cultists);

	if (_worker_count <= 0)
	{
		return;
	}

	var _workers = array_create(_worker_count);

	for (var _copy_index = 0; _copy_index < _worker_count; ++_copy_index)
	{
		_workers[_copy_index] = worker_cultists[_copy_index];
	}

	if (instance_exists(o_game_controller))
	{
		var _game_controller = instance_find(o_game_controller, 0);

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

	worker_cultists = array_create(0);
	recalculate_production_speed_multiplier();
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

building_worker_stamina_update = function()
{
	if (global.day_phase != DAY_PHASE.DAY
		|| !building_spends_worker_stamina())
	{
		return;
	}

	var _stamina_delta = -BALANCE_CULTIST_STAMINA_DRAIN_PER_SECOND
		* building_stamina_drain_multiplier_get()
		/ max(1, room_speed);

	var _worker_count = array_length(worker_cultists);

	for (var _worker_index = 0; _worker_index < _worker_count; ++_worker_index)
	{
		var _worker = worker_cultists[_worker_index];

		if (instance_exists(_worker)
			&& variable_instance_exists(_worker, "stamina_amount"))
		{
			var _stamina_before = _worker.stamina_amount;
			var _stamina_max = BALANCE_CULTIST_STAMINA_MAX;

			if (variable_instance_exists(_worker, "stamina_max"))
			{
				_stamina_max = _worker.stamina_max;
			}

			_worker.stamina_amount = clamp(_worker.stamina_amount + _stamina_delta, 0, _stamina_max);

			if (_stamina_before > 0
				&& _worker.stamina_amount <= 0
				&& variable_global_exists("tutorial_hint_trigger"))
			{
				global.tutorial_hint_trigger("stamina");
			}

			if (_stamina_before > 0
				&& _worker.stamina_amount <= 0
				&& instance_exists(o_game_controller))
			{
				var _game_controller = instance_find(o_game_controller, 0);

				if (variable_instance_exists(_game_controller, "clear_cultist_building_assignment"))
				{
					_game_controller.clear_cultist_building_assignment(_worker);
					return;
				}
			}
		}
	}
};

building_upgrade_can_buy = function(_upgrade_index)
{
	if (variable_instance_exists(id, "building_upgrade_levels"))
	{
		if (_upgrade_index < 0 || _upgrade_index >= array_length(building_upgrade_levels))
		{
			return false;
		}

		if (!building_upgrade_requirement_met(_upgrade_index))
		{
			return false;
		}

		if (object_index == o_shell_factory)
		{
			return building_has_upgrades
				&& building_upgrade_levels[_upgrade_index] < cannon_upgrade_level_max_get(_upgrade_index)
				&& global.resources[RESOURCES.IRON] >= shell_factory_upgrade_iron_cost_get(_upgrade_index)
				&& global.resources[RESOURCES.FLESH] >= shell_factory_upgrade_flesh_cost_get(_upgrade_index);
		}

		var _upgrade_resource = cannon_upgrade_resource_get(_upgrade_index);
		var _upgrade_cost = cannon_upgrade_next_cost_get(_upgrade_index);

		return building_has_upgrades
			&& building_upgrade_levels[_upgrade_index] < cannon_upgrade_level_max_get(_upgrade_index)
			&& global.resources[_upgrade_resource] >= _upgrade_cost;
	}

	if (_upgrade_index < 0 || _upgrade_index >= array_length(building_upgrade_flags))
	{
		return false;
	}

	if (!building_upgrade_requirement_met(_upgrade_index))
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
		if (!building_upgrade_requirement_met(_upgrade_index))
		{
			building_warning_show("Requires Settlement Expansion", COLOR_STATUS_NEGATIVE_RED);
			return false;
		}

		if (object_index == o_shell_factory
			&& variable_instance_exists(id, "building_upgrade_levels")
			&& _upgrade_index >= 0
			&& _upgrade_index < array_length(building_upgrade_levels))
		{
			var _missing_iron_cost = shell_factory_upgrade_iron_cost_get(_upgrade_index);
			var _missing_flesh_cost = shell_factory_upgrade_flesh_cost_get(_upgrade_index);

			if (global.resources[RESOURCES.IRON] < _missing_iron_cost)
			{
				building_warning_show("Need " + string(_missing_iron_cost) + " Iron", COLOR_STATUS_NEGATIVE_RED);
				return false;
			}

			if (global.resources[RESOURCES.FLESH] < _missing_flesh_cost)
			{
				building_warning_show("Need " + string(_missing_flesh_cost) + " Flesh", COLOR_STATUS_NEGATIVE_RED);
				return false;
			}
		}

		if (variable_instance_exists(id, "building_upgrade_levels")
			&& _upgrade_index >= 0
			&& _upgrade_index < array_length(building_upgrade_levels))
		{
			var _level_missing_resource = cannon_upgrade_resource_get(_upgrade_index);
			var _level_missing_cost = cannon_upgrade_next_cost_get(_upgrade_index);
			building_warning_show("Need " + string(_level_missing_cost) + " " + resource_name_get(_level_missing_resource), COLOR_STATUS_NEGATIVE_RED);
			return false;
		}

		if (_upgrade_index >= 0 && _upgrade_index < array_length(building_upgrade_costs))
		{
			var _missing_resource = building_upgrade_resources[_upgrade_index];
			building_warning_show("Need " + string(building_upgrade_costs[_upgrade_index]) + " " + resource_name_get(_missing_resource), COLOR_STATUS_NEGATIVE_RED);
		}

		return false;
	}

	if (variable_instance_exists(id, "building_upgrade_levels"))
	{
		if (object_index == o_shell_factory)
		{
			var _shell_upgrade_iron_cost = shell_factory_upgrade_iron_cost_get(_upgrade_index);
			var _shell_upgrade_flesh_cost = shell_factory_upgrade_flesh_cost_get(_upgrade_index);
			global.resources[RESOURCES.IRON] -= _shell_upgrade_iron_cost;
			global.resources[RESOURCES.FLESH] -= _shell_upgrade_flesh_cost;
			resource_popup_create(x - 18, y - production_bar_offset_y, RESOURCES.IRON, -_shell_upgrade_iron_cost);
			resource_popup_create(x + 18, y - production_bar_offset_y, RESOURCES.FLESH, -_shell_upgrade_flesh_cost);
			building_upgrade_levels[_upgrade_index]++;

			if (shell_factory_random_projectile_add())
			{
				building_warning_show("+1 shell", COLOR_PROJECTILE_BUILDING_SHELL);
			}

			recalculate_production_speed_multiplier();
			return true;
		}

		var _level_upgrade_cost = cannon_upgrade_next_cost_get(_upgrade_index);
		var _level_upgrade_resource = cannon_upgrade_resource_get(_upgrade_index);
		global.resources[_level_upgrade_resource] -= _level_upgrade_cost;
		resource_popup_create(x, y - production_bar_offset_y, _level_upgrade_resource, -_level_upgrade_cost);
		building_upgrade_levels[_upgrade_index]++;

		if (_upgrade_index >= 0 && _upgrade_index < array_length(building_upgrade_flags))
		{
			building_upgrade_flags[_upgrade_index] = building_upgrade_levels[_upgrade_index] > 0;
		}

		if (production_daily_limit_upgrade_index != noone
			&& _upgrade_index == production_daily_limit_upgrade_index)
		{
			production_daily_limit_refresh(true);
		}

		garrison_owned_units_stats_refresh();

		if (garrison_building_is_active() && _upgrade_index == 0)
		{
			garrison_morning_spawn_units();
		}

		recalculate_production_speed_multiplier();
		return true;
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
	var _pit_limit = BALANCE_GOBLINS_PER_PIT_LIMIT;

	if (object_index == o_goblins_pit
		&& array_length(building_upgrade_flags) > 0
		&& building_upgrade_flags[0])
	{
		_pit_limit = BALANCE_GOBLINS_PER_UPGRADED_PIT_LIMIT;
	}

	return _pit_limit;
};

goblins_pit_goblin_count_get = function()
{
	if (object_index != o_goblins_pit)
	{
		return 0;
	}

	var _owned_goblin_count = 0;
	var _goblin_count = instance_number(o_goblin);

	for (var _goblin_index = 0; _goblin_index < _goblin_count; ++_goblin_index)
	{
		var _goblin = instance_find(o_goblin, _goblin_index);

		if (instance_exists(_goblin)
			&& variable_instance_exists(_goblin, "owner_goblins_pit")
			&& _goblin.owner_goblins_pit == id)
		{
			_owned_goblin_count++;
		}
	}

	return _owned_goblin_count;
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

garrison_building_is_active = function()
{
	return garrison_unit_object != noone;
};

garrison_unit_limit_get = function()
{
	if (!garrison_building_is_active())
	{
		return 0;
	}

	var _summon_upgrade_level = 0;

	if (variable_instance_exists(id, "building_upgrade_levels")
		&& array_length(building_upgrade_levels) > 0)
	{
		_summon_upgrade_level = building_upgrade_levels[0];
	}

	return garrison_unit_base_limit + (_summon_upgrade_level * garrison_unit_spawn_bonus_per_upgrade);
};

garrison_owned_unit_count_get = function()
{
	if (!garrison_building_is_active())
	{
		return 0;
	}

	var _owned_count = 0;
	var _friendly_count = instance_number(o_friendly_units);

	for (var _friendly_index = 0; _friendly_index < _friendly_count; ++_friendly_index)
	{
		var _friendly_unit = instance_find(o_friendly_units, _friendly_index);

		if (instance_exists(_friendly_unit)
			&& _friendly_unit.object_index == garrison_unit_object
			&& variable_instance_exists(_friendly_unit, "owner_garrison_building")
			&& _friendly_unit.owner_garrison_building == id)
		{
			_owned_count++;
		}
	}

	return _owned_count;
};

garrison_unit_stats_apply = function(_unit)
{
	if (!instance_exists(_unit) || !garrison_building_is_active())
	{
		return;
	}

	var _armor_level = 0;
	var _damage_level = 0;

	if (variable_instance_exists(id, "building_upgrade_levels")
		&& array_length(building_upgrade_levels) > 2)
	{
		_armor_level = building_upgrade_levels[1];
		_damage_level = building_upgrade_levels[2];
	}

	_unit.settlement_garrison_unit = true;
	_unit.owner_garrison_building = id;

	if (variable_instance_exists(_unit, "summon_nights_remaining"))
	{
		_unit.summon_nights_remaining = 1;
	}

	if (garrison_unit_object == o_skeleton)
	{
		_unit.damage = BALANCE_SKELETON_DAMAGE * (1 + (_damage_level * BALANCE_GRAVEYARD2_DAMAGE_UPGRADE_BONUS));
		_unit.magic_damage = 0;
		_unit.armor = 100 * (1 + (_armor_level * BALANCE_GRAVEYARD2_ARMOR_UPGRADE_BONUS));
	}
	else if (garrison_unit_object == o_pitling)
	{
		_unit.damage = 0;
		_unit.magic_damage = BALANCE_PITLING_DAMAGE * (1 + (_damage_level * BALANCE_PITLINGS_PIT2_DAMAGE_UPGRADE_BONUS));
		_unit.magic_resistance = 100 * (1 + (_armor_level * BALANCE_PITLINGS_PIT2_ARMOR_UPGRADE_BONUS));
	}
};

garrison_unit_create = function(_spawn_x, _spawn_y)
{
	if (!garrison_building_is_active())
	{
		return noone;
	}

	var _summoned_unit = instance_create_layer(_spawn_x, _spawn_y, "Instances", garrison_unit_object);
	garrison_unit_stats_apply(_summoned_unit);
	return _summoned_unit;
};

garrison_owned_units_stats_refresh = function()
{
	if (!garrison_building_is_active())
	{
		return;
	}

	var _friendly_count = instance_number(o_friendly_units);

	for (var _friendly_index = 0; _friendly_index < _friendly_count; ++_friendly_index)
	{
		var _friendly_unit = instance_find(o_friendly_units, _friendly_index);

		if (instance_exists(_friendly_unit)
			&& _friendly_unit.object_index == garrison_unit_object
			&& variable_instance_exists(_friendly_unit, "owner_garrison_building")
			&& _friendly_unit.owner_garrison_building == id)
		{
			garrison_unit_stats_apply(_friendly_unit);
		}
	}
};

garrison_morning_spawn_units = function()
{
	// Graveyard and Demons Pit now create persistent squads exclusively through day events.
	if (object_index == o_graveyard2 || object_index == o_pitlings_pit2)
	{
		return;
	}

	if (!garrison_building_is_active())
	{
		return;
	}

	var _missing_count = max(0, garrison_unit_limit_get() - garrison_owned_unit_count_get());

	for (var _spawn_index = 0; _spawn_index < _missing_count; ++_spawn_index)
	{
		var _spawn_direction = random(360);
		var _spawn_distance = random(BALANCE_SUMMON_BUILDING_SPAWN_RADIUS);
		var _spawn_x = x + lengthdir_x(_spawn_distance, _spawn_direction);
		var _spawn_y = y + lengthdir_y(_spawn_distance, _spawn_direction);
		var _summoned_unit = garrison_unit_create(_spawn_x, _spawn_y);

		if (instance_exists(o_game_controller))
		{
			var _game_controller = instance_find(o_game_controller, 0);

			if (variable_instance_exists(_game_controller, "move_spawned_summoned_unit_to_cannon_inner"))
			{
				_game_controller.move_spawned_summoned_unit_to_cannon_inner(_summoned_unit);
			}
		}
	}
};

cannon_upgrade_level_max_get = function(_upgrade_index)
{
	if (object_index == o_shell_factory)
	{
		return BALANCE_SHELL_FACTORY_UPGRADE_MAX;
	}

	if (production_daily_limit_upgrade_index != noone)
	{
		if (_upgrade_index == production_daily_limit_upgrade_index)
		{
			return BALANCE_RESOURCE_BUILDING_DAILY_LIMIT_UPGRADE_MAX;
		}

		return 1;
	}

	if (!garrison_building_is_active())
	{
		return 1;
	}

	if (_upgrade_index == 0)
	{
		return object_index == o_graveyard2
			? BALANCE_GRAVEYARD2_SUMMON_UPGRADE_MAX
			: BALANCE_PITLINGS_PIT2_SUMMON_UPGRADE_MAX;
	}

	if (_upgrade_index == 1)
	{
		return object_index == o_graveyard2
			? BALANCE_GRAVEYARD2_ARMOR_UPGRADE_MAX
			: BALANCE_PITLINGS_PIT2_ARMOR_UPGRADE_MAX;
	}

	return object_index == o_graveyard2
		? BALANCE_GRAVEYARD2_DAMAGE_UPGRADE_MAX
		: BALANCE_PITLINGS_PIT2_DAMAGE_UPGRADE_MAX;
};

cannon_upgrade_display_level_get = function(_upgrade_index)
{
	return building_upgrade_levels[_upgrade_index];
};

cannon_upgrade_next_display_level_get = function(_upgrade_index)
{
	return min(building_upgrade_levels[_upgrade_index] + 1, cannon_upgrade_level_max_get(_upgrade_index));
};

cannon_upgrade_display_level_max_get = function(_upgrade_index)
{
	return cannon_upgrade_level_max_get(_upgrade_index);
};

cannon_upgrade_resource_get = function(_upgrade_index)
{
	if (object_index == o_shell_factory)
	{
		return RESOURCES.IRON;
	}

	if (production_daily_limit_upgrade_index != noone)
	{
		if (_upgrade_index == production_daily_limit_upgrade_index)
		{
			return production_daily_limit_upgrade_resource_get();
		}

		if (_upgrade_index >= 0 && _upgrade_index < array_length(building_upgrade_resources))
		{
			return building_upgrade_resources[_upgrade_index];
		}

		return RESOURCES.IRON;
	}

	if (_upgrade_index == 0)
	{
		return object_index == o_graveyard2 ? RESOURCES.SOULS : RESOURCES.FLESH;
	}

	if (_upgrade_index == 2)
	{
		return object_index == o_graveyard2 ? RESOURCES.FLESH : RESOURCES.SOULS;
	}

	return RESOURCES.IRON;
};

cannon_upgrade_next_cost_get = function(_upgrade_index)
{
	if (object_index == o_shell_factory)
	{
		var _shell_factory_next_level = min(building_upgrade_levels[_upgrade_index] + 1, BALANCE_SHELL_FACTORY_UPGRADE_MAX);

		if (_shell_factory_next_level == 1)
		{
			return BALANCE_SHELL_FACTORY_UPGRADE_IRON_COST_LEVEL_1;
		}

		if (_shell_factory_next_level == 2)
		{
			return BALANCE_SHELL_FACTORY_UPGRADE_IRON_COST_LEVEL_2;
		}

		return BALANCE_SHELL_FACTORY_UPGRADE_IRON_COST_LEVEL_3;
	}

	if (production_daily_limit_upgrade_index != noone)
	{
		if (_upgrade_index == production_daily_limit_upgrade_index)
		{
			return production_daily_limit_upgrade_next_cost_get();
		}

		if (_upgrade_index >= 0 && _upgrade_index < array_length(building_upgrade_costs))
		{
			return building_upgrade_costs[_upgrade_index];
		}

		return BALANCE_BUILDING_UPGRADE_IRON_COST;
	}

	var _current_upgrade_level = 0;

	if (_upgrade_index >= 0 && _upgrade_index < array_length(building_upgrade_levels))
	{
		_current_upgrade_level = building_upgrade_levels[_upgrade_index];
	}

	var _garrison_cost_gain = _current_upgrade_level * BALANCE_GARRISON_UPGRADE_COST_GAIN;

	if (_upgrade_index == 0)
	{
		var _summon_upgrade_cost = object_index == o_graveyard2
			? BALANCE_GRAVEYARD2_SUMMON_UPGRADE_SOUL_COST
			: BALANCE_PITLINGS_PIT2_SUMMON_UPGRADE_FLESH_COST;

		return _summon_upgrade_cost + _garrison_cost_gain;
	}

	if (_upgrade_index == 1)
	{
		var _armor_upgrade_cost = object_index == o_graveyard2
			? BALANCE_GRAVEYARD2_ARMOR_UPGRADE_IRON_COST
			: BALANCE_PITLINGS_PIT2_ARMOR_UPGRADE_IRON_COST;

		return _armor_upgrade_cost + _garrison_cost_gain;
	}

	var _damage_upgrade_cost = object_index == o_graveyard2
		? BALANCE_GRAVEYARD2_DAMAGE_UPGRADE_FLESH_COST
		: BALANCE_PITLINGS_PIT2_DAMAGE_UPGRADE_SOUL_COST;

	return _damage_upgrade_cost + _garrison_cost_gain;
};

cannon_upgrade_cost_text_get = function(_upgrade_index)
{
	if (object_index == o_shell_factory)
	{
		return string(shell_factory_upgrade_iron_cost_get(_upgrade_index)) + " Iron + "
			+ string(shell_factory_upgrade_flesh_cost_get(_upgrade_index)) + " Flesh";
	}

	var _cost = cannon_upgrade_next_cost_get(_upgrade_index);
	var _resource = cannon_upgrade_resource_get(_upgrade_index);
	return string(_cost) + " " + resource_name_get(_resource);
};

building_upgrade_description_get = function(_upgrade_index)
{
	if (object_index == o_shell_factory)
	{
		return "Immediately produces 1 random special shell.";
	}

	if (production_daily_limit_upgrade_index != noone)
	{
		if (_upgrade_index == production_daily_limit_upgrade_index)
		{
			return production_daily_limit_upgrade_description_get();
		}

		if (_upgrade_index >= 0 && _upgrade_index < array_length(building_upgrade_descriptions))
		{
			var _description = building_upgrade_descriptions[_upgrade_index];

			if (!building_upgrade_requirement_met(_upgrade_index))
			{
				_description += " Requires Settlement Expansion.";
			}

			return _description;
		}

		return "";
	}

	if (_upgrade_index == 0)
	{
		var _bonus_count = object_index == o_graveyard2
			? BALANCE_GRAVEYARD2_SKELETONS_PER_SUMMON_UPGRADE
			: BALANCE_PITLINGS_PIT2_PITLINGS_PER_SUMMON_UPGRADE;
		var _unit_name = object_index == o_graveyard2 ? "Skeletons" : "Pitlings";

		return "+" + string(_bonus_count) + " morning " + _unit_name + " limit for this building.";
	}

	if (_upgrade_index == 1)
	{
		var _armor_text = object_index == o_graveyard2 ? "physical armor" : "magic armor";
		return "+8% " + _armor_text + " for units from this building.";
	}

	var _damage_text = object_index == o_graveyard2 ? "physical damage" : "magic damage";
	return "+8% " + _damage_text + " for units from this building.";
};

shell_factory_upgrade_iron_cost_get = function(_upgrade_index)
{
	var _next_level = min(building_upgrade_levels[_upgrade_index] + 1, BALANCE_SHELL_FACTORY_UPGRADE_MAX);

	if (_next_level == 1)
	{
		return BALANCE_SHELL_FACTORY_UPGRADE_IRON_COST_LEVEL_1;
	}

	if (_next_level == 2)
	{
		return BALANCE_SHELL_FACTORY_UPGRADE_IRON_COST_LEVEL_2;
	}

	return BALANCE_SHELL_FACTORY_UPGRADE_IRON_COST_LEVEL_3;
};

shell_factory_upgrade_flesh_cost_get = function(_upgrade_index)
{
	var _next_level = min(building_upgrade_levels[_upgrade_index] + 1, BALANCE_SHELL_FACTORY_UPGRADE_MAX);

	if (_next_level == 1)
	{
		return BALANCE_SHELL_FACTORY_UPGRADE_FLESH_COST_LEVEL_1;
	}

	if (_next_level == 2)
	{
		return BALANCE_SHELL_FACTORY_UPGRADE_FLESH_COST_LEVEL_2;
	}

	return BALANCE_SHELL_FACTORY_UPGRADE_FLESH_COST_LEVEL_3;
};

shell_factory_random_projectile_add = function()
{
	if (!instance_exists(o_game_controller))
	{
		return false;
	}

	var _game_controller = instance_find(o_game_controller, 0);

	if (!variable_instance_exists(_game_controller, "cannon_feast_bonus_projectile_roll")
		|| !variable_instance_exists(_game_controller, "cannon_projectile_queue_add"))
	{
		return false;
	}

	var _projectile_type = _game_controller.cannon_feast_bonus_projectile_roll();

	if (_projectile_type == noone)
	{
		return false;
	}

	return _game_controller.cannon_projectile_queue_add(_projectile_type);
};

shell_factory_morning_projectile_limit_get = function(_projectile_type)
{
	if (object_index != o_shell_factory)
	{
		return 0;
	}

	if (_projectile_type == PROJECTILE_TYPE.BOMB)
	{
		return BALANCE_SHELL_FACTORY_MORNING_HELLCOW_LIMIT
			+ shell_factory_hellcow_morning_limit_bonus;
	}

	if (_projectile_type == PROJECTILE_TYPE.HEAL)
	{
		return BALANCE_SHELL_FACTORY_MORNING_FIRST_AID_LIMIT
			+ shell_factory_first_aid_morning_limit_bonus;
	}

	if (_projectile_type == PROJECTILE_TYPE.CORRUPTION)
	{
		return BALANCE_SHELL_FACTORY_MORNING_TAINT_COMPOST_LIMIT
			+ shell_factory_taint_compost_morning_limit_bonus;
	}

	return 0;
};

building_tooltip_detail_get = function()
{
	if (garrison_building_is_active())
	{
		var _unit_name = object_index == o_graveyard2 ? "Skeletons" : "Pitlings";
		return "Each morning spawns: " + string(garrison_unit_limit_get()) + " " + _unit_name + ". Workers make extra " + _unit_name + " with " + summon_cost_text_get() + ".";
	}

	if (object_index == o_shell_factory)
	{
		var _hellcow_limit = shell_factory_morning_projectile_limit_get(PROJECTILE_TYPE.BOMB);
		var _first_aid_limit = shell_factory_morning_projectile_limit_get(PROJECTILE_TYPE.HEAL);
		var _taint_compost_limit = shell_factory_morning_projectile_limit_get(PROJECTILE_TYPE.CORRUPTION);

		return "Uses " + string(BALANCE_SHELL_FACTORY_SOUL_COST) + " Souls + "
			+ string(BALANCE_SHELL_FACTORY_IRON_COST) + " Iron while staffed. Morning stockpile: "
			+ string(_hellcow_limit) + " Hellcow, "
			+ string(_first_aid_limit) + " First Aid Meat, "
			+ string(_taint_compost_limit) + " Taint Compost. Bonus: "
			+ production_bonus_stat_name + " +" + string(BALANCE_RESOURCE_BUILDING_STAT_SPEED_BONUS) + "x per point";
	}

	if (object_index == o_goblins_pit)
	{
		return "Uses " + summon_cost_text_get() + ". Keeps up to "
			+ string(goblins_pit_goblin_limit_get()) + " own Goblins. Goblins work +"
			+ string(BALANCE_GOBLIN_WORK_SPEED_MULTIPLIER) + "x";
	}

	return building_tooltip_detail;
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
