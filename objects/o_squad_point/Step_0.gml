// Availability reacts immediately to squad creation, event orders, and day-limit changes.
squad_point_state_update();

// An open selection window remains responsive while gameplay is paused.
if (squad_point_selection_open)
{
	if (global.day_phase != DAY_PHASE.DAY
		|| squad_point_state != SQUAD_POINT_STATE.AVAILABLE)
	{
		squad_point_selection_close();
		exit;
	}

	if (global.focus_window != FOCUS_WINDOW.SQUAD_POINT_SELECTION
		|| !variable_global_exists("squad_point_selection_source")
		|| global.squad_point_selection_source != id)
	{
		squad_point_selection_open = false;
		exit;
	}

	if (mouse_check_button_pressed(mb_left))
	{
		var _mouse_x = device_mouse_x_to_gui(0);
		var _mouse_y = device_mouse_y_to_gui(0);
		var _choice_index = squad_point_choice_hover_index_get(_mouse_x, _mouse_y);

		if (_choice_index >= 0
			&& _choice_index < array_length(squad_point_choices)
			&& squad_point_recruitment_event_create(squad_point_choices[_choice_index])
			&& variable_global_exists("ui_confirm_sound_play"))
		{
			global.ui_confirm_sound_play();
		}
	}

	exit;
}

squad_point_hovered = squad_point_is_hovered();

if (squad_point_hovered
	&& squad_point_hover_key != string(id)
	&& variable_global_exists("ui_hover_sounds")
	&& variable_global_exists("sound_priority_ui"))
{
	global.sound_play_random(global.ui_hover_sounds, global.sound_priority_ui);
	squad_point_hover_key = string(id);
}
else if (!squad_point_hovered)
{
	squad_point_hover_key = "";
}

if (squad_point_hovered && mouse_check_button_pressed(mb_left))
{
	if (squad_point_selection_open_window()
		&& variable_global_exists("ui_confirm_sound_play"))
	{
		global.ui_confirm_sound_play();
	}
}
