// Draw daytime tint over the world while keeping HUD readable.
if (global.day_phase == DAY_PHASE.DAY)
{
	draw_set_alpha(night_overlay_alpha);
	draw_set_color(COLOR_NIGHT_OVERLAY);
	draw_rectangle(0, 0, camera_view_width, camera_view_height, false);
	draw_set_alpha(1);
	draw_set_color(c_white);
}

// Draw target selection radius under the cursor.
if (global.focus_window == FOCUS_WINDOW.TARGET_SELECTION && instance_exists(o_camera_controller))
{
	var _camera_controller = instance_find(o_camera_controller, 0);
	var _mouse_x = device_mouse_x_to_gui(0);
	var _mouse_y = device_mouse_y_to_gui(0);
	var _radius_scale = camera_view_width / _camera_controller.view_width;
	var _draw_radius = target_selection_radius * _radius_scale;
	var _target_color = COLOR_PROJECTILE_DAMAGE;

	if (target_selection_projectile_type == PROJECTILE_TYPE.CORRUPTION)
	{
		_target_color = COLOR_PROJECTILE_CORRUPTION;
	}
	else if (target_selection_projectile_type == PROJECTILE_TYPE.SUMMON)
	{
		_target_color = COLOR_PROJECTILE_SUMMON;
	}
	else if (target_selection_projectile_type == PROJECTILE_TYPE.RALLY)
	{
		_target_color = COLOR_PROJECTILE_RALLY;
	}

	draw_set_color(_target_color);
	draw_set_alpha(target_selection_alpha);
	draw_circle(_mouse_x, _mouse_y, _draw_radius, false);
	draw_set_alpha(target_selection_outline_alpha);
	draw_circle(_mouse_x, _mouse_y, _draw_radius, true);

	draw_set_color(c_white);
	draw_set_alpha(1);
}

// Draw nothing while the pause menu is closed.
if (!pause_menu_open)
{
	exit;
}

// Draw dimmed fullscreen overlay.
draw_set_alpha(overlay_alpha);
draw_set_color(c_black);
draw_rectangle(0, 0, camera_view_width, camera_view_height, false);
draw_set_alpha(1);

// Prepare centered menu text.
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

if (!settings_open)
{
	// Draw main pause menu buttons.
	var _button_x = (camera_view_width - button_width) * 0.5;
	var _button_y = (camera_view_height - ((button_height * pause_button_count) + (button_gap * (pause_button_count - 1)))) * 0.5;
	var _button_step = button_height + button_gap;

	for (var _button_index = 0; _button_index < pause_button_count; ++_button_index)
	{
		var _draw_y = _button_y + (_button_step * _button_index);

		draw_set_color(c_white);
		draw_rectangle(_button_x, _draw_y, _button_x + button_width, _draw_y + button_height, false);

		draw_set_color(c_black);
		draw_text(_button_x + (button_width * 0.5), _draw_y + (button_height * 0.5), pause_button_labels[_button_index]);
	}
}
else
{
	// Draw settings panel.
	var _panel_x = (camera_view_width - settings_panel_width) * 0.5;
	var _panel_y = (camera_view_height - settings_panel_height) * 0.5;
	var _toggle_x = _panel_x + settings_panel_width - settings_toggle_right_padding;
	var _toggle_y = _panel_y + settings_toggle_top_padding;
	var _close_button_x = _panel_x + ((settings_panel_width - button_width) * 0.5);
	var _close_button_y = _panel_y + settings_panel_height - button_height - settings_close_bottom_padding;

	draw_set_color(c_white);
	draw_rectangle(_panel_x, _panel_y, _panel_x + settings_panel_width, _panel_y + settings_panel_height, false);

	draw_set_color(c_black);
	draw_text(_panel_x + (settings_panel_width * 0.5), _panel_y + 34, "SETTINGS");

	draw_set_halign(fa_left);
	draw_text(_panel_x + 46, _toggle_y + (fullscreen_toggle_size * 0.5), "Fullscreen");

	draw_set_halign(fa_center);
	draw_rectangle(_toggle_x, _toggle_y, _toggle_x + fullscreen_toggle_size, _toggle_y + fullscreen_toggle_size, true);

	if (fullscreen_enabled)
	{
		var _check_padding = 8;
		draw_rectangle(
			_toggle_x + _check_padding,
			_toggle_y + _check_padding,
			_toggle_x + fullscreen_toggle_size - _check_padding,
			_toggle_y + fullscreen_toggle_size - _check_padding,
			false
		);
	}

	draw_rectangle(_close_button_x, _close_button_y, _close_button_x + button_width, _close_button_y + button_height, true);
	draw_text(_close_button_x + (button_width * 0.5), _close_button_y + (button_height * 0.5), "BACK");
}

// Restore default draw state.
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);
