if (!instance_exists(payload)) exit;
if (payload.sprite_index != -1) draw_sprite_ext(payload.sprite_index, 0, x, y, payload.image_xscale, payload.image_yscale, 0, c_white, 1);
else { draw_set_color(COLOR_CANNON_NORMAL); draw_circle(x, y, 16, false); draw_set_color(c_white); }
