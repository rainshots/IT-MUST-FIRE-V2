// Draw unit sprite.
draw_self();

// Draw unit health bar.
var _bar_x = x - (bar_width * 0.5);
var _bar_y = y - bar_offset_y;
var _hp_progress = clamp(hp / max_hp, 0, 1);

draw_set_alpha(0.75);
draw_set_color(c_black);
draw_rectangle(_bar_x, _bar_y, _bar_x + bar_width, _bar_y + bar_height, false);

draw_set_alpha(1);
draw_set_color(c_lime);
draw_rectangle(_bar_x, _bar_y, _bar_x + (bar_width * _hp_progress), _bar_y + bar_height, false);

// Restore default draw state.
draw_set_color(c_white);
draw_set_alpha(1);
