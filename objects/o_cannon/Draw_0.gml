// Draw cannon sprite.
var _cannon_alpha = 1;

if (cannon_has_worker_behind_sprite())
{
	_cannon_alpha = hidden_worker_alpha;
}

draw_set_alpha(_cannon_alpha);
draw_self();
draw_set_alpha(1);

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

// Remind the player to assign corpse haulers when Feast fuel is waiting.
if (cannon_should_show_hauler_prompt())
{
	var _shake_interval = max(0.01, hauler_prompt_shake_interval) * 1000;
	var _shake_time = max(0, hauler_prompt_shake_time) * 1000;
	var _shake_phase = current_time mod _shake_interval;
	var _shake_x = 0;
	var _shake_y = 0;

	if (_shake_phase <= _shake_time)
	{
		_shake_x = random_range(-hauler_prompt_shake_strength, hauler_prompt_shake_strength);
		_shake_y = random_range(-hauler_prompt_shake_strength, hauler_prompt_shake_strength);
	}

	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);

	var _prompt_x = x + _shake_x;
	var _prompt_y = y + hauler_prompt_offset_y + _shake_y;
	var _prompt_width = string_width(hauler_prompt_text) + (hauler_prompt_padding_x * 2);
	var _prompt_height = string_height(hauler_prompt_text) + (hauler_prompt_padding_y * 2);

	draw_set_alpha(hauler_prompt_background_alpha);
	draw_set_color(COLOR_HUD_BACKGROUND);
	draw_rectangle(
		_prompt_x - (_prompt_width * 0.5),
		_prompt_y - (_prompt_height * 0.5),
		_prompt_x + (_prompt_width * 0.5),
		_prompt_y + (_prompt_height * 0.5),
		false
	);

	draw_set_alpha(1);
	draw_set_color(COLOR_STATUS_NEGATIVE_RED);
	draw_text(_prompt_x, _prompt_y, hauler_prompt_text);
}

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
