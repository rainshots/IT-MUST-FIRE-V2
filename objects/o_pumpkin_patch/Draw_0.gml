var _half = placement_size * 0.5;
draw_set_color(COLOR_PUMPKIN_PATCH);
draw_rectangle(x - _half, y - _half, x + _half, y + _half, true);
var _sprite = s_pumpkin_mine;
var _scale = BALANCE_PUMPKIN_DRAW_SIZE / max(sprite_get_width(_sprite), sprite_get_height(_sprite));
for (var _i = 0; _i < array_length(mines); ++_i)
{
	var _mine_x = x + mines[_i].x + (sprite_get_xoffset(_sprite) - sprite_get_width(_sprite) * 0.5) * _scale;
	var _mine_y = y + mines[_i].y + (sprite_get_yoffset(_sprite) - sprite_get_height(_sprite) * 0.5) * _scale;
	draw_sprite_ext(_sprite, 0, _mine_x, _mine_y, _scale, _scale, 0, c_white, 1);
}
draw_set_color(COLOR_HUD_TEXT);
draw_set_halign(fa_center);
draw_set_valign(fa_bottom);
draw_text_transformed(x, y - _half, building_label + " " + string(array_length(mines)) + "/" + string(BALANCE_PUMPKIN_MAX_MINES), 0.5, 0.5, 0);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
building_work_progress_draw();
