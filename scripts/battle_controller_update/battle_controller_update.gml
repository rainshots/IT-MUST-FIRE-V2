/// @description Runs preparation input, the battle clock, and the result screen for o_game_controller.
function battle_controller_update(_controller)
{
	var _layout = battle_ui_layout_get();
	var _mouse_x = device_mouse_x_to_gui(0);
	var _mouse_y = device_mouse_y_to_gui(0);
	var _button_hovered = ui_mouse_is_inside_rect(_mouse_x, _mouse_y,
		_layout.button_x, _layout.button_y, _layout.button_width, _layout.button_height);
	var _pressed = mouse_check_button_pressed(mb_left);
	var _phase = _controller.battle_phase;

	// The result button returns to the persistent campaign map without restarting the game.
	if (_phase == BATTLE_PHASE.VICTORY || _phase == BATTLE_PHASE.DEFEAT)
	{
		if ((_button_hovered && _pressed) || keyboard_check_pressed(vk_enter))
		{
			global.pause = false;
			global.focus_window = FOCUS_WINDOW.NOONE;
			// Preserve roster array changes as well as the shared squad structs and damage counters.
			var _map = instance_find(o_world_map, 0);
			if (instance_exists(_map)) _map.squads = global.squads;
			room_goto(r_world_map);
		}
		return;
	}

	// F8 also works while paused or preparing and never fabricates squad damage totals.
	if (global.cheats_enabled && keyboard_check_pressed(vk_f8))
	{
		battle_enemies_clear();
		battle_result_update(_controller);
		if (_controller.battle_phase == BATTLE_PHASE.VICTORY) return;
	}

	// The point owns construction-menu clicks; keep battle input blocked until it closes.
	if (global.focus_window == FOCUS_WINDOW.CURSED_POINT_STRUCTURE_SELECTION)
	{
		if (keyboard_check_pressed(vk_escape))
		{
			var _point = global.cursed_point_structure_selection_source;
			if (instance_exists(_point))
			{
				_point.cursed_point_structure_selection_close();
			}
			else
			{
				global.cursed_point_structure_selection_source = noone;
				global.focus_window = FOCUS_WINDOW.NOONE;
				global.pause = false;
			}
		}
		return;
	}

	// Escape cancels the current gesture first; otherwise Escape or Space toggles pause.
	if (keyboard_check_pressed(vk_escape))
	{
		if (is_struct(_controller.battle_dragged_squad))
		{
			_controller.battle_dragged_squad = noone;
			_controller.battle_preview_positions = [];
		}
		else if (is_struct(global.dragged_squad)) squad_drag_end(global.dragged_squad, false);
		else if (global.focus_window == FOCUS_WINDOW.TARGET_SELECTION)
		{
			global.focus_window = FOCUS_WINDOW.NOONE;
			_controller.hellcow_aim_is_dragging = false;
		}
		else global.pause = !global.pause;
	}
	else if (keyboard_check_pressed(vk_space)) global.pause = !global.pause;
	// Preparation pause keeps aiming available; battle pause also allows squad orders below.
	if (global.pause && _phase == BATTLE_PHASE.PREPARATION)
	{
		if (!is_struct(_controller.battle_dragged_squad) && !is_struct(global.dragged_squad))
		{
			cannon_target_input_update(_controller);
			_controller.gameplay_time_scale_update();
		}
		return;
	}

	// Start is always available, including when no squad was deployed or shells remain unused.
	if (_phase == BATTLE_PHASE.PREPARATION && _button_hovered && _pressed)
	{
		battle_start(_controller);
		return;
	}
	if (!global.pause && _phase == BATTLE_PHASE.BATTLE && keyboard_check_pressed(ord("Q")))
	{
		_controller.night_fast_forward_set(!_controller.night_fast_forward_active);
	}

	// The original HUD sorts cards by squad type; reuse its hit test for dragging.
	var _hovered_squad = noone;
	if (instance_exists(o_hud))
	{
		var _hud = instance_find(o_hud, 0);
		_hovered_squad = _hud.hud_squad_at_gui_position(_mouse_x, _mouse_y);
	}
	var _mouse_world = battle_mouse_world_get();
	var _inside_world = !_layout.mouse_is_over_ui;

	if (_phase == BATTLE_PHASE.PREPARATION)
	{
		// RMB on a card recalls its squad; LMB drags either a reserve card or an existing flag.
		if (is_struct(_hovered_squad) && mouse_check_button_pressed(mb_right))
		{
			battle_squad_recall(_controller, _hovered_squad);
		}
		if (_pressed && global.focus_window == FOCUS_WINDOW.NOONE)
		{
			var _picked_squad = _hovered_squad;
			if (!is_struct(_picked_squad) && _inside_world)
			{
				_picked_squad = battle_preparation_squad_at_world(_mouse_world.x, _mouse_world.y);
			}
			if (is_struct(_picked_squad)) _controller.battle_dragged_squad = _picked_squad;
		}
		var _dragged = _controller.battle_dragged_squad;
		if (is_struct(_dragged))
		{
			var _positions = battle_formation_positions_get(_dragged, _mouse_world.x, _mouse_world.y);
			_controller.battle_preview_positions = _positions;
			_controller.battle_preview_valid = _inside_world && battle_deployment_is_valid(_controller, _dragged, _positions);
			if (mouse_check_button_released(mb_left))
			{
				if (_controller.battle_preview_valid)
				{
					battle_squad_deploy(_controller, _dragged, _positions);
					_controller.battle_feedback = _dragged.name + " deployed";
				}
				else
				{
					_controller.battle_feedback = !_dragged.properties.battle_deployed
						&& _controller.battle_deployed_count >= BALANCE_BATTLE_DEPLOYMENT_LIMIT
						? "Maximum " + string(BALANCE_BATTLE_DEPLOYMENT_LIMIT) + " squads on the field"
						: "Place the whole squad on clear Taint, away from the cannon and other squads";
				}
				_controller.battle_dragged_squad = noone;
				_controller.battle_preview_positions = [];
			}
			return;
		}
	}
	else
	{
		// Shared combat updates stay frozen while input can still change a squad's destination.
		if (!global.pause)
		{
			squad_combat_guides_update();
			squad_night_markers_update();
		}

		// Battle flags keep the old left-drag move and right-drag attack-move controls.
		if (is_struct(global.dragged_squad))
		{
			var _dragged = global.dragged_squad;
			if (_inside_world)
			{
				var _world_per_gui = camera_get_view_height(view_camera[0]) / display_get_gui_height();
				squad_drag_update(_dragged, _mouse_world.x,
					_mouse_world.y + (BALANCE_SQUAD_MARKER_DRAG_TARGET_OFFSET_Y * _world_per_gui));
			}
			if (!mouse_check_button(_dragged.properties.marker_drag_button)) squad_drag_end(_dragged, _inside_world);
		}
		else if (global.focus_window == FOCUS_WINDOW.NOONE
			&& (_pressed || mouse_check_button_pressed(mb_right)))
		{
			var _picked_squad = _hovered_squad;
			if (!is_struct(_picked_squad) && _inside_world)
			{
				_picked_squad = squad_marker_find_at_position(_mouse_world.x, _mouse_world.y);
			}
			if (is_struct(_picked_squad) && _picked_squad.properties.battle_deployed
				&& squad_living_unit_count_get(_picked_squad) > 0)
			{
				var _button = mouse_check_button_pressed(mb_right) ? mb_right : mb_left;
				squad_drag_begin(_picked_squad, _button,
					_button == mb_right ? SQUAD_ORDER.MOVE_AND_ATTACK : SQUAD_ORDER.MOVE);
			}
		}

		// Pause accepts orders without advancing the battle clock, results, or enemy cannon schedule.
		if (!global.pause)
		{
			_controller.battle_elapsed_seconds += global.gameplay_time_scale / max(1, room_speed);
			_controller.battle_result_check_seconds -= global.gameplay_time_scale / max(1, room_speed);
			if (_controller.battle_result_check_seconds <= 0)
			{
				_controller.battle_result_check_seconds = BALANCE_BATTLE_RESULT_CHECK_SECONDS;
				battle_result_update(_controller);
				if (_controller.battle_phase != BATTLE_PHASE.BATTLE) return;
			}

			// Reuse the original Holy Cannon shells and warning sequence on the battle schedule.
			if (_controller.battle_elapsed_seconds >= _controller.battle_holy_cannon_next_seconds)
			{
				_controller.holy_cannon_strike_create();
				_controller.battle_holy_cannon_next_seconds += BALANCE_BATTLE_HOLY_CANNON_INTERVAL_SECONDS;
			}
		}
	}

	// Keep the established aiming, projectile consumption, and reload mechanics.
	if (!is_struct(global.dragged_squad)) cannon_target_input_update(_controller);
	_controller.gameplay_time_scale_update();
}
