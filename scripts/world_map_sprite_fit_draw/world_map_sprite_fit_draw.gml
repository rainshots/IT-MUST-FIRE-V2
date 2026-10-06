/// @description Draws a sprite inside a centered box while respecting its origin and aspect ratio.
function world_map_sprite_fit_draw(_sprite, _x, _y, _width, _height, _alpha = 1)
{
	if (!sprite_exists(_sprite)) return;
	var _sprite_width = max(1, sprite_get_width(_sprite));
	var _sprite_height = max(1, sprite_get_height(_sprite));
	var _scale = min(_width / _sprite_width, _height / _sprite_height);
	var _draw_x = _x + (sprite_get_xoffset(_sprite) - _sprite_width * 0.5) * _scale;
	var _draw_y = _y + (sprite_get_yoffset(_sprite) - _sprite_height * 0.5) * _scale;
	draw_sprite_ext(_sprite, 0, _draw_x, _draw_y, _scale, _scale, 0, c_white, _alpha);
}
