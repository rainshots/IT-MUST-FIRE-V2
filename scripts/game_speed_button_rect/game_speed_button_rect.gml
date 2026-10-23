/// @description Returns the game-speed button directly below the stance button.
function game_speed_button_rect()
{
	var _r = player_unit_mode_rect();
	_r.y += _r.height + BALANCE_GAME_SPEED_BUTTON_GAP;
	return _r;
}
