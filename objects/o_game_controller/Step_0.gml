// Keep game surfaces aligned before any tutorial popup can block gameplay input.
resources_clamp_to_max();

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

// Faction selection owns input until the selecting mouse button is released.
if (faction_selection_active)
{
	faction_selection_update();
	exit;
}
if (faction_selection_release_pending)
{
	if (!mouse_check_button(mb_left))
	{
		faction_selection_release_pending = false;
		global.focus_window = FOCUS_WINDOW.NOONE;
		global.pause = false;
	}
	exit;
}

// Base defeats are permanent; gameplay stops only after the match has a result.
faction_match_update();
faction_favor_update();
if (faction_match_finished)
{
	if (keyboard_check_pressed(vk_enter)) room_restart();
	exit;
}

faction_mana_update();
faction_heroes_update();
faction_summon_ai_update();
if (!global.pause)
{
	var _ai_squad_count = array_length(global.squads);
	for (var _ai_index = 0; _ai_index < _ai_squad_count; ++_ai_index)
	{
		squad_ai_update(global.squads[_ai_index]);
	}
}

// F3 toggles fog visibility for fast map testing.
if (global.cheats_enabled && keyboard_check_pressed(vk_f3))
{
	global.fog_of_war_visible = !global.fog_of_war_visible;
}

// F5 toggles the visible portion of the shared wall navigation grid.
if (global.cheats_enabled && keyboard_check_pressed(vk_f5))
{
	wall_navigation_debug_visible = !wall_navigation_debug_visible;
}

// F12 restarts the current room for fast prototype iteration.
if (global.cheats_enabled && keyboard_check_pressed(vk_f12))
{
	room_restart();
	exit;
}

// Backtick toggles the in-game debug menu.
if (global.cheats_enabled
	&& (keyboard_check_pressed(ord("`")) || keyboard_check_pressed(192)))
{
	debug_menu_open = !debug_menu_open;
}

var _debug_left_mouse_pressed = mouse_check_button_pressed(mb_left);
var _debug_right_mouse_pressed = mouse_check_button_pressed(mb_right);

if (global.cheats_enabled
	&& debug_menu_open
	&& (_debug_left_mouse_pressed || _debug_right_mouse_pressed))
{
	var _debug_mouse_x = device_mouse_x_to_gui(0);
	var _debug_mouse_y = device_mouse_y_to_gui(0);
	var _debug_menu_height = debug_menu_height_get();
	var _debug_menu_contains_mouse = _debug_mouse_x >= debug_menu_x
		&& _debug_mouse_x <= debug_menu_x + debug_menu_width
		&& _debug_mouse_y >= debug_menu_y
		&& _debug_mouse_y <= debug_menu_y + _debug_menu_height;

	if (_debug_menu_contains_mouse)
	{
		var _debug_tab_count = array_length(debug_menu_tab_ids);
		var _debug_tab_was_clicked = false;

		for (var _debug_tab_index = 0; _debug_left_mouse_pressed && _debug_tab_index < _debug_tab_count; ++_debug_tab_index)
		{
			var _debug_tab_rect = debug_menu_tab_rect_get(_debug_tab_index);

			if (_debug_mouse_x >= _debug_tab_rect.x
				&& _debug_mouse_x <= _debug_tab_rect.x + _debug_tab_rect.width
				&& _debug_mouse_y >= _debug_tab_rect.y
				&& _debug_mouse_y <= _debug_tab_rect.y + _debug_tab_rect.height)
			{
				debug_menu_tab = debug_menu_tab_ids[_debug_tab_index];
				_debug_tab_was_clicked = true;
				break;
			}
		}

		if (_debug_tab_was_clicked)
		{
			exit;
		}

		var _debug_choices = debug_menu_choices_get();
		var _debug_choice_count = array_length(_debug_choices);

		for (var _debug_choice_index = 0; _debug_choice_index < _debug_choice_count; ++_debug_choice_index)
		{
			var _debug_rect = debug_shell_choice_rect_get(_debug_choice_index);

			if (_debug_mouse_x >= _debug_rect.x
				&& _debug_mouse_x <= _debug_rect.x + _debug_rect.width
				&& _debug_mouse_y >= _debug_rect.y
				&& _debug_mouse_y <= _debug_rect.y + _debug_rect.height)
			{
				if (_debug_right_mouse_pressed && debug_menu_tab != "units")
				{
					break;
				}

				var _debug_spawn_count = _debug_right_mouse_pressed
					? BALANCE_DEBUG_UNIT_GROUP_SPAWN_COUNT
					: 1;
				debug_menu_choice_activate(_debug_choices[_debug_choice_index], _debug_spawn_count);
				break;
			}
		}

		exit;
	}
}

// Space toggles gameplay pause without opening a blocking focus window.
if (keyboard_check_pressed(vk_space)
	&& (global.focus_window == FOCUS_WINDOW.NOONE
		|| global.focus_window == FOCUS_WINDOW.TARGET_SELECTION
		|| global.focus_window == FOCUS_WINDOW.SUMMON)
	&& !pause_menu_open
	&& !instance_exists(global.dragged_cultist)
	&& !instance_exists(global.dragged_artifact))
{
	player_pause_active = !player_pause_active;
	global.pause = player_pause_active;
}

// Keep combat and squad controls active throughout the match.
if (!global.pause)
{
	player_building_ground_state_update();
	squad_destroyed_remove();
}
if (faction_summon_input_update())
{
	squad_night_markers_update();
	exit;
}
var _squad_selection_escape_consumed = squad_control_selection_update();
squad_combat_guides_update();
squad_night_markers_update();

// Allow the player to pick up and reposition cultists during gameplay.
if (global.focus_window == FOCUS_WINDOW.NOONE && variable_global_exists("archdemons") && instance_exists(o_camera_controller))
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
	var _squad_roster_card_clicked = false;
	var _cultist_status_card_clicked = false;
	var _minimap_camera_clicked = false;
	var _artifact_clicked = false;
	var _squad_marker_input_handled = false;

	// Clicking a roster card centers the camera on the squad's surviving members.
	if (!instance_exists(global.dragged_cultist)
		&& !instance_exists(global.dragged_artifact)
		&& !is_struct(global.dragged_squad)
		&& mouse_check_button_pressed(mb_left)
		&& instance_exists(o_hud))
	{
		var _squad_hud = instance_find(o_hud, 0);

		if (variable_instance_exists(_squad_hud, "hud_squad_at_gui_position"))
		{
			var _roster_squad = _squad_hud.hud_squad_at_gui_position(_mouse_gui_x, _mouse_gui_y);

			if (is_struct(_roster_squad) && squad_marker_position_update(_roster_squad))
			{
				if (variable_instance_exists(_camera_controller, "camera_center_on_position"))
				{
					_camera_controller.camera_center_on_position(
						_roster_squad.properties.marker_x,
						_roster_squad.properties.marker_y
					);
				}
				else
				{
					_camera_controller.x = _roster_squad.properties.marker_x;
					_camera_controller.y = _roster_squad.properties.marker_y;
					_camera_controller.velocity_x = 0;
					_camera_controller.velocity_y = 0;
				}

				_squad_roster_card_clicked = true;
			}
		}
	}

	// Night flag input uses either click-selection orders or drag-and-release orders.
	if (!global.pause)
	{
		if (squad_flag_system_2_enabled)
		{
			_squad_marker_input_handled = squad_control_world_input_update(
				_mouse_world_x, _mouse_world_y, _mouse_gui_x, _mouse_gui_y);
		}
		else if (is_struct(global.dragged_squad))
		{
			var _squad_drag_button = variable_struct_exists(
				global.dragged_squad.properties,
				"marker_drag_button"
			)
				? global.dragged_squad.properties.marker_drag_button
				: mb_left;
			var _squad_marker_world_offset_y = BALANCE_SQUAD_MARKER_DRAG_TARGET_OFFSET_Y
				* (_camera_height / max(1, camera_view_height));
			squad_drag_update(
				global.dragged_squad,
				_mouse_world_x,
				_mouse_world_y + _squad_marker_world_offset_y
			);
			_squad_marker_input_handled = true;

			if (!mouse_check_button(_squad_drag_button))
			{
				squad_drag_end(global.dragged_squad, true);
				global.sound_play_random(global.release_worker_sounds);
			}
		}
		else if (!_squad_roster_card_clicked
			&& (mouse_check_button_pressed(mb_left) || mouse_check_button_pressed(mb_right)))
		{
			var _picked_squad = squad_marker_find_at_position(_mouse_world_x, _mouse_world_y);
			var _squad_drag_button = mouse_check_button_pressed(mb_right) ? mb_right : mb_left;
			var _squad_drag_order_mode = _squad_drag_button == mb_right
				? SQUAD_ORDER.MOVE_AND_ATTACK
				: SQUAD_ORDER.MOVE;

			if (is_struct(_picked_squad)
				&& squad_drag_begin(_picked_squad, _squad_drag_button, _squad_drag_order_mode))
			{
				_squad_marker_input_handled = true;
				global.sound_play_random(global.pick_worker_sounds);
			}
		}
	}

	if (!_squad_roster_card_clicked
		&& !_squad_marker_input_handled
		&& mouse_check_button_pressed(mb_left)
		&& instance_exists(o_artifact))
	{
		var _artifact_count = instance_number(o_artifact);

		for (var _artifact_index = 0; _artifact_index < _artifact_count; ++_artifact_index)
		{
			var _artifact = instance_find(o_artifact, _artifact_index);

			if (!instance_exists(_artifact))
			{
				continue;
			}

			var _artifact_pickup_radius = 0;

			if (variable_instance_exists(_artifact, "artifact_pickup_radius"))
			{
				_artifact_pickup_radius = _artifact.artifact_pickup_radius;
			}

			if (instance_exists(_artifact)
				&& ((_mouse_world_x >= _artifact.bbox_left
						&& _mouse_world_x <= _artifact.bbox_right
						&& _mouse_world_y >= _artifact.bbox_top
						&& _mouse_world_y <= _artifact.bbox_bottom)
					|| point_distance(_mouse_world_x, _mouse_world_y, _artifact.x, _artifact.y) <= _artifact_pickup_radius))
			{
				_artifact_clicked = true;
				break;
			}
		}
	}

	if (!instance_exists(global.dragged_cultist)
		&& !instance_exists(global.dragged_artifact)
		&& !is_struct(global.dragged_squad)
		&& !_squad_roster_card_clicked
		&& mouse_check_button_pressed(mb_left)
		&& instance_exists(o_hud))
	{
		var _hud = instance_find(o_hud, 0);

		if (variable_instance_exists(_hud, "cultist_status_card_find_at_gui"))
		{
			var _status_card_cultist = _hud.cultist_status_card_find_at_gui(_mouse_gui_x, _mouse_gui_y);

			if (instance_exists(_status_card_cultist))
			{
				if (variable_instance_exists(_camera_controller, "camera_center_on_instance"))
				{
					_camera_controller.camera_center_on_instance(_status_card_cultist);
				}
				else
				{
					_camera_controller.x = _status_card_cultist.x;
					_camera_controller.y = _status_card_cultist.y;
					_camera_controller.velocity_x = 0;
					_camera_controller.velocity_y = 0;
				}

				_cultist_status_card_clicked = true;
			}
		}
	}

	if (!instance_exists(global.dragged_cultist)
		&& !instance_exists(global.dragged_artifact)
		&& !is_struct(global.dragged_squad)
		&& !_squad_roster_card_clicked
		&& mouse_check_button(mb_left)
		&& instance_exists(o_hud))
	{
		var _minimap_hud = instance_find(o_hud, 0);

		if (variable_instance_exists(_minimap_hud, "minimap_world_position_from_gui"))
		{
			var _minimap_position = _minimap_hud.minimap_world_position_from_gui(_mouse_gui_x, _mouse_gui_y);

			if (_minimap_position[0])
			{
				if (variable_instance_exists(_camera_controller, "camera_center_on_position"))
				{
					_camera_controller.camera_center_on_position(_minimap_position[1], _minimap_position[2]);
				}
				else
				{
					_camera_controller.x = _minimap_position[1];
					_camera_controller.y = _minimap_position[2];
					_camera_controller.velocity_x = 0;
					_camera_controller.velocity_y = 0;
				}

				_minimap_camera_clicked = true;
			}
		}
	}

}

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

if (global.cheats_enabled)
{
	// Shift + right mouse button spawns meat at the cursor for Brute Corpse Eater testing.
	if (keyboard_check(vk_shift)
		&& mouse_check_button_pressed(mb_right)
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

		instance_create_layer(_mouse_world_x, _mouse_world_y, "Instances", o_meat);
	}

	// Shift + NumPad 1-7 creates a Bone Warrior squad with the selected Unholy Trait.
	var _debug_shift_is_held = keyboard_check(vk_shift);
	var _debug_unholy_trait = UNHOLY_TRAIT.NONE;

	if (_debug_shift_is_held)
	{
		var _debug_number_1_pressed = keyboard_check_pressed(ord("1"))
			|| keyboard_check_pressed(vk_numpad1)
			|| keyboard_check_pressed(vk_end);
		var _debug_number_2_pressed = keyboard_check_pressed(ord("2"))
			|| keyboard_check_pressed(vk_numpad2)
			|| keyboard_check_pressed(vk_down);
		var _debug_number_3_pressed = keyboard_check_pressed(ord("3"))
			|| keyboard_check_pressed(vk_numpad3)
			|| keyboard_check_pressed(vk_pagedown);
		var _debug_number_4_pressed = keyboard_check_pressed(ord("4"))
			|| keyboard_check_pressed(vk_numpad4)
			|| keyboard_check_pressed(vk_left);
		var _debug_number_5_pressed = keyboard_check_pressed(ord("5"))
			|| keyboard_check_pressed(vk_numpad5)
			|| keyboard_check_pressed(KEY_CODE_NUMPAD_CENTER);
		var _debug_number_6_pressed = keyboard_check_pressed(ord("6"))
			|| keyboard_check_pressed(vk_numpad6)
			|| keyboard_check_pressed(vk_right);
		var _debug_number_7_pressed = keyboard_check_pressed(ord("7"))
			|| keyboard_check_pressed(vk_numpad7)
			|| keyboard_check_pressed(vk_home);

		if (_debug_number_1_pressed)
		{
			_debug_unholy_trait = UNHOLY_TRAIT.BOILING_BLOOD;
		}
		else if (_debug_number_2_pressed)
		{
			_debug_unholy_trait = UNHOLY_TRAIT.STUNNING_ARRIVAL;
		}
		else if (_debug_number_3_pressed)
		{
			_debug_unholy_trait = UNHOLY_TRAIT.SAVAGE_LEAP;
		}
		else if (_debug_number_4_pressed)
		{
			_debug_unholy_trait = UNHOLY_TRAIT.ENDLESS_PROCESSION;
		}
		else if (_debug_number_5_pressed)
		{
			_debug_unholy_trait = UNHOLY_TRAIT.TAINT_TREATMENT;
		}
		else if (_debug_number_6_pressed)
		{
			_debug_unholy_trait = UNHOLY_TRAIT.ROAR_OF_THE_ABYSS;
		}
		else if (_debug_number_7_pressed)
		{
			_debug_unholy_trait = UNHOLY_TRAIT.POWER_OF_TWILIGHT;
		}
	}

	if (_debug_unholy_trait != UNHOLY_TRAIT.NONE)
	{
		debug_unholy_bone_warrior_squad_create(_debug_unholy_trait);
	}

	// Unmodified NumPad keys spawn prototype units under the cursor for encounter testing.
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
	else if (keyboard_check_pressed(vk_numpad5))
	{
		_debug_spawn_unit_object = o_enemy_catapult;
	}
	else if (keyboard_check_pressed(vk_numpad6))
	{
		_debug_spawn_unit_object = o_crusader;
	}
	else if (keyboard_check_pressed(vk_numpad7))
	{
		_debug_spawn_unit_object = o_provocateur;
	}
	else if (keyboard_check_pressed(vk_numpad8))
	{
		_debug_spawn_unit_object = o_ripcage_cannon;
	}
	else if (keyboard_check_pressed(vk_numpad9))
	{
		_debug_spawn_unit_object = o_bone_bannerman;
	}

	if (_debug_spawn_unit_object != noone
		&& !_debug_shift_is_held
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

			if (_target_instance.object_index == o_holy_tower)
			{
				_damage_amount = max(1, _target_instance.max_hp * 0.5);
			}
			else if (_target_instance.object_index == o_house)
			{
				_damage_amount = max(1, _target_instance.max_hp * 0.34);
			}

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
				ensure_cultist_levelup_options(_target_instance);
			}
		}
	}

	// F7 adds prototype resources for fast construction testing.
	if (keyboard_check_pressed(vk_f7))
	{
		resource_add(RESOURCES.FLESH, BALANCE_DEBUG_RESOURCE_CHEAT_AMOUNT);
		resource_add(RESOURCES.SOULS, BALANCE_DEBUG_RESOURCE_CHEAT_AMOUNT);
		resource_add(RESOURCES.IRON, BALANCE_DEBUG_RESOURCE_CHEAT_AMOUNT);
		resource_add(RESOURCES.IHOR, BALANCE_DEBUG_RESOURCE_CHEAT_AMOUNT);
	}

}

// Resolve Escape by the current focused window.
if (keyboard_check_pressed(vk_escape) && !_squad_selection_escape_consumed)
{
	if (global.focus_window == FOCUS_WINDOW.TARGET_SELECTION)
	{
		hellcow_aim_is_dragging = false;
		hellcow_aim_drag_distance = 0;
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
	else if (global.focus_window == FOCUS_WINDOW.BUILDING_EVENTS)
	{
		close_building_events_window();
	}
	else if (global.focus_window == FOCUS_WINDOW.CANNON_SATISFACTION)
	{
		close_cannon_satisfaction_window();
	}
	else if (global.focus_window == FOCUS_WINDOW.CURSED_POINT_STRUCTURE_SELECTION)
	{
		if (variable_global_exists("cursed_point_structure_selection_source")
			&& instance_exists(global.cursed_point_structure_selection_source))
		{
			global.cursed_point_structure_selection_source.cursed_point_structure_selection_close();
		}
		else
		{
			global.focus_window = FOCUS_WINDOW.NOONE;
			global.pause = false;
		}
	}
	else if (global.focus_window == FOCUS_WINDOW.SQUAD_POINT_SELECTION)
	{
		if (variable_global_exists("squad_point_selection_source")
			&& instance_exists(global.squad_point_selection_source)
			&& variable_instance_exists(global.squad_point_selection_source, "squad_point_selection_close"))
		{
			global.squad_point_selection_source.squad_point_selection_close();
		}
		else
		{
			global.focus_window = FOCUS_WINDOW.NOONE;
			global.pause = false;
		}
	}
	else if (global.focus_window == FOCUS_WINDOW.JOBS)
	{
		if (instance_exists(o_jobs_ui))
		{
			var _jobs_ui = instance_find(o_jobs_ui, 0);
			_jobs_ui.jobs_window_close();
		}
	}
	else if (global.focus_window == FOCUS_WINDOW.END_DAY_CONFIRMATION)
	{
		if (instance_exists(o_jobs_ui))
		{
			var _jobs_ui = instance_find(o_jobs_ui, 0);
			_jobs_ui.jobs_end_day_confirmation_close();
		}
	}
	else if (global.focus_window == FOCUS_WINDOW.WORLD_EVENT_SQUAD_SELECTION)
	{
		world_event_squad_selector_close();
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

ui_audio_update();

// Handle pause menu buttons and settings sliders.
if (pause_menu_open && (mouse_check_button_pressed(mb_left) || settings_open))
{
	var _mouse_x = device_mouse_x_to_gui(0);
	var _mouse_y = device_mouse_y_to_gui(0);

	if (!settings_open && mouse_check_button_pressed(mb_left))
	{
		for (var _pause_button_index = 0; _pause_button_index < pause_button_count; ++_pause_button_index)
		{
			var _pause_button_x = pause_button_x_get(_pause_button_index);
			var _pause_button_y = pause_button_y_get(_pause_button_index);
			var _pause_button_width = pause_button_width_get(_pause_button_index);
			var _pause_button_height = pause_button_height_get(_pause_button_index);

			if (!ui_mouse_is_inside_rect(_mouse_x, _mouse_y, _pause_button_x, _pause_button_y, _pause_button_width, _pause_button_height))
			{
				continue;
			}

			if (_pause_button_index == continue_button_index)
			{
				pause_menu_open = false;
				global.pause = false;
				player_pause_active = false;
				global.focus_window = FOCUS_WINDOW.NOONE;
			}
			else if (_pause_button_index == settings_button_index)
			{
				settings_open = true;
				global.focus_window = FOCUS_WINDOW.SETTINGS;
			}
			else if (_pause_button_index == feedback_button_index)
			{
				url_open(pause_feedback_url);
			}
			else if (_pause_button_index == quit_button_index)
			{
				game_end();
			}

			break;
		}
	}
	else
	{
		var _panel_x = (camera_view_width - settings_panel_width) * 0.5;
		var _panel_y = (camera_view_height - settings_panel_height) * 0.5;
		var _close_button_x = _panel_x + ((settings_panel_width - button_width) * 0.5);
		var _close_button_y = _panel_y + settings_panel_height - button_height - settings_close_bottom_padding;
		var _edge_toggle_rect = settings_edge_toggle_rect_get();
		var _flag_system_rect = settings_flag_system_rect_get();
		var _settings_slider_index = settings_slider_find_at_gui(_mouse_x, _mouse_y);

		if (mouse_check_button_pressed(mb_left)
			&& ui_mouse_is_inside_rect(_mouse_x, _mouse_y, _edge_toggle_rect.x, _edge_toggle_rect.y, _edge_toggle_rect.width, _edge_toggle_rect.height))
		{
			global.edge_scroll_enabled = !global.edge_scroll_enabled;
			settings_drag_slider_index = -1;
		}
		else if (SQUAD_FLAG_SYSTEM_SETTING_VISIBLE && mouse_check_button_pressed(mb_left)
			&& ui_mouse_is_inside_rect(_mouse_x, _mouse_y, _flag_system_rect.x, _flag_system_rect.y,
				_flag_system_rect.width, _flag_system_rect.height))
		{
			squad_flag_system_set(!squad_flag_system_2_enabled);
			settings_drag_slider_index = -1;
		}
		else if (mouse_check_button_pressed(mb_left) && _settings_slider_index >= 0)
		{
			settings_drag_slider_index = _settings_slider_index;
			settings_slider_value_set(
				settings_drag_slider_index,
				settings_slider_value_from_gui(settings_drag_slider_index, _mouse_x)
			);
		}
		else if (settings_drag_slider_index >= 0 && mouse_check_button(mb_left))
		{
			settings_slider_value_set(
				settings_drag_slider_index,
				settings_slider_value_from_gui(settings_drag_slider_index, _mouse_x)
			);
		}
		else if (!mouse_check_button(mb_left))
		{
			settings_drag_slider_index = -1;
		}

		if (settings_drag_slider_index < 0
			&& mouse_check_button_pressed(mb_left)
			&& _mouse_x >= _close_button_x
			&& _mouse_x <= _close_button_x + button_width
			&& _mouse_y >= _close_button_y
			&& _mouse_y <= _close_button_y + button_height)
		{
			settings_open = false;
			global.focus_window = FOCUS_WINDOW.PAUSE_MENU;
		}
	}
}
