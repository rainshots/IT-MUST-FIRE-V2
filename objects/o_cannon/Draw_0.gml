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

// Show the upgrade key when the cannon is hovered during regular gameplay.
if (global.focus_window == FOCUS_WINDOW.NOONE
	&& (!variable_global_exists("dragged_cultist") || !instance_exists(global.dragged_cultist))
	&& mouse_x >= bbox_left
	&& mouse_x <= bbox_right
	&& mouse_y >= bbox_top
	&& mouse_y <= bbox_bottom)
{
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	var _prompt_width = string_width(upgrade_prompt_text) + (upgrade_prompt_padding_x * 2);
	var _prompt_height = string_height(upgrade_prompt_text) + (upgrade_prompt_padding_y * 2);
	var _prompt_x = x;
	var _prompt_y = y - upgrade_prompt_offset_y;

	draw_set_alpha(upgrade_prompt_background_alpha);
	draw_set_color(c_black);
	draw_rectangle(
		_prompt_x - (_prompt_width * 0.5),
		_prompt_y - (_prompt_height * 0.5),
		_prompt_x + (_prompt_width * 0.5),
		_prompt_y + (_prompt_height * 0.5),
		false
	);

	draw_set_alpha(1);
	draw_set_color(c_white);
	draw_text(_prompt_x, _prompt_y, upgrade_prompt_text);
}

// Restore default draw state.
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);
