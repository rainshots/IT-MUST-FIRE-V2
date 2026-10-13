/// @description Returns the centered manual fire button in GUI coordinates.
function cannon_fire_rect_get()
{
	var _width = 180;
	var _height = 64;
	return {x: (display_get_gui_width() - _width) * 0.5, y: (display_get_gui_height() - _height) * 0.5, width: _width, height: _height};
}
