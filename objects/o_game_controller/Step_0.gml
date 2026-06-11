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

// Space toggles gameplay pause without opening a blocking focus window.
if (keyboard_check_pressed(vk_space)
	&& global.focus_window == FOCUS_WINDOW.NOONE
	&& !pause_menu_open
	&& !instance_exists(global.dragged_cultist))
{
	player_pause_active = !player_pause_active;
	global.pause = player_pause_active;
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
		var _drag_world_x = _mouse_world_x;
		var _drop_world_y = _mouse_world_y + cultist_drag_drop_offset_y;
		var _assignment_world_y = _mouse_world_y;

		if (unit_is_blocked_by_cannon_wall(_dragged_cultist))
		{
			var _clamped_position = cannon_wall_position_clamp(_drag_world_x, _drop_world_y);

			_drag_world_x = _clamped_position[0];
			_drop_world_y = _clamped_position[1];
			_assignment_world_y = _drop_world_y;
		}

		_dragged_cultist.x = _drag_world_x;
		_dragged_cultist.y = _drop_world_y + cultist_drag_lift_offset_y - cultist_drag_drop_offset_y;
		_dragged_cultist.drag_drop_x = _drag_world_x;
		_dragged_cultist.drag_drop_y = _drop_world_y;

		global.cultist_assignment_preview_building = find_worker_building_at_position(_drag_world_x, _assignment_world_y);

		if (!mouse_check_button(mb_left))
		{
			var _drop_building = global.cultist_assignment_preview_building;
			var _was_assigned_to_building = assign_cultist_to_worker_building(_dragged_cultist, _drop_building);

			if (!_was_assigned_to_building)
			{
				_dragged_cultist.x = _dragged_cultist.drag_drop_x;
				_dragged_cultist.y = _dragged_cultist.drag_drop_y;
			}

			_dragged_cultist.is_being_dragged = false;
			global.sound_play_random(global.release_worker_sounds);

			if (_dragged_cultist.object_index != o_cultist
				&& variable_instance_exists(_dragged_cultist, "demon_type")
				&& _dragged_cultist.demon_type != DEMON_TYPE.NONE
				&& variable_instance_exists(_dragged_cultist, "stun_apply"))
			{
				_dragged_cultist.stun_apply(BALANCE_DEMON_DRAG_STUN_TIME);
			}

			global.dragged_cultist = noone;
			global.cultist_assignment_preview_building = noone;
		}
	}
	else if (mouse_check_button_pressed(mb_left))
	{
		var _cultist_count = array_length(global.cultists);
		var _closest_cultist = noone;
		var _closest_distance = infinity;

		for (var _cultist_index = 0; _cultist_index < _cultist_count; ++_cultist_index)
		{
			var _cultist = global.cultists[_cultist_index];

			if (instance_exists(_cultist)
				&& (!variable_instance_exists(_cultist, "hp") || _cultist.hp > 0)
				&& (!variable_instance_exists(_cultist, "cannon_loading") || !_cultist.cannon_loading)
				&& (!variable_instance_exists(_cultist, "cannon_loaded") || !_cultist.cannon_loaded)
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

		var _worker_unit_objects = [o_goblin];

		for (var _worker_object_index = 0; _worker_object_index < array_length(_worker_unit_objects); ++_worker_object_index)
		{
			var _worker_object = _worker_unit_objects[_worker_object_index];
			var _worker_unit_count = instance_number(_worker_object);

			for (var _worker_unit_index = 0; _worker_unit_index < _worker_unit_count; ++_worker_unit_index)
			{
				var _worker_unit = instance_find(_worker_object, _worker_unit_index);

				if (instance_exists(_worker_unit)
					&& _mouse_world_x >= _worker_unit.bbox_left
					&& _mouse_world_x <= _worker_unit.bbox_right
					&& _mouse_world_y >= _worker_unit.bbox_top
					&& _mouse_world_y <= _worker_unit.bbox_bottom)
				{
					var _distance_to_worker_unit = point_distance(_mouse_world_x, _mouse_world_y, _worker_unit.x, _worker_unit.y);

					if (_distance_to_worker_unit < _closest_distance)
					{
						_closest_distance = _distance_to_worker_unit;
						_closest_cultist = _worker_unit;
					}
				}
			}
		}

		if (instance_exists(_closest_cultist))
		{
			clear_cultist_building_assignment(_closest_cultist);

			global.dragged_cultist = _closest_cultist;
			_closest_cultist.is_being_dragged = true;
			_closest_cultist.x = _mouse_world_x;
			_closest_cultist.y = _mouse_world_y + cultist_drag_lift_offset_y;
			_closest_cultist.drag_drop_x = _mouse_world_x;
			_closest_cultist.drag_drop_y = _mouse_world_y + cultist_drag_drop_offset_y;
			global.sound_play_random(global.pick_worker_sounds);
		}
		else
		{
			var _building_slot = find_building_slot_at_position(_mouse_world_x, _mouse_world_y);

			if (instance_exists(_building_slot))
			{
				open_building_window(_building_slot);
			}
		}
	}
}
else if (instance_exists(global.dragged_cultist))
{
	global.dragged_cultist.x = global.dragged_cultist.drag_drop_x;
	global.dragged_cultist.y = global.dragged_cultist.drag_drop_y;
	global.dragged_cultist.is_being_dragged = false;
	global.sound_play_random(global.release_worker_sounds);

	if (global.dragged_cultist.object_index != o_cultist
		&& variable_instance_exists(global.dragged_cultist, "demon_type")
		&& global.dragged_cultist.demon_type != DEMON_TYPE.NONE
		&& variable_instance_exists(global.dragged_cultist, "stun_apply"))
	{
		global.dragged_cultist.stun_apply(BALANCE_DEMON_DRAG_STUN_TIME);
	}

	global.dragged_cultist = noone;
	global.cultist_assignment_preview_building = noone;
}
else
{
	global.cultist_assignment_preview_building = noone;
}

// Assigned cannon workers haul corpses during the day.
cannon_corpse_workers_update();

// Sort enabled world objects by their feet position: lower screen y draws above.
with (all)
{
	if (variable_instance_exists(id, "y_sort_enabled") && y_sort_enabled)
	{
		var _sort_y = y;

		if (variable_instance_exists(id, "is_being_dragged") && is_being_dragged)
		{
			_sort_y = drag_drop_y;
		}

		depth = -floor(_sort_y);
	}
}

// F4 manually starts a combat-form test while the full day/night cycle is disabled.
if (keyboard_check_pressed(vk_f4) && global.focus_window == FOCUS_WINDOW.NOONE && !instance_exists(global.dragged_cultist))
{
	transform_cultists_to_demons();
}

// F1 adds satiety for fast Feast projectile testing.
if (keyboard_check_pressed(vk_f1) && global.focus_window == FOCUS_WINDOW.NOONE && !instance_exists(global.dragged_cultist))
{
	cannon_satiety_add(BALANCE_CANNON_SATIETY_CHEAT_AMOUNT);
}

// F5 fills the cannon satiety meter for fast corpse-feed testing.
if (keyboard_check_pressed(vk_f5) && global.focus_window == FOCUS_WINDOW.NOONE && !instance_exists(global.dragged_cultist))
{
	global.cannon_satiety = global.cannon_satiety_max;
}

// Right mouse button spawns meat at the cursor for Brute Corpse Eater testing.
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

	instance_create_layer(_mouse_world_x, _mouse_world_y, "Instances", o_meat);
}

// NumPad keys spawn prototype units under the cursor for encounter testing.
var _debug_spawn_unit_object = noone;

if (keyboard_check_pressed(vk_numpad1))
{
	_debug_spawn_unit_object = o_enemy_peasant;
}
else if (keyboard_check_pressed(vk_numpad2))
{
	_debug_spawn_unit_object = o_enemy_knight;
}
else if (keyboard_check_pressed(vk_numpad3))
{
	_debug_spawn_unit_object = o_enemy_archer;
}
else if (keyboard_check_pressed(vk_numpad4))
{
	_debug_spawn_unit_object = o_enemy_mage;
}
else if (keyboard_check_pressed(vk_numpad8))
{
	_debug_spawn_unit_object = o_skeleton;
}
else if (keyboard_check_pressed(vk_numpad9))
{
	_debug_spawn_unit_object = o_pitling;
}

if (_debug_spawn_unit_object != noone
	&& global.focus_window == FOCUS_WINDOW.NOONE
	&& !global.pause
	&& instance_exists(o_camera_controller))
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

	instance_create_layer(_mouse_world_x, _mouse_world_y, "Instances", _debug_spawn_unit_object);
}

// Mouse button 5 damages the topmost HP-bearing instance under the cursor for debugging.
var _debug_damage_mouse_button = 5;

if (mouse_check_button_pressed(_debug_damage_mouse_button)
	&& global.focus_window == FOCUS_WINDOW.NOONE
	&& instance_exists(o_camera_controller))
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
	var _target_instance = noone;
	var _target_depth = infinity;
	var _instance_count = instance_number(all);

	for (var _instance_index = 0; _instance_index < _instance_count; ++_instance_index)
	{
		var _instance = instance_find(all, _instance_index);

		if (instance_exists(_instance)
			&& variable_instance_exists(_instance, "hp")
			&& _instance.hp > 0
			&& _mouse_world_x >= _instance.bbox_left
			&& _mouse_world_x <= _instance.bbox_right
			&& _mouse_world_y >= _instance.bbox_top
			&& _mouse_world_y <= _instance.bbox_bottom
			&& _instance.depth < _target_depth)
		{
			_target_instance = _instance;
			_target_depth = _instance.depth;
		}
	}

	if (instance_exists(_target_instance))
	{
		var _damage_amount = BALANCE_DEBUG_MOUSE_DAMAGE;
		var _target_faction = UNIT_FACTION.ENEMY;

		if (variable_instance_exists(_target_instance, "unit_faction"))
		{
			_target_faction = _target_instance.unit_faction;
		}

		if (variable_instance_exists(_target_instance, "unit_damage_receive"))
		{
			_target_instance.unit_damage_receive(_damage_amount, UNIT_FACTION.NOONE);
		}
		else
		{
			_target_instance.hp = max(_target_instance.hp - _damage_amount, 0);
			damage_popup_create(_target_instance.x, _target_instance.y, _damage_amount, _target_faction);
		}
	}
}

// Mouse button 4 gives night reward EXP to the topmost cultist or demon under the cursor.
var _debug_exp_mouse_button = 4;

if (mouse_check_button_pressed(_debug_exp_mouse_button)
	&& global.focus_window == FOCUS_WINDOW.NOONE
	&& instance_exists(o_camera_controller))
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
	var _target_instance = noone;
	var _target_depth = infinity;
	var _instance_count = instance_number(all);

	for (var _instance_index = 0; _instance_index < _instance_count; ++_instance_index)
	{
		var _instance = instance_find(all, _instance_index);

		if (instance_exists(_instance)
			&& variable_instance_exists(_instance, "current_exp")
			&& variable_instance_exists(_instance, "current_lvl")
			&& variable_instance_exists(_instance, "cultist_points")
			&& _mouse_world_x >= _instance.bbox_left
			&& _mouse_world_x <= _instance.bbox_right
			&& _mouse_world_y >= _instance.bbox_top
			&& _mouse_world_y <= _instance.bbox_bottom
			&& _instance.depth < _target_depth)
		{
			_target_instance = _instance;
			_target_depth = _instance.depth;
		}
	}

	if (instance_exists(_target_instance))
	{
		if (cultist_exp_add(_target_instance, BALANCE_CULTIST_NIGHT_EXP_REWARD))
		{
			open_cultist_levelup();
		}
	}
}

// F2 adds prototype resources for fast construction testing.
if (keyboard_check_pressed(vk_f2))
{
	global.resources[RESOURCES.FLESH] += BALANCE_DEBUG_RESOURCE_CHEAT_AMOUNT;
	global.resources[RESOURCES.SOULS] += BALANCE_DEBUG_RESOURCE_CHEAT_AMOUNT;
	global.resources[RESOURCES.IRON] += BALANCE_DEBUG_RESOURCE_CHEAT_AMOUNT;
}

// F8 skips the current day or night phase.
if (keyboard_check_pressed(vk_f8)
	&& global.day_cycle_enabled
	&& global.focus_window == FOCUS_WINDOW.NOONE)
{
	if (global.day_phase == DAY_PHASE.DAY)
	{
		start_night_phase();
	}
	else
	{
		debug_kill_all_enemies();
		start_day_phase();
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
	else if (global.focus_window == FOCUS_WINDOW.BUILDING_CONSTRUCTION)
	{
		close_building_window();
	}
	else if (global.focus_window == FOCUS_WINDOW.BUILDING_UPGRADE)
	{
		close_building_upgrade_window();
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
		player_pause_active = false;
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

// Play UI feedback for the currently hovered or clicked button.
ui_audio_update();

// Update the day timer and let night end only after the attack is cleared.
if (!global.pause && global.day_cycle_enabled)
{
	if (global.day_phase == DAY_PHASE.DAY)
	{
		global.day_timer--;

		if (global.day_timer <= 0)
		{
			start_night_phase();
		}
	}
	else if (global.day_phase == DAY_PHASE.NIGHT)
	{
		global.day_timer = max(global.day_timer - 1, 0);
	}
}

cannon_corrupted_ground_damage_update();

// Open building upgrade window from a hovered worker building.
if (keyboard_check_pressed(ord("G"))
	&& global.focus_window == FOCUS_WINDOW.NOONE
	&& !instance_exists(global.dragged_cultist)
	&& instance_exists(o_camera_controller))
{
	var _upgrade_camera_controller = instance_find(o_camera_controller, 0);
	var _upgrade_mouse_gui_x = device_mouse_x_to_gui(0);
	var _upgrade_mouse_gui_y = device_mouse_y_to_gui(0);
	var _upgrade_camera_x = camera_get_view_x(_upgrade_camera_controller.camera_id);
	var _upgrade_camera_y = camera_get_view_y(_upgrade_camera_controller.camera_id);
	var _upgrade_camera_width = camera_get_view_width(_upgrade_camera_controller.camera_id);
	var _upgrade_camera_height = camera_get_view_height(_upgrade_camera_controller.camera_id);
	var _upgrade_mouse_world_x = _upgrade_camera_x + ((_upgrade_mouse_gui_x / camera_view_width) * _upgrade_camera_width);
	var _upgrade_mouse_world_y = _upgrade_camera_y + ((_upgrade_mouse_gui_y / camera_view_height) * _upgrade_camera_height);
	var _upgrade_building = find_upgrade_building_at_position(_upgrade_mouse_world_x, _upgrade_mouse_world_y);

	open_building_upgrade_window(_upgrade_building);
}

// Handle construction menu tile clicks.
if (global.focus_window == FOCUS_WINDOW.BUILDING_CONSTRUCTION && mouse_check_button_pressed(mb_left))
{
	if (building_window_input_blocked)
	{
		building_window_input_blocked = false;
	}
	else
	{
		var _mouse_x = device_mouse_x_to_gui(0);
		var _mouse_y = device_mouse_y_to_gui(0);
		var _panel_x = (camera_view_width - building_window_width) * 0.5;
		var _panel_y = (camera_view_height - building_window_height) * 0.5;
		var _close_size = 34;
		var _close_x = _panel_x + building_window_width - _close_size - 14;
		var _close_y = _panel_y + 14;
		var _grid_x = _panel_x + 44;
		var _grid_y = _panel_y + 94;
		var _choice_count = array_length(building_choices);

		if (_mouse_x >= _close_x && _mouse_x <= _close_x + _close_size
			&& _mouse_y >= _close_y && _mouse_y <= _close_y + _close_size)
		{
			close_building_window();
		}
		else
		{
			for (var _choice_index = 0; _choice_index < _choice_count; ++_choice_index)
			{
				var _column = _choice_index mod building_tile_columns;
				var _row = _choice_index div building_tile_columns;
				var _tile_x = _grid_x + ((building_tile_width + building_tile_gap) * _column);
				var _tile_y = _grid_y + ((building_tile_height + building_tile_gap) * _row);

				if (_mouse_x >= _tile_x && _mouse_x <= _tile_x + building_tile_width
					&& _mouse_y >= _tile_y && _mouse_y <= _tile_y + building_tile_height)
				{
					construct_building_from_choice(building_choices[_choice_index]);
					break;
				}
			}
		}
	}
}

// Handle building upgrade window clicks.
if (global.focus_window == FOCUS_WINDOW.BUILDING_UPGRADE && mouse_check_button_pressed(mb_left))
{
	var _mouse_x = device_mouse_x_to_gui(0);
	var _mouse_y = device_mouse_y_to_gui(0);
	var _panel_x = (camera_view_width - building_upgrade_window_width) * 0.5;
	var _panel_y = (camera_view_height - building_upgrade_window_height) * 0.5;
	var _close_size = 34;
	var _close_x = _panel_x + building_upgrade_window_width - _close_size - 14;
	var _close_y = _panel_y + 14;
	var _tile_start_x = _panel_x + 38;
	var _tile_y = _panel_y + 104;

	if (_mouse_x >= _close_x && _mouse_x <= _close_x + _close_size
		&& _mouse_y >= _close_y && _mouse_y <= _close_y + _close_size)
	{
		close_building_upgrade_window();
	}
	else if (instance_exists(building_upgrade_window_building))
	{
		var _upgrade_count = 0;

		if (variable_instance_exists(building_upgrade_window_building, "building_upgrade_levels"))
		{
			_upgrade_count = array_length(building_upgrade_window_building.building_upgrade_levels);
		}
		else if (variable_instance_exists(building_upgrade_window_building, "building_upgrade_flags"))
		{
			_upgrade_count = array_length(building_upgrade_window_building.building_upgrade_flags);
		}

		for (var _upgrade_index = 0; _upgrade_index < _upgrade_count; ++_upgrade_index)
		{
			var _tile_x = _tile_start_x + ((building_upgrade_tile_width + building_upgrade_tile_gap) * _upgrade_index);

			if (_mouse_x >= _tile_x && _mouse_x <= _tile_x + building_upgrade_tile_width
				&& _mouse_y >= _tile_y && _mouse_y <= _tile_y + building_upgrade_tile_height)
			{
				building_upgrade_window_building.building_upgrade_buy(_upgrade_index);
				break;
			}
		}
	}
	else
	{
		close_building_upgrade_window();
	}
}

// Handle cultist demon selection window.
if (global.focus_window == FOCUS_WINDOW.CULTIST_DEMON_SELECTION && mouse_check_button_pressed(mb_left))
{
	var _mouse_x = device_mouse_x_to_gui(0);
	var _mouse_y = device_mouse_y_to_gui(0);
	var _design_width = 1024;
	var _design_height = 836;
	var _design_scale = min(camera_view_width / _design_width, camera_view_height / _design_height);
	var _panel_x = (camera_view_width - (_design_width * _design_scale)) * 0.5;
	var _panel_y = (camera_view_height - (_design_height * _design_scale)) * 0.5;
	var _button_start_x = _panel_x + (58 * _design_scale);
	var _button_y = _panel_y + (514 * _design_scale);
	var _button_step = cultist_selection_button_width + cultist_selection_button_gap;
	var _button_count = array_length(cultist_selection_buttons);

	for (var _button_index = 0; _button_index < _button_count; ++_button_index)
	{
		var _button_x = _button_start_x + ((_button_step * _button_index) * _design_scale);
		var _button_width = cultist_selection_button_width * _design_scale;
		var _button_height = cultist_selection_button_height * _design_scale;

		if (_mouse_x >= _button_x && _mouse_x <= _button_x + _button_width
			&& _mouse_y >= _button_y && _mouse_y <= _button_y + _button_height)
		{
			cultist_selected_demon_type = cultist_selection_buttons[_button_index];
			cultist_selected_starting_ability = cultist_starting_ability_default_get(cultist_selected_demon_type);
		}
	}

	var _ability_options = cultist_demon_active_abilities_get(cultist_selected_demon_type);
	var _ability_count = array_length(_ability_options);
	var _ability_button_x = _panel_x + (58 * _design_scale);
	var _ability_button_y = _panel_y + (650 * _design_scale);
	var _ability_button_width = cultist_ability_selection_button_width * _design_scale;
	var _ability_button_height = cultist_ability_selection_button_height * _design_scale;

	for (var _ability_index = 0; _ability_index < _ability_count; ++_ability_index)
	{
		var _current_ability_x = _ability_button_x
			+ (((cultist_ability_selection_button_width + cultist_ability_selection_button_gap) * _ability_index) * _design_scale);

		if (_mouse_x >= _current_ability_x && _mouse_x <= _current_ability_x + _ability_button_width
			&& _mouse_y >= _ability_button_y && _mouse_y <= _ability_button_y + _ability_button_height)
		{
			cultist_selected_starting_ability = _ability_options[_ability_index];
			break;
		}
	}

	var _confirm_x = _panel_x + (56 * _design_scale);
	var _confirm_y = _panel_y + (763 * _design_scale);
	var _confirm_width = 219 * _design_scale;
	var _confirm_height = 64 * _design_scale;

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
	var _panel_y = (camera_view_height - 660) * 0.5;
	var _button_y = _panel_y + 550;
	var _button_width = 150;
	var _button_height = 44;
	var _button_gap = 18;
	var _button_start_x = _panel_x + 92;
	var _cultist = noone;

	if (cultist_levelup_index >= 0 && cultist_levelup_index < array_length(global.cultists))
	{
		_cultist = global.cultists[cultist_levelup_index];
	}

	if (instance_exists(_cultist))
	{
		ensure_cultist_levelup_options(_cultist);
		var _reward_type = cultist_level_reward_type_get(_cultist);
		var _attribute_stat_order = [CULTIST_STAT.BODY, CULTIST_STAT.FERVOR, CULTIST_STAT.SPIRIT];
		var _button_count = array_length(_attribute_stat_order);

		if (_reward_type == CULTIST_LEVEL_REWARD.PASSIVE)
		{
			_button_count = array_length(_cultist.passive_choice_options);
		}
		else if (_reward_type == CULTIST_LEVEL_REWARD.ACTIVE)
		{
			_button_count = array_length(_cultist.active_choice_options);
		}
		else if (_reward_type == CULTIST_LEVEL_REWARD.ABILITY_UPGRADE)
		{
			_button_count = array_length(_cultist.ability_upgrade_choice_options);
		}

		for (var _choice_index = 0; _choice_index < _button_count; ++_choice_index)
		{
			var _button_x = _button_start_x + ((_button_width + _button_gap) * _choice_index);

			if (_mouse_x >= _button_x && _mouse_x <= _button_x + _button_width
				&& _mouse_y >= _button_y && _mouse_y <= _button_y + _button_height)
			{
				if (_reward_type == CULTIST_LEVEL_REWARD.ATTRIBUTE)
				{
					add_cultist_level_point(_attribute_stat_order[_choice_index]);
				}
				else if (_reward_type == CULTIST_LEVEL_REWARD.PASSIVE)
				{
					add_cultist_level_ability(_cultist.passive_choice_options[_choice_index]);
				}
				else if (_reward_type == CULTIST_LEVEL_REWARD.ACTIVE)
				{
					add_cultist_level_ability(_cultist.active_choice_options[_choice_index]);
				}
				else if (_reward_type == CULTIST_LEVEL_REWARD.ABILITY_UPGRADE)
				{
					add_cultist_level_ability(_cultist.ability_upgrade_choice_options[_choice_index]);
				}
			}
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
			array_push(global.cannon_projectile_payload_queue, noone);
			global.cannon_projectile_gain_timer = 0;
		}
	}
	else
	{
		global.cannon_projectile_gain_timer = 0;
	}
}

// Move night cultists into the cannon until they become queued projectiles.
update_cultists_loading_into_cannon();

// Release planned night attack waves while the night phase is active.
night_attack_spawning_update();

// Morning starts once every planned enemy has spawned and no enemies remain alive.
if (!global.pause
	&& global.day_cycle_enabled
	&& global.day_phase == DAY_PHASE.NIGHT
	&& night_attack_is_complete())
{
	start_day_phase();
}

// Cannon shots are only available during the night phase.
if (global.day_phase != DAY_PHASE.NIGHT && global.focus_window == FOCUS_WINDOW.TARGET_SELECTION)
{
	global.focus_window = FOCUS_WINDOW.NOONE;
}

var _can_select_cannon_projectile = global.day_phase == DAY_PHASE.NIGHT
	&& (global.focus_window == FOCUS_WINDOW.NOONE
		|| (global.cannon_projectile_cheat_enabled && global.focus_window == FOCUS_WINDOW.TARGET_SELECTION));

// Start or update target selection mode from hotkeys when a queued projectile is ready at night.
if (_can_select_cannon_projectile)
{
	var _projectile_queue_count = array_length(global.cannon_projectile_queue);
	var _feast_projectile_count = floor(max(0, global.cannon_satiety) / max(1, global.cannon_satiety_max));
	var _selectable_projectile_count = _projectile_queue_count + _feast_projectile_count;

	if (global.cannon_projectile_cheat_enabled)
	{
		var _selected_projectile_index = -1;
		var _max_digit_count = min(_selectable_projectile_count, 9);

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
			var _selected_projectile_type = PROJECTILE_TYPE.FEAST;
			var _selected_projectile_payload = noone;

			if (_selected_projectile_index < _projectile_queue_count)
			{
				_selected_projectile_type = global.cannon_projectile_queue[_selected_projectile_index];

				if (_selected_projectile_index < array_length(global.cannon_projectile_payload_queue))
				{
					_selected_projectile_payload = global.cannon_projectile_payload_queue[_selected_projectile_index];
				}

				for (var _queue_index = _selected_projectile_index; _queue_index > 0; --_queue_index)
				{
					global.cannon_projectile_queue[_queue_index] = global.cannon_projectile_queue[_queue_index - 1];

					if (_queue_index < array_length(global.cannon_projectile_payload_queue))
					{
						global.cannon_projectile_payload_queue[_queue_index] = global.cannon_projectile_payload_queue[_queue_index - 1];
					}
				}

				global.cannon_projectile_queue[0] = _selected_projectile_type;
				global.cannon_projectile_payload_queue[0] = _selected_projectile_payload;
			}

			target_selection_projectile_type = _selected_projectile_type;
			target_selection_radius = projectile_target_selection_radius_get(_selected_projectile_type);
			global.focus_window = FOCUS_WINDOW.TARGET_SELECTION;
		}
	}
	else
	{
		var _normal_selected_projectile_index = -1;
		var _normal_max_digit_count = min(_selectable_projectile_count, 9);

		for (var _normal_digit_index = 0; _normal_digit_index < _normal_max_digit_count; ++_normal_digit_index)
		{
			if (keyboard_check_pressed(ord(string(_normal_digit_index + 1))))
			{
				_normal_selected_projectile_index = _normal_digit_index;
				break;
			}
		}

		if (_normal_selected_projectile_index >= 0)
		{
			var _normal_selected_projectile_type = PROJECTILE_TYPE.FEAST;
			var _normal_selected_projectile_payload = noone;

			if (_normal_selected_projectile_index < _projectile_queue_count)
			{
				_normal_selected_projectile_type = global.cannon_projectile_queue[_normal_selected_projectile_index];

				if (_normal_selected_projectile_index < array_length(global.cannon_projectile_payload_queue))
				{
					_normal_selected_projectile_payload = global.cannon_projectile_payload_queue[_normal_selected_projectile_index];
				}

				for (var _normal_queue_index = _normal_selected_projectile_index; _normal_queue_index > 0; --_normal_queue_index)
				{
					global.cannon_projectile_queue[_normal_queue_index] = global.cannon_projectile_queue[_normal_queue_index - 1];

					if (_normal_queue_index < array_length(global.cannon_projectile_payload_queue))
					{
						global.cannon_projectile_payload_queue[_normal_queue_index] = global.cannon_projectile_payload_queue[_normal_queue_index - 1];
					}
				}

				global.cannon_projectile_queue[0] = _normal_selected_projectile_type;
				global.cannon_projectile_payload_queue[0] = _normal_selected_projectile_payload;
			}

			target_selection_projectile_type = _normal_selected_projectile_type;
			target_selection_radius = projectile_target_selection_radius_get(_normal_selected_projectile_type);
			global.focus_window = FOCUS_WINDOW.TARGET_SELECTION;
		}
	}
}

// Confirm target selection with left mouse button.
if (global.focus_window == FOCUS_WINDOW.TARGET_SELECTION && mouse_check_button_pressed(mb_left))
{
	if (global.day_phase != DAY_PHASE.NIGHT)
	{
		global.focus_window = FOCUS_WINDOW.NOONE;
	}
	else if (array_length(global.cannon_projectile_queue) <= 0
		&& target_selection_projectile_type != PROJECTILE_TYPE.FEAST)
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
		var _target_world_x = _camera_x + ((_mouse_x / camera_view_width) * _view_width);
		var _target_world_y = _camera_y + ((_mouse_y / camera_view_height) * _view_height);

		if (target_selection_projectile_type != PROJECTILE_TYPE.FEAST)
		{
			target_selection_projectile_type = global.cannon_projectile_queue[0];
		}

		target_selection_radius = projectile_target_selection_radius_get(target_selection_projectile_type);
		var _target_can_be_confirmed = true;
		var _target_consumes_projectile_queue = target_selection_projectile_type != PROJECTILE_TYPE.FEAST;

		if (target_selection_projectile_type == PROJECTILE_TYPE.CULTIST
			&& !world_position_is_revealed_by_fog(_target_world_x, _target_world_y))
		{
			_target_can_be_confirmed = false;
		}
		else if (target_selection_projectile_type == PROJECTILE_TYPE.FEAST
			&& !feast_target_touches_corruption(_target_world_x, _target_world_y))
		{
			_target_can_be_confirmed = false;
		}

		if (_target_can_be_confirmed)
		{
			if (target_selection_projectile_type == PROJECTILE_TYPE.FEAST)
			{
				if (!cannon_satiety_spend_feast())
				{
					_target_can_be_confirmed = false;
				}
			}
		}

		if (_target_can_be_confirmed)
		{
			global.cannon_target_exists = true;
			global.cannon_target_x = _target_world_x;
			global.cannon_target_y = _target_world_y;
			global.cannon_target_projectile_type = target_selection_projectile_type;
			global.cannon_target_consumes_projectile_queue = _target_consumes_projectile_queue;
			global.cannon_target_version++;
			global.focus_window = FOCUS_WINDOW.NOONE;
		}
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
				player_pause_active = false;
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
		var _close_button_x = _panel_x + ((settings_panel_width - button_width) * 0.5);
		var _close_button_y = _panel_y + settings_panel_height - button_height - settings_close_bottom_padding;

		if (_mouse_x >= _close_button_x && _mouse_x <= _close_button_x + button_width && _mouse_y >= _close_button_y && _mouse_y <= _close_button_y + button_height)
		{
			settings_open = false;
			global.focus_window = FOCUS_WINDOW.PAUSE_MENU;
		}
	}
}
