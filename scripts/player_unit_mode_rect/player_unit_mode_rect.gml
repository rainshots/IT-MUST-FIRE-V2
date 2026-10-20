/// @description Returns the stance button at the left-middle of the GUI.
function player_unit_mode_rect()
{
	return {x: BALANCE_UNIT_MODE_BUTTON_MARGIN,
		y: (display_get_gui_height() - BALANCE_UNIT_MODE_BUTTON_HEIGHT) * 0.5,
		width: BALANCE_UNIT_MODE_BUTTON_WIDTH, height: BALANCE_UNIT_MODE_BUTTON_HEIGHT};
}
