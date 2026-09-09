if (variable_global_exists("blood_moon_reward_popup_active")
	&& global.blood_moon_reward_popup_active)
{
	exit;
}

if (variable_global_exists("ui_font") && font_exists(global.ui_font))
{
	draw_set_font(global.ui_font);
}

// Lead the player from a nearby Squad Summoning Circle to the Assign Rites window.
if (global.day_phase == DAY_PHASE.DAY
	&& (!variable_global_exists("tutorial_hints_enabled") || global.tutorial_hints_enabled)
	&& global.focus_window == FOCUS_WINDOW.NOONE
	&& (!variable_global_exists("tutorial_popup_active") || !global.tutorial_popup_active)
	&& instance_exists(o_camera_controller))
{
	var _squad_hint_target = jobs_squad_point_hint_target_get();

	if (instance_exists(_squad_hint_target))
	{
		var _squad_hint_camera = instance_find(o_camera_controller, 0);
		var _squad_hint_camera_x = camera_get_view_x(_squad_hint_camera.camera_id);
		var _squad_hint_camera_y = camera_get_view_y(_squad_hint_camera.camera_id);
		var _squad_hint_camera_width = max(1, camera_get_view_width(_squad_hint_camera.camera_id));
		var _squad_hint_camera_height = max(1, camera_get_view_height(_squad_hint_camera.camera_id));
		var _squad_hint_gui_width = display_get_gui_width();
		var _squad_hint_gui_height = display_get_gui_height();
		var _squad_hint_scale = min(
			_squad_hint_gui_width / jobs_design_width,
			_squad_hint_gui_height / jobs_design_height
		);
		var _squad_hint_target_x = ((_squad_hint_target.x - _squad_hint_camera_x)
			/ _squad_hint_camera_width) * _squad_hint_gui_width;
		var _squad_hint_target_y = ((_squad_hint_target.y - _squad_hint_camera_y)
			/ _squad_hint_camera_height) * _squad_hint_gui_height;
		var _squad_hint_previous_font = draw_get_font();
		draw_set_font(jobs_onboarding_font);

		// Measure with the same font and wrapping width used for drawing.
		var _squad_hint_max_text_width = jobs_squad_point_hint_max_width
			- (jobs_squad_point_hint_padding_x * 2);
		var _squad_hint_text_width = min(
			_squad_hint_max_text_width,
			string_width(jobs_squad_point_hint_text)
		);
		var _squad_hint_width = (_squad_hint_text_width
			+ (jobs_squad_point_hint_padding_x * 2)) * _squad_hint_scale;
		var _squad_hint_padding_x = jobs_squad_point_hint_padding_x * _squad_hint_scale;
		var _squad_hint_padding_y = jobs_squad_point_hint_padding_y * _squad_hint_scale;
		var _squad_hint_text_height = string_height_ext(
			jobs_squad_point_hint_text,
			jobs_squad_point_hint_line_height,
			_squad_hint_text_width
		) * _squad_hint_scale;
		var _squad_hint_height = _squad_hint_text_height + (_squad_hint_padding_y * 2);
		var _squad_hint_margin = 18 * _squad_hint_scale;
		var _squad_hint_x = clamp(
			_squad_hint_target_x - (_squad_hint_width * 0.5),
			_squad_hint_margin,
			_squad_hint_gui_width - _squad_hint_width - _squad_hint_margin
		);
		var _squad_hint_y = clamp(
			_squad_hint_target_y + (jobs_squad_point_hint_offset_y * _squad_hint_scale),
			_squad_hint_margin,
			_squad_hint_gui_height - _squad_hint_height - _squad_hint_margin
		);
		var _squad_hint_pulse = 0.88 + (sin(current_time * 0.006) * 0.08);

		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		draw_set_alpha(jobs_squad_point_hint_background_alpha * _squad_hint_pulse);
		draw_set_color(COLOR_HUD_BACKGROUND);
		draw_rectangle(
			_squad_hint_x,
			_squad_hint_y,
			_squad_hint_x + _squad_hint_width,
			_squad_hint_y + _squad_hint_height,
			false
		);

		draw_set_alpha(_squad_hint_pulse);
		draw_set_color(COLOR_HUD_TEXT);
		draw_text_ext_transformed(
			_squad_hint_x + _squad_hint_padding_x,
			_squad_hint_y + _squad_hint_padding_y,
			jobs_squad_point_hint_text,
			jobs_squad_point_hint_line_height,
			_squad_hint_text_width,
			_squad_hint_scale,
			_squad_hint_scale,
			0
		);

		if (sprite_exists(s_attack_arrow))
		{
			var _squad_hint_arrow_scale = jobs_squad_point_hint_arrow_scale * _squad_hint_scale;

			draw_sprite_ext(
				s_attack_arrow,
				0,
				_squad_hint_target_x,
				_squad_hint_target_y,
				_squad_hint_arrow_scale,
				_squad_hint_arrow_scale,
				jobs_squad_point_hint_arrow_angle,
				c_white,
				BALANCE_ATTACK_ARROW_ALPHA * _squad_hint_pulse
			);
		}

		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		draw_set_color(c_white);
		draw_set_alpha(1);
		draw_set_font(_squad_hint_previous_font);
	}
}

// After recruitment, reveal a nearby construction slot and lead the player to it.
if (global.day_phase == DAY_PHASE.DAY
	&& (!variable_global_exists("tutorial_hints_enabled") || global.tutorial_hints_enabled)
	&& global.focus_window == FOCUS_WINDOW.NOONE
	&& (!variable_global_exists("tutorial_popup_active") || !global.tutorial_popup_active)
	&& instance_exists(o_camera_controller))
{
	var _building_hint_target = jobs_building_slot_hint_target_get();

	if (instance_exists(_building_hint_target))
	{
		var _building_hint_camera = instance_find(o_camera_controller, 0);
		var _building_hint_camera_x = camera_get_view_x(_building_hint_camera.camera_id);
		var _building_hint_camera_y = camera_get_view_y(_building_hint_camera.camera_id);
		var _building_hint_camera_width = max(1, camera_get_view_width(_building_hint_camera.camera_id));
		var _building_hint_camera_height = max(1, camera_get_view_height(_building_hint_camera.camera_id));
		var _building_hint_gui_width = display_get_gui_width();
		var _building_hint_gui_height = display_get_gui_height();
		var _building_hint_scale = min(
			_building_hint_gui_width / jobs_design_width,
			_building_hint_gui_height / jobs_design_height
		);
		var _building_hint_target_x = ((_building_hint_target.x - _building_hint_camera_x)
			/ _building_hint_camera_width) * _building_hint_gui_width;
		var _building_hint_target_y = ((_building_hint_target.y - _building_hint_camera_y)
			/ _building_hint_camera_height) * _building_hint_gui_height;
		var _building_hint_previous_font = draw_get_font();
		draw_set_font(jobs_onboarding_font);

		var _building_hint_text_width = min(
			jobs_building_slot_hint_max_width - (jobs_building_slot_hint_padding_x * 2),
			string_width(jobs_building_slot_hint_text)
		);
		var _building_hint_width = (_building_hint_text_width
			+ (jobs_building_slot_hint_padding_x * 2)) * _building_hint_scale;
		var _building_hint_padding_x = jobs_building_slot_hint_padding_x * _building_hint_scale;
		var _building_hint_padding_y = jobs_building_slot_hint_padding_y * _building_hint_scale;
		var _building_hint_text_height = string_height_ext(
			jobs_building_slot_hint_text,
			jobs_building_slot_hint_line_height,
			_building_hint_text_width
		) * _building_hint_scale;
		var _building_hint_height = _building_hint_text_height + (_building_hint_padding_y * 2);
		var _building_hint_margin = 18 * _building_hint_scale;
		var _building_hint_x = clamp(
			_building_hint_target_x - (_building_hint_width * 0.5),
			_building_hint_margin,
			_building_hint_gui_width - _building_hint_width - _building_hint_margin
		);
		var _building_hint_y = clamp(
			_building_hint_target_y + (jobs_building_slot_hint_offset_y * _building_hint_scale),
			_building_hint_margin,
			_building_hint_gui_height - _building_hint_height - _building_hint_margin
		);
		var _building_hint_pulse = 0.88 + (sin(current_time * 0.006) * 0.08);

		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		draw_set_alpha(jobs_building_slot_hint_background_alpha * _building_hint_pulse);
		draw_set_color(COLOR_HUD_BACKGROUND);
		draw_rectangle(
			_building_hint_x,
			_building_hint_y,
			_building_hint_x + _building_hint_width,
			_building_hint_y + _building_hint_height,
			false
		);
		draw_set_alpha(_building_hint_pulse);
		draw_set_color(COLOR_HUD_TEXT);
		draw_text_ext_transformed(
			_building_hint_x + _building_hint_padding_x,
			_building_hint_y + _building_hint_padding_y,
			jobs_building_slot_hint_text,
			jobs_building_slot_hint_line_height,
			_building_hint_text_width,
			_building_hint_scale,
			_building_hint_scale,
			0
		);

		if (sprite_exists(s_attack_arrow))
		{
			var _building_hint_arrow_scale = jobs_building_slot_hint_arrow_scale * _building_hint_scale;

			draw_sprite_ext(
				s_attack_arrow,
				0,
				_building_hint_target_x,
				_building_hint_target_y,
				_building_hint_arrow_scale,
				_building_hint_arrow_scale,
				jobs_building_slot_hint_arrow_angle,
				c_white,
				BALANCE_ATTACK_ARROW_ALPHA * _building_hint_pulse
			);
		}

		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		draw_set_color(c_white);
		draw_set_alpha(1);
		draw_set_font(_building_hint_previous_font);
	}
}

if (global.day_phase == DAY_PHASE.DAY
	&& global.focus_window == FOCUS_WINDOW.NOONE
	&& jobs_show_button_is_visible())
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
		"ASSIGN RITES",
		_show_rect.scale * _show_visual_scale,
		_show_rect.scale * _show_visual_scale,
		0
	);

	// Guide the player to Cultist Assignment until the window has been opened once.
	if (!jobs_window_opened_once && day_event_current_day_get() == 1)
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

		if (jobs_end_day_hint_active)
		{
			var _end_hint_previous_font = draw_get_font();
			draw_set_font(jobs_onboarding_font);

			var _end_hint_scale = _end_rect.scale;
			var _end_hint_arrow_scale = jobs_end_day_hint_arrow_scale * _end_hint_scale;
			var _end_hint_arrow_width = sprite_exists(s_attack_arrow)
				? sprite_get_width(s_attack_arrow) * _end_hint_arrow_scale
				: 0;
			var _end_hint_arrow_x = _end_rect.x + _end_rect.width + (10 * _end_hint_scale);
			var _end_hint_arrow_y = _end_center_y;
			var _end_hint_text_width = min(
				jobs_end_day_hint_max_width - (jobs_end_day_hint_padding_x * 2),
				string_width(jobs_end_day_hint_text)
			);
			var _end_hint_width = (_end_hint_text_width
				+ (jobs_end_day_hint_padding_x * 2)) * _end_hint_scale;
			var _end_hint_padding_x = jobs_end_day_hint_padding_x * _end_hint_scale;
			var _end_hint_padding_y = jobs_end_day_hint_padding_y * _end_hint_scale;
			var _end_hint_text_height = string_height_ext(
				jobs_end_day_hint_text,
				jobs_end_day_hint_line_height,
				_end_hint_text_width
			) * _end_hint_scale;
			var _end_hint_height = _end_hint_text_height + (_end_hint_padding_y * 2);
			var _end_hint_margin = 18 * _end_hint_scale;
			var _end_hint_x = clamp(
				_end_hint_arrow_x
					+ _end_hint_arrow_width
					+ (jobs_end_day_hint_gap_from_arrow * _end_hint_scale),
				_end_hint_margin,
				display_get_gui_width() - _end_hint_width - _end_hint_margin
			);
			var _end_hint_y = clamp(
				_end_hint_arrow_y - (_end_hint_height * 0.5),
				_end_hint_margin,
				display_get_gui_height() - _end_hint_height - _end_hint_margin
			);
			var _end_hint_pulse = 0.88 + (sin(current_time * 0.006) * 0.08);

			draw_set_halign(fa_left);
			draw_set_valign(fa_top);
			draw_set_alpha(jobs_end_day_hint_background_alpha * _end_hint_pulse);
			draw_set_color(COLOR_HUD_BACKGROUND);
			draw_rectangle(
				_end_hint_x,
				_end_hint_y,
				_end_hint_x + _end_hint_width,
				_end_hint_y + _end_hint_height,
				false
			);
			draw_set_alpha(_end_hint_pulse);
			draw_set_color(COLOR_HUD_TEXT);
			draw_text_ext_transformed(
				_end_hint_x + _end_hint_padding_x,
				_end_hint_y + _end_hint_padding_y,
				jobs_end_day_hint_text,
				jobs_end_day_hint_line_height,
				_end_hint_text_width,
				_end_hint_scale,
				_end_hint_scale,
				0
			);

			if (sprite_exists(s_attack_arrow))
			{
				draw_sprite_ext(
					s_attack_arrow,
					0,
					_end_hint_arrow_x,
					_end_hint_arrow_y,
					_end_hint_arrow_scale,
					_end_hint_arrow_scale,
					jobs_end_day_hint_arrow_angle,
					c_white,
					BALANCE_ATTACK_ARROW_ALPHA * _end_hint_pulse
				);
			}

			draw_set_font(_end_hint_previous_font);
			draw_set_halign(fa_left);
			draw_set_valign(fa_top);
			draw_set_color(c_white);
			draw_set_alpha(1);
		}
	}
}

if (global.focus_window == FOCUS_WINDOW.END_DAY_CONFIRMATION)
{
	var _confirmation_layout = jobs_end_day_confirmation_layout_get();
	var _confirmation_gui_width = display_get_gui_width();
	var _confirmation_gui_height = display_get_gui_height();
	var _confirmation_title_text = "Are you sure you want to end the day?";

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
	draw_set_valign(fa_middle);
	draw_set_font(jobs_show_font);
	draw_set_color(COLOR_JOBS_ASSIGN_TEXT);
	draw_text_transformed(
		_confirmation_layout.panel_x + (_confirmation_layout.panel_width * 0.5),
		_confirmation_layout.panel_y + (48 * _confirmation_layout.scale),
		_confirmation_title_text,
		_confirmation_layout.scale,
		_confirmation_layout.scale,
		0
	);

	// Center each warning with its own icon and fit long text inside the panel.
	var _confirmation_warning_count = array_length(jobs_confirmation_warnings);
	for (var _warning_index = 0; _warning_index < _confirmation_warning_count; ++_warning_index)
	{
		var _warning = jobs_confirmation_warnings[_warning_index];
		var _confirmation_warning_y = _confirmation_layout.panel_y
			+ ((jobs_confirmation_warning_y + (_warning_index * jobs_confirmation_warning_row_step))
				* _confirmation_layout.scale);
		var _confirmation_icon_size = jobs_confirmation_warning_icon_size * _confirmation_layout.scale;
		var _confirmation_icon_gap = jobs_confirmation_warning_icon_gap * _confirmation_layout.scale;
		var _confirmation_icon_is_visible = sprite_exists(_warning.icon);
		var _confirmation_icon_row_width = _confirmation_icon_is_visible
			? _confirmation_icon_size + _confirmation_icon_gap
			: 0;
		var _confirmation_text_available_width = _confirmation_layout.panel_width
			- (jobs_confirmation_padding * 2 * _confirmation_layout.scale) - _confirmation_icon_row_width;
		var _confirmation_text_scale = min(_confirmation_layout.scale,
			_confirmation_text_available_width / max(1, string_width(_warning.text)));
		var _confirmation_warning_width = string_width(_warning.text) * _confirmation_text_scale;
		var _confirmation_row_x = _confirmation_layout.panel_x
			+ ((_confirmation_layout.panel_width - _confirmation_icon_row_width - _confirmation_warning_width) * 0.5);

		if (_confirmation_icon_is_visible)
		{
			var _icon_sprite_width = sprite_get_width(_warning.icon);
			var _icon_sprite_height = sprite_get_height(_warning.icon);
			var _confirmation_icon_scale = _confirmation_icon_size
				/ max(1, max(_icon_sprite_width, _icon_sprite_height));
			var _icon_x = _confirmation_row_x + (_confirmation_icon_size * 0.5)
				+ ((sprite_get_xoffset(_warning.icon) - (_icon_sprite_width * 0.5)) * _confirmation_icon_scale);
			var _icon_y = _confirmation_warning_y
				+ ((sprite_get_yoffset(_warning.icon) - (_icon_sprite_height * 0.5)) * _confirmation_icon_scale);
			draw_sprite_ext(_warning.icon, 0, _icon_x, _icon_y,
				_confirmation_icon_scale, _confirmation_icon_scale, 0, c_white, 1);
		}

		draw_set_halign(fa_left);
		draw_text_transformed(
			_confirmation_row_x + _confirmation_icon_row_width,
			_confirmation_warning_y,
			_warning.text,
			_confirmation_text_scale,
			_confirmation_text_scale,
			0
		);
	}

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

	// The fixed header is drawn after the scrolling contents so it stays opaque.
	draw_set_alpha(1);
	draw_set_color(COLOR_JOBS_WINDOW_BACKGROUND);
	draw_rectangle(
		_layout.panel_x,
		_layout.panel_y,
		_layout.panel_x + _layout.panel_width,
		_layout.panel_y + _layout.panel_height,
		false
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
	var _hovered_result_relic = RELIC.NONE;
	var _hovered_shell_enchantment_choice = noone;
	var _mouse_gui_x = device_mouse_x_to_gui(0);
	var _mouse_gui_y = device_mouse_y_to_gui(0);
	var _mouse_is_over_event_viewport = point_in_rectangle(
		_mouse_gui_x,
		_mouse_gui_y,
		_event_viewport.x,
		_event_viewport.y,
		_event_viewport.x + _event_viewport.width,
		_event_viewport.y + _event_viewport.height
	);
	gpu_set_scissor(_event_scissor);

	var _event_count = array_length(global.day_events);
	for (var _event_index = 0; _event_index < _event_count; ++_event_index)
	{
		var _event = global.day_events[_event_index];
		var _event_reveal_alpha = jobs_event_reveal_alpha_get(_event);

		if (_event_reveal_alpha <= 0)
		{
			continue;
		}

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

		// Fill the card from left to right while the Rite is being performed.
		var _execution_duration = BALANCE_DAY_EVENT_EXECUTION_TIME * room_speed;
		var _execution_progress = variable_struct_exists(_event, "execution_timer")
			? clamp(_event.execution_timer / max(1, _execution_duration), 0, 1)
			: 0;

		if (_execution_progress > 0)
		{
			draw_set_color(COLOR_JOBS_EVENT_PROGRESS);
			draw_rectangle(
				_event_rect.x,
				_event_rect.y,
				_event_rect.x + (_event_rect.width * _execution_progress),
				_event_rect.y + _event_rect.height,
				false
			);
		}

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

		if (day_event_execution_staffing_is_ready(_event) && !day_event_execution_is_active(_event))
		{
			var _invoke_rect = jobs_invoke_button_rect_get(_event_index);
			draw_set_color(COLOR_JOBS_EVENT_PROGRESS);
			draw_rectangle(_invoke_rect.x, _invoke_rect.y,
				_invoke_rect.x + _invoke_rect.width, _invoke_rect.y + _invoke_rect.height, false);
			draw_set_color(COLOR_JOBS_SLOT_BORDER);
			draw_rectangle(_invoke_rect.x, _invoke_rect.y,
				_invoke_rect.x + _invoke_rect.width, _invoke_rect.y + _invoke_rect.height, true);
			draw_set_halign(fa_center);
			draw_set_valign(fa_middle);
			draw_set_font(jobs_invoke_font);
			draw_set_color(COLOR_JOBS_ASSIGN_TEXT);
			draw_text_transformed(_invoke_rect.x + (_invoke_rect.width * 0.5),
				_invoke_rect.y + (_invoke_rect.height * 0.5), "INVOKE", _layout.scale, _layout.scale, 0);
			draw_set_halign(fa_left);
			draw_set_valign(fa_top);
		}
		else if (sprite_exists(_source_sprite))
		{
			var _source_available_width = jobs_source_icon_width * _layout.scale;
			var _source_available_height = jobs_source_icon_height * _layout.scale;
			var _source_sprite_width = max(1, sprite_get_width(_source_sprite));
			var _source_sprite_height = max(1, sprite_get_height(_source_sprite));
			var _source_scale = min(
				_source_available_width / _source_sprite_width,
				_source_available_height / _source_sprite_height
			);
			var _source_width = _source_sprite_width * _source_scale;
			var _source_height = _source_sprite_height * _source_scale;
			var _source_area_center_x = _event_rect.x
				+ ((jobs_source_icon_offset_x + (jobs_source_icon_width * 0.5)) * _layout.scale);
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

		var _description_x = _event_rect.x + (34 * _layout.scale);
		var _description_y = _event_rect.y + (48 * _layout.scale);
		var _modifier_text = day_event_modifiers_text_get(_display_event);
		var _is_mastery_offer = variable_struct_exists(_display_event, "is_cultist_mastery")
			&& _display_event.is_cultist_mastery;
		if (_is_mastery_offer)
		{
			// Keep the building name and icon together, with the benefit directly beneath them.
			var _mastery_line_height = 16 * _layout.scale;
			var _mastery_gap = 4 * _layout.scale;
			var _mastery_request = _display_event.mastery_request;
			draw_text_ext(_description_x, _description_y, _display_event.mastery_flavor_text,
				_mastery_line_height, _description_width);
			var _benefit_y = _description_y + string_height_ext(_display_event.mastery_flavor_text,
				_mastery_line_height, _description_width) + _mastery_gap;
			var _benefit_prefix = "All events at ";
			draw_text(_description_x, _benefit_y, _benefit_prefix);
			var _building_name_x = _description_x + string_width(_benefit_prefix);
			draw_set_font(jobs_description_bold_font);
			draw_text(_building_name_x, _benefit_y, _mastery_request.building_name);
			var _building_icon_x = _building_name_x + string_width(_mastery_request.building_name) + _mastery_gap;
			if (sprite_exists(_mastery_request.building_sprite))
			{
				var _building_sprite = _mastery_request.building_sprite;
				var _building_icon_scale = _mastery_line_height
					/ max(1, max(sprite_get_width(_building_sprite), sprite_get_height(_building_sprite)));
				draw_sprite_stretched_ext(_building_sprite, 0, _building_icon_x, _benefit_y,
					sprite_get_width(_building_sprite) * _building_icon_scale,
					sprite_get_height(_building_sprite) * _building_icon_scale, c_white, 1);
			}
			draw_set_font(jobs_description_font);
			draw_text(_description_x, _benefit_y + _mastery_line_height,
				"cost this cultist -" + string(BALANCE_CULTIST_MASTERY_HP_DISCOUNT) + "HP.");
		}
		else
		{
			draw_text_ext(
				_description_x,
				_description_y,
				_display_event.description,
				16 * _layout.scale,
				_description_width
			);
		}

		if (_modifier_text != "")
		{
			var _description_height = string_height_ext(
				_display_event.description,
				16 * _layout.scale,
				_description_width
			);
			draw_set_color(COLOR_STATUS_NEGATIVE_RED);
			draw_text_ext(
				_description_x,
				_description_y + _description_height + (8 * _layout.scale),
				_modifier_text,
				16 * _layout.scale,
				_description_width
			);
			draw_set_color(COLOR_JOBS_ASSIGN_TEXT);
		}

		// Choice Jobs show unit masteries, Relics, or shell enchantments as selectable icons.
		if (_has_unit_choices)
		{
			var _choice_count = array_length(_display_event.unit_choice_options);
			var _selected_choice_index = variable_struct_exists(_display_event, "selected_unit_choice_index")
				? floor(_display_event.selected_unit_choice_index)
				: 0;

			for (var _choice_index = 0; _choice_index < _choice_count; ++_choice_index)
			{
				var _choice = _display_event.unit_choice_options[_choice_index];

				if (!is_struct(_choice))
				{
					continue;
				}

				var _choice_has_unit = variable_struct_exists(_choice, "target_unit_object");
				var _choice_has_relic = variable_struct_exists(_choice, "relic");
				var _choice_has_shell_enchantment = variable_struct_exists(_choice, "shell_enchantment");

				if (!_choice_has_unit && !_choice_has_relic && !_choice_has_shell_enchantment)
				{
					continue;
				}

				var _choice_unit_object = _choice_has_unit ? _choice.target_unit_object : noone;
				var _choice_relic = _choice_has_relic ? _choice.relic : RELIC.NONE;
				var _choice_icon_rect = jobs_event_unit_choice_icon_rect_get(_event_index, _choice_index);
				var _choice_center_x = _choice_icon_rect.x + (_choice_icon_rect.width * 0.5);
				var _choice_center_y = _choice_icon_rect.y + (_choice_icon_rect.height * 0.5);
				var _choice_radius = _choice_icon_rect.width * 0.5;
				var _choice_sprite = variable_struct_exists(_choice, "icon_sprite")
					? _choice.icon_sprite
					: (_choice_has_unit ? object_get_sprite(_choice_unit_object) : noone);
				var _choice_is_visible = _choice_icon_rect.y + _choice_icon_rect.height >= _event_viewport.y
					&& _choice_icon_rect.y <= _event_viewport.y + _event_viewport.height;
				var _choice_is_hovered = _mouse_is_over_event_viewport && _choice_is_visible
					&& _event_reveal_alpha >= 1
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
				if (_choice_has_relic || _choice_has_shell_enchantment)
				{
					draw_text_ext(
						_choice_center_x,
						_event_rect.y + (jobs_unit_choice_label_y * _layout.scale),
						_choice.label,
						12 * _layout.scale,
						jobs_unit_choice_icon_step * _layout.scale
					);
				}
				else
				{
					draw_text(
						_choice_center_x,
						_event_rect.y + (jobs_unit_choice_label_y * _layout.scale),
						_choice.label
					);
				}

				draw_set_alpha(1);

				if (_choice_is_hovered)
				{
					if (_choice_has_unit)
					{
						_hovered_result_unit_object = _choice_unit_object;
					}
					else if (_choice_has_relic)
					{
						_hovered_result_relic = _choice_relic;
					}
					else
					{
						_hovered_shell_enchantment_choice = _choice;
					}
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

			if (_mouse_is_over_event_viewport && _result_icon_is_visible
				&& _event_reveal_alpha >= 1
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
			var _selector_text = array_length(_display_event.eligible_squads) > 0
				? "SELECT SQUAD"
				: "NO ELIGIBLE SQUAD";

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
			var _slot_rect = jobs_event_slot_rect_get(_event_index, _slot_index, _slot_count);
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

			// Empty slots show the centered gray Spirit eye as the assignment affordance.
			if (_slot_index >= array_length(_display_event.assigned_cultists))
			{
				var _slot_key = string(_event_index) + ":" + string(_slot_index);
				var _eye_hover_scale = jobs_hovered_empty_slot_key == _slot_key ? 1.35 : 1;
				var _eye_center_x = _slot_x + (_slot_rect.width * 0.5);
				var _eye_center_y = _slot_y + (_slot_rect.height * 0.5);

				// A personal request shows its author's ghost portrait beneath the Spirit eye.
				if (variable_struct_exists(_display_event, "required_cultist")
					&& instance_exists(_display_event.required_cultist))
				{
					var _required = _display_event.required_cultist;
					var _ghost_alpha = 0.3;
					var _ghost_scale = min(_slot_rect.width / max(1, sprite_get_width(_required.sprite_index)),
						(_slot_rect.height * 0.874) / max(1, sprite_get_height(_required.sprite_index)));
					draw_sprite_ext(_required.sprite_index, _required.image_index,
						_eye_center_x, _slot_y + (_slot_rect.height * 0.62) + (20 * _layout.scale),
						_ghost_scale, _ghost_scale, 0, c_white, _ghost_alpha);
					draw_set_alpha(_ghost_alpha);
					draw_set_halign(fa_center);
					draw_set_valign(fa_top);
					draw_set_color(COLOR_JOBS_ASSIGN_TEXT);
					draw_set_font(jobs_hp_font);
					draw_text(_eye_center_x, _slot_y - (8 * _layout.scale), _required.cultist_name);
					draw_set_alpha(1);
					draw_set_halign(fa_left);
					draw_set_valign(fa_top);
				}

				var _eye_scale = _layout.scale * _eye_hover_scale;
				draw_sprite_ext(s_spirit_eye_gray, 0, _eye_center_x, _eye_center_y,
					_eye_scale, _eye_scale, 0, c_white, 1);

				// Show the Rite cost and every global or building modifier on separate rows.
				var _empty_slot_hp_rows = jobs_event_empty_slot_hp_rows_get(_display_event, _slot_index);

				if (array_length(_empty_slot_hp_rows) > 0)
				{
					draw_set_halign(fa_center);
					draw_set_valign(fa_top);
					draw_set_font(jobs_hp_font);

					for (var _hp_row_index = 0;
						_hp_row_index < array_length(_empty_slot_hp_rows);
						++_hp_row_index)
					{
						var _hp_row = _empty_slot_hp_rows[_hp_row_index];
						var _hp_row_rect = jobs_hp_preview_row_rect_get(
							_slot_rect,
							_hp_row_index,
							jobs_slot_hp_cost_offset_y
						);
						draw_set_color(_hp_row.color);
						draw_text(
							_hp_row_rect.x + (_hp_row_rect.width * 0.5),
							_hp_row_rect.y,
							_hp_row.text
						);
					}

					draw_set_halign(fa_left);
				}
			}
		}

		// Building events expose the Figma actions to the right of the card.
		if (day_event_building_action_is_available(_event))
		{
			if (global.day_event_rerolls_remaining > 0
				&& day_event_reroll_is_available(_event))
			{
				var _reroll_rect = jobs_event_action_rect_get(_event_index, "reroll");
				var _reroll_key = jobs_event_action_key_get(_event, "reroll");
				var _reroll_hovered = jobs_hovered_event_action_key == _reroll_key;
				var _reroll_visual_scale = _reroll_hovered ? 1.08 : 1;
				var _reroll_sprite_scale = _layout.scale
					* jobs_reroll_icon_scale
					* _reroll_visual_scale;

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
				draw_set_halign(fa_center);
				draw_set_valign(fa_top);
				draw_set_font(jobs_action_font);
				draw_set_color(COLOR_JOBS_EVENT_ACTION);
				draw_text(
					_reroll_rect.x + (_reroll_rect.width * 0.5),
					_event_rect.y + (jobs_reroll_action_label_y * _layout.scale),
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
				var _pin_sprite_scale = _layout.scale
					* jobs_pin_icon_scale
					* _pin_visual_scale;
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
					_event_rect.y + (jobs_pin_action_label_y * _layout.scale),
					_pin_label
				);
			}
		}

		// Fade the completed row into the Jobs panel while its Cultists fly back to the pool.
		if (_event.is_resolved)
		{
			var _fade_duration = max(1, BALANCE_JOBS_EVENT_FADE_TIME * room_speed);
			var _fade_progress = clamp(
				_event.completion_animation_timer / _fade_duration,
				0,
				1
			);
			draw_set_alpha(_fade_progress);
			draw_set_color(COLOR_JOBS_WINDOW_BACKGROUND);
			draw_rectangle(
				_layout.panel_x,
				_event_rect.y,
				_layout.panel_x + _layout.panel_width,
				_event_rect.y + _event_rect.height,
				false
			);
			draw_set_alpha(1);
		}

		// Fade the complete row against its opaque backing, including slots, text and source art.
		if (_event_reveal_alpha < 1)
		{
			draw_set_alpha(1 - _event_reveal_alpha);
			draw_set_color(COLOR_JOBS_WINDOW_BACKGROUND);
			draw_rectangle(
				_layout.panel_x,
				_event_rect.y,
				_layout.panel_x + _layout.panel_width,
				_event_rect.y + _event_rect.height,
				false
			);
			draw_set_alpha(1);
		}
	}

	// An informational last card reminds the player about free squad capacity, without controls.
	if (jobs_squad_reminder_visible)
	{
		var _reminder_rect = jobs_event_rect_get(_event_count);
		var _reminder_alpha = jobs_event_reveal_alpha_get(jobs_squad_reminder);

		if (_reminder_alpha > 0
			&& _reminder_rect.y + _reminder_rect.height > _event_viewport.y
			&& _reminder_rect.y < _event_viewport.y + _event_viewport.height)
		{
			draw_set_alpha(_reminder_alpha);
			draw_set_color(COLOR_JOBS_EVENT_INACTIVE);
			draw_rectangle(
				_reminder_rect.x,
				_reminder_rect.y,
				_reminder_rect.x + _reminder_rect.width,
				_reminder_rect.y + _reminder_rect.height,
				false
			);
			draw_set_font(jobs_title_font);
			var _reminder_text_width = _reminder_rect.width - (jobs_squad_reminder_padding * 2 * _layout.scale);
			var _reminder_text_scale = min(_layout.scale,
				_reminder_text_width / max(1, string_width(jobs_squad_reminder_text)));
			draw_set_halign(fa_center);
			draw_set_valign(fa_middle);
			draw_set_color(COLOR_JOBS_ASSIGN_TEXT);
			draw_text_transformed(
				_reminder_rect.x + (_reminder_rect.width * 0.5),
				_reminder_rect.y + (_reminder_rect.height * 0.5),
				jobs_squad_reminder_text,
				_reminder_text_scale,
				_reminder_text_scale,
				0
			);
			draw_set_halign(fa_left);
			draw_set_valign(fa_top);
			draw_set_color(c_white);
			draw_set_alpha(1);
		}
	}

	// Finish the scrollable event list with a compact construction reminder.
	if (_event_count > 0 || jobs_squad_reminder_visible)
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

	// Draw assigned Cultists first, then cover the fixed header before drawing its pool.
	var _cultist_count = array_length(global.event_cultists);
	for (var _cultist_draw_pass = 0; _cultist_draw_pass < 2; ++_cultist_draw_pass)
	{
		var _draw_assigned_cultists = _cultist_draw_pass == 0;

		if (!_draw_assigned_cultists)
		{
			// The backing spans the entire panel down to the shared input/scroll boundary.
			draw_set_alpha(1);
			draw_set_color(COLOR_JOBS_WINDOW_BACKGROUND);
			draw_rectangle(
				_layout.panel_x,
				_layout.panel_y,
				_layout.panel_x + _layout.panel_width,
				_event_viewport.y,
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
			draw_set_color(c_white);
		}

		for (var _cultist_index = 0; _cultist_index < _cultist_count; ++_cultist_index)
		{
			var _cultist = global.event_cultists[_cultist_index];

			if (!instance_exists(_cultist) || _cultist == jobs_dragged_cultist)
			{
				continue;
			}

			var _cultist_is_in_scroll_list = is_struct(_cultist.assigned_event);
			if (_cultist_is_in_scroll_list != _draw_assigned_cultists)
			{
				continue;
			}

			var _cultist_reveal_alpha = _cultist_is_in_scroll_list
				? jobs_event_reveal_alpha_get(_cultist.assigned_event)
				: 1;
			if (_cultist_reveal_alpha <= 0)
			{
				continue;
			}

			var _cultist_rect = jobs_cultist_rect_get(_cultist);

			if (!is_struct(_cultist_rect))
			{
				continue;
			}

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
			var _cultist_angle = variable_instance_exists(_cultist, "is_unconscious")
				&& _cultist.is_unconscious
				? 90
				: 0;
			draw_sprite_ext(
				_cultist.sprite_index,
				_cultist.image_index,
				_cultist_rect.x + (_cultist_rect.width * 0.5),
				_cultist_rect.y + (_cultist_rect.height * 0.62) + (20 * _layout.scale),
				_sprite_scale,
				_sprite_scale,
				_cultist_angle,
				c_white,
				_cultist_reveal_alpha
			);
			draw_set_alpha(_cultist_reveal_alpha);
			draw_set_halign(fa_center);
			draw_set_valign(fa_top);
			draw_set_font(jobs_hp_font);
			var _cultist_text_x = _cultist_rect.x + (_cultist_rect.width * 0.5);
			// One red eye per remaining Spirit, drawn directly over the Cultist portrait.
			for (var _spirit_index = 0; _spirit_index < _cultist.spirit; ++_spirit_index)
			{
				draw_sprite_ext(s_spirit_eye_red, 0,
					_cultist_rect.x + (jobs_spirit_icon_offset_x * _layout.scale),
					_cultist_rect.y + ((jobs_spirit_icon_offset_y
						+ _spirit_index * jobs_spirit_icon_step) * _layout.scale),
					_layout.scale, _layout.scale, 0, c_white, _cultist_reveal_alpha);
			}
			var _cultist_name_y = _cultist_rect.y - (8 * _layout.scale);
			var _cultist_hp_y = _cultist_rect.y + _cultist_rect.height + (4 * _layout.scale);

			// Match the Figma worker stack: name above the portrait, HP and event cost below it.
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
					var _hp_rows_data = jobs_event_cultist_hp_rows_get(
						_preview_event,
						_preview_slot_index,
						_cultist
					);
					var _hp_preview = _hp_rows_data.preview;

					for (var _hp_row_index = 0;
						_hp_row_index < array_length(_hp_rows_data.rows);
						++_hp_row_index)
					{
						var _hp_row = _hp_rows_data.rows[_hp_row_index];
						var _hp_row_rect = jobs_hp_preview_row_rect_get(
							_cultist_rect,
							_hp_row_index,
							jobs_assigned_hp_preview_offset_y
						);
						draw_set_color(_hp_row.color);
						draw_text(_cultist_text_x, _hp_row_rect.y, _hp_row.text);
					}

					if (_hp_preview.loses_consciousness)
					{
						draw_set_valign(fa_middle);
						draw_set_color(COLOR_STATUS_NEGATIVE_RED);
						draw_text(
							_cultist_text_x,
							_cultist_rect.y + (_cultist_rect.height * 0.5),
							"KO"
						);
					}
				}
			}

			if (_cultist_is_in_scroll_list)
			{
				gpu_set_scissor(_previous_scissor);
			}
			draw_set_alpha(1);
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

	// Draw the Whip in its pool slot or attached to the cursor while LMB is held.
	if (instance_exists(jobs_whip) && sprite_exists(jobs_whip.sprite_index))
	{
		var _whip_is_held = jobs_whip.is_held;
		var _whip_position = _whip_is_held
			? [device_mouse_x_to_gui(0), device_mouse_y_to_gui(0)]
			: jobs_whip_home_position_get();
		var _whip_scale = (_whip_is_held ? jobs_whip_held_scale : jobs_whip_home_scale)
			* _layout.scale;

		draw_set_alpha(1);
		draw_set_color(c_white);
		draw_sprite_ext(
			jobs_whip.sprite_index,
			0,
			_whip_position[0],
			_whip_position[1],
			_whip_scale,
			_whip_scale,
			0,
			c_white,
			1
		);

		var _whip_hint = "";

		if (_whip_is_held
			&& jobs_whip.whip_cultist_is_valid(jobs_hovered_cultist))
		{
			_whip_hint = jobs_whip_target_hint;
		}
		else if (!_whip_is_held && jobs_whip_hovered)
		{
			_whip_hint = jobs_whip_pickup_hint;
		}

		if (_whip_hint != "")
		{
			draw_set_font(jobs_hp_font);
			var _hint_padding_x = jobs_whip_tooltip_padding_x * _layout.scale;
			var _hint_padding_y = jobs_whip_tooltip_padding_y * _layout.scale;
			var _hint_width = (string_width(_whip_hint) * _layout.scale) + (_hint_padding_x * 2);
			var _hint_height = (string_height(_whip_hint) * _layout.scale) + (_hint_padding_y * 2);
			var _hint_margin = jobs_whip_tooltip_margin * _layout.scale;
			var _hint_x = clamp(
				device_mouse_x_to_gui(0) - (_hint_width * 0.5),
				_hint_margin,
				display_get_gui_width() - _hint_width - _hint_margin
			);
			var _hint_y = min(
				device_mouse_y_to_gui(0) + (jobs_whip_tooltip_offset_y * _layout.scale),
				display_get_gui_height() - _hint_height - _hint_margin
			);

			draw_set_alpha(jobs_whip_tooltip_background_alpha);
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
				_whip_hint,
				_layout.scale,
				_layout.scale,
				0
			);
			draw_set_halign(fa_left);
			draw_set_valign(fa_top);
		}
	}

	// Dragged cultist follows the cursor above all cards.
	if (instance_exists(jobs_dragged_cultist))
	{
		var _drag_sprite = jobs_dragged_cultist.sprite_index;
		var _drag_mouse_x = device_mouse_x_to_gui(0);
		var _drag_mouse_y = device_mouse_y_to_gui(0);
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
		// Keep the remaining Spirit visible while the worker is being dragged.
		for (var _drag_spirit_index = 0; _drag_spirit_index < jobs_dragged_cultist.spirit; ++_drag_spirit_index)
		{
			draw_sprite_ext(s_spirit_eye_red, 0,
				_drag_mouse_x - (jobs_icon_width * 0.5 - jobs_spirit_icon_offset_x) * _layout.scale,
				_drag_mouse_y - (jobs_icon_height * 0.5 - jobs_spirit_icon_offset_y
					- _drag_spirit_index * jobs_spirit_icon_step) * _layout.scale,
				_layout.scale, _layout.scale, 0, c_white, 1);
		}

		if (jobs_spirit_assignment_blocked)
		{
			// Explain the rejected assignment above cards without covering the target slot.
			draw_set_font(jobs_hp_font);
			draw_set_halign(fa_left);
			draw_set_valign(fa_top);
			var _spirit_hint_text = "NOT ENOUGH SPIRIT";
			var _spirit_hint_padding = 8 * _layout.scale;
			var _spirit_hint_icon_space = 22 * _layout.scale;
			var _spirit_hint_width = string_width(_spirit_hint_text) + _spirit_hint_icon_space
				+ (_spirit_hint_padding * 2);
			var _spirit_hint_height = max(string_height(_spirit_hint_text),
				sprite_get_height(s_spirit_eye_red) * _layout.scale) + (_spirit_hint_padding * 2);
			var _spirit_hint_x = clamp(_drag_mouse_x + _spirit_hint_padding,
				0, max(0, display_get_gui_width() - _spirit_hint_width));
			var _spirit_hint_y = clamp(_drag_mouse_y + _spirit_hint_padding,
				0, max(0, display_get_gui_height() - _spirit_hint_height));
			draw_set_color(COLOR_JOBS_ASSIGN_BACKGROUND);
			draw_rectangle(_spirit_hint_x, _spirit_hint_y,
				_spirit_hint_x + _spirit_hint_width, _spirit_hint_y + _spirit_hint_height, false);
			draw_sprite_ext(s_spirit_eye_red, 0,
				_spirit_hint_x + _spirit_hint_padding + (7 * _layout.scale),
				_spirit_hint_y + _spirit_hint_height * 0.5, _layout.scale, _layout.scale, 0, c_white, 1);
			draw_set_color(COLOR_STATUS_NEGATIVE_RED);
			draw_text(_spirit_hint_x + _spirit_hint_padding + _spirit_hint_icon_space,
				_spirit_hint_y + _spirit_hint_padding, _spirit_hint_text);
			draw_set_color(c_white);
			draw_set_alpha(1);
		}
	}
	else if ((!instance_exists(jobs_whip) || !jobs_whip.is_held)
		&& instance_exists(jobs_hovered_cultist)
		&& sprite_exists(s_hand))
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

	// Relic and shell enchantment choices show their full effect on hover.
	if (_hovered_result_relic != RELIC.NONE || is_struct(_hovered_shell_enchantment_choice))
	{
		var _tooltip_width = 340 * _layout.scale;
		var _tooltip_padding = 12 * _layout.scale;
		var _tooltip_margin = 8 * _layout.scale;
		var _tooltip_mouse_offset = 14 * _layout.scale;
		var _tooltip_line_separation = 16 * _layout.scale;
		var _tooltip_title_gap = 7 * _layout.scale;
		var _tooltip_title = _hovered_result_relic != RELIC.NONE
			? squad_relic_name_get(_hovered_result_relic)
			: _hovered_shell_enchantment_choice.title;
		var _tooltip_description = _hovered_result_relic != RELIC.NONE
			? squad_relic_description_get(_hovered_result_relic)
			: _hovered_shell_enchantment_choice.description;
		var _tooltip_text_width = _tooltip_width - (_tooltip_padding * 2);
		draw_set_font(jobs_title_font);
		var _tooltip_title_height = string_height(_tooltip_title);
		draw_set_font(jobs_description_font);
		var _tooltip_description_height = string_height_ext(
			_tooltip_description,
			_tooltip_line_separation,
			_tooltip_text_width
		);
		var _tooltip_height = (_tooltip_padding * 2)
			+ _tooltip_title_height
			+ _tooltip_title_gap
			+ _tooltip_description_height;
		var _tooltip_x = clamp(
			_mouse_gui_x + _tooltip_mouse_offset,
			_tooltip_margin,
			display_get_gui_width() - _tooltip_width - _tooltip_margin
		);
		var _tooltip_y = _mouse_gui_y + _tooltip_mouse_offset;

		if (_tooltip_y + _tooltip_height > display_get_gui_height() - _tooltip_margin)
		{
			_tooltip_y = _mouse_gui_y - _tooltip_height - _tooltip_mouse_offset;
		}

		_tooltip_y = clamp(
			_tooltip_y,
			_tooltip_margin,
			display_get_gui_height() - _tooltip_height - _tooltip_margin
		);

		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		draw_set_alpha(0.97);
		draw_set_color(COLOR_JOBS_ASSIGN_BACKGROUND);
		draw_rectangle(
			_tooltip_x,
			_tooltip_y,
			_tooltip_x + _tooltip_width,
			_tooltip_y + _tooltip_height,
			false
		);
		draw_set_alpha(1);
		draw_set_color(COLOR_JOBS_EVENT_ACTIVE);
		draw_rectangle(
			_tooltip_x,
			_tooltip_y,
			_tooltip_x + _tooltip_width,
			_tooltip_y + _tooltip_height,
			true
		);
		draw_set_font(jobs_title_font);
		draw_text(
			_tooltip_x + _tooltip_padding,
			_tooltip_y + _tooltip_padding,
			_tooltip_title
		);
		draw_set_font(jobs_description_font);
		draw_set_color(COLOR_JOBS_ASSIGN_TEXT);
		draw_text_ext(
			_tooltip_x + _tooltip_padding,
			_tooltip_y + _tooltip_padding + _tooltip_title_height + _tooltip_title_gap,
			_tooltip_description,
			_tooltip_line_separation,
			_tooltip_text_width
		);
	}

	// After the overview closes, point directly at the first recruitment Rite card.
	var _show_squad_rite_hint = jobs_assign_rites_overview_closed
		&& !jobs_first_squad_rite_completed
		&& (!variable_global_exists("tutorial_hints_enabled") || global.tutorial_hints_enabled)
		&& (!variable_global_exists("tutorial_popup_active") || !global.tutorial_popup_active);

	if (_show_squad_rite_hint)
	{
		var _squad_rite_event_index = jobs_first_squad_rite_event_index_get();

		if (_squad_rite_event_index >= 0)
		{
			var _squad_rite_event = global.day_events[_squad_rite_event_index];
			var _squad_rite_slot_count = _squad_rite_event.cultist_cost
				* _squad_rite_event.activation_limit;
			var _squad_rite_left_slot = jobs_event_slot_rect_get(
				_squad_rite_event_index,
				0,
				_squad_rite_slot_count
			);
			var _squad_rite_arrow_scale = jobs_squad_rite_hint_arrow_scale * _layout.scale;
			var _squad_rite_arrow_width = sprite_exists(s_attack_arrow)
				? sprite_get_width(s_attack_arrow) * _squad_rite_arrow_scale
				: 0;
			var _squad_rite_arrow_x = _squad_rite_left_slot.x - (18 * _layout.scale);
			var _squad_rite_arrow_y = _squad_rite_left_slot.y
				+ (_squad_rite_left_slot.height * 0.5);
			var _squad_rite_previous_font = draw_get_font();
			draw_set_font(jobs_onboarding_font);

			var _squad_rite_max_text_width = jobs_squad_rite_hint_max_width
				- (jobs_squad_rite_hint_padding_x * 2);
			var _squad_rite_text_width = min(
				_squad_rite_max_text_width,
				string_width(jobs_squad_rite_hint_text)
			);
			var _squad_rite_width = (_squad_rite_text_width
				+ (jobs_squad_rite_hint_padding_x * 2)) * _layout.scale;
			var _squad_rite_padding_x = jobs_squad_rite_hint_padding_x * _layout.scale;
			var _squad_rite_padding_y = jobs_squad_rite_hint_padding_y * _layout.scale;
			var _squad_rite_text_height = string_height_ext(
				jobs_squad_rite_hint_text,
				jobs_squad_rite_hint_line_height,
				_squad_rite_text_width
			) * _layout.scale;
			var _squad_rite_height = _squad_rite_text_height + (_squad_rite_padding_y * 2);
			var _squad_rite_margin = 18 * _layout.scale;
			var _squad_rite_box_right = _squad_rite_arrow_x
				- _squad_rite_arrow_width
				- (jobs_squad_rite_hint_gap_from_arrow * _layout.scale);
			var _squad_rite_x = clamp(
				_squad_rite_box_right - _squad_rite_width,
				_squad_rite_margin,
				_gui_width - _squad_rite_width - _squad_rite_margin
			);
			var _squad_rite_y = clamp(
				_squad_rite_arrow_y - (_squad_rite_height * 0.5),
				_squad_rite_margin,
				_gui_height - _squad_rite_height - _squad_rite_margin
			);
			var _squad_rite_pulse = 0.88 + (sin(current_time * 0.006) * 0.08);

			draw_set_halign(fa_left);
			draw_set_valign(fa_top);
			draw_set_alpha(jobs_squad_rite_hint_background_alpha * _squad_rite_pulse);
			draw_set_color(COLOR_HUD_BACKGROUND);
			draw_rectangle(
				_squad_rite_x,
				_squad_rite_y,
				_squad_rite_x + _squad_rite_width,
				_squad_rite_y + _squad_rite_height,
				false
			);
			draw_set_alpha(_squad_rite_pulse);
			draw_set_color(COLOR_HUD_TEXT);
			draw_text_ext_transformed(
				_squad_rite_x + _squad_rite_padding_x,
				_squad_rite_y + _squad_rite_padding_y,
				jobs_squad_rite_hint_text,
				jobs_squad_rite_hint_line_height,
				_squad_rite_text_width,
				_layout.scale,
				_layout.scale,
				0
			);

			if (sprite_exists(s_attack_arrow))
			{
				draw_sprite_ext(
					s_attack_arrow,
					0,
					_squad_rite_arrow_x,
					_squad_rite_arrow_y,
					_squad_rite_arrow_scale,
					_squad_rite_arrow_scale,
					jobs_squad_rite_hint_arrow_angle,
					c_white,
					BALANCE_ATTACK_ARROW_ALPHA * _squad_rite_pulse
				);
			}

			draw_set_font(_squad_rite_previous_font);
			draw_set_halign(fa_left);
			draw_set_valign(fa_top);
			draw_set_color(c_white);
			draw_set_alpha(1);
		}
	}

	// Point at the Blood Bath construction Rite after the forced building choice.
	var _blood_bath_rite_event_index = jobs_blood_bath_construction_event_index_get();

	if (_blood_bath_rite_event_index >= 0
		&& (!variable_global_exists("tutorial_hints_enabled") || global.tutorial_hints_enabled)
		&& (!variable_global_exists("tutorial_popup_active") || !global.tutorial_popup_active))
	{
		var _blood_bath_rite_event = global.day_events[_blood_bath_rite_event_index];
		var _blood_bath_rite_slot_count = _blood_bath_rite_event.cultist_cost
			* _blood_bath_rite_event.activation_limit;
		var _blood_bath_rite_left_slot = jobs_event_slot_rect_get(
			_blood_bath_rite_event_index,
			0,
			_blood_bath_rite_slot_count
		);
		var _blood_bath_rite_arrow_scale = jobs_squad_rite_hint_arrow_scale * _layout.scale;
		var _blood_bath_rite_arrow_width = sprite_exists(s_attack_arrow)
			? sprite_get_width(s_attack_arrow) * _blood_bath_rite_arrow_scale
			: 0;
		var _blood_bath_rite_arrow_x = _blood_bath_rite_left_slot.x - (18 * _layout.scale);
		var _blood_bath_rite_arrow_y = _blood_bath_rite_left_slot.y
			+ (_blood_bath_rite_left_slot.height * 0.5);
		var _blood_bath_rite_previous_font = draw_get_font();
		draw_set_font(jobs_onboarding_font);

		var _blood_bath_rite_max_text_width = jobs_squad_rite_hint_max_width
			- (jobs_squad_rite_hint_padding_x * 2);
		var _blood_bath_rite_text_width = min(
			_blood_bath_rite_max_text_width,
			string_width(jobs_blood_bath_rite_hint_text)
		);
		var _blood_bath_rite_width = (_blood_bath_rite_text_width
			+ (jobs_squad_rite_hint_padding_x * 2)) * _layout.scale;
		var _blood_bath_rite_padding_x = jobs_squad_rite_hint_padding_x * _layout.scale;
		var _blood_bath_rite_padding_y = jobs_squad_rite_hint_padding_y * _layout.scale;
		var _blood_bath_rite_text_height = string_height_ext(
			jobs_blood_bath_rite_hint_text,
			jobs_squad_rite_hint_line_height,
			_blood_bath_rite_text_width
		) * _layout.scale;
		var _blood_bath_rite_height = _blood_bath_rite_text_height + (_blood_bath_rite_padding_y * 2);
		var _blood_bath_rite_margin = 18 * _layout.scale;
		var _blood_bath_rite_box_right = _blood_bath_rite_arrow_x
			- _blood_bath_rite_arrow_width
			- (jobs_squad_rite_hint_gap_from_arrow * _layout.scale);
		var _blood_bath_rite_x = clamp(
			_blood_bath_rite_box_right - _blood_bath_rite_width,
			_blood_bath_rite_margin,
			_gui_width - _blood_bath_rite_width - _blood_bath_rite_margin
		);
		var _blood_bath_rite_y = clamp(
			_blood_bath_rite_arrow_y - (_blood_bath_rite_height * 0.5),
			_blood_bath_rite_margin,
			_gui_height - _blood_bath_rite_height - _blood_bath_rite_margin
		);
		var _blood_bath_rite_pulse = 0.88 + (sin(current_time * 0.006) * 0.08);

		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		draw_set_alpha(jobs_squad_rite_hint_background_alpha * _blood_bath_rite_pulse);
		draw_set_color(COLOR_HUD_BACKGROUND);
		draw_rectangle(
			_blood_bath_rite_x,
			_blood_bath_rite_y,
			_blood_bath_rite_x + _blood_bath_rite_width,
			_blood_bath_rite_y + _blood_bath_rite_height,
			false
		);
		draw_set_alpha(_blood_bath_rite_pulse);
		draw_set_color(COLOR_HUD_TEXT);
		draw_text_ext_transformed(
			_blood_bath_rite_x + _blood_bath_rite_padding_x,
			_blood_bath_rite_y + _blood_bath_rite_padding_y,
			jobs_blood_bath_rite_hint_text,
			jobs_squad_rite_hint_line_height,
			_blood_bath_rite_text_width,
			_layout.scale,
			_layout.scale,
			0
		);

		if (sprite_exists(s_attack_arrow))
		{
			draw_sprite_ext(
				s_attack_arrow,
				0,
				_blood_bath_rite_arrow_x,
				_blood_bath_rite_arrow_y,
				_blood_bath_rite_arrow_scale,
				_blood_bath_rite_arrow_scale,
				jobs_squad_rite_hint_arrow_angle,
				c_white,
				BALANCE_ATTACK_ARROW_ALPHA * _blood_bath_rite_pulse
			);
		}

		draw_set_font(_blood_bath_rite_previous_font);
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		draw_set_color(c_white);
		draw_set_alpha(1);
	}

	// Introduce the possessed cannon when its first demand appears at the top of day two.
	var _first_event_is_cannon_demand = array_length(global.day_events) > 0
		&& is_struct(global.day_events[0])
		&& variable_struct_exists(global.day_events[0], "is_cannon_demand")
		&& global.day_events[0].is_cannon_demand;
	var _show_cannon_satisfaction_hint = day_event_current_day_get()
		== BALANCE_CANNON_SATISFACTION_UNLOCK_DAY
		&& _first_event_is_cannon_demand
		&& (!variable_global_exists("tutorial_hints_enabled") || global.tutorial_hints_enabled);

	if (_show_cannon_satisfaction_hint)
	{
		var _cannon_hint_design_offset_x = _layout.panel_x
			- (jobs_onboarding_design_panel_x * _layout.scale);
		var _cannon_hint_text_x = _cannon_hint_design_offset_x
			+ (jobs_cannon_satisfaction_hint_text_x * _layout.scale);
		var _cannon_hint_text_y = jobs_cannon_satisfaction_hint_text_y * _layout.scale;

		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		draw_set_color(COLOR_JOBS_EVENT_ACTION);
		draw_set_alpha(1);
		draw_set_font(jobs_show_font);
		draw_text_ext_transformed(
			_cannon_hint_text_x,
			_cannon_hint_text_y,
			jobs_cannon_satisfaction_hint_text,
			jobs_cannon_satisfaction_hint_text_line_height,
			jobs_cannon_satisfaction_hint_text_width,
			_layout.scale,
			_layout.scale,
			0
		);

		if (sprite_exists(s_attack_arrow))
		{
			var _cannon_hint_arrow_x = _cannon_hint_design_offset_x
				+ (jobs_cannon_satisfaction_hint_arrow_x * _layout.scale);
			var _cannon_hint_arrow_y = jobs_cannon_satisfaction_hint_arrow_y * _layout.scale;
			var _cannon_hint_arrow_scale = jobs_cannon_satisfaction_hint_arrow_scale
				* _layout.scale;

			draw_sprite_ext(
				s_attack_arrow,
				0,
				_cannon_hint_arrow_x,
				_cannon_hint_arrow_y,
				_cannon_hint_arrow_scale,
				_cannon_hint_arrow_scale,
				0,
				c_white,
				BALANCE_ATTACK_ARROW_ALPHA
			);
		}
	}

	// Whip rewards float above the fixed pool and cards, outside the scrolling clip.
	var _whip_popup_count = array_length(jobs_whip_feedback_popups);
	if (_whip_popup_count > 0)
	{
		var _popup_previous_font = draw_get_font();
		var _popup_margin = jobs_whip_feedback_margin * _layout.scale;
		var _popup_shadow_offset = jobs_whip_feedback_shadow_offset * _layout.scale;
		draw_set_font(jobs_action_font);
		draw_set_halign(fa_center);
		draw_set_valign(fa_top);

		for (var _popup_index = 0; _popup_index < _whip_popup_count; ++_popup_index)
		{
			var _popup = jobs_whip_feedback_popups[_popup_index];
			var _popup_progress = clamp(_popup.elapsed_seconds / jobs_whip_feedback_duration_seconds, 0, 1);
			var _popup_half_width = string_width(_popup.text) * _layout.scale * 0.5;
			var _popup_x = clamp(_popup.x,
				_popup_half_width + _popup_margin, _gui_width - _popup_half_width - _popup_margin);
			var _popup_y = max(_popup_margin,
				_popup.y - (_popup_progress * jobs_whip_feedback_rise * _layout.scale));

			draw_set_alpha(1 - _popup_progress);
			draw_set_color(COLOR_JOBS_ASSIGN_BACKGROUND);
			draw_text_transformed(_popup_x + _popup_shadow_offset, _popup_y + _popup_shadow_offset,
				_popup.text, _layout.scale, _layout.scale, 0);
			draw_set_color(COLOR_ABILITY_POPUP);
			draw_text_transformed(_popup_x, _popup_y, _popup.text, _layout.scale, _layout.scale, 0);
		}

		draw_set_font(_popup_previous_font);
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		draw_set_color(c_white);
		draw_set_alpha(1);
	}

	// Keep contextual explanations above the Assign Rites window.
	jobs_cultist_info_draw();
	jobs_hp_modifier_tooltip_draw();
	jobs_building_overuse_tooltip_draw();

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

// The cannon's world meter remains above the Assign Rites panel as requested.
if (global.focus_window == FOCUS_WINDOW.JOBS)
{
	cannon_satisfaction_world_ui_draw();
}
