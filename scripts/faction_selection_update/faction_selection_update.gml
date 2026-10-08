/// @description Handles faction selection; called by the game controller while paused.
function faction_selection_update()
{
	if (!mouse_check_button_pressed(mb_left)) return;
	var _mouse_x = device_mouse_x_to_gui(0);
	var _mouse_y = device_mouse_y_to_gui(0);
	var _count = array_length(faction_choices);
	for (var _index = 0; _index < _count; ++_index)
	{
		var _rect = faction_selection_rect_get(_index);
		if (!point_in_rectangle(_mouse_x, _mouse_y, _rect.x, _rect.y,
			_rect.x + _rect.width, _rect.y + _rect.height)) continue;
		if (!faction_player_assign(faction_choices[_index].faction))
		{
			continue;
		}
		faction_selection_active = false;
		faction_selection_release_pending = true;
		global.ui_confirm_sound_play();
		break;
	}
}
