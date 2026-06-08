// Draw cannon sprite.
draw_self();

// Highlight the cannon when a dragged unit can be assigned here.
if (variable_global_exists("cultist_assignment_preview_building")
	&& global.cultist_assignment_preview_building == id)
{
	var _preview_padding = 8;

	draw_set_alpha(0.22);
	draw_set_color(COLOR_PROJECTILE_SUMMON);
	draw_rectangle(
		bbox_left - _preview_padding,
		bbox_top - _preview_padding,
		bbox_right + _preview_padding,
		bbox_bottom + _preview_padding,
		false
	);
}

// Draw cannon health bar above the sprite.
var _bar_x = x - (bar_width * 0.5);
var _bar_y = y - bar_offset_y;
var _hp_progress = clamp(hp / max_hp, 0, 1);

draw_set_alpha(0.75);
draw_set_color(COLOR_HUD_BACKGROUND);
draw_rectangle(_bar_x, _bar_y, _bar_x + bar_width, _bar_y + bar_height, false);

draw_set_alpha(1);
draw_set_color(COLOR_HEALTH_BAR);
draw_rectangle(_bar_x, _bar_y, _bar_x + (bar_width * _hp_progress), _bar_y + bar_height, false);

// Restore default draw state.
draw_set_color(c_white);
draw_set_alpha(1);
