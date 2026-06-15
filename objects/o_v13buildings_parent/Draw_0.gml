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

var _building_is_hovered = global.focus_window == FOCUS_WINDOW.NOONE
	&& !global.pause
	&& building_is_mouse_hovered();

// Show upgrade prompt while the cursor hovers upgradeable buildings.
if (_building_is_hovered && building_has_upgrades)
{
	var _prompt_width = string_width(upgrade_prompt_text) + (upgrade_prompt_padding_x * 2);
	var _prompt_height = string_height(upgrade_prompt_text) + (upgrade_prompt_padding_y * 2);
	var _prompt_x = x - (_prompt_width * 0.5);
	var _prompt_y = bbox_bottom + upgrade_prompt_offset_y;

	draw_set_alpha(upgrade_prompt_background_alpha);
	draw_set_color(COLOR_HUD_BACKGROUND);
	draw_rectangle(_prompt_x, _prompt_y, _prompt_x + _prompt_width, _prompt_y + _prompt_height, false);

	draw_set_alpha(1);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_set_color(COLOR_HUD_IRON);
	draw_text(x, _prompt_y + (_prompt_height * 0.5), upgrade_prompt_text);
}

// Show demolition prompt under base buildings.
if (_building_is_hovered)
{
	var _demolish_prompt_width = string_width(demolish_prompt_text) + (demolish_prompt_padding_x * 2);
	var _demolish_prompt_height = string_height(demolish_prompt_text) + (demolish_prompt_padding_y * 2);
	var _demolish_prompt_x = x - (_demolish_prompt_width * 0.5);
	var _demolish_prompt_y = bbox_bottom + demolish_prompt_offset_y;

	draw_set_alpha(demolish_prompt_background_alpha);
	draw_set_color(COLOR_HUD_BACKGROUND);
	draw_rectangle(
		_demolish_prompt_x,
		_demolish_prompt_y,
		_demolish_prompt_x + _demolish_prompt_width,
		_demolish_prompt_y + _demolish_prompt_height,
		false
	);

	draw_set_alpha(1);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_set_color(COLOR_STATUS_NEGATIVE_RED);
	draw_text(x, _demolish_prompt_y + (_demolish_prompt_height * 0.5), demolish_prompt_text);
}

// Draw building warnings above the production UI.
if (building_warning_timer > 0 && building_warning_text != "")
{
	var _warning_alpha = clamp(building_warning_timer / max(1, building_warning_time), 0, 1);
	var _warning_x = x;
	var _warning_y = y - building_warning_offset_y;
	var _warning_width = string_width(building_warning_text) + (building_warning_padding_x * 2);
	var _warning_height = string_height(building_warning_text) + (building_warning_padding_y * 2);
	var _warning_left = _warning_x - (_warning_width * 0.5);
	var _warning_top = _warning_y - (_warning_height * 0.5);

	draw_set_alpha(building_warning_background_alpha * _warning_alpha);
	draw_set_color(COLOR_HUD_BACKGROUND);
	draw_roundrect(
		_warning_left,
		_warning_top,
		_warning_left + _warning_width,
		_warning_top + _warning_height,
		false
	);

	draw_set_alpha(_warning_alpha);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_set_color(building_warning_color);
	draw_text(_warning_x, _warning_y, building_warning_text);
}

// Draw remaining paid healing for the current Flesh chunk.
if (object_index == o_meat_bath)
{
	if (meat_bath_heal_pool > 0)
	{
		var _bar_x = x - (production_bar_width * 0.5);
		var _bar_y = y - production_bar_offset_y;
		var _progress = clamp(meat_bath_heal_pool / BALANCE_MEAT_BATH_FLESH_HEAL_AMOUNT, 0, 1);
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
	}

	// Restore default draw state.
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
	draw_set_alpha(1);
	exit;
}

// Draw remaining stored XP for the current training chunk.
if (object_index == o_ritual_circle)
{
	var _bar_x = x - (production_bar_width * 0.5);
	var _bar_y = y - production_bar_offset_y;

	if (ritual_circle_exp_pool > 0)
	{
		var _progress = clamp(ritual_circle_exp_pool / max(1, ritual_circle_exp_pool_amount), 0, 1);

		draw_set_alpha(production_bar_background_alpha);
		draw_set_color(COLOR_HUD_BACKGROUND);
		draw_rectangle(_bar_x, _bar_y, _bar_x + production_bar_width, _bar_y + production_bar_height, false);

		draw_set_alpha(1);
		draw_set_color(production_resource_color);
		draw_rectangle(_bar_x, _bar_y, _bar_x + (production_bar_width * _progress), _bar_y + production_bar_height, false);

		draw_set_alpha(production_bar_outline_alpha);
		draw_set_color(COLOR_HUD_TEXT);
		draw_rectangle(_bar_x, _bar_y, _bar_x + production_bar_width, _bar_y + production_bar_height, true);
	}

	var _reserve_bar_height = 3;
	var _reserve_bar_gap = 3;
	var _reserve_bar_y = _bar_y + production_bar_height + _reserve_bar_gap;
	var _reserve_progress = clamp(ritual_circle_daily_exp_remaining / max(1, BALANCE_RITUAL_CIRCLE_DAILY_EXP_LIMIT), 0, 1);

	draw_set_alpha(production_bar_background_alpha);
	draw_set_color(COLOR_HUD_BACKGROUND);
	draw_rectangle(_bar_x, _reserve_bar_y, _bar_x + production_bar_width, _reserve_bar_y + _reserve_bar_height, false);

	draw_set_alpha(1);
	draw_set_color(COLOR_CULTIST_SPIRIT);
	draw_rectangle(_bar_x, _reserve_bar_y, _bar_x + (production_bar_width * _reserve_progress), _reserve_bar_y + _reserve_bar_height, false);

	// Restore default draw state.
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
	draw_set_alpha(1);
	exit;
}

// Draw remaining paid repair for the current Iron chunk.
if (object_index == o_workshop)
{
	var _bar_x = x - (production_bar_width * 0.5);
	var _bar_y = y - production_bar_offset_y;
	var _multiplier_text = string_format(production_speed_multiplier, 0, 1) + "x";
	var _multiplier_x = _bar_x - production_multiplier_gap - string_width(_multiplier_text);
	var _multiplier_y = _bar_y + (production_bar_height * 0.5);

	draw_set_alpha(1);
	draw_set_halign(fa_left);
	draw_set_valign(fa_middle);
	draw_set_color(production_bonus_stat_color);
	draw_text(_multiplier_x, _multiplier_y, _multiplier_text);

	if (workshop_repair_pool > 0)
	{
		var _progress = clamp(workshop_repair_pool / BALANCE_WORKSHOP_IRON_REPAIR_AMOUNT, 0, 1);
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
	}

	// Restore default draw state.
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
	draw_set_alpha(1);
	exit;
}

// Draw summoning progress for paid Soul cycles.
if (summon_unit_object != noone)
{
	if (summon_has_paid_cost)
	{
		var _bar_x = x - (production_bar_width * 0.5);
		var _bar_y = y - production_bar_offset_y;
		var _progress = clamp(summon_progress, 0, 1);
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
	}

	// Restore default draw state.
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
	draw_set_alpha(1);
	exit;
}

if (production_resource == noone)
{
	// Restore default draw state.
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
	draw_set_alpha(1);
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
