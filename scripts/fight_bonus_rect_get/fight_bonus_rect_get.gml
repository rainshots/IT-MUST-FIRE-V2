/// @description Returns one of the three centered bonus cards in GUI coordinates.
function fight_bonus_rect_get(_index)
{
	var _scale = min(1, display_get_gui_width() / 1100, display_get_gui_height() / 650);
	var _width = 290 * _scale;
	var _height = 210 * _scale;
	var _gap = 22 * _scale;
	var _total_width = BALANCE_BONUS_CHOICE_COUNT * _width + (BALANCE_BONUS_CHOICE_COUNT - 1) * _gap;
	return {x: (display_get_gui_width() - _total_width) * 0.5 + _index * (_width + _gap),
		y: (display_get_gui_height() - _height) * 0.5, width: _width, height: _height, scale: _scale};
}
