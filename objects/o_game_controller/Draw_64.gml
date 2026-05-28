// Draw night tint over the world while keeping HUD readable.
if (variable_global_exists("ui_font") && font_exists(global.ui_font))
{
	draw_set_font(global.ui_font);
}

if (global.day_phase == DAY_PHASE.NIGHT)
{
	draw_set_alpha(night_overlay_alpha);
	draw_set_color(COLOR_NIGHT_OVERLAY);
	draw_rectangle(0, 0, camera_view_width, camera_view_height, false);
	draw_set_alpha(1);
	draw_set_color(c_white);
}

// Draw target selection radius under the cursor.
if (global.focus_window == FOCUS_WINDOW.TARGET_SELECTION && instance_exists(o_camera_controller))
{
	var _camera_controller = instance_find(o_camera_controller, 0);
	var _mouse_x = device_mouse_x_to_gui(0);
	var _mouse_y = device_mouse_y_to_gui(0);
	var _radius_scale = camera_view_width / _camera_controller.view_width;
	var _draw_radius = target_selection_radius * _radius_scale;
	var _target_color = COLOR_PROJECTILE_DAMAGE;

	if (target_selection_projectile_type == PROJECTILE_TYPE.CORRUPTION)
	{
		_target_color = COLOR_PROJECTILE_CORRUPTION;
	}
	else if (target_selection_projectile_type == PROJECTILE_TYPE.SUMMON)
	{
		_target_color = COLOR_PROJECTILE_SUMMON;
	}
	else if (target_selection_projectile_type == PROJECTILE_TYPE.RALLY)
	{
		_target_color = COLOR_PROJECTILE_RALLY;
	}

	draw_set_color(_target_color);
	draw_set_alpha(target_selection_alpha);
	draw_circle(_mouse_x, _mouse_y, _draw_radius, false);
	draw_set_alpha(target_selection_outline_alpha);
	draw_circle(_mouse_x, _mouse_y, _draw_radius, true);

	draw_set_color(c_white);
	draw_set_alpha(1);
}

// Draw cultist demon selection window.
if (global.focus_window == FOCUS_WINDOW.CULTIST_DEMON_SELECTION)
{
	var _cultist = get_current_cultist();
	var _panel_x = (camera_view_width - cultist_panel_width) * 0.5;
	var _panel_y = (camera_view_height - cultist_panel_height) * 0.5;
	var _button_start_x = _panel_x + 70;
	var _button_y = _panel_y + 360;
	var _button_step = cultist_selection_button_width + cultist_selection_button_gap;
	var _name_text = string_copy(keyboard_string, 1, 16);
	var _mouse_x = device_mouse_x_to_gui(0);
	var _mouse_y = device_mouse_y_to_gui(0);
	var _hovered_demon_type = DEMON_TYPE.NONE;
	var _recommended_demon_type = DEMON_TYPE.NONE;

	draw_set_alpha(0.55);
	draw_set_color(c_black);
	draw_rectangle(0, 0, camera_view_width, camera_view_height, false);

	draw_set_alpha(1);
	draw_set_color(COLOR_HUD_BACKGROUND);
	draw_rectangle(_panel_x, _panel_y, _panel_x + cultist_panel_width, _panel_y + cultist_panel_height, false);
	draw_set_color(c_white);
	draw_rectangle(_panel_x, _panel_y, _panel_x + cultist_panel_width, _panel_y + cultist_panel_height, true);

	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_set_color(COLOR_HUD_TEXT);
	draw_text(_panel_x + (cultist_panel_width * 0.5), _panel_y + 34, "Choose Cultist Demon Form");

	if (instance_exists(_cultist))
	{
		var _body_points = _cultist.cultist_points[CULTIST_STAT.BODY];
		var _spirit_points = _cultist.cultist_points[CULTIST_STAT.SPIRIT];
		var _fervor_points = _cultist.cultist_points[CULTIST_STAT.FERVOR];
		var _stat_x = _panel_x + 90;
		var _stat_y = _panel_y + 110;
		var _stat_gap = 58;
		var _box_size = 12;
		var _box_gap = 5;
		var _stat_names = ["Body", "Fervor", "Spirit"];
		var _stat_notes = ["HP, Armor, Physical damage", "Crit chance, Attack, Ability Recharge", "Exp, Magic damage, Magic power, Resistance"];
		var _stat_points = [_body_points, _fervor_points, _spirit_points];
		var _stat_colors = [COLOR_CULTIST_BODY, COLOR_CULTIST_FERVOR, COLOR_CULTIST_SPIRIT];

		// Recommend the demon form that best fits the cultist's strongest attribute.
		if (_body_points >= _fervor_points && _body_points >= _spirit_points)
		{
			_recommended_demon_type = DEMON_TYPE.BRUTE;
		}
		else if (_fervor_points >= _spirit_points)
		{
			_recommended_demon_type = DEMON_TYPE.IMP;
		}
		else
		{
			_recommended_demon_type = DEMON_TYPE.WARLOCK;
		}

		draw_set_halign(fa_left);

		for (var _stat_index = 0; _stat_index < CULTIST_STAT.COUNT; ++_stat_index)
		{
			var _draw_y = _stat_y + (_stat_gap * _stat_index);

			draw_set_color(_stat_colors[_stat_index]);
			draw_text(_stat_x, _draw_y, _stat_names[_stat_index]);
			draw_set_color(_stat_colors[_stat_index]);
			draw_text(_stat_x, _draw_y + 20, _stat_notes[_stat_index]);

			for (var _point_index = 0; _point_index < _stat_points[_stat_index]; ++_point_index)
			{
				var _box_x = _panel_x + 345 + ((_box_size + _box_gap) * _point_index);
				var _box_y = _draw_y - 7;

				draw_set_color(_stat_colors[_stat_index]);
				draw_rectangle(_box_x, _box_y, _box_x + _box_size, _box_y + _box_size, false);
			}
		}

		var _name_input_x = _panel_x + 90;
		var _name_input_y = _panel_y + 310;
		var _name_input_width = 380;
		var _name_input_height = 40;
		var _name_input_text_x = _name_input_x + 14;
		var _name_input_text_y = _name_input_y + (_name_input_height * 0.5);

		draw_set_color(COLOR_HUD_TEXT);
		draw_text(_name_input_x, _panel_y + 288, "Cultist name");
		draw_set_color(c_white);
		draw_rectangle(_name_input_x, _name_input_y, _name_input_x + _name_input_width, _name_input_y + _name_input_height, true);
		draw_text(_name_input_text_x, _name_input_text_y, _name_text);

		// Blink the name input caret while this setup window owns keyboard input.
		if ((current_time div 500) mod 2 == 0)
		{
			var _caret_x = _name_input_text_x + string_width(_name_text);
			var _caret_y = _name_input_text_y;

			draw_set_color(COLOR_HUD_TEXT);
			draw_line(_caret_x + 2, _caret_y - 8, _caret_x + 2, _caret_y + 8);
		}
	}

	var _preview_name = _name_text;

	if (_preview_name == "" && instance_exists(_cultist))
	{
		_preview_name = "Cultist " + string(cultist_selection_index + 1);
	}

	var _preview_object = cultist_demon_object_get(cultist_selected_demon_type);
	var _preview_sprite = object_get_sprite(_preview_object);

	if (_preview_sprite != -1)
	{
		var _preview_x = _panel_x + 585;
		var _preview_y = _panel_y + 332;
		var _preview_scale = 2.3;
		var _preview_frame_count = max(sprite_get_number(_preview_sprite), 1);
		var _preview_frame = (current_time div 120) mod _preview_frame_count;

		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		draw_set_color(COLOR_HUD_TEXT);
		draw_text(_preview_x, _panel_y + 102, _preview_name);
		draw_sprite_ext(_preview_sprite, _preview_frame, _preview_x, _preview_y, _preview_scale, _preview_scale, 0, c_white, 1);
	}

	var _button_count = array_length(cultist_selection_buttons);

	for (var _button_index = 0; _button_index < _button_count; ++_button_index)
	{
		var _demon_type = cultist_selection_buttons[_button_index];
		var _button_x = _button_start_x + (_button_step * _button_index);
		var _is_selected = _demon_type == cultist_selected_demon_type;
		var _is_hovered = _mouse_x >= _button_x && _mouse_x <= _button_x + cultist_selection_button_width
			&& _mouse_y >= _button_y && _mouse_y <= _button_y + cultist_selection_button_height;

		if (_is_hovered)
		{
			_hovered_demon_type = _demon_type;
		}

		// Draw readable demon buttons with a stronger selected state.
		if (_is_selected)
		{
			draw_set_color(COLOR_CULTIST_FERVOR);
			draw_rectangle(_button_x, _button_y, _button_x + cultist_selection_button_width, _button_y + cultist_selection_button_height, false);
			draw_set_color(c_white);
			draw_rectangle(_button_x, _button_y, _button_x + cultist_selection_button_width, _button_y + cultist_selection_button_height, true);
		}
		else
		{
			draw_set_color(c_black);
			draw_rectangle(_button_x, _button_y, _button_x + cultist_selection_button_width, _button_y + cultist_selection_button_height, false);
			draw_set_color(_is_hovered ? COLOR_CULTIST_FERVOR : c_white);
			draw_rectangle(_button_x, _button_y, _button_x + cultist_selection_button_width, _button_y + cultist_selection_button_height, true);
		}

		draw_set_halign(fa_center);
		draw_set_color(_is_selected ? c_black : COLOR_HUD_TEXT);
		draw_text(_button_x + (cultist_selection_button_width * 0.5), _button_y + (cultist_selection_button_height * 0.5), cultist_demon_name_get(_demon_type));

		if (_demon_type == _recommended_demon_type)
		{
			draw_set_color(COLOR_HEALTH_BAR);
			draw_text(_button_x + (cultist_selection_button_width * 0.5), _button_y + cultist_selection_button_height + 18, "RECOMMENDED");
		}
	}

	var _confirm_x = _panel_x + cultist_panel_width - 210;
	var _confirm_y = _panel_y + cultist_panel_height - 78;
	var _confirm_width = 150;
	var _confirm_height = 44;

	draw_set_color(c_white);
	draw_rectangle(_confirm_x, _confirm_y, _confirm_x + _confirm_width, _confirm_y + _confirm_height, true);
	draw_set_halign(fa_center);
	draw_set_color(COLOR_HUD_TEXT);
	draw_text(_confirm_x + (_confirm_width * 0.5), _confirm_y + (_confirm_height * 0.5), "Confirm");

	// Draw hover details for the demon under the cursor.
	if (_hovered_demon_type != DEMON_TYPE.NONE)
	{
		var _hover_width = 520;
		var _hover_height = 300;
		var _hover_x = min(_mouse_x + 18, camera_view_width - _hover_width - 18);
		var _hover_y = min(_mouse_y + 18, camera_view_height - _hover_height - 18);
		var _hover_padding = 14;
		var _ability_x = _hover_x + 285;

		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		draw_set_alpha(0.96);
		draw_set_color(COLOR_HUD_BACKGROUND);
		draw_rectangle(_hover_x, _hover_y, _hover_x + _hover_width, _hover_y + _hover_height, false);
		draw_set_alpha(1);
		draw_set_color(COLOR_CULTIST_FERVOR);
		draw_rectangle(_hover_x, _hover_y, _hover_x + _hover_width, _hover_y + _hover_height, true);

		draw_set_color(COLOR_HUD_TEXT);
		draw_text(_hover_x + _hover_padding, _hover_y + _hover_padding, cultist_demon_name_get(_hovered_demon_type));

		draw_set_color(COLOR_HUD_PROJECTILE_DESCRIPTION);
		draw_text(_hover_x + _hover_padding, _hover_y + 40, cultist_demon_description_get(_hovered_demon_type));

		draw_set_color(COLOR_HUD_TEXT);
		draw_text(_hover_x + _hover_padding, _hover_y + 70, "Stats");

		var _hover_stats = cultist_base_stats_get(_hovered_demon_type);
		var _hover_body = 0;
		var _hover_spirit = 0;
		var _hover_fervor = 0;

		if (instance_exists(_cultist))
		{
			_hover_body = _cultist.cultist_points[CULTIST_STAT.BODY];
			_hover_spirit = _cultist.cultist_points[CULTIST_STAT.SPIRIT];
			_hover_fervor = _cultist.cultist_points[CULTIST_STAT.FERVOR];
		}

		var _stat_labels = [
			"HP",
			"Armor",
			"Physical damage",
			"Crit chance",
			"Attack speed",
			"Ability Recharge",
			"Exp",
			"Magic power",
			"Resistance"
		];
		var _stat_base_values = [
			_hover_stats.hp,
			_hover_stats.armor,
			_hover_stats.damage,
			_hover_stats.crit_chance,
			_hover_stats.attack_speed,
			_hover_stats.abilities_cd_spd,
			_hover_stats.exp_effectiveness,
			_hover_stats.magic_effectiveness,
			_hover_stats.resistance
		];
		var _stat_bonuses = [
			_hover_stats.hp * (_hover_body * 0.05),
			_hover_stats.armor * (_hover_body * 0.05),
			_hover_stats.damage * (_hover_body * 0.05),
			_hover_stats.crit_chance * (_hover_fervor * 0.05),
			_hover_stats.attack_speed * (_hover_fervor * 0.07),
			_hover_stats.abilities_cd_spd * (_hover_fervor * 0.07),
			_hover_stats.exp_effectiveness * (_hover_spirit * 0.07),
			_hover_stats.magic_effectiveness * (_hover_spirit * 0.07),
			_hover_stats.resistance * (_hover_spirit * 0.07)
		];
		var _stat_colors = [
			COLOR_CULTIST_BODY,
			COLOR_CULTIST_BODY,
			COLOR_CULTIST_BODY,
			COLOR_CULTIST_FERVOR,
			COLOR_CULTIST_FERVOR,
			COLOR_CULTIST_FERVOR,
			COLOR_CULTIST_SPIRIT,
			COLOR_CULTIST_SPIRIT,
			COLOR_CULTIST_SPIRIT
		];

		if (_hover_stats.magic_damage > 0)
		{
			_stat_labels[2] = "Magic damage";
			_stat_base_values[2] = _hover_stats.magic_damage;
			_stat_bonuses[2] = _hover_stats.magic_damage * (_hover_spirit * 0.05);
			_stat_colors[2] = COLOR_CULTIST_SPIRIT;
		}

		var _stat_count = array_length(_stat_labels);
		var _stat_line_height = 16;
		var _stat_value_x = _hover_x + _hover_padding;

		for (var _hover_stat_index = 0; _hover_stat_index < _stat_count; ++_hover_stat_index)
		{
			var _stat_y = _hover_y + 94 + (_stat_line_height * _hover_stat_index);
			var _base_value = _stat_base_values[_hover_stat_index];
			var _bonus_value = _stat_bonuses[_hover_stat_index];
			var _final_value = _base_value + _bonus_value;
			var _line_text = _stat_labels[_hover_stat_index] + ": " + string_format(_final_value, 0, 2);
			var _bonus_text = " (+" + string_format(_bonus_value, 0, 2) + ")";

			if (_hover_stat_index == 3)
			{
				_line_text = _stat_labels[_hover_stat_index] + ": " + string_format(_final_value * 100, 0, 1) + "%";
				_bonus_text = " (+" + string_format(_bonus_value * 100, 0, 1) + "%)";
			}
			else if (_hover_stat_index == 1)
			{
				_line_text = _stat_labels[_hover_stat_index] + ": " + string_format(_final_value - 100, 0, 1) + "%";
				_bonus_text = " (+" + string_format(_bonus_value, 0, 1) + "%)";
			}

			draw_set_color(_stat_colors[_hover_stat_index]);
			draw_text(_stat_value_x, _stat_y, _line_text);
			draw_set_color(COLOR_HEALTH_BAR);
			draw_text(_stat_value_x + string_width(_line_text), _stat_y, _bonus_text);
		}

		if (_hover_stats.aoe_radius > 0)
		{
			draw_set_color(COLOR_HUD_PROJECTILE_DESCRIPTION);
			draw_text(_stat_value_x, _hover_y + 94 + (_stat_line_height * _stat_count), "Aoe radius: " + string(_hover_stats.aoe_radius));
		}

		draw_set_color(COLOR_HUD_TEXT);
		draw_text(_ability_x, _hover_y + 70, "Ability");
		draw_set_color(COLOR_HUD_PROJECTILE_DESCRIPTION);
		draw_text_ext(_ability_x, _hover_y + 94, cultist_demon_abilities_text_get(_hovered_demon_type), 16, _hover_width - 300);
	}

	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
	draw_set_alpha(1);
	exit;
}

// Draw cultist level-up window.
if (global.focus_window == FOCUS_WINDOW.CULTIST_LEVEL_UP)
{
	var _cultist = noone;

	if (cultist_levelup_index >= 0 && cultist_levelup_index < array_length(global.cultists))
	{
		_cultist = global.cultists[cultist_levelup_index];
	}

	var _panel_width = cultist_panel_width;
	var _panel_height = 580;
	var _panel_x = (camera_view_width - _panel_width) * 0.5;
	var _panel_y = (camera_view_height - _panel_height) * 0.5;
	var _button_width = 150;
	var _button_height = 44;
	var _button_gap = 18;
	var _button_start_x = _panel_x + 92;
	var _button_y = _panel_y + 470;
	var _stat_names = ["Body", "Spirit", "Fervor"];
	var _mouse_x = device_mouse_x_to_gui(0);
	var _mouse_y = device_mouse_y_to_gui(0);
	var _hovered_stat = -1;

	// Detect button hover before drawing stats so bonuses can preview the next point.
	for (var _hover_stat_index = 0; _hover_stat_index < CULTIST_STAT.COUNT; ++_hover_stat_index)
	{
		var _hover_button_x = _button_start_x + ((_button_width + _button_gap) * _hover_stat_index);
		var _is_button_hovered = _mouse_x >= _hover_button_x && _mouse_x <= _hover_button_x + _button_width
			&& _mouse_y >= _button_y && _mouse_y <= _button_y + _button_height;

		if (_is_button_hovered)
		{
			_hovered_stat = _hover_stat_index;
		}
	}

	draw_set_alpha(0.55);
	draw_set_color(c_black);
	draw_rectangle(0, 0, camera_view_width, camera_view_height, false);

	draw_set_alpha(1);
	draw_set_color(COLOR_HUD_BACKGROUND);
	draw_rectangle(_panel_x, _panel_y, _panel_x + _panel_width, _panel_y + _panel_height, false);
	draw_set_color(c_white);
	draw_rectangle(_panel_x, _panel_y, _panel_x + _panel_width, _panel_y + _panel_height, true);

	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_set_color(COLOR_HUD_TEXT);
	draw_text(_panel_x + (_panel_width * 0.5), _panel_y + 40, "Level Up");

	if (instance_exists(_cultist))
	{
		var _display_name = _cultist.cultist_name;

		if (_display_name == "")
		{
			_display_name = "Cultist " + string(cultist_levelup_index + 1);
		}

		var _cultist_level = 1;
		var _pending_level_points = 0;

		if (variable_instance_exists(_cultist, "current_lvl"))
		{
			_cultist_level = _cultist.current_lvl;
		}

		if (variable_instance_exists(_cultist, "pending_level_points"))
		{
			_pending_level_points = _cultist.pending_level_points;
		}

		draw_text_transformed(_panel_x + (_panel_width * 0.5), _panel_y + 88, "LVL " + string(_cultist_level), 2, 2, 0);
		draw_text(_panel_x + (_panel_width * 0.5), _panel_y + 132, _display_name);
		draw_text(_panel_x + (_panel_width * 0.5), _panel_y + 158, "Attribute points: " + string(_pending_level_points));

		if (variable_instance_exists(_cultist, "demon_type") && _cultist.demon_type != DEMON_TYPE.NONE)
		{
			var _points = _cultist.cultist_points;
			var _base_stats = cultist_base_stats_get(_cultist.demon_type);
			var _demon_stats = cultist_calculated_stats_get(_cultist.demon_type, _points);
			var _stats_left_x = _panel_x + 92;
			var _stats_right_x = _panel_x + 390;
			var _stats_y = _panel_y + 242;
			var _line_height = 22;
			var _body_points = _points[CULTIST_STAT.BODY];
			var _spirit_points = _points[CULTIST_STAT.SPIRIT];
			var _fervor_points = _points[CULTIST_STAT.FERVOR];
			var _preview_body_points = _body_points;
			var _preview_spirit_points = _spirit_points;
			var _preview_fervor_points = _fervor_points;

			if (_hovered_stat == CULTIST_STAT.BODY)
			{
				_preview_body_points++;
			}
			else if (_hovered_stat == CULTIST_STAT.SPIRIT)
			{
				_preview_spirit_points++;
			}
			else if (_hovered_stat == CULTIST_STAT.FERVOR)
			{
				_preview_fervor_points++;
			}

			var _hp_bonus = _base_stats.hp * (_preview_body_points * 0.05);
			var _armor_bonus = _base_stats.armor * (_preview_body_points * 0.05);
			var _damage_bonus = _base_stats.damage * (_preview_body_points * 0.05);
			var _magic_damage_bonus = _base_stats.magic_damage * (_preview_spirit_points * 0.05);
			var _crit_bonus = _base_stats.crit_chance * (_preview_fervor_points * 0.05);
			var _attack_speed_bonus = _base_stats.attack_speed * (_preview_fervor_points * 0.07);
			var _cooldown_bonus = _base_stats.abilities_cd_spd * (_preview_fervor_points * 0.07);
			var _exp_bonus = _base_stats.exp_effectiveness * (_preview_spirit_points * 0.07);
			var _magic_bonus = _base_stats.magic_effectiveness * (_preview_spirit_points * 0.07);
			var _resistance_bonus = _base_stats.resistance * (_preview_spirit_points * 0.07);
			var _hp_text = "HP: " + string_format(_demon_stats.hp, 0, 1);

			if (variable_instance_exists(_cultist, "hp"))
			{
				_hp_text = "HP: " + string_format(_cultist.hp, 0, 1) + " / " + string_format(_cultist.max_hp, 0, 1);
			}

			draw_set_halign(fa_left);
			draw_set_valign(fa_top);

			draw_set_color(COLOR_HUD_TEXT);
			draw_text(_stats_left_x, _panel_y + 184, "Demon: " + cultist_demon_name_get(_cultist.demon_type));
			draw_text(_stats_left_x, _panel_y + 206, "Ability: " + cultist_ability_name_get(_cultist.demon_ability));

			// Draw current attribute points as compact square rows.
			var _square_start_x = _stats_right_x + 72;
			var _square_y = _panel_y + 182;
			var _square_size = 8;
			var _square_gap = 4;
			var _attribute_names = ["Body", "Spirit", "Fervor"];
			var _attribute_points = [_body_points, _spirit_points, _fervor_points];
			var _attribute_colors = [COLOR_CULTIST_BODY, COLOR_CULTIST_SPIRIT, COLOR_CULTIST_FERVOR];

			for (var _attribute_index = 0; _attribute_index < CULTIST_STAT.COUNT; ++_attribute_index)
			{
				var _row_y = _square_y + (_attribute_index * 18);

				draw_set_color(_attribute_colors[_attribute_index]);
				draw_text(_stats_right_x, _row_y - 3, _attribute_names[_attribute_index]);

				for (var _point_index = 0; _point_index < _attribute_points[_attribute_index]; ++_point_index)
				{
					var _square_x = _square_start_x + ((_square_size + _square_gap) * _point_index);
					draw_rectangle(_square_x, _row_y, _square_x + _square_size, _row_y + _square_size, false);
				}

				if (_hovered_stat == _attribute_index)
				{
					var _preview_square_x = _square_start_x + ((_square_size + _square_gap) * _attribute_points[_attribute_index]);
					draw_rectangle(_preview_square_x, _row_y, _preview_square_x + _square_size, _row_y + _square_size, true);
				}
			}

			draw_set_color(COLOR_CULTIST_BODY);
			draw_text(_stats_left_x, _stats_y, _hp_text);
			draw_set_color(COLOR_HEALTH_BAR);
			draw_text(_stats_left_x + string_width(_hp_text), _stats_y, " (+" + string_format(_hp_bonus, 0, 1) + ")");

			var _stat_text = "Armor: " + string_format(_demon_stats.armor - 100, 0, 1) + "%";
			draw_set_color(COLOR_CULTIST_BODY);
			draw_text(_stats_left_x, _stats_y + (_line_height * 1), _stat_text);
			draw_set_color(COLOR_HEALTH_BAR);
			draw_text(_stats_left_x + string_width(_stat_text), _stats_y + (_line_height * 1), " (+" + string_format(_armor_bonus, 0, 1) + "%)");

			_stat_text = "Physical damage: " + string_format(_demon_stats.damage, 0, 2);
			var _damage_text_color = COLOR_CULTIST_BODY;
			var _shown_damage_bonus = _damage_bonus;

			if (_demon_stats.magic_damage > 0)
			{
				_stat_text = "Magic damage: " + string_format(_demon_stats.magic_damage, 0, 2);
				_damage_text_color = COLOR_CULTIST_SPIRIT;
				_shown_damage_bonus = _magic_damage_bonus;
			}

			draw_set_color(_damage_text_color);
			draw_text(_stats_left_x, _stats_y + (_line_height * 2), _stat_text);
			draw_set_color(COLOR_HEALTH_BAR);
			draw_text(_stats_left_x + string_width(_stat_text), _stats_y + (_line_height * 2), " (+" + string_format(_shown_damage_bonus, 0, 2) + ")");

			_stat_text = "Crit chance: " + string_format(_demon_stats.crit_chance * 100, 0, 1) + "%";
			draw_set_color(COLOR_CULTIST_FERVOR);
			draw_text(_stats_left_x, _stats_y + (_line_height * 3), _stat_text);
			draw_set_color(COLOR_HEALTH_BAR);
			draw_text(_stats_left_x + string_width(_stat_text), _stats_y + (_line_height * 3), " (+" + string_format(_crit_bonus * 100, 0, 1) + "%)");

			_stat_text = "Attack speed: " + string_format(_demon_stats.attack_speed, 0, 2);
			draw_set_color(COLOR_CULTIST_FERVOR);
			draw_text(_stats_left_x, _stats_y + (_line_height * 4), _stat_text);
			draw_set_color(COLOR_HEALTH_BAR);
			draw_text(_stats_left_x + string_width(_stat_text), _stats_y + (_line_height * 4), " (+" + string_format(_attack_speed_bonus, 0, 2) + ")");

			_stat_text = "Ability Recharge: " + string_format(_demon_stats.abilities_cd_spd, 0, 2);
			draw_set_color(COLOR_CULTIST_FERVOR);
			draw_text(_stats_left_x, _stats_y + (_line_height * 5), _stat_text);
			draw_set_color(COLOR_HEALTH_BAR);
			draw_text(_stats_left_x + string_width(_stat_text), _stats_y + (_line_height * 5), " (+" + string_format(_cooldown_bonus, 0, 2) + ")");

			_stat_text = "XP Gain: " + string_format(_demon_stats.exp_effectiveness, 0, 2);
			draw_set_color(COLOR_CULTIST_SPIRIT);
			draw_text(_stats_right_x, _stats_y, _stat_text);
			draw_set_color(COLOR_HEALTH_BAR);
			draw_text(_stats_right_x + string_width(_stat_text), _stats_y, " (+" + string_format(_exp_bonus, 0, 2) + ")");

			_stat_text = "Magic power: " + string_format(_demon_stats.magic_effectiveness, 0, 2);
			draw_set_color(COLOR_CULTIST_SPIRIT);
			draw_text(_stats_right_x, _stats_y + (_line_height * 1), _stat_text);
			draw_set_color(COLOR_HEALTH_BAR);
			draw_text(_stats_right_x + string_width(_stat_text), _stats_y + (_line_height * 1), " (+" + string_format(_magic_bonus, 0, 2) + ")");

			_stat_text = "Resistance: " + string_format(_demon_stats.resistance, 0, 2);
			draw_set_color(COLOR_CULTIST_SPIRIT);
			draw_text(_stats_right_x, _stats_y + (_line_height * 2), _stat_text);
			draw_set_color(COLOR_HEALTH_BAR);
			draw_text(_stats_right_x + string_width(_stat_text), _stats_y + (_line_height * 2), " (+" + string_format(_resistance_bonus, 0, 2) + ")");

			if (_demon_stats.aoe_radius > 0)
			{
				draw_set_color(COLOR_HUD_TEXT);
				draw_text(_stats_right_x, _stats_y + (_line_height * 3), "Aoe radius: " + string(_demon_stats.aoe_radius));
			}
		}
	}

	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_set_color(COLOR_HUD_TEXT);
	draw_text(_panel_x + (_panel_width * 0.5), _button_y - 28, "Choose one attribute point");

	var _levelup_stat_colors = [COLOR_CULTIST_BODY, COLOR_CULTIST_SPIRIT, COLOR_CULTIST_FERVOR];

	for (var _stat_index = 0; _stat_index < CULTIST_STAT.COUNT; ++_stat_index)
	{
		var _button_x = _button_start_x + ((_button_width + _button_gap) * _stat_index);
		var _is_hovered = _mouse_x >= _button_x && _mouse_x <= _button_x + _button_width
			&& _mouse_y >= _button_y && _mouse_y <= _button_y + _button_height;

		if (_is_hovered)
		{
			_hovered_stat = _stat_index;
		}

		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		draw_set_color(c_white);
		draw_rectangle(_button_x, _button_y, _button_x + _button_width, _button_y + _button_height, true);
		draw_set_color(_levelup_stat_colors[_stat_index]);
		draw_text(_button_x + (_button_width * 0.5), _button_y + (_button_height * 0.5), _stat_names[_stat_index]);
	}

	if (_hovered_stat >= 0)
	{
		var _tooltip_width = 250;
		var _tooltip_height = 136;
		var _tooltip_x = min(_mouse_x + 18, camera_view_width - _tooltip_width - 18);
		var _tooltip_y = min(_mouse_y + 18, camera_view_height - _tooltip_height - 18);
		var _tooltip_text = "";

		if (instance_exists(_cultist) && variable_instance_exists(_cultist, "demon_type") && _cultist.demon_type != DEMON_TYPE.NONE)
		{
			var _base_stats = cultist_base_stats_get(_cultist.demon_type);

			if (_hovered_stat == CULTIST_STAT.BODY)
			{
				_tooltip_text = "Next point gives:"
					+ "\nHP +" + string_format(_base_stats.hp * 0.05, 0, 2)
					+ "\nArmor +" + string_format(_base_stats.armor * 0.05, 0, 1) + "%";

				if (_base_stats.damage > 0)
				{
					_tooltip_text += "\nPhysical damage +" + string_format(_base_stats.damage * 0.05, 0, 2);
				}
			}
			else if (_hovered_stat == CULTIST_STAT.SPIRIT)
			{
				_tooltip_text = "Next point gives:"
					+ "\nXP Gain +" + string_format(_base_stats.exp_effectiveness * 0.07, 0, 2)
					+ "\nMagic power +" + string_format(_base_stats.magic_effectiveness * 0.07, 0, 2)
					+ "\nResistance +" + string_format(_base_stats.resistance * 0.07, 0, 2);

				if (_base_stats.magic_damage > 0)
				{
					_tooltip_text += "\nMagic damage +" + string_format(_base_stats.magic_damage * 0.05, 0, 2);
				}
			}
			else if (_hovered_stat == CULTIST_STAT.FERVOR)
			{
				_tooltip_text = "Next point gives:"
					+ "\nCrit chance +" + string_format(_base_stats.crit_chance * 5, 0, 1) + "%"
					+ "\nAttack speed +" + string_format(_base_stats.attack_speed * 0.07, 0, 2)
					+ "\nAbility Recharge +" + string_format(_base_stats.abilities_cd_spd * 0.07, 0, 2);
			}
		}

		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		draw_set_alpha(0.96);
		draw_set_color(COLOR_HUD_BACKGROUND);
		draw_rectangle(_tooltip_x, _tooltip_y, _tooltip_x + _tooltip_width, _tooltip_y + _tooltip_height, false);
		draw_set_alpha(1);
		draw_set_color(_levelup_stat_colors[_hovered_stat]);
		draw_rectangle(_tooltip_x, _tooltip_y, _tooltip_x + _tooltip_width, _tooltip_y + _tooltip_height, true);
		draw_text(_tooltip_x + 12, _tooltip_y + 10, _stat_names[_hovered_stat]);
		draw_set_color(COLOR_HUD_TEXT);
		draw_text_ext(_tooltip_x + 12, _tooltip_y + 34, _tooltip_text, 18, _tooltip_width - 24);
	}

	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
	draw_set_alpha(1);
	exit;
}

// Draw cultist stat hover in regular gameplay.
if (global.focus_window == FOCUS_WINDOW.NOONE && variable_global_exists("cultists") && instance_exists(o_camera_controller))
{
	var _camera_controller = instance_find(o_camera_controller, 0);
	var _mouse_gui_x = device_mouse_x_to_gui(0);
	var _mouse_gui_y = device_mouse_y_to_gui(0);
	var _camera_x = camera_get_view_x(_camera_controller.camera_id);
	var _camera_y = camera_get_view_y(_camera_controller.camera_id);
	var _camera_width = camera_get_view_width(_camera_controller.camera_id);
	var _camera_height = camera_get_view_height(_camera_controller.camera_id);
	var _mouse_world_x = _camera_x + ((_mouse_gui_x / camera_view_width) * _camera_width);
	var _mouse_world_y = _camera_y + ((_mouse_gui_y / camera_view_height) * _camera_height);
	var _hovered_cultist = noone;
	var _nearest_distance = infinity;
	var _cultist_count = array_length(global.cultists);

	for (var _cultist_index = 0; _cultist_index < _cultist_count; ++_cultist_index)
	{
		var _cultist = global.cultists[_cultist_index];

		if (instance_exists(_cultist) && variable_instance_exists(_cultist, "cultist_points"))
		{
			var _is_inside_cultist_collision = _mouse_world_x >= _cultist.bbox_left
				&& _mouse_world_x <= _cultist.bbox_right
				&& _mouse_world_y >= _cultist.bbox_top
				&& _mouse_world_y <= _cultist.bbox_bottom;

			if (_is_inside_cultist_collision)
			{
				var _distance_to_cultist = point_distance(_mouse_world_x, _mouse_world_y, _cultist.x, _cultist.y);

				if (_distance_to_cultist <= _nearest_distance)
				{
					_nearest_distance = _distance_to_cultist;
					_hovered_cultist = _cultist;
				}
			}
		}
	}

	if (instance_exists(_hovered_cultist))
	{
		var _hover_width = 280;
		var _hover_height = 430;
		var _hover_margin = 18;
		var _hover_y_max = max(_hover_margin, camera_view_height - _hover_height - _hover_margin);
		var _hover_x = _hover_margin;
		var _hover_y = min(96, _hover_y_max);
		var _hover_padding = 14;
		var _points = _hovered_cultist.cultist_points;
		var _demon_type = _hovered_cultist.demon_type;
		var _base_stats = cultist_base_stats_get(_demon_type);
		var _demon_stats = cultist_calculated_stats_get(_demon_type, _points);
		var _display_name = _hovered_cultist.cultist_name;
		var _ability_text = "Ability: " + cultist_ability_name_get(_hovered_cultist.demon_ability);
		var _ability_description = cultist_ability_description_get(_hovered_cultist.demon_ability);
		var _body_points = _points[CULTIST_STAT.BODY];
		var _spirit_points = _points[CULTIST_STAT.SPIRIT];
		var _fervor_points = _points[CULTIST_STAT.FERVOR];
		var _current_level = _hovered_cultist.current_lvl;
		var _current_exp = _hovered_cultist.current_exp;
		var _required_exp = cultist_level_exp_required_get(_current_level);
		var _exp_progress = clamp(_current_exp / max(1, _required_exp), 0, 1);
		var _exp_bar_width = 180;
		var _exp_bar_height = 5;
		var _exp_bar_x = _hover_x + _hover_padding;
		var _exp_bar_y = _hover_y + 60;
		var _level_text = "Level: " + string(_current_level)
			+ " (" + string_format(_current_exp, 0, 0)
			+ "/" + string_format(_required_exp, 0, 0) + " exp)";

		if (_display_name == "")
		{
			_display_name = "Unnamed";
		}

		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		draw_set_alpha(0.96);
		draw_set_color(COLOR_HUD_BACKGROUND);
		draw_rectangle(_hover_x, _hover_y, _hover_x + _hover_width, _hover_y + _hover_height, false);
		draw_set_alpha(1);
		draw_set_color(COLOR_CULTIST_FERVOR);
		draw_rectangle(_hover_x, _hover_y, _hover_x + _hover_width, _hover_y + _hover_height, true);

		draw_set_color(COLOR_HUD_TEXT);
		draw_text(_hover_x + _hover_padding, _hover_y + _hover_padding, _display_name);
		draw_text(_hover_x + _hover_padding, _hover_y + 38, _level_text);

		draw_set_alpha(0.75);
		draw_set_color(c_black);
		draw_rectangle(_exp_bar_x, _exp_bar_y, _exp_bar_x + _exp_bar_width, _exp_bar_y + _exp_bar_height, false);
		draw_set_alpha(1);
		draw_set_color(COLOR_HEALTH_BAR);
		draw_rectangle(_exp_bar_x, _exp_bar_y, _exp_bar_x + (_exp_bar_width * _exp_progress), _exp_bar_y + _exp_bar_height, false);

		draw_set_color(COLOR_HUD_PROJECTILE_DESCRIPTION);
		draw_text(_hover_x + _hover_padding, _hover_y + 78, "Demon: " + cultist_demon_name_get(_demon_type));
		draw_text(_hover_x + _hover_padding, _hover_y + 98, _ability_text);
		draw_text_ext(_hover_x + _hover_padding, _hover_y + 118, _ability_description, 16, _hover_width - (_hover_padding * 2));

		var _attribute_names = ["Body", "Spirit", "Fervor"];
		var _attribute_points = [_body_points, _spirit_points, _fervor_points];
		var _attribute_colors = [COLOR_CULTIST_BODY, COLOR_CULTIST_SPIRIT, COLOR_CULTIST_FERVOR];
		var _attribute_x = _hover_x + _hover_padding;
		var _attribute_y = _hover_y + 184;
		var _attribute_gap = 24;
		var _box_size = 8;
		var _box_gap = 4;

		for (var _attribute_index = 0; _attribute_index < CULTIST_STAT.COUNT; ++_attribute_index)
		{
			var _draw_y = _attribute_y + (_attribute_gap * _attribute_index);

			draw_set_color(_attribute_colors[_attribute_index]);
			draw_text(_attribute_x, _draw_y, _attribute_names[_attribute_index]);

			for (var _point_index = 0; _point_index < _attribute_points[_attribute_index]; ++_point_index)
			{
				var _box_x = _attribute_x + 68 + ((_box_size + _box_gap) * _point_index);
				var _box_y = _draw_y + 4;

				draw_rectangle(_box_x, _box_y, _box_x + _box_size, _box_y + _box_size, false);
			}
		}

		var _stats_x = _hover_x + _hover_padding;
		var _stats_y = _hover_y + 266;
		var _line_height = 18;
		var _stat_line_index = 0;
		var _hp_text = "HP: " + string_format(_demon_stats.hp, 0, 1);
		var _hp_bonus = _base_stats.hp * (_body_points * 0.05);
		var _armor_bonus = _base_stats.armor * (_body_points * 0.05);
		var _damage_bonus = _base_stats.damage * (_body_points * 0.05);
		var _magic_damage_bonus = _base_stats.magic_damage * (_spirit_points * 0.05);
		var _crit_bonus = _base_stats.crit_chance * (_fervor_points * 0.05);
		var _attack_speed_bonus = _base_stats.attack_speed * (_fervor_points * 0.07);
		var _cooldown_bonus = _base_stats.abilities_cd_spd * (_fervor_points * 0.07);
		var _exp_bonus = _base_stats.exp_effectiveness * (_spirit_points * 0.07);
		var _magic_bonus = _base_stats.magic_effectiveness * (_spirit_points * 0.07);
		var _resistance_bonus = _base_stats.resistance * (_spirit_points * 0.07);

		if (variable_instance_exists(_hovered_cultist, "hp"))
		{
			_hp_text = "HP: " + string_format(_hovered_cultist.hp, 0, 1) + " / " + string_format(_hovered_cultist.max_hp, 0, 1);
		}

		draw_set_color(COLOR_CULTIST_BODY);
		draw_text(_stats_x, _stats_y + (_line_height * _stat_line_index), _hp_text);
		draw_set_color(COLOR_HEALTH_BAR);
		draw_text(_stats_x + string_width(_hp_text), _stats_y + (_line_height * _stat_line_index), " (+" + string_format(_hp_bonus, 0, 1) + ")");
		_stat_line_index++;

		var _left_stat_text = "Armor: " + string_format(_demon_stats.armor - 100, 0, 1) + "%";
		draw_set_color(COLOR_CULTIST_BODY);
		draw_text(_stats_x, _stats_y + (_line_height * _stat_line_index), _left_stat_text);
		draw_set_color(COLOR_HEALTH_BAR);
		draw_text(_stats_x + string_width(_left_stat_text), _stats_y + (_line_height * _stat_line_index), " (+" + string_format(_armor_bonus, 0, 1) + "%)");
		_stat_line_index++;

		_left_stat_text = "Phys dmg: " + string_format(_demon_stats.damage, 0, 2);
		var _left_damage_color = COLOR_CULTIST_BODY;
		var _left_damage_bonus = _damage_bonus;

		if (_demon_stats.magic_damage > 0)
		{
			_left_stat_text = "Magic dmg: " + string_format(_demon_stats.magic_damage, 0, 2);
			_left_damage_color = COLOR_CULTIST_SPIRIT;
			_left_damage_bonus = _magic_damage_bonus;
		}

		draw_set_color(_left_damage_color);
		draw_text(_stats_x, _stats_y + (_line_height * _stat_line_index), _left_stat_text);
		draw_set_color(COLOR_HEALTH_BAR);
		draw_text(_stats_x + string_width(_left_stat_text), _stats_y + (_line_height * _stat_line_index), " (+" + string_format(_left_damage_bonus, 0, 2) + ")");
		_stat_line_index++;

		_left_stat_text = "Crit chance: " + string_format(_demon_stats.crit_chance * 100, 0, 1) + "%";
		draw_set_color(COLOR_CULTIST_FERVOR);
		draw_text(_stats_x, _stats_y + (_line_height * _stat_line_index), _left_stat_text);
		draw_set_color(COLOR_HEALTH_BAR);
		draw_text(_stats_x + string_width(_left_stat_text), _stats_y + (_line_height * _stat_line_index), " (+" + string_format(_crit_bonus * 100, 0, 1) + "%)");
		_stat_line_index++;

		_left_stat_text = "Attack speed: " + string_format(_demon_stats.attack_speed, 0, 2);
		draw_set_color(COLOR_CULTIST_FERVOR);
		draw_text(_stats_x, _stats_y + (_line_height * _stat_line_index), _left_stat_text);
		draw_set_color(COLOR_HEALTH_BAR);
		draw_text(_stats_x + string_width(_left_stat_text), _stats_y + (_line_height * _stat_line_index), " (+" + string_format(_attack_speed_bonus, 0, 2) + ")");
		_stat_line_index++;

		var _right_stat_text = "Ability rec: " + string_format(_demon_stats.abilities_cd_spd, 0, 2);
		draw_set_color(COLOR_CULTIST_FERVOR);
		draw_text(_stats_x, _stats_y + (_line_height * _stat_line_index), _right_stat_text);
		draw_set_color(COLOR_HEALTH_BAR);
		draw_text(_stats_x + string_width(_right_stat_text), _stats_y + (_line_height * _stat_line_index), " (+" + string_format(_cooldown_bonus, 0, 2) + ")");
		_stat_line_index++;

		_right_stat_text = "XP Gain: " + string_format(_demon_stats.exp_effectiveness, 0, 2);
		draw_set_color(COLOR_CULTIST_SPIRIT);
		draw_text(_stats_x, _stats_y + (_line_height * _stat_line_index), _right_stat_text);
		draw_set_color(COLOR_HEALTH_BAR);
		draw_text(_stats_x + string_width(_right_stat_text), _stats_y + (_line_height * _stat_line_index), " (+" + string_format(_exp_bonus, 0, 2) + ")");
		_stat_line_index++;

		_right_stat_text = "Magic power: " + string_format(_demon_stats.magic_effectiveness, 0, 2);
		draw_set_color(COLOR_CULTIST_SPIRIT);
		draw_text(_stats_x, _stats_y + (_line_height * _stat_line_index), _right_stat_text);
		draw_set_color(COLOR_HEALTH_BAR);
		draw_text(_stats_x + string_width(_right_stat_text), _stats_y + (_line_height * _stat_line_index), " (+" + string_format(_magic_bonus, 0, 2) + ")");
		_stat_line_index++;

		_right_stat_text = "Resistance: " + string_format(_demon_stats.resistance, 0, 2);
		draw_set_color(COLOR_CULTIST_SPIRIT);
		draw_text(_stats_x, _stats_y + (_line_height * _stat_line_index), _right_stat_text);
		draw_set_color(COLOR_HEALTH_BAR);
		draw_text(_stats_x + string_width(_right_stat_text), _stats_y + (_line_height * _stat_line_index), " (+" + string_format(_resistance_bonus, 0, 2) + ")");
		_stat_line_index++;

		if (_demon_stats.aoe_radius > 0)
		{
			draw_set_color(COLOR_HUD_TEXT);
			draw_text(_stats_x, _stats_y + (_line_height * _stat_line_index), "Aoe radius: " + string(_demon_stats.aoe_radius));
		}

		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		draw_set_color(c_white);
		draw_set_alpha(1);
	}
}

// Draw friendly summoned unit stats on hover.
if (global.focus_window == FOCUS_WINDOW.NOONE && instance_exists(o_camera_controller))
{
	var _camera_controller = instance_find(o_camera_controller, 0);
	var _mouse_gui_x = device_mouse_x_to_gui(0);
	var _mouse_gui_y = device_mouse_y_to_gui(0);
	var _camera_x = camera_get_view_x(_camera_controller.camera_id);
	var _camera_y = camera_get_view_y(_camera_controller.camera_id);
	var _camera_width = camera_get_view_width(_camera_controller.camera_id);
	var _camera_height = camera_get_view_height(_camera_controller.camera_id);
	var _mouse_world_x = _camera_x + ((_mouse_gui_x / camera_view_width) * _camera_width);
	var _mouse_world_y = _camera_y + ((_mouse_gui_y / camera_view_height) * _camera_height);
	var _hovered_unit = noone;
	var _nearest_distance = infinity;
	var _friendly_count = instance_number(o_friendly_units);

	for (var _friendly_index = 0; _friendly_index < _friendly_count; ++_friendly_index)
	{
		var _friendly_unit = instance_find(o_friendly_units, _friendly_index);

		if (instance_exists(_friendly_unit)
			&& !variable_instance_exists(_friendly_unit, "cultist_points")
			&& _mouse_world_x >= _friendly_unit.bbox_left
			&& _mouse_world_x <= _friendly_unit.bbox_right
			&& _mouse_world_y >= _friendly_unit.bbox_top
			&& _mouse_world_y <= _friendly_unit.bbox_bottom)
		{
			var _distance_to_unit = point_distance(_mouse_world_x, _mouse_world_y, _friendly_unit.x, _friendly_unit.y);

			if (_distance_to_unit <= _nearest_distance)
			{
				_nearest_distance = _distance_to_unit;
				_hovered_unit = _friendly_unit;
			}
		}
	}

	if (instance_exists(_hovered_unit))
	{
		var _hover_width = 260;
		var _hover_height = 168;
		var _hover_margin = 18;
		var _hover_y_max = max(_hover_margin, camera_view_height - _hover_height - _hover_margin);
		var _hover_x = _hover_margin;
		var _hover_y = min(96, _hover_y_max);
		var _hover_padding = 14;
		var _unit_name = object_get_name(_hovered_unit.object_index);
		var _damage_text = "Damage: " + string_format(_hovered_unit.damage, 0, 1);
		var _attack_speed = room_speed / max(_hovered_unit.reload_time, 1);

		if (_hovered_unit.magic_damage > 0)
		{
			_damage_text = "Magic damage: " + string_format(_hovered_unit.magic_damage, 0, 1);
		}

		if (_hovered_unit.object_index == o_skeleton)
		{
			_unit_name = "Skeleton";
		}
		else if (_hovered_unit.object_index == o_pitling)
		{
			_unit_name = "Pitling";
		}

		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		draw_set_alpha(0.96);
		draw_set_color(COLOR_HUD_BACKGROUND);
		draw_rectangle(_hover_x, _hover_y, _hover_x + _hover_width, _hover_y + _hover_height, false);
		draw_set_alpha(1);
		draw_set_color(COLOR_PROJECTILE_SUMMON);
		draw_rectangle(_hover_x, _hover_y, _hover_x + _hover_width, _hover_y + _hover_height, true);

		draw_set_color(COLOR_HUD_TEXT);
		draw_text(_hover_x + _hover_padding, _hover_y + _hover_padding, _unit_name);
		draw_text(_hover_x + _hover_padding, _hover_y + 42, "HP: " + string_format(_hovered_unit.hp, 0, 1) + " / " + string_format(_hovered_unit.max_hp, 0, 1));
		draw_text(_hover_x + _hover_padding, _hover_y + 62, _damage_text);
		draw_text(_hover_x + _hover_padding, _hover_y + 82, "Attack speed: " + string_format(_attack_speed, 0, 2));
		draw_text(_hover_x + _hover_padding, _hover_y + 102, "Attack radius: " + string_format(_hovered_unit.attack_radius, 0, 0));
		draw_text(_hover_x + _hover_padding, _hover_y + 122, "Move speed: " + string_format(_hovered_unit.move_speed, 0, 2));

		if (variable_instance_exists(_hovered_unit, "summon_nights_remaining"))
		{
			draw_set_color(COLOR_HUD_SOULS);
			draw_text(_hover_x + _hover_padding, _hover_y + 142, "Nights left: " + string(_hovered_unit.summon_nights_remaining));
		}

		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		draw_set_color(c_white);
		draw_set_alpha(1);
	}
}

// Draw lightweight gameplay pause indicator without blocking hover info.
if (player_pause_active && global.focus_window == FOCUS_WINDOW.NOONE)
{
	var _pause_margin = 10;
	var _pause_label_width = 144;
	var _pause_label_height = 34;
	var _pause_label_x = (camera_view_width - _pause_label_width) * 0.5;
	var _pause_label_y = 14;

	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_set_alpha(0.95);
	draw_set_color(COLOR_HUD_BACKGROUND);
	draw_rectangle(_pause_label_x, _pause_label_y, _pause_label_x + _pause_label_width, _pause_label_y + _pause_label_height, false);

	draw_set_alpha(1);
	draw_set_color(COLOR_CULTIST_FERVOR);
	draw_rectangle(_pause_margin, _pause_margin, camera_view_width - _pause_margin, camera_view_height - _pause_margin, true);
	draw_rectangle(_pause_label_x, _pause_label_y, _pause_label_x + _pause_label_width, _pause_label_y + _pause_label_height, true);

	draw_set_color(COLOR_HUD_TEXT);
	draw_text(_pause_label_x + (_pause_label_width * 0.5), _pause_label_y + (_pause_label_height * 0.5), "PAUSE");

	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
	draw_set_alpha(1);
}

// Draw nothing while the pause menu is closed.
if (!pause_menu_open)
{
	exit;
}

// Draw dimmed fullscreen overlay.
draw_set_alpha(overlay_alpha);
draw_set_color(c_black);
draw_rectangle(0, 0, camera_view_width, camera_view_height, false);
draw_set_alpha(1);

// Prepare centered menu text.
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

if (!settings_open)
{
	// Draw main pause menu buttons.
	var _button_x = (camera_view_width - button_width) * 0.5;
	var _button_y = (camera_view_height - ((button_height * pause_button_count) + (button_gap * (pause_button_count - 1)))) * 0.5;
	var _button_step = button_height + button_gap;

	for (var _button_index = 0; _button_index < pause_button_count; ++_button_index)
	{
		var _draw_y = _button_y + (_button_step * _button_index);

		draw_set_color(c_white);
		draw_rectangle(_button_x, _draw_y, _button_x + button_width, _draw_y + button_height, false);

		draw_set_color(c_black);
		draw_text(_button_x + (button_width * 0.5), _draw_y + (button_height * 0.5), pause_button_labels[_button_index]);
	}
}
else
{
	// Draw settings panel.
	var _panel_x = (camera_view_width - settings_panel_width) * 0.5;
	var _panel_y = (camera_view_height - settings_panel_height) * 0.5;
	var _toggle_x = _panel_x + settings_panel_width - settings_toggle_right_padding;
	var _toggle_y = _panel_y + settings_toggle_top_padding;
	var _close_button_x = _panel_x + ((settings_panel_width - button_width) * 0.5);
	var _close_button_y = _panel_y + settings_panel_height - button_height - settings_close_bottom_padding;

	draw_set_color(c_white);
	draw_rectangle(_panel_x, _panel_y, _panel_x + settings_panel_width, _panel_y + settings_panel_height, false);

	draw_set_color(c_black);
	draw_text(_panel_x + (settings_panel_width * 0.5), _panel_y + 34, "SETTINGS");

	draw_set_halign(fa_left);
	draw_text(_panel_x + 46, _toggle_y + (fullscreen_toggle_size * 0.5), "Fullscreen");

	draw_set_halign(fa_center);
	draw_rectangle(_toggle_x, _toggle_y, _toggle_x + fullscreen_toggle_size, _toggle_y + fullscreen_toggle_size, true);

	if (fullscreen_enabled)
	{
		var _check_padding = 8;
		draw_rectangle(
			_toggle_x + _check_padding,
			_toggle_y + _check_padding,
			_toggle_x + fullscreen_toggle_size - _check_padding,
			_toggle_y + fullscreen_toggle_size - _check_padding,
			false
		);
	}

	draw_rectangle(_close_button_x, _close_button_y, _close_button_x + button_width, _close_button_y + button_height, true);
	draw_text(_close_button_x + (button_width * 0.5), _close_button_y + (button_height * 0.5), "BACK");
}

// Restore default draw state.
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);
