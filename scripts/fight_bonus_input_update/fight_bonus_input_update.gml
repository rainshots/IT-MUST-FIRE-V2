/// @description Handles the modal reward without allowing the MOVE ON click to select a card.
function fight_bonus_input_update()
{
	if (!fight_bonus_open) return;
	global.pause = true;
	if (fight_bonus_wait_release)
	{
		if (!mouse_check_button(mb_left)) fight_bonus_wait_release = false;
		return;
	}
	if (!mouse_check_button_pressed(mb_left)) return;
	var _x = device_mouse_x_to_gui(0);
	var _y = device_mouse_y_to_gui(0);
	for (var _index = 0; _index < array_length(fight_bonus_options); ++_index)
	{
		var _rect = fight_bonus_rect_get(_index);
		if (point_in_rectangle(_x, _y, _rect.x, _rect.y, _rect.x + _rect.width, _rect.y + _rect.height))
		{
			fight_bonus_choose(_index);
			return;
		}
	}
}
