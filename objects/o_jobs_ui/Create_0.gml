// Jobs window follows the 1920x1080 Figma composition and scales to the GUI.
jobs_design_width = 1920;
jobs_design_height = 1080;
jobs_panel_width = 864;
jobs_panel_height = 898;
jobs_pool_width = 700;
jobs_pool_height = 86;
jobs_event_height = 132;
jobs_event_gap = 6;
jobs_icon_width = 38;
jobs_icon_height = 60;
jobs_icon_gap = 18;
jobs_event_slot_start_x = 435;
jobs_event_slot_step = 58;
jobs_scroll_offset = 0;
jobs_scroll_step = 80;
jobs_scrollbar_width = 8;
jobs_scrollbar_gap = 12;
jobs_dragged_cultist = noone;
jobs_drag_origin_event = noone;
jobs_drag_origin_slot_index = -1;
jobs_hovered_cultist = noone;
jobs_hovered_empty_slot_key = "";
jobs_show_hovered = false;
jobs_end_hovered = false;
jobs_squad_selector_event = noone;
jobs_squad_selector_width = 150;
jobs_squad_selector_height = 28;
jobs_squad_selector_option_height = 30;

// Window-specific fonts match the Figma hierarchy.
jobs_title_font = font_add("Arial", 16, true, false, 32, 1279);
jobs_description_font = font_add("Arial", 9, false, false, 32, 1279);
jobs_button_font = font_add("Arial", 30, true, false, 32, 1279);
jobs_hp_font = font_add("Arial", 8, true, false, 32, 1279);
jobs_show_font = font_add("Arial", 30, true, false, 32, 1279);

jobs_layout_get = function()
{
	var _gui_width = display_get_gui_width();
	var _gui_height = display_get_gui_height();
	var _scale = min(_gui_width / jobs_design_width, _gui_height / jobs_design_height);
	var _panel_width = jobs_panel_width * _scale;
	var _panel_height = jobs_panel_height * _scale;
	var _panel_x = (_gui_width - _panel_width) * 0.5;
	var _panel_y = 69 * _scale;
	var _content_x = _panel_x + (82 * _scale);

	return {
		scale: _scale,
		panel_x: _panel_x,
		panel_y: _panel_y,
		panel_width: _panel_width,
		panel_height: _panel_height,
		pool_x: _content_x,
		pool_y: _panel_y + (36 * _scale),
		pool_width: jobs_pool_width * _scale,
		pool_height: jobs_pool_height * _scale,
		event_x: _content_x,
		event_y: _panel_y + (140 * _scale),
		event_width: jobs_pool_width * _scale,
		event_height: jobs_event_height * _scale,
		close_x: _panel_x + _panel_width - (72 * _scale),
		close_y: _panel_y + (10 * _scale),
		close_size: 56 * _scale,
		end_width: 325 * _scale,
		end_height: 61 * _scale,
		end_y: _panel_y + _panel_height + (12 * _scale)
	};
};

jobs_show_button_rect_get = function()
{
	var _gui_width = display_get_gui_width();
	var _gui_height = display_get_gui_height();
	var _scale = min(_gui_width / jobs_design_width, _gui_height / jobs_design_height);
	var _button_width = 353 * _scale;
	var _button_height = 88 * _scale;
	var _bottom_margin = 105 * _scale;

	return {
		x: (_gui_width - _button_width) * 0.5,
		y: _gui_height - _bottom_margin - _button_height,
		width: _button_width,
		height: _button_height,
		scale: _scale
	};
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

jobs_event_slot_rect_get = function(_event_index, _slot_index)
{
	var _layout = jobs_layout_get();
	var _event_rect = jobs_event_rect_get(_event_index);

	return {
		x: _event_rect.x
			+ (jobs_event_slot_start_x * _layout.scale)
			+ (_slot_index * jobs_event_slot_step * _layout.scale),
		y: _event_rect.y + (18 * _layout.scale),
		width: jobs_icon_width * _layout.scale,
		height: jobs_icon_height * _layout.scale
	};
};

jobs_pool_healthiest_cultist_get = function()
{
	var _healthiest_cultist = noone;
	var _highest_hp = -infinity;

	// Auto-assignment only considers currently available cultists in the pool.
	for (var _cultist_index = 0; _cultist_index < array_length(global.event_cultists); ++_cultist_index)
	{
		var _cultist = global.event_cultists[_cultist_index];

		if (!instance_exists(_cultist)
			|| is_struct(_cultist.assigned_event)
			|| !variable_instance_exists(_cultist, "is_available")
			|| !_cultist.is_available())
		{
			continue;
		}

		if (_cultist.hp > _highest_hp)
		{
			_healthiest_cultist = _cultist;
			_highest_hp = _cultist.hp;
		}
	}

	return _healthiest_cultist;
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
	var _hp_change = 0;
	var _is_sacrificed = false;

	if (!is_struct(_event) || !instance_exists(_cultist))
	{
		return { hp_change: 0, dies: false };
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
			_hp_change -= max(0, _action.data.hp_cost);
		}

		switch (_action.action_type)
		{
			case "produce_regular_shells":
				_hp_change -= 10;
				break;

			case "blood_bath":
				_hp_change += min(BALANCE_BLOOD_BATH_HEAL_AMOUNT, max(0, _cultist.max_hp - _cultist.hp));
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
							_hp_change -= BALANCE_BLOOD_TRANSFUSION_HEALTHY_DAMAGE;
						}
						else
						{
							var _new_max_hp = _cultist.max_hp + BALANCE_BLOOD_TRANSFUSION_MAX_HP_BONUS;
							_hp_change += min(
								BALANCE_BLOOD_TRANSFUSION_WOUNDED_HEAL,
								max(0, _new_max_hp - _cultist.hp)
							);
						}
					}
				}
				break;

			case "harden_the_vessel":
				_hp_change -= BALANCE_HARDEN_VESSEL_DAMAGE;
				break;

			case "the_bath_demands_a_name":
			case "blood_for_blood":
				_is_sacrificed = true;
				break;
		}
	}

	return {
		hp_change: _hp_change,
		dies: _is_sacrificed || _cultist.hp + _hp_change <= 0
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
		x: _layout.event_x,
		y: _layout.event_y,
		width: _layout.event_width,
		height: _layout.panel_y + _layout.panel_height - _layout.event_y - _bottom_padding
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
	var _content_height = (_event_count * jobs_event_height)
		+ (max(0, _event_count - 1) * jobs_event_gap);
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
					var _event_rect = jobs_event_rect_get(_event_index);
					return {
						x: _event_rect.x
							+ (jobs_event_slot_start_x * _layout.scale)
							+ (_slot_index * jobs_event_slot_step * _layout.scale),
						y: _event_rect.y + (18 * _layout.scale),
						width: _icon_width,
						height: _icon_height
					};
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
				x: _layout.pool_x + (215 * _layout.scale) + (_pool_index * _icon_step),
				y: _layout.pool_y + (5 * _layout.scale),
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
	jobs_squad_selector_event = noone;
	jobs_scroll_offset = 0;
	global.pause = true;
	global.focus_window = FOCUS_WINDOW.JOBS;
	return true;
};

jobs_window_close = function()
{
	jobs_dragged_cultist = noone;
	jobs_drag_origin_event = noone;
	jobs_drag_origin_slot_index = -1;
	jobs_hovered_cultist = noone;
	jobs_hovered_empty_slot_key = "";
	jobs_squad_selector_event = noone;

	if (global.focus_window == FOCUS_WINDOW.JOBS)
	{
		global.focus_window = FOCUS_WINDOW.NOONE;
		global.pause = false;
	}
};
