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
	var _event_scissor = jobs_scissor_rect_get(_event_viewport);
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

		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		draw_set_color(COLOR_JOBS_ASSIGN_TEXT);
		draw_set_font(jobs_title_font);
		draw_text(_event_rect.x + (34 * _layout.scale), _event_rect.y + (18 * _layout.scale), _event.title);
		draw_set_font(jobs_description_font);
		draw_text_ext(
			_event_rect.x + (34 * _layout.scale),
			_event_rect.y + (48 * _layout.scale),
			_event.description,
			16 * _layout.scale,
			390 * _layout.scale
		);

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
			var _slot_x = _event_rect.x
				+ (jobs_event_slot_start_x * _layout.scale)
				+ (_slot_index * jobs_event_slot_step * _layout.scale);
			var _slot_y = _event_rect.y + (18 * _layout.scale);
			draw_set_color(COLOR_JOBS_SLOT_BORDER);
			draw_rectangle(
				_slot_x,
				_slot_y,
				_slot_x + (jobs_icon_width * _layout.scale),
				_slot_y + (jobs_icon_height * _layout.scale),
				true
			);
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

		if (_cultist_is_in_scroll_list)
		{
			gpu_set_scissor(_previous_scissor);
		}
	}

	// Draw a scrollbar only when the event list is taller than its viewport.
	var _scroll_max = jobs_scroll_max_get();

	if (_scroll_max > 0)
	{
		var _scrollbar_x = _event_viewport.x
			+ _event_viewport.width
			+ (jobs_scrollbar_gap * _layout.scale);
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
