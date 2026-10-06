/// @description Handles the shared cannon hotkeys, shell selection, and targeting gestures. Requires o_game_controller.
function cannon_target_input_update(_controller)
{
	if (!instance_exists(_controller)) return;
	with (_controller)
	{
		// Close aiming when the selected shell is phase-locked or the Cannon begins reloading.
		if (global.focus_window == FOCUS_WINDOW.TARGET_SELECTION
			&& (!cannon_projectile_type_can_fire_in_current_phase(target_selection_projectile_type)
				|| !cannon_is_ready_to_fire()))
		{
			hellcow_aim_is_dragging = false;
			hellcow_aim_drag_distance = 0;
			global.focus_window = FOCUS_WINDOW.NOONE;
		}
		
		var _cannon_is_ready = cannon_is_ready_to_fire();
		var _can_select_cannon_projectile = _cannon_is_ready
			&& (global.day_phase == DAY_PHASE.NIGHT
				|| global.day_phase == DAY_PHASE.DAY)
			&& (global.focus_window == FOCUS_WINDOW.NOONE
				|| (global.cannon_projectile_cheat_enabled && global.focus_window == FOCUS_WINDOW.TARGET_SELECTION));
		var _projectile_selection_click_index = -1;
		var _projectile_selection_click_used = false;
		
		// Projectile slots use the same selection path as their number hotkeys.
		if ((global.day_phase == DAY_PHASE.NIGHT || global.day_phase == DAY_PHASE.DAY)
			&& _cannon_is_ready
			&& (global.focus_window == FOCUS_WINDOW.NOONE
				|| global.focus_window == FOCUS_WINDOW.TARGET_SELECTION)
			&& mouse_check_button_pressed(mb_left)
			&& instance_exists(o_hud))
		{
			var _projectile_hud = instance_find(o_hud, 0);
		
			if (variable_instance_exists(_projectile_hud, "projectile_slot_at_gui_position"))
			{
				var _projectile_mouse_x = device_mouse_x_to_gui(0);
				var _projectile_mouse_y = device_mouse_y_to_gui(0);
				var _clicked_projectile_slot = _projectile_hud.projectile_slot_at_gui_position(
					_projectile_mouse_x,
					_projectile_mouse_y,
					id
				);
		
				if (is_struct(_clicked_projectile_slot))
				{
					_projectile_selection_click_used = true;
		
					if (_clicked_projectile_slot.queue_index >= 0
						&& _clicked_projectile_slot.count > 0
						&& cannon_projectile_type_can_fire_in_current_phase(_clicked_projectile_slot.projectile_type))
					{
						_projectile_selection_click_index = _clicked_projectile_slot.consume_queue_index;
		
						if (variable_global_exists("ui_confirm_sound_play"))
						{
							global.ui_confirm_sound_play();
						}
					}
				}
			}
		}
		
		// Start or update target selection mode from hotkeys when a usable projectile is ready.
		if (_can_select_cannon_projectile || _projectile_selection_click_index >= 0)
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
				if (_can_select_cannon_projectile
					&& !(global.cheats_enabled && keyboard_check(vk_shift))
					&& keyboard_check_pressed(ord(string(_digit_index + 1))))
				{
					var _digit_slot = _projectile_display_slots[_digit_index];
					var _digit_projectile_type = _digit_slot.projectile_type;
		
					if (cannon_projectile_type_can_fire_in_current_phase(_digit_projectile_type))
					{
						_selected_projectile_index = _digit_slot.consume_queue_index;
					}
		
					break;
				}
			}
		
			if (_projectile_selection_click_index >= 0)
			{
				_selected_projectile_index = _projectile_selection_click_index;
			}
		
			if (_selected_projectile_index >= 0)
			{
				var _selected_projectile_type = PROJECTILE_TYPE.DAMAGE;
		
				if (_selected_projectile_index < _projectile_queue_count)
				{
					_selected_projectile_type = global.cannon_projectile_queue[_selected_projectile_index];
				}
		
				global.cannon_selected_projectile_index = _selected_projectile_index;
				target_selection_projectile_type = _selected_projectile_type;
				target_selection_radius = projectile_target_selection_radius_get(_selected_projectile_type);
				hellcow_aim_is_dragging = false;
				hellcow_aim_drag_distance = 0;
				global.focus_window = FOCUS_WINDOW.TARGET_SELECTION;
			}
		}
		
		// Hellcow uses one gesture: press to place it, drag for direction and distance, release to fire.
		var _hellcow_target_selection_active = global.focus_window == FOCUS_WINDOW.TARGET_SELECTION
			&& target_selection_projectile_type == PROJECTILE_TYPE.BOMB;
		
		if (_hellcow_target_selection_active
			&& mouse_check_button_pressed(mb_left)
			&& !_projectile_selection_click_used
			&& (!battle_mode_active || !battle_ui_layout_get().mouse_is_over_ui)
			&& instance_exists(o_camera_controller))
		{
			var _hellcow_camera_controller = instance_find(o_camera_controller, 0);
			var _hellcow_mouse_x = device_mouse_x_to_gui(0);
			var _hellcow_mouse_y = device_mouse_y_to_gui(0);
			var _hellcow_camera_x = camera_get_view_x(_hellcow_camera_controller.camera_id);
			var _hellcow_camera_y = camera_get_view_y(_hellcow_camera_controller.camera_id);
			var _hellcow_camera_width = camera_get_view_width(_hellcow_camera_controller.camera_id);
			var _hellcow_camera_height = camera_get_view_height(_hellcow_camera_controller.camera_id);
		
			hellcow_aim_start_x = _hellcow_camera_x
				+ ((_hellcow_mouse_x / camera_view_width) * _hellcow_camera_width);
			hellcow_aim_start_y = _hellcow_camera_y
				+ ((_hellcow_mouse_y / camera_view_height) * _hellcow_camera_height);
			hellcow_aim_is_dragging = true;
			hellcow_aim_drag_distance = 0;
		}
		
		if (_hellcow_target_selection_active
			&& hellcow_aim_is_dragging
			&& (mouse_check_button(mb_left) || mouse_check_button_released(mb_left))
			&& instance_exists(o_camera_controller))
		{
			var _hellcow_drag_camera = instance_find(o_camera_controller, 0);
			var _hellcow_drag_mouse_x = device_mouse_x_to_gui(0);
			var _hellcow_drag_mouse_y = device_mouse_y_to_gui(0);
			var _hellcow_drag_camera_x = camera_get_view_x(_hellcow_drag_camera.camera_id);
			var _hellcow_drag_camera_y = camera_get_view_y(_hellcow_drag_camera.camera_id);
			var _hellcow_drag_camera_width = camera_get_view_width(_hellcow_drag_camera.camera_id);
			var _hellcow_drag_camera_height = camera_get_view_height(_hellcow_drag_camera.camera_id);
			var _hellcow_drag_world_x = _hellcow_drag_camera_x
				+ ((_hellcow_drag_mouse_x / camera_view_width) * _hellcow_drag_camera_width);
			var _hellcow_drag_world_y = _hellcow_drag_camera_y
				+ ((_hellcow_drag_mouse_y / camera_view_height) * _hellcow_drag_camera_height);
		
			hellcow_aim_drag_distance = point_distance(
				hellcow_aim_start_x,
				hellcow_aim_start_y,
				_hellcow_drag_world_x,
				_hellcow_drag_world_y
			);
		
			if (hellcow_aim_drag_distance > 0)
			{
				hellcow_aim_direction = point_direction(
					hellcow_aim_start_x,
					hellcow_aim_start_y,
					_hellcow_drag_world_x,
					_hellcow_drag_world_y
				);
			}
		}
		
		var _target_selection_should_confirm = global.focus_window == FOCUS_WINDOW.TARGET_SELECTION
			&& !_projectile_selection_click_used
			&& (!battle_mode_active || !battle_ui_layout_get().mouse_is_over_ui)
			&& ((!_hellcow_target_selection_active && mouse_check_button_pressed(mb_left))
				|| (_hellcow_target_selection_active
					&& hellcow_aim_is_dragging
					&& mouse_check_button_released(mb_left)));
		
		// Confirm ordinary targets on click and Hellcow targets on drag release.
		if (_target_selection_should_confirm)
		{
			if (!cannon_projectile_type_can_fire_in_current_phase(target_selection_projectile_type))
			{
				global.focus_window = FOCUS_WINDOW.NOONE;
			}
			else if (array_length(global.cannon_projectile_queue) <= 0)
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
		
				if (_hellcow_target_selection_active)
				{
					_target_world_x = hellcow_aim_start_x;
					_target_world_y = hellcow_aim_start_y;
				}
		
				var _projectile_queue_count = array_length(global.cannon_projectile_queue);
				var _selected_projectile_index = clamp(global.cannon_selected_projectile_index, 0, 8);
		
				if (_projectile_queue_count > 0)
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
				var _target_consumes_projectile_queue = !cannon_projectile_type_is_reusable(target_selection_projectile_type);
		
				if (!cannon_is_ready_to_fire())
				{
					_target_can_be_confirmed = false;
				}
				else if (_hellcow_target_selection_active
					&& hellcow_aim_drag_distance < BALANCE_PROJECTILE_HELLCOW_AIM_MIN_DRAG)
				{
					_target_can_be_confirmed = false;
				}
				else if (target_selection_projectile_type == PROJECTILE_TYPE.CULTIST
					&& !world_position_is_revealed_by_fog(_target_world_x, _target_world_y))
				{
					_target_can_be_confirmed = false;
				}
				else if (target_selection_projectile_type == PROJECTILE_TYPE.CORRUPTION
					&& !taint_compost_target_touches_corruption(_target_world_x, _target_world_y))
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
					// Snapshot the range before clearing the gesture; in-flight shells keep their own copy.
					hellcow_target_charge_distance = _hellcow_target_selection_active
						? hellcow_aim_charge_distance_get()
						: BALANCE_PROJECTILE_HELLCOW_CHARGE_DISTANCE;
					global.cannon_target_exists = true;
					global.cannon_target_x = _target_world_x;
					global.cannon_target_y = _target_world_y;
					global.cannon_target_projectile_type = target_selection_projectile_type;
					global.cannon_target_direction = _hellcow_target_selection_active
						? hellcow_aim_direction
						: 0;
					global.cannon_target_consumes_projectile_queue = _target_consumes_projectile_queue;
					global.cannon_target_projectile_queue_index = _selected_projectile_index;
					global.cannon_target_version++;
					hellcow_aim_is_dragging = false;
					hellcow_aim_drag_distance = 0;
					global.focus_window = FOCUS_WINDOW.NOONE;
				}
				else if (_hellcow_target_selection_active)
				{
					hellcow_aim_is_dragging = false;
					hellcow_aim_drag_distance = 0;
				}
			}
		}
	}
}
