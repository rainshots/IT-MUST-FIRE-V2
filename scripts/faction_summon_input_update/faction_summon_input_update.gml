/// @description Handles instant purchases with buttons or keys 1-5; called in controller context.
function faction_summon_input_update()
{
	if (global.pause || fight_state != FIGHT_STATE.ACTIVE || global.focus_window != FOCUS_WINDOW.NOONE) return false;
	var _choices = faction_summon_options[global.player_faction];
	var _choice_count = array_length(_choices);
	var _mouse_x = device_mouse_x_to_gui(0);
	var _mouse_y = device_mouse_y_to_gui(0);
	for (var _index = 0; _index < _choice_count; ++_index)
	{
		var _rect = faction_summon_rect_get(_index);
		var _clicked = mouse_check_button_pressed(mb_left)
			&& point_in_rectangle(_mouse_x, _mouse_y, _rect.x, _rect.y, _rect.x + _rect.width, _rect.y + _rect.height);
		if (_clicked || keyboard_check_pressed(ord("1") + _index))
		{
			faction_summon_purchase(global.player_faction, _index);
			return true;
		}
	}
	return false;
}
