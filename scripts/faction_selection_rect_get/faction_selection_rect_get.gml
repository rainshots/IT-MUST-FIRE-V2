/// @description Returns a faction button rectangle in GUI coordinates.
function faction_selection_rect_get(_index)
{
	var _gui_width = display_get_gui_width();
	var _gui_height = display_get_gui_height();
	var _width = min(760, _gui_width * 0.8);
	var _height = min(120, _gui_height * 0.13);
	var _gap = 16;
	var _count = 4;
	var _total_height = (_height * _count) + (_gap * (_count - 1));
	return {
		x: (_gui_width - _width) * 0.5,
		y: (_gui_height - _total_height) * 0.5 + 36 + (_index * (_height + _gap)),
		width: _width,
		height: _height
	};
}
