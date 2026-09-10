// One squad or one pending recruitment event can reserve this daytime point.
assigned_squad = noone;
pending_squad_event = noone;
squad_point_state = -1;
image_speed = 0;

// The occupied-area sprite defines where this squad may wander during daytime.
var _area_sprite_width = sprite_exists(s_squad_point) ? sprite_get_width(s_squad_point) : 0;
var _area_sprite_height = sprite_exists(s_squad_point) ? sprite_get_height(s_squad_point) : 0;

squad_wander_radius_x = max(
	BALANCE_SQUAD_POINT_MINIMUM_RADIUS,
	(_area_sprite_width * abs(image_xscale) * 0.5) - BALANCE_SQUAD_POINT_MARGIN_X
);
squad_wander_radius_y = max(
	BALANCE_SQUAD_POINT_MINIMUM_RADIUS,
	(_area_sprite_height * abs(image_yscale) * 0.5) - BALANCE_SQUAD_POINT_MARGIN_Y
);

// Squad points recruit specialized undead and demon squads directly.
squad_point_choices = [
	{
		squad_name: "Skeleton Warrior Squad",
		squad_type: SQUAD_TYPE.UNDEAD,
		unit_object: o_skeleton_warrior,
		unit_count: BALANCE_SQUAD_SKELETON_COUNT,
		card_description: "Melee undead warriors.",
		event_description: "Recruit a Skeleton Warrior squad at the selected Squad Point."
	},
	{
		squad_name: "Skeleton Archer Squad",
		squad_type: SQUAD_TYPE.UNDEAD,
		unit_object: o_skeleton_archer,
		unit_count: BALANCE_SQUAD_SKELETON_COUNT,
		card_description: "Undead ranged archers.",
		event_description: "Recruit a Skeleton Archer squad at the selected Squad Point."
	},
	{
		squad_name: "Skeleton Mage Squad",
		squad_type: SQUAD_TYPE.UNDEAD,
		unit_object: o_skeleton_mage,
		unit_count: BALANCE_SQUAD_SKELETON_COUNT,
		card_description: "Undead spellcasters.",
		event_description: "Recruit a Skeleton Mage squad at the selected Squad Point."
	},
	{
		squad_name: "Succubus Squad",
		squad_type: SQUAD_TYPE.DEMON,
		unit_object: o_succubus,
		unit_count: BALANCE_SQUAD_PITLING_COUNT,
		card_description: "A squad of succubi.",
		event_description: "Recruit a Succubus squad at the selected Squad Point."
	},
	{
		squad_name: "Balgor Squad",
		squad_type: SQUAD_TYPE.DEMON,
		unit_object: o_balgor,
		unit_count: BALANCE_SQUAD_PITLING_COUNT,
		card_description: "A squad of balgors.",
		event_description: "Recruit a Balgor squad at the selected Squad Point."
	},
	{
		squad_name: "Pitling Squad",
		squad_type: SQUAD_TYPE.DEMON,
		unit_object: o_pitling,
		unit_count: BALANCE_SQUAD_PITLING_COUNT,
		card_description: "A squad of pitlings.",
		event_description: "Recruit a Pitling squad at the selected Squad Point."
	}
];

// Selection-window state and dimensions.
squad_point_selection_open = false;
squad_point_selection_previous_pause_state = false;
squad_point_hovered = false;
squad_point_hover_key = "";
squad_point_hover_scale = 1.04;
squad_point_hover_pulse_scale = 0.025;
squad_point_hover_pulse_speed = 0.008;
squad_point_hover_glow_scale = 0.1;
squad_point_hover_glow_alpha = 0.32;
squad_point_hover_label = "SUMMON SQUAD";
squad_point_hover_label_offset_y = 18;
squad_point_hover_label_padding_x = 10;
squad_point_hover_label_padding_y = 5;
squad_point_window_width = 900;
squad_point_window_height = 730;
squad_point_window_margin = 20;
squad_point_card_width = 260;
squad_point_card_height = 260;
squad_point_card_gap = 28;
squad_point_card_top = 124;
squad_point_card_columns = 3;
squad_point_card_sprite_size = 104;

squad_point_pending_event_is_active = function()
{
	if (!is_struct(pending_squad_event)
		|| !variable_global_exists("day_events")
		|| !is_array(global.day_events))
	{
		pending_squad_event = noone;
		return false;
	}

	// The reference is valid only while its reserving card remains in today's event list.
	for (var _event_index = 0; _event_index < array_length(global.day_events); ++_event_index)
	{
		var _event = global.day_events[_event_index];

		if (_event == pending_squad_event
			&& variable_struct_exists(_event, "reserves_squad_slot")
			&& _event.reserves_squad_slot)
		{
			return true;
		}
	}

	pending_squad_event = noone;
	return false;
};

squad_point_state_update = function()
{
	var _new_state = SQUAD_POINT_STATE.BLOCKED;

	if (is_struct(assigned_squad))
	{
		_new_state = SQUAD_POINT_STATE.OCCUPIED;
	}
	else if (global.day_phase == DAY_PHASE.DAY
		&& !squad_point_pending_event_is_active()
		&& squad_slot_is_available())
	{
		_new_state = SQUAD_POINT_STATE.AVAILABLE;
	}

	if (_new_state == squad_point_state)
	{
		return false;
	}

	squad_point_state = _new_state;
	image_index = 0;
	image_speed = 0;

	switch (squad_point_state)
	{
		case SQUAD_POINT_STATE.OCCUPIED:
			sprite_index = s_squad_point;
			break;

		case SQUAD_POINT_STATE.AVAILABLE:
			sprite_index = s_squad_point_available;
			break;

		default:
			// Blocked points remain active for state updates but draw no sprite.
			sprite_index = -1;
			break;
	}

	return true;
};

squad_point_gui_size_get = function()
{
	return [display_get_gui_width(), display_get_gui_height()];
};

squad_point_mouse_world_position_get = function()
{
	if (!instance_exists(o_camera_controller))
	{
		return [mouse_x, mouse_y];
	}

	var _camera_controller = instance_find(o_camera_controller, 0);
	var _mouse_gui_x = device_mouse_x_to_gui(0);
	var _mouse_gui_y = device_mouse_y_to_gui(0);
	var _camera_x = camera_get_view_x(_camera_controller.camera_id);
	var _camera_y = camera_get_view_y(_camera_controller.camera_id);
	var _camera_width = camera_get_view_width(_camera_controller.camera_id);
	var _camera_height = camera_get_view_height(_camera_controller.camera_id);
	var _gui_size = squad_point_gui_size_get();
	var _world_x = _camera_x + ((_mouse_gui_x / max(1, _gui_size[0])) * _camera_width);
	var _world_y = _camera_y + ((_mouse_gui_y / max(1, _gui_size[1])) * _camera_height);

	return [_world_x, _world_y];
};

squad_point_is_hovered = function()
{
	if (squad_point_state != SQUAD_POINT_STATE.AVAILABLE
		|| squad_point_selection_open
		|| global.day_phase != DAY_PHASE.DAY
		|| global.pause
		|| global.focus_window != FOCUS_WINDOW.NOONE)
	{
		return false;
	}

	var _mouse_position = squad_point_mouse_world_position_get();
	return _mouse_position[0] >= bbox_left
		&& _mouse_position[0] <= bbox_right
		&& _mouse_position[1] >= bbox_top
		&& _mouse_position[1] <= bbox_bottom;
};

squad_point_window_layout_get = function()
{
	var _gui_size = squad_point_gui_size_get();
	var _window_width = min(
		squad_point_window_width,
		max(1, _gui_size[0] - (squad_point_window_margin * 2))
	);
	var _window_height = min(
		squad_point_window_height,
		max(1, _gui_size[1] - (squad_point_window_margin * 2))
	);

	return {
		x: (_gui_size[0] - _window_width) * 0.5,
		y: (_gui_size[1] - _window_height) * 0.5,
		width: _window_width,
		height: _window_height,
		gui_width: _gui_size[0],
		gui_height: _gui_size[1]
	};
};

squad_point_choice_rect_get = function(_choice_index)
{
	var _layout = squad_point_window_layout_get();
	var _choice_count = max(1, array_length(squad_point_choices));
	var _columns = min(squad_point_card_columns, _choice_count);
	var _total_width = (squad_point_card_width * _columns)
		+ (squad_point_card_gap * max(0, _columns - 1));
	var _card_x = _layout.x + ((_layout.width - _total_width) * 0.5)
		+ ((squad_point_card_width + squad_point_card_gap) * (_choice_index mod _columns));
	var _card_y = _layout.y + squad_point_card_top
		+ ((squad_point_card_height + squad_point_card_gap) * floor(_choice_index / _columns));

	return [
		_card_x,
		_card_y,
		squad_point_card_width,
		squad_point_card_height
	];
};

squad_point_choice_hover_index_get = function(_mouse_x, _mouse_y)
{
	for (var _choice_index = 0; _choice_index < array_length(squad_point_choices); ++_choice_index)
	{
		var _rect = squad_point_choice_rect_get(_choice_index);

		if (point_in_rectangle(
			_mouse_x,
			_mouse_y,
			_rect[0],
			_rect[1],
			_rect[0] + _rect[2],
			_rect[1] + _rect[3]
		))
		{
			return _choice_index;
		}
	}

	return -1;
};

squad_point_choice_hover_key_get = function(_mouse_x, _mouse_y)
{
	if (!squad_point_selection_open)
	{
		return "";
	}

	var _choice_index = squad_point_choice_hover_index_get(_mouse_x, _mouse_y);
	return _choice_index >= 0
		? "squad_point_choice_" + string(id) + "_" + string(_choice_index)
		: "";
};

squad_point_selection_open_window = function()
{
	if (squad_point_state != SQUAD_POINT_STATE.AVAILABLE
		|| squad_point_selection_open
		|| global.day_phase != DAY_PHASE.DAY
		|| global.focus_window != FOCUS_WINDOW.NOONE
		|| array_length(squad_point_choices) <= 0)
	{
		return false;
	}

	squad_point_selection_open = true;
	squad_point_selection_previous_pause_state = global.pause;
	global.pause = true;
	global.focus_window = FOCUS_WINDOW.SQUAD_POINT_SELECTION;
	global.squad_point_selection_source = id;
	return true;
};

squad_point_selection_close = function()
{
	squad_point_selection_open = false;

	if (variable_global_exists("squad_point_selection_source")
		&& global.squad_point_selection_source == id)
	{
		global.squad_point_selection_source = noone;
	}

	global.pause = squad_point_selection_previous_pause_state;
	global.focus_window = FOCUS_WINDOW.NOONE;
};

squad_point_recruitment_event_create = function(_choice)
{
	if (squad_point_state != SQUAD_POINT_STATE.AVAILABLE)
	{
		return false;
	}

	var _event = day_event_squad_recruitment_create(id, _choice);

	if (!is_struct(_event))
	{
		return false;
	}

	squad_point_selection_close();
	squad_point_state_update();
	return true;
};

// Resolve the initial sprite after all point state has been initialized.
squad_point_state_update();
