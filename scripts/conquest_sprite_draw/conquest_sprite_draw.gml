/// @description Fits existing art to a box with its visible bottom anchored at the requested position.
function conquest_sprite_draw(_sprite, _x, _bottom, _width, _height, _flip = false)
{
	if (!sprite_exists(_sprite)) return;
	var _sprite_width = max(1, sprite_get_bbox_right(_sprite) - sprite_get_bbox_left(_sprite) + 1);
	var _sprite_height = max(1, sprite_get_bbox_bottom(_sprite) - sprite_get_bbox_top(_sprite) + 1);
	var _scale = min(_width / _sprite_width, _height / _sprite_height);
	var _direction = _flip ? -1 : 1;
	var _center = (sprite_get_bbox_left(_sprite) + sprite_get_bbox_right(_sprite)) * 0.5;
	var _draw_x = _x + (sprite_get_xoffset(_sprite) - _center) * _scale * _direction;
	var _draw_y = _bottom + (sprite_get_yoffset(_sprite) - sprite_get_bbox_bottom(_sprite)) * _scale;
	draw_sprite_ext(_sprite, 0, _draw_x, _draw_y, _scale * _direction, _scale, 0, c_white, 1);
}
