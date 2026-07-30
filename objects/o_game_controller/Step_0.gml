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

// Phase banner fades out independently from gameplay pause.
if (phase_banner_timer > 0)
{
	phase_banner_timer--;
}

// Night effect layers come online over a few seconds after night starts.
if (night_effect_transition_active)
{
	night_effect_transition_timer++;

	var _night_effect_progress = night_effect_transition_timer / max(1, night_effect_transition_duration);
	night_effect_layers_set_progress(_night_effect_progress);

	if (_night_effect_progress >= 1)
	{
		night_effect_transition_active = false;
		night_effect_layers_set_progress(1);
	}
}

// Blood Moon rewards block lower input until the player acknowledges the arrivals.
if (global.blood_moon_reward_popup_active)
{
	var _popup_x = (display_get_gui_width() - blood_moon_reward_popup_width) * 0.5;
	var _popup_y = (display_get_gui_height() - blood_moon_reward_popup_height) * 0.5;
	var _button_x = _popup_x + ((blood_moon_reward_popup_width - blood_moon_reward_button_width) * 0.5);
	var _button_y = _popup_y + blood_moon_reward_popup_height - blood_moon_reward_button_height - 24;
	var _mouse_x = device_mouse_x_to_gui(0);
	var _mouse_y = device_mouse_y_to_gui(0);
	var _button_hovered_now = ui_mouse_is_inside_rect(
		_mouse_x,
		_mouse_y,
		_button_x,
		_button_y,
		blood_moon_reward_button_width,
		blood_moon_reward_button_height
	);

	if (_button_hovered_now
		&& !blood_moon_reward_button_hovered
		&& variable_global_exists("sound_play_random")
		&& variable_global_exists("ui_hover_sounds"))
	{
		global.sound_play_random(global.ui_hover_sounds, global.sound_priority_ui);
	}

	blood_moon_reward_button_hovered = _button_hovered_now;

	// Ignore the input that caused the morning transition until it is released.
	if (blood_moon_reward_input_blocked)
	{
		if (!mouse_check_button(mb_left)
			&& !keyboard_check(vk_enter)
			&& !keyboard_check(vk_space))
		{
			blood_moon_reward_input_blocked = false;
		}
	}
	else if ((_button_hovered_now && mouse_check_button_pressed(mb_left))
		|| keyboard_check_pressed(vk_enter)
		|| keyboard_check_pressed(vk_space))
	{
		if (variable_global_exists("ui_confirm_sound_play"))
		{
			global.ui_confirm_sound_play();
		}

		blood_moon_reward_popup_close();
	}

	exit;
}

// Keep the modal focus until the acknowledgement input is released.
if (blood_moon_reward_focus_restore_pending)
{
	if (mouse_check_button(mb_left)
		|| keyboard_check(vk_enter)
		|| keyboard_check(vk_space))
	{
		exit;
	}

	blood_moon_reward_modal_state_restore();
}

// Tutorial popups block every lower gameplay and UI input.
if (variable_global_exists("tutorial_popup_active") && global.tutorial_popup_active)
{
	exit;
}

// Q toggles quadruple simulation speed while the night is active.
if (!global.pause
	&& global.day_phase == DAY_PHASE.NIGHT
	&& keyboard_check_pressed(ord("Q")))
{
	night_fast_forward_set(!night_fast_forward_active);
}

// F3 toggles fog visibility for fast map testing.
if (global.cheats_enabled && keyboard_check_pressed(vk_f3))
{
	global.fog_of_war_visible = !global.fog_of_war_visible;
}

// F6 replaces the current daily cards with every currently available event.
if (global.cheats_enabled && keyboard_check_pressed(vk_f6))
{
	debug_all_events_give();
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
	&& global.focus_window == FOCUS_WINDOW.NOONE
	&& !pause_menu_open
	&& !instance_exists(global.dragged_cultist)
	&& !instance_exists(global.dragged_artifact))
{
	player_pause_active = !player_pause_active;
	global.pause = player_pause_active;
}

// Spawn the starting cultists once the cannon exists in the room.
if (!cultists_spawned)
{
	spawn_starting_cultists();
}

// Open the first cultist choice after the welcome tutorial has closed.
if (starting_cultist_selection_pending)
{
	open_starting_cultist_selection();
}

// Spawn objective shrines around the cannon once the cannon exists.
if (!shrines_spawned)
{
	spawn_objective_shrines();
}

// Track shrine objective completion for the HUD and win condition hooks.
shrine_objective_update();

// Cleansed ground weakens player buildings after holy attacks remove Taint.
if (!global.pause)
{
	player_building_ground_state_update();
	crusade_taint_threshold_update();
}

// Delay the first worker assignment hint until gameplay has been visible for a moment.
if (!global.pause
	&& global.tutorial_hints_enabled
	&& global.focus_window == FOCUS_WINDOW.NOONE
	&& worker_assignment_hint_delay_started
	&& worker_assignment_hint_delay_timer > 0)
{
	worker_assignment_hint_delay_timer--;
}

// Delay the full moon tutorial until the player has unobstructed daytime control.
full_moon_hint_delay_update();

// Keep every night squad marker centered between its surviving units.
squad_night_markers_update();

// World event squad selectors block gameplay input while their dropdown is open.
world_event_squad_selector_input_update();

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
	var _cultist_status_card_clicked = false;
	var _minimap_camera_clicked = false;
	var _artifact_clicked = false;
	var _squad_marker_input_handled = false;

	// Day HUD buttons have priority over every world interaction beneath their GUI rectangles.
	if (global.day_phase == DAY_PHASE.DAY
		&& mouse_check_button_pressed(mb_left)
		&& instance_exists(o_jobs_ui))
	{
		var _jobs_ui = instance_find(o_jobs_ui, 0);
		var _jobs_show_rect = _jobs_ui.jobs_show_button_rect_get();
		var _jobs_end_rect = _jobs_ui.jobs_end_day_button_rect_get();
		var _jobs_show_button_clicked = point_in_rectangle(
			_mouse_gui_x,
			_mouse_gui_y,
			_jobs_show_rect.x,
			_jobs_show_rect.y,
			_jobs_show_rect.x + _jobs_show_rect.width,
			_jobs_show_rect.y + _jobs_show_rect.height
		);
		var _jobs_end_button_clicked = point_in_rectangle(
			_mouse_gui_x,
			_mouse_gui_y,
			_jobs_end_rect.x,
			_jobs_end_rect.y,
			_jobs_end_rect.x + _jobs_end_rect.width,
			_jobs_end_rect.y + _jobs_end_rect.height
		);

		if (_jobs_show_button_clicked)
		{
			if (_jobs_ui.jobs_window_open()
				&& variable_global_exists("ui_confirm_sound_play"))
			{
				global.ui_confirm_sound_play();
			}

			exit;
		}
		else if (_jobs_end_button_clicked)
		{
			if (_jobs_ui.jobs_end_day_request()
				&& variable_global_exists("ui_confirm_sound_play"))
			{
				global.ui_confirm_sound_play();
			}

			exit;
		}
	}

	// Night squad markers move every surviving member toward one shared cursor target.
	if (global.day_phase == DAY_PHASE.NIGHT)
	{
		if (is_struct(global.dragged_squad))
		{
			var _squad_marker_world_offset_y = BALANCE_SQUAD_MARKER_OFFSET_Y
				* (_camera_height / max(1, camera_view_height));
			squad_drag_update(
				global.dragged_squad,
				_mouse_world_x,
				_mouse_world_y + _squad_marker_world_offset_y
			);
			_squad_marker_input_handled = true;

			if (!mouse_check_button(mb_left))
			{
				squad_drag_end(global.dragged_squad, true);
				global.sound_play_random(global.release_worker_sounds);
			}
		}
		else if (mouse_check_button_pressed(mb_left))
		{
			var _picked_squad = squad_marker_find_at_position(_mouse_world_x, _mouse_world_y);

			if (is_struct(_picked_squad) && squad_drag_begin(_picked_squad))
			{
				_squad_marker_input_handled = true;
				global.sound_play_random(global.pick_worker_sounds);
			}
		}
	}

	if (!_squad_marker_input_handled
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

	if (global.day_phase == DAY_PHASE.DAY
		&& (!variable_global_exists("squad_info_window_open") || !global.squad_info_window_open)
		&& !instance_exists(global.dragged_cultist)
		&& !instance_exists(global.dragged_artifact)
		&& !is_struct(global.dragged_squad)
		&& mouse_check_button_pressed(mb_right))
	{
		var _whip_target = find_worker_whip_target_at_position(_mouse_world_x, _mouse_world_y);

		if (instance_exists(_whip_target))
		{
			worker_whip_apply(_whip_target);
		}
	}

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

		// Keep dragged units inside the already revealed fog of war area.
		if (!world_position_is_revealed_by_fog(_drag_world_x, _drop_world_y))
		{
			_drag_world_x = _dragged_cultist.drag_drop_x;
			_drop_world_y = _dragged_cultist.drag_drop_y;
			_assignment_world_y = _drop_world_y;
		}

		_dragged_cultist.x = _drag_world_x;
		_dragged_cultist.y = _drop_world_y + cultist_drag_lift_offset_y - cultist_drag_drop_offset_y;
		_dragged_cultist.drag_drop_x = _drag_world_x;
		_dragged_cultist.drag_drop_y = _drop_world_y;

		var _is_event_worker = _dragged_cultist.object_index == o_cultist;

		if (_is_event_worker)
		{
			global.cultist_assignment_preview_building = day_event_source_find_at_position(
				_drag_world_x,
				_assignment_world_y
			);
		}
		else
		{
			global.cultist_assignment_preview_building = find_worker_building_at_position(
				_drag_world_x,
				_assignment_world_y
			);
		}

		if (!_is_event_worker
			&& _dragged_cultist.object_index == o_goblin
			&& instance_exists(global.cultist_assignment_preview_building)
			&& global.cultist_assignment_preview_building.object_index == o_ritual_circle)
		{
			global.cultist_assignment_preview_building = noone;
		}

		if (!_is_event_worker
			&& instance_exists(global.cultist_assignment_preview_building)
			&& day_worker_is_out_of_stamina(_dragged_cultist)
			&& global.cultist_assignment_preview_building.object_index != o_ritual_circle
			&& global.cultist_assignment_preview_building.object_index != o_meat_bath
			&& variable_instance_exists(global.cultist_assignment_preview_building, "building_warning_show"))
		{
			global.cultist_assignment_preview_building.building_warning_show("NO STAMINA", COLOR_STATUS_NEGATIVE_RED);
			global.cultist_assignment_preview_building = noone;
		}

		if (!mouse_check_button(mb_left))
		{
			var _drop_building = global.cultist_assignment_preview_building;
			var _was_assigned_to_building = false;

			if (_is_event_worker)
			{
				if (instance_exists(_drop_building))
				{
					_was_assigned_to_building = day_event_worker_assign_to_source(
						_dragged_cultist,
						_drop_building
					);
				}
				else
				{
					// Dropping away from every event building removes the Jobs assignment.
					day_event_worker_unassign(_dragged_cultist);
					_was_assigned_to_building = true;
				}
			}
			else
			{
				_was_assigned_to_building = assign_cultist_to_worker_building(
					_dragged_cultist,
					_drop_building
				);
			}

			if (!_was_assigned_to_building && !_is_event_worker)
			{
				_dragged_cultist.x = _dragged_cultist.drag_drop_x;
				_dragged_cultist.y = _dragged_cultist.drag_drop_y;
				demon_manual_structure_target_assign_near_drop(_dragged_cultist);
			}
			else if (_is_event_worker)
			{
				// Remove the cursor lift before the worker starts walking or wandering.
				_dragged_cultist.x = _dragged_cultist.drag_drop_x;
				_dragged_cultist.y = _dragged_cultist.drag_drop_y;
			}

			_dragged_cultist.is_being_dragged = false;
			global.sound_play_random(global.release_worker_sounds);

			if (variable_instance_exists(_dragged_cultist, "demon_type")
				&& _dragged_cultist.demon_type != DEMON_TYPE.NONE
				&& variable_instance_exists(_dragged_cultist, "stun_apply"))
			{
				_dragged_cultist.stun_apply(BALANCE_DEMON_DRAG_STUN_TIME);
			}

			global.dragged_cultist = noone;
			global.cultist_assignment_preview_building = noone;
		}
	}
	else if (mouse_check_button_pressed(mb_left)
		&& !_squad_marker_input_handled
		&& !_artifact_clicked
		&& !_cultist_status_card_clicked
		&& !_minimap_camera_clicked)
	{
		var _levelup_cultist = cultist_levelup_button_find_at_gui(_mouse_gui_x, _mouse_gui_y);

		if (instance_exists(_levelup_cultist))
		{
			open_cultist_levelup_for_cultist(_levelup_cultist);
			exit;
		}

		var _cultist_count = array_length(global.archdemons);
		var _closest_cultist = noone;
		var _closest_distance = infinity;

		for (var _cultist_index = 0; _cultist_index < _cultist_count; ++_cultist_index)
		{
			var _cultist = global.archdemons[_cultist_index];

			if (drag_cultist_can_be_picked(_cultist)
				&& _mouse_world_x >= _cultist.bbox_left
				&& _mouse_world_x <= _cultist.bbox_right
				&& _mouse_world_y >= _cultist.bbox_top
				&& _mouse_world_y <= _cultist.bbox_bottom)
			{
				var _distance_to_archdemon = point_distance(_mouse_world_x, _mouse_world_y, _cultist.x, _cultist.y);

				if (_distance_to_archdemon < _closest_distance)
				{
					_closest_distance = _distance_to_archdemon;
					_closest_cultist = _cultist;
				}
			}
		}

		if (global.day_phase == DAY_PHASE.DAY
			&& variable_global_exists("event_cultists")
			&& is_array(global.event_cultists))
		{
			var _event_cultist_count = array_length(global.event_cultists);

			for (var _event_cultist_index = 0; _event_cultist_index < _event_cultist_count; ++_event_cultist_index)
			{
				var _event_cultist = global.event_cultists[_event_cultist_index];

				if (drag_cultist_can_be_picked(_event_cultist)
					&& _mouse_world_x >= _event_cultist.bbox_left
					&& _mouse_world_x <= _event_cultist.bbox_right
					&& _mouse_world_y >= _event_cultist.bbox_top
					&& _mouse_world_y <= _event_cultist.bbox_bottom)
				{
					var _distance_to_event_cultist = point_distance(
						_mouse_world_x,
						_mouse_world_y,
						_event_cultist.x,
						_event_cultist.y
					);

					if (_distance_to_event_cultist < _closest_distance)
					{
						_closest_distance = _distance_to_event_cultist;
						_closest_cultist = _event_cultist;
					}
				}
			}
		}

		var _worker_unit_objects = [o_goblin];

		if (global.day_phase == DAY_PHASE.DAY)
		{
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
		}

		if (instance_exists(_closest_cultist))
		{
			clear_cultist_building_assignment(_closest_cultist);

			// Store the last valid drop point before lifting the unit to the cursor.
			var _starting_drag_drop_x = _closest_cultist.x;
			var _starting_drag_drop_y = _closest_cultist.y;

			global.dragged_cultist = _closest_cultist;
			_closest_cultist.is_being_dragged = true;
			_closest_cultist.x = _mouse_world_x;
			_closest_cultist.y = _mouse_world_y + cultist_drag_lift_offset_y;
			_closest_cultist.drag_drop_x = _starting_drag_drop_x;
			_closest_cultist.drag_drop_y = _starting_drag_drop_y;
			global.sound_play_random(global.pick_worker_sounds);
		}
		else
		{
			var _building_slot = find_building_slot_at_position(_mouse_world_x, _mouse_world_y);

			if (instance_exists(_building_slot))
			{
				open_building_window(_building_slot);
			}
			else
			{
				var _events_building = find_building_events_at_position(_mouse_world_x, _mouse_world_y);

				if (instance_exists(_events_building))
				{
					open_building_events_window(_events_building);
				}
			}
		}
	}
}
else if (is_struct(global.dragged_squad))
{
	squad_drag_end(global.dragged_squad, false);
}
else if (instance_exists(global.dragged_cultist))
{
	global.dragged_cultist.x = global.dragged_cultist.drag_drop_x;
	global.dragged_cultist.y = global.dragged_cultist.drag_drop_y;
	global.dragged_cultist.is_being_dragged = false;
	global.sound_play_random(global.release_worker_sounds);

	if (variable_instance_exists(global.dragged_cultist, "demon_type")
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

// Worker whip bonuses tick only while gameplay is running.
if (!global.pause && variable_global_exists("archdemons"))
{
	worker_whip_effects_update();
	day_idle_cultists_wander_update();
	squad_day_group_update();
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

if (global.cheats_enabled)
{
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
		var _satiety_to_next_feast = global.cannon_satiety_max - (global.cannon_satiety mod global.cannon_satiety_max);

		if (_satiety_to_next_feast <= 0)
		{
			_satiety_to_next_feast = global.cannon_satiety_max;
		}

		cannon_satiety_add(_satiety_to_next_feast);
	}

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
		_debug_spawn_unit_object = o_boss_griffith;
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

	// F2 adds prototype resources for fast construction testing.
	if (keyboard_check_pressed(vk_f2))
	{
		resource_add(RESOURCES.FLESH, BALANCE_DEBUG_RESOURCE_CHEAT_AMOUNT);
		resource_add(RESOURCES.SOULS, BALANCE_DEBUG_RESOURCE_CHEAT_AMOUNT);
		resource_add(RESOURCES.IRON, BALANCE_DEBUG_RESOURCE_CHEAT_AMOUNT);
		resource_add(RESOURCES.IHOR, BALANCE_DEBUG_RESOURCE_CHEAT_AMOUNT);
	}

	// F8 skips the current day or night phase.
	if (keyboard_check_pressed(vk_f8)
		&& global.day_cycle_enabled
		&& global.focus_window == FOCUS_WINDOW.NOONE)
	{
		if (global.day_phase == DAY_PHASE.DAY)
		{
			day_event_finish_day();
			start_night_phase();
		}
		else
		{
			debug_kill_all_enemies();
			start_day_phase();
		}
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
	else if (global.focus_window == FOCUS_WINDOW.BUILDING_EVENTS)
	{
		close_building_events_window();
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

// Play UI feedback for the currently hovered or clicked button.
ui_audio_update();

// Track elapsed night time, but never force Blood Moon or boss nights to end by timer.
if (!global.pause && global.day_cycle_enabled)
{
	var _blood_moon_is_active = variable_global_exists("full_moon_night_active")
		&& global.full_moon_night_active;

	if (global.day_phase == DAY_PHASE.NIGHT)
	{
		global.day_timer = max(global.day_timer - 1, 0);

		if (!_blood_moon_is_active
			&& !boss_griffith_night_active
			&& !night_force_end_active)
		{
			night_force_end_timer = max(night_force_end_timer - 1, 0);

			if (night_force_end_timer <= 0)
			{
				night_force_end_active = true;
				night_timeout_enemy_retreat_start();
				start_day_phase();
			}
		}
	}
}

cannon_corrupted_ground_damage_update();

// Handle hover-card Reroll and Pin hotkeys before the legacy demolition action.
var _building_reroll_key_pressed = keyboard_check_pressed(ord("R"));
var _building_pin_key_pressed = keyboard_check_pressed(ord("T"));

if ((_building_reroll_key_pressed || _building_pin_key_pressed)
	&& global.day_phase == DAY_PHASE.DAY
	&& global.focus_window == FOCUS_WINDOW.NOONE
	&& !global.pause
	&& !instance_exists(global.dragged_cultist)
	&& instance_exists(o_camera_controller))
{
	var _action_camera_controller = instance_find(o_camera_controller, 0);
	var _action_mouse_gui_x = device_mouse_x_to_gui(0);
	var _action_mouse_gui_y = device_mouse_y_to_gui(0);
	var _action_camera_x = camera_get_view_x(_action_camera_controller.camera_id);
	var _action_camera_y = camera_get_view_y(_action_camera_controller.camera_id);
	var _action_camera_width = camera_get_view_width(_action_camera_controller.camera_id);
	var _action_camera_height = camera_get_view_height(_action_camera_controller.camera_id);
	var _action_mouse_world_x = _action_camera_x
		+ ((_action_mouse_gui_x / camera_view_width) * _action_camera_width);
	var _action_mouse_world_y = _action_camera_y
		+ ((_action_mouse_gui_y / camera_view_height) * _action_camera_height);
	var _action_building = find_building_events_at_position(
		_action_mouse_world_x,
		_action_mouse_world_y
	);
	var _action_event = day_event_source_event_get(_action_building);
	var _event_action_changed = false;

	if (day_event_building_action_is_available(_action_event))
	{
		if (_building_reroll_key_pressed && !global.day_event_reroll_used_today)
		{
			_event_action_changed = day_event_reroll(_action_event);
		}
		else if (_building_pin_key_pressed)
		{
			if (day_event_pin_is_event(_action_event))
			{
				_event_action_changed = day_event_pin_clear();
			}
			else if (!day_event_pin_is_active())
			{
				_event_action_changed = day_event_pin_set(_action_event);
			}
		}
	}
	else if (_building_pin_key_pressed)
	{
		// Buildings without an event card retain the existing demolition shortcut.
		var _demolish_building = find_demolishable_building_at_position(
			_action_mouse_world_x,
			_action_mouse_world_y
		);

		if (instance_exists(_demolish_building))
		{
			_demolish_building.building_demolish();
		}
	}

	if (_event_action_changed && variable_global_exists("ui_confirm_sound_play"))
	{
		global.ui_confirm_sound_play();
	}
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
		var _is_foundry_window = instance_exists(building_window_foundry);
		var _grid_y = _panel_y + building_window_grid_y + (_is_foundry_window ? 112 : 0);
		var _foundry_current_x = _panel_x + 44;
		var _foundry_current_y = _panel_y + 118;
		var _foundry_current_width = building_window_width - 88;
		var _foundry_current_height = 78;
		var _choice_count = array_length(building_window_choices);

		if (_mouse_x >= _close_x && _mouse_x <= _close_x + _close_size
			&& _mouse_y >= _close_y && _mouse_y <= _close_y + _close_size)
		{
			close_building_window();
		}
		else if (_is_foundry_window
			&& instance_exists(building_window_foundry)
			&& is_struct(building_window_foundry.foundry_selected_shell)
			&& _mouse_x >= _foundry_current_x
			&& _mouse_x <= _foundry_current_x + _foundry_current_width
			&& _mouse_y >= _foundry_current_y
			&& _mouse_y <= _foundry_current_y + _foundry_current_height)
		{
			if (variable_instance_exists(building_window_foundry, "foundry_shell_cancel"))
			{
				building_window_foundry.foundry_shell_cancel(true);
			}
		}
		else
		{
			var _daily_limit_reached = !_is_foundry_window
				&& !day_event_building_construction_can_start();

			for (var _choice_index = 0; !_daily_limit_reached && _choice_index < _choice_count; ++_choice_index)
			{
				var _tile_rect = building_choice_tile_rect_get(_choice_index, _is_foundry_window, _grid_x, _grid_y);

				if (is_struct(_tile_rect)
					&& ui_mouse_is_inside_rect(_mouse_x, _mouse_y, _tile_rect.x, _tile_rect.y, _tile_rect.width, _tile_rect.height))
				{
					construct_building_from_choice(building_window_choices[_choice_index]);
					break;
				}
			}
		}
	}
}

// The building event catalog is informational; only closing and scrolling are allowed.
if (global.focus_window == FOCUS_WINDOW.BUILDING_EVENTS)
{
	var _events_gui_width = display_get_gui_width();
	var _events_gui_height = display_get_gui_height();
	var _events_scale = min(_events_gui_width / 1920, _events_gui_height / 1080);
	var _events_panel_width = 1112 * _events_scale;
	var _events_panel_height = 898 * _events_scale;
	var _events_panel_x = (_events_gui_width - _events_panel_width) * 0.5;
	var _events_panel_y = 69 * _events_scale;
	var _events_start_y = _events_panel_y + (141 * _events_scale);
	var _events_step = 114 * _events_scale;
	var _events_current_gap = is_struct(building_events_window_current_event)
		? 40 * _events_scale
		: 0;
	var _events_viewport_height = _events_panel_y + _events_panel_height
		- (24 * _events_scale)
		- _events_start_y;
	var _events_content_height = (array_length(building_events_window_entries) * _events_step)
		+ _events_current_gap;
	var _max_scroll_row = ceil(
		max(0, _events_content_height - _events_viewport_height)
		/ max(1, _events_step)
	);

	if (mouse_wheel_up())
	{
		building_events_scroll_row = max(0, building_events_scroll_row - 1);
	}

	if (mouse_wheel_down())
	{
		building_events_scroll_row = min(_max_scroll_row, building_events_scroll_row + 1);
	}

	if (mouse_check_button_pressed(mb_left))
	{
		if (building_events_input_blocked)
		{
			building_events_input_blocked = false;
			exit;
		}

		var _mouse_x = device_mouse_x_to_gui(0);
		var _mouse_y = device_mouse_y_to_gui(0);
		var _close_size = 56 * _events_scale;
		var _close_x = _events_panel_x + _events_panel_width - (64 * _events_scale);
		var _close_y = _events_panel_y + (10 * _events_scale);

		if (_mouse_x >= _close_x && _mouse_x <= _close_x + _close_size
			&& _mouse_y >= _close_y && _mouse_y <= _close_y + _close_size)
		{
			close_building_events_window();
		}
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
	var _attribute_button_y = _panel_y + 486;
	var _ability_button_y = _panel_y + 560;
	var _button_width = 150;
	var _button_height = 44;
	var _button_gap = 18;
	var _button_start_x = _panel_x + 92;
	var _confirm_width = 210;
	var _confirm_height = 42;
	var _confirm_x = _panel_x + ((cultist_panel_width - _confirm_width) * 0.5);
	var _confirm_y = _panel_y + 612;
	var _cultist = noone;

	if (cultist_levelup_index >= 0 && cultist_levelup_index < array_length(global.archdemons))
	{
		_cultist = global.archdemons[cultist_levelup_index];
	}

	if (instance_exists(_cultist))
	{
		ensure_cultist_levelup_options(_cultist);
		var _ability_reward_type = cultist_levelup_ability_reward_type_get(_cultist);
		var _has_attribute_choice = cultist_levelup_has_attribute_choice(_cultist);
		var _has_ability_choice = _ability_reward_type != -1;
		var _attribute_stat_order = [CULTIST_STAT.BODY, CULTIST_STAT.FERVOR, CULTIST_STAT.SPIRIT];

		if (_has_attribute_choice)
		{
			var _attribute_button_count = array_length(_attribute_stat_order);

			for (var _stat_choice_index = 0; _stat_choice_index < _attribute_button_count; ++_stat_choice_index)
			{
				var _stat_button_x = _button_start_x + ((_button_width + _button_gap) * _stat_choice_index);

				if (_mouse_x >= _stat_button_x && _mouse_x <= _stat_button_x + _button_width
					&& _mouse_y >= _attribute_button_y && _mouse_y <= _attribute_button_y + _button_height)
				{
					cultist_levelup_selected_stat = _attribute_stat_order[_stat_choice_index];
					break;
				}
			}
		}

		if (_has_ability_choice)
		{
			var _ability_options = cultist_levelup_ability_options_get(_cultist, _ability_reward_type);
			var _ability_button_count = array_length(_ability_options);

			for (var _ability_choice_index = 0; _ability_choice_index < _ability_button_count; ++_ability_choice_index)
			{
				var _ability_button_x = _button_start_x + ((_button_width + _button_gap) * _ability_choice_index);

				if (_mouse_x >= _ability_button_x && _mouse_x <= _ability_button_x + _button_width
					&& _mouse_y >= _ability_button_y && _mouse_y <= _ability_button_y + _button_height)
				{
					cultist_levelup_selected_ability = _ability_options[_ability_choice_index];
					cultist_levelup_selected_reward_type = _ability_reward_type;
					break;
				}
			}
		}

		if (cultist_levelup_confirm_can_apply(_cultist)
			&& _mouse_x >= _confirm_x && _mouse_x <= _confirm_x + _confirm_width
			&& _mouse_y >= _confirm_y && _mouse_y <= _confirm_y + _confirm_height)
		{
			cultist_levelup_apply_selected();
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
			global.cannon_selected_projectile_index = clamp(global.cannon_selected_projectile_index, 0, array_length(global.cannon_projectile_queue) - 1);
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

// Structure shells can be aimed during the day; combat projectiles are night-only.
if (global.day_phase != DAY_PHASE.NIGHT
	&& global.focus_window == FOCUS_WINDOW.TARGET_SELECTION
	&& target_selection_projectile_type != PROJECTILE_TYPE.BUILDING_SHELL)
{
	global.focus_window = FOCUS_WINDOW.NOONE;
}

var _can_select_cannon_projectile = (global.day_phase == DAY_PHASE.NIGHT
		|| global.day_phase == DAY_PHASE.DAY)
	&& (global.focus_window == FOCUS_WINDOW.NOONE
		|| (global.cannon_projectile_cheat_enabled && global.focus_window == FOCUS_WINDOW.TARGET_SELECTION));

// Start or update target selection mode from hotkeys when a usable projectile is ready.
if (_can_select_cannon_projectile)
{
	var _projectile_queue_count = array_length(global.cannon_projectile_queue);
	var _projectile_display_slots = cannon_projectile_display_slots_get(9);
	var _max_digit_count = array_length(_projectile_display_slots);
	var _selected_projectile_index = -1;

	if (_max_digit_count > 0)
	{
		global.cannon_selected_projectile_index = clamp(global.cannon_selected_projectile_index, 0, max(0, _projectile_queue_count));
	}
	else
	{
		global.cannon_selected_projectile_index = 0;
	}

	for (var _digit_index = 0; _digit_index < _max_digit_count; ++_digit_index)
	{
		if (keyboard_check_pressed(ord(string(_digit_index + 1))))
		{
			var _digit_slot = _projectile_display_slots[_digit_index];
			var _digit_projectile_type = _digit_slot.projectile_type;

			if (global.day_phase == DAY_PHASE.NIGHT
				|| _digit_projectile_type == PROJECTILE_TYPE.BUILDING_SHELL)
			{
				_selected_projectile_index = _digit_slot.consume_queue_index;
			}

			break;
		}
	}

	if (_selected_projectile_index >= 0)
	{
		var _selected_projectile_type = PROJECTILE_TYPE.FEAST;

		if (_selected_projectile_index < _projectile_queue_count)
		{
			_selected_projectile_type = global.cannon_projectile_queue[_selected_projectile_index];
		}

		global.cannon_selected_projectile_index = _selected_projectile_index;
		target_selection_projectile_type = _selected_projectile_type;
		target_selection_radius = projectile_target_selection_radius_get(_selected_projectile_type);
		global.focus_window = FOCUS_WINDOW.TARGET_SELECTION;
	}
}

// Confirm target selection with left mouse button.
if (global.focus_window == FOCUS_WINDOW.TARGET_SELECTION && mouse_check_button_pressed(mb_left))
{
	if (global.day_phase != DAY_PHASE.NIGHT
		&& target_selection_projectile_type != PROJECTILE_TYPE.BUILDING_SHELL)
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
		var _projectile_queue_count = array_length(global.cannon_projectile_queue);
		var _selected_projectile_index = clamp(global.cannon_selected_projectile_index, 0, 8);

		if (target_selection_projectile_type != PROJECTILE_TYPE.FEAST && _projectile_queue_count > 0)
		{
			_selected_projectile_index = clamp(_selected_projectile_index, 0, _projectile_queue_count - 1);
			target_selection_projectile_type = global.cannon_projectile_queue[_selected_projectile_index];

			if (cannon_projectile_type_can_stack_in_hud(target_selection_projectile_type))
			{
				for (var _stack_queue_index = _projectile_queue_count - 1; _stack_queue_index >= 0; --_stack_queue_index)
				{
					if (global.cannon_projectile_queue[_stack_queue_index] == target_selection_projectile_type)
					{
						_selected_projectile_index = _stack_queue_index;
						break;
					}
				}
			}
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
		else if (target_selection_projectile_type == PROJECTILE_TYPE.BUILDING_SHELL
			&& !ground_cell_is_tainted_at_position(_target_world_x, _target_world_y))
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
			global.cannon_target_projectile_queue_index = _selected_projectile_index;
			global.cannon_target_version++;
			global.focus_window = FOCUS_WINDOW.NOONE;
		}
	}
}

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
		var _settings_slider_index = settings_slider_find_at_gui(_mouse_x, _mouse_y);

		if (mouse_check_button_pressed(mb_left)
			&& ui_mouse_is_inside_rect(_mouse_x, _mouse_y, _edge_toggle_rect.x, _edge_toggle_rect.y, _edge_toggle_rect.width, _edge_toggle_rect.height))
		{
			global.edge_scroll_enabled = !global.edge_scroll_enabled;
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
