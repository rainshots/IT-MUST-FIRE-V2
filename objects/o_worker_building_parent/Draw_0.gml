// A future child supplies its sprite; this parent has no production-building appearance.
var _bounds = building_bounds_get(id, x, y);
if (sprite_index != -1)
{
	var _scale = min((_bounds.right - _bounds.left) / sprite_get_width(sprite_index), (_bounds.bottom - _bounds.top) / sprite_get_height(sprite_index));
	var _draw_x = x + (sprite_get_xoffset(sprite_index) - sprite_get_width(sprite_index) * 0.5) * _scale;
	var _draw_y = y + (sprite_get_yoffset(sprite_index) - sprite_get_height(sprite_index) * 0.5) * _scale;
	draw_sprite_ext(sprite_index, image_index, _draw_x, _draw_y, _scale, _scale, image_angle, image_blend, image_alpha);
}

if (!is_grid_trash && building_label != "Building")
{
	draw_set_color(COLOR_HUD_TEXT);draw_set_halign(fa_center);draw_set_valign(fa_bottom);
	draw_text_transformed(x,_bounds.top,building_label+"\n"+string(array_length(worker_cultists))+" / "+string(worker_max)+" workers",0.5,0.5,0);
	draw_set_halign(fa_left);draw_set_valign(fa_top);draw_set_color(c_white);
}

// Production children and the Furnace share actual progress and blocked-state feedback.
building_work_progress_draw();
