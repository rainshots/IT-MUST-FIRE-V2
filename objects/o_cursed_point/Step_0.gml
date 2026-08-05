// Cleansed ground makes the point inactive even if the selection window is open.
cursed_point_ground_state_update();

// Handle an already opened structure choice even while gameplay is paused.
if (structure_selection_open)
{
	if (global.day_phase != DAY_PHASE.DAY)
	{
		cursed_point_structure_selection_close();
		exit;
	}

	if (global.focus_window != FOCUS_WINDOW.CURSED_POINT_STRUCTURE_SELECTION
		|| !variable_global_exists("cursed_point_structure_selection_source")
		|| global.cursed_point_structure_selection_source != id)
	{
		structure_selection_open = false;
		exit;
	}

	if (mouse_check_button_pressed(mb_left))
	{
		var _mouse_x = device_mouse_x_to_gui(0);
		var _mouse_y = device_mouse_y_to_gui(0);
		var _hovered_choice = cursed_point_structure_choice_hover_index_get(_mouse_x, _mouse_y);

		if (_hovered_choice >= 0
			&& _hovered_choice < array_length(structure_choice_options))
		{
			var _choice = structure_choice_options[_hovered_choice];

			if (cursed_point_structure_choice_can_construct(_choice))
			{
				cursed_point_structure_build(_choice);
			}
		}
	}

	exit;
}

// Check whether visible Taint overlaps the ground under the cursed point.
tower_capture_update();

// The summon button stays interactive during lightweight gameplay pause.
var _pause_menu_blocks_button = false;

if (instance_exists(o_game_controller))
{
	var _game_controller = instance_find(o_game_controller, 0);

	if (variable_instance_exists(_game_controller, "pause_menu_open"))
	{
		_pause_menu_blocks_button = _game_controller.pause_menu_open;
	}
}

summon_button_hovered = !_pause_menu_blocks_button && cursed_point_summon_button_is_hovered();

if (summon_button_hovered
	&& summon_button_hover_key != string(id)
	&& variable_global_exists("ui_hover_sounds")
	&& variable_global_exists("sound_priority_ui"))
{
	global.sound_play_random(global.ui_hover_sounds, global.sound_priority_ui);
	summon_button_hover_key = string(id);
}
else if (!summon_button_hovered)
{
	summon_button_hover_key = "";
}

if (summon_button_hovered && mouse_check_button_pressed(mb_left))
{
	if (variable_global_exists("ui_confirm_sound_play"))
	{
		global.ui_confirm_sound_play();
	}

	cursed_point_structure_selection_open();
}

// Pause freezes the remaining world logic.
if (global.pause)
{
	exit;
}
