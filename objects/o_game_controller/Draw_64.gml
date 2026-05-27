// Draw night tint over the world while keeping HUD readable.
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
	draw_text(_panel_x + (cultist_panel_width * 0.5), _panel_y + 34, "Choose Demon");

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
		var _stat_notes = ["HP, Armor, Damage", "Crit, Attack, Cooldown", "Exp, Magic, Resistance"];
		var _stat_points = [_body_points, _fervor_points, _spirit_points];
		var _stat_colors = [COLOR_CULTIST_BODY, COLOR_CULTIST_FERVOR, COLOR_CULTIST_SPIRIT];

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

		draw_set_color(COLOR_HUD_TEXT);
		draw_text(_panel_x + 90, _panel_y + 300, "Name");
		draw_set_color(c_white);
		draw_rectangle(_panel_x + 170, _panel_y + 287, _panel_x + 470, _panel_y + 327, true);
		draw_text(_panel_x + 184, _panel_y + 298, _name_text);

		// Blink the name input caret while this setup window owns keyboard input.
		if ((current_time div 500) mod 2 == 0)
		{
			var _caret_x = _panel_x + 184 + string_width(_name_text);
			var _caret_y = _panel_y + 298;

			draw_set_color(COLOR_HUD_TEXT);
			draw_line(_caret_x + 2, _caret_y - 1, _caret_x + 2, _caret_y + 16);
		}
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
			"Damage",
			"Crit",
			"Attack speed",
			"CD speed",
			"Exp",
			"Magic",
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
	var _panel_height = 330;
	var _panel_x = (camera_view_width - _panel_width) * 0.5;
	var _panel_y = (camera_view_height - _panel_height) * 0.5;
	var _button_width = 150;
	var _button_height = 44;
	var _button_gap = 18;
	var _button_start_x = _panel_x + 92;
	var _button_y = _panel_y + 210;
	var _stat_names = ["Body", "Spirit", "Fervor"];

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

		draw_text(_panel_x + (_panel_width * 0.5), _panel_y + 94, _display_name);
		draw_text(_panel_x + (_panel_width * 0.5), _panel_y + 132, "Choose one attribute point");
	}

	var _levelup_stat_colors = [COLOR_CULTIST_BODY, COLOR_CULTIST_SPIRIT, COLOR_CULTIST_FERVOR];

	for (var _stat_index = 0; _stat_index < CULTIST_STAT.COUNT; ++_stat_index)
	{
		var _button_x = _button_start_x + ((_button_width + _button_gap) * _stat_index);

		draw_set_color(c_white);
		draw_rectangle(_button_x, _button_y, _button_x + _button_width, _button_y + _button_height, true);
		draw_set_color(_levelup_stat_colors[_stat_index]);
		draw_text(_button_x + (_button_width * 0.5), _button_y + (_button_height * 0.5), _stat_names[_stat_index]);
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
		var _hover_width = 560;
		var _hover_height = 350;
		var _hover_x = min(_mouse_gui_x + 18, camera_view_width - _hover_width - 18);
		var _hover_y = min(_mouse_gui_y + 18, camera_view_height - _hover_height - 18);
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
		draw_set_color(COLOR_HUD_PROJECTILE_DESCRIPTION);
		draw_text(_hover_x + _hover_padding, _hover_y + 38, "Demon: " + cultist_demon_name_get(_demon_type));
		draw_text(_hover_x + _hover_padding, _hover_y + 58, _ability_text);
		draw_text_ext(_hover_x + _hover_padding, _hover_y + 78, _ability_description, 16, _hover_width - (_hover_padding * 2));

		var _attribute_names = ["Body", "Spirit", "Fervor"];
		var _attribute_points = [_body_points, _spirit_points, _fervor_points];
		var _attribute_colors = [COLOR_CULTIST_BODY, COLOR_CULTIST_SPIRIT, COLOR_CULTIST_FERVOR];
		var _attribute_x = _hover_x + _hover_padding;
		var _attribute_y = _hover_y + 120;
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

		var _left_x = _hover_x + _hover_padding;
		var _right_x = _hover_x + 310;
		var _stats_y = _hover_y + 202;
		var _line_height = 18;
		var _hp_text = "HP: " + string_format(_demon_stats.hp, 0, 1);
		var _hp_bonus = _base_stats.hp * (_body_points * 0.05);
		var _armor_bonus = _base_stats.armor * (_body_points * 0.05);
		var _damage_bonus = _base_stats.damage * (_body_points * 0.05);
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
		draw_text(_left_x, _stats_y, _hp_text);
		draw_set_color(COLOR_HEALTH_BAR);
		draw_text(_left_x + string_width(_hp_text), _stats_y, " (+" + string_format(_hp_bonus, 0, 1) + ")");

		var _left_stat_text = "Armor: " + string_format(_demon_stats.armor, 0, 2);
		draw_set_color(COLOR_CULTIST_BODY);
		draw_text(_left_x, _stats_y + (_line_height * 1), _left_stat_text);
		draw_set_color(COLOR_HEALTH_BAR);
		draw_text(_left_x + string_width(_left_stat_text), _stats_y + (_line_height * 1), " (+" + string_format(_armor_bonus, 0, 2) + ")");

		_left_stat_text = "Damage: " + string_format(_demon_stats.damage, 0, 2);
		draw_set_color(COLOR_CULTIST_BODY);
		draw_text(_left_x, _stats_y + (_line_height * 2), _left_stat_text);
		draw_set_color(COLOR_HEALTH_BAR);
		draw_text(_left_x + string_width(_left_stat_text), _stats_y + (_line_height * 2), " (+" + string_format(_damage_bonus, 0, 2) + ")");

		_left_stat_text = "Crit: " + string_format(_demon_stats.crit_chance, 0, 2);
		draw_set_color(COLOR_CULTIST_FERVOR);
		draw_text(_left_x, _stats_y + (_line_height * 3), _left_stat_text);
		draw_set_color(COLOR_HEALTH_BAR);
		draw_text(_left_x + string_width(_left_stat_text), _stats_y + (_line_height * 3), " (+" + string_format(_crit_bonus, 0, 2) + ")");

		_left_stat_text = "Attack speed: " + string_format(_demon_stats.attack_speed, 0, 2);
		draw_set_color(COLOR_CULTIST_FERVOR);
		draw_text(_left_x, _stats_y + (_line_height * 4), _left_stat_text);
		draw_set_color(COLOR_HEALTH_BAR);
		draw_text(_left_x + string_width(_left_stat_text), _stats_y + (_line_height * 4), " (+" + string_format(_attack_speed_bonus, 0, 2) + ")");

		var _right_stat_text = "CD speed: " + string_format(_demon_stats.abilities_cd_spd, 0, 2);
		draw_set_color(COLOR_CULTIST_FERVOR);
		draw_text(_right_x, _stats_y, _right_stat_text);
		draw_set_color(COLOR_HEALTH_BAR);
		draw_text(_right_x + string_width(_right_stat_text), _stats_y, " (+" + string_format(_cooldown_bonus, 0, 2) + ")");

		_right_stat_text = "Exp: " + string_format(_demon_stats.exp_effectiveness, 0, 2);
		draw_set_color(COLOR_CULTIST_SPIRIT);
		draw_text(_right_x, _stats_y + (_line_height * 1), _right_stat_text);
		draw_set_color(COLOR_HEALTH_BAR);
		draw_text(_right_x + string_width(_right_stat_text), _stats_y + (_line_height * 1), " (+" + string_format(_exp_bonus, 0, 2) + ")");

		_right_stat_text = "Magic: " + string_format(_demon_stats.magic_effectiveness, 0, 2);
		draw_set_color(COLOR_CULTIST_SPIRIT);
		draw_text(_right_x, _stats_y + (_line_height * 2), _right_stat_text);
		draw_set_color(COLOR_HEALTH_BAR);
		draw_text(_right_x + string_width(_right_stat_text), _stats_y + (_line_height * 2), " (+" + string_format(_magic_bonus, 0, 2) + ")");

		_right_stat_text = "Resistance: " + string_format(_demon_stats.resistance, 0, 2);
		draw_set_color(COLOR_CULTIST_SPIRIT);
		draw_text(_right_x, _stats_y + (_line_height * 3), _right_stat_text);
		draw_set_color(COLOR_HEALTH_BAR);
		draw_text(_right_x + string_width(_right_stat_text), _stats_y + (_line_height * 3), " (+" + string_format(_resistance_bonus, 0, 2) + ")");

		if (_demon_stats.aoe_radius > 0)
		{
			draw_set_color(COLOR_HUD_TEXT);
			draw_text(_right_x, _stats_y + (_line_height * 4), "Aoe radius: " + string(_demon_stats.aoe_radius));
		}

		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		draw_set_color(c_white);
		draw_set_alpha(1);
	}
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
