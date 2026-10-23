/// @description Returns the outline toggle beneath the speed button.
function building_outlines_button_rect()
{
	var _r = game_speed_button_rect();
	_r.y += _r.height + BALANCE_GAME_SPEED_BUTTON_GAP;
	return _r;
}
