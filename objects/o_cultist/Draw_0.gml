// Draw the regular cultist and a compact health bar.
draw_self();

var _bar_width = BALANCE_EVENT_CULTIST_HEALTH_BAR_WIDTH;
var _bar_height = BALANCE_EVENT_CULTIST_HEALTH_BAR_HEIGHT;
var _bar_x = x - (_bar_width * 0.5);
var _bar_y = bbox_bottom + BALANCE_EVENT_CULTIST_HEALTH_BAR_OFFSET_Y;
var _health_progress = clamp(hp / max(1, max_hp), 0, 1);

draw_set_color(c_black);
draw_rectangle(_bar_x, _bar_y, _bar_x + _bar_width, _bar_y + _bar_height, false);
draw_set_color(COLOR_HEALTH_BAR);
draw_rectangle(_bar_x, _bar_y, _bar_x + (_bar_width * _health_progress), _bar_y + _bar_height, false);

draw_set_halign(fa_center);
draw_set_valign(fa_bottom);
draw_set_color(c_white);
draw_text(x, bbox_top, cultist_name);

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);
