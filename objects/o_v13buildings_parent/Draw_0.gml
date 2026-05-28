// Draw the building sprite first because this parent owns the draw event.
draw_self();

// Highlight the building that will receive the dragged cultist if released.
if (variable_global_exists("cultist_assignment_preview_building")
	&& global.cultist_assignment_preview_building == id)
{
	draw_set_alpha(assignment_preview_alpha);
	draw_set_color(production_resource_color);
	draw_rectangle(
		bbox_left - assignment_preview_padding,
		bbox_top - assignment_preview_padding,
		bbox_right + assignment_preview_padding,
		bbox_bottom + assignment_preview_padding,
		false
	);

	draw_set_alpha(assignment_preview_outline_alpha);
	draw_rectangle(
		bbox_left - assignment_preview_padding,
		bbox_top - assignment_preview_padding,
		bbox_right + assignment_preview_padding,
		bbox_bottom + assignment_preview_padding,
		true
	);
}

if (production_resource == noone)
{
	exit;
}

// Draw production progress above resource buildings.
var _bar_x = x - (production_bar_width * 0.5);
var _bar_y = y - production_bar_offset_y;
var _progress = clamp(production_progress, 0, 1);
var _multiplier_text = string_format(production_speed_multiplier, 0, 1) + "x";
var _multiplier_x = _bar_x - production_multiplier_gap - string_width(_multiplier_text);
var _multiplier_y = _bar_y + (production_bar_height * 0.5);
var _icon_x = _bar_x + production_bar_width + production_icon_gap;
var _icon_y = _bar_y + (production_bar_height * 0.5);

draw_set_alpha(production_bar_background_alpha);
draw_set_color(COLOR_HUD_BACKGROUND);
draw_rectangle(_bar_x, _bar_y, _bar_x + production_bar_width, _bar_y + production_bar_height, false);

draw_set_alpha(1);
draw_set_color(production_resource_color);
draw_rectangle(_bar_x, _bar_y, _bar_x + (production_bar_width * _progress), _bar_y + production_bar_height, false);

draw_set_alpha(production_bar_outline_alpha);
draw_set_color(COLOR_HUD_TEXT);
draw_rectangle(_bar_x, _bar_y, _bar_x + production_bar_width, _bar_y + production_bar_height, true);

draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_middle);
draw_set_color(production_bonus_stat_color);
draw_text(_multiplier_x, _multiplier_y, _multiplier_text);

if (sprite_exists(production_resource_icon))
{
	draw_sprite_stretched_ext(
		production_resource_icon,
		0,
		_icon_x,
		_icon_y - (production_icon_size * 0.5),
		production_icon_size,
		production_icon_size,
		c_white,
		1
	);
}

// Restore default draw state.
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);
