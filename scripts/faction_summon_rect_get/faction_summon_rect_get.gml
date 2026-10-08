/// @description Shared GUI layout for the three summon buttons at bottom center.
function faction_summon_rect_get(_index)
{
	var _scale = clamp(display_get_gui_height() / 1080, 0.6, 1);
	var _width = BALANCE_SUMMON_BUTTON_WIDTH * _scale;
	var _height = BALANCE_SUMMON_BUTTON_HEIGHT * _scale;
	var _gap = BALANCE_SUMMON_BUTTON_GAP * _scale;
	var _left = (display_get_gui_width() - (_width * 3 + _gap * 2)) * 0.5;
	return {x: _left + _index * (_width + _gap), y: display_get_gui_height() - _height - 20 * _scale,
		width: _width, height: _height, scale: _scale};
}
