// A translucent sand ring and rotating inner rings mark the active field.
draw_set_color(COLOR_QUICKSAND);
draw_set_alpha(0.12);
draw_circle(x, y, effect_radius, false);
draw_set_alpha(0.65);
draw_circle(x, y, effect_radius, true);
var _ring_count = 3;
for (var _ring_index = 0; _ring_index < _ring_count; ++_ring_index)
{
	var _phase = frac(swirl_angle / 90 + _ring_index / _ring_count);
	draw_circle(x, y, effect_radius * (1 - _phase), true);
}
draw_set_color(c_white);
draw_set_alpha(1);
