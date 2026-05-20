// Toggle pause menu with Escape.
if (keyboard_check_pressed(vk_escape))
{
	pause_menu_open = !pause_menu_open;
	settings_open = false;
	global.pause = pause_menu_open;
}

// Keep game surfaces aligned with the current window size.
var _window_width = window_get_width();
var _window_height = window_get_height();

if (_window_width != previous_window_width || _window_height != previous_window_height)
{
	current_view_width = _window_width;
	current_view_height = _window_height;
	previous_window_width = _window_width;
	previous_window_height = _window_height;

	if (!fullscreen_enabled)
	{
		windowed_view_width = current_view_width;
		windowed_view_height = current_view_height;
	}

	// Keep the game resolution fixed and let GameMaker apply aspect correction.
	display_set_gui_size(camera_view_width, camera_view_height);
	view_xport[main_view_index] = 0;
	view_yport[main_view_index] = 0;
	view_wport[main_view_index] = camera_view_width;
	view_hport[main_view_index] = camera_view_height;

	if (surface_exists(application_surface))
	{
		surface_resize(application_surface, camera_view_width, camera_view_height);
		application_surface_ready = true;
	}
}

// Resize the application surface once it becomes available.
if (!application_surface_ready && surface_exists(application_surface))
{
	surface_resize(application_surface, camera_view_width, camera_view_height);
	application_surface_ready = true;
}

// Handle pause menu buttons.
if (pause_menu_open && mouse_check_button_pressed(mb_left))
{
	var _mouse_x = device_mouse_x_to_gui(0);
	var _mouse_y = device_mouse_y_to_gui(0);
	var _button_x = (camera_view_width - button_width) * 0.5;
	var _button_y = (camera_view_height - ((button_height * pause_button_count) + (button_gap * (pause_button_count - 1)))) * 0.5;
	var _button_step = button_height + button_gap;

	if (!settings_open)
	{
		if (_mouse_x >= _button_x && _mouse_x <= _button_x + button_width)
		{
			var _continue_button_y = _button_y + (_button_step * continue_button_index);
			var _settings_button_y = _button_y + (_button_step * settings_button_index);
			var _quit_button_y = _button_y + (_button_step * quit_button_index);

			if (_mouse_y >= _continue_button_y && _mouse_y <= _continue_button_y + button_height)
			{
				pause_menu_open = false;
				global.pause = false;
			}
			else if (_mouse_y >= _settings_button_y && _mouse_y <= _settings_button_y + button_height)
			{
				settings_open = true;
			}
			else if (_mouse_y >= _quit_button_y && _mouse_y <= _quit_button_y + button_height)
			{
				game_end();
			}
		}
	}
	else
	{
		var _panel_x = (camera_view_width - settings_panel_width) * 0.5;
		var _panel_y = (camera_view_height - settings_panel_height) * 0.5;
		var _toggle_x = _panel_x + settings_panel_width - settings_toggle_right_padding;
		var _toggle_y = _panel_y + settings_toggle_top_padding;
		var _close_button_x = _panel_x + ((settings_panel_width - button_width) * 0.5);
		var _close_button_y = _panel_y + settings_panel_height - button_height - settings_close_bottom_padding;

		if (_mouse_x >= _toggle_x && _mouse_x <= _toggle_x + fullscreen_toggle_size && _mouse_y >= _toggle_y && _mouse_y <= _toggle_y + fullscreen_toggle_size)
		{
			fullscreen_enabled = !fullscreen_enabled;

			if (fullscreen_enabled)
			{
				windowed_view_width = current_view_width;
				windowed_view_height = current_view_height;
			}

			window_set_fullscreen(fullscreen_enabled);

			if (!fullscreen_enabled)
			{
				window_set_size(windowed_view_width, windowed_view_height);
			}
		}

		if (_mouse_x >= _close_button_x && _mouse_x <= _close_button_x + button_width && _mouse_y >= _close_button_y && _mouse_y <= _close_button_y + button_height)
		{
			settings_open = false;
		}
	}
}
