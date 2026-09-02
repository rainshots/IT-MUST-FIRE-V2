// Draw Jobs above gameplay indicators while keeping tutorial popups in front.
depth = DEPTH_JOBS_UI;

// Jobs window follows the right-docked 1920x1080 Figma composition and scales to the GUI.
jobs_design_width = 1920;
jobs_design_height = 1080;
jobs_panel_width = 821;
jobs_content_offset_x = 212;
jobs_pool_y = 44;
jobs_pool_width = 456;
jobs_pool_height = 85;
jobs_pool_cultist_start_x = 107;
jobs_pool_cultist_y = 10;
jobs_whip_home_offset_x = 58;
jobs_whip_home_offset_y = 55;
jobs_whip_home_scale = 0.4;
jobs_whip_held_scale = 0.5;
jobs_whip_tooltip_offset_y = 42;
jobs_whip_tooltip_padding_x = 8;
jobs_whip_tooltip_padding_y = 5;
jobs_whip_tooltip_margin = 8;
jobs_whip_tooltip_background_alpha = 0.9;
jobs_whip_pickup_hint = "Hold LMB to hold a whip.";
jobs_whip_target_hint = "Press RMB to satisfy cannon demon";
jobs_whip = instance_create_layer(0, 0, layer, o_whip);
jobs_whip_hovered = false;
jobs_event_y = 147;
jobs_event_width = 458;
jobs_event_height = 132;
jobs_event_gap = 6;
// Reminder shown after the final event card in the scrollable list.
jobs_event_footer_gap = 18;
jobs_event_footer_height = 34;
jobs_event_footer_text = "Don't forget that you can build buildings and towers. They require a Cultist, but do not cost HP.";
jobs_icon_width = 44;
jobs_icon_height = 60;
jobs_icon_gap = 8;
jobs_event_slot_y = 22;
jobs_event_slot_step = 52;
jobs_slot_hp_cost_offset_y = 10;
jobs_assigned_hp_preview_offset_y = 13;
jobs_hp_preview_row_step = 10;
jobs_hp_preview_row_hover_width = 48;
jobs_hp_modifier_tooltip_offset_y = 18;
jobs_hp_modifier_tooltip_padding_x = 8;
jobs_hp_modifier_tooltip_padding_y = 5;
jobs_hp_modifier_tooltip_margin = 8;
jobs_hp_modifier_tooltip_background_alpha = 0.94;
jobs_hp_modifier_source_sulking = "Cannon is Sulking";
jobs_hp_modifier_source_damaged_building = "Building was damaged during the night";
jobs_hp_modifier_source_specialization = "Cultist specialization";
jobs_hovered_hp_modifier_source = "";
jobs_result_unit_icon_center_x = 400;
jobs_result_unit_icon_center_y = 58;
jobs_result_unit_icon_size = 68;
jobs_source_icon_offset_x = 525;
jobs_source_icon_width = 74;
jobs_source_icon_height = 70;
// Specialization Jobs place three selectable result portraits before worker slots.
jobs_unit_choice_icon_start_x = 264;
jobs_unit_choice_icon_y = 35;
jobs_unit_choice_icon_size = 44;
jobs_unit_choice_icon_step = 58;
jobs_unit_choice_label_y = 92;
jobs_scroll_offset = 0;
jobs_scroll_step = 80;
jobs_scrollbar_width = 8;
jobs_scrollbar_gap = 12;
jobs_dragged_cultist = noone;
jobs_drag_origin_event = noone;
jobs_drag_origin_slot_index = -1;
jobs_hovered_cultist = noone;
// A stationary one-second hover opens a Cultist summary and completed-work history.
jobs_cultist_info_hover_target = noone;
jobs_cultist_info_cultist = noone;
jobs_cultist_info_hover_frames = 0;
jobs_cultist_info_hover_delay_seconds = 0.15;
jobs_cultist_info_width = 250;
jobs_cultist_info_header_height = 128;
jobs_cultist_info_icon_size = 52;
jobs_cultist_info_icon_gap = 8;
jobs_cultist_info_padding = 12;
jobs_cultist_info_margin = 12;
// Assigned Cultists explain the RMB shortcut below the hover hand.
jobs_unassign_hint_text = "RMB to unassign";
jobs_unassign_hint_offset_y = 36;
jobs_unassign_hint_padding_x = 7;
jobs_unassign_hint_padding_y = 4;
jobs_unassign_hint_screen_margin = 8;
jobs_unassign_hint_background_alpha = 0.86;
jobs_hovered_empty_slot_key = "";
jobs_show_hovered = false;
jobs_end_hovered = false;
// Unlocks End Day after the player has opened Cultist Assignment once.
jobs_window_opened_once = false;
jobs_confirmation_cancel_hovered = false;
jobs_confirmation_end_hovered = false;
jobs_confirmation_previous_pause_state = false;
// Prevent a click that closed another window from activating the Jobs HUD beneath it.
jobs_input_blocked_until_mouse_release = false;
jobs_squad_selector_event = noone;
jobs_squad_selector_width = 150;
jobs_squad_selector_height = 28;
jobs_squad_selector_option_height = 30;
jobs_event_action_width = 54;
jobs_event_action_height = 54;
jobs_reroll_action_x = 462;
jobs_pin_action_x = 462;
jobs_reroll_action_y = 0;
jobs_pin_action_y = 55;
jobs_reroll_action_icon_y = 19;
jobs_pin_action_icon_y = 79;
jobs_reroll_action_label_y = 40;
jobs_pin_action_label_y = 96;
jobs_reroll_icon_scale = 0.625;
jobs_pin_icon_scale = 0.52;
jobs_hovered_event_action_key = "";
jobs_camera_visual_zoom = 0.5;
jobs_show_button_width = 313;
jobs_show_button_height = 80;
jobs_show_button_right_margin = 53;
jobs_show_button_top = 58;
// Assignment onboarding hint uses offsets from the Figma HUD composition.
jobs_assignment_hint_text_offset_x = -502;
jobs_assignment_hint_text_offset_y = 172;
jobs_assignment_hint_arrow_tip_offset_x = 19;
jobs_assignment_hint_arrow_tip_offset_y = 68;
jobs_assignment_hint_arrow_scale = 0.5;
jobs_assignment_hint_arrow_angle = 45;
// First-day Assign Duties onboarding follows the annotated 1920x1080 Figma composition.
jobs_onboarding_design_panel_x = 1099;
jobs_onboarding_arrow_scale = 0.5;
jobs_onboarding_text_line_height = 22;
jobs_onboarding_hints = [
	{
		text: "Unassigned Cultists",
		text_x: 953,
		text_y: 69,
		text_width: 228,
		arrow_x: 1274,
		arrow_y: 93,
		arrow_angle: 0
	},
	{
		text: "Each building gives one random Rite per day.",
		text_x: 839,
		text_y: 164,
		text_width: 228,
		arrow_x: 1155,
		arrow_y: 194,
		arrow_angle: 0
	},
	{
		text: "If the required number of Cultists is assigned to the Rite, it will be completed tomorrow morning.",
		text_x: 1123,
		text_y: 620,
		text_width: 250,
		arrow_x: 1179,
		arrow_y: 505,
		arrow_angle: 90
	},
	{
		text: "You can pin 1 Rite per day, so it will remain available tomorrow.\nSome Rites cannot be pinned.",
		text_with_reroll: "You can pin 1 Rite per day, so it will remain available tomorrow.\nYou can also reroll building Rites while the Cannon is Playful or better.\nSome Rites cannot be rerolled or pinned.",
		text_x: 1625,
		text_y: 620,
		text_width: 250,
		arrow_x: 1807,
		arrow_y: 505,
		arrow_angle: 90
	}
];
// Second-day Cannon Satisfaction introduction follows the annotated Figma composition.
jobs_cannon_satisfaction_hint_text = "The Cannon is possessed, moody, and bored. "
	+ "Fulfill its demands to raise Satisfaction and earn unholy bonuses. "
	+ "Ignore it and the whole cult suffers.";
jobs_cannon_satisfaction_hint_text_x = 752;
jobs_cannon_satisfaction_hint_text_y = 151;
jobs_cannon_satisfaction_hint_text_width = 322;
jobs_cannon_satisfaction_hint_text_line_height = 30;
jobs_cannon_satisfaction_hint_arrow_x = 1184;
jobs_cannon_satisfaction_hint_arrow_y = 211;
jobs_cannon_satisfaction_hint_arrow_scale = 0.5;
jobs_end_day_button_width = 353;
jobs_end_day_button_height = 88;
jobs_end_day_button_bottom_margin = 65;
jobs_end_day_button_text_padding_x = 20;
jobs_end_day_button_text_padding_y = 12;
jobs_first_archdemon_event_id = day_event_world_archdemon_event_id_get(1);
jobs_first_archdemon_assignment_prompt = "Summon a Archdemon in\nthe assign duties window";
jobs_confirmation_width = 860;
jobs_confirmation_height = 270;
jobs_confirmation_padding = 42;
jobs_confirmation_button_width = 260;
jobs_confirmation_button_height = 70;
jobs_confirmation_button_bottom_margin = 34;

// Window-specific fonts match the Figma hierarchy.
jobs_title_font = font_add("Arial", 16, true, false, 32, 1279);
jobs_description_font = font_add("Arial", 9, false, false, 32, 1279);
jobs_button_font = font_add("Arial", 30, true, false, 32, 1279);
jobs_hp_font = font_add("Arial", 8, true, false, 32, 1279);
jobs_show_font = font_add("Arial", 25, true, false, 32, 1279);
jobs_action_font = font_add("Arial", 12, false, false, 32, 1279);
jobs_world_action_font = WORLD_EVENT_INTERFACE_ENABLED
	? font_add("Arial", 13, true, false, 32, 1279)
	: -1;
jobs_onboarding_font = font_add("Arial", 20, true, false, 32, 1279);

jobs_layout_get = function()
{
	var _gui_width = display_get_gui_width();
	var _gui_height = display_get_gui_height();
	var _scale = min(_gui_width / jobs_design_width, _gui_height / jobs_design_height);
	var _panel_width = jobs_panel_width * _scale;
	var _panel_height = _gui_height;
	var _panel_x = _gui_width - _panel_width;
	var _panel_y = 0;
	var _content_x = _panel_x + (jobs_content_offset_x * _scale);

	return {
		scale: _scale,
		panel_x: _panel_x,
		panel_y: _panel_y,
		panel_width: _panel_width,
		panel_height: _panel_height,
		pool_x: _content_x,
		pool_y: _panel_y + (jobs_pool_y * _scale),
		pool_width: jobs_pool_width * _scale,
		pool_height: jobs_pool_height * _scale,
		event_x: _content_x,
		event_y: _panel_y + (jobs_event_y * _scale),
		event_width: jobs_event_width * _scale,
		event_height: jobs_event_height * _scale,
		close_x: _panel_x + _panel_width - (64 * _scale),
		close_y: _panel_y + (10 * _scale),
		close_size: 56 * _scale
	};
};

jobs_whip_home_position_get = function()
{
	var _layout = jobs_layout_get();

	return [
		_layout.pool_x + (jobs_whip_home_offset_x * _layout.scale),
		_layout.pool_y + (jobs_whip_home_offset_y * _layout.scale)
	];
};

jobs_whip_rect_get = function()
{
	if (!instance_exists(jobs_whip) || !sprite_exists(jobs_whip.sprite_index))
	{
		return noone;
	}

	var _layout = jobs_layout_get();
	var _home_position = jobs_whip_home_position_get();
	var _sprite = jobs_whip.sprite_index;
	var _sprite_scale = jobs_whip_home_scale * _layout.scale;
	var _sprite_width = sprite_get_width(_sprite) * _sprite_scale;
	var _sprite_height = sprite_get_height(_sprite) * _sprite_scale;
	var _sprite_origin_x = sprite_get_xoffset(_sprite) * _sprite_scale;
	var _sprite_origin_y = sprite_get_yoffset(_sprite) * _sprite_scale;

	return {
		x: _home_position[0] - _sprite_origin_x,
		y: _home_position[1] - _sprite_origin_y,
		width: _sprite_width,
		height: _sprite_height
	};
};

jobs_event_action_rect_get = function(_event_index, _action)
{
	var _layout = jobs_layout_get();
	var _event_rect = jobs_event_rect_get(_event_index);
	var _action_x = _action == "reroll"
		? jobs_reroll_action_x
		: jobs_pin_action_x;
	var _action_y = _action == "reroll"
		? jobs_reroll_action_y
		: jobs_pin_action_y;

	return {
		x: _event_rect.x + (_action_x * _layout.scale),
		y: _event_rect.y + (_action_y * _layout.scale),
		width: jobs_event_action_width * _layout.scale,
		height: jobs_event_action_height * _layout.scale
	};
};

jobs_event_action_key_get = function(_event, _action)
{
	if (!is_struct(_event)
		|| !variable_struct_exists(_event, "event_id"))
	{
		return "";
	}

	var _action_key = _action + ":" + _event.event_id;

	if (variable_struct_exists(_event, "source_building")
		&& instance_exists(_event.source_building))
	{
		_action_key += ":" + string(_event.source_building.id);
	}

	return _action_key;
};

jobs_event_pin_action_get = function(_event)
{
	if (!day_event_building_action_is_available(_event)
		|| (variable_struct_exists(_event, "can_pin") && !_event.can_pin))
	{
		return "";
	}

	if (day_event_pin_is_event(_event))
	{
		return "unpin";
	}

	return global.day_event_pins_remaining > 0
		&& !day_event_has_funded_activation(_event)
		&& !day_event_pin_source_is_active(_event.source_building)
		? "pin"
		: "";
};

jobs_show_button_rect_get = function()
{
	var _gui_width = display_get_gui_width();
	var _gui_height = display_get_gui_height();
	var _scale = min(_gui_width / jobs_design_width, _gui_height / jobs_design_height);
	var _button_width = jobs_show_button_width * _scale;
	var _button_height = jobs_show_button_height * _scale;

	return {
		x: _gui_width - _button_width - (jobs_show_button_right_margin * _scale),
		y: jobs_show_button_top * _scale,
		width: _button_width,
		height: _button_height,
		scale: _scale
	};
};

jobs_end_day_button_rect_get = function()
{
	var _gui_width = display_get_gui_width();
	var _gui_height = display_get_gui_height();
	var _scale = min(_gui_width / jobs_design_width, _gui_height / jobs_design_height);
	var _button_width = jobs_end_day_button_width * _scale;
	var _button_height = jobs_end_day_button_height * _scale;

	return {
		x: (_gui_width - _button_width) * 0.5,
		y: _gui_height - _button_height - (jobs_end_day_button_bottom_margin * _scale),
		width: _button_width,
		height: _button_height,
		scale: _scale
	};
};

jobs_end_day_is_visible = function()
{
	return jobs_window_opened_once;
};

jobs_first_archdemon_assignment_is_missing = function()
{
	if (!jobs_window_opened_once
		|| global.day_phase != DAY_PHASE.DAY
		|| day_event_current_day_get() != 1)
	{
		return false;
	}

	// Find the required first-day world Job and keep prompting until its slot is occupied.
	for (var _event_index = 0; _event_index < array_length(global.day_events); ++_event_index)
	{
		var _event = global.day_events[_event_index];

		if (is_struct(_event)
			&& variable_struct_exists(_event, "event_id")
			&& variable_struct_exists(_event, "assigned_cultists")
			&& _event.event_id == jobs_first_archdemon_event_id)
		{
			return array_length(_event.assigned_cultists) <= 0;
		}
	}

	return false;
};

jobs_end_day_button_text_get = function()
{
	return jobs_first_archdemon_assignment_is_missing()
		? jobs_first_archdemon_assignment_prompt
		: "END DAY";
};

jobs_end_day_is_actionable = function()
{
	return !jobs_first_archdemon_assignment_is_missing();
};

jobs_end_day_confirmation_layout_get = function()
{
	var _gui_width = display_get_gui_width();
	var _gui_height = display_get_gui_height();
	var _scale = min(_gui_width / jobs_design_width, _gui_height / jobs_design_height);
	var _panel_width = jobs_confirmation_width * _scale;
	var _panel_height = jobs_confirmation_height * _scale;
	var _panel_x = (_gui_width - _panel_width) * 0.5;
	var _panel_y = (_gui_height - _panel_height) * 0.5;
	var _button_width = jobs_confirmation_button_width * _scale;
	var _button_height = jobs_confirmation_button_height * _scale;
	var _button_y = _panel_y
		+ _panel_height
		- _button_height
		- (jobs_confirmation_button_bottom_margin * _scale);

	return {
		scale: _scale,
		panel_x: _panel_x,
		panel_y: _panel_y,
		panel_width: _panel_width,
		panel_height: _panel_height,
		cancel_x: _panel_x + (jobs_confirmation_padding * _scale),
		cancel_y: _button_y,
		cancel_width: _button_width,
		cancel_height: _button_height,
		end_x: _panel_x + _panel_width - _button_width - (jobs_confirmation_padding * _scale),
		end_y: _button_y,
		end_width: _button_width,
		end_height: _button_height
	};
};

jobs_unassigned_cultist_count_get = function()
{
	var _unassigned_count = 0;

	for (var _cultist_index = 0; _cultist_index < array_length(global.event_cultists); ++_cultist_index)
	{
		var _cultist = global.event_cultists[_cultist_index];

		if (instance_exists(_cultist)
			&& variable_instance_exists(_cultist, "is_available")
			&& _cultist.is_available())
		{
			_unassigned_count++;
		}
	}

	return _unassigned_count;
};

jobs_available_assignment_slot_count_get = function()
{
	var _available_slot_count = 0;

	for (var _event_index = 0; _event_index < array_length(global.day_events); ++_event_index)
	{
		var _event = global.day_events[_event_index];

		if (!is_struct(_event) || _event.is_resolved)
		{
			continue;
		}

		var _event_capacity = _event.cultist_cost * _event.activation_limit;
		_available_slot_count += max(0, _event_capacity - array_length(_event.assigned_cultists));
	}

	return _available_slot_count;
};

jobs_end_day_confirmation_close = function()
{
	if (global.focus_window != FOCUS_WINDOW.END_DAY_CONFIRMATION)
	{
		return false;
	}

	global.focus_window = FOCUS_WINDOW.NOONE;
	global.pause = jobs_confirmation_previous_pause_state;
	return true;
};

jobs_input_block_until_mouse_release = function()
{
	jobs_input_blocked_until_mouse_release = true;
	jobs_show_hovered = false;
	jobs_end_hovered = false;
	jobs_confirmation_cancel_hovered = false;
	jobs_confirmation_end_hovered = false;
};

jobs_end_day_execute = function()
{
	if (global.day_phase != DAY_PHASE.DAY)
	{
		return false;
	}

	// Close the jobs UI before an executed event opens its own mandatory window.
	if (global.focus_window == FOCUS_WINDOW.JOBS)
	{
		jobs_window_close();
	}
	else if (global.focus_window == FOCUS_WINDOW.END_DAY_CONFIRMATION)
	{
		jobs_end_day_confirmation_close();
	}

	day_event_finish_day();

	if (instance_exists(o_game_controller))
	{
		var _game_controller = instance_find(o_game_controller, 0);
		_game_controller.start_night_phase_after_day_events();
	}

	return true;
};

jobs_end_day_request = function()
{
	if (!jobs_end_day_is_visible()
		|| !jobs_end_day_is_actionable()
		|| global.day_phase != DAY_PHASE.DAY
		|| global.focus_window != FOCUS_WINDOW.NOONE)
	{
		return false;
	}

	var _unassigned_count = jobs_unassigned_cultist_count_get();
	var _available_slot_count = jobs_available_assignment_slot_count_get();

	if (_unassigned_count > 0 && _available_slot_count > 0)
	{
		jobs_confirmation_previous_pause_state = global.pause;
		global.pause = true;
		global.focus_window = FOCUS_WINDOW.END_DAY_CONFIRMATION;
		return true;
	}

	return jobs_end_day_execute();
};

jobs_event_rect_get = function(_event_index)
{
	var _layout = jobs_layout_get();
	var _event_step = (_layout.event_height + (jobs_event_gap * _layout.scale));

	return {
		x: _layout.event_x,
		y: _layout.event_y + (_event_step * _event_index) - (jobs_scroll_offset * _layout.scale),
		width: _layout.event_width,
		height: _layout.event_height
	};
};

jobs_event_slot_rect_get = function(_event_index, _slot_index, _slot_count = -1)
{
	var _layout = jobs_layout_get();
	var _event_rect = jobs_event_rect_get(_event_index);

	if (_slot_count < 0)
	{
		var _event = global.day_events[_event_index];
		_slot_count = _event.cultist_cost * _event.activation_limit;
	}

	var _slot_distance = (_slot_count - _slot_index) * jobs_event_slot_step * _layout.scale;

	return {
		x: _event_rect.x - _slot_distance,
		y: _event_rect.y + (jobs_event_slot_y * _layout.scale),
		width: jobs_icon_width * _layout.scale,
		height: jobs_icon_height * _layout.scale
	};
};

jobs_event_result_unit_object_get = function(_event)
{
	// Choice Jobs preview the unit currently selected by the player.
	if (is_struct(_event)
		&& variable_struct_exists(_event, "unit_choice_options")
		&& is_array(_event.unit_choice_options)
		&& variable_struct_exists(_event, "selected_unit_choice_index"))
	{
		var _choice_count = array_length(_event.unit_choice_options);
		var _choice_index = floor(_event.selected_unit_choice_index);

		if (_choice_index >= 0 && _choice_index < _choice_count)
		{
			var _choice = _event.unit_choice_options[_choice_index];

			if (is_struct(_choice)
				&& variable_struct_exists(_choice, "target_unit_object"))
			{
				return _choice.target_unit_object;
			}
		}
	}

	if (!is_struct(_event)
		|| !variable_struct_exists(_event, "actions")
		|| !is_array(_event.actions))
	{
		return noone;
	}

	// Unit Jobs store the deterministic result in their action data.
	for (var _action_index = 0; _action_index < array_length(_event.actions); ++_action_index)
	{
		var _action = _event.actions[_action_index];

		if (!is_struct(_action))
		{
			continue;
		}

		var _action_type = variable_struct_exists(_action, "action_type")
			? _action.action_type
			: "";

		// Draft Jobs obtain the most common unit from the selected squad.
		if ((_action_type == "fill_demon_ranks"
				|| _action_type == "draft_demons"
				|| _action_type == "draft_skeletons")
			&& variable_struct_exists(_event, "selected_squad")
			&& is_struct(_event.selected_squad)
			&& variable_struct_exists(_event.selected_squad, "unit_objects")
			&& is_array(_event.selected_squad.unit_objects)
			&& array_length(_event.selected_squad.unit_objects) > 0)
		{
			var _unit_objects = _event.selected_squad.unit_objects;
			var _most_common_object = _unit_objects[0];
			var _most_common_count = 0;

			for (var _candidate_index = 0; _candidate_index < array_length(_unit_objects); ++_candidate_index)
			{
				var _candidate_object = _unit_objects[_candidate_index];
				var _candidate_count = 0;

				for (var _unit_index = 0; _unit_index < array_length(_unit_objects); ++_unit_index)
				{
					if (_unit_objects[_unit_index] == _candidate_object)
					{
						_candidate_count++;
					}
				}

				if (_candidate_count > _most_common_count)
				{
					_most_common_count = _candidate_count;
					_most_common_object = _candidate_object;
				}
			}

			return _most_common_object;
		}

		if (!variable_struct_exists(_action, "data")
			|| !is_struct(_action.data))
		{
			continue;
		}

		if (variable_struct_exists(_action.data, "target_unit_object"))
		{
			return _action.data.target_unit_object;
		}

		if (variable_struct_exists(_action.data, "unit_object"))
		{
			return _action.data.unit_object;
		}
	}

	return noone;
};

jobs_event_result_unit_icon_rect_get = function(_event_index)
{
	var _layout = jobs_layout_get();
	var _event_rect = jobs_event_rect_get(_event_index);
	var _icon_size = jobs_result_unit_icon_size * _layout.scale;

	return {
		x: _event_rect.x + (jobs_result_unit_icon_center_x * _layout.scale) - (_icon_size * 0.5),
		y: _event_rect.y + (jobs_result_unit_icon_center_y * _layout.scale) - (_icon_size * 0.5),
		width: _icon_size,
		height: _icon_size
	};
};

jobs_event_unit_choice_icon_rect_get = function(_event_index, _choice_index)
{
	var _layout = jobs_layout_get();
	var _event_rect = jobs_event_rect_get(_event_index);
	var _icon_size = jobs_unit_choice_icon_size * _layout.scale;

	return {
		x: _event_rect.x
			+ ((jobs_unit_choice_icon_start_x
				+ (_choice_index * jobs_unit_choice_icon_step)) * _layout.scale),
		y: _event_rect.y + (jobs_unit_choice_icon_y * _layout.scale),
		width: _icon_size,
		height: _icon_size
	};
};

jobs_event_empty_slot_hp_cost_text_get = function(_event)
{
	var _fixed_hp_cost = 0;
	var _hp_share_cost = 0;

	if (!is_struct(_event)
		|| !variable_struct_exists(_event, "actions")
		|| !is_array(_event.actions))
	{
		return "";
	}

	// Costs stored in action data do not depend on the assigned cultist.
	for (var _action_index = 0; _action_index < array_length(_event.actions); ++_action_index)
	{
		var _action = _event.actions[_action_index];

		if (!is_struct(_action))
		{
			continue;
		}

		if (variable_struct_exists(_action, "data") && is_struct(_action.data))
		{
			if (variable_struct_exists(_action.data, "hp_cost"))
			{
				_fixed_hp_cost += max(0, _action.data.hp_cost);
			}

			if (variable_struct_exists(_action.data, "hp_share"))
			{
				_hp_share_cost += max(0, _action.data.hp_share);
			}
		}

		// These fixed costs are encoded by their specialized action callbacks.
		switch (_action.action_type)
		{
			case "harden_the_vessel":
				_fixed_hp_cost += BALANCE_HARDEN_VESSEL_DAMAGE;
				break;

			case "the_bath_demands_a_name":
				_fixed_hp_cost += BALANCE_BATH_DEMANDS_NAME_DAMAGE;
				break;

			case "blood_for_blood":
				_fixed_hp_cost += BALANCE_BLOOD_FOR_BLOOD_DAMAGE;
				break;
		}
	}

	if (_fixed_hp_cost > 0 && _hp_share_cost > 0)
	{
		return "-" + string(round(_fixed_hp_cost)) + " HP -" + string(round(_hp_share_cost * 100)) + "% HP";
	}

	if (_fixed_hp_cost > 0)
	{
		return "-" + string(round(_fixed_hp_cost)) + " HP";
	}

	if (_hp_share_cost > 0)
	{
		return "-" + string(round(_hp_share_cost * 100)) + "% HP";
	}

	return "";
};

jobs_event_cultist_slot_index_get = function(_event, _cultist)
{
	if (!is_struct(_event) || !instance_exists(_cultist))
	{
		return -1;
	}

	for (var _slot_index = 0; _slot_index < array_length(_event.assigned_cultists); ++_slot_index)
	{
		if (_event.assigned_cultists[_slot_index] == _cultist)
		{
			return _slot_index;
		}
	}

	return -1;
};

jobs_event_cultist_hp_preview_get = function(_event, _slot_index, _cultist)
{
	var _hp_loss = 0;
	var _hp_gain = 0;
	var _lethal_hp_loss = 0;
	var _specialization_eligible_hp_loss = 0;

	if (!is_struct(_event) || !instance_exists(_cultist))
	{
		return {
			hp_change: 0,
			hp_loss: 0,
			hp_gain: 0,
			sulking_hp_cost: 0,
			damaged_building_hp_cost: 0,
			specialization_hp_discount: 0,
			loses_consciousness: false
		};
	}

	for (var _action_index = 0; _action_index < array_length(_event.actions); ++_action_index)
	{
		var _action = _event.actions[_action_index];

		if (!is_struct(_action))
		{
			continue;
		}

		if (variable_struct_exists(_action, "data")
			&& is_struct(_action.data)
			&& variable_struct_exists(_action.data, "hp_cost"))
		{
			var _hp_cost = max(0, _action.data.hp_cost);
			_hp_loss += _hp_cost;
			_lethal_hp_loss += _hp_cost;
			_specialization_eligible_hp_loss += _hp_cost;
		}

		if (variable_struct_exists(_action, "data")
			&& is_struct(_action.data)
			&& variable_struct_exists(_action.data, "hp_share"))
		{
			var _hp_share_cost = _cultist.max_hp * max(0, _action.data.hp_share);
			_hp_loss += _hp_share_cost;
			_lethal_hp_loss += _hp_share_cost;
			_specialization_eligible_hp_loss += _hp_share_cost;
		}

		switch (_action.action_type)
		{
			case "crimson_baptism":
				_hp_gain += min(
					BALANCE_BLOOD_BATH_CRIMSON_MORNING_HEAL,
					max(0, _cultist.max_hp - _cultist.hp)
				);
				break;

			case "blood_bath":
				_hp_gain += min(
					BALANCE_BLOOD_BATH_HEAL_AMOUNT,
					max(0, _cultist.max_hp - _cultist.hp)
				);
				break;

			case "lingering_wounds":
				if (variable_instance_exists(_cultist, "blood_bath_morning_hp_snapshot"))
				{
					var _lingering_wounds_target_hp = clamp(
						_cultist.blood_bath_morning_hp_snapshot,
						0,
						_cultist.max_hp
					);

					if (_lingering_wounds_target_hp > _cultist.hp)
					{
						_hp_gain += _lingering_wounds_target_hp - _cultist.hp;
					}
					else
					{
						_hp_loss += _cultist.hp - _lingering_wounds_target_hp;
					}
				}
				break;

			case "blood_transfusion":
				if (array_length(_event.assigned_cultists) >= 2)
				{
					var _first_cultist = _event.assigned_cultists[0];
					var _second_cultist = _event.assigned_cultists[1];

					if (instance_exists(_first_cultist) && instance_exists(_second_cultist))
					{
						var _healthiest = _first_cultist.hp >= _second_cultist.hp
							? _first_cultist
							: _second_cultist;

						if (_cultist == _healthiest)
						{
							_hp_loss += BALANCE_BLOOD_TRANSFUSION_HEALTHY_DAMAGE;
							_lethal_hp_loss += BALANCE_BLOOD_TRANSFUSION_HEALTHY_DAMAGE;
							_specialization_eligible_hp_loss += BALANCE_BLOOD_TRANSFUSION_HEALTHY_DAMAGE;
						}
						else
						{
							_hp_gain += min(
								BALANCE_BLOOD_TRANSFUSION_WOUNDED_HEAL,
								max(0, _cultist.max_hp - _cultist.hp)
							);
						}
					}
				}
				break;

			case "harden_the_vessel":
				_hp_loss += BALANCE_HARDEN_VESSEL_DAMAGE;
				_lethal_hp_loss += BALANCE_HARDEN_VESSEL_DAMAGE;
				_specialization_eligible_hp_loss += BALANCE_HARDEN_VESSEL_DAMAGE;

				var _hardened_hp = _cultist.hp - _lethal_hp_loss;

				if (_hardened_hp > 0)
				{
					_hp_gain += min(
						BALANCE_HARDEN_VESSEL_MORNING_HEAL,
						max(0, _cultist.max_hp - _hardened_hp)
					);
				}
				break;

			case "the_bath_demands_a_name":
				_hp_loss += BALANCE_BATH_DEMANDS_NAME_DAMAGE;
				_lethal_hp_loss += BALANCE_BATH_DEMANDS_NAME_DAMAGE;
				_specialization_eligible_hp_loss += BALANCE_BATH_DEMANDS_NAME_DAMAGE;
				break;

			case "blood_for_blood":
				_hp_loss += BALANCE_BLOOD_FOR_BLOOD_DAMAGE;
				_lethal_hp_loss += BALANCE_BLOOD_FOR_BLOOD_DAMAGE;
				_specialization_eligible_hp_loss += BALANCE_BLOOD_FOR_BLOOD_DAMAGE;
				break;

			case "blood_warpaint":
				var _warpaint_target_hp = min(
					_cultist.max_hp,
					BALANCE_BLOOD_WARPAINT_MORNING_HP
				);

				if (_warpaint_target_hp > _cultist.hp)
				{
					_hp_gain += _warpaint_target_hp - _cultist.hp;
				}
				else
				{
					_hp_loss += _cultist.hp - _warpaint_target_hp;
				}
				break;
		}
	}

	// Keep global and building costs separate from the Rite's own HP effect for the UI.
	var _sulking_hp_cost = cannon_satisfaction_event_hp_cost_get();
	var _damaged_building_hp_cost = day_event_damaged_building_hp_cost_get(_event);
	var _additional_hp_cost = _sulking_hp_cost + _damaged_building_hp_cost;
	_lethal_hp_loss += _additional_hp_cost;
	_specialization_eligible_hp_loss += _additional_hp_cost;
	var _specialization_hp_discount = min(
		day_event_cultist_specialization_hp_discount_get(_cultist, _event),
		_specialization_eligible_hp_loss
	);
	var _total_hp_loss = _hp_loss + _additional_hp_cost;

	return {
		hp_change: _hp_gain + _specialization_hp_discount - _total_hp_loss,
		hp_loss: _hp_loss,
		hp_gain: _hp_gain,
		sulking_hp_cost: _sulking_hp_cost,
		damaged_building_hp_cost: _damaged_building_hp_cost,
		specialization_hp_discount: _specialization_hp_discount,
		loses_consciousness: _cultist.hp
			- max(0, _lethal_hp_loss - _specialization_hp_discount) <= 0
	};
};

jobs_event_empty_slot_hp_rows_get = function(_event)
{
	var _rows = [];
	var _event_hp_text = jobs_event_empty_slot_hp_cost_text_get(_event);

	// The Rite's own HP cost is always the first, unmodified row.
	if (_event_hp_text != "")
	{
		array_push(_rows, {
			text: _event_hp_text,
			color: COLOR_STATUS_NEGATIVE_RED,
			source: ""
		});
	}

	var _sulking_hp_cost = cannon_satisfaction_event_hp_cost_get();

	if (_sulking_hp_cost > 0)
	{
		array_push(_rows, {
			text: "-" + string(round(_sulking_hp_cost)) + " HP",
			color: COLOR_STATUS_NEGATIVE_RED,
			source: jobs_hp_modifier_source_sulking
		});
	}

	var _damaged_building_hp_cost = day_event_damaged_building_hp_cost_get(_event);

	if (_damaged_building_hp_cost > 0)
	{
		array_push(_rows, {
			text: "-" + string(round(_damaged_building_hp_cost)) + " HP",
			color: COLOR_STATUS_NEGATIVE_RED,
			source: jobs_hp_modifier_source_damaged_building
		});
	}

	return _rows;
};

jobs_event_cultist_hp_rows_get = function(_event, _slot_index, _cultist)
{
	var _preview = jobs_event_cultist_hp_preview_get(_event, _slot_index, _cultist);
	var _rows = [];

	// Base Rite HP changes are followed by every independent modifier.
	if (_preview.hp_loss > 0)
	{
		array_push(_rows, {
			text: "-" + string(round(_preview.hp_loss)) + " HP",
			color: COLOR_STATUS_NEGATIVE_RED,
			source: ""
		});
	}

	if (_preview.hp_gain > 0)
	{
		array_push(_rows, {
			text: "+" + string(round(_preview.hp_gain)) + " HP",
			color: COLOR_HEALTH_BAR,
			source: ""
		});
	}

	if (_preview.sulking_hp_cost > 0)
	{
		array_push(_rows, {
			text: "-" + string(round(_preview.sulking_hp_cost)) + " HP",
			color: COLOR_STATUS_NEGATIVE_RED,
			source: jobs_hp_modifier_source_sulking
		});
	}

	if (_preview.damaged_building_hp_cost > 0)
	{
		array_push(_rows, {
			text: "-" + string(round(_preview.damaged_building_hp_cost)) + " HP",
			color: COLOR_STATUS_NEGATIVE_RED,
			source: jobs_hp_modifier_source_damaged_building
		});
	}

	if (_preview.specialization_hp_discount > 0)
	{
		array_push(_rows, {
			text: "+" + string(round(_preview.specialization_hp_discount)) + " HP",
			color: COLOR_HEALTH_BAR,
			source: jobs_hp_modifier_source_specialization
		});
	}

	return {
		preview: _preview,
		rows: _rows
	};
};

jobs_hp_preview_row_rect_get = function(_slot_rect, _row_index, _offset_y)
{
	if (!is_struct(_slot_rect))
	{
		return noone;
	}

	var _layout = jobs_layout_get();
	var _row_step = jobs_hp_preview_row_step * _layout.scale;
	var _row_width = jobs_hp_preview_row_hover_width * _layout.scale;
	var _row_y = _slot_rect.y
		+ _slot_rect.height
		+ (_offset_y * _layout.scale)
		+ (_row_index * _row_step);

	return {
		x: _slot_rect.x + (_slot_rect.width * 0.5) - (_row_width * 0.5),
		y: _row_y,
		width: _row_width,
		height: _row_step
	};
};

jobs_squad_selector_rect_get = function(_event_index)
{
	var _layout = jobs_layout_get();
	var _event_rect = jobs_event_rect_get(_event_index);

	return {
		x: _event_rect.x + (270 * _layout.scale),
		y: _event_rect.y + (96 * _layout.scale),
		width: jobs_squad_selector_width * _layout.scale,
		height: jobs_squad_selector_height * _layout.scale
	};
};

jobs_squad_selector_option_rect_get = function(_event_index, _option_index)
{
	var _layout = jobs_layout_get();
	var _selector_rect = jobs_squad_selector_rect_get(_event_index);
	var _viewport = jobs_event_viewport_get();
	var _option_count = array_length(global.day_events[_event_index].eligible_squads);
	var _option_height = jobs_squad_selector_option_height * _layout.scale;
	var _options_y = _selector_rect.y + _selector_rect.height;

	if (_options_y + (_option_count * _option_height) > _viewport.y + _viewport.height)
	{
		_options_y = _selector_rect.y - (_option_count * _option_height);
	}

	return {
		x: _selector_rect.x,
		y: _options_y + (_option_index * _option_height),
		width: _selector_rect.width,
		height: _option_height
	};
};

jobs_event_viewport_get = function()
{
	var _layout = jobs_layout_get();
	var _bottom_padding = 12 * _layout.scale;

	return {
		x: _layout.panel_x,
		y: _layout.event_y,
		width: _layout.panel_width,
		height: _layout.panel_y + _layout.panel_height - _layout.event_y - _bottom_padding
	};
};

jobs_event_content_height_get = function()
{
	var _event_count = array_length(global.day_events);

	if (_event_count <= 0)
	{
		return 0;
	}

	var _event_cards_height = (_event_count * jobs_event_height)
		+ (max(0, _event_count - 1) * jobs_event_gap);

	return _event_cards_height + jobs_event_footer_gap + jobs_event_footer_height;
};

jobs_event_footer_rect_get = function()
{
	var _layout = jobs_layout_get();
	var _event_count = array_length(global.day_events);
	var _event_cards_height = (_event_count * jobs_event_height)
		+ (max(0, _event_count - 1) * jobs_event_gap);

	return {
		x: _layout.event_x,
		y: _layout.event_y
			+ ((_event_cards_height + jobs_event_footer_gap - jobs_scroll_offset) * _layout.scale),
		width: _layout.event_width,
		height: jobs_event_footer_height * _layout.scale
	};
};

jobs_scroll_max_get = function()
{
	var _event_count = array_length(global.day_events);

	if (_event_count <= 0)
	{
		return 0;
	}

	var _layout = jobs_layout_get();
	var _viewport = jobs_event_viewport_get();
	var _content_height = jobs_event_content_height_get();
	var _viewport_height = _viewport.height / max(0.01, _layout.scale);
	return max(0, _content_height - _viewport_height);
};

jobs_scroll_clamp = function()
{
	jobs_scroll_offset = clamp(jobs_scroll_offset, 0, jobs_scroll_max_get());
};

jobs_scissor_rect_get = function(_gui_rect)
{
	var _gui_width = max(1, display_get_gui_width());
	var _gui_height = max(1, display_get_gui_height());
	var _window_width = max(1, window_get_width());
	var _window_height = max(1, window_get_height());
	var _scale_x = _window_width / _gui_width;
	var _scale_y = _window_height / _gui_height;

	return {
		x: floor(_gui_rect.x * _scale_x),
		y: floor(_gui_rect.y * _scale_y),
		w: ceil(_gui_rect.width * _scale_x),
		h: ceil(_gui_rect.height * _scale_y)
	};
};

jobs_cultist_rect_get = function(_cultist)
{
	if (!instance_exists(_cultist))
	{
		return noone;
	}

	var _layout = jobs_layout_get();
	var _icon_width = jobs_icon_width * _layout.scale;
	var _icon_height = jobs_icon_height * _layout.scale;
	var _icon_step = _icon_width + (jobs_icon_gap * _layout.scale);

	if (is_struct(_cultist.assigned_event))
	{
		for (var _event_index = 0; _event_index < array_length(global.day_events); ++_event_index)
		{
			var _event = global.day_events[_event_index];

			if (_event != _cultist.assigned_event)
			{
				continue;
			}

			for (var _slot_index = 0; _slot_index < array_length(_event.assigned_cultists); ++_slot_index)
			{
				if (_event.assigned_cultists[_slot_index] == _cultist)
				{
					return jobs_event_slot_rect_get(_event_index, _slot_index);
				}
			}
		}
	}

	var _pool_index = 0;

	for (var _cultist_index = 0; _cultist_index < array_length(global.event_cultists); ++_cultist_index)
	{
		var _pool_cultist = global.event_cultists[_cultist_index];

		if (!instance_exists(_pool_cultist) || is_struct(_pool_cultist.assigned_event))
		{
			continue;
		}

		if (_pool_cultist == _cultist)
		{
			return {
				x: _layout.pool_x
					+ (jobs_pool_cultist_start_x * _layout.scale)
					+ (_pool_index * _icon_step),
				y: _layout.pool_y + (jobs_pool_cultist_y * _layout.scale),
				width: _icon_width,
				height: _icon_height
			};
		}

		_pool_index++;
	}

	return noone;
};

jobs_hp_modifier_hover_update = function(_mouse_x, _mouse_y)
{
	jobs_hovered_hp_modifier_source = "";
	var _event_viewport = jobs_event_viewport_get();
	var _mouse_is_over_event_viewport = point_in_rectangle(
		_mouse_x,
		_mouse_y,
		_event_viewport.x,
		_event_viewport.y,
		_event_viewport.x + _event_viewport.width,
		_event_viewport.y + _event_viewport.height
	);

	if (!_mouse_is_over_event_viewport)
	{
		return false;
	}

	// Match the rows currently drawn for every occupied or empty event slot.
	for (var _event_index = 0; _event_index < array_length(global.day_events); ++_event_index)
	{
		var _event = global.day_events[_event_index];

		if (!is_struct(_event))
		{
			continue;
		}

		var _display_event = _event;
		var _reroll_preview_is_active = jobs_hovered_event_action_key
			== jobs_event_action_key_get(_event, "reroll")
			&& variable_struct_exists(_event, "reroll_preview_event")
			&& is_struct(_event.reroll_preview_event);

		if (_reroll_preview_is_active)
		{
			_display_event = _event.reroll_preview_event;
		}

		if (!variable_struct_exists(_display_event, "assigned_cultists")
			|| !is_array(_display_event.assigned_cultists))
		{
			continue;
		}

		var _slot_count = _display_event.cultist_cost * _display_event.activation_limit;
		var _assigned_count = array_length(_display_event.assigned_cultists);

		for (var _slot_index = 0; _slot_index < _slot_count; ++_slot_index)
		{
			var _slot_rect = jobs_event_slot_rect_get(_event_index, _slot_index, _slot_count);
			var _rows = [];
			var _row_offset_y = jobs_slot_hp_cost_offset_y;

			if (_slot_index < _assigned_count)
			{
				var _cultist = _display_event.assigned_cultists[_slot_index];

				if (!instance_exists(_cultist))
				{
					continue;
				}

				var _hp_rows = jobs_event_cultist_hp_rows_get(_display_event, _slot_index, _cultist);
				_rows = _hp_rows.rows;
				_row_offset_y = jobs_assigned_hp_preview_offset_y;
			}
			else
			{
				_rows = jobs_event_empty_slot_hp_rows_get(_display_event);
			}

			for (var _row_index = 0; _row_index < array_length(_rows); ++_row_index)
			{
				var _row = _rows[_row_index];

				if (!is_struct(_row) || _row.source == "")
				{
					continue;
				}

				var _row_rect = jobs_hp_preview_row_rect_get(
					_slot_rect,
					_row_index,
					_row_offset_y
				);

				if (point_in_rectangle(
					_mouse_x,
					_mouse_y,
					_row_rect.x,
					_row_rect.y,
					_row_rect.x + _row_rect.width,
					_row_rect.y + _row_rect.height
				))
				{
					jobs_hovered_hp_modifier_source = _row.source;
					return true;
				}
			}
		}
	}

	return false;
};

jobs_hp_modifier_tooltip_draw = function()
{
	if (jobs_hovered_hp_modifier_source == "")
	{
		return false;
	}

	var _layout = jobs_layout_get();
	var _scale = max(0.01, _layout.scale);
	var _padding_x = jobs_hp_modifier_tooltip_padding_x * _scale;
	var _padding_y = jobs_hp_modifier_tooltip_padding_y * _scale;
	var _margin = jobs_hp_modifier_tooltip_margin * _scale;
	var _offset_y = jobs_hp_modifier_tooltip_offset_y * _scale;
	var _mouse_x = device_mouse_x_to_gui(0);
	var _mouse_y = device_mouse_y_to_gui(0);
	var _gui_width = display_get_gui_width();
	var _gui_height = display_get_gui_height();

	draw_set_font(jobs_hp_font);
	var _tooltip_width = (string_width(jobs_hovered_hp_modifier_source) * _scale)
		+ (_padding_x * 2);
	var _tooltip_height = (string_height(jobs_hovered_hp_modifier_source) * _scale)
		+ (_padding_y * 2);
	var _tooltip_x = clamp(
		_mouse_x - (_tooltip_width * 0.5),
		_margin,
		max(_margin, _gui_width - _tooltip_width - _margin)
	);
	var _tooltip_y = _mouse_y + _offset_y;

	if (_tooltip_y + _tooltip_height > _gui_height - _margin)
	{
		_tooltip_y = _mouse_y - _tooltip_height - _offset_y;
	}

	_tooltip_y = clamp(
		_tooltip_y,
		_margin,
		max(_margin, _gui_height - _tooltip_height - _margin)
	);

	// Draw the source explanation next to the hovered modifier line.
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_alpha(jobs_hp_modifier_tooltip_background_alpha);
	draw_set_color(COLOR_JOBS_ASSIGN_BACKGROUND);
	draw_rectangle(
		_tooltip_x,
		_tooltip_y,
		_tooltip_x + _tooltip_width,
		_tooltip_y + _tooltip_height,
		false
	);
	draw_set_alpha(1);
	draw_set_color(COLOR_JOBS_SLOT_BORDER);
	draw_rectangle(
		_tooltip_x,
		_tooltip_y,
		_tooltip_x + _tooltip_width,
		_tooltip_y + _tooltip_height,
		true
	);
	draw_set_color(COLOR_JOBS_ASSIGN_TEXT);
	draw_text_transformed(
		_tooltip_x + _padding_x,
		_tooltip_y + _padding_y,
		jobs_hovered_hp_modifier_source,
		_scale,
		_scale,
		0
	);

	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
	draw_set_alpha(1);
	return true;
};

jobs_cultist_info_reset = function()
{
	jobs_cultist_info_hover_target = noone;
	jobs_cultist_info_cultist = noone;
	jobs_cultist_info_hover_frames = 0;
};

jobs_cultist_info_hover_update = function(_cultist)
{
	var _mouse_button_down = mouse_check_button(mb_left)
		|| mouse_check_button(mb_right);

	if (!instance_exists(_cultist) || _mouse_button_down)
	{
		jobs_cultist_info_reset();
		return false;
	}

	if (jobs_cultist_info_hover_target != _cultist)
	{
		jobs_cultist_info_hover_target = _cultist;
		jobs_cultist_info_cultist = noone;
		jobs_cultist_info_hover_frames = 1;
		return false;
	}

	var _hover_delay_frames = max(
		1,
		round(jobs_cultist_info_hover_delay_seconds * room_speed)
	);
	jobs_cultist_info_hover_frames = min(
		jobs_cultist_info_hover_frames + 1,
		_hover_delay_frames
	);

	if (jobs_cultist_info_hover_frames >= _hover_delay_frames)
	{
		jobs_cultist_info_cultist = _cultist;
		return true;
	}

	return false;
};

jobs_cultist_info_draw = function()
{
	var _cultist = jobs_cultist_info_cultist;

	if (!instance_exists(_cultist))
	{
		return false;
	}

	var _cultist_rect = jobs_cultist_rect_get(_cultist);

	if (!is_struct(_cultist_rect))
	{
		return false;
	}

	var _layout = jobs_layout_get();
	var _scale = max(0.01, _layout.scale);
	var _gui_width = display_get_gui_width();
	var _gui_height = display_get_gui_height();
	var _margin = jobs_cultist_info_margin * _scale;
	var _padding = jobs_cultist_info_padding * _scale;
	var _header_height = jobs_cultist_info_header_height * _scale;
	var _icon_size = jobs_cultist_info_icon_size * _scale;
	var _icon_gap = jobs_cultist_info_icon_gap * _scale;
	var _history = variable_instance_exists(_cultist, "work_history")
		&& is_array(_cultist.work_history)
		? _cultist.work_history
		: [];
	var _history_count = array_length(_history);
	var _available_history_height = max(
		_icon_size,
		_gui_height - (_margin * 2) - _header_height - (_padding * 2)
	);
	var _max_rows = max(
		1,
		floor((_available_history_height + _icon_gap) / (_icon_size + _icon_gap))
	);
	var _row_count = _history_count > 0 ? min(_history_count, _max_rows) : 1;
	var _column_count = _history_count > 0 ? ceil(_history_count / _max_rows) : 1;
	var _history_width = (_column_count * _icon_size)
		+ (max(0, _column_count - 1) * _icon_gap);
	var _panel_width = max(jobs_cultist_info_width * _scale, _history_width + (_padding * 2));
	var _history_height = (_row_count * _icon_size)
		+ (max(0, _row_count - 1) * _icon_gap);
	var _panel_height = _header_height + _history_height + (_padding * 2);
	var _panel_right = _layout.panel_x - _margin;
	var _panel_x = clamp(
		_panel_right - _panel_width,
		_margin,
		max(_margin, _gui_width - _panel_width - _margin)
	);
	var _panel_y = clamp(
		_cultist_rect.y,
		_margin,
		max(_margin, _gui_height - _panel_height - _margin)
	);
	var _content_x = _panel_x + _padding;
	var _history_y = _panel_y + _header_height + _padding;
	var _cultist_name = _cultist.cultist_name == "" ? "Unnamed" : _cultist.cultist_name;
	var _hp_text = "HP: " + string(max(0, ceil(_cultist.hp)))
		+ "/" + string(ceil(_cultist.max_hp));
	var _status_text = "Available";
	var _status_color = COLOR_HEALTH_BAR;
	var _specialization_name = "None";
	var _specialization_color = COLOR_HUD_PROJECTILE_DESCRIPTION;

	if (variable_instance_exists(_cultist, "is_unconscious") && _cultist.is_unconscious)
	{
		_status_text = "Unconscious";
		_status_color = COLOR_STATUS_NEGATIVE_RED;
	}
	else if (variable_instance_exists(_cultist, "assigned_event")
		&& is_struct(_cultist.assigned_event))
	{
		_status_text = "Assigned";
		_status_color = COLOR_JOBS_EVENT_ACTION;
	}

	if (variable_instance_exists(_cultist, "specialization_building_object")
		&& _cultist.specialization_building_object != noone
		&& variable_instance_exists(_cultist, "specialization_building_name")
		&& _cultist.specialization_building_name != "")
	{
		_specialization_name = _cultist.specialization_building_name;
		_specialization_color = COLOR_HEALTH_BAR;
	}

	// Draw the summary above a newest-first, top-to-bottom work history.
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_alpha(0.96);
	draw_set_color(COLOR_JOBS_ASSIGN_BACKGROUND);
	draw_rectangle(
		_panel_x,
		_panel_y,
		_panel_x + _panel_width,
		_panel_y + _panel_height,
		false
	);
	draw_set_alpha(1);
	draw_set_color(COLOR_JOBS_SLOT_BORDER);
	draw_rectangle(
		_panel_x,
		_panel_y,
		_panel_x + _panel_width,
		_panel_y + _panel_height,
		true
	);

	draw_set_font(jobs_action_font);
	draw_set_color(COLOR_JOBS_ASSIGN_TEXT);
	draw_text(_content_x, _panel_y + _padding, _cultist_name);
	draw_set_font(jobs_hp_font);
	draw_text(_content_x, _panel_y + (_padding + (26 * _scale)), _hp_text);
	draw_set_color(_status_color);
	draw_text(_content_x, _panel_y + (_padding + (46 * _scale)), _status_text);
	draw_set_color(_specialization_color);
	draw_text(
		_content_x,
		_panel_y + (_padding + (66 * _scale)),
		"Specialization: " + _specialization_name
	);
	draw_set_color(COLOR_JOBS_EVENT_ACTION);
	draw_text(_content_x, _panel_y + (_header_height - (24 * _scale)), "WORK HISTORY - NEWEST FIRST");

	if (_history_count <= 0)
	{
		draw_set_color(COLOR_HUD_PROJECTILE_DESCRIPTION);
		draw_text(_content_x, _history_y + (16 * _scale), "No completed Rites yet.");
	}
	else
	{
		for (var _display_index = 0; _display_index < _history_count; ++_display_index)
		{
			var _history_index = _history_count - 1 - _display_index;
			var _building_sprite = _history[_history_index];
			var _column = floor(_display_index / _max_rows);
			var _row = _display_index mod _max_rows;
			var _icon_x = _content_x + (_column * (_icon_size + _icon_gap));
			var _icon_y = _history_y + (_row * (_icon_size + _icon_gap));

			draw_set_alpha(0.72);
			draw_set_color(COLOR_HUD_BACKGROUND);
			draw_rectangle(
				_icon_x,
				_icon_y,
				_icon_x + _icon_size,
				_icon_y + _icon_size,
				false
			);
			draw_set_alpha(1);
			draw_set_color(COLOR_JOBS_SLOT_BORDER);
			draw_rectangle(
				_icon_x,
				_icon_y,
				_icon_x + _icon_size,
				_icon_y + _icon_size,
				true
			);

			if (sprite_exists(_building_sprite))
			{
				var _sprite_width = max(1, sprite_get_width(_building_sprite));
				var _sprite_height = max(1, sprite_get_height(_building_sprite));
				var _available_icon_size = max(1, _icon_size - (8 * _scale));
				var _sprite_scale = min(
					_available_icon_size / _sprite_width,
					_available_icon_size / _sprite_height
				);
				var _icon_center_x = _icon_x + (_icon_size * 0.5);
				var _icon_center_y = _icon_y + (_icon_size * 0.5);
				var _sprite_x = _icon_center_x
					+ ((sprite_get_xoffset(_building_sprite) - (_sprite_width * 0.5)) * _sprite_scale);
				var _sprite_y = _icon_center_y
					+ ((sprite_get_yoffset(_building_sprite) - (_sprite_height * 0.5)) * _sprite_scale);

				draw_sprite_ext(
					_building_sprite,
					0,
					_sprite_x,
					_sprite_y,
					_sprite_scale,
					_sprite_scale,
					0,
					c_white,
					1
				);
			}
		}
	}

	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
	draw_set_alpha(1);
	return true;
};

jobs_window_open = function()
{
	if (global.day_phase != DAY_PHASE.DAY || global.focus_window != FOCUS_WINDOW.NOONE)
	{
		return false;
	}

	jobs_dragged_cultist = noone;
	jobs_drag_origin_event = noone;
	jobs_drag_origin_slot_index = -1;
	jobs_hovered_cultist = noone;
	jobs_hovered_hp_modifier_source = "";
	jobs_hovered_empty_slot_key = "";
	jobs_hovered_event_action_key = "";
	jobs_squad_selector_event = noone;
	jobs_scroll_offset = 0;
	jobs_whip_hovered = false;
	jobs_cultist_info_reset();

	if (instance_exists(jobs_whip))
	{
		jobs_whip.whip_release();
	}

	jobs_window_opened_once = true;
	global.focus_window = FOCUS_WINDOW.JOBS;

	// Frame the Cannon in the center of the unobstructed left side without pausing simulation.
	if (instance_exists(o_camera_controller) && instance_exists(o_cannon))
	{
		var _camera_controller = instance_find(o_camera_controller, 0);

		if (variable_instance_exists(_camera_controller, "camera_jobs_view_open"))
		{
			var _layout = jobs_layout_get();
			var _panel_width_share = _layout.panel_width / max(1, display_get_gui_width());
			_camera_controller.camera_jobs_view_open(
				instance_find(o_cannon, 0),
				_panel_width_share,
				jobs_camera_visual_zoom
			);
		}
	}

	return true;
};

jobs_window_close = function()
{
	jobs_dragged_cultist = noone;
	jobs_drag_origin_event = noone;
	jobs_drag_origin_slot_index = -1;
	jobs_hovered_cultist = noone;
	jobs_hovered_hp_modifier_source = "";
	jobs_hovered_empty_slot_key = "";
	jobs_hovered_event_action_key = "";
	jobs_squad_selector_event = noone;
	jobs_whip_hovered = false;
	jobs_cultist_info_reset();

	if (instance_exists(jobs_whip))
	{
		jobs_whip.whip_release();
	}

	if (instance_exists(o_camera_controller))
	{
		var _camera_controller = instance_find(o_camera_controller, 0);

		if (variable_instance_exists(_camera_controller, "camera_jobs_view_close"))
		{
			_camera_controller.camera_jobs_view_close();
		}
	}

	if (global.focus_window == FOCUS_WINDOW.JOBS)
	{
		global.focus_window = FOCUS_WINDOW.NOONE;
	}
};

jobs_window_toggle = function()
{
	if (global.focus_window == FOCUS_WINDOW.JOBS)
	{
		jobs_window_close();
		return true;
	}

	return jobs_window_open();
};
