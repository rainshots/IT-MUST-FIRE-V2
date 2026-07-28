if (variable_global_exists("ui_font") && font_exists(global.ui_font))
{
	draw_set_font(global.ui_font);
}

if (global.day_phase == DAY_PHASE.DAY && global.focus_window == FOCUS_WINDOW.NOONE)
{
	var _show_rect = jobs_show_button_rect_get();
	var _show_pulse = 0.5 + (sin(current_time / 260) * 0.5);
	var _show_pulse_scale = 0.98 + (_show_pulse * 0.04);
	var _show_hover_scale = jobs_show_hovered ? 1.06 : 1;
	var _show_visual_scale = _show_pulse_scale * _show_hover_scale;
	var _show_center_x = _show_rect.x + (_show_rect.width * 0.5);
	var _show_center_y = _show_rect.y + (_show_rect.height * 0.5);
	var _show_visual_width = _show_rect.width * _show_visual_scale;
	var _show_visual_height = _show_rect.height * _show_visual_scale;
	var _show_visual_x = _show_center_x - (_show_visual_width * 0.5);
	var _show_visual_y = _show_center_y - (_show_visual_height * 0.5);

	// Pulse around the center and grow further while hovered without changing the hitbox.
	draw_set_alpha(1);
	draw_set_color(COLOR_JOBS_ASSIGN_BACKGROUND);
	draw_rectangle(
		_show_visual_x,
		_show_visual_y,
		_show_visual_x + _show_visual_width,
		_show_visual_y + _show_visual_height,
		false
	);

	draw_set_color(COLOR_JOBS_ASSIGN_BORDER);
	for (var _show_border_index = 0; _show_border_index < 2; ++_show_border_index)
	{
		draw_rectangle(
			_show_visual_x + _show_border_index,
			_show_visual_y + _show_border_index,
			_show_visual_x + _show_visual_width - _show_border_index,
			_show_visual_y + _show_visual_height - _show_border_index,
			true
		);
	}
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_set_color(COLOR_JOBS_ASSIGN_TEXT);
	draw_set_font(jobs_show_font);
	draw_text_transformed(
		_show_center_x,
		_show_center_y,
		"ASSIGN DUTIES",
		_show_rect.scale * _show_visual_scale,
		_show_rect.scale * _show_visual_scale,
		0
	);
}

if (global.focus_window == FOCUS_WINDOW.JOBS)
{
	var _layout = jobs_layout_get();
	var _gui_width = display_get_gui_width();
	var _gui_height = display_get_gui_height();

	// Darken the game behind the jobs window.
	draw_set_alpha(0.65);
	draw_set_color(c_black);
	draw_rectangle(0, 0, _gui_width, _gui_height, false);
	draw_set_alpha(1);

	// Main panel and available-cultist pool.
	draw_set_color(COLOR_JOBS_WINDOW_BACKGROUND);
	draw_rectangle(
		_layout.panel_x,
		_layout.panel_y,
		_layout.panel_x + _layout.panel_width,
		_layout.panel_y + _layout.panel_height,
		false
	);
	draw_set_color(COLOR_JOBS_POOL_BORDER);
	draw_rectangle(
		_layout.pool_x,
		_layout.pool_y,
		_layout.pool_x + _layout.pool_width,
		_layout.pool_y + _layout.pool_height,
		true
	);

	// Event cards and their required worker slots.
	var _event_viewport = jobs_event_viewport_get();
	var _event_scissor_viewport = {
		x: _layout.panel_x,
		y: _event_viewport.y,
		width: _layout.panel_width,
		height: _event_viewport.height
	};
	var _event_scissor = jobs_scissor_rect_get(_event_scissor_viewport);
	var _previous_scissor = gpu_get_scissor();
	gpu_set_scissor(_event_scissor);

	for (var _event_index = 0; _event_index < array_length(global.day_events); ++_event_index)
	{
		var _event = global.day_events[_event_index];
		var _event_rect = jobs_event_rect_get(_event_index);
		var _is_ready = _event.activation_ready_count_get() > 0;
		draw_set_color(_is_ready ? COLOR_JOBS_EVENT_ACTIVE : COLOR_JOBS_EVENT_INACTIVE);
		draw_rectangle(
			_event_rect.x,
			_event_rect.y,
			_event_rect.x + _event_rect.width,
			_event_rect.y + _event_rect.height,
			false
		);

		// Show the building or cannon that generated this event beside its card.
		var _source_sprite = noone;
		var _source_frame = 0;

		if (variable_struct_exists(_event, "source_sprite")
			&& sprite_exists(_event.source_sprite))
		{
			_source_sprite = _event.source_sprite;
		}
		else if (variable_struct_exists(_event, "source_building")
			&& instance_exists(_event.source_building)
			&& sprite_exists(_event.source_building.sprite_index))
		{
			_source_sprite = _event.source_building.sprite_index;
			_source_frame = _event.source_building.image_index;
		}

		if (sprite_exists(_source_sprite))
		{
			var _source_available_width = 64 * _layout.scale;
			var _source_available_height = 96 * _layout.scale;
			var _source_sprite_width = max(1, sprite_get_width(_source_sprite));
			var _source_sprite_height = max(1, sprite_get_height(_source_sprite));
			var _source_scale = min(
				_source_available_width / _source_sprite_width,
				_source_available_height / _source_sprite_height
			);
			var _source_width = _source_sprite_width * _source_scale;
			var _source_height = _source_sprite_height * _source_scale;
			var _source_area_center_x = _layout.panel_x
				+ ((_event_rect.x - _layout.panel_x) * 0.5);
			var _source_x = _source_area_center_x - (_source_width * 0.5);
			var _source_y = _event_rect.y + ((_event_rect.height - _source_height) * 0.5);

			draw_sprite_stretched_ext(
				_source_sprite,
				_source_frame,
				_source_x,
				_source_y,
				_source_width,
				_source_height,
				c_white,
				1
			);
		}

		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		draw_set_color(COLOR_JOBS_ASSIGN_TEXT);
		draw_set_font(jobs_title_font);
		draw_text(_event_rect.x + (34 * _layout.scale), _event_rect.y + (18 * _layout.scale), _event.title);
		draw_set_font(jobs_description_font);
		var _description_width = 390 * _layout.scale;
		var _has_archdemon_target = variable_struct_exists(_event, "target_archdemon_name")
			&& variable_struct_exists(_event, "target_archdemon_sprite")
			&& sprite_exists(_event.target_archdemon_sprite);

		if (_has_archdemon_target)
		{
			_description_width = 292 * _layout.scale;
		}

		draw_text_ext(
			_event_rect.x + (34 * _layout.scale),
			_event_rect.y + (48 * _layout.scale),
			_event.description,
			16 * _layout.scale,
			_description_width
		);

		// Targeted Foundry training shows the locked Archdemon portrait and name.
		if (_has_archdemon_target)
		{
			var _target_sprite = _event.target_archdemon_sprite;
			var _target_frame = variable_struct_exists(_event, "target_archdemon_frame")
				? _event.target_archdemon_frame
				: 0;
			var _target_center_x = _event_rect.x + (386 * _layout.scale);
			var _target_available_width = 42 * _layout.scale;
			var _target_available_height = 50 * _layout.scale;
			var _target_scale = min(
				_target_available_width / max(1, sprite_get_width(_target_sprite)),
				_target_available_height / max(1, sprite_get_height(_target_sprite))
			);
			var _target_width = sprite_get_width(_target_sprite) * _target_scale;
			var _target_height = sprite_get_height(_target_sprite) * _target_scale;
			var _target_x = _target_center_x - (_target_width * 0.5);
			var _target_y = _event_rect.y + (53 * _layout.scale);

			draw_set_halign(fa_center);
			draw_set_valign(fa_middle);
			draw_set_font(jobs_hp_font);
			draw_set_color(COLOR_JOBS_SLOT_BORDER);
			draw_text(_target_center_x, _event_rect.y + (46 * _layout.scale), "TARGET");
			draw_sprite_stretched_ext(
				_target_sprite,
				_target_frame,
				_target_x,
				_target_y,
				_target_width,
				_target_height,
				c_white,
				1
			);
			draw_set_color(COLOR_JOBS_ASSIGN_TEXT);
			draw_text(
				_target_center_x,
				_event_rect.y + (113 * _layout.scale),
				_event.target_archdemon_name
			);
			draw_set_halign(fa_left);
			draw_set_valign(fa_top);
		}

		if (variable_struct_exists(_event, "requires_squad_selection")
			&& _event.requires_squad_selection)
		{
			var _selector_rect = jobs_squad_selector_rect_get(_event_index);
			var _selector_text = "SELECT SQUAD";

			if (variable_struct_exists(_event, "selected_squad") && is_struct(_event.selected_squad))
			{
				_selector_text = _event.selected_squad.name;
			}

			draw_set_alpha(0.9);
			draw_set_color(COLOR_JOBS_ASSIGN_BACKGROUND);
			draw_rectangle(
				_selector_rect.x,
				_selector_rect.y,
				_selector_rect.x + _selector_rect.width,
				_selector_rect.y + _selector_rect.height,
				false
			);
			draw_set_alpha(1);
			draw_set_color(is_struct(_event.selected_squad) ? COLOR_JOBS_EVENT_ACTIVE : COLOR_JOBS_SLOT_BORDER);
			draw_rectangle(
				_selector_rect.x,
				_selector_rect.y,
				_selector_rect.x + _selector_rect.width,
				_selector_rect.y + _selector_rect.height,
				true
			);
			draw_set_halign(fa_center);
			draw_set_valign(fa_middle);
			draw_set_font(jobs_hp_font);
			draw_set_color(COLOR_JOBS_ASSIGN_TEXT);
			draw_text(
				_selector_rect.x + (_selector_rect.width * 0.5),
				_selector_rect.y + (_selector_rect.height * 0.5),
				_selector_text
			);
		}

		var _slot_count = _event.cultist_cost * _event.activation_limit;

		for (var _slot_index = 0; _slot_index < _slot_count; ++_slot_index)
		{
			var _slot_rect = jobs_event_slot_rect_get(_event_index, _slot_index);
			var _slot_x = _slot_rect.x;
			var _slot_y = _slot_rect.y;
			draw_set_color(COLOR_JOBS_SLOT_BORDER);
			draw_rectangle(
				_slot_x,
				_slot_y,
				_slot_x + _slot_rect.width,
				_slot_y + _slot_rect.height,
				true
			);

			// Empty slots show an enlarging plus as direct assignment affordance.
			if (_slot_index >= array_length(_event.assigned_cultists))
			{
				var _slot_key = string(_event_index) + ":" + string(_slot_index);
				var _plus_scale = jobs_hovered_empty_slot_key == _slot_key ? 1.35 : 1;
				var _plus_half_size = 7 * _layout.scale * _plus_scale;
				var _plus_line_width = 2 * _layout.scale * _plus_scale;
				var _plus_center_x = _slot_x + (_slot_rect.width * 0.5);
				var _plus_center_y = _slot_y + (_slot_rect.height * 0.5);

				draw_set_color(COLOR_JOBS_ASSIGN_TEXT);
				draw_rectangle(
					_plus_center_x - _plus_half_size,
					_plus_center_y - (_plus_line_width * 0.5),
					_plus_center_x + _plus_half_size,
					_plus_center_y + (_plus_line_width * 0.5),
					false
				);
				draw_rectangle(
					_plus_center_x - (_plus_line_width * 0.5),
					_plus_center_y - _plus_half_size,
					_plus_center_x + (_plus_line_width * 0.5),
					_plus_center_y + _plus_half_size,
					false
				);
			}
		}

		// Building events expose the Figma actions to the right of the card.
		if (day_event_building_action_is_available(_event))
		{
			var _reroll_rect = jobs_event_action_rect_get(_event_index, "reroll");
			var _reroll_key = jobs_event_action_key_get(_event, "reroll");
			var _reroll_enabled = !global.day_event_reroll_used_today;
			var _reroll_hovered = _reroll_enabled
				&& jobs_hovered_event_action_key == _reroll_key;
			var _reroll_visual_scale = _reroll_hovered ? 1.08 : 1;
			var _reroll_color = _reroll_enabled
				? COLOR_JOBS_EVENT_ACTION
				: COLOR_JOBS_SLOT_BORDER;
			var _reroll_sprite_scale = _layout.scale * _reroll_visual_scale;

			draw_set_alpha(_reroll_enabled ? 1 : 0.35);
			draw_sprite_ext(
				s_reroll_icon,
				0,
				_reroll_rect.x + (_reroll_rect.width * 0.5),
				_event_rect.y + (jobs_reroll_action_icon_y * _layout.scale),
				_reroll_sprite_scale,
				_reroll_sprite_scale,
				0,
				c_white,
				1
			);
			draw_set_alpha(1);
			draw_set_halign(fa_center);
			draw_set_valign(fa_top);
			draw_set_font(jobs_action_font);
			draw_set_color(_reroll_color);
			draw_text(
				_reroll_rect.x + (_reroll_rect.width * 0.5),
				_event_rect.y + (jobs_event_action_label_y * _layout.scale),
				"Reroll (" + string(_reroll_enabled ? 1 : 0) + ")"
			);

			var _pin_action = jobs_event_pin_action_get(_event);

			if (_pin_action != "")
			{
				var _pin_rect = jobs_event_action_rect_get(_event_index, _pin_action);
				var _pin_key = jobs_event_action_key_get(_event, _pin_action);
				var _pin_hovered = jobs_hovered_event_action_key == _pin_key;
				var _pin_visual_scale = _pin_hovered ? 1.08 : 1;
				var _pin_sprite_scale = _layout.scale * _pin_visual_scale;
				var _pin_label = _pin_action == "unpin" ? "Unpin" : "Pin (1)";

				draw_sprite_ext(
					s_pin_icon,
					0,
					_pin_rect.x + (_pin_rect.width * 0.5),
					_event_rect.y + (jobs_pin_action_icon_y * _layout.scale),
					_pin_sprite_scale,
					_pin_sprite_scale,
					30,
					c_white,
					1
				);
				draw_set_halign(fa_center);
				draw_set_valign(fa_top);
				draw_set_font(jobs_action_font);
				draw_set_color(COLOR_JOBS_EVENT_ACTION);
				draw_text(
					_pin_rect.x + (_pin_rect.width * 0.5),
					_event_rect.y + (jobs_event_action_label_y * _layout.scale),
					_pin_label
				);
			}
		}
	}

	// The active selector is drawn last so its squad list overlays the event cards below it.
	if (is_struct(jobs_squad_selector_event))
	{
		var _selector_event_index = -1;
		var _global_event_count = array_length(global.day_events);

		for (var _event_search_index = 0; _event_search_index < _global_event_count; ++_event_search_index)
		{
			if (global.day_events[_event_search_index] == jobs_squad_selector_event)
			{
				_selector_event_index = _event_search_index;
				break;
			}
		}

		if (_selector_event_index >= 0)
		{
			var _eligible_squad_count = array_length(jobs_squad_selector_event.eligible_squads);

			for (var _option_index = 0; _option_index < _eligible_squad_count; ++_option_index)
			{
				var _option_squad = jobs_squad_selector_event.eligible_squads[_option_index];
				var _option_rect = jobs_squad_selector_option_rect_get(_selector_event_index, _option_index);

				draw_set_alpha(0.97);
				draw_set_color(COLOR_JOBS_WINDOW_BACKGROUND);
				draw_rectangle(_option_rect.x, _option_rect.y, _option_rect.x + _option_rect.width, _option_rect.y + _option_rect.height, false);
				draw_set_alpha(1);
				draw_set_color(COLOR_JOBS_SLOT_BORDER);
				draw_rectangle(_option_rect.x, _option_rect.y, _option_rect.x + _option_rect.width, _option_rect.y + _option_rect.height, true);
				draw_set_halign(fa_center);
				draw_set_valign(fa_middle);
				draw_set_font(jobs_hp_font);
				draw_set_color(COLOR_JOBS_ASSIGN_TEXT);
				draw_text(_option_rect.x + (_option_rect.width * 0.5), _option_rect.y + (_option_rect.height * 0.5), _option_squad.name);
			}
		}
	}

	gpu_set_scissor(_previous_scissor);

	// Draw every cultist at its current pool or event position.
	for (var _cultist_index = 0; _cultist_index < array_length(global.event_cultists); ++_cultist_index)
	{
		var _cultist = global.event_cultists[_cultist_index];

		if (!instance_exists(_cultist) || _cultist == jobs_dragged_cultist)
		{
			continue;
		}

		var _cultist_rect = jobs_cultist_rect_get(_cultist);

		if (!is_struct(_cultist_rect))
		{
			continue;
		}

		var _cultist_is_in_scroll_list = is_struct(_cultist.assigned_event);

		if (_cultist_is_in_scroll_list)
		{
			var _cultist_is_visible = _cultist_rect.y + _cultist_rect.height >= _event_viewport.y
				&& _cultist_rect.y <= _event_viewport.y + _event_viewport.height;

			if (!_cultist_is_visible)
			{
				continue;
			}

			gpu_set_scissor(_event_scissor);
		}

		var _sprite_scale = min(
			_cultist_rect.width / sprite_get_width(_cultist.sprite_index),
			(_cultist_rect.height * 0.874) / sprite_get_height(_cultist.sprite_index)
		);
		draw_sprite_ext(
			_cultist.sprite_index,
			_cultist.image_index,
			_cultist_rect.x + (_cultist_rect.width * 0.5),
			_cultist_rect.y + (_cultist_rect.height * 0.62) + (20 * _layout.scale),
			_sprite_scale,
			_sprite_scale,
			0,
			c_white,
			1
		);
		draw_set_halign(fa_center);
		draw_set_valign(fa_top);
		draw_set_font(jobs_hp_font);
		var _cultist_text_x = _cultist_rect.x + (_cultist_rect.width * 0.5);
		var _cultist_name_y = _cultist_rect.y + _cultist_rect.height - (2 * _layout.scale);
		var _cultist_hp_y = _cultist_rect.y + _cultist_rect.height + (10 * _layout.scale);

		// Place the cultist name directly above the lowered HP value.
		draw_set_color(COLOR_JOBS_ASSIGN_TEXT);
		draw_text(_cultist_text_x, _cultist_name_y, _cultist.cultist_name);
		draw_set_color(COLOR_JOBS_ASSIGN_TEXT);
		draw_text(
			_cultist_text_x,
			_cultist_hp_y,
			string(ceil(_cultist.hp)) + "hp"
		);

		// Assigned slots preview their HP result and mark lethal outcomes.
		if (_cultist_is_in_scroll_list)
		{
			var _preview_event = _cultist.assigned_event;
			var _preview_slot_index = -1;

			for (var _assigned_index = 0; _assigned_index < array_length(_preview_event.assigned_cultists); ++_assigned_index)
			{
				if (_preview_event.assigned_cultists[_assigned_index] == _cultist)
				{
					_preview_slot_index = _assigned_index;
					break;
				}
			}

			if (_preview_slot_index >= 0)
			{
				var _hp_preview = jobs_event_cultist_hp_preview_get(_preview_event, _preview_slot_index, _cultist);

				if (_hp_preview.hp_change != 0)
				{
					var _change_prefix = _hp_preview.hp_change > 0 ? "+" : "";
					var _change_y = _cultist_rect.y + _cultist_rect.height + (22 * _layout.scale);
					draw_set_color(_hp_preview.hp_change > 0 ? COLOR_JOBS_EVENT_ACTIVE : COLOR_STATUS_NEGATIVE_RED);
					draw_text(_cultist_text_x, _change_y, _change_prefix + string(round(_hp_preview.hp_change)) + " HP");
				}

				if (_hp_preview.dies && sprite_exists(s_ui_scull_white))
				{
					var _skull_size = 24 * _layout.scale;
					var _skull_scale = _skull_size / max(1, sprite_get_width(s_ui_scull_white));
					draw_sprite_ext(
						s_ui_scull_white,
						0,
						_cultist_text_x,
						_cultist_rect.y - (6 * _layout.scale),
						_skull_scale,
						_skull_scale,
						0,
						COLOR_STATUS_NEGATIVE_RED,
						1
					);
				}
			}
		}

		if (_cultist_is_in_scroll_list)
		{
			gpu_set_scissor(_previous_scissor);
		}
	}

	// Draw a scrollbar only when the event list is taller than its viewport.
	var _scroll_max = jobs_scroll_max_get();

	if (_scroll_max > 0)
	{
		var _scrollbar_x = _layout.panel_x
			+ _layout.panel_width
			- ((jobs_scrollbar_width + jobs_scrollbar_gap) * _layout.scale);
		var _scrollbar_width = jobs_scrollbar_width * _layout.scale;
		var _event_count = array_length(global.day_events);
		var _content_height = ((_event_count * jobs_event_height)
			+ (max(0, _event_count - 1) * jobs_event_gap)) * _layout.scale;
		var _thumb_height = max(32 * _layout.scale, _event_viewport.height * (_event_viewport.height / _content_height));
		var _thumb_travel = _event_viewport.height - _thumb_height;
		var _thumb_y = _event_viewport.y + (_thumb_travel * (jobs_scroll_offset / _scroll_max));

		draw_set_alpha(0.45);
		draw_set_color(COLOR_JOBS_EVENT_INACTIVE);
		draw_rectangle(
			_scrollbar_x,
			_event_viewport.y,
			_scrollbar_x + _scrollbar_width,
			_event_viewport.y + _event_viewport.height,
			false
		);
		draw_set_alpha(1);
		draw_set_color(COLOR_JOBS_SLOT_BORDER);
		draw_rectangle(
			_scrollbar_x,
			_thumb_y,
			_scrollbar_x + _scrollbar_width,
			_thumb_y + _thumb_height,
			false
		);
	}

	// Dragged cultist follows the cursor above all cards.
	if (instance_exists(jobs_dragged_cultist))
	{
		var _drag_sprite = jobs_dragged_cultist.sprite_index;
		var _drag_scale = min(
			(jobs_icon_width * _layout.scale) / sprite_get_width(_drag_sprite),
			(jobs_icon_height * _layout.scale) / sprite_get_height(_drag_sprite)
		);
		draw_sprite_ext(
			_drag_sprite,
			jobs_dragged_cultist.image_index,
			device_mouse_x_to_gui(0),
			device_mouse_y_to_gui(0),
			_drag_scale,
			_drag_scale,
			0,
			c_white,
			1
		);
	}
	else if (instance_exists(jobs_hovered_cultist) && sprite_exists(s_hand))
	{
		// Use the same red hand cursor feedback as cultists in the world.
		var _hand_scale = 0.33 * _layout.scale;
		draw_sprite_ext(
			s_hand,
			0,
			device_mouse_x_to_gui(0),
			device_mouse_y_to_gui(0),
			_hand_scale,
			_hand_scale,
			0,
			c_white,
			1
		);
	}

	// Close button.
	draw_set_color(c_white);
	draw_rectangle(
		_layout.close_x,
		_layout.close_y,
		_layout.close_x + _layout.close_size,
		_layout.close_y + _layout.close_size,
		true
	);
	draw_line(_layout.close_x + (10 * _layout.scale), _layout.close_y + (10 * _layout.scale), _layout.close_x + _layout.close_size - (10 * _layout.scale), _layout.close_y + _layout.close_size - (10 * _layout.scale));
	draw_line(_layout.close_x + _layout.close_size - (10 * _layout.scale), _layout.close_y + (10 * _layout.scale), _layout.close_x + (10 * _layout.scale), _layout.close_y + _layout.close_size - (10 * _layout.scale));

	// End-day action below the panel.
	var _end_x = (_gui_width - _layout.end_width) * 0.5;
	var _end_pulse = 0.5 + (sin(current_time / 260) * 0.5);
	var _end_pulse_scale = 0.98 + (_end_pulse * 0.04);
	var _end_hover_scale = jobs_end_hovered ? 1.06 : 1;
	var _end_visual_scale = _end_pulse_scale * _end_hover_scale;
	var _end_center_x = _end_x + (_layout.end_width * 0.5);
	var _end_center_y = _layout.end_y + (_layout.end_height * 0.5);
	var _end_visual_width = _layout.end_width * _end_visual_scale;
	var _end_visual_height = _layout.end_height * _end_visual_scale;
	var _end_visual_x = _end_center_x - (_end_visual_width * 0.5);
	var _end_visual_y = _end_center_y - (_end_visual_height * 0.5);

	draw_set_color(COLOR_JOBS_ASSIGN_BACKGROUND);
	draw_rectangle(
		_end_visual_x,
		_end_visual_y,
		_end_visual_x + _end_visual_width,
		_end_visual_y + _end_visual_height,
		false
	);

	draw_set_color(COLOR_JOBS_ASSIGN_BORDER);
	for (var _end_border_index = 0; _end_border_index < 2; ++_end_border_index)
	{
		draw_rectangle(
			_end_visual_x + _end_border_index,
			_end_visual_y + _end_border_index,
			_end_visual_x + _end_visual_width - _end_border_index,
			_end_visual_y + _end_visual_height - _end_border_index,
			true
		);
	}

	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_set_color(COLOR_JOBS_ASSIGN_TEXT);
	draw_set_font(jobs_button_font);
	draw_text_transformed(
		_end_center_x,
		_end_center_y,
		"END DAY",
		_layout.scale * _end_visual_scale,
		_layout.scale * _end_visual_scale,
		0
	);
}

// Restore default draw state.
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);

if (variable_global_exists("ui_font") && font_exists(global.ui_font))
{
	draw_set_font(global.ui_font);
}
