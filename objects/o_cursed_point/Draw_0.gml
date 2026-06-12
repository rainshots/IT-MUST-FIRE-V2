// Draw the point without inherited health bars because this is not a combat target.
draw_self();

if (!is_captured || structure_selection_open)
{
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
	draw_set_alpha(1);
	exit;
}

// Draw the pulsing world button above the captured point.
var _button_rect = cursed_point_summon_button_rect_get();
var _pulse = 1 + (sin(current_time * summon_button_pulse_speed) * summon_button_pulse_scale);
var _button_center_x = _button_rect[0] + (_button_rect[2] * 0.5);
var _button_center_y = _button_rect[1] + (_button_rect[3] * 0.5);
var _draw_width = _button_rect[2] * _pulse;
var _draw_height = _button_rect[3] * _pulse;
var _draw_x = _button_center_x - (_draw_width * 0.5);
var _draw_y = _button_center_y - (_draw_height * 0.5);
var _button_color = summon_button_hovered ? COLOR_PROJECTILE_SUMMON : COLOR_HUD_TEXT;

draw_set_alpha(0.9);
draw_set_color(COLOR_HUD_BACKGROUND);
draw_rectangle(_draw_x, _draw_y, _draw_x + _draw_width, _draw_y + _draw_height, false);

draw_set_alpha(1);
draw_set_color(_button_color);
draw_rectangle(_draw_x, _draw_y, _draw_x + _draw_width, _draw_y + _draw_height, true);

draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(COLOR_HUD_TEXT);
draw_text_transformed(_button_center_x, _button_center_y, summon_button_text, _pulse, _pulse, 0);

// Restore default draw state.
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);
