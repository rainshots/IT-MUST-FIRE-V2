/// @description Returns a cargo icon cell under the objective HUD.
function cargo_icon_rect_get(_index)
{
	var _scale = clamp(display_get_gui_height() / 1080, 0.6, 1);
	return {x: display_get_gui_width() - 328 * _scale + (_index mod 5) * 54 * _scale,
		y: 195 * _scale + (_index div 5) * 54 * _scale, size: 46 * _scale};
}
