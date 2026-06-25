// Draw the vein and its remaining ihor bar.
draw_set_alpha(1);
draw_self();

var _bar_x = x - (bar_width * 0.5);
var _bar_y = bbox_bottom + bar_offset_y;
var _bar_progress = clamp(ihor_remaining / max(1, ihor_capacity), 0, 1);

draw_set_alpha(bar_background_alpha);
draw_set_color(c_black);
draw_rectangle(_bar_x, _bar_y, _bar_x + bar_width, _bar_y + bar_height, false);

draw_set_alpha(1);
draw_set_color(COLOR_HUD_IHOR);
draw_rectangle(_bar_x, _bar_y, _bar_x + (bar_width * _bar_progress), _bar_y + bar_height, false);

draw_set_color(c_white);
draw_set_alpha(1);
