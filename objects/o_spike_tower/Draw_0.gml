// Center the art in its placement footprint regardless of the sprite origin.
var _scale = placement_size / max(sprite_get_width(sprite_index), sprite_get_height(sprite_index));
var _draw_x = x + (sprite_get_xoffset(sprite_index) - sprite_get_width(sprite_index) * 0.5) * _scale;
var _draw_y = y + (sprite_get_yoffset(sprite_index) - sprite_get_height(sprite_index) * 0.5) * _scale;
draw_sprite_ext(sprite_index, 0, _draw_x, _draw_y, _scale, _scale, 0, image_blend, image_alpha);
draw_set_color(COLOR_HUD_TEXT);
draw_set_halign(fa_center);
draw_set_valign(fa_bottom);
draw_text_transformed(x, y - placement_size * 0.5, building_label, 0.5, 0.5, 0);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
building_work_progress_draw();
