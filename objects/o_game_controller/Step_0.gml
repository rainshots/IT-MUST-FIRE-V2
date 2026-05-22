// F3 toggles fog visibility for fast map testing.
if (keyboard_check_pressed(vk_f3))
{
	global.fog_of_war_visible = !global.fog_of_war_visible;
}

// F2 enables infinite projectile testing with one projectile of every known type.
if (keyboard_check_pressed(vk_f2))
{
	var _cheat_projectile_count = array_length(global.cannon_projectile_drop_types);

	global.cannon_projectile_queue = array_create(_cheat_projectile_count);
	global.cannon_projectile_cheat_enabled = true;
	global.cannon_projectile_gain_timer = 0;
	target_selection_projectile_type = global.cannon_projectile_drop_types[0];

	for (var _cheat_projectile_index = 0; _cheat_projectile_index < _cheat_projectile_count; ++_cheat_projectile_index)
	{
		global.cannon_projectile_queue[_cheat_projectile_index] = global.cannon_projectile_drop_types[_cheat_projectile_index];
	}
}

// Resolve Escape by the current focused window.
if (keyboard_check_pressed(vk_escape))
{
	if (global.focus_window == FOCUS_WINDOW.TARGET_SELECTION)
	{
		global.focus_window = FOCUS_WINDOW.NOONE;
	}
	else if (global.focus_window == FOCUS_WINDOW.SETTINGS)
	{
		settings_open = false;
		global.focus_window = FOCUS_WINDOW.PAUSE_MENU;
	}
	else if (global.focus_window == FOCUS_WINDOW.PAUSE_MENU)
	{
		pause_menu_open = false;
		settings_open = false;
		global.pause = false;
		global.focus_window = FOCUS_WINDOW.NOONE;
	}
	else
	{
		pause_menu_open = true;
		settings_open = false;
		global.pause = true;
		global.focus_window = FOCUS_WINDOW.PAUSE_MENU;
	}
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

// Update day and night cycle.
if (!global.pause)
{
	if (global.day_phase == DAY_PHASE.DAY)
	{
		global.night_attack_unit_count = 0;
		global.day_timer--;

		if (global.day_timer <= 0)
		{
			global.day_phase = DAY_PHASE.NIGHT;

			with (o_garnizon)
			{
				if (is_activated)
				{
					release_owned_units();
				}
			}

			var _released_enemy_count = instance_number(o_enemy_units);

			for (var _enemy_index = 0; _enemy_index < _released_enemy_count; ++_enemy_index)
			{
				var _enemy = instance_find(o_enemy_units, _enemy_index);

				if (instance_exists(_enemy)
					&& variable_instance_exists(_enemy, "owner_garnizon")
					&& instance_exists(_enemy.owner_garnizon)
					&& _enemy.owner_garnizon.is_activated)
				{
					_enemy.unit_can_attack_cannon = true;
					_enemy.is_night_attack_unit = true;
					_enemy.guard_target = noone;
					_enemy.owner_garnizon = noone;
				}
			}
		}
	}
	else if (global.day_phase == DAY_PHASE.NIGHT)
	{
		var _night_unit_count = 0;
		var _night_enemy_count = instance_number(o_enemy_units);

		for (var _enemy_index = 0; _enemy_index < _night_enemy_count; ++_enemy_index)
		{
			var _enemy = instance_find(o_enemy_units, _enemy_index);

			if (instance_exists(_enemy)
				&& variable_instance_exists(_enemy, "is_night_attack_unit")
				&& _enemy.is_night_attack_unit)
			{
				_night_unit_count++;
			}
		}

		global.night_attack_unit_count = _night_unit_count;

		if (_night_unit_count <= 0)
		{
			global.day_phase = DAY_PHASE.DAY;
			global.day_timer = global.day_duration * room_speed;
			global.night_attack_unit_count = 0;
		}
	}
}

// Add a new projectile to the back of the queue at a fixed room-speed-aware interval.
if (!global.pause && variable_global_exists("cannon_projectile_queue") && !global.cannon_projectile_cheat_enabled)
{
	var _projectile_queue_count = array_length(global.cannon_projectile_queue);
	var _projectile_gain_interval = global.cannon_projectile_gain_time * room_speed;

	if (_projectile_queue_count < global.cannon_projectile_queue_max)
	{
		global.cannon_projectile_gain_timer++;

		if (global.cannon_projectile_gain_timer >= _projectile_gain_interval)
		{
			var _drop_type_count = array_length(global.cannon_projectile_drop_types);
			var _new_projectile_type = global.cannon_projectile_drop_types[irandom(_drop_type_count - 1)];

			array_push(global.cannon_projectile_queue, _new_projectile_type);
			global.cannon_projectile_gain_timer = 0;
		}
	}
	else
	{
		global.cannon_projectile_gain_timer = 0;
	}
}

// Start or update target selection mode from hotkeys when a queued projectile is ready.
if (global.focus_window == FOCUS_WINDOW.NOONE
	|| (global.cannon_projectile_cheat_enabled && global.focus_window == FOCUS_WINDOW.TARGET_SELECTION))
{
	var _projectile_queue_count = array_length(global.cannon_projectile_queue);

	if (global.cannon_projectile_cheat_enabled)
	{
		var _selected_projectile_index = -1;
		var _max_digit_count = min(_projectile_queue_count, 9);

		for (var _digit_index = 0; _digit_index < _max_digit_count; ++_digit_index)
		{
			if (keyboard_check_pressed(ord(string(_digit_index + 1))))
			{
				_selected_projectile_index = _digit_index;
				break;
			}
		}

		if (_selected_projectile_index >= 0)
		{
			var _selected_projectile_type = global.cannon_projectile_queue[_selected_projectile_index];

			for (var _queue_index = _selected_projectile_index; _queue_index > 0; --_queue_index)
			{
				global.cannon_projectile_queue[_queue_index] = global.cannon_projectile_queue[_queue_index - 1];
			}

			global.cannon_projectile_queue[0] = _selected_projectile_type;
			target_selection_projectile_type = _selected_projectile_type;
			global.focus_window = FOCUS_WINDOW.TARGET_SELECTION;
		}
	}
	else
	{
		var _target_hotkey_pressed = keyboard_check_pressed(ord("1"))
			|| keyboard_check_pressed(ord("2"))
			|| keyboard_check_pressed(ord("3"));

		if (_target_hotkey_pressed && _projectile_queue_count > 0)
		{
			target_selection_projectile_type = global.cannon_projectile_queue[0];
			global.focus_window = FOCUS_WINDOW.TARGET_SELECTION;
		}
	}
}

// Confirm target selection with left mouse button.
if (global.focus_window == FOCUS_WINDOW.TARGET_SELECTION && mouse_check_button_pressed(mb_left))
{
	if (array_length(global.cannon_projectile_queue) <= 0)
	{
		global.focus_window = FOCUS_WINDOW.NOONE;
	}
	else if (instance_exists(o_camera_controller))
	{
		var _camera_controller = instance_find(o_camera_controller, 0);
		var _mouse_x = device_mouse_x_to_gui(0);
		var _mouse_y = device_mouse_y_to_gui(0);
		var _camera_x = camera_get_view_x(_camera_controller.camera_id);
		var _camera_y = camera_get_view_y(_camera_controller.camera_id);
		var _view_width = camera_get_view_width(_camera_controller.camera_id);
		var _view_height = camera_get_view_height(_camera_controller.camera_id);

		target_selection_projectile_type = global.cannon_projectile_queue[0];
		global.cannon_target_exists = true;
		global.cannon_target_x = _camera_x + ((_mouse_x / camera_view_width) * _view_width);
		global.cannon_target_y = _camera_y + ((_mouse_y / camera_view_height) * _view_height);
		global.cannon_target_projectile_type = target_selection_projectile_type;
		global.cannon_target_version++;
		global.focus_window = FOCUS_WINDOW.NOONE;
	}
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
				global.focus_window = FOCUS_WINDOW.NOONE;
			}
			else if (_mouse_y >= _settings_button_y && _mouse_y <= _settings_button_y + button_height)
			{
				settings_open = true;
				global.focus_window = FOCUS_WINDOW.SETTINGS;
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
			global.focus_window = FOCUS_WINDOW.PAUSE_MENU;
		}
	}
}
