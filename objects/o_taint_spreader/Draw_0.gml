// Draw the affected area behind the object on hover and during activation.
var _is_hovered = taint_spreader_is_hovered();
var _effect_alpha_scale = 1;

if (_is_hovered)
{
	draw_set_alpha(BALANCE_TAINT_SPREADER_HOVER_FILL_ALPHA);
	draw_set_color(COLOR_TAINT_SPREADER_RADIUS);
	draw_circle(x, y, corruption_spread_radius, false);

	draw_set_alpha(BALANCE_TAINT_SPREADER_HOVER_OUTLINE_ALPHA);
	draw_circle(x, y, corruption_spread_radius, true);
}
else if (is_activated)
{
	_effect_alpha_scale = clamp(activation_effect_timer / activation_effect_duration, 0, 1);

	draw_set_alpha(BALANCE_TAINT_SPREADER_EXPLOSION_FILL_ALPHA * _effect_alpha_scale);
	draw_set_color(COLOR_TAINT_SPREADER_RADIUS);
	draw_circle(x, y, corruption_spread_radius, false);

	draw_set_alpha(BALANCE_TAINT_SPREADER_HOVER_OUTLINE_ALPHA * _effect_alpha_scale);
	draw_circle(x, y, corruption_spread_radius, true);
}

draw_set_color(c_white);
draw_set_alpha(_effect_alpha_scale);
draw_self();
draw_set_alpha(1);

// Show the object name directly above its sprite while hovered.
if (_is_hovered)
{
	var _previous_font = draw_get_font();

	if (variable_global_exists("ui_font"))
	{
		draw_set_font(global.ui_font);
	}

	var _label_x = x;
	var _label_y = bbox_top - BALANCE_TAINT_SPREADER_LABEL_OFFSET_Y;
	var _label_width = string_width(display_name) + (BALANCE_TAINT_SPREADER_LABEL_PADDING_X * 2);
	var _label_height = string_height(display_name) + (BALANCE_TAINT_SPREADER_LABEL_PADDING_Y * 2);

	draw_set_alpha(BALANCE_TAINT_SPREADER_LABEL_BACKGROUND_ALPHA);
	draw_set_color(COLOR_HUD_BACKGROUND);
	draw_roundrect(
		_label_x - (_label_width * 0.5),
		_label_y - (_label_height * 0.5),
		_label_x + (_label_width * 0.5),
		_label_y + (_label_height * 0.5),
		false
	);

	draw_set_alpha(1);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_set_color(COLOR_TAINT_SPREADER_RADIUS);
	draw_text(_label_x, _label_y, display_name);
	draw_set_font(_previous_font);
}

// Restore the project draw defaults.
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);
