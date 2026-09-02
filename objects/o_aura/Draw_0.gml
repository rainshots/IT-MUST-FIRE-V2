// White aura art accepts a per-effect tint; a subtle ellipse keeps the effect readable without art.
var _pulse_scale = 1 + (sin(current_time * aura_pulse_speed) * aura_pulse_amount);
var _draw_scale_x = aura_scale_x * _pulse_scale;
var _draw_scale_y = aura_scale_y * _pulse_scale;

if (sprite_exists(aura_sprite))
{
	draw_sprite_ext(
		aura_sprite,
		image_index,
		x,
		y,
		_draw_scale_x,
		_draw_scale_y,
		0,
		aura_color,
		aura_alpha
	);
}
else
{
	var _half_width = BALANCE_AURA_FALLBACK_WIDTH * 0.5 * _draw_scale_x;
	var _half_height = BALANCE_AURA_FALLBACK_HEIGHT * 0.5 * _draw_scale_y;

	draw_set_color(aura_color);
	draw_set_alpha(aura_alpha * 0.45);
	draw_ellipse(x - _half_width, y - _half_height, x + _half_width, y + _half_height, false);
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);
