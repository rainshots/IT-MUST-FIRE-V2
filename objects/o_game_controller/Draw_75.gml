// Draw cultist stats above the regular GUI.
if (variable_global_exists("ui_font") && font_exists(global.ui_font))
{
	draw_set_font(global.ui_font);
}

if (global.focus_window == FOCUS_WINDOW.NOONE
	&& variable_global_exists("archdemons")
	&& instance_exists(o_camera_controller)
	&& (!variable_global_exists("squad_info_window_open") || !global.squad_info_window_open)
	&& (!variable_global_exists("tutorial_popup_active") || !global.tutorial_popup_active))
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
	var _cultist_count = array_length(global.archdemons);

	for (var _cultist_index = 0; _cultist_index < _cultist_count; ++_cultist_index)
	{
		var _cultist = global.archdemons[_cultist_index];

		if (instance_exists(_cultist)
			&& variable_instance_exists(_cultist, "cultist_points")
			&& (!variable_instance_exists(_cultist, "hp") || _cultist.hp > 0))
		{
			var _is_inside_cultist_collision = _mouse_world_x >= _cultist.bbox_left
				&& _mouse_world_x <= _cultist.bbox_right
				&& _mouse_world_y >= _cultist.bbox_top
				&& _mouse_world_y <= _cultist.bbox_bottom;

			if (_is_inside_cultist_collision)
			{
				var _distance_to_archdemon = point_distance(_mouse_world_x, _mouse_world_y, _cultist.x, _cultist.y);

				if (_distance_to_archdemon <= _nearest_distance)
				{
					_nearest_distance = _distance_to_archdemon;
					_hovered_cultist = _cultist;
				}
			}
		}
	}

	if (instance_exists(_hovered_cultist))
	{
		var _hover_width = min(300, camera_view_width - 36);
		var _hover_height = 570;
		var _hover_margin = 18;
		var _hover_y_max = max(_hover_margin, camera_view_height - _hover_height - _hover_margin);
		var _hover_x = _hover_margin;
		var _hover_y = min(120, _hover_y_max);
		var _hover_padding = 14;
		var _ability_width = _hover_width - (_hover_padding * 2);
		var _points = _hovered_cultist.cultist_points;
		var _demon_type = _hovered_cultist.demon_type;
		var _base_stats = cultist_base_stats_get(_demon_type);
		var _demon_stats = cultist_calculated_stats_get(_demon_type, _points);
		var _display_name = _hovered_cultist.cultist_name;
		var _abilities_text = cultist_owned_abilities_text_get(_hovered_cultist);
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

		var _attribute_names = ["Body", "Spirit", "Fervor"];
		var _attribute_points = [_body_points, _spirit_points, _fervor_points];
		var _attribute_colors = [COLOR_CULTIST_BODY, COLOR_CULTIST_SPIRIT, COLOR_CULTIST_FERVOR];
		var _attribute_stat_order = [CULTIST_STAT.BODY, CULTIST_STAT.FERVOR, CULTIST_STAT.SPIRIT];
		var _attribute_x = _hover_x + _hover_padding;
		var _attribute_y = _hover_y + 112;
		var _attribute_gap = 24;
		var _box_size = 8;
		var _box_gap = 4;
		var _attribute_count = array_length(_attribute_stat_order);

		for (var _attribute_index = 0; _attribute_index < _attribute_count; ++_attribute_index)
		{
			var _attribute_stat = _attribute_stat_order[_attribute_index];
			var _draw_y = _attribute_y + (_attribute_gap * _attribute_index);

			draw_set_color(_attribute_colors[_attribute_stat]);
			draw_text(_attribute_x, _draw_y, _attribute_names[_attribute_stat]);

			for (var _point_index = 0; _point_index < _attribute_points[_attribute_stat]; ++_point_index)
			{
				var _box_x = _attribute_x + 68 + ((_box_size + _box_gap) * _point_index);
				var _box_y = _draw_y + 4;

				draw_rectangle(_box_x, _box_y, _box_x + _box_size, _box_y + _box_size, false);
			}
		}

		var _stats_x = _hover_x + _hover_padding;
		var _stats_y = _hover_y + 194;
		var _line_height = 18;
		var _stat_line_index = 0;
		var _hp_text = "HP: " + string_format(_demon_stats.hp, 0, 1);
		var _hp_bonus = _base_stats.hp * (_body_points * BALANCE_CULTIST_BODY_STAT_BONUS);
		var _armor_bonus = _base_stats.armor * (_body_points * BALANCE_CULTIST_BODY_STAT_BONUS);
		var _damage_bonus = _base_stats.damage * (_body_points * BALANCE_CULTIST_BODY_STAT_BONUS);
		var _magic_damage_bonus = _base_stats.magic_damage * (_spirit_points * BALANCE_CULTIST_MAGIC_DAMAGE_STAT_BONUS);
		var _crit_damage_bonus = _body_points * BALANCE_CULTIST_CRIT_DAMAGE_PER_BODY;
		var _crit_bonus = _base_stats.crit_chance * (_fervor_points * BALANCE_CULTIST_CRIT_CHANCE_STAT_BONUS);
		var _attack_speed_bonus = _base_stats.attack_speed * (_fervor_points * BALANCE_CULTIST_FERVOR_STAT_BONUS);
		var _move_speed_bonus = _base_stats.move_speed * (_fervor_points * BALANCE_CULTIST_FERVOR_STAT_BONUS);
		var _shown_attack_speed = _demon_stats.attack_speed;
		var _has_demonic_infusion = variable_instance_exists(_hovered_cultist, "demonic_infusion_timer")
			&& _hovered_cultist.demonic_infusion_timer > 0;

		if (_has_demonic_infusion && variable_instance_exists(_hovered_cultist, "effective_attack_speed_get"))
		{
			_shown_attack_speed = _hovered_cultist.effective_attack_speed_get();
		}

		var _cooldown_bonus = _base_stats.abilities_cd_spd * (_spirit_points * BALANCE_CULTIST_SPIRIT_STAT_BONUS);
		var _exp_bonus = _base_stats.exp_effectiveness * (_spirit_points * BALANCE_CULTIST_SPIRIT_STAT_BONUS);
		var _magic_bonus = _base_stats.magic_effectiveness * (_spirit_points * BALANCE_CULTIST_SPIRIT_STAT_BONUS);
		var _resistance_bonus = _base_stats.resistance * (_spirit_points * BALANCE_CULTIST_SPIRIT_STAT_BONUS);

		if (variable_instance_exists(_hovered_cultist, "hp"))
		{
			_hp_text = "HP: " + string_format(_hovered_cultist.hp, 0, 1) + " / " + string_format(_hovered_cultist.max_hp, 0, 1);
		}

		draw_set_color(COLOR_CULTIST_BODY);
		draw_text(_stats_x, _stats_y + (_line_height * _stat_line_index), _hp_text);
		draw_set_color(COLOR_HEALTH_BAR);
		draw_text(_stats_x + string_width(_hp_text), _stats_y + (_line_height * _stat_line_index), " (+" + string_format(_hp_bonus, 0, 1) + ")");
		_stat_line_index++;

		var _shown_armor = _demon_stats.armor;

		if (variable_instance_exists(_hovered_cultist, "armor"))
		{
			_shown_armor = _hovered_cultist.armor;
		}

		var _left_stat_text = "Armor: " + string_format(_shown_armor - 100, 0, 1) + "%";
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

		_left_stat_text = "Crit dmg: x" + string_format(_demon_stats.crit_damage, 0, 2);
		draw_set_color(COLOR_CULTIST_BODY);
		draw_text(_stats_x, _stats_y + (_line_height * _stat_line_index), _left_stat_text);
		draw_set_color(COLOR_HEALTH_BAR);
		draw_text(_stats_x + string_width(_left_stat_text), _stats_y + (_line_height * _stat_line_index), " (+x" + string_format(_crit_damage_bonus, 0, 2) + ")");
		_stat_line_index++;

		_left_stat_text = "Crit chance: " + string_format(_demon_stats.crit_chance * 100, 0, 1) + "%";
		draw_set_color(COLOR_CULTIST_FERVOR);
		draw_text(_stats_x, _stats_y + (_line_height * _stat_line_index), _left_stat_text);
		draw_set_color(COLOR_HEALTH_BAR);
		draw_text(_stats_x + string_width(_left_stat_text), _stats_y + (_line_height * _stat_line_index), " (+" + string_format(_crit_bonus * 100, 0, 1) + "%)");
		_stat_line_index++;

		_left_stat_text = "Attack speed: " + string_format(_shown_attack_speed, 0, 2);
		draw_set_color(COLOR_CULTIST_FERVOR);
		draw_text(_stats_x, _stats_y + (_line_height * _stat_line_index), _left_stat_text);
		draw_set_color(COLOR_HEALTH_BAR);
		if (_has_demonic_infusion)
		{
			draw_text(_stats_x + string_width(_left_stat_text), _stats_y + (_line_height * _stat_line_index), " (Demonic Infusion)");
		}
		else
		{
			draw_text(_stats_x + string_width(_left_stat_text), _stats_y + (_line_height * _stat_line_index), " (+" + string_format(_attack_speed_bonus, 0, 2) + ")");
		}
		_stat_line_index++;

		_left_stat_text = "Move speed: " + string_format(_demon_stats.move_speed, 0, 2);
		draw_set_color(COLOR_CULTIST_FERVOR);
		draw_text(_stats_x, _stats_y + (_line_height * _stat_line_index), _left_stat_text);
		draw_set_color(COLOR_HEALTH_BAR);
		draw_text(_stats_x + string_width(_left_stat_text), _stats_y + (_line_height * _stat_line_index), " (+" + string_format(_move_speed_bonus, 0, 2) + ")");
		_stat_line_index++;

		var _right_stat_text = "Ability rec: " + string_format(_demon_stats.abilities_cd_spd, 0, 2);
		draw_set_color(COLOR_CULTIST_SPIRIT);
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

		_right_stat_text = "Magic resistance: " + string_format(_demon_stats.magic_resistance - 100, 0, 1) + "%";
		draw_set_color(COLOR_CULTIST_SPIRIT);
		draw_text(_stats_x, _stats_y + (_line_height * _stat_line_index), _right_stat_text);
		draw_set_color(COLOR_HEALTH_BAR);
		draw_text(_stats_x + string_width(_right_stat_text), _stats_y + (_line_height * _stat_line_index), " (+" + string_format(_resistance_bonus, 0, 1) + "%)");
		_stat_line_index++;

		if (_demon_stats.aoe_radius > 0)
		{
			draw_set_color(COLOR_HUD_TEXT);
			draw_text(_stats_x, _stats_y + (_line_height * _stat_line_index), "Aoe radius: " + string(_demon_stats.aoe_radius));
			_stat_line_index++;
		}

		// Draw the full ability list below the unit characteristics.
		var _abilities_y = _stats_y + (_line_height * _stat_line_index) + 18;

		draw_set_color(COLOR_HUD_PROJECTILE_DESCRIPTION);
		draw_text(_hover_x + _hover_padding, _abilities_y, "Abilities");
		draw_text_ext(_hover_x + _hover_padding, _abilities_y + 22, _abilities_text, 16, _ability_width);

		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		draw_set_color(c_white);
		draw_set_alpha(1);
	}
}

// Draw combat unit stats on hover.
if (global.focus_window == FOCUS_WINDOW.NOONE
	&& instance_exists(o_camera_controller)
	&& (!variable_global_exists("squad_info_window_open") || !global.squad_info_window_open)
	&& (!variable_global_exists("tutorial_popup_active") || !global.tutorial_popup_active))
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
	var _hovered_unit_is_enemy = false;
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
				_hovered_unit_is_enemy = false;
			}
		}
	}

	var _enemy_count = instance_number(o_enemy_units);

	for (var _enemy_index = 0; _enemy_index < _enemy_count; ++_enemy_index)
	{
		var _enemy_unit = instance_find(o_enemy_units, _enemy_index);

		if (instance_exists(_enemy_unit)
			&& _mouse_world_x >= _enemy_unit.bbox_left
			&& _mouse_world_x <= _enemy_unit.bbox_right
			&& _mouse_world_y >= _enemy_unit.bbox_top
			&& _mouse_world_y <= _enemy_unit.bbox_bottom)
		{
			var _distance_to_enemy = point_distance(_mouse_world_x, _mouse_world_y, _enemy_unit.x, _enemy_unit.y);

			if (_distance_to_enemy <= _nearest_distance)
			{
				_nearest_distance = _distance_to_enemy;
				_hovered_unit = _enemy_unit;
				_hovered_unit_is_enemy = true;
			}
		}
	}

	if (instance_exists(_hovered_unit))
	{
		var _unit_object = _hovered_unit.object_index;
		var _matchup = combat_unit_matchup_get(_unit_object);
		var _strong_against = _matchup.strong_against;
		var _weak_against = _matchup.weak_against;

		var _hover_width = 260;
		var _hover_height = 248;
		var _is_goblin_hovered = _hovered_unit.object_index == o_goblin;
		var _strong_count = array_length(_strong_against);
		var _weak_count = array_length(_weak_against);
		var _matchup_row_count = (_strong_count > 0 ? 1 : 0) + (_weak_count > 0 ? 1 : 0);

		if (_matchup_row_count > 0)
		{
			var _matchup_row_height = 48;
			_hover_height += 12 + (_matchup_row_height * _matchup_row_count);
		}

		if (_is_goblin_hovered)
		{
			_hover_height = 126;
		}

		var _hover_margin = 18;
		var _hover_y_max = max(_hover_margin, camera_view_height - _hover_height - _hover_margin);
		var _hover_x = _hover_margin;
		var _hover_y = min(120, _hover_y_max);
		var _hover_padding = 14;
		var _unit_name = object_get_name(_hovered_unit.object_index);
		var _damage_text = "Damage: " + string_format(_hovered_unit.damage, 0, 1);
		var _attack_speed = room_speed / max(_hovered_unit.reload_time, 1);
		var _armor_text = "Armor: " + string_format(_hovered_unit.armor - 100, 0, 1) + "%";
		var _magic_resistance_text = "Magic resistance: " + string_format(_hovered_unit.magic_resistance - 100, 0, 1) + "%";
		var _has_demonic_infusion = variable_instance_exists(_hovered_unit, "demonic_infusion_timer")
			&& _hovered_unit.demonic_infusion_timer > 0;

		if (variable_instance_exists(_hovered_unit, "effective_attack_speed_get"))
		{
			_attack_speed = _hovered_unit.effective_attack_speed_get();
		}

		if (_hovered_unit.magic_damage > 0)
		{
			_damage_text = "Magic damage: " + string_format(_hovered_unit.magic_damage, 0, 1);
		}

		if (_hovered_unit.object_index == o_skeleton_bonelet)
		{
			_unit_name = "Skeleton Bonelet";
		}
		else if (_hovered_unit.object_index == o_skeleton_warrior)
		{
			_unit_name = "Bone Warrior";
		}
		else if (_hovered_unit.object_index == o_skeleton_archer)
		{
			_unit_name = "Bone Archer";
		}
		else if (_hovered_unit.object_index == o_skeleton_mage)
		{
			_unit_name = "Bone Mage";
		}
		else if (_hovered_unit.object_index == o_skeleton_healer)
		{
			_unit_name = "Skeleton Healer";
		}
		else if (_hovered_unit.object_index == o_skeleton)
		{
			_unit_name = "Skeleton";
		}
		else if (_hovered_unit.object_index == o_zombie)
		{
			_unit_name = "Zombie";
		}
		else if (_hovered_unit.object_index == o_mawling)
		{
			_unit_name = "Mawling";
		}
		else if (_hovered_unit.object_index == o_demon_wizard)
		{
			_unit_name = "Demon Wizard";
		}
		else if (_hovered_unit.object_index == o_pitling)
		{
			_unit_name = "Pitling";
		}
		else if (_hovered_unit.object_index == o_succubus)
		{
			_unit_name = "Succubus";
		}
		else if (_hovered_unit.object_index == o_balgor)
		{
			_unit_name = "Balgor";
		}
		else if (_hovered_unit.object_index == o_goblin)
		{
			_unit_name = "Goblin";
		}
		else if (_hovered_unit.object_index == o_imp)
		{
			_unit_name = "Imp";
		}
		else if (_hovered_unit.object_index == o_imp_clone)
		{
			_unit_name = "Bloody Clone";
		}
		else if (_hovered_unit.object_index == o_warlock)
		{
			_unit_name = "Warlock";
		}
		else if (_hovered_unit.object_index == o_brute)
		{
			_unit_name = "Brute";
		}
		else if (_hovered_unit.object_index == o_enemy_peasant)
		{
			_unit_name = "Peasant";
		}
		else if (_hovered_unit.object_index == o_enemy_archer)
		{
			_unit_name = "Archer";
		}
		else if (_hovered_unit.object_index == o_enemy_knight)
		{
			_unit_name = "Knight";
		}
		else if (_hovered_unit.object_index == o_enemy_mage)
		{
			_unit_name = "Mage";
		}
		else if (_hovered_unit.object_index == o_enemy_catapult)
		{
			_unit_name = "Catapult";
		}
		else if (_hovered_unit.object_index == o_boss_griffith)
		{
			_unit_name = "Griffith";
		}

		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		draw_set_alpha(0.96);
		draw_set_color(COLOR_HUD_BACKGROUND);
		draw_rectangle(_hover_x, _hover_y, _hover_x + _hover_width, _hover_y + _hover_height, false);
		draw_set_alpha(1);
		draw_set_color(_hovered_unit_is_enemy ? COLOR_DAMAGE_ENEMY : COLOR_PROJECTILE_SUMMON);
		draw_rectangle(_hover_x, _hover_y, _hover_x + _hover_width, _hover_y + _hover_height, true);

		draw_set_color(COLOR_HUD_TEXT);
		draw_text(_hover_x + _hover_padding, _hover_y + _hover_padding, _unit_name);

		var _extra_line_y = 42;

		if (_is_goblin_hovered)
		{
			draw_text(_hover_x + _hover_padding, _hover_y + _extra_line_y, "Can work in buildings during the day.");
			_extra_line_y += 20;
			draw_text(_hover_x + _hover_padding, _hover_y + _extra_line_y, "Rests at night and does not fight.");
			_extra_line_y += 28;
		}
		else
		{
			draw_text(_hover_x + _hover_padding, _hover_y + _extra_line_y, "HP: " + string_format(_hovered_unit.hp, 0, 1) + " / " + string_format(_hovered_unit.max_hp, 0, 1));
			_extra_line_y += 20;
			draw_text(_hover_x + _hover_padding, _hover_y + _extra_line_y, _damage_text);
			_extra_line_y += 20;
			draw_text(_hover_x + _hover_padding, _hover_y + _extra_line_y, "Attack speed: " + string_format(_attack_speed, 0, 2));
			_extra_line_y += 20;
			draw_text(_hover_x + _hover_padding, _hover_y + _extra_line_y, "Attack radius: " + string_format(_hovered_unit.attack_radius, 0, 0));
			_extra_line_y += 20;
			draw_text(_hover_x + _hover_padding, _hover_y + _extra_line_y, "Move speed: " + string_format(_hovered_unit.move_speed, 0, 2));
			_extra_line_y += 20;
			draw_text(_hover_x + _hover_padding, _hover_y + _extra_line_y, _armor_text);
			_extra_line_y += 20;
			draw_text(_hover_x + _hover_padding, _hover_y + _extra_line_y, _magic_resistance_text);
			_extra_line_y += 20;

			if (_has_demonic_infusion)
			{
				draw_set_color(COLOR_WARLOCK_DEMONIC_INFUSION);
				draw_text(_hover_x + _hover_padding, _hover_y + _extra_line_y, "Demonic Infusion +" + string_format(BALANCE_WARLOCK_DEMONIC_INFUSION_ATTACK_SPEED_BONUS * 100, 0, 0) + "%");
				_extra_line_y += 20;
			}

			if (variable_instance_exists(_hovered_unit, "worker_speed_multiplier"))
			{
				draw_set_color(COLOR_CULTIST_BODY);
				draw_text(_hover_x + _hover_padding, _hover_y + _extra_line_y, "Worker +" + string_format(_hovered_unit.worker_speed_multiplier, 0, 1) + "x");
				_extra_line_y += 20;
			}
		}

		if (variable_instance_exists(_hovered_unit, "summon_nights_remaining"))
		{
			var _summon_life_label = "Nights left";

			if (variable_instance_exists(_hovered_unit, "summon_life_label"))
			{
				_summon_life_label = _hovered_unit.summon_life_label;
			}

			draw_set_color(COLOR_HUD_SOULS);
			draw_text(_hover_x + _hover_padding, _hover_y + _extra_line_y, _summon_life_label + ": " + string(_hovered_unit.summon_nights_remaining));
			_extra_line_y += 20;
		}

		// Draw matchup portraits on green or red circles below the unit stats.
		var _matchup_y = _hover_y + _extra_line_y + 10;
		var _matchup_icon_start_x = _hover_x + 126;
		var _matchup_icon_gap = 42;
		var _matchup_icon_radius = 18;
		var _matchup_sprite_size = 28;

		if (_strong_count > 0)
		{
			draw_set_color(COLOR_PROJECTILE_SUMMON);
			draw_text(_hover_x + _hover_padding, _matchup_y + 8, "Strong vs");

			for (var _strong_index = 0; _strong_index < _strong_count; ++_strong_index)
			{
				var _strong_object = _strong_against[_strong_index];
				var _strong_sprite = object_get_sprite(_strong_object);
				var _strong_x = _matchup_icon_start_x + (_matchup_icon_gap * _strong_index);
				var _strong_y = _matchup_y + _matchup_icon_radius;

				draw_set_alpha(0.9);
				draw_set_color(COLOR_PROJECTILE_SUMMON);
				draw_circle(_strong_x, _strong_y, _matchup_icon_radius, false);
				draw_set_alpha(1);
				draw_set_color(c_white);
				draw_circle(_strong_x, _strong_y, _matchup_icon_radius, true);

				if (_strong_sprite != -1)
				{
					var _strong_sprite_width = max(1, sprite_get_width(_strong_sprite));
					var _strong_sprite_height = max(1, sprite_get_height(_strong_sprite));
					var _strong_sprite_scale = min(_matchup_sprite_size / _strong_sprite_width, _matchup_sprite_size / _strong_sprite_height);
					var _strong_draw_x = _strong_x + ((sprite_get_xoffset(_strong_sprite) - (_strong_sprite_width * 0.5)) * _strong_sprite_scale);
					var _strong_draw_y = _strong_y + ((sprite_get_yoffset(_strong_sprite) - (_strong_sprite_height * 0.5)) * _strong_sprite_scale);

					draw_sprite_ext(_strong_sprite, 0, _strong_draw_x, _strong_draw_y, _strong_sprite_scale, _strong_sprite_scale, 0, c_white, 1);
				}
			}

			_matchup_y += 48;
		}

		if (_weak_count > 0)
		{
			draw_set_color(COLOR_STATUS_NEGATIVE_RED);
			draw_text(_hover_x + _hover_padding, _matchup_y + 8, "Weak vs");

			for (var _weak_index = 0; _weak_index < _weak_count; ++_weak_index)
			{
				var _weak_object = _weak_against[_weak_index];
				var _weak_sprite = object_get_sprite(_weak_object);
				var _weak_x = _matchup_icon_start_x + (_matchup_icon_gap * _weak_index);
				var _weak_y = _matchup_y + _matchup_icon_radius;

				draw_set_alpha(0.9);
				draw_set_color(COLOR_STATUS_NEGATIVE_RED);
				draw_circle(_weak_x, _weak_y, _matchup_icon_radius, false);
				draw_set_alpha(1);
				draw_set_color(c_white);
				draw_circle(_weak_x, _weak_y, _matchup_icon_radius, true);

				if (_weak_sprite != -1)
				{
					var _weak_sprite_width = max(1, sprite_get_width(_weak_sprite));
					var _weak_sprite_height = max(1, sprite_get_height(_weak_sprite));
					var _weak_sprite_scale = min(_matchup_sprite_size / _weak_sprite_width, _matchup_sprite_size / _weak_sprite_height);
					var _weak_draw_x = _weak_x + ((sprite_get_xoffset(_weak_sprite) - (_weak_sprite_width * 0.5)) * _weak_sprite_scale);
					var _weak_draw_y = _weak_y + ((sprite_get_yoffset(_weak_sprite) - (_weak_sprite_height * 0.5)) * _weak_sprite_scale);

					draw_sprite_ext(_weak_sprite, 0, _weak_draw_x, _weak_draw_y, _weak_sprite_scale, _weak_sprite_scale, 0, c_white, 1);
				}
			}
		}

		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		draw_set_color(c_white);
		draw_set_alpha(1);
	}
}

// Draw the debug menu after every regular GUI layer.
debug_menu_draw();
