var _scale = BALANCE_PUMPKIN_DRAW_SIZE / max(sprite_get_width(sprite_index), sprite_get_height(sprite_index));
var _draw_x = x + (sprite_get_xoffset(sprite_index) - sprite_get_width(sprite_index) * 0.5) * _scale;
var _draw_y = y + (sprite_get_yoffset(sprite_index) - sprite_get_height(sprite_index) * 0.5) * _scale;
draw_sprite_ext(sprite_index, 0, _draw_x, _draw_y, _scale, _scale, 0, c_white, 1);
