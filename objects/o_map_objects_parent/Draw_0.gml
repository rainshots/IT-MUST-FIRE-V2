// Draw the map object sprite.
draw_self();

// Draw health and corruption bars above the object.
var _bar_x = x - (bar_width * 0.5);
var _health_bar_y = y - bar_offset_y;
var _corruption_bar_y = _health_bar_y + bar_height + bar_gap;
var _hp_progress = clamp(hp / max_hp, 0, 1);
var _corruption_progress = clamp(corruption / max_corruption, 0, 1);

draw_set_alpha(0.75);
draw_set_color(c_black);
draw_rectangle(_bar_x, _health_bar_y, _bar_x + bar_width, _health_bar_y + bar_height, false);
draw_rectangle(_bar_x, _corruption_bar_y, _bar_x + bar_width, _corruption_bar_y + bar_height, false);

draw_set_alpha(1);
draw_set_color(c_lime);
draw_rectangle(_bar_x, _health_bar_y, _bar_x + (bar_width * _hp_progress), _health_bar_y + bar_height, false);

draw_set_color(COLOR_PROJECTILE_CORRUPTION);
draw_rectangle(_bar_x, _corruption_bar_y, _bar_x + (bar_width * _corruption_progress), _corruption_bar_y + bar_height, false);

// Restore default draw state.
draw_set_color(c_white);
draw_set_alpha(1);
