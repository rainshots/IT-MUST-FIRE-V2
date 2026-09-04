if (variable_global_exists("blood_moon_reward_popup_active")
	&& global.blood_moon_reward_popup_active)
{
	exit;
}

// Draw global resources in the right HUD sidebar.
if (!variable_global_exists("resources"))
{
	exit;
}

// Draw the Cannon Satisfaction details before the regular HUD visibility check.
if (global.focus_window == FOCUS_WINDOW.CANNON_SATISFACTION)
{
	cannon_satisfaction_window_draw();
	exit;
}

// Hide regular HUD while modal windows are visible, but keep projectile choices during aiming.
var _tutorial_popup_blocks_hud = variable_global_exists("tutorial_popup_active") && global.tutorial_popup_active;
var _projectile_queue_stays_visible = global.focus_window == FOCUS_WINDOW.TARGET_SELECTION
	&& !_tutorial_popup_blocks_hud;
var _regular_hud_is_visible = global.focus_window == FOCUS_WINDOW.NOONE
	&& !_tutorial_popup_blocks_hud;

if (!_regular_hud_is_visible && !_projectile_queue_stays_visible)
{
	exit;
}

if (_regular_hud_is_visible)
{
	var _sidebar_gui_width = display_get_gui_width();
	var _sidebar_gui_height = display_get_gui_height();
	var _sidebar_scale = clamp(_sidebar_gui_height / 1080, 0.6, 1);
	var _sidebar_width = hud_sidebar_width * _sidebar_scale;
	var _sidebar_x = _sidebar_gui_width - _sidebar_width;

	// Draw all squad cards in type order, followed by the shared empty slots.
	if (variable_global_exists("squads") && variable_global_exists("squad_limit"))
	{
		var _squad_card_width = 112 * _sidebar_scale;
		var _squad_card_height = 145 * _sidebar_scale;
		var _squad_card_gap = 19 * _sidebar_scale;
		var _squad_card_x = 53 * _sidebar_scale;
		var _squad_card_y = 58 * _sidebar_scale;
		var _squad_type_y = 38 * _sidebar_scale;
		var _squad_card_index = 0;

		// Every squad-card label is positioned from the horizontal center of its card.
		draw_set_halign(fa_center);
		draw_set_valign(fa_top);

		for (var _squad_type = SQUAD_TYPE.ARCHDEMON; _squad_type < SQUAD_TYPE.COUNT; ++_squad_type)
		{
			var _type_name = _squad_type == SQUAD_TYPE.ARCHDEMON ? "ARCHDEMON" : (_squad_type == SQUAD_TYPE.UNDEAD ? "UNDEAD SQUAD" : "DEMON SQUAD");

			for (var _squad_index = 0; _squad_index < array_length(global.squads); ++_squad_index)
			{
				var _squad = global.squads[_squad_index];
				if (_squad.squad_type != _squad_type) continue;
				var _card_x = _squad_card_x + (_squad_card_index * (_squad_card_width + _squad_card_gap));
				var _card_center_x = _card_x + (_squad_card_width * 0.5);
				var _hp_values = squad_total_hp_get(_squad);
				var _hp_progress = clamp(_hp_values[0] / _hp_values[1], 0, 1);
				var _squad_sprite = squad_icon_sprite_get(_squad);

				draw_set_alpha(1);
				draw_set_color(COLOR_SQUAD_CARD_BACKGROUND);
				draw_rectangle(_card_x, _squad_card_y, _card_x + _squad_card_width, _squad_card_y + _squad_card_height, false);
				draw_set_color(COLOR_SQUAD_CARD_BORDER);
				draw_rectangle(_card_x, _squad_card_y, _card_x + _squad_card_width, _squad_card_y + _squad_card_height, true);
				draw_set_halign(fa_center);
				draw_set_valign(fa_top);
				draw_set_color(COLOR_SQUAD_CARD_TYPE);
				draw_text_transformed(_card_center_x, _squad_type_y, _type_name, 0.55 * _sidebar_scale, 0.55 * _sidebar_scale, 0);

				if (sprite_exists(_squad_sprite))
				{
					var _sprite_size = max(1, max(sprite_get_width(_squad_sprite), sprite_get_height(_squad_sprite)));
					var _sprite_scale = (82 * _sidebar_scale) / _sprite_size;
					var _sprite_y = _squad_card_y + (78 * _sidebar_scale);

					if (array_length(_squad.unit_objects) > 1)
					{
						draw_sprite_ext(_squad_sprite, 0, _card_center_x - (24 * _sidebar_scale), _sprite_y + (8 * _sidebar_scale), _sprite_scale * 0.78, _sprite_scale * 0.78, 0, c_white, 0.5);
						draw_sprite_ext(_squad_sprite, 0, _card_center_x + (24 * _sidebar_scale), _sprite_y + (8 * _sidebar_scale), _sprite_scale * 0.78, _sprite_scale * 0.78, 0, c_white, 0.5);
					}

					draw_sprite_ext(_squad_sprite, 0, _card_center_x, _sprite_y, _sprite_scale, _sprite_scale, 0, c_white, 1);
				}

				draw_set_color(COLOR_SQUAD_CARD_TEXT);
				draw_text_transformed(_card_center_x, _squad_card_y + (109 * _sidebar_scale), squad_name_display_get(_squad.name), 0.75 * _sidebar_scale, 0.75 * _sidebar_scale, 0);
				var _hp_x = _card_x + (8 * _sidebar_scale);
				var _hp_y = _squad_card_y + (128 * _sidebar_scale);
				var _hp_width = _squad_card_width - (16 * _sidebar_scale);
				draw_set_color(COLOR_SQUAD_HP_BACKGROUND);
				draw_rectangle(_hp_x, _hp_y, _hp_x + _hp_width, _hp_y + (13 * _sidebar_scale), false);
				draw_set_color(COLOR_SQUAD_HP_FILL);
				draw_rectangle(_hp_x + (3 * _sidebar_scale), _hp_y + (3 * _sidebar_scale), _hp_x + (3 * _sidebar_scale) + ((_hp_width - (6 * _sidebar_scale)) * _hp_progress), _hp_y + (10 * _sidebar_scale), false);
				_squad_card_index++;
			}
		}

		// Recruitment cards reserve their slots before their squads are created at nightfall.
		var _pending_slot_count = squad_pending_event_count_get();

		for (var _pending_index = 0; _pending_index < _pending_slot_count; ++_pending_index)
		{
			var _pending_x = _squad_card_x + (_squad_card_index * (_squad_card_width + _squad_card_gap));
			draw_set_color(COLOR_SQUAD_CARD_BACKGROUND);
			draw_rectangle(_pending_x, _squad_card_y, _pending_x + _squad_card_width, _squad_card_y + _squad_card_height, false);
			draw_set_color(COLOR_PROJECTILE_SUMMON);
			draw_rectangle(_pending_x, _squad_card_y, _pending_x + _squad_card_width, _squad_card_y + _squad_card_height, true);
			draw_set_color(COLOR_SQUAD_CARD_TYPE);
			draw_text_transformed(_pending_x + (_squad_card_width * 0.5), _squad_type_y, "SQUAD", 0.55 * _sidebar_scale, 0.55 * _sidebar_scale, 0);
			draw_set_color(COLOR_PROJECTILE_SUMMON);
			draw_text_transformed(_pending_x + (_squad_card_width * 0.5), _squad_card_y + (109 * _sidebar_scale), "Pending", 0.75 * _sidebar_scale, 0.75 * _sidebar_scale, 0);
			_squad_card_index++;
		}

		var _empty_slot_count = max(0, global.squad_limit - squad_slot_occupied_count_get());

		for (var _empty_index = 0; _empty_index < _empty_slot_count; ++_empty_index)
		{
			var _empty_x = _squad_card_x + (_squad_card_index * (_squad_card_width + _squad_card_gap));
			draw_set_color(COLOR_SQUAD_CARD_BACKGROUND);
			draw_rectangle(_empty_x, _squad_card_y, _empty_x + _squad_card_width, _squad_card_y + _squad_card_height, false);
			draw_set_color(COLOR_SQUAD_CARD_BORDER);
			draw_rectangle(_empty_x, _squad_card_y, _empty_x + _squad_card_width, _squad_card_y + _squad_card_height, true);
			draw_set_color(COLOR_SQUAD_CARD_TYPE);
			draw_text_transformed(_empty_x + (_squad_card_width * 0.5), _squad_type_y, "SQUAD", 0.55 * _sidebar_scale, 0.55 * _sidebar_scale, 0);
			draw_set_color(COLOR_SQUAD_CARD_TEXT);
			draw_text_transformed(_empty_x + (_squad_card_width * 0.5), _squad_card_y + (109 * _sidebar_scale), "Empty", 0.75 * _sidebar_scale, 0.75 * _sidebar_scale, 0);
			_squad_card_index++;
		}

		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
	}

	// Draw the regular-cultist counter as a squad-style card below the roster.
	if (variable_global_exists("event_cultists") && variable_global_exists("cultist_limit"))
	{
		var _cultist_counter_x = cultist_counter_x * _sidebar_scale;
		var _cultist_counter_y = cultist_counter_y * _sidebar_scale;
		var _cultist_counter_width = cultist_counter_width * _sidebar_scale;
		var _cultist_counter_height = cultist_counter_height * _sidebar_scale;
		var _cultist_counter_icon_x = _cultist_counter_x + (cultist_counter_icon_x * _sidebar_scale);
		var _cultist_counter_icon_y = _cultist_counter_y + (cultist_counter_icon_y * _sidebar_scale);
		var _cultist_counter_count = day_event_cultist_count_get();
		var _cultist_counter_text = string(_cultist_counter_count) + "/" + string(global.cultist_limit);

		draw_set_alpha(1);
		draw_set_color(COLOR_SQUAD_CARD_BACKGROUND);
		draw_rectangle(
			_cultist_counter_x,
			_cultist_counter_y,
			_cultist_counter_x + _cultist_counter_width,
			_cultist_counter_y + _cultist_counter_height,
			false
		);

		// Draw a two-pixel frame to match squad cards in the design.
		draw_set_color(COLOR_SQUAD_CARD_BORDER);
		for (var _cultist_counter_border = 0; _cultist_counter_border < 2; ++_cultist_counter_border)
		{
			draw_rectangle(
				_cultist_counter_x + _cultist_counter_border,
				_cultist_counter_y + _cultist_counter_border,
				_cultist_counter_x + _cultist_counter_width - _cultist_counter_border,
				_cultist_counter_y + _cultist_counter_height - _cultist_counter_border,
				true
			);
		}

		if (sprite_exists(s_cultist_04))
		{
			var _cultist_counter_sprite_width = max(1, sprite_get_width(s_cultist_04));
			var _cultist_counter_sprite_height = max(1, sprite_get_height(s_cultist_04));
			var _cultist_counter_sprite_scale = (cultist_counter_icon_height * _sidebar_scale) / _cultist_counter_sprite_height;
			var _cultist_counter_sprite_x = _cultist_counter_icon_x
				+ ((sprite_get_xoffset(s_cultist_04) - (_cultist_counter_sprite_width * 0.5)) * _cultist_counter_sprite_scale);
			var _cultist_counter_sprite_y = _cultist_counter_icon_y
				+ ((sprite_get_yoffset(s_cultist_04) - (_cultist_counter_sprite_height * 0.5)) * _cultist_counter_sprite_scale);
			draw_sprite_ext(
				s_cultist_04,
				0,
				_cultist_counter_sprite_x,
				_cultist_counter_sprite_y,
				_cultist_counter_sprite_scale,
				_cultist_counter_sprite_scale,
				0,
				c_white,
				1
			);
		}

		draw_set_halign(fa_left);
		draw_set_valign(fa_middle);
		draw_set_color(COLOR_CULTIST_COUNTER_TEXT);
		draw_text(
			_cultist_counter_x + (cultist_counter_text_x * _sidebar_scale),
			_cultist_counter_icon_y,
			_cultist_counter_text
		);
	}

	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);

	var _resource_count = 0;

	for (var _resource_index = 0; _resource_index < _resource_count; ++_resource_index)
	{
		var _resource = resource_order[_resource_index];
		var _value = global.resources[_resource];
		var _value_text = string(_value);
		var _icon_x = _sidebar_x + ((resource_sidebar_first_icon_offset_x + (resource_sidebar_item_gap * _resource_index)) * _sidebar_scale);
		var _icon_y = resource_sidebar_y * _sidebar_scale;
		var _icon_sprite = resource_icon_sprites[_resource];
		var _icon_size = resource_sidebar_icon_size * _sidebar_scale;
		var _text_x = _icon_x + (resource_sidebar_value_offset_x * _sidebar_scale);
		var _text_y = _icon_y;

		if (_resource != RESOURCES.IHOR)
		{
			_value_text += "/" + string(BALANCE_PLAYER_RESOURCE_MAX);
		}

		// Draw resource icon, falling back to a color dot if the sprite is unavailable.
		draw_set_alpha(1);
		if (sprite_exists(_icon_sprite))
		{
			var _icon_left = _icon_x - (_icon_size * 0.5);
			var _icon_top = _icon_y - (_icon_size * 0.5);

			draw_sprite_stretched_ext(_icon_sprite, 0, _icon_left, _icon_top, _icon_size, _icon_size, c_white, 1);
		}
		else
		{
			draw_set_color(resource_colors[_resource]);
			draw_circle(_icon_x, _icon_y, resource_icon_radius * _sidebar_scale, false);
		}

		draw_set_color(COLOR_HUD_TEXT);
		draw_text(_text_x, _text_y, _value_text);
	}

	// Draw day phase inside the right HUD sidebar.
	if (false && variable_global_exists("day_phase"))
	{
		var _current_day = 1;
		var _day_progress = 0;

		if (instance_exists(o_game_controller))
		{
			var _game_controller = instance_find(o_game_controller, 0);

			if (variable_instance_exists(_game_controller, "night_attack_night_index"))
			{
				_current_day = max(1, _game_controller.night_attack_night_index);
			}
		}

		if (variable_global_exists("day_cycle_enabled") && global.day_cycle_enabled)
		{
			if (global.day_phase == DAY_PHASE.DAY)
			{
				var _game_speed_normal = variable_global_exists("game_speed_normal") ? global.game_speed_normal : room_speed;
				var _day_duration_frames = max(1, global.day_duration * _game_speed_normal);

				_day_progress = 1 - clamp(global.day_timer / _day_duration_frames, 0, 1);
			}
			else
			{
				_day_progress = 1;
			}
		}

		var _day_text_x = _sidebar_x + (day_phase_text_offset_x * _sidebar_scale);
		var _day_text_y = day_phase_text_y * _sidebar_scale;
		var _day_bar_x = _sidebar_x + (day_phase_bar_offset_x * _sidebar_scale);
		var _day_bar_y = day_phase_bar_y * _sidebar_scale;
		var _day_bar_width = day_phase_bar_width * _sidebar_scale;
		var _day_bar_height = day_phase_bar_height * _sidebar_scale;

		draw_set_halign(fa_center);
		draw_set_valign(fa_top);
		draw_set_alpha(1);
		draw_set_color(COLOR_HUD_TEXT);
		draw_text(_day_text_x, _day_text_y, "DAY " + string(_current_day));

		draw_set_alpha(0.8);
		draw_set_color(c_black);
		draw_rectangle(_day_bar_x, _day_bar_y, _day_bar_x + _day_bar_width, _day_bar_y + _day_bar_height, false);

		draw_set_alpha(1);
		draw_set_color(COLOR_HUD_DAY_PROGRESS);
		draw_rectangle(_day_bar_x, _day_bar_y, _day_bar_x + (_day_bar_width * _day_progress), _day_bar_y + _day_bar_height, false);
	}

	// Legacy unit counters and individual cultist cards are no longer part of the squad HUD.
	if (false)
	{
	// Draw player unit counts immediately left of the right sidebar.
	var _unit_counter_count = array_length(unit_counter_unit_objects);
	var _unit_counter_width = unit_counter_width * _sidebar_scale;
	var _unit_counter_row_height = unit_counter_row_height * _sidebar_scale;
	var _unit_counter_padding = unit_counter_padding * _sidebar_scale;
	var _unit_counter_row_gap = unit_counter_row_gap * _sidebar_scale;
	var _unit_counter_icon_size = unit_counter_icon_size * _sidebar_scale;
	var _unit_counter_height = (_unit_counter_padding * 2)
		+ (_unit_counter_row_height * _unit_counter_count)
		+ (_unit_counter_row_gap * max(0, _unit_counter_count - 1));
	var _unit_counter_x = _sidebar_x - _unit_counter_width - (unit_counter_gap_right * _sidebar_scale);
	var _unit_counter_y = unit_counter_y * _sidebar_scale;

	draw_set_alpha(unit_counter_background_alpha);
	draw_set_color(COLOR_HUD_BACKGROUND);
	draw_rectangle(
		_unit_counter_x,
		_unit_counter_y,
		_unit_counter_x + _unit_counter_width,
		_unit_counter_y + _unit_counter_height,
		false
	);

	for (var _unit_counter_index = 0; _unit_counter_index < _unit_counter_count; ++_unit_counter_index)
	{
		var _unit_object = unit_counter_unit_objects[_unit_counter_index];
		var _unit_sprite = unit_counter_unit_sprites[_unit_counter_index];
		var _unit_count = instance_number(_unit_object);
		var _unit_alpha = _unit_count > 0 ? 1 : unit_counter_empty_alpha;
		var _row_x = _unit_counter_x + _unit_counter_padding;
		var _row_y = _unit_counter_y + _unit_counter_padding
			+ ((_unit_counter_row_height + _unit_counter_row_gap) * _unit_counter_index);
		var _row_width = _unit_counter_width - (_unit_counter_padding * 2);
		var _icon_x = _row_x + (_unit_counter_icon_size * 0.5) + (4 * _sidebar_scale);
		var _icon_y = _row_y + (_unit_counter_row_height * 0.5);
		var _count_x = _row_x + _row_width - (8 * _sidebar_scale);

		draw_set_alpha(unit_counter_row_alpha * _unit_alpha);
		draw_set_color(c_black);
		draw_rectangle(_row_x, _row_y, _row_x + _row_width, _row_y + _unit_counter_row_height, false);

		draw_set_alpha(_unit_alpha);
		if (sprite_exists(_unit_sprite))
		{
			draw_sprite_stretched_ext(
				_unit_sprite,
				0,
				_icon_x - (_unit_counter_icon_size * 0.5),
				_icon_y - (_unit_counter_icon_size * 0.5),
				_unit_counter_icon_size,
				_unit_counter_icon_size,
				c_white,
				_unit_alpha
			);
		}
		else
		{
			draw_set_color(COLOR_HUD_TEXT);
			draw_circle(_icon_x, _icon_y, _unit_counter_icon_size * 0.34, false);
		}

		draw_set_halign(fa_right);
		draw_set_valign(fa_middle);
		draw_set_color(COLOR_HUD_TEXT);
		draw_text(_count_x, _icon_y, string(_unit_count));
	}

	// Draw compact cultist status cards while gameplay is unobstructed.
	if (variable_global_exists("archdemons")
		&& variable_global_exists("focus_window")
		&& global.focus_window == FOCUS_WINDOW.NOONE
		&& (!variable_global_exists("tutorial_popup_active") || !global.tutorial_popup_active))
	{
	var _cultist_card_gui_width = display_get_gui_width();
	var _cultist_card_gui_height = display_get_gui_height();
	var _cultist_card_scale = clamp(_cultist_card_gui_height / 1080, 0.6, 1);
	var _cultist_card_width = cultist_status_card_width * _cultist_card_scale;
	var _cultist_card_height = cultist_status_card_height * _cultist_card_scale;
	var _cultist_card_gap = cultist_status_card_gap * _cultist_card_scale;
	var _cultist_card_padding_x = cultist_status_card_padding_x * _cultist_card_scale;
	var _cultist_card_portrait_width = cultist_status_card_portrait_width * _cultist_card_scale;
	var _cultist_card_portrait_height = cultist_status_card_portrait_height * _cultist_card_scale;
	var _cultist_card_portrait_y = cultist_status_card_portrait_y * _cultist_card_scale;
	var _cultist_card_level_y = cultist_status_card_level_y * _cultist_card_scale;
	var _cultist_card_text_x = cultist_status_card_text_x * _cultist_card_scale;
	var _cultist_card_name_y = cultist_status_card_name_y * _cultist_card_scale;
	var _cultist_card_bar_x = cultist_status_card_bar_x * _cultist_card_scale;
	var _cultist_card_bar_y = cultist_status_card_bar_y * _cultist_card_scale;
	var _cultist_card_bar_width = cultist_status_card_bar_width * _cultist_card_scale;
	var _cultist_card_bar_height = cultist_status_card_bar_height * _cultist_card_scale;
	var _cultist_card_bar_gap = cultist_status_card_bar_gap * _cultist_card_scale;
	var _cultist_card_label_gap = cultist_status_card_label_gap * _cultist_card_scale;
	var _cultist_card_x = _sidebar_x + ((_sidebar_width - _cultist_card_width) * 0.5);
	var _cultist_card_count = array_length(global.archdemons);
	var _cultist_card_slot_count = cultist_status_card_slot_count;

	for (var _cultist_card_index = 0; _cultist_card_index < _cultist_card_slot_count; ++_cultist_card_index)
	{
		var _cultist = noone;

		if (_cultist_card_index < _cultist_card_count)
		{
			_cultist = global.archdemons[_cultist_card_index];
		}

		var _cultist_card_y = cultist_status_card_y
			+ ((_cultist_card_height + _cultist_card_gap) * _cultist_card_index);

		if (_cultist_card_y + _cultist_card_height > _cultist_card_gui_height - hud_margin_y)
		{
			break;
		}

		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		draw_set_alpha(cultist_status_card_background_alpha);
		draw_set_color(c_black);
		draw_rectangle(
			_cultist_card_x,
			_cultist_card_y,
			_cultist_card_x + _cultist_card_width,
			_cultist_card_y + _cultist_card_height,
			false
		);

		if (!instance_exists(_cultist))
		{
			continue;
		}

		var _portrait_sprite = _cultist.sprite_index;

		if (variable_instance_exists(_cultist, "cultist_sprite_index") && sprite_exists(_cultist.cultist_sprite_index))
		{
			_portrait_sprite = _cultist.cultist_sprite_index;
		}

		var _portrait_x = _cultist_card_x + _cultist_card_padding_x;
		var _portrait_y = _cultist_card_y + _cultist_card_portrait_y;

		draw_set_alpha(1);

		if (sprite_exists(_portrait_sprite))
		{
			draw_sprite_stretched_ext(
				_portrait_sprite,
				0,
				_portrait_x,
				_portrait_y,
				_cultist_card_portrait_width,
				_cultist_card_portrait_height,
				c_white,
				1
			);
		}
		else
		{
			draw_set_color(COLOR_CULTIST_BODY);
			draw_circle(
				_portrait_x + (_cultist_card_portrait_width * 0.5),
				_portrait_y + (_cultist_card_portrait_height * 0.5),
				_cultist_card_portrait_width * 0.35,
				false
			);
		}

		var _cultist_name = "Cultist";

		if (variable_instance_exists(_cultist, "cultist_name") && _cultist.cultist_name != "")
		{
			_cultist_name = _cultist.cultist_name;
		}

		if (string_length(_cultist_name) > cultist_status_card_name_max_characters)
		{
			_cultist_name = string_copy(_cultist_name, 1, cultist_status_card_name_max_characters - 3) + "...";
		}

		var _current_level = 1;

		if (variable_instance_exists(_cultist, "current_lvl"))
		{
			_current_level = _cultist.current_lvl;
		}

		draw_set_alpha(1);
		draw_set_color(COLOR_HUD_TEXT);
		draw_text(
			_cultist_card_x + _cultist_card_text_x,
			_cultist_card_y + _cultist_card_name_y,
			_cultist_name
		);
		draw_text(
			_portrait_x + 4,
			_cultist_card_y + _cultist_card_level_y,
			"LVL " + string(_current_level)
		);

		var _hp_progress = 0;
		var _exp_progress = 0;
		var _stamina_progress = 0;

		if (variable_instance_exists(_cultist, "hp") && variable_instance_exists(_cultist, "max_hp"))
		{
			_hp_progress = clamp(_cultist.hp / max(1, _cultist.max_hp), 0, 1);
		}

		if (variable_instance_exists(_cultist, "current_exp"))
		{
			var _required_exp = max(1, cultist_level_exp_required_get(_current_level));
			_exp_progress = clamp(_cultist.current_exp / _required_exp, 0, 1);
		}

		if (variable_instance_exists(_cultist, "stamina_amount"))
		{
			var _cultist_stamina_max = BALANCE_CULTIST_STAMINA_MAX;

			if (variable_instance_exists(_cultist, "stamina_max"))
			{
				_cultist_stamina_max = _cultist.stamina_max;
			}

			_stamina_progress = clamp(_cultist.stamina_amount / max(1, _cultist_stamina_max), 0, 1);
		}

		var _bar_labels = ["HP", "XP", "Stamina"];
		var _bar_values = [_hp_progress, _exp_progress, _stamina_progress];
		var _bar_colors = [
			cultist_status_card_hp_color,
			cultist_status_card_exp_color,
			cultist_status_card_stamina_color
		];
		var _bar_count = array_length(_bar_labels);

		for (var _bar_index = 0; _bar_index < _bar_count; ++_bar_index)
		{
			var _cultist_status_bar_x = _cultist_card_x + _cultist_card_bar_x;
			var _cultist_status_bar_y = _cultist_card_y + _cultist_card_bar_y
				+ ((_cultist_card_bar_height + _cultist_card_bar_gap) * _bar_index);

			draw_set_color(cultist_status_card_bar_background_color);
			draw_rectangle(
				_cultist_status_bar_x,
				_cultist_status_bar_y,
				_cultist_status_bar_x + _cultist_card_bar_width,
				_cultist_status_bar_y + _cultist_card_bar_height,
				false
			);

			draw_set_color(_bar_colors[_bar_index]);
			draw_rectangle(
				_cultist_status_bar_x,
				_cultist_status_bar_y,
				_cultist_status_bar_x + (_cultist_card_bar_width * _bar_values[_bar_index]),
				_cultist_status_bar_y + _cultist_card_bar_height,
				false
			);

			draw_set_color(cultist_status_card_label_color);
			draw_text(
				_cultist_status_bar_x + _cultist_card_bar_width + _cultist_card_label_gap,
				_cultist_status_bar_y,
				_bar_labels[_bar_index]
			);
		}
		}
	}
	}

}

// Draw minimap in the lower part of the right HUD sidebar.
if (instance_exists(o_cannon))
{
	var _minimap_gui_width = display_get_gui_width();
	var _minimap_gui_height = display_get_gui_height();
	var _minimap_scale = clamp(_minimap_gui_height / 1080, 0.6, 1);
	var _minimap_size = minimap_size * _minimap_scale;
	var _minimap_x = _minimap_gui_width - (minimap_margin_right * _minimap_scale) - _minimap_size;
	var _minimap_y = minimap_y * _minimap_scale;
	var _minimap_right = _minimap_x + _minimap_size;
	var _minimap_bottom = _minimap_y + _minimap_size;
	var _minimap_center_x = _minimap_x + (_minimap_size * 0.5);
	var _minimap_center_y = _minimap_y + (_minimap_size * 0.5);
	var _minimap_cannon = instance_find(o_cannon, 0);
	var _world_center_x = _minimap_cannon.x;
	var _world_center_y = _minimap_cannon.y;
	var _world_to_minimap_scale = (_minimap_size * 0.5) / max(1, minimap_world_radius);

	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_alpha(1);
	draw_set_color(COLOR_HUD_MINIMAP_BACKGROUND);
	draw_rectangle(_minimap_x, _minimap_y, _minimap_right, _minimap_bottom, false);

	// Draw cached tainted and saint ground cells under minimap units.
	if (instance_exists(o_corruption_grid))
	{
		var _corruption_grid_object = instance_find(o_corruption_grid, 0);
		var _corruption_cell_size = _corruption_grid_object.cell_size;
		var _ground_cell_count = array_length(minimap_ground_cell_xs);

		for (var _ground_cell_index = 0; _ground_cell_index < _ground_cell_count; ++_ground_cell_index)
		{
			var _ground_cell_x = minimap_ground_cell_xs[_ground_cell_index];
			var _ground_cell_y = minimap_ground_cell_ys[_ground_cell_index];
			var _ground_amount = minimap_ground_amounts[_ground_cell_index];
			var _ground_is_saint = minimap_ground_is_saint[_ground_cell_index];
			var _taint_left = _minimap_center_x + (((_ground_cell_x * _corruption_cell_size) - _world_center_x) * _world_to_minimap_scale);
			var _taint_top = _minimap_center_y + (((_ground_cell_y * _corruption_cell_size) - _world_center_y) * _world_to_minimap_scale);
			var _taint_right = _minimap_center_x + (((_ground_cell_x + 1) * _corruption_cell_size - _world_center_x) * _world_to_minimap_scale);
			var _taint_bottom = _minimap_center_y + (((_ground_cell_y + 1) * _corruption_cell_size - _world_center_y) * _world_to_minimap_scale);

			_taint_left = clamp(_taint_left, _minimap_x, _minimap_right);
			_taint_top = clamp(_taint_top, _minimap_y, _minimap_bottom);
			_taint_right = clamp(_taint_right, _minimap_x, _minimap_right);
			_taint_bottom = clamp(_taint_bottom, _minimap_y, _minimap_bottom);

			draw_set_color(_ground_is_saint ? COLOR_HUD_MINIMAP_SAINT : COLOR_HUD_MINIMAP_TAINT);
			draw_set_alpha(clamp(_ground_amount, 0.35, 1));
			draw_rectangle(_taint_left, _taint_top, _taint_right, _taint_bottom, false);
		}

		draw_set_alpha(1);
	}

	// Draw enemy units as red tactical markers.
	var _enemy_count = instance_number(o_enemy_units);
	var _enemy_size = minimap_enemy_size * _minimap_scale;
	var _enemy_half_size = _enemy_size * 0.5;

	for (var _enemy_index = 0; _enemy_index < _enemy_count; ++_enemy_index)
	{
		var _enemy = instance_find(o_enemy_units, _enemy_index);

		if (!instance_exists(_enemy)
			|| (variable_instance_exists(_enemy, "hp") && _enemy.hp <= 0))
		{
			continue;
		}

		var _enemy_map_x = _minimap_center_x + ((_enemy.x - _world_center_x) * _world_to_minimap_scale);
		var _enemy_map_y = _minimap_center_y + ((_enemy.y - _world_center_y) * _world_to_minimap_scale);

		_enemy_map_x = clamp(_enemy_map_x, _minimap_x + _enemy_half_size, _minimap_right - _enemy_half_size);
		_enemy_map_y = clamp(_enemy_map_y, _minimap_y + _enemy_half_size, _minimap_bottom - _enemy_half_size);

		draw_set_alpha(1);
		draw_set_color(COLOR_HUD_MINIMAP_ENEMY);
		draw_rectangle(
			_enemy_map_x - _enemy_half_size,
			_enemy_map_y - _enemy_half_size,
			_enemy_map_x + _enemy_half_size,
			_enemy_map_y + _enemy_half_size,
			false
		);
	}

	// Draw the cannon base at the center of the minimap.
	var _base_size = minimap_base_size * _minimap_scale;
	var _base_left = _minimap_center_x - (_base_size * 0.5);
	var _base_top = _minimap_center_y - (_base_size * 0.5);
	var _base_sprite = s_cannon_icon;

	if (sprite_exists(_base_sprite))
	{
		draw_sprite_stretched_ext(_base_sprite, 0, _base_left, _base_top, _base_size, _base_size, c_white, 1);
	}
	else
	{
		draw_set_color(COLOR_HUD_TEXT);
		draw_circle(_minimap_center_x, _minimap_center_y, _base_size * 0.35, false);
	}

	// Draw cultists with their icons and compact health bars.
	if (variable_global_exists("archdemons"))
	{
		var _minimap_cultist_count = array_length(global.archdemons);
		var _cultist_width = minimap_cultist_width * _minimap_scale;
		var _cultist_height = minimap_cultist_height * _minimap_scale;
		var _cultist_half_width = _cultist_width * 0.5;
		var _cultist_half_height = _cultist_height * 0.5;
		var _cultist_bar_width = minimap_cultist_bar_width * _minimap_scale;
		var _cultist_bar_height = minimap_cultist_bar_height * _minimap_scale;
		var _cultist_bar_gap = minimap_cultist_bar_gap * _minimap_scale;

		for (var _minimap_cultist_index = 0; _minimap_cultist_index < _minimap_cultist_count; ++_minimap_cultist_index)
		{
			var _minimap_cultist = global.archdemons[_minimap_cultist_index];

			if (!instance_exists(_minimap_cultist))
			{
				continue;
			}

			var _cultist_map_x = _minimap_center_x + ((_minimap_cultist.x - _world_center_x) * _world_to_minimap_scale);
			var _cultist_map_y = _minimap_center_y + ((_minimap_cultist.y - _world_center_y) * _world_to_minimap_scale);

			_cultist_map_x = clamp(_cultist_map_x, _minimap_x + _cultist_half_width, _minimap_right - _cultist_half_width);
			_cultist_map_y = clamp(_cultist_map_y, _minimap_y + _cultist_half_height, _minimap_bottom - _cultist_half_height - _cultist_bar_height);

			var _cultist_sprite = _minimap_cultist.sprite_index;

			if (variable_instance_exists(_minimap_cultist, "cultist_sprite_index")
				&& sprite_exists(_minimap_cultist.cultist_sprite_index))
			{
				_cultist_sprite = _minimap_cultist.cultist_sprite_index;
			}

			if (sprite_exists(_cultist_sprite))
			{
				draw_sprite_stretched_ext(
					_cultist_sprite,
					0,
					_cultist_map_x - _cultist_half_width,
					_cultist_map_y - _cultist_half_height,
					_cultist_width,
					_cultist_height,
					c_white,
					1
				);
			}
			else
			{
				draw_set_color(COLOR_CULTIST_BODY);
				draw_circle(_cultist_map_x, _cultist_map_y, _cultist_half_width, false);
			}

			var _cultist_hp_progress = 0;

			if (variable_instance_exists(_minimap_cultist, "hp") && variable_instance_exists(_minimap_cultist, "max_hp"))
			{
				_cultist_hp_progress = clamp(_minimap_cultist.hp / max(1, _minimap_cultist.max_hp), 0, 1);
			}

			var _cultist_bar_x = _cultist_map_x - (_cultist_bar_width * 0.5);
			var _cultist_bar_y = _cultist_map_y + _cultist_half_height + _cultist_bar_gap;

			draw_set_color(COLOR_HUD_MINIMAP_HEALTH_BACKGROUND);
			draw_rectangle(_cultist_bar_x, _cultist_bar_y, _cultist_bar_x + _cultist_bar_width, _cultist_bar_y + _cultist_bar_height, false);

			draw_set_color(cultist_status_card_hp_color);
			draw_rectangle(
				_cultist_bar_x,
				_cultist_bar_y,
				_cultist_bar_x + (_cultist_bar_width * _cultist_hp_progress),
				_cultist_bar_y + _cultist_bar_height,
				false
			);
		}
	}

	// Draw the current camera rectangle over the minimap.
	if (instance_exists(o_camera_controller))
	{
		var _camera_controller = instance_find(o_camera_controller, 0);
		var _camera = _camera_controller.camera_id;
		var _camera_left = camera_get_view_x(_camera);
		var _camera_top = camera_get_view_y(_camera);
		var _camera_width = camera_get_view_width(_camera);
		var _camera_height = camera_get_view_height(_camera);
		var _camera_map_left = _minimap_center_x + ((_camera_left - _world_center_x) * _world_to_minimap_scale);
		var _camera_map_top = _minimap_center_y + ((_camera_top - _world_center_y) * _world_to_minimap_scale);
		var _camera_map_right = _camera_map_left + (_camera_width * _world_to_minimap_scale);
		var _camera_map_bottom = _camera_map_top + (_camera_height * _world_to_minimap_scale);

		_camera_map_left = clamp(_camera_map_left, _minimap_x, _minimap_right);
		_camera_map_top = clamp(_camera_map_top, _minimap_y, _minimap_bottom);
		_camera_map_right = clamp(_camera_map_right, _minimap_x, _minimap_right);
		_camera_map_bottom = clamp(_camera_map_bottom, _minimap_y, _minimap_bottom);

		var _camera_min_size = minimap_view_min_size * _minimap_scale;

		if (_camera_map_right - _camera_map_left < _camera_min_size)
		{
			var _camera_map_center_x = clamp(
				(_camera_map_left + _camera_map_right) * 0.5,
				_minimap_x + (_camera_min_size * 0.5),
				_minimap_right - (_camera_min_size * 0.5)
			);

			_camera_map_left = _camera_map_center_x - (_camera_min_size * 0.5);
			_camera_map_right = _camera_map_center_x + (_camera_min_size * 0.5);
		}

		if (_camera_map_bottom - _camera_map_top < _camera_min_size)
		{
			var _camera_map_center_y = clamp(
				(_camera_map_top + _camera_map_bottom) * 0.5,
				_minimap_y + (_camera_min_size * 0.5),
				_minimap_bottom - (_camera_min_size * 0.5)
			);

			_camera_map_top = _camera_map_center_y - (_camera_min_size * 0.5);
			_camera_map_bottom = _camera_map_center_y + (_camera_min_size * 0.5);
		}

		draw_set_alpha(minimap_view_alpha);
		draw_set_color(COLOR_HUD_MINIMAP_VIEW_FILL);
		draw_rectangle(_camera_map_left, _camera_map_top, _camera_map_right, _camera_map_bottom, false);

		draw_set_alpha(0.85);
		draw_set_color(c_black);

		for (var _camera_shadow_index = 0; _camera_shadow_index < minimap_view_border_width + 2; ++_camera_shadow_index)
		{
			draw_rectangle(
				clamp(_camera_map_left + _camera_shadow_index, _minimap_x, _minimap_right),
				clamp(_camera_map_top + _camera_shadow_index, _minimap_y, _minimap_bottom),
				clamp(_camera_map_right - _camera_shadow_index, _minimap_x, _minimap_right),
				clamp(_camera_map_bottom - _camera_shadow_index, _minimap_y, _minimap_bottom),
				true
			);
		}

		draw_set_alpha(1);
		draw_set_color(COLOR_HUD_MINIMAP_VIEW_BORDER);

		for (var _camera_border_index = 0; _camera_border_index < minimap_view_border_width; ++_camera_border_index)
		{
			draw_rectangle(
				clamp(_camera_map_left + _camera_border_index + 1, _minimap_x, _minimap_right),
				clamp(_camera_map_top + _camera_border_index + 1, _minimap_y, _minimap_bottom),
				clamp(_camera_map_right - _camera_border_index - 1, _minimap_x, _minimap_right),
				clamp(_camera_map_bottom - _camera_border_index - 1, _minimap_y, _minimap_bottom),
				true
			);
		}
	}

	// Draw the total tainted ground counter below the minimap.
	var _taint_counter_y = _minimap_bottom + (corruption_minimap_offset_y * _minimap_scale);
	var _taint_counter_text = corruption_display_name
		+ " "
		+ string_format(corruption_display_value, 0, corruption_display_decimals)
		+ " / "
		+ string_format(corruption_display_percent, 0, 1)
		+ "%";

	draw_set_halign(fa_center);
	draw_set_valign(fa_top);
	draw_set_alpha(1);
	draw_set_color(c_black);
	draw_text_transformed(
		_minimap_center_x + (2 * _minimap_scale),
		_taint_counter_y + (2 * _minimap_scale),
		_taint_counter_text,
		corruption_minimap_label_scale * _minimap_scale,
		corruption_minimap_label_scale * _minimap_scale,
		0
	);

	draw_set_color(corruption_display_color);
	draw_text_transformed(
		_minimap_center_x,
		_taint_counter_y,
		_taint_counter_text,
		corruption_minimap_label_scale * _minimap_scale,
		corruption_minimap_label_scale * _minimap_scale,
		0
	);
}

// Draw unobtrusive control hints while no modal window is open.
if (_regular_hud_is_visible)
{
	var _control_hint_gui_height = display_get_gui_height();
	var _control_hint_scale = clamp(_control_hint_gui_height / 1080, 0.6, 1);
	var _control_hint_count = array_length(control_hint_keys);
	var _control_hint_x = control_hints_x * _control_hint_scale;
	var _control_hint_row_height = control_hints_row_height * _control_hint_scale;
	var _control_hint_row_gap = control_hints_row_gap * _control_hint_scale;
	var _control_hint_key_height = control_hints_key_height * _control_hint_scale;
	var _control_hint_key_padding_x = control_hints_key_padding_x * _control_hint_scale;
	var _control_hint_key_text_gap = control_hints_key_text_gap * _control_hint_scale;
	var _control_hint_padding_x = control_hints_padding_x * _control_hint_scale;
	var _control_hint_padding_y = control_hints_padding_y * _control_hint_scale;
	var _control_hint_action_width = 116 * _control_hint_scale;
	var _control_hint_key_width = control_hints_key_min_width * _control_hint_scale;

	for (var _control_hint_measure_index = 0; _control_hint_measure_index < _control_hint_count; ++_control_hint_measure_index)
	{
		_control_hint_key_width = max(
			_control_hint_key_width,
			string_width(control_hint_keys[_control_hint_measure_index]) + (_control_hint_key_padding_x * 2)
		);
	}

	var _control_hint_height = (_control_hint_row_height * _control_hint_count)
		+ (_control_hint_row_gap * (_control_hint_count - 1))
		+ (_control_hint_padding_y * 2);
	var _control_hint_y = _control_hint_gui_height
		- (control_hints_bottom_margin * _control_hint_scale)
		- _control_hint_height;
	var _control_hint_width = (_control_hint_padding_x * 2)
		+ _control_hint_key_width
		+ _control_hint_key_text_gap
		+ _control_hint_action_width;

	draw_set_halign(fa_left);
	draw_set_valign(fa_middle);
	draw_set_alpha(control_hints_background_alpha);
	draw_set_color(COLOR_HUD_BACKGROUND);
	draw_rectangle(
		_control_hint_x,
		_control_hint_y,
		_control_hint_x + _control_hint_width,
		_control_hint_y + _control_hint_height,
		false
	);

	for (var _control_hint_index = 0; _control_hint_index < _control_hint_count; ++_control_hint_index)
	{
		var _control_hint_row_y = _control_hint_y
			+ _control_hint_padding_y
			+ ((_control_hint_row_height + _control_hint_row_gap) * _control_hint_index);
		var _control_hint_key_x = _control_hint_x + _control_hint_padding_x;
		var _control_hint_key_y = _control_hint_row_y + ((_control_hint_row_height - _control_hint_key_height) * 0.5);

		draw_set_alpha(control_hints_key_alpha);
		draw_set_color(c_white);
		draw_rectangle(
			_control_hint_key_x,
			_control_hint_key_y,
			_control_hint_key_x + _control_hint_key_width,
			_control_hint_key_y + _control_hint_key_height,
			false
		);

		draw_set_alpha(0.86);
		draw_set_color(COLOR_HUD_TEXT);
		draw_rectangle(
			_control_hint_key_x,
			_control_hint_key_y,
			_control_hint_key_x + _control_hint_key_width,
			_control_hint_key_y + _control_hint_key_height,
			true
		);

		draw_set_alpha(1);
		draw_set_color(COLOR_HUD_TEXT);
		draw_text(
			_control_hint_key_x + _control_hint_key_padding_x,
			_control_hint_row_y + (_control_hint_row_height * 0.5),
			control_hint_keys[_control_hint_index]
		);

		draw_set_color(COLOR_HUD_PROJECTILE_DESCRIPTION);
		draw_text(
			_control_hint_key_x + _control_hint_key_width + _control_hint_key_text_gap,
			_control_hint_row_y + (_control_hint_row_height * 0.5),
			control_hint_actions[_control_hint_index]
		);
	}

	draw_set_alpha(1);
}

// Draw objective complete notice once the shrine goal is finished.
if (variable_global_exists("shrine_objective_complete") && global.shrine_objective_complete)
{
	var _gui_width = display_get_gui_width();
	var _notice_x = (_gui_width - objective_complete_notice_width) * 0.5;
	var _notice_y = objective_complete_notice_y;

	draw_set_halign(fa_center);
	draw_set_valign(fa_top);
	draw_set_alpha(0.86);
	draw_set_color(c_black);
	draw_rectangle(
		_notice_x,
		_notice_y,
		_notice_x + objective_complete_notice_width,
		_notice_y + objective_complete_notice_height,
		false
	);

	draw_set_alpha(1);
	draw_set_color(COLOR_PROJECTILE_CORRUPTION);
	draw_rectangle(
		_notice_x,
		_notice_y,
		_notice_x + objective_complete_notice_width,
		_notice_y + objective_complete_notice_height,
		true
	);

	draw_set_color(COLOR_PROJECTILE_CORRUPTION);
	if (variable_global_exists("ui_heading_font") && font_exists(global.ui_heading_font))
	{
		draw_set_font(global.ui_heading_font);
	}

	draw_text(_notice_x + (objective_complete_notice_width * 0.5), _notice_y + objective_complete_notice_padding, objective_complete_title);

	if (variable_global_exists("ui_font") && font_exists(global.ui_font))
	{
		draw_set_font(global.ui_font);
	}

	draw_set_color(COLOR_HUD_TEXT);
	draw_text(
		_notice_x + (objective_complete_notice_width * 0.5),
		_notice_y + objective_complete_notice_padding + 46,
		objective_complete_description
	);
}

// Draw the upcoming-day strip to the left of the minimap.
if (global.focus_window == FOCUS_WINDOW.NOONE && instance_exists(o_game_controller))
{
	var _night_panel_game_controller = instance_find(o_game_controller, 0);
	var _night_panel_current_day = 1;
	var _night_panel_scale = clamp(display_get_gui_height() / 1080, 0.6, 1);
	var _night_panel_minimap_size = minimap_size * _night_panel_scale;
	var _night_panel_minimap_left = display_get_gui_width()
		- (minimap_margin_right * _night_panel_scale)
		- _night_panel_minimap_size;
	var _night_panel_origin_offset = sprite_get_xoffset(s_day_night_pannel) * _night_panel_scale;
	var _night_panel_origin_offset_y = sprite_get_yoffset(s_day_night_pannel) * _night_panel_scale;
	var _night_panel_anchor_x = _night_panel_minimap_left + _night_panel_origin_offset;
	var _night_panel_anchor_y = (minimap_y - 55) * _night_panel_scale;
	var _night_panel_top = _night_panel_anchor_y - _night_panel_origin_offset_y;
	var _night_panel_icon_gap = night_panel_icon_gap * _night_panel_scale;
	var _night_panel_icon_size = night_panel_icon_size * _night_panel_scale;

	if (variable_instance_exists(_night_panel_game_controller, "night_attack_night_index"))
	{
		_night_panel_current_day = max(1, _night_panel_game_controller.night_attack_night_index);
	}

	// Draw the current day label directly above and aligned with the day strip.
	var _day_label_width = night_panel_day_label_width * _night_panel_scale;
	var _day_label_height = night_panel_day_label_height * _night_panel_scale;
	var _day_label_x = _night_panel_minimap_left;
	var _day_label_y = _night_panel_top - _day_label_height;
	draw_set_alpha(1);
	draw_set_color(COLOR_HUD_MINIMAP_BACKGROUND);
	draw_rectangle(
		_day_label_x,
		_day_label_y,
		_day_label_x + _day_label_width,
		_day_label_y + _day_label_height,
		false
	);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_set_color(COLOR_SQUAD_CARD_TYPE);
	draw_text_transformed(
		_day_label_x + (_day_label_width * 0.5),
		_day_label_y + (_day_label_height * 0.5),
		"DAY " + string(_night_panel_current_day),
		_night_panel_scale,
		_night_panel_scale,
		0
	);

	if (sprite_exists(s_day_night_pannel))
	{
		draw_sprite_ext(s_day_night_pannel, 0, _night_panel_anchor_x, _night_panel_anchor_y, _night_panel_scale, _night_panel_scale, 0, c_white, 1);
	}

	for (var _night_offset = -1; _night_offset < night_panel_visible_count - 1; ++_night_offset)
	{
		var _night_index = max(1, _night_panel_current_day + _night_offset);
		var _night_icon_sprite = s_regular_night_icon;

		if (variable_instance_exists(_night_panel_game_controller, "boss_griffith_night_is_scheduled")
			&& _night_panel_game_controller.boss_griffith_night_is_scheduled(_night_index))
		{
			_night_icon_sprite = s_boss_icon;
		}
		else if (variable_instance_exists(_night_panel_game_controller, "full_moon_night_is_scheduled")
			&& _night_panel_game_controller.full_moon_night_is_scheduled(_night_index))
		{
			_night_icon_sprite = s_full_moon_icon;
		}

		var _night_icon_x = _night_panel_anchor_x + (_night_offset * _night_panel_icon_gap);
		var _night_icon_alpha = _night_offset == 0 ? 1 : 0.72;

		if (sprite_exists(_night_icon_sprite))
		{
			var _night_sprite_size = max(1, max(sprite_get_width(_night_icon_sprite), sprite_get_height(_night_icon_sprite)));
			var _night_icon_scale = _night_panel_icon_size / _night_sprite_size;
			draw_sprite_ext(_night_icon_sprite, 0, _night_icon_x, _night_panel_anchor_y, _night_icon_scale, _night_icon_scale, 0, c_white, _night_icon_alpha);
		}
	}

}

// Satiety remains active as a mechanic, but its HUD is hidden for now.
if (false
	&& global.focus_window == FOCUS_WINDOW.NOONE
	&& variable_global_exists("cannon_satiety")
	&& variable_global_exists("cannon_satiety_max"))
{
	var _gui_width = display_get_gui_width();
	var _satiety_x = (_gui_width - cannon_satiety_width) * 0.5;
	var _satiety_y = hud_margin_y + resource_item_height + resource_item_gap;
	var _satiety_value = max(0, global.cannon_satiety);
	var _satiety_max = max(1, global.cannon_satiety_max);
	var _satiety_per_corpse = max(1, BALANCE_CANNON_SATIETY_PER_CORPSE);
	var _satiety_max_corpses = ceil(_satiety_max / _satiety_per_corpse);
	var _satiety_bar_count = max(1, ceil(_satiety_value / _satiety_max));
	var _satiety_stack_height = cannon_satiety_height + ((_satiety_bar_count - 1) * (cannon_satiety_bar_height + cannon_satiety_bar_gap));
	var _satiety_text_x = _satiety_x + cannon_satiety_padding_x;
	var _satiety_text_y = _satiety_y + (cannon_satiety_height * 0.5);
	var _satiety_bar_x = _satiety_x + cannon_satiety_bar_offset_x;
	var _satiety_bar_y = _satiety_y + ((cannon_satiety_height - cannon_satiety_bar_height) * 0.5);
	var _satiety_bar_label_x = _satiety_bar_x + cannon_satiety_bar_width + cannon_satiety_bar_label_gap;

	// Draw the night schedule strip above satiety; the panel pivot marks the current night.
	if (instance_exists(o_game_controller))
	{
		var _night_panel_game_controller = instance_find(o_game_controller, 0);
		var _night_panel_current_day = 1;
		var _night_panel_scale = clamp(display_get_gui_height() / 1080, 0.6, 1);
		var _night_panel_anchor_x = display_get_gui_width() - ((hud_sidebar_width * 0.5) * _night_panel_scale);
		var _night_panel_anchor_y = (minimap_y - 55) * _night_panel_scale;
		var _night_panel_icon_gap = night_panel_icon_gap * _night_panel_scale;
		var _night_panel_icon_size = night_panel_icon_size * _night_panel_scale;

		if (variable_instance_exists(_night_panel_game_controller, "night_attack_night_index"))
		{
			_night_panel_current_day = max(1, _night_panel_game_controller.night_attack_night_index);
		}

		if (sprite_exists(s_day_night_pannel))
		{
			draw_sprite_ext(s_day_night_pannel, 0, _night_panel_anchor_x, _night_panel_anchor_y, _night_panel_scale, _night_panel_scale, 0, c_white, 1);
		}

		for (var _night_offset = -1; _night_offset < night_panel_visible_count - 1; ++_night_offset)
		{
			var _night_index = max(1, _night_panel_current_day + _night_offset);
			var _night_icon_sprite = s_regular_night_icon;

			if (variable_instance_exists(_night_panel_game_controller, "boss_griffith_night_is_scheduled")
				&& _night_panel_game_controller.boss_griffith_night_is_scheduled(_night_index))
			{
				_night_icon_sprite = s_boss_icon;
			}
			else if (variable_instance_exists(_night_panel_game_controller, "full_moon_night_is_scheduled")
				&& _night_panel_game_controller.full_moon_night_is_scheduled(_night_index))
			{
				_night_icon_sprite = s_full_moon_icon;
			}

			var _night_icon_x = _night_panel_anchor_x + (_night_offset * _night_panel_icon_gap);
			var _night_icon_y = _night_panel_anchor_y;
			var _night_icon_alpha = (_night_offset == 0) ? 1 : 0.72;

			if (sprite_exists(_night_icon_sprite))
			{
				var _night_sprite_size = max(1, max(sprite_get_width(_night_icon_sprite), sprite_get_height(_night_icon_sprite)));
				var _night_icon_scale = _night_panel_icon_size / _night_sprite_size;
				draw_sprite_ext(_night_icon_sprite, 0, _night_icon_x, _night_icon_y, _night_icon_scale, _night_icon_scale, 0, c_white, _night_icon_alpha);
			}
		}
	}

	draw_set_halign(fa_left);
	draw_set_valign(fa_middle);
	draw_set_alpha(0.72);
	draw_set_color(COLOR_HUD_BACKGROUND);
	draw_rectangle(_satiety_x, _satiety_y, _satiety_x + cannon_satiety_width, _satiety_y + _satiety_stack_height, false);

	draw_set_alpha(1);
	draw_set_color(COLOR_HUD_TEXT);
	draw_text(_satiety_text_x, _satiety_text_y, cannon_satiety_label);

	for (var _satiety_bar_index = 0; _satiety_bar_index < _satiety_bar_count; ++_satiety_bar_index)
	{
		var _satiety_bar_value = _satiety_value - (_satiety_bar_index * _satiety_max);
		var _satiety_progress = clamp(_satiety_bar_value / _satiety_max, 0, 1);
		var _satiety_current_bar_y = _satiety_bar_y + (_satiety_bar_index * (cannon_satiety_bar_height + cannon_satiety_bar_gap));
		var _satiety_bar_corpses = ceil(clamp(_satiety_bar_value, 0, _satiety_max) / _satiety_per_corpse);
		var _satiety_bar_label = string(_satiety_bar_corpses) + "/" + string(_satiety_max_corpses) + " corpses";
		var _satiety_reward_alpha = _satiety_progress >= 1 ? 1 : 0.35;

		draw_set_alpha(0.75);
		draw_set_color(c_black);
		draw_rectangle(
			_satiety_bar_x,
			_satiety_current_bar_y,
			_satiety_bar_x + cannon_satiety_bar_width,
			_satiety_current_bar_y + cannon_satiety_bar_height,
			false
		);

		draw_set_alpha(1);
		draw_set_color(COLOR_PROJECTILE_CORRUPTION);
		draw_rectangle(
			_satiety_bar_x,
			_satiety_current_bar_y,
			_satiety_bar_x + (cannon_satiety_bar_width * _satiety_progress),
			_satiety_current_bar_y + cannon_satiety_bar_height,
			false
		);

		draw_set_color(COLOR_HUD_TEXT);
		draw_text(_satiety_bar_label_x, _satiety_current_bar_y + (cannon_satiety_bar_height * 0.5), _satiety_bar_label);

		var _satiety_reward_start_x = _satiety_bar_label_x
			+ string_width(_satiety_bar_label)
			+ cannon_satiety_reward_icon_gap
			+ 18;
		var _satiety_reward_y = _satiety_current_bar_y + (cannon_satiety_bar_height * 0.5);
		var _taint_shell_icon_x = _satiety_reward_start_x
			+ string_width("+1")
			+ cannon_satiety_reward_label_gap
			+ cannon_satiety_reward_icon_radius;

		draw_set_alpha(_satiety_reward_alpha);
		draw_set_color(COLOR_HUD_TEXT);
		draw_text(_satiety_reward_start_x, _satiety_reward_y, "+1");

		draw_set_color(COLOR_PROJECTILE_CORRUPTION);
		draw_circle(
			_taint_shell_icon_x,
			_satiety_reward_y,
			cannon_satiety_reward_icon_radius,
			false
		);
	}

	draw_set_alpha(1);
}

// Draw defeat notice when the cannon has no HP left.
if (instance_exists(o_cannon))
{
	var _cannon = instance_find(o_cannon, 0);

	if (variable_instance_exists(_cannon, "hp") && _cannon.hp <= 0)
	{
		var _gui_width = display_get_gui_width();
		var _notice_x = (_gui_width - wall_fallen_notice_width) * 0.5;
		var _notice_y = wall_fallen_notice_y;

		draw_set_halign(fa_center);
		draw_set_valign(fa_top);
		draw_set_alpha(0.86);
		draw_set_color(c_black);
		draw_rectangle(
			_notice_x,
			_notice_y,
			_notice_x + wall_fallen_notice_width,
			_notice_y + wall_fallen_notice_height,
			false
		);

		draw_set_alpha(1);
		draw_set_color(COLOR_PROJECTILE_DAMAGE);
		draw_rectangle(
			_notice_x,
			_notice_y,
			_notice_x + wall_fallen_notice_width,
			_notice_y + wall_fallen_notice_height,
			true
		);

		draw_set_color(COLOR_PROJECTILE_DAMAGE);
		if (variable_global_exists("ui_heading_font") && font_exists(global.ui_heading_font))
		{
			draw_set_font(global.ui_heading_font);
		}

		draw_text(_notice_x + (wall_fallen_notice_width * 0.5), _notice_y + wall_fallen_notice_padding, wall_fallen_title);

		if (variable_global_exists("ui_font") && font_exists(global.ui_font))
		{
			draw_set_font(global.ui_font);
		}

		draw_set_color(COLOR_HUD_TEXT);
		draw_text(
			_notice_x + (wall_fallen_notice_width * 0.5),
			_notice_y + wall_fallen_notice_padding + 46,
			wall_fallen_description
		);
	}
}

// Draw the cannon HP centered against the top edge.
if (instance_exists(o_cannon))
{
	var _cannon = instance_find(o_cannon, 0);

	if (variable_instance_exists(_cannon, "hp") && variable_instance_exists(_cannon, "max_hp"))
	{
		var _gui_width = display_get_gui_width();
		var _gui_height = display_get_gui_height();
		var _hp_progress = clamp(_cannon.hp / max(1, _cannon.max_hp), 0, 1);
		var _bar_width = _gui_width * cannon_hp_bar_width_share;
		var _fill_height = max(1, _gui_height * cannon_hp_fill_height_share);
		var _background_height = max(1, _gui_height * cannon_hp_background_height_share);
		var _fill_x = (_gui_width - _bar_width) * 0.5;
		var _fill_y = 0;
		var _background_y = _gui_height * cannon_hp_background_top_share;
		var _label_x = _fill_x + (_bar_width * 0.5);
		var _label_y = _fill_y + (_fill_height * 0.5);

		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		draw_set_alpha(0.8);
		draw_set_color(c_black);
		draw_rectangle(_fill_x, _background_y, _fill_x + _bar_width, _background_y + _background_height, false);

		draw_set_alpha(1);
		draw_set_color(COLOR_CANNON_HP_BAR);
		draw_rectangle(_fill_x, _fill_y, _fill_x + (_bar_width * _hp_progress), _fill_y + _fill_height, false);

		draw_set_color(c_white);
		if (variable_global_exists("ui_heading_font") && font_exists(global.ui_heading_font))
		{
			draw_set_font(global.ui_heading_font);
		}

		draw_text_transformed(_label_x, _label_y, cannon_hp_label, cannon_hp_label_scale, cannon_hp_label_scale, 0);

		// Warn during preparation when the upcoming night is a boss fight or Blood Moon.
		var _special_night_warning_text = "";

		if (global.day_phase == DAY_PHASE.DAY && instance_exists(o_game_controller))
		{
			var _game_controller = instance_find(o_game_controller, 0);

			if (variable_instance_exists(_game_controller, "boss_griffith_night_is_scheduled")
				&& _game_controller.boss_griffith_night_is_scheduled(_game_controller.night_attack_night_index))
			{
				_special_night_warning_text = cannon_special_night_boss_text;
			}
			else if (variable_instance_exists(_game_controller, "full_moon_night_is_scheduled")
				&& _game_controller.full_moon_night_is_scheduled(_game_controller.night_attack_night_index))
			{
				_special_night_warning_text = cannon_special_night_blood_moon_text;
			}
		}

		if (_special_night_warning_text != "")
		{
			var _warning_pulse = 0.5
				+ (sin(current_time * cannon_special_night_warning_pulse_speed) * 0.5);
			var _warning_scale = lerp(
				cannon_special_night_warning_scale_min,
				cannon_special_night_warning_scale_max,
				_warning_pulse
			);
			var _warning_y = _fill_y + _fill_height + cannon_special_night_warning_gap;

			draw_set_color(c_black);
			draw_text_transformed(
				_label_x + cannon_special_night_warning_shadow_offset,
				_warning_y + cannon_special_night_warning_shadow_offset,
				_special_night_warning_text,
				_warning_scale,
				_warning_scale,
				0
			);
			draw_set_color(COLOR_STATUS_NEGATIVE_RED);
			draw_text_transformed(
				_label_x,
				_warning_y,
				_special_night_warning_text,
				_warning_scale,
				_warning_scale,
				0
			);
		}

		if (variable_global_exists("ui_font") && font_exists(global.ui_font))
		{
			draw_set_font(global.ui_font);
		}
	}
}

// Draw the first-night cultist projectile prompt until the player fires it.
if (variable_global_exists("first_night_cultist_projectile_fired")
	&& variable_global_exists("day_phase")
	&& variable_global_exists("cannon_projectile_queue")
	&& global.day_phase == DAY_PHASE.NIGHT
	&& !global.first_night_cultist_projectile_fired
	&& array_length(global.cannon_projectile_queue) > 0
	&& global.cannon_projectile_queue[0] == PROJECTILE_TYPE.CULTIST
	&& instance_exists(o_game_controller))
{
	var _prompt_game_controller = instance_find(o_game_controller, 0);

	if (variable_instance_exists(_prompt_game_controller, "night_attack_night_index")
		&& _prompt_game_controller.night_attack_night_index == 1)
	{
		var _prompt_x = display_get_gui_width() * 0.5;
		var _prompt_y = display_get_gui_height() * 0.5;
		var _prompt_text = first_night_cultist_prompt_text;
		var _prompt_shadow_offset = first_night_cultist_prompt_shadow_offset;

		if (global.focus_window == FOCUS_WINDOW.TARGET_SELECTION
			&& variable_instance_exists(_prompt_game_controller, "target_selection_projectile_type")
			&& _prompt_game_controller.target_selection_projectile_type == PROJECTILE_TYPE.CULTIST)
		{
			_prompt_text = first_night_cultist_aim_prompt_text;
		}

		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);

		if (variable_global_exists("ui_heading_font") && font_exists(global.ui_heading_font))
		{
			draw_set_font(global.ui_heading_font);
		}

		draw_set_alpha(0.82);
		draw_set_color(c_black);
		draw_text_transformed(
			_prompt_x + _prompt_shadow_offset,
			_prompt_y + _prompt_shadow_offset,
			_prompt_text,
			first_night_cultist_prompt_scale,
			first_night_cultist_prompt_scale,
			0
		);

		draw_set_alpha(1);
		draw_set_color(COLOR_HUD_TEXT);
		draw_text_transformed(
			_prompt_x,
			_prompt_y,
			_prompt_text,
			first_night_cultist_prompt_scale,
			first_night_cultist_prompt_scale,
			0
		);

		if (variable_global_exists("ui_font") && font_exists(global.ui_font))
		{
			draw_set_font(global.ui_font);
		}
	}
}

// Draw queued cannon projectiles at the bottom center of the HUD.
if (variable_global_exists("cannon_projectile_queue")
	&& variable_global_exists("day_phase"))
{
	var _combat_projectiles_are_active = global.day_phase == DAY_PHASE.NIGHT;
	var _projectile_queue_count = array_length(global.cannon_projectile_queue);
	var _projectile_display_slots = array_create(0);
	var _projectile_game_controller = noone;

	if (instance_exists(o_game_controller))
	{
		_projectile_game_controller = instance_find(o_game_controller, 0);
		_projectile_display_slots = projectile_display_slots_get(_projectile_game_controller, 9);
	}

	var _projectile_display_count = array_length(_projectile_display_slots);
	var _projectile_mouse_x = device_mouse_x_to_gui(0);
	var _projectile_mouse_y = device_mouse_y_to_gui(0);
	var _gui_width = display_get_gui_width();
	var _gui_height = display_get_gui_height();
	var _projectile_base_y = _gui_height - projectile_queue_margin_bottom - projectile_slot_height - projectile_name_offset_y;
	var _has_building_shell_projectile = false;

	// Keep the daytime projectile row fully above the bottom-center End Day button.
	if (global.day_phase == DAY_PHASE.DAY && instance_exists(o_jobs_ui))
	{
		var _jobs_ui = instance_find(o_jobs_ui, 0);

		if (variable_instance_exists(_jobs_ui, "jobs_end_day_button_rect_get"))
		{
			var _end_day_button_rect = _jobs_ui.jobs_end_day_button_rect_get();
			_projectile_base_y = _end_day_button_rect.y
				- projectile_slot_height
				- projectile_day_end_button_gap;
		}
	}

	for (var _building_shell_check_index = 0; _building_shell_check_index < _projectile_display_count; ++_building_shell_check_index)
	{
		var _building_shell_check_slot = _projectile_display_slots[_building_shell_check_index];

		if (_building_shell_check_slot.projectile_type == PROJECTILE_TYPE.BUILDING_SHELL)
		{
			_has_building_shell_projectile = true;
			break;
		}
	}

	if (_has_building_shell_projectile)
	{
		_projectile_base_y -= projectile_building_shell_row_offset_y;
	}

	var _projectile_total_width = (projectile_slot_width * _projectile_display_count)
		+ (projectile_slot_gap * max(0, _projectile_display_count - 1));
	var _projectile_start_x = (_gui_width - _projectile_total_width) * 0.5;
	var _cannon_is_reloading = false;
	var _cannon_reload_progress = 1;
	var _cannon_reload_seconds = 0;
	var _reload_ui_reserved_height = 0;

	if (instance_exists(o_cannon))
	{
		var _reload_cannon = instance_find(o_cannon, 0);

		if (variable_instance_exists(_reload_cannon, "cannon_reload_is_ready")
			&& !_reload_cannon.cannon_reload_is_ready())
		{
			_cannon_is_reloading = true;
			_cannon_reload_progress = _reload_cannon.cannon_reload_progress_get();
			_cannon_reload_seconds = _reload_cannon.cannon_reload_remaining_seconds_get();
			_reload_ui_reserved_height = projectile_recharge_reserved_height;
		}
	}

	// Show one shared Cannon reload bar above every projectile choice.
	if (_cannon_is_reloading && _projectile_display_count > 0)
	{
		var _reload_bar_width = min(projectile_recharge_bar_width, max(projectile_slot_width, _projectile_total_width));
		var _reload_bar_x = (_gui_width - _reload_bar_width) * 0.5;
		var _reload_bar_y = _projectile_base_y - projectile_recharge_bar_gap;
		var _reload_label = "RELOADING " + string_format(_cannon_reload_seconds, 0, 1) + "s";

		draw_set_halign(fa_center);
		draw_set_valign(fa_bottom);
		draw_set_alpha(1);
		draw_set_color(COLOR_HUD_TEXT);
		draw_text(_gui_width * 0.5, _reload_bar_y - projectile_recharge_label_gap, _reload_label);

		draw_set_alpha(0.72);
		draw_set_color(COLOR_HUD_BACKGROUND);
		draw_rectangle(
			_reload_bar_x,
			_reload_bar_y,
			_reload_bar_x + _reload_bar_width,
			_reload_bar_y + projectile_recharge_bar_height,
			false
		);

		draw_set_alpha(1);
		draw_set_color(COLOR_HUD_PROJECTILE_SELECTED);
		draw_rectangle(
			_reload_bar_x,
			_reload_bar_y,
			_reload_bar_x + (_reload_bar_width * _cannon_reload_progress),
			_reload_bar_y + projectile_recharge_bar_height,
			false
		);
	}

	var _hovered_projectile_index = -1;
	var _projectile_payload_data = array_create(_projectile_queue_count, noone);
	var _deploy_preview_units = array_create(0);
	var _deploy_preview_cursor = 0;
	var _remaining_cultist_projectile_count = 0;
	var _selected_projectile_index = 0;
	var _selected_projectile_type = PROJECTILE_TYPE.DAMAGE;

	if (_projectile_display_count > 0 && variable_global_exists("cannon_selected_projectile_index"))
	{
		_selected_projectile_index = clamp(global.cannon_selected_projectile_index, 0, max(0, _projectile_queue_count));
	}

	if (_selected_projectile_index < _projectile_queue_count)
	{
		_selected_projectile_type = global.cannon_projectile_queue[_selected_projectile_index];
	}

	// Matchup guidance is shown only for selected shells that deploy combat units.
	var _selected_projectile_matchups = {
		strong_against: [],
		weak_against: []
	};
	var _selected_projectile_matchup_row_count = 0;
	var _selected_projectile_matchup_height = 0;

	if (_combat_projectiles_are_active
		&& instance_exists(_projectile_game_controller)
		&& variable_instance_exists(_projectile_game_controller, "combat_unit_matchup_get"))
	{
		var _selected_projectile_payload = noone;

		if (variable_global_exists("cannon_projectile_payload_queue")
			&& _selected_projectile_index >= 0
			&& _selected_projectile_index < array_length(global.cannon_projectile_payload_queue))
		{
			_selected_projectile_payload = global.cannon_projectile_payload_queue[_selected_projectile_index];
		}

		var _selected_projectile_unit_object = projectile_matchup_unit_object_get(
			_selected_projectile_type,
			_selected_projectile_payload
		);

		if (_selected_projectile_unit_object != noone)
		{
			_selected_projectile_matchups = _projectile_game_controller.combat_unit_matchup_get(
				_selected_projectile_unit_object
			);
			var _selected_strong_count = array_length(_selected_projectile_matchups.strong_against);
			var _selected_weak_count = array_length(_selected_projectile_matchups.weak_against);
			_selected_projectile_matchup_row_count = (_selected_strong_count > 0 ? 1 : 0)
				+ (_selected_weak_count > 0 ? 1 : 0);

			if (_selected_projectile_matchup_row_count > 0)
			{
				_selected_projectile_matchup_height = (projectile_matchup_icon_radius * 2)
					+ (projectile_matchup_row_gap * (_selected_projectile_matchup_row_count - 1))
					+ projectile_matchup_card_gap
					+ projectile_current_scale_padding;
			}
		}
	}

	// Build compact cultist projectile payload previews from the current queue.
	for (var _preview_queue_index = 0; _preview_queue_index < _projectile_queue_count; ++_preview_queue_index)
	{
		if (global.cannon_projectile_queue[_preview_queue_index] == PROJECTILE_TYPE.CULTIST)
		{
			_remaining_cultist_projectile_count++;
		}
	}

	if (_remaining_cultist_projectile_count > 0)
	{
		var _friendly_count = instance_number(o_friendly_units);

		for (var _friendly_index = 0; _friendly_index < _friendly_count; ++_friendly_index)
		{
			var _friendly_unit = instance_find(o_friendly_units, _friendly_index);

			var _is_squad_combat_unit = instance_exists(_friendly_unit)
				&& (_friendly_unit.object_index == o_pitling || _friendly_unit.object_index == o_skeleton)
				&& variable_instance_exists(_friendly_unit, "squad")
				&& is_struct(_friendly_unit.squad);

			if (!instance_exists(_friendly_unit)
				|| (!variable_instance_exists(_friendly_unit, "summon_nights_remaining") && !_is_squad_combat_unit)
				|| !variable_instance_exists(_friendly_unit, "cultist_projectile_deploy_assigned")
				|| _friendly_unit.cultist_projectile_deploy_assigned
				|| (_friendly_unit.object_index != o_skeleton && _friendly_unit.object_index != o_pitling))
			{
				continue;
			}

			array_push(_deploy_preview_units, _friendly_unit.object_index);
		}
	}

	for (var _preview_projectile_index = 0; _preview_projectile_index < _projectile_queue_count; ++_preview_projectile_index)
	{
		if (global.cannon_projectile_queue[_preview_projectile_index] != PROJECTILE_TYPE.CULTIST)
		{
			continue;
		}

		var _preview_demon_sprite = noone;

		if (variable_global_exists("cannon_projectile_payload_queue")
			&& _preview_projectile_index < array_length(global.cannon_projectile_payload_queue))
		{
			var _preview_cultist_payload = global.cannon_projectile_payload_queue[_preview_projectile_index];

			if (instance_exists(_preview_cultist_payload)
				&& variable_instance_exists(_preview_cultist_payload, "demon_type"))
			{
				var _preview_demon_object = cultist_demon_object_get(_preview_cultist_payload.demon_type);

				if (_preview_demon_object != noone)
				{
					_preview_demon_sprite = object_get_sprite(_preview_demon_object);
				}
			}
		}

		var _remaining_deploy_count = array_length(_deploy_preview_units) - _deploy_preview_cursor;
		var _take_count = min(_remaining_deploy_count, ceil(_remaining_deploy_count / max(1, _remaining_cultist_projectile_count)));
		var _skeleton_count = 0;
		var _pitling_count = 0;

		for (var _take_index = 0; _take_index < _take_count; ++_take_index)
		{
			var _preview_unit_object = _deploy_preview_units[_deploy_preview_cursor + _take_index];

			if (_preview_unit_object == o_skeleton)
			{
				_skeleton_count++;
			}
			else if (_preview_unit_object == o_pitling)
			{
				_pitling_count++;
			}
		}

		_deploy_preview_cursor += _take_count;
		_remaining_cultist_projectile_count--;

		_projectile_payload_data[_preview_projectile_index] = {
			demon_sprite: _preview_demon_sprite,
			pitling_count: _pitling_count,
			skeleton_count: _skeleton_count
		};
	}

	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);

	for (var _projectile_display_index = 0; _projectile_display_index < _projectile_display_count; ++_projectile_display_index)
	{
		var _projectile_slot = _projectile_display_slots[_projectile_display_index];
		var _projectile_index = _projectile_slot.queue_index;
		var _projectile_type = _projectile_slot.projectile_type;
		var _projectile_stack_count = _projectile_slot.count;
		var _projectile_is_available = _projectile_index >= 0 && _projectile_stack_count > 0;

		var _slot_x = _projectile_start_x + ((projectile_slot_width + projectile_slot_gap) * _projectile_display_index);
		var _slot_y = _projectile_base_y;
		var _slot_width = projectile_slot_width;
		var _slot_height = projectile_slot_background_height;
		var _is_current_projectile = _projectile_index == _selected_projectile_index
			|| (_projectile_stack_count > 1
				&& _selected_projectile_type == _projectile_type
				&& _projectile_type != PROJECTILE_TYPE.CULTIST
				&& _projectile_type != PROJECTILE_TYPE.BUILDING_SHELL);
		var _projectile_color = COLOR_PROJECTILE_DAMAGE;
		var _projectile_sprite = noone;
		var _projectile_squad_unit_sprite = noone;
		var _circle_radius = projectile_circle_radius;

		if (_projectile_type == PROJECTILE_TYPE.CORRUPTION)
		{
			_projectile_color = COLOR_PROJECTILE_CORRUPTION;
			_projectile_sprite = s_taint_shell;
		}
		else if (_projectile_type == PROJECTILE_TYPE.SUMMON)
		{
			_projectile_color = COLOR_PROJECTILE_SUMMON;
		}
		else if (_projectile_type == PROJECTILE_TYPE.RALLY)
		{
			_projectile_color = COLOR_PROJECTILE_RALLY;
		}
		else if (_projectile_type == PROJECTILE_TYPE.CULTIST)
		{
			_projectile_color = COLOR_PROJECTILE_CULTIST;

			if (variable_global_exists("cannon_projectile_payload_queue")
				&& _projectile_index >= 0
				&& _projectile_index < array_length(global.cannon_projectile_payload_queue))
			{
				var _squad_projectile_payload = global.cannon_projectile_payload_queue[_projectile_index];
				_projectile_squad_unit_sprite = projectile_squad_unit_sprite_get(_squad_projectile_payload);
			}
		}
		else if (_projectile_type == PROJECTILE_TYPE.HEAL)
		{
			_projectile_color = COLOR_PROJECTILE_HEAL;
			_projectile_sprite = s_heal_meat;
		}
		else if (_projectile_type == PROJECTILE_TYPE.BOMB)
		{
			_projectile_color = COLOR_PROJECTILE_BOMB;
			_projectile_sprite = s_cow;
		}
		else if (_projectile_type == PROJECTILE_TYPE.DOOM_BELL)
		{
			_projectile_color = COLOR_PROJECTILE_BOMB;
			_projectile_sprite = s_mega_bell;
		}
		else if (_projectile_type == PROJECTILE_TYPE.SKELETONS)
		{
			_projectile_color = COLOR_PROJECTILE_SKELETONS;
		}
		else if (_projectile_type == PROJECTILE_TYPE.BUILDING_SHELL)
		{
			_projectile_color = COLOR_PROJECTILE_BUILDING_SHELL;
		}

		var _projectile_is_active = instance_exists(_projectile_game_controller)
			&& _projectile_game_controller.cannon_projectile_type_can_fire_in_current_phase(_projectile_type);
		var _projectile_can_fire = _projectile_is_active
			&& _projectile_is_available
			&& !_cannon_is_reloading;
		var _projectile_draw_alpha = _projectile_is_active ? 1 : projectile_day_alpha;

		if (!_projectile_is_available)
		{
			_projectile_draw_alpha *= projectile_day_alpha;
		}
		else if (_cannon_is_reloading)
		{
			_projectile_draw_alpha *= 0.6;
		}

		if (_projectile_type == PROJECTILE_TYPE.BUILDING_SHELL)
		{
			_slot_y += projectile_building_shell_row_offset_y;
		}

		if (_is_current_projectile)
		{
			_slot_x -= projectile_current_scale_padding;
			_slot_y -= projectile_current_scale_padding;
			_slot_width += projectile_current_scale_padding * 2;
			_slot_height += projectile_current_scale_padding * 2;
			_circle_radius = projectile_current_circle_radius;
		}

		// Center green and red matchup rows above the selected unit shell.
		if (_is_current_projectile && _selected_projectile_matchup_row_count > 0)
		{
			var _matchup_center_x = _slot_x + (_slot_width * 0.5);
			var _matchup_center_y = _slot_y
				- projectile_matchup_card_gap
				- projectile_matchup_icon_radius
				- (projectile_matchup_row_gap * (_selected_projectile_matchup_row_count - 1))
				- _reload_ui_reserved_height;

			if (array_length(_selected_projectile_matchups.strong_against) > 0)
			{
				projectile_matchup_row_draw(
					_selected_projectile_matchups.strong_against,
					_matchup_center_x,
					_matchup_center_y,
					COLOR_PROJECTILE_SUMMON
				);
				_matchup_center_y += projectile_matchup_row_gap;
			}

			if (array_length(_selected_projectile_matchups.weak_against) > 0)
			{
				projectile_matchup_row_draw(
					_selected_projectile_matchups.weak_against,
					_matchup_center_x,
					_matchup_center_y,
					COLOR_STATUS_NEGATIVE_RED
				);
			}
		}

		if (_projectile_mouse_x >= _slot_x && _projectile_mouse_x <= _slot_x + _slot_width
			&& _projectile_mouse_y >= _slot_y && _projectile_mouse_y <= _slot_y + _slot_height)
		{
			_hovered_projectile_index = _projectile_display_index;
		}

		draw_set_alpha(0.76 * _projectile_draw_alpha);
		draw_set_color(COLOR_HUD_BACKGROUND);
		draw_rectangle(_slot_x, _slot_y, _slot_x + _slot_width, _slot_y + _slot_height, false);

		if (_is_current_projectile)
		{
			draw_set_alpha(_projectile_draw_alpha);
			draw_set_color(COLOR_HUD_PROJECTILE_SELECTED);
			draw_rectangle(_slot_x, _slot_y, _slot_x + _slot_width, _slot_y + _slot_height, true);
		}

		draw_set_alpha(_projectile_draw_alpha);

		if (_projectile_sprite != noone)
		{
			var _sprite_width = max(1, sprite_get_width(_projectile_sprite));
			var _sprite_height = max(1, sprite_get_height(_projectile_sprite));
			var _sprite_max_size = max(_sprite_width, _sprite_height);
			var _sprite_scale = (_circle_radius * 2) / _sprite_max_size;

			draw_set_color(c_white);
			draw_sprite_ext(
				_projectile_sprite,
				0,
				_slot_x + (_slot_width * 0.5),
				_slot_y + 22,
				_sprite_scale,
				_sprite_scale,
				0,
				c_white,
				1
			);
		}
		else
		{
			draw_set_color(_projectile_color);
			draw_circle(_slot_x + (_slot_width * 0.5), _slot_y + 22, _circle_radius, false);
		}

		// Squad shells place their main combat unit inside the colored projectile circle.
		if (_projectile_squad_unit_sprite != noone && sprite_exists(_projectile_squad_unit_sprite))
		{
			var _unit_sprite_width = max(1, sprite_get_width(_projectile_squad_unit_sprite));
			var _unit_sprite_height = max(1, sprite_get_height(_projectile_squad_unit_sprite));
			var _unit_sprite_max_size = max(_unit_sprite_width, _unit_sprite_height);
			var _unit_icon_size = _circle_radius * projectile_squad_unit_icon_scale;
			var _unit_icon_scale = _unit_icon_size / _unit_sprite_max_size;
			var _unit_icon_width = _unit_sprite_width * _unit_icon_scale;
			var _unit_icon_height = _unit_sprite_height * _unit_icon_scale;
			var _unit_icon_center_x = _slot_x + (_slot_width * 0.5);
			var _unit_icon_center_y = _slot_y + 22;

			draw_sprite_stretched_ext(
				_projectile_squad_unit_sprite,
				0,
				_unit_icon_center_x - (_unit_icon_width * 0.5),
				_unit_icon_center_y - (_unit_icon_height * 0.5),
				_unit_icon_width,
				_unit_icon_height,
				c_white,
				_projectile_draw_alpha
			);
		}

		// Only stockpiled shells show a quantity; reusable shells are governed by Cannon reload.
		var _projectile_count_is_visible = _projectile_stack_count > 1
			|| _projectile_type == PROJECTILE_TYPE.CORRUPTION;

		if (_projectile_count_is_visible)
		{
			draw_set_halign(fa_center);
			draw_set_valign(fa_middle);
			draw_set_alpha(_projectile_draw_alpha);
			draw_set_color(COLOR_HUD_BACKGROUND);
			draw_circle(_slot_x + _slot_width - 15, _slot_y + 14, 12, false);
			draw_set_color(COLOR_HUD_TEXT);
			draw_text(_slot_x + _slot_width - 15, _slot_y + 14, string(_projectile_stack_count));
		}

		draw_set_color(COLOR_HUD_TEXT);
		var _projectile_name = projectile_names[_projectile_type];

		if (_projectile_type == PROJECTILE_TYPE.CULTIST)
		{
			if (!_projectile_is_available)
			{
				_projectile_name = "";
			}
			else if (variable_global_exists("cannon_projectile_payload_queue")
				&& _projectile_index < array_length(global.cannon_projectile_payload_queue))
			{
				var _cultist_payload = global.cannon_projectile_payload_queue[_projectile_index];

				if (instance_exists(_cultist_payload)
					&& variable_instance_exists(_cultist_payload, "squad")
					&& is_struct(_cultist_payload.squad)
					&& _cultist_payload.squad.name != "")
				{
					var _projectile_squad_name = squad_name_display_get(_cultist_payload.squad.name);
					_projectile_name = string_copy(_projectile_squad_name, 1, 10);
				}
				else if (instance_exists(_cultist_payload)
					&& variable_instance_exists(_cultist_payload, "cultist_name")
					&& _cultist_payload.cultist_name != "")
				{
					_projectile_name = string_copy(_cultist_payload.cultist_name, 1, 10);
				}
			}
		}
		else if (_projectile_type == PROJECTILE_TYPE.BUILDING_SHELL
			&& variable_global_exists("cannon_projectile_payload_queue")
			&& _projectile_index >= 0
			&& _projectile_index < array_length(global.cannon_projectile_payload_queue))
		{
			var _building_payload = global.cannon_projectile_payload_queue[_projectile_index];

			if (is_struct(_building_payload)
				&& variable_struct_exists(_building_payload, "building_name"))
			{
				_projectile_name = string_copy(_building_payload.building_name, 1, 12);
			}
		}

		draw_text(_slot_x + (_slot_width * 0.5), _slot_y + projectile_name_offset_y, _projectile_name);

		draw_set_alpha(_projectile_draw_alpha);
		draw_set_color(COLOR_HUD_TEXT);

		if (_projectile_index >= 0
			&& _projectile_index < array_length(_projectile_payload_data)
			&& _projectile_payload_data[_projectile_index] != noone)
		{
			var _payload_data = _projectile_payload_data[_projectile_index];
			var _payload_icon_y = _slot_y + projectile_payload_offset_y;
			var _payload_center_x = _slot_x + (_slot_width * 0.5);
			var _payload_width = projectile_payload_icon_size;

			if (_payload_data.pitling_count > 0)
			{
				_payload_width += projectile_payload_icon_gap
					+ string_width(string(_payload_data.pitling_count))
					+ projectile_payload_count_gap
					+ projectile_payload_icon_size;
			}

			if (_payload_data.skeleton_count > 0)
			{
				_payload_width += projectile_payload_icon_gap
					+ string_width(string(_payload_data.skeleton_count))
					+ projectile_payload_count_gap
					+ projectile_payload_icon_size;
			}

			var _payload_draw_x = _payload_center_x - (_payload_width * 0.5);

			draw_set_halign(fa_left);
			draw_set_valign(fa_middle);

			if (_payload_data.demon_sprite != noone && sprite_exists(_payload_data.demon_sprite))
			{
				draw_sprite_stretched_ext(
					_payload_data.demon_sprite,
					0,
					_payload_draw_x,
					_payload_icon_y - (projectile_payload_icon_size * 0.5),
					projectile_payload_icon_size,
					projectile_payload_icon_size,
					c_white,
					_projectile_draw_alpha
				);
			}

			_payload_draw_x += projectile_payload_icon_size;

			if (_payload_data.pitling_count > 0)
			{
				_payload_draw_x += projectile_payload_icon_gap;
				draw_set_color(COLOR_HUD_PROJECTILE_DESCRIPTION);
				draw_text(_payload_draw_x, _payload_icon_y, string(_payload_data.pitling_count));
				_payload_draw_x += string_width(string(_payload_data.pitling_count)) + projectile_payload_count_gap;

				if (sprite_exists(s_demon))
				{
					draw_sprite_stretched_ext(
						s_demon,
						0,
						_payload_draw_x,
						_payload_icon_y - (projectile_payload_icon_size * 0.5),
						projectile_payload_icon_size,
						projectile_payload_icon_size,
						c_white,
						_projectile_draw_alpha
					);
				}

				_payload_draw_x += projectile_payload_icon_size;
			}

			if (_payload_data.skeleton_count > 0)
			{
				_payload_draw_x += projectile_payload_icon_gap;
				draw_set_color(COLOR_HUD_PROJECTILE_DESCRIPTION);
				draw_text(_payload_draw_x, _payload_icon_y, string(_payload_data.skeleton_count));
				_payload_draw_x += string_width(string(_payload_data.skeleton_count)) + projectile_payload_count_gap;

				if (sprite_exists(s_skeleton))
				{
					draw_sprite_stretched_ext(
						s_skeleton,
						0,
						_payload_draw_x,
						_payload_icon_y - (projectile_payload_icon_size * 0.5),
						projectile_payload_icon_size,
						projectile_payload_icon_size,
						c_white,
						_projectile_draw_alpha
					);
				}
			}

			draw_set_halign(fa_center);
			draw_set_valign(fa_middle);
		}

		if (_projectile_can_fire)
		{
			var _key_prompt_text = projectile_key_prompt_prefix + string(_projectile_display_index + 1);

			if (_is_current_projectile)
			{
				draw_set_color(COLOR_HUD_TEXT);
			}
			else
			{
				draw_set_color(COLOR_HUD_PROJECTILE_DESCRIPTION);
			}

			draw_text(
				_slot_x + (_slot_width * 0.5),
				_slot_y + _slot_height + projectile_aim_prompt_gap,
				_key_prompt_text
			);
		}
	}

	// Projectile descriptions stay hidden until the player points at a visible slot.
	var _description_projectile_index = _hovered_projectile_index;

	if (_description_projectile_index >= 0)
	{
		var _description_slot = _projectile_display_slots[_description_projectile_index];
		var _description_queue_index = _description_slot.queue_index;
		var _description_type = PROJECTILE_TYPE.DAMAGE;
		var _description_payload = noone;
		var _draw_cultist_payload_card = false;

		_description_type = _description_slot.projectile_type;

		var _description_projectile_is_active = instance_exists(_projectile_game_controller)
			&& _projectile_game_controller.cannon_projectile_type_can_fire_in_current_phase(_description_type);
		var _description_draw_alpha = _description_projectile_is_active ? 1 : projectile_day_alpha;

		if (_hovered_projectile_index >= 0
			&& _description_type == PROJECTILE_TYPE.CULTIST
			&& _combat_projectiles_are_active
			&& variable_global_exists("cannon_projectile_payload_queue")
			&& _description_queue_index >= 0
			&& _description_queue_index < array_length(global.cannon_projectile_payload_queue))
		{
			_description_payload = global.cannon_projectile_payload_queue[_description_queue_index];
			_draw_cultist_payload_card = instance_exists(_description_payload)
				&& variable_instance_exists(_description_payload, "cultist_points");
		}

		var _description_bottom_y = _projectile_base_y
			- projectile_description_gap
			- _selected_projectile_matchup_height
			- _reload_ui_reserved_height;

		if (_draw_cultist_payload_card && instance_exists(o_game_controller))
		{
			var _card_width = min(300, _gui_width - 36);
			var _card_height = 570;
			var _card_margin = 18;
			var _card_x = min(_projectile_mouse_x + 18, _gui_width - _card_width - _card_margin);
			var _card_y = max(
				_card_margin,
				_projectile_base_y
					- _card_height
					- projectile_description_gap
					- _selected_projectile_matchup_height
					- _reload_ui_reserved_height
			);
			var _game_controller = instance_find(o_game_controller, 0);

			if (variable_instance_exists(_game_controller, "cultist_stats_card_draw"))
			{
				_game_controller.cultist_stats_card_draw(_description_payload, _card_x, _card_y);
			}
		}
		else
		{
			var _description_width = min(
				projectile_description_width,
				_gui_width - (projectile_description_screen_margin * 2)
			);
			var _description_text_width = _description_width - (projectile_description_padding * 2);
			var _description_name = projectile_names[_description_type];
			var _description_text = projectile_descriptions[_description_type];
			var _enchantment_description = projectile_enchantment_description_get(_description_type);
			var _upgrade_description = projectile_shell_factory_upgrade_description_get(_description_type);

			if (_enchantment_description != "")
			{
				_description_text += "\n\n" + _enchantment_description;
			}

			if (_upgrade_description != "")
			{
				_description_text += "\n\n" + _upgrade_description;
			}

			// Payload shells use the stored unit or structure name as their title.
			if (_description_type == PROJECTILE_TYPE.CULTIST
				&& variable_global_exists("cannon_projectile_payload_queue")
				&& _description_queue_index >= 0
				&& _description_queue_index < array_length(global.cannon_projectile_payload_queue))
			{
				_description_payload = global.cannon_projectile_payload_queue[_description_queue_index];

				if (instance_exists(_description_payload)
					&& variable_instance_exists(_description_payload, "squad")
					&& is_struct(_description_payload.squad)
					&& _description_payload.squad.name != "")
				{
					_description_name = squad_name_display_get(_description_payload.squad.name);
				}
				else if (instance_exists(_description_payload)
					&& variable_instance_exists(_description_payload, "cultist_name")
					&& _description_payload.cultist_name != "")
				{
					_description_name = _description_payload.cultist_name;
				}
			}
			else if (_description_type == PROJECTILE_TYPE.BUILDING_SHELL
				&& variable_global_exists("cannon_projectile_payload_queue")
				&& _description_queue_index >= 0
				&& _description_queue_index < array_length(global.cannon_projectile_payload_queue))
			{
				_description_payload = global.cannon_projectile_payload_queue[_description_queue_index];

				if (is_struct(_description_payload)
					&& variable_struct_exists(_description_payload, "building_name"))
				{
					_description_name = _description_payload.building_name;
				}
			}

			// Measure wrapped content first so the frame grows upward from a stable bottom edge.
			var _description_title_height = string_height(_description_name);
			var _description_text_height = string_height_ext(
				_description_text,
				projectile_description_line_separation,
				_description_text_width
			);
			var _description_height = max(
				projectile_description_minimum_height,
				(projectile_description_padding * 2)
					+ _description_title_height
					+ projectile_description_title_gap
					+ _description_text_height
			);
			var _description_x = (_gui_width - _description_width) * 0.5;
			var _description_y = _description_bottom_y - _description_height;
			var _description_text_y = _description_y
				+ projectile_description_padding
				+ _description_title_height
				+ projectile_description_title_gap;

			draw_set_halign(fa_left);
			draw_set_valign(fa_top);
			draw_set_alpha(0.84 * _description_draw_alpha);
			draw_set_color(COLOR_HUD_BACKGROUND);
			draw_rectangle(
				_description_x,
				_description_y,
				_description_x + _description_width,
				_description_bottom_y,
				false
			);

			draw_set_alpha(_description_draw_alpha);
			draw_set_color(COLOR_HUD_TEXT);
			draw_text(
				_description_x + projectile_description_padding,
				_description_y + projectile_description_padding,
				_description_name
			);

			draw_set_color(COLOR_HUD_PROJECTILE_DESCRIPTION);
			draw_text_ext(
				_description_x + projectile_description_padding,
				_description_text_y,
				_description_text,
				projectile_description_line_separation,
				_description_text_width
			);
		}
	}

}

// Draw squad-card help and squad information above the rest of the HUD.
if (_regular_hud_is_visible && variable_global_exists("squads"))
{
	if (variable_global_exists("ui_font") && font_exists(global.ui_font))
	{
		draw_set_font(global.ui_font);
	}

	var _squad_info_mouse_x = device_mouse_x_to_gui(0);
	var _squad_info_mouse_y = device_mouse_y_to_gui(0);
	var _hovered_roster_squad = hud_squad_at_gui_position(_squad_info_mouse_x, _squad_info_mouse_y);

	if (is_struct(_hovered_roster_squad))
	{
		var _hint_text = squad_info_is_pinned && squad_info_squad == _hovered_roster_squad
			? "RMB: unpin info"
			: "RMB: pin info";
		var _hint_padding = 7;
		var _hint_width = string_width(_hint_text) + (_hint_padding * 2);
		var _hint_height = string_height(_hint_text) + (_hint_padding * 2);
		var _hint_x = min(_squad_info_mouse_x + 14, display_get_gui_width() - _hint_width - 8);
		var _hint_y = min(_squad_info_mouse_y + 14, display_get_gui_height() - _hint_height - 8);

		draw_set_alpha(0.94);
		draw_set_color(COLOR_HUD_BACKGROUND);
		draw_rectangle(_hint_x, _hint_y, _hint_x + _hint_width, _hint_y + _hint_height, false);
		draw_set_alpha(1);
		draw_set_color(COLOR_PROJECTILE_SUMMON);
		draw_rectangle(_hint_x, _hint_y, _hint_x + _hint_width, _hint_y + _hint_height, true);
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		draw_set_color(COLOR_HUD_TEXT);
		draw_text(_hint_x + _hint_padding, _hint_y + _hint_padding, _hint_text);
	}

	if (is_struct(squad_info_squad))
	{
		var _gui_width = display_get_gui_width();
		var _gui_height = display_get_gui_height();
		var _window_width = min(squad_info_window_width, _gui_width - 36);
		var _squad_unit_count = array_length(squad_info_squad.unit_objects);
		var _icon_step = squad_info_unit_icon_size + squad_info_unit_icon_gap;
		var _icon_available_width = _window_width - (squad_info_padding * 2);
		var _icon_column_count = max(1, floor((_icon_available_width + squad_info_unit_icon_gap) / _icon_step));
		var _icon_row_count = max(1, ceil(_squad_unit_count / _icon_column_count));
		var _additional_icon_row_count = max(0, _icon_row_count - 1);
		var _window_height_growth = _additional_icon_row_count * _icon_step;
		var _window_height = min(squad_info_window_height + _window_height_growth, _gui_height - 36);
		var _window_x = (_gui_width - _window_width) * 0.5;
		var _window_y = max(18, (_gui_height - _window_height) * 0.5);
		var _hovered_unit_index = -1;
		var _hovered_relic = RELIC.NONE;
		var _living_unit_count = 0;
		var _squad_hp_values = squad_total_hp_get(squad_info_squad);
		var _icon_grid_bottom = _window_y + squad_info_unit_grid_offset_y
			+ (_icon_row_count * squad_info_unit_icon_size)
			+ (max(0, _icon_row_count - 1) * squad_info_unit_icon_gap);
		var _summary_y = _icon_grid_bottom + 14;
		var _unit_details_title_y = _summary_y + 26;
		var _unit_details_y = _unit_details_title_y + 30;

		draw_set_alpha(0.97);
		draw_set_color(COLOR_HUD_BACKGROUND);
		draw_rectangle(_window_x, _window_y, _window_x + _window_width, _window_y + _window_height, false);
		draw_set_alpha(1);
		draw_set_color(COLOR_PROJECTILE_SUMMON);
		draw_rectangle(_window_x, _window_y, _window_x + _window_width, _window_y + _window_height, true);
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		draw_set_color(COLOR_HUD_TEXT);
		draw_text(_window_x + squad_info_padding, _window_y + 16, squad_name_display_get(squad_info_squad.name));
		draw_set_halign(fa_right);
		draw_set_color(squad_info_is_pinned ? COLOR_PROJECTILE_SUMMON : COLOR_HUD_PROJECTILE_DESCRIPTION);
		draw_text(
			_window_x + _window_width - squad_info_padding,
			_window_y + 16,
			squad_info_is_pinned ? "PINNED" : "RMB ON CARD: PIN"
		);
		draw_set_halign(fa_left);

		// Unholy Trait belongs to the whole squad and is always visible above its members.
		var _unholy_trait = squad_unholy_trait_get(squad_info_squad);
		var _unholy_trait_label = "Unholy Trait: ";
		var _unholy_trait_x = _window_x + squad_info_padding;
		var _unholy_trait_y = _window_y + squad_info_unholy_trait_offset_y;
		var _unholy_trait_text = _unholy_trait_label + squad_unholy_trait_name_get(_unholy_trait);
		var _unholy_trait_is_hovered = _unholy_trait != UNHOLY_TRAIT.NONE
			&& point_in_rectangle(
				_squad_info_mouse_x,
				_squad_info_mouse_y,
				_unholy_trait_x,
				_unholy_trait_y,
				_unholy_trait_x + string_width(_unholy_trait_text),
				_unholy_trait_y + string_height(_unholy_trait_text)
			);
		draw_set_color(COLOR_HUD_PROJECTILE_DESCRIPTION);
		draw_text(_unholy_trait_x, _unholy_trait_y, _unholy_trait_label);
		draw_set_color(_unholy_trait == UNHOLY_TRAIT.NONE ? COLOR_HUD_PROJECTILE_DESCRIPTION : COLOR_PROJECTILE_SUMMON);
		draw_text(
			_unholy_trait_x + string_width(_unholy_trait_label),
			_unholy_trait_y,
			squad_unholy_trait_name_get(_unholy_trait)
		);

		// Relics occupy two permanent squad slots, including visible empty circles.
		var _relic_label_x = _window_x + squad_info_padding;
		var _relic_label_y = _window_y + squad_info_relic_offset_y
			+ (squad_info_relic_slot_size * 0.5);
		draw_set_halign(fa_left);
		draw_set_valign(fa_middle);
		draw_set_color(COLOR_HUD_PROJECTILE_DESCRIPTION);
		draw_text(_relic_label_x, _relic_label_y, "Relics:");

		for (var _relic_slot_index = 0;
			_relic_slot_index < BALANCE_SQUAD_RELIC_SLOT_COUNT;
			++_relic_slot_index)
		{
			var _relic = squad_relic_slot_get(squad_info_squad, _relic_slot_index);
			var _relic_rect = hud_squad_info_relic_slot_rect_get(
				_window_x,
				_window_y,
				_relic_slot_index
			);
			var _relic_center_x = _relic_rect.x + (_relic_rect.width * 0.5);
			var _relic_center_y = _relic_rect.y + (_relic_rect.height * 0.5);
			var _relic_radius = _relic_rect.width * 0.5;
			var _relic_is_hovered = point_in_rectangle(
				_squad_info_mouse_x,
				_squad_info_mouse_y,
				_relic_rect.x,
				_relic_rect.y,
				_relic_rect.x + _relic_rect.width,
				_relic_rect.y + _relic_rect.height
			);
			var _relic_is_filled = _relic != RELIC.NONE;

			draw_set_alpha(_relic_is_filled ? 0.9 : 0.42);
			draw_set_color(COLOR_SQUAD_CARD_BACKGROUND);
			draw_circle(_relic_center_x, _relic_center_y, _relic_radius, false);
			draw_set_alpha(1);
			draw_set_color(_relic_is_hovered
				? COLOR_PROJECTILE_SUMMON
				: (_relic_is_filled ? COLOR_SQUAD_CARD_BORDER : COLOR_HUD_PROJECTILE_DESCRIPTION));
			draw_circle(_relic_center_x, _relic_center_y, _relic_radius, true);

			var _relic_sprite = squad_relic_sprite_get(_relic);

			if (_relic_is_filled && sprite_exists(_relic_sprite))
			{
				var _relic_sprite_width = max(1, sprite_get_width(_relic_sprite));
				var _relic_sprite_height = max(1, sprite_get_height(_relic_sprite));
				var _relic_available_size = _relic_rect.width * 0.72;
				var _relic_sprite_scale = min(
					_relic_available_size / _relic_sprite_width,
					_relic_available_size / _relic_sprite_height
				);
				var _relic_sprite_x = _relic_center_x
					+ ((sprite_get_xoffset(_relic_sprite) - (_relic_sprite_width * 0.5))
						* _relic_sprite_scale);
				var _relic_sprite_y = _relic_center_y
					+ ((sprite_get_yoffset(_relic_sprite) - (_relic_sprite_height * 0.5))
						* _relic_sprite_scale);

				draw_sprite_ext(
					_relic_sprite,
					0,
					_relic_sprite_x,
					_relic_sprite_y,
					_relic_sprite_scale,
					_relic_sprite_scale,
					0,
					c_white,
					1
				);
			}

			if (_relic_is_hovered && _relic_is_filled)
			{
				_hovered_relic = _relic;
			}
		}

		draw_set_halign(fa_left);
		draw_set_valign(fa_top);

		// Draw one slot for every individual squad member.
		for (var _unit_index = 0; _unit_index < _squad_unit_count; ++_unit_index)
		{
			var _icon_unit = hud_squad_unit_instance_at_index_get(squad_info_squad, _unit_index);
			var _icon_unit_object = hud_squad_unit_object_at_index_get(squad_info_squad, _unit_index);
			var _unit_is_alive = instance_exists(_icon_unit);
			var _icon_rect = hud_squad_info_unit_icon_rect_get(
				_window_x,
				_window_y,
				_icon_column_count,
				_unit_index
			);
			var _icon_is_hovered = point_in_rectangle(
				_squad_info_mouse_x,
				_squad_info_mouse_y,
				_icon_rect.x,
				_icon_rect.y,
				_icon_rect.x + _icon_rect.width,
				_icon_rect.y + _icon_rect.height
			);

			if (_unit_is_alive)
			{
				_living_unit_count++;
			}

			var _slot_alpha = _icon_is_hovered
				? squad_info_unit_icon_hover_alpha
				: (_unit_is_alive ? squad_info_unit_icon_alive_alpha : squad_info_unit_icon_fallen_alpha);
			draw_set_alpha(_slot_alpha);
			draw_set_color(COLOR_SQUAD_CARD_BACKGROUND);
			draw_rectangle(_icon_rect.x, _icon_rect.y, _icon_rect.x + _icon_rect.width, _icon_rect.y + _icon_rect.height, false);
			draw_set_alpha(1);
			draw_set_color(
				_icon_is_hovered
					? COLOR_PROJECTILE_SUMMON
					: (_unit_is_alive ? COLOR_SQUAD_CARD_BORDER : COLOR_STATUS_NEGATIVE_RED)
			);
			draw_rectangle(_icon_rect.x, _icon_rect.y, _icon_rect.x + _icon_rect.width, _icon_rect.y + _icon_rect.height, true);

			var _unit_sprite = -1;

			if (_unit_is_alive)
			{
				_unit_sprite = _icon_unit.sprite_index;
			}
			else if (_icon_unit_object != noone)
			{
				_unit_sprite = object_get_sprite(_icon_unit_object);
			}

			if (_unit_sprite != -1)
			{
				var _sprite_width = max(1, sprite_get_width(_unit_sprite));
				var _sprite_height = max(1, sprite_get_height(_unit_sprite));
				var _sprite_scale = min((_icon_rect.width - 8) / _sprite_width, (_icon_rect.height - 8) / _sprite_height);
				var _sprite_center_x = _icon_rect.x + (_icon_rect.width * 0.5);
				var _sprite_center_y = _icon_rect.y + (_icon_rect.height * 0.5);
				var _sprite_x = _sprite_center_x + ((sprite_get_xoffset(_unit_sprite) - (_sprite_width * 0.5)) * _sprite_scale);
				var _sprite_y = _sprite_center_y + ((sprite_get_yoffset(_unit_sprite) - (_sprite_height * 0.5)) * _sprite_scale);

				draw_sprite_ext(
					_unit_sprite,
					0,
					_sprite_x,
					_sprite_y,
					_sprite_scale,
					_sprite_scale,
					0,
					c_white,
					_unit_is_alive ? 1 : squad_info_unit_icon_fallen_alpha
				);
			}

			if (_icon_is_hovered)
			{
				_hovered_unit_index = _unit_index;
			}
		}

		// Keep the squad-wide summary readable without interacting with the window.
		draw_set_color(COLOR_HUD_TEXT);
		draw_text(
			_window_x + squad_info_padding,
			_summary_y,
			"Living units: " + string(_living_unit_count) + " / " + string(_squad_unit_count)
				+ "    Squad HP: " + string_format(_squad_hp_values[0], 0, 1)
				+ " / " + string_format(_squad_hp_values[1], 0, 1)
		);

		if (_hovered_unit_index < 0)
		{
			draw_set_color(COLOR_HUD_PROJECTILE_DESCRIPTION);
			draw_text(
				_window_x + squad_info_padding,
				_unit_details_title_y,
				squad_info_is_pinned
					? "Hover a unit to inspect its current stats."
					: "Pin this window with RMB to inspect individual units."
			);
		}
		else
		{
			var _unit = hud_squad_unit_instance_at_index_get(squad_info_squad, _hovered_unit_index);
			var _selected_unit_object = hud_squad_unit_object_at_index_get(squad_info_squad, _hovered_unit_index);
			var _base_stats = hud_unit_base_stats_get(_selected_unit_object);
			var _stats_x = _window_x + squad_info_padding;
			var _stats_y = _unit_details_y;
			var _line_height = 23;

			draw_set_color(COLOR_HUD_TEXT);
			draw_text(
				_stats_x,
				_unit_details_title_y,
				hud_unit_display_name_get(_selected_unit_object)
					+ " - unit " + string(_hovered_unit_index + 1)
					+ " of " + string(_squad_unit_count)
			);

			if (!instance_exists(_unit))
			{
				draw_set_color(COLOR_STATUS_NEGATIVE_RED);
				draw_text(_stats_x, _stats_y, "This unit is not currently alive.");
			}
			else
			{
				if (!is_struct(_base_stats))
				{
					_base_stats = {
						max_hp: variable_instance_exists(_unit, "max_hp") ? _unit.max_hp : 0,
						armor: variable_instance_exists(_unit, "armor") ? _unit.armor : 100,
						magic_resistance: variable_instance_exists(_unit, "magic_resistance") ? _unit.magic_resistance : 100,
						damage: variable_instance_exists(_unit, "damage") ? _unit.damage : 0,
						magic_damage: variable_instance_exists(_unit, "magic_damage") ? _unit.magic_damage : 0,
						reload_time: variable_instance_exists(_unit, "reload_time") ? _unit.reload_time : room_speed,
						attack_radius: variable_instance_exists(_unit, "attack_radius") ? _unit.attack_radius : 0,
						move_speed: variable_instance_exists(_unit, "move_speed") ? _unit.move_speed : 0
					};
				}

				draw_set_color(COLOR_HUD_TEXT);

				if (variable_instance_exists(_unit, "hp") && variable_instance_exists(_unit, "max_hp"))
				{
					draw_text(_stats_x, _stats_y, "Current HP: " + string_format(_unit.hp, 0, 1) + " / " + string_format(_unit.max_hp, 0, 1));
					_stats_y += _line_height;
					hud_squad_info_stat_draw("Max HP", _unit.max_hp, _base_stats.max_hp, _stats_x, _stats_y, 1);
					_stats_y += _line_height;
				}

				if (variable_instance_exists(_unit, "damage"))
				{
					hud_squad_info_stat_draw("Damage", _unit.damage, _base_stats.damage, _stats_x, _stats_y, 1);
					_stats_y += _line_height;
				}

				if (variable_instance_exists(_unit, "magic_damage")
					&& (_unit.magic_damage > 0 || _base_stats.magic_damage > 0))
				{
					hud_squad_info_stat_draw("Magic damage", _unit.magic_damage, _base_stats.magic_damage, _stats_x, _stats_y, 1);
					_stats_y += _line_height;
				}

				if (variable_instance_exists(_unit, "reload_time"))
				{
					// Squad info compares permanent stats; terrain and combat effects are temporary.
					var _current_attack_speed = room_speed / max(1, _unit.reload_time);
					var _base_attack_speed = room_speed / max(1, _base_stats.reload_time);

					hud_squad_info_stat_draw("Attack speed", _current_attack_speed, _base_attack_speed, _stats_x, _stats_y, 2);
					_stats_y += _line_height;
				}

				if (variable_instance_exists(_unit, "attack_radius"))
				{
					hud_squad_info_stat_draw("Attack radius", _unit.attack_radius, _base_stats.attack_radius, _stats_x, _stats_y, 0);
					_stats_y += _line_height;
				}

				if (variable_instance_exists(_unit, "move_speed"))
				{
					hud_squad_info_stat_draw("Move speed", _unit.move_speed, _base_stats.move_speed, _stats_x, _stats_y, 2);
					_stats_y += _line_height;
				}

				if (variable_instance_exists(_unit, "armor"))
				{
					hud_squad_info_stat_draw("Armor", _unit.armor - 100, _base_stats.armor - 100, _stats_x, _stats_y, 1, "%");
					_stats_y += _line_height;
				}

				if (variable_instance_exists(_unit, "magic_resistance"))
				{
					hud_squad_info_stat_draw("Magic resistance", _unit.magic_resistance - 100, _base_stats.magic_resistance - 100, _stats_x, _stats_y, 1, "%");
				}
			}

			var _matchups = hud_unit_matchups_get(_selected_unit_object);
			var _matchup_x = _window_x + 300;
			var _matchup_y = _unit_details_y;
			var _matchup_icon_radius = 18;
			var _matchup_icon_gap = 44;
			var _matchup_sprite_size = 28;
			var _strong_count = array_length(_matchups.strong_against);
			var _weak_count = array_length(_matchups.weak_against);

			if (_strong_count > 0)
			{
				draw_set_color(COLOR_PROJECTILE_SUMMON);
				draw_text(_matchup_x, _matchup_y, "Strong vs");
				_matchup_y += 28;

				for (var _strong_index = 0; _strong_index < _strong_count; ++_strong_index)
				{
					var _strong_object = _matchups.strong_against[_strong_index];
					var _strong_sprite = object_get_sprite(_strong_object);
					var _strong_x = _matchup_x + _matchup_icon_radius + (_strong_index * _matchup_icon_gap);
					var _strong_y = _matchup_y + _matchup_icon_radius;

					draw_set_color(COLOR_PROJECTILE_SUMMON);
					draw_circle(_strong_x, _strong_y, _matchup_icon_radius, false);
					draw_set_color(c_white);
					draw_circle(_strong_x, _strong_y, _matchup_icon_radius, true);

					if (_strong_sprite != -1)
					{
						var _strong_width = max(1, sprite_get_width(_strong_sprite));
						var _strong_height = max(1, sprite_get_height(_strong_sprite));
						var _strong_scale = min(_matchup_sprite_size / _strong_width, _matchup_sprite_size / _strong_height);
						var _strong_draw_x = _strong_x + ((sprite_get_xoffset(_strong_sprite) - (_strong_width * 0.5)) * _strong_scale);
						var _strong_draw_y = _strong_y + ((sprite_get_yoffset(_strong_sprite) - (_strong_height * 0.5)) * _strong_scale);
						draw_sprite_ext(_strong_sprite, 0, _strong_draw_x, _strong_draw_y, _strong_scale, _strong_scale, 0, c_white, 1);
					}
				}

				_matchup_y += 58;
			}

			if (_weak_count > 0)
			{
				draw_set_color(COLOR_STATUS_NEGATIVE_RED);
				draw_text(_matchup_x, _matchup_y, "Weak vs");
				_matchup_y += 28;

				for (var _weak_index = 0; _weak_index < _weak_count; ++_weak_index)
				{
					var _weak_object = _matchups.weak_against[_weak_index];
					var _weak_sprite = object_get_sprite(_weak_object);
					var _weak_x = _matchup_x + _matchup_icon_radius + (_weak_index * _matchup_icon_gap);
					var _weak_y = _matchup_y + _matchup_icon_radius;

					draw_set_color(COLOR_STATUS_NEGATIVE_RED);
					draw_circle(_weak_x, _weak_y, _matchup_icon_radius, false);
					draw_set_color(c_white);
					draw_circle(_weak_x, _weak_y, _matchup_icon_radius, true);

					if (_weak_sprite != -1)
					{
						var _weak_width = max(1, sprite_get_width(_weak_sprite));
						var _weak_height = max(1, sprite_get_height(_weak_sprite));
						var _weak_scale = min(_matchup_sprite_size / _weak_width, _matchup_sprite_size / _weak_height);
						var _weak_draw_x = _weak_x + ((sprite_get_xoffset(_weak_sprite) - (_weak_width * 0.5)) * _weak_scale);
						var _weak_draw_y = _weak_y + ((sprite_get_yoffset(_weak_sprite) - (_weak_height * 0.5)) * _weak_scale);
						draw_sprite_ext(_weak_sprite, 0, _weak_draw_x, _weak_draw_y, _weak_scale, _weak_scale, 0, c_white, 1);
					}
				}
			}
		}

		// Trait help is drawn last so it remains above unit details and the squad window.
		if (_unholy_trait_is_hovered)
		{
			hud_squad_info_unholy_tooltip_draw(
				_unholy_trait,
				_squad_info_mouse_x,
				_squad_info_mouse_y
			);
		}
		else if (_hovered_relic != RELIC.NONE)
		{
			hud_squad_info_relic_tooltip_draw(
				_hovered_relic,
				_squad_info_mouse_x,
				_squad_info_mouse_y
			);
		}
	}
}

// Keep all active cheat shortcuts visible without opening the debug menu.
cheat_hud_draw();

// Restore default draw state.
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);

// Keep the world meter visible during normal play and while selecting a target.
if (global.focus_window == FOCUS_WINDOW.NOONE
	|| global.focus_window == FOCUS_WINDOW.TARGET_SELECTION)
{
	cannon_satisfaction_world_ui_draw();
}
