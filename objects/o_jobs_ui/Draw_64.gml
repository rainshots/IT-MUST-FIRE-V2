if (variable_global_exists("blood_moon_reward_popup_active")
	&& global.blood_moon_reward_popup_active)
{
	exit;
}

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

	// Guide the player to Cultist Assignment until the window has been opened once.
	if (!jobs_window_opened_once)
	{
		var _hint_text_x = _show_rect.x + (jobs_assignment_hint_text_offset_x * _show_rect.scale);
		var _hint_text_y = _show_rect.y + (jobs_assignment_hint_text_offset_y * _show_rect.scale);

		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		draw_set_color(c_white);
		draw_set_font(jobs_button_font);
		draw_text_transformed(
			_hint_text_x,
			_hint_text_y,
			"Click to open the Cultist Assignment window",
			_show_rect.scale,
			_show_rect.scale,
			0
		);

		if (sprite_exists(s_attack_arrow))
		{
			var _hint_arrow_x = _show_rect.x
				+ (jobs_assignment_hint_arrow_tip_offset_x * _show_rect.scale);
			var _hint_arrow_y = _show_rect.y
				+ (jobs_assignment_hint_arrow_tip_offset_y * _show_rect.scale);
			var _hint_arrow_scale = jobs_assignment_hint_arrow_scale * _show_rect.scale;

			draw_sprite_ext(
				s_attack_arrow,
				0,
				_hint_arrow_x,
				_hint_arrow_y,
				_hint_arrow_scale,
				_hint_arrow_scale,
				jobs_assignment_hint_arrow_angle,
				c_white,
				BALANCE_ATTACK_ARROW_ALPHA
			);
		}
	}

	// The bottom action appears after Jobs onboarding; its first-day prompt remains non-interactive.
	if (jobs_end_day_is_visible())
	{
		var _end_rect = jobs_end_day_button_rect_get();
		var _end_pulse = 0.5 + (sin(current_time / 260) * 0.5);
		var _end_pulse_scale = 0.98 + (_end_pulse * 0.04);
		var _end_hover_scale = jobs_end_hovered ? 1.06 : 1;
		var _end_visual_scale = _end_pulse_scale * _end_hover_scale;
		var _end_center_x = _end_rect.x + (_end_rect.width * 0.5);
		var _end_center_y = _end_rect.y + (_end_rect.height * 0.5);
		var _end_visual_width = _end_rect.width * _end_visual_scale;
		var _end_visual_height = _end_rect.height * _end_visual_scale;
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
		var _end_text = jobs_end_day_button_text_get();
		var _end_text_draw_scale = _end_rect.scale * _end_visual_scale;
		var _end_text_width = string_width(_end_text) * _end_text_draw_scale;
		var _end_text_height = string_height(_end_text) * _end_text_draw_scale;
		var _end_text_available_width = _end_visual_width - (jobs_end_day_button_text_padding_x * 2 * _end_rect.scale);
		var _end_text_available_height = _end_visual_height - (jobs_end_day_button_text_padding_y * 2 * _end_rect.scale);
		var _end_text_fit_scale = min(
			1,
			min(
				_end_text_available_width / max(1, _end_text_width),
				_end_text_available_height / max(1, _end_text_height)
			)
		);
		_end_text_draw_scale *= _end_text_fit_scale;
		draw_text_transformed(
			_end_center_x,
			_end_center_y,
			_end_text,
			_end_text_draw_scale,
			_end_text_draw_scale,
			0
		);
	}
}

if (global.focus_window == FOCUS_WINDOW.END_DAY_CONFIRMATION)
{
	var _confirmation_layout = jobs_end_day_confirmation_layout_get();
	var _confirmation_gui_width = display_get_gui_width();
	var _confirmation_gui_height = display_get_gui_height();
	var _confirmation_unassigned_count = jobs_unassigned_cultist_count_get();
	var _confirmation_text = "Are you sure you want to end the day? You still have unassigned Cultists ("
		+ string(_confirmation_unassigned_count)
		+ ")";

	draw_set_alpha(0.65);
	draw_set_color(c_black);
	draw_rectangle(0, 0, _confirmation_gui_width, _confirmation_gui_height, false);

	draw_set_alpha(1);
	draw_set_color(COLOR_JOBS_WINDOW_BACKGROUND);
	draw_rectangle(
		_confirmation_layout.panel_x,
		_confirmation_layout.panel_y,
		_confirmation_layout.panel_x + _confirmation_layout.panel_width,
		_confirmation_layout.panel_y + _confirmation_layout.panel_height,
		false
	);
	draw_set_color(COLOR_JOBS_POOL_BORDER);
	draw_rectangle(
		_confirmation_layout.panel_x,
		_confirmation_layout.panel_y,
		_confirmation_layout.panel_x + _confirmation_layout.panel_width,
		_confirmation_layout.panel_y + _confirmation_layout.panel_height,
		true
	);

	draw_set_halign(fa_center);
	draw_set_valign(fa_top);
	draw_set_font(jobs_show_font);
	draw_set_color(COLOR_JOBS_ASSIGN_TEXT);
	draw_text_ext(
		_confirmation_layout.panel_x + (_confirmation_layout.panel_width * 0.5),
		_confirmation_layout.panel_y + (42 * _confirmation_layout.scale),
		_confirmation_text,
		34 * _confirmation_layout.scale,
		_confirmation_layout.panel_width - (84 * _confirmation_layout.scale)
	);

	var _cancel_scale = jobs_confirmation_cancel_hovered ? 1.06 : 1;
	var _cancel_center_x = _confirmation_layout.cancel_x
		+ (_confirmation_layout.cancel_width * 0.5);
	var _cancel_center_y = _confirmation_layout.cancel_y
		+ (_confirmation_layout.cancel_height * 0.5);

	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_set_font(jobs_button_font);
	draw_set_color(COLOR_JOBS_ASSIGN_TEXT);
	draw_text_transformed(
		_cancel_center_x,
		_cancel_center_y,
		"CANCEL",
		_confirmation_layout.scale * _cancel_scale,
		_confirmation_layout.scale * _cancel_scale,
		0
	);

	var _confirmation_end_scale = jobs_confirmation_end_hovered ? 1.06 : 1;
	var _confirmation_end_center_x = _confirmation_layout.end_x
		+ (_confirmation_layout.end_width * 0.5);
	var _confirmation_end_center_y = _confirmation_layout.end_y
		+ (_confirmation_layout.end_height * 0.5);
	var _confirmation_end_width = _confirmation_layout.end_width * _confirmation_end_scale;
	var _confirmation_end_height = _confirmation_layout.end_height * _confirmation_end_scale;
	var _confirmation_end_x = _confirmation_end_center_x - (_confirmation_end_width * 0.5);
	var _confirmation_end_y = _confirmation_end_center_y - (_confirmation_end_height * 0.5);

	draw_set_color(COLOR_JOBS_ASSIGN_BACKGROUND);
	draw_rectangle(
		_confirmation_end_x,
		_confirmation_end_y,
		_confirmation_end_x + _confirmation_end_width,
		_confirmation_end_y + _confirmation_end_height,
		false
	);
	draw_set_color(COLOR_JOBS_ASSIGN_BORDER);
	for (var _confirmation_end_border = 0; _confirmation_end_border < 2; ++_confirmation_end_border)
	{
		draw_rectangle(
			_confirmation_end_x + _confirmation_end_border,
			_confirmation_end_y + _confirmation_end_border,
			_confirmation_end_x + _confirmation_end_width - _confirmation_end_border,
			_confirmation_end_y + _confirmation_end_height - _confirmation_end_border,
			true
		);
	}

	draw_set_color(COLOR_JOBS_ASSIGN_TEXT);
	draw_text_transformed(
		_confirmation_end_center_x,
		_confirmation_end_center_y,
		"END DAY",
		_confirmation_layout.scale * _confirmation_end_scale,
		_confirmation_layout.scale * _confirmation_end_scale,
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
	var _hovered_result_unit_object = noone;
	var _mouse_gui_x = device_mouse_x_to_gui(0);
	var _mouse_gui_y = device_mouse_y_to_gui(0);
	gpu_set_scissor(_event_scissor);

	for (var _event_index = 0; _event_index < array_length(global.day_events); ++_event_index)
	{
		var _event = global.day_events[_event_index];
		var _display_event = _event;
		var _event_rect = jobs_event_rect_get(_event_index);
		var _reroll_preview_key = jobs_event_action_key_get(_event, "reroll");
		var _reroll_preview_is_active = jobs_hovered_event_action_key == _reroll_preview_key
			&& variable_struct_exists(_event, "reroll_preview_event")
			&& is_struct(_event.reroll_preview_event);

		if (_reroll_preview_is_active)
		{
			_display_event = _event.reroll_preview_event;
		}

		var _is_ready = _display_event.activation_ready_count_get() > 0;
		var _event_background_color = _reroll_preview_is_active
			? COLOR_JOBS_REROLL_PREVIEW
			: (_is_ready ? COLOR_JOBS_EVENT_ACTIVE : COLOR_JOBS_EVENT_INACTIVE);
		draw_set_color(_event_background_color);
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

		if (variable_struct_exists(_display_event, "source_sprite")
			&& sprite_exists(_display_event.source_sprite))
		{
			_source_sprite = _display_event.source_sprite;
		}
		else if (variable_struct_exists(_display_event, "source_building")
			&& instance_exists(_display_event.source_building)
			&& sprite_exists(_display_event.source_building.sprite_index))
		{
			_source_sprite = _display_event.source_building.sprite_index;
			_source_frame = _display_event.source_building.image_index;
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
		draw_text(_event_rect.x + (34 * _layout.scale), _event_rect.y + (18 * _layout.scale), _display_event.title);
		draw_set_font(jobs_description_font);
		var _result_unit_object = jobs_event_result_unit_object_get(_display_event);
		var _has_result_unit = _result_unit_object != noone;
		var _has_unit_choices = variable_struct_exists(_display_event, "unit_choice_options")
			&& is_array(_display_event.unit_choice_options)
			&& array_length(_display_event.unit_choice_options) > 0;
		var _description_width = (_has_unit_choices ? 220 : (_has_result_unit ? 328 : 390)) * _layout.scale;
		var _has_archdemon_target = variable_struct_exists(_display_event, "target_archdemon_name")
			&& variable_struct_exists(_display_event, "target_archdemon_sprite")
			&& sprite_exists(_display_event.target_archdemon_sprite);

		if (_has_archdemon_target)
		{
			_description_width = 292 * _layout.scale;
		}

		draw_text_ext(
			_event_rect.x + (34 * _layout.scale),
			_event_rect.y + (48 * _layout.scale),
			_display_event.description,
			16 * _layout.scale,
			_description_width
		);

		// Specialization Jobs show all outcomes and let the player compare them by hovering.
		if (_has_unit_choices)
		{
			var _choice_count = array_length(_display_event.unit_choice_options);
			var _selected_choice_index = variable_struct_exists(_display_event, "selected_unit_choice_index")
				? floor(_display_event.selected_unit_choice_index)
				: 0;

			for (var _choice_index = 0; _choice_index < _choice_count; ++_choice_index)
			{
				var _choice = _display_event.unit_choice_options[_choice_index];

				if (!is_struct(_choice)
					|| !variable_struct_exists(_choice, "target_unit_object"))
				{
					continue;
				}

				var _choice_unit_object = _choice.target_unit_object;
				var _choice_icon_rect = jobs_event_unit_choice_icon_rect_get(_event_index, _choice_index);
				var _choice_center_x = _choice_icon_rect.x + (_choice_icon_rect.width * 0.5);
				var _choice_center_y = _choice_icon_rect.y + (_choice_icon_rect.height * 0.5);
				var _choice_radius = _choice_icon_rect.width * 0.5;
				var _choice_sprite = object_get_sprite(_choice_unit_object);
				var _choice_is_visible = _choice_icon_rect.y + _choice_icon_rect.height >= _event_viewport.y
					&& _choice_icon_rect.y <= _event_viewport.y + _event_viewport.height;
				var _choice_is_hovered = _choice_is_visible
					&& point_in_rectangle(
						_mouse_gui_x,
						_mouse_gui_y,
						_choice_icon_rect.x,
						_choice_icon_rect.y,
						_choice_icon_rect.x + _choice_icon_rect.width,
						_choice_icon_rect.y + _choice_icon_rect.height
					);
				var _choice_is_selected = _choice_index == _selected_choice_index;
				var _choice_alpha = _choice_is_selected
					? BALANCE_EVENT_UNIT_CHOICE_SELECTED_ALPHA
					: BALANCE_EVENT_UNIT_CHOICE_UNSELECTED_ALPHA;

				draw_set_alpha(_choice_alpha);
				draw_set_color(COLOR_JOBS_ASSIGN_BACKGROUND);
				draw_circle(_choice_center_x, _choice_center_y, _choice_radius, false);
				draw_set_color(_choice_is_selected || _choice_is_hovered
					? COLOR_JOBS_EVENT_ACTIVE
					: COLOR_JOBS_SLOT_BORDER);
				draw_circle(_choice_center_x, _choice_center_y, _choice_radius, true);

				if (sprite_exists(_choice_sprite))
				{
					var _choice_sprite_width = max(1, sprite_get_width(_choice_sprite));
					var _choice_sprite_height = max(1, sprite_get_height(_choice_sprite));
					var _choice_available_size = _choice_icon_rect.width * 0.78;
					var _choice_sprite_scale = min(
						_choice_available_size / _choice_sprite_width,
						_choice_available_size / _choice_sprite_height
					);
					var _choice_sprite_x = _choice_center_x
						+ ((sprite_get_xoffset(_choice_sprite) - (_choice_sprite_width * 0.5)) * _choice_sprite_scale);
					var _choice_sprite_y = _choice_center_y
						+ ((sprite_get_yoffset(_choice_sprite) - (_choice_sprite_height * 0.5)) * _choice_sprite_scale);

					draw_sprite_ext(
						_choice_sprite,
						0,
						_choice_sprite_x,
						_choice_sprite_y,
						_choice_sprite_scale,
						_choice_sprite_scale,
						0,
						c_white,
						1
					);
				}

				draw_set_halign(fa_center);
				draw_set_valign(fa_top);
				draw_set_font(jobs_hp_font);
				draw_set_color(_choice_is_selected ? COLOR_STATUS_NEGATIVE_RED : COLOR_JOBS_ASSIGN_TEXT);
				draw_text(
					_choice_center_x,
					_event_rect.y + (jobs_unit_choice_label_y * _layout.scale),
					_choice.label
				);
				draw_set_alpha(1);

				if (_choice_is_hovered)
				{
					_hovered_result_unit_object = _choice_unit_object;
				}
			}

			if (_selected_choice_index >= 0 && _selected_choice_index < _choice_count)
			{
				var _selected_choice = _display_event.unit_choice_options[_selected_choice_index];

				if (is_struct(_selected_choice) && variable_struct_exists(_selected_choice, "title"))
				{
					// Center the selection summary directly below the three result portraits.
					var _selected_text_x = _event_rect.x
						+ ((jobs_unit_choice_icon_start_x
							+ (jobs_unit_choice_icon_size * 0.5)
							+ (((_choice_count - 1) * jobs_unit_choice_icon_step) * 0.5)) * _layout.scale);
					draw_set_halign(fa_center);
					draw_set_valign(fa_top);
					draw_set_font(jobs_hp_font);
					draw_set_color(COLOR_STATUS_NEGATIVE_RED);
					draw_text(
						_selected_text_x,
						_event_rect.y + (111 * _layout.scale),
						"Selected: " + _selected_choice.title
					);
				}
			}
		}
		// Unit recruitment and summoning Jobs preview their single result.
		else if (_has_result_unit)
		{
			var _result_icon_rect = jobs_event_result_unit_icon_rect_get(_event_index);
			var _result_icon_center_x = _result_icon_rect.x + (_result_icon_rect.width * 0.5);
			var _result_icon_center_y = _result_icon_rect.y + (_result_icon_rect.height * 0.5);
			var _result_icon_radius = _result_icon_rect.width * 0.5;
			var _result_unit_sprite = object_get_sprite(_result_unit_object);

			draw_set_alpha(0.9);
			draw_set_color(COLOR_JOBS_ASSIGN_BACKGROUND);
			draw_circle(_result_icon_center_x, _result_icon_center_y, _result_icon_radius, false);
			draw_set_alpha(1);
			draw_set_color(COLOR_PROJECTILE_SUMMON);
			draw_circle(_result_icon_center_x, _result_icon_center_y, _result_icon_radius, true);

			if (sprite_exists(_result_unit_sprite))
			{
				var _result_sprite_width = max(1, sprite_get_width(_result_unit_sprite));
				var _result_sprite_height = max(1, sprite_get_height(_result_unit_sprite));
				var _result_available_size = _result_icon_rect.width * 0.78;
				var _result_sprite_scale = min(
					_result_available_size / _result_sprite_width,
					_result_available_size / _result_sprite_height
				);
				var _result_sprite_x = _result_icon_center_x
					+ ((sprite_get_xoffset(_result_unit_sprite) - (_result_sprite_width * 0.5)) * _result_sprite_scale);
				var _result_sprite_y = _result_icon_center_y
					+ ((sprite_get_yoffset(_result_unit_sprite) - (_result_sprite_height * 0.5)) * _result_sprite_scale);

				draw_sprite_ext(
					_result_unit_sprite,
					0,
					_result_sprite_x,
					_result_sprite_y,
					_result_sprite_scale,
					_result_sprite_scale,
					0,
					c_white,
					1
				);
			}

			var _result_icon_is_visible = _result_icon_rect.y + _result_icon_rect.height >= _event_viewport.y
				&& _result_icon_rect.y <= _event_viewport.y + _event_viewport.height;

			if (_result_icon_is_visible
				&& point_in_rectangle(
					_mouse_gui_x,
					_mouse_gui_y,
					_result_icon_rect.x,
					_result_icon_rect.y,
					_result_icon_rect.x + _result_icon_rect.width,
					_result_icon_rect.y + _result_icon_rect.height
				))
			{
				_hovered_result_unit_object = _result_unit_object;
			}
		}

		// Targeted Foundry training shows the locked Archdemon portrait and name.
		if (_has_archdemon_target)
		{
			var _target_sprite = _display_event.target_archdemon_sprite;
			var _target_frame = variable_struct_exists(_display_event, "target_archdemon_frame")
				? _display_event.target_archdemon_frame
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
				_display_event.target_archdemon_name
			);
			draw_set_halign(fa_left);
			draw_set_valign(fa_top);
		}

		if (variable_struct_exists(_display_event, "requires_squad_selection")
			&& _display_event.requires_squad_selection)
		{
			var _selector_rect = jobs_squad_selector_rect_get(_event_index);
			var _selector_text = "SELECT SQUAD";

			if (variable_struct_exists(_display_event, "selected_squad") && is_struct(_display_event.selected_squad))
			{
				_selector_text = squad_name_display_get(_display_event.selected_squad.name);
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
			draw_set_color(is_struct(_display_event.selected_squad) ? COLOR_JOBS_EVENT_ACTIVE : COLOR_JOBS_SLOT_BORDER);
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

		var _slot_count = _display_event.cultist_cost * _display_event.activation_limit;

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
			if (_slot_index >= array_length(_display_event.assigned_cultists))
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

				// Show the HP cost before a cultist is assigned, matching occupied slots.
				var _empty_slot_hp_cost_text = jobs_event_empty_slot_hp_cost_text_get(_display_event);

				if (_empty_slot_hp_cost_text != "")
				{
					draw_set_halign(fa_center);
					draw_set_valign(fa_top);
					draw_set_font(jobs_hp_font);
					draw_set_color(COLOR_STATUS_NEGATIVE_RED);
					draw_text(
						_plus_center_x,
						_slot_y + _slot_rect.height + (22 * _layout.scale),
						_empty_slot_hp_cost_text
					);
					draw_set_halign(fa_left);
				}
			}
		}

		// Building events expose the Figma actions to the right of the card.
		if (day_event_building_action_is_available(_event))
		{
			if (day_event_reroll_is_available(_event))
			{
				var _reroll_rect = jobs_event_action_rect_get(_event_index, "reroll");
				var _reroll_key = jobs_event_action_key_get(_event, "reroll");
				var _reroll_enabled = global.day_event_rerolls_remaining > 0;
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
					"Reroll (" + string(global.day_event_rerolls_remaining) + ")"
				);
			}

			var _pin_action = jobs_event_pin_action_get(_event);

			if (_pin_action != "")
			{
				var _pin_rect = jobs_event_action_rect_get(_event_index, _pin_action);
				var _pin_key = jobs_event_action_key_get(_event, _pin_action);
				var _pin_hovered = jobs_hovered_event_action_key == _pin_key;
				var _pin_visual_scale = _pin_hovered ? 1.08 : 1;
				var _pin_sprite_scale = _layout.scale * _pin_visual_scale;
				var _pin_label = _pin_action == "unpin"
					? "Unpin"
					: "Pin (" + string(global.day_event_pins_remaining) + ")";

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

	// Finish the scrollable event list with a compact construction reminder.
	if (array_length(global.day_events) > 0)
	{
		var _event_footer_rect = jobs_event_footer_rect_get();

		draw_set_alpha(0.72);
		draw_set_halign(fa_center);
		draw_set_valign(fa_top);
		draw_set_font(jobs_description_font);
		draw_set_color(COLOR_JOBS_ASSIGN_TEXT);
		draw_text_ext(
			_event_footer_rect.x + (_event_footer_rect.width * 0.5),
			_event_footer_rect.y,
			jobs_event_footer_text,
			14 * _layout.scale,
			_event_footer_rect.width
		);
		draw_set_alpha(1);
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
				draw_text(_option_rect.x + (_option_rect.width * 0.5), _option_rect.y + (_option_rect.height * 0.5), squad_name_display_get(_option_squad.name));
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
		var _assigned_event_is_previewed = _cultist_is_in_scroll_list
			&& jobs_hovered_event_action_key == jobs_event_action_key_get(_cultist.assigned_event, "reroll")
			&& variable_struct_exists(_cultist.assigned_event, "reroll_preview_event")
			&& is_struct(_cultist.assigned_event.reroll_preview_event);

		if (_assigned_event_is_previewed)
		{
			continue;
		}

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
				var _change_y = _cultist_rect.y + _cultist_rect.height + (22 * _layout.scale);

				if (_hp_preview.hp_loss > 0)
				{
					draw_set_color(COLOR_STATUS_NEGATIVE_RED);
					draw_text(_cultist_text_x, _change_y, "-" + string(round(_hp_preview.hp_loss)) + " HP");
					_change_y += 12 * _layout.scale;
				}

				if (_hp_preview.hp_gain > 0)
				{
					draw_set_color(COLOR_HEALTH_BAR);
					draw_text(_cultist_text_x, _change_y, "+" + string(round(_hp_preview.hp_gain)) + " HP");
				}

				if (_hp_preview.dies && sprite_exists(s_ui_scull_white))
				{
					var _skull_size = 24 * _layout.scale;
					var _skull_scale = _skull_size / max(1, sprite_get_width(s_ui_scull_white));
					draw_sprite_ext(
						s_ui_scull_white,
						0,
						_cultist_text_x,
						_cultist_rect.y + (_cultist_rect.height * 0.5),
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
		var _content_height = jobs_event_content_height_get() * _layout.scale;
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
		var _hand_x = device_mouse_x_to_gui(0);
		var _hand_y = device_mouse_y_to_gui(0);
		draw_sprite_ext(
			s_hand,
			0,
			_hand_x,
			_hand_y,
			_hand_scale,
			_hand_scale,
			0,
			c_white,
			1
		);

		// RMB can unassign only Cultists that already occupy a Job slot.
		if (variable_instance_exists(jobs_hovered_cultist, "assigned_event")
			&& is_struct(jobs_hovered_cultist.assigned_event))
		{
			draw_set_font(jobs_hp_font);
			var _hint_padding_x = jobs_unassign_hint_padding_x * _layout.scale;
			var _hint_padding_y = jobs_unassign_hint_padding_y * _layout.scale;
			var _hint_width = (string_width(jobs_unassign_hint_text) * _layout.scale) + (_hint_padding_x * 2);
			var _hint_height = (string_height(jobs_unassign_hint_text) * _layout.scale) + (_hint_padding_y * 2);
			var _hint_margin = jobs_unassign_hint_screen_margin * _layout.scale;
			var _hint_x = clamp(
				_hand_x - (_hint_width * 0.5),
				_hint_margin,
				display_get_gui_width() - _hint_width - _hint_margin
			);
			var _hint_y = min(
				_hand_y + (jobs_unassign_hint_offset_y * _layout.scale),
				display_get_gui_height() - _hint_height - _hint_margin
			);

			draw_set_alpha(jobs_unassign_hint_background_alpha);
			draw_set_color(COLOR_JOBS_ASSIGN_BACKGROUND);
			draw_rectangle(_hint_x, _hint_y, _hint_x + _hint_width, _hint_y + _hint_height, false);
			draw_set_alpha(1);
			draw_set_color(COLOR_JOBS_SLOT_BORDER);
			draw_rectangle(_hint_x, _hint_y, _hint_x + _hint_width, _hint_y + _hint_height, true);
			draw_set_halign(fa_center);
			draw_set_valign(fa_top);
			draw_set_color(COLOR_JOBS_ASSIGN_TEXT);
			draw_text_transformed(
				_hint_x + (_hint_width * 0.5),
				_hint_y + _hint_padding_y,
				jobs_unassign_hint_text,
				_layout.scale,
				_layout.scale,
				0
			);
			draw_set_halign(fa_left);
			draw_set_valign(fa_top);
		}
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

	// Keep the complete Jobs guide visible through every opening on the first day.
	if (jobs_first_day_hints_are_visible())
	{
		var _hint_design_origin_x = (_gui_width - (jobs_design_width * _layout.scale)) * 0.5;
		var _hint_text_count = array_length(jobs_first_day_hint_texts);

		draw_set_valign(fa_top);
		draw_set_font(jobs_show_font);
		draw_set_color(COLOR_JOBS_EVENT_ACTION);

		for (var _hint_text_index = 0; _hint_text_index < _hint_text_count; ++_hint_text_index)
		{
			var _hint_text = jobs_first_day_hint_texts[_hint_text_index];
			var _hint_text_x = _hint_design_origin_x + (_hint_text.x * _layout.scale);
			var _hint_text_y = _hint_text.y * _layout.scale;

			draw_set_halign(_hint_text.alignment);
			draw_text_transformed(
				_hint_text_x,
				_hint_text_y,
				_hint_text.text,
				_layout.scale,
				_layout.scale,
				0
			);
		}

		if (sprite_exists(s_attack_arrow))
		{
			var _hint_arrow_count = array_length(jobs_first_day_hint_arrows);
			var _hint_arrow_scale = jobs_first_day_hint_arrow_scale * _layout.scale;

			for (var _hint_arrow_index = 0;
				_hint_arrow_index < _hint_arrow_count;
				++_hint_arrow_index)
			{
				var _hint_arrow = jobs_first_day_hint_arrows[_hint_arrow_index];
				var _hint_arrow_x = _hint_design_origin_x
					+ (_hint_arrow.tip_x * _layout.scale);
				var _hint_arrow_y = _hint_arrow.tip_y * _layout.scale;

				draw_sprite_ext(
					s_attack_arrow,
					0,
					_hint_arrow_x,
					_hint_arrow_y,
					_hint_arrow_scale,
					_hint_arrow_scale,
					_hint_arrow.angle,
					c_white,
					BALANCE_ATTACK_ARROW_ALPHA
				);
			}
		}
	}

	// Result-unit hover uses the same stat card and matchup information as world units.
	if (_hovered_result_unit_object != noone && instance_exists(o_game_controller))
	{
		o_game_controller.player_unit_object_stats_card_draw(
			_hovered_result_unit_object,
			18 * _layout.scale,
			120 * _layout.scale,
			jobs_hp_font
		);
	}

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
