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

// Show Goblins Pit capacity and missing resource state above the building.
if (object_index == o_goblins_pit)
{
	var _goblin_count = goblins_pit_goblin_count_get();
	var _goblin_limit = goblins_pit_goblin_limit_get();
	var _status_text = "Goblins " + string(_goblin_count) + "/" + string(_goblin_limit);
	var _resource_text = "";
	var _status_color = _goblin_count >= _goblin_limit ? COLOR_STATUS_NEGATIVE_RED : COLOR_HUD_TEXT;

	if (missing_work_resource != noone)
	{
		_resource_text = "Need " + string(missing_work_resource_amount) + " " + missing_work_resource_name;
		_status_color = missing_work_resource_color;
	}

	var _status_x = x;
	var _status_y = y - goblin_status_offset_y;
	var _status_text_width = max(string_width(_status_text), string_width(_resource_text));
	var _status_line_count = 1 + (missing_work_resource != noone);
	var _status_width = _status_text_width + (building_warning_padding_x * 2);
	var _status_height = (goblin_status_line_height * _status_line_count) + (building_warning_padding_y * 2);
	var _status_left = _status_x - (_status_width * 0.5);
	var _status_top = _status_y - (_status_height * 0.5);

	draw_set_alpha(building_warning_background_alpha);
	draw_set_color(COLOR_HUD_BACKGROUND);
	draw_roundrect(
		_status_left,
		_status_top,
		_status_left + _status_width,
		_status_top + _status_height,
		false
	);

	draw_set_alpha(1);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_set_color(_status_color);
	draw_text(_status_x, _status_top + building_warning_padding_y + (goblin_status_line_height * 0.5), _status_text);

	if (_resource_text != "")
	{
		draw_text(_status_x, _status_top + building_warning_padding_y + (goblin_status_line_height * 1.5), _resource_text);
	}
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
	var _reserve_progress = clamp(ritual_circle_daily_exp_remaining / max(1, ritual_circle_daily_exp_limit_get()), 0, 1);

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

// Draw summoning progress for paid resource cycles.
if (summon_unit_object != noone)
{
	if (summon_has_paid_cost)
	{
		var _bar_x = x - (production_bar_width * 0.5);
		var _bar_y = y - production_bar_offset_y;
		var _progress = clamp(summon_progress, 0, 1);
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

		var _cost_count = array_length(summon_resource_costs);

		for (var _cost_index = 0; _cost_index < _cost_count; ++_cost_index)
		{
			var _cost_data = summon_resource_costs[_cost_index];

			if (sprite_exists(_cost_data.icon))
			{
				draw_sprite_stretched_ext(
					_cost_data.icon,
					0,
					_icon_x,
					_icon_y - (production_icon_size * 0.5),
					production_icon_size,
					production_icon_size,
					c_white,
					1
				);

				_icon_x += production_icon_size + 2;
			}
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
