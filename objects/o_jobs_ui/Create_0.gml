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
		text: "Each building gives one random Job per day.",
		text_x: 839,
		text_y: 164,
		text_width: 228,
		arrow_x: 1155,
		arrow_y: 194,
		arrow_angle: 0
	},
	{
		text: "If the required number of Cultists is assigned to the Job, it will be completed tomorrow morning.",
		text_x: 1123,
		text_y: 620,
		text_width: 250,
		arrow_x: 1179,
		arrow_y: 505,
		arrow_angle: 90
	},
	{
		text: "You can pin 1 Job per day, so it will remain available tomorrow.\nYou can also reroll 1 Job per day.\nSome Jobs cannot be rerolled or pinned.",
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

	if (!is_struct(_event) || !instance_exists(_cultist))
	{
		return {
			hp_change: 0,
			hp_loss: 0,
			hp_gain: 0,
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
		}

		if (variable_struct_exists(_action, "data")
			&& is_struct(_action.data)
			&& variable_struct_exists(_action.data, "hp_share"))
		{
			var _hp_share_cost = _cultist.max_hp * max(0, _action.data.hp_share);
			_hp_loss += _hp_share_cost;
			_lethal_hp_loss += _hp_share_cost;
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
				break;

			case "blood_for_blood":
				_hp_loss += BALANCE_BLOOD_FOR_BLOOD_DAMAGE;
				_lethal_hp_loss += BALANCE_BLOOD_FOR_BLOOD_DAMAGE;
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

	// Sulking adds the same visible HP cost to every funded event slot.
	var _sulking_hp_cost = cannon_satisfaction_event_hp_cost_get();
	_hp_loss += _sulking_hp_cost;
	_lethal_hp_loss += _sulking_hp_cost;

	return {
		hp_change: _hp_gain - _hp_loss,
		hp_loss: _hp_loss,
		hp_gain: _hp_gain,
		loses_consciousness: _cultist.hp - _lethal_hp_loss <= 0
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
	jobs_hovered_empty_slot_key = "";
	jobs_hovered_event_action_key = "";
	jobs_squad_selector_event = noone;
	jobs_scroll_offset = 0;
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
	jobs_hovered_empty_slot_key = "";
	jobs_hovered_event_action_key = "";
	jobs_squad_selector_event = noone;

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
