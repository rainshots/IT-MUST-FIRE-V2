// F3 toggles fog visibility for fast map testing.
if (keyboard_check_pressed(vk_f3))
{
	global.fog_of_war_visible = !global.fog_of_war_visible;
}

// L restarts the current room for fast prototype iteration.
if (keyboard_check_pressed(ord("L")))
{
	room_restart();
	exit;
}

// Spawn the starting cultists once the cannon exists in the room.
if (!cultists_spawned)
{
	spawn_starting_cultists();
}

// Allow the player to pick up and reposition cultists during gameplay.
if (global.focus_window == FOCUS_WINDOW.NOONE && variable_global_exists("cultists") && instance_exists(o_camera_controller))
{
	var _camera_controller = instance_find(o_camera_controller, 0);
	var _mouse_gui_x = device_mouse_x_to_gui(0);
	var _mouse_gui_y = device_mouse_y_to_gui(0);
	var _camera_x = camera_get_view_x(_camera_controller.camera_id);
	var _camera_y = camera_get_view_y(_camera_controller.camera_id);
	var _camera_width = camera_get_view_width(_camera_controller.camera_id);
	var _camera_height = camera_get_view_height(_camera_controller.camera_id);
	var _mouse_world_x = _camera_x + ((_mouse_gui_x / camera_view_width) * _camera_width);
	var _mouse_world_y = _camera_y + ((_mouse_gui_y / camera_view_height) * _camera_height);

	if (instance_exists(global.dragged_cultist))
	{
		var _dragged_cultist = global.dragged_cultist;

		_dragged_cultist.x = _mouse_world_x;
		_dragged_cultist.y = _mouse_world_y + cultist_drag_lift_offset_y;
		_dragged_cultist.drag_drop_x = _mouse_world_x;
		_dragged_cultist.drag_drop_y = _mouse_world_y + cultist_drag_drop_offset_y;

		if (!mouse_check_button(mb_left))
		{
			_dragged_cultist.x = _dragged_cultist.drag_drop_x;
			_dragged_cultist.y = _dragged_cultist.drag_drop_y;
			_dragged_cultist.is_being_dragged = false;
			global.dragged_cultist = noone;
		}
	}
	else if (mouse_check_button_pressed(mb_left) && !global.pause)
	{
		var _cultist_count = array_length(global.cultists);
		var _closest_cultist = noone;
		var _closest_distance = infinity;

		for (var _cultist_index = 0; _cultist_index < _cultist_count; ++_cultist_index)
		{
			var _cultist = global.cultists[_cultist_index];

			if (instance_exists(_cultist)
				&& _mouse_world_x >= _cultist.bbox_left
				&& _mouse_world_x <= _cultist.bbox_right
				&& _mouse_world_y >= _cultist.bbox_top
				&& _mouse_world_y <= _cultist.bbox_bottom)
			{
				var _distance_to_cultist = point_distance(_mouse_world_x, _mouse_world_y, _cultist.x, _cultist.y);

				if (_distance_to_cultist < _closest_distance)
				{
					_closest_distance = _distance_to_cultist;
					_closest_cultist = _cultist;
				}
			}
		}

		if (instance_exists(_closest_cultist))
		{
			global.dragged_cultist = _closest_cultist;
			_closest_cultist.is_being_dragged = true;
			_closest_cultist.x = _mouse_world_x;
			_closest_cultist.y = _mouse_world_y + cultist_drag_lift_offset_y;
			_closest_cultist.drag_drop_x = _mouse_world_x;
			_closest_cultist.drag_drop_y = _mouse_world_y + cultist_drag_drop_offset_y;
		}
	}
}
else if (instance_exists(global.dragged_cultist))
{
	global.dragged_cultist.x = global.dragged_cultist.drag_drop_x;
	global.dragged_cultist.y = global.dragged_cultist.drag_drop_y;
	global.dragged_cultist.is_being_dragged = false;
	global.dragged_cultist = noone;
}

// F4 manually starts a combat-form test while the full day/night cycle is disabled.
if (keyboard_check_pressed(vk_f4) && global.focus_window == FOCUS_WINDOW.NOONE && !instance_exists(global.dragged_cultist))
{
	transform_cultists_to_demons();
}

// F5 opens the prototype level-up choice window.
if (keyboard_check_pressed(vk_f5) && global.focus_window == FOCUS_WINDOW.NOONE && !instance_exists(global.dragged_cultist))
{
	open_cultist_levelup();
}

// Right mouse button spawns blood particles at the cursor for particle testing.
if (mouse_check_button_pressed(mb_right) && global.focus_window == FOCUS_WINDOW.NOONE && instance_exists(o_camera_controller))
{
	var _camera_controller = instance_find(o_camera_controller, 0);
	var _mouse_gui_x = device_mouse_x_to_gui(0);
	var _mouse_gui_y = device_mouse_y_to_gui(0);
	var _camera_x = camera_get_view_x(_camera_controller.camera_id);
	var _camera_y = camera_get_view_y(_camera_controller.camera_id);
	var _camera_width = camera_get_view_width(_camera_controller.camera_id);
	var _camera_height = camera_get_view_height(_camera_controller.camera_id);
	var _mouse_world_x = _camera_x + ((_mouse_gui_x / camera_view_width) * _camera_width);
	var _mouse_world_y = _camera_y + ((_mouse_gui_y / camera_view_height) * _camera_height);

	blood_particles_create(_mouse_world_x, _mouse_world_y, BALANCE_BLOOD_PARTICLE_COUNT * 3);
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
	else if (global.focus_window == FOCUS_WINDOW.CULTIST_DEMON_SELECTION
		|| global.focus_window == FOCUS_WINDOW.CULTIST_LEVEL_UP)
	{
		// Cultist setup and level-up choices are mandatory prototype windows.
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

// Update day and night cycle when the prototype allows it.
if (!global.pause && global.day_cycle_enabled)
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
else
{
	global.day_phase = DAY_PHASE.DAY;
	global.day_timer = global.day_duration * room_speed;
	global.night_attack_unit_count = 0;
}

// Handle cultist demon selection window.
if (global.focus_window == FOCUS_WINDOW.CULTIST_DEMON_SELECTION && mouse_check_button_pressed(mb_left))
{
	var _mouse_x = device_mouse_x_to_gui(0);
	var _mouse_y = device_mouse_y_to_gui(0);
	var _panel_x = (camera_view_width - cultist_panel_width) * 0.5;
	var _panel_y = (camera_view_height - cultist_panel_height) * 0.5;
	var _button_start_x = _panel_x + 70;
	var _button_y = _panel_y + 360;
	var _button_step = cultist_selection_button_width + cultist_selection_button_gap;
	var _button_count = array_length(cultist_selection_buttons);

	for (var _button_index = 0; _button_index < _button_count; ++_button_index)
	{
		var _button_x = _button_start_x + (_button_step * _button_index);

		if (_mouse_x >= _button_x && _mouse_x <= _button_x + cultist_selection_button_width
			&& _mouse_y >= _button_y && _mouse_y <= _button_y + cultist_selection_button_height)
		{
			cultist_selected_demon_type = cultist_selection_buttons[_button_index];
		}
	}

	var _confirm_x = _panel_x + cultist_panel_width - 210;
	var _confirm_y = _panel_y + cultist_panel_height - 78;
	var _confirm_width = 150;
	var _confirm_height = 44;

	if (_mouse_x >= _confirm_x && _mouse_x <= _confirm_x + _confirm_width
		&& _mouse_y >= _confirm_y && _mouse_y <= _confirm_y + _confirm_height)
	{
		assign_current_cultist_demon();
	}
}

// Handle cultist level-up choice window.
if (global.focus_window == FOCUS_WINDOW.CULTIST_LEVEL_UP && mouse_check_button_pressed(mb_left))
{
	var _mouse_x = device_mouse_x_to_gui(0);
	var _mouse_y = device_mouse_y_to_gui(0);
	var _panel_x = (camera_view_width - cultist_panel_width) * 0.5;
	var _panel_y = (camera_view_height - 580) * 0.5;
	var _button_y = _panel_y + 470;
	var _button_width = 150;
	var _button_height = 44;
	var _button_gap = 18;
	var _button_start_x = _panel_x + 92;

	for (var _stat_index = 0; _stat_index < CULTIST_STAT.COUNT; ++_stat_index)
	{
		var _button_x = _button_start_x + ((_button_width + _button_gap) * _stat_index);

		if (_mouse_x >= _button_x && _mouse_x <= _button_x + _button_width
			&& _mouse_y >= _button_y && _mouse_y <= _button_y + _button_height)
		{
			add_cultist_level_point(_stat_index);
		}
	}
}

// Add a new projectile to the back of the queue when automatic gain is enabled.
if (!global.pause
	&& variable_global_exists("cannon_projectile_queue")
	&& global.cannon_projectile_gain_enabled
	&& !global.cannon_projectile_cheat_enabled)
{
	var _projectile_queue_count = array_length(global.cannon_projectile_queue);
	var _projectile_gain_interval = global.cannon_projectile_gain_time * room_speed;

	if (_projectile_queue_count < global.cannon_projectile_queue_max)
	{
		global.cannon_projectile_gain_timer++;

		if (global.cannon_projectile_gain_timer >= _projectile_gain_interval)
		{
			var _drop_type_count = array_length(global.cannon_projectile_drop_types);
			var _new_projectile_type = PROJECTILE_TYPE.DAMAGE;
			var _valid_drop_types = array_create(0);

			for (var _drop_type_index = 0; _drop_type_index < _drop_type_count; ++_drop_type_index)
			{
				var _drop_type = global.cannon_projectile_drop_types[_drop_type_index];
				var _can_drop_type = true;

				if (_drop_type == PROJECTILE_TYPE.RALLY)
				{
					_can_drop_type = false;

					if (instance_exists(o_cannon) && instance_exists(o_friendly_units))
					{
						var _cannon = instance_find(o_cannon, 0);
						var _friendly_unit = instance_nearest(_cannon.x, _cannon.y, o_friendly_units);

						if (instance_exists(_friendly_unit))
						{
							var _friendly_distance = point_distance(_cannon.x, _cannon.y, _friendly_unit.x, _friendly_unit.y);

							_can_drop_type = _friendly_distance <= BALANCE_PROJECTILE_RALLY_UNIT_SEARCH_RADIUS;
						}
					}
				}

				if (_can_drop_type)
				{
					array_push(_valid_drop_types, _drop_type);
				}
			}

			if (array_length(_valid_drop_types) > 0)
			{
				_new_projectile_type = _valid_drop_types[irandom(array_length(_valid_drop_types) - 1)];
			}

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
