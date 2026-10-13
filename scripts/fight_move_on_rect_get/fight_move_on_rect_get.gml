/// @description Returns the shared middle-right MOVE ON button rectangle.
function fight_move_on_rect_get()
{
	var _scale = clamp(display_get_gui_height() / 1080, 0.6, 1);
	var _width = 220 * _scale;
	var _height = 64 * _scale;
	var _margin = 32 * _scale;
	return {x: display_get_gui_width() - _width - _margin,
		y: (display_get_gui_height() - _height) * 0.5, width: _width, height: _height};
}
