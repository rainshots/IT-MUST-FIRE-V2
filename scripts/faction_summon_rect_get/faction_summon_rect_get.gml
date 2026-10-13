/// @description Shared GUI layout for the player summon buttons at bottom center.
function faction_summon_rect_get(_index)
{
	var _scale = clamp(display_get_gui_height() / 1080, 0.6, 1);
	var _width = BALANCE_SUMMON_BUTTON_WIDTH * _scale;
	var _height = BALANCE_SUMMON_BUTTON_HEIGHT * _scale;
	var _gap = BALANCE_SUMMON_BUTTON_GAP * _scale;
	var _count = array_length(faction_summon_options[global.player_faction]);
	var _left = (display_get_gui_width() - (_width * _count + _gap * (_count - 1))) * 0.5;
	return {x: _left + _index * (_width + _gap), y: display_get_gui_height() - _height - 20 * _scale,
		width: _width, height: _height, scale: _scale};
}
