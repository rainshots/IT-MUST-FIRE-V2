/// @description Draws the world meter and details window for Cannon Satisfaction.

function cannon_satisfaction_ui_jobs_font_get(_font_variable_name, _fallback_font)
{
	if (instance_exists(o_jobs_ui))
	{
		var _jobs_ui = instance_find(o_jobs_ui, 0);

		if (variable_instance_exists(_jobs_ui, _font_variable_name))
		{
			var _font = variable_instance_get(_jobs_ui, _font_variable_name);

			if (font_exists(_font))
			{
				return _font;
			}
		}
	}

	return _fallback_font;
}

function cannon_satisfaction_ui_default_font_get()
{
	if (variable_global_exists("ui_font") && font_exists(global.ui_font))
	{
		return global.ui_font;
	}

	return -1;
}

function cannon_satisfaction_world_ui_draw()
{
	if (day_event_current_day_get() < BALANCE_CANNON_SATISFACTION_UNLOCK_DAY
		|| !instance_exists(o_cannon)
		|| !instance_exists(o_camera_controller))
	{
		return false;
	}

	var _cannon = instance_find(o_cannon, 0);
	var _camera_controller = instance_find(o_camera_controller, 0);
	var _camera_id = _camera_controller.camera_id;
	var _camera_x = camera_get_view_x(_camera_id);
	var _camera_y = camera_get_view_y(_camera_id);
	var _camera_width = max(1, camera_get_view_width(_camera_id));
	var _camera_height = max(1, camera_get_view_height(_camera_id));
	var _gui_width = display_get_gui_width();
	var _gui_height = display_get_gui_height();
	var _gui_scale = min(_gui_width / 1920, _gui_height / 1080);
	var _indicator_scale = 0.75; // Keep the world indicator compact beside the cannon.
	var _draw_scale = _gui_scale * _indicator_scale;
	var _cannon_gui_x = ((_cannon.bbox_right - _camera_x) / _camera_width) * _gui_width;
	var _cannon_gui_y = ((_cannon.y - _camera_y) / _camera_height) * _gui_height;
	var _screen_margin = 16 * _draw_scale;

	// Skip the world indicator when the cannon is outside the camera view.
	if (_cannon_gui_x < -_screen_margin
		|| _cannon_gui_x > _gui_width + _screen_margin
		|| _cannon_gui_y < -_screen_margin
		|| _cannon_gui_y > _gui_height + _screen_margin)
	{
		return false;
	}

	var _bar_width = 42 * _draw_scale;
	var _bar_height = 315 * _draw_scale;
	var _bar_offset_x = -24 * _draw_scale;
	var _bar_bottom_offset_y = -110 * _draw_scale;
	var _bar_x = clamp(
		_cannon_gui_x + _bar_offset_x,
		_screen_margin,
		_gui_width - _bar_width - _screen_margin
	);
	var _bar_bottom = clamp(
		_cannon_gui_y + _bar_bottom_offset_y,
		_bar_height + _screen_margin,
		_gui_height - (90 * _draw_scale)
	);
	var _bar_top = _bar_bottom - _bar_height;
	var _satisfaction = cannon_satisfaction_get();
	var _fill_share = _satisfaction / BALANCE_CANNON_SATISFACTION_MAX;
	var _fill_height = _bar_height * _fill_share;
	var _fill_top = _bar_bottom - _fill_height;
	var _marker_size = 12 * _draw_scale;
	var _text_gap = 26 * _draw_scale;
	var _effect_width = 310 * _draw_scale;
	var _effect_x = min(_bar_x + _bar_width + _text_gap, _gui_width - _effect_width - _screen_margin);
	var _effect_y = clamp(_fill_top - (26 * _draw_scale), _screen_margin, _gui_height - (180 * _draw_scale));
	var _level = cannon_satisfaction_level_get();
	var _default_font = cannon_satisfaction_ui_default_font_get();
	var _heading_font = cannon_satisfaction_ui_jobs_font_get("jobs_title_font", _default_font);
	var _body_font = cannon_satisfaction_ui_jobs_font_get("jobs_action_font", _default_font);
	var _value_font = cannon_satisfaction_ui_jobs_font_get("jobs_button_font", _heading_font);

	// Draw the vertical meter from the Figma composition.
	draw_set_alpha(0.8);
	draw_set_color(c_black);
	draw_rectangle(_bar_x, _bar_top, _bar_x + _bar_width, _bar_bottom, false);
	draw_set_alpha(1);
	draw_set_color(COLOR_SQUAD_HP_FILL);
	draw_rectangle(_bar_x, _fill_top, _bar_x + _bar_width, _bar_bottom, false);
	draw_triangle(
		_bar_x + _bar_width,
		_fill_top,
		_bar_x + _bar_width + _marker_size,
		_fill_top - _marker_size,
		_bar_x + _bar_width + _marker_size,
		_fill_top + _marker_size,
		false
	);

	// Show the numeric value inside the meter.
	if (font_exists(_value_font))
	{
		draw_set_font(_value_font);
	}

	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_set_color(COLOR_JOBS_ASSIGN_TEXT);
	draw_text_transformed(
		_bar_x + (_bar_width * 0.5),
		_bar_top + (_bar_height * 0.5),
		string(round(_satisfaction)),
		_draw_scale,
		_draw_scale,
		0
	);

	// Label the meter below the bar.
	if (font_exists(_heading_font))
	{
		draw_set_font(_heading_font);
	}

	draw_set_valign(fa_top);
	draw_text_ext_transformed(
		_bar_x + (_bar_width * 0.5),
		_bar_bottom + (10 * _draw_scale),
		"CANNON\nSATISFACTION\n(" + string(round(_satisfaction)) + "/" + string(BALANCE_CANNON_SATISFACTION_MAX) + ")",
		14,
		130,
		_draw_scale,
		_draw_scale,
		0
	);

	// Show only the currently active effect beside the meter.
	draw_set_halign(fa_left);
	draw_set_color(COLOR_JOBS_ASSIGN_TEXT);
	draw_text_transformed(
		_effect_x,
		_effect_y,
		cannon_satisfaction_level_name_get(_level) + ":",
		_draw_scale,
		_draw_scale,
		0
	);

	if (font_exists(_body_font))
	{
		draw_set_font(_body_font);
	}

	draw_text_ext_transformed(
		_effect_x,
		_effect_y + (24 * _draw_scale),
		cannon_satisfaction_effect_text_get(_level),
		18,
		_effect_width / max(_draw_scale, 0.01),
		_draw_scale,
		_draw_scale,
		0
	);

	// Replace the hidden system cursor with a readable interaction label.
	var _satisfaction_info_is_hovered = false;

	if (instance_exists(o_game_controller))
	{
		var _game_controller = instance_find(o_game_controller, 0);

		if (variable_instance_exists(_game_controller, "cannon_satisfaction_hovered_get"))
		{
			_satisfaction_info_is_hovered = _game_controller.cannon_satisfaction_hovered_get();
		}
	}

	if (_satisfaction_info_is_hovered)
	{
		var _cursor_label_text = "SATTISFACTION INFO";
		var _cursor_label_padding_x = 9 * _draw_scale;
		var _cursor_label_padding_y = 5 * _draw_scale;
		var _cursor_label_offset_y = 14 * _draw_scale;

		if (font_exists(_heading_font))
		{
			draw_set_font(_heading_font);
		}

		var _cursor_label_width = (string_width(_cursor_label_text) * _draw_scale)
			+ (_cursor_label_padding_x * 2);
		var _cursor_label_height = (string_height(_cursor_label_text) * _draw_scale)
			+ (_cursor_label_padding_y * 2);
		var _cursor_label_x = clamp(
			device_mouse_x_to_gui(0),
			_cursor_label_width * 0.5,
			_gui_width - (_cursor_label_width * 0.5)
		);
		var _cursor_label_y = clamp(
			device_mouse_y_to_gui(0) + _cursor_label_offset_y,
			0,
			_gui_height - _cursor_label_height
		);
		var _cursor_label_left = _cursor_label_x - (_cursor_label_width * 0.5);

		draw_set_alpha(0.78);
		draw_set_color(COLOR_HUD_BACKGROUND);
		draw_rectangle(
			_cursor_label_left,
			_cursor_label_y,
			_cursor_label_left + _cursor_label_width,
			_cursor_label_y + _cursor_label_height,
			false
		);

		draw_set_alpha(1);
		draw_set_color(COLOR_HUD_IRON);
		draw_rectangle(
			_cursor_label_left,
			_cursor_label_y,
			_cursor_label_left + _cursor_label_width,
			_cursor_label_y + _cursor_label_height,
			true
		);

		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		draw_set_color(COLOR_HUD_TEXT);
		draw_text_transformed(
			_cursor_label_x,
			_cursor_label_y + (_cursor_label_height * 0.5),
			_cursor_label_text,
			_draw_scale,
			_draw_scale,
			0
		);
	}

	// Restore the project draw defaults.
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
	draw_set_alpha(1);

	if (font_exists(_default_font))
	{
		draw_set_font(_default_font);
	}

	return true;
}

function cannon_satisfaction_window_rect_get()
{
	var _gui_width = display_get_gui_width();
	var _gui_height = display_get_gui_height();
	var _scale = min(_gui_width / 1920, _gui_height / 1080);
	var _width = 744 * _scale;
	var _height = 587 * _scale;
	var _x = (_gui_width - _width) * 0.5;
	var _y = (_gui_height - _height) * 0.5;

	return {
		x: _x,
		y: _y,
		width: _width,
		height: _height,
		scale: _scale,
		close_x: _x + (672 * _scale),
		close_y: _y + (13 * _scale),
		close_size: 55 * _scale
	};
}

function cannon_satisfaction_window_draw()
{
	if (day_event_current_day_get() < BALANCE_CANNON_SATISFACTION_UNLOCK_DAY)
	{
		return false;
	}

	var _rect = cannon_satisfaction_window_rect_get();
	var _gui_width = display_get_gui_width();
	var _gui_height = display_get_gui_height();
	var _scale = _rect.scale;
	var _content_x = _rect.x + (110 * _scale);
	var _content_width = 520 * _scale;
	var _default_font = cannon_satisfaction_ui_default_font_get();
	var _title_font = cannon_satisfaction_ui_jobs_font_get("jobs_show_font", _default_font);
	var _heading_font = cannon_satisfaction_ui_jobs_font_get("jobs_title_font", _default_font);
	var _body_font = cannon_satisfaction_ui_jobs_font_get("jobs_action_font", _default_font);
	var _current_level = cannon_satisfaction_level_get();
	var _entries = [
		{ range: "0-25", level: CANNON_SATISFACTION_LEVEL.SULKING },
		{ range: "26-49", level: CANNON_SATISFACTION_LEVEL.AWAKE },
		{ range: "50-74", level: CANNON_SATISFACTION_LEVEL.PLAYFUL },
		{ range: "75-99", level: CANNON_SATISFACTION_LEVEL.ECSTATIC },
		{ range: "100-120", level: CANNON_SATISFACTION_LEVEL.IT_MUST_FIRE }
	];

	// Dim gameplay and draw the centered Figma-style panel.
	draw_set_alpha(0.65);
	draw_set_color(c_black);
	draw_rectangle(0, 0, _gui_width, _gui_height, false);
	draw_set_alpha(1);
	draw_set_color(COLOR_SQUAD_CARD_BACKGROUND);
	draw_rectangle(_rect.x, _rect.y, _rect.x + _rect.width, _rect.y + _rect.height, false);
	draw_set_color(COLOR_SQUAD_CARD_BORDER);
	draw_rectangle(_rect.x, _rect.y, _rect.x + _rect.width, _rect.y + _rect.height, true);

	// Draw the standard outlined close button used by Jobs windows.
	draw_set_color(c_white);
	draw_rectangle(
		_rect.close_x,
		_rect.close_y,
		_rect.close_x + _rect.close_size,
		_rect.close_y + _rect.close_size,
		true
	);
	var _close_padding = 10 * _scale;
	draw_line(
		_rect.close_x + _close_padding,
		_rect.close_y + _close_padding,
		_rect.close_x + _rect.close_size - _close_padding,
		_rect.close_y + _rect.close_size - _close_padding
	);
	draw_line(
		_rect.close_x + _rect.close_size - _close_padding,
		_rect.close_y + _close_padding,
		_rect.close_x + _close_padding,
		_rect.close_y + _rect.close_size - _close_padding
	);

	// Draw the title and current value.
	if (font_exists(_title_font))
	{
		draw_set_font(_title_font);
	}

	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(COLOR_JOBS_ASSIGN_TEXT);
	draw_text_transformed(
		_content_x,
		_rect.y + (78 * _scale),
		"CANNON SATISFACTION\n(" + string(round(cannon_satisfaction_get())) + "/" + string(BALANCE_CANNON_SATISFACTION_MAX) + ")",
		_scale,
		_scale,
		0
	);

	// List every tier with spacing tuned to the reference panel.
	var _entry_y = _rect.y + (150 * _scale);
	var _entry_count = array_length(_entries);

	for (var _entry_index = 0; _entry_index < _entry_count; ++_entry_index)
	{
		var _entry = _entries[_entry_index];
		var _level_name = cannon_satisfaction_level_name_get(_entry.level);
		var _effect_text = cannon_satisfaction_effect_text_get(_entry.level);
		var _entry_color = (_entry.level == _current_level)
			? COLOR_CANNON_SATISFACTION_ACTIVE
			: COLOR_JOBS_ASSIGN_TEXT;
		draw_set_color(_entry_color);

		if (font_exists(_heading_font))
		{
			draw_set_font(_heading_font);
		}

		draw_text_transformed(
			_content_x,
			_entry_y,
			_entry.range + " - " + _level_name + ":",
			_scale,
			_scale,
			0
		);

		if (font_exists(_body_font))
		{
			draw_set_font(_body_font);
		}

		draw_text_ext_transformed(
			_content_x,
			_entry_y + (20 * _scale),
			_effect_text,
			16,
			_content_width / max(_scale, 0.01),
			_scale,
			_scale,
			0
		);

		var _effect_line_count = string_count("\n", _effect_text) + 1;
		var _entry_height = 48 + (max(0, _effect_line_count - 1) * 16);
		_entry_y += _entry_height * _scale;
	}

	// Restore the project draw defaults.
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
	draw_set_alpha(1);

	if (font_exists(_default_font))
	{
		draw_set_font(_default_font);
	}

	return true;
}
