// HUD layout in GUI coordinates.
hud_margin_x = 18;
hud_margin_y = 16;
hud_sidebar_width = 431;
resource_item_width = 150;
resource_item_height = 34;
resource_item_gap = 10;
resource_icon_radius = 8;
resource_icon_size = 22;
resource_icon_text_gap = 12;
resource_text_padding = 20;
resource_sidebar_y = 48;
resource_sidebar_icon_size = 30;
resource_sidebar_first_icon_offset_x = 34;
resource_sidebar_item_gap = 94;
resource_sidebar_value_offset_x = 36;

// Squad information window opened from the roster cards with RMB.
squad_info_squad = noone;
global.squad_info_window_open = false;
squad_info_window_width = 520;
squad_info_window_height = 430;
squad_info_padding = 18;
squad_info_unit_icon_size = 52;
squad_info_unit_icon_gap = 8;
squad_info_unit_count_scale = 0.72;
squad_info_unit_count_margin = 2;
squad_info_unit_count_padding_x = 4;
squad_info_unit_count_padding_y = 2;
squad_info_unit_count_background_alpha = 0.88;

hud_squad_at_gui_position = function(_mouse_x, _mouse_y)
{
	if (!variable_global_exists("squads") || !variable_global_exists("squad_limits"))
	{
		return noone;
	}

	var _gui_height = display_get_gui_height();
	var _scale = clamp(_gui_height / 1080, 0.6, 1);
	var _card_width = 112 * _scale;
	var _card_height = 145 * _scale;
	var _card_gap = 19 * _scale;
	var _card_start_x = 53 * _scale;
	var _card_y = 58 * _scale;
	var _card_index = 0;
	var _squad_count = array_length(global.squads);

	for (var _squad_type = SQUAD_TYPE.ARCHDEMON; _squad_type < SQUAD_TYPE.COUNT; ++_squad_type)
	{
		var _type_squad_count = 0;

		for (var _squad_index = 0; _squad_index < _squad_count; ++_squad_index)
		{
			var _squad = global.squads[_squad_index];

			if (_squad.squad_type != _squad_type)
			{
				continue;
			}

			var _card_x = _card_start_x + (_card_index * (_card_width + _card_gap));

			if (point_in_rectangle(_mouse_x, _mouse_y, _card_x, _card_y, _card_x + _card_width, _card_y + _card_height))
			{
				return _squad;
			}

			_type_squad_count++;
			_card_index++;
		}

		_card_index += max(0, global.squad_limits[_squad_type] - _type_squad_count);
	}

	return noone;
};

hud_squad_unique_unit_objects_get = function(_squad)
{
	var _unit_objects = [];

	if (!is_struct(_squad))
	{
		return _unit_objects;
	}

	var _squad_unit_count = array_length(_squad.unit_objects);
	var _live_unit_count = array_length(_squad.units);

	for (var _unit_index = 0; _unit_index < _squad_unit_count; ++_unit_index)
	{
		var _unit_object = _squad.unit_objects[_unit_index];

		if (_unit_index < _live_unit_count && instance_exists(_squad.units[_unit_index]))
		{
			_unit_object = _squad.units[_unit_index].object_index;
		}

		var _object_is_added = false;
		var _unique_count = array_length(_unit_objects);

		for (var _unique_index = 0; _unique_index < _unique_count; ++_unique_index)
		{
			if (_unit_objects[_unique_index] == _unit_object)
			{
				_object_is_added = true;
				break;
			}
		}

		if (!_object_is_added)
		{
			array_push(_unit_objects, _unit_object);
		}
	}

	return _unit_objects;
};

hud_squad_unit_instance_get = function(_squad, _unit_object)
{
	if (!is_struct(_squad))
	{
		return noone;
	}

	var _unit_count = array_length(_squad.units);

	for (var _unit_index = 0; _unit_index < _unit_count; ++_unit_index)
	{
		var _unit = _squad.units[_unit_index];

		if (instance_exists(_unit) && _unit.object_index == _unit_object)
		{
			return _unit;
		}
	}

	return noone;
};

hud_squad_unit_type_count_get = function(_squad, _unit_object)
{
	if (!is_struct(_squad))
	{
		return 0;
	}

	var _matching_unit_count = 0;
	var _squad_unit_count = array_length(_squad.unit_objects);
	var _live_unit_count = array_length(_squad.units);

	for (var _unit_index = 0; _unit_index < _squad_unit_count; ++_unit_index)
	{
		var _squad_unit_object = _squad.unit_objects[_unit_index];

		if (_unit_index < _live_unit_count && instance_exists(_squad.units[_unit_index]))
		{
			_squad_unit_object = _squad.units[_unit_index].object_index;
		}

		if (_squad_unit_object == _unit_object)
		{
			_matching_unit_count++;
		}
	}

	return _matching_unit_count;
};

hud_unit_display_name_get = function(_unit_object)
{
	if (_unit_object == o_skeleton_bonelet)
	{
		return "Skeleton Bonelet";
	}

	if (_unit_object == o_skeleton_warrior)
	{
		return "Bone Warrior";
	}

	if (_unit_object == o_skeleton_archer)
	{
		return "Bone Archer";
	}

	if (_unit_object == o_skeleton_mage)
	{
		return "Bone Mage";
	}

	if (_unit_object == o_skeleton_healer)
	{
		return "Skeleton Healer";
	}

	if (_unit_object == o_skeleton)
	{
		return "Skeleton";
	}

	if (_unit_object == o_mawling)
	{
		return "Mawling";
	}

	if (_unit_object == o_pitling)
	{
		return "Pitling";
	}

	if (_unit_object == o_succubus)
	{
		return "Succubus";
	}

	if (_unit_object == o_balgor)
	{
		return "Balgor";
	}

	if (_unit_object == o_demon_wizard)
	{
		return "Demon Wizard";
	}

	if (_unit_object == o_imp)
	{
		return "Imp";
	}

	if (_unit_object == o_brute)
	{
		return "Brute";
	}

	if (_unit_object == o_warlock)
	{
		return "Warlock";
	}

	if (_unit_object == o_archdemon)
	{
		return "Archdemon";
	}

	return object_get_name(_unit_object);
};

hud_unit_base_stats_create = function(
	_max_hp,
	_armor,
	_magic_resistance,
	_damage,
	_magic_damage,
	_reload_time,
	_attack_radius,
	_move_speed
)
{
	return {
		max_hp: _max_hp,
		armor: _armor,
		magic_resistance: _magic_resistance,
		damage: _damage,
		magic_damage: _magic_damage,
		reload_time: _reload_time * room_speed,
		attack_radius: _attack_radius,
		move_speed: _move_speed
	};
};

hud_unit_base_stats_get = function(_unit_object)
{
	var _stats = noone;

	if (_unit_object == o_skeleton_bonelet)
	{
		_stats = hud_unit_base_stats_create(BALANCE_SKELETON_BONELET_HP, BALANCE_SKELETON_BONELET_ARMOR, BALANCE_SKELETON_BONELET_MAGIC_RESISTANCE, BALANCE_SKELETON_BONELET_DAMAGE, 0, BALANCE_SKELETON_BONELET_RELOAD_TIME, BALANCE_SKELETON_BONELET_ATTACK_RADIUS, BALANCE_SKELETON_BONELET_MOVE_SPEED);
	}
	else if (_unit_object == o_skeleton_warrior)
	{
		_stats = hud_unit_base_stats_create(BALANCE_SKELETON_WARRIOR_HP, BALANCE_SKELETON_WARRIOR_ARMOR, BALANCE_SKELETON_WARRIOR_MAGIC_RESISTANCE, BALANCE_SKELETON_WARRIOR_DAMAGE, 0, BALANCE_SKELETON_WARRIOR_RELOAD_TIME, BALANCE_SKELETON_WARRIOR_ATTACK_RADIUS, BALANCE_SKELETON_WARRIOR_MOVE_SPEED);
	}
	else if (_unit_object == o_skeleton_archer)
	{
		_stats = hud_unit_base_stats_create(BALANCE_SKELETON_ARCHER_HP, BALANCE_SKELETON_ARCHER_ARMOR, BALANCE_SKELETON_ARCHER_MAGIC_RESISTANCE, BALANCE_SKELETON_ARCHER_DAMAGE, 0, BALANCE_SKELETON_ARCHER_RELOAD_TIME, BALANCE_SKELETON_ARCHER_ATTACK_RADIUS, BALANCE_SKELETON_ARCHER_MOVE_SPEED);
	}
	else if (_unit_object == o_skeleton_mage)
	{
		_stats = hud_unit_base_stats_create(BALANCE_SKELETON_MAGE_HP, BALANCE_SKELETON_MAGE_ARMOR, BALANCE_SKELETON_MAGE_MAGIC_RESISTANCE, 0, BALANCE_SKELETON_MAGE_MAGIC_DAMAGE, BALANCE_SKELETON_MAGE_RELOAD_TIME, BALANCE_SKELETON_MAGE_ATTACK_RADIUS, BALANCE_SKELETON_MAGE_MOVE_SPEED);
	}
	else if (_unit_object == o_skeleton_healer)
	{
		_stats = hud_unit_base_stats_create(BALANCE_SKELETON_HEALER_HP, BALANCE_SKELETON_HEALER_ARMOR, BALANCE_SKELETON_HEALER_MAGIC_RESISTANCE, BALANCE_SKELETON_HEALER_DAMAGE, BALANCE_SKELETON_HEALER_MAGIC_DAMAGE, BALANCE_SKELETON_HEALER_RELOAD_TIME, BALANCE_SKELETON_HEALER_ATTACK_RADIUS, BALANCE_SKELETON_HEALER_MOVE_SPEED);
	}
	else if (_unit_object == o_skeleton)
	{
		_stats = hud_unit_base_stats_create(BALANCE_SKELETON_HP, BALANCE_SKELETON_ARMOR, BALANCE_SKELETON_MAGIC_RESISTANCE, BALANCE_SKELETON_DAMAGE, 0, BALANCE_SKELETON_RELOAD_TIME, BALANCE_SKELETON_ATTACK_RADIUS, BALANCE_SKELETON_MOVE_SPEED);
	}
	else if (_unit_object == o_mawling)
	{
		_stats = hud_unit_base_stats_create(BALANCE_MAWLING_HP, BALANCE_MAWLING_ARMOR, BALANCE_MAWLING_MAGIC_RESISTANCE, BALANCE_MAWLING_DAMAGE, 0, BALANCE_MAWLING_RELOAD_TIME, BALANCE_MAWLING_ATTACK_RADIUS, BALANCE_MAWLING_MOVE_SPEED);
	}
	else if (_unit_object == o_pitling)
	{
		_stats = hud_unit_base_stats_create(BALANCE_PITLING_HP, BALANCE_PITLING_ARMOR, BALANCE_PITLING_MAGIC_RESISTANCE, BALANCE_PITLING_DAMAGE, 0, BALANCE_PITLING_RELOAD_TIME, BALANCE_PITLING_ATTACK_RADIUS, BALANCE_PITLING_MOVE_SPEED);
	}
	else if (_unit_object == o_succubus)
	{
		_stats = hud_unit_base_stats_create(BALANCE_SUCCUBUS_HP, BALANCE_SUCCUBUS_ARMOR, BALANCE_SUCCUBUS_MAGIC_RESISTANCE, BALANCE_SUCCUBUS_DAMAGE, BALANCE_SUCCUBUS_MAGIC_DAMAGE, BALANCE_SUCCUBUS_RELOAD_TIME, BALANCE_SUCCUBUS_ATTACK_RADIUS, BALANCE_SUCCUBUS_MOVE_SPEED);
	}
	else if (_unit_object == o_balgor)
	{
		_stats = hud_unit_base_stats_create(BALANCE_BALGOR_HP, BALANCE_BALGOR_ARMOR, BALANCE_BALGOR_MAGIC_RESISTANCE, BALANCE_BALGOR_DAMAGE, 0, BALANCE_BALGOR_RELOAD_TIME, BALANCE_BALGOR_ATTACK_RADIUS, BALANCE_BALGOR_MOVE_SPEED);
	}
	else if (_unit_object == o_demon_wizard)
	{
		_stats = hud_unit_base_stats_create(BALANCE_DEMON_WIZARD_HP, BALANCE_DEMON_WIZARD_ARMOR, BALANCE_DEMON_WIZARD_MAGIC_RESISTANCE, BALANCE_DEMON_WIZARD_DAMAGE, BALANCE_DEMON_WIZARD_MAGIC_DAMAGE, BALANCE_DEMON_WIZARD_RELOAD_TIME, BALANCE_DEMON_WIZARD_ATTACK_RADIUS, BALANCE_DEMON_WIZARD_MOVE_SPEED);
	}
	else if (_unit_object == o_imp)
	{
		_stats = hud_unit_base_stats_create(BALANCE_IMP_HP, BALANCE_IMP_ARMOR, BALANCE_IMP_RESISTANCE, BALANCE_IMP_DAMAGE, 0, 1 / BALANCE_IMP_ATTACK_SPEED, BALANCE_IMP_ATTACK_RADIUS, BALANCE_IMP_MOVE_SPEED);
	}
	else if (_unit_object == o_brute)
	{
		_stats = hud_unit_base_stats_create(BALANCE_BRUTE_HP, BALANCE_BRUTE_ARMOR, BALANCE_BRUTE_RESISTANCE, BALANCE_BRUTE_DAMAGE, 0, 1 / BALANCE_BRUTE_ATTACK_SPEED, BALANCE_BRUTE_ATTACK_RADIUS, BALANCE_BRUTE_MOVE_SPEED);
	}
	else if (_unit_object == o_warlock)
	{
		_stats = hud_unit_base_stats_create(BALANCE_WARLOCK_HP, BALANCE_WARLOCK_ARMOR, BALANCE_WARLOCK_RESISTANCE, 0, BALANCE_WARLOCK_MAGIC_DAMAGE, 1 / BALANCE_WARLOCK_ATTACK_SPEED, BALANCE_WARLOCK_ATTACK_RADIUS, BALANCE_WARLOCK_MOVE_SPEED);
	}

	return _stats;
};

hud_unit_matchups_get = function(_unit_object)
{
	var _strong_against = [];
	var _weak_against = [];

	if (_unit_object == o_skeleton_bonelet)
	{
		_strong_against = [o_enemy_mage];
		_weak_against = [o_enemy_peasant, o_enemy_knight];
	}
	else if (_unit_object == o_skeleton_warrior)
	{
		_strong_against = [o_enemy_peasant, o_enemy_catapult];
		_weak_against = [o_enemy_mage];
	}
	else if (_unit_object == o_skeleton_archer)
	{
		_strong_against = [o_enemy_archer, o_enemy_mage];
		_weak_against = [o_enemy_knight, o_enemy_catapult];
	}
	else if (_unit_object == o_skeleton_mage)
	{
		_strong_against = [o_enemy_knight, o_enemy_mage];
		_weak_against = [o_enemy_peasant, o_enemy_catapult];
	}
	else if (_unit_object == o_mawling)
	{
		_strong_against = [o_enemy_mage];
		_weak_against = [o_enemy_peasant, o_enemy_knight];
	}
	else if (_unit_object == o_pitling)
	{
		_strong_against = [o_enemy_archer];
		_weak_against = [o_enemy_mage];
	}
	else if (_unit_object == o_succubus)
	{
		_strong_against = [o_enemy_archer, o_enemy_knight];
		_weak_against = [o_enemy_peasant];
	}
	else if (_unit_object == o_balgor)
	{
		_strong_against = [o_enemy_peasant, o_enemy_knight, o_enemy_catapult];
		_weak_against = [o_enemy_archer, o_enemy_mage];
	}

	return { strong_against: _strong_against, weak_against: _weak_against };
};

hud_squad_info_unit_icon_rect_get = function(_window_x, _window_y, _unit_index)
{
	return {
		x: _window_x + squad_info_padding + (_unit_index * (squad_info_unit_icon_size + squad_info_unit_icon_gap)),
		y: _window_y + 54,
		width: squad_info_unit_icon_size,
		height: squad_info_unit_icon_size
	};
};

hud_squad_info_stat_draw = function(_label, _current_value, _base_value, _x, _y, _decimal_places = 1, _suffix = "")
{
	var _text = _label + ": " + string_format(_current_value, 0, _decimal_places) + _suffix;
	draw_set_color(COLOR_HUD_TEXT);
	draw_text(_x, _y, _text);
	var _difference = _current_value - _base_value;

	if (abs(_difference) > 0.001)
	{
		var _difference_prefix = _difference > 0 ? "+" : "";
		draw_set_color(_difference > 0 ? COLOR_PROJECTILE_SUMMON : COLOR_STATUS_NEGATIVE_RED);
		draw_text(_x + string_width(_text) + 6, _y, "(" + _difference_prefix + string_format(_difference, 0, _decimal_places) + _suffix + ")");
	}
};

// Cannon HP is centered against the top edge of the HUD.
cannon_hp_bar_width_share = 0.375;
cannon_hp_fill_height_share = 0.02778;
cannon_hp_background_height_share = 0.01389;
cannon_hp_background_top_share = 0.00741;
cannon_hp_label = "CANNON HP";
cannon_hp_label_scale = 0.5;
// Upcoming special-night warning pulses directly below the Cannon HP bar.
cannon_special_night_boss_text = "AT NIGHT BOSS WILL ARRIVE!";
cannon_special_night_blood_moon_text = "BLOOD MOON!";
cannon_special_night_warning_gap = 20;
cannon_special_night_warning_scale_min = 0.7;
cannon_special_night_warning_scale_max = 0.9;
cannon_special_night_warning_pulse_speed = 0.006;
cannon_special_night_warning_shadow_offset = 2;

// First night prompt nudges the player to select the starting cultist projectile.
first_night_cultist_prompt_text = "PRESS 1";
first_night_cultist_aim_prompt_text = "AIM AND PRESS LMB";
first_night_cultist_prompt_scale = 3;
first_night_cultist_prompt_shadow_offset = 4;

// Day cycle and shrine objective display in the top-right corner.
day_phase_text_offset_x = 85;
day_phase_text_y = 83;
day_phase_bar_offset_x = 47;
day_phase_bar_y = 120;
day_phase_bar_width = 336;
day_phase_bar_height = 35;
day_phase_objective_y = 1027;
shrine_icon_size = 30;
shrine_icon_gap = 8;
shrine_icon_y_offset = 55;
night_panel_satiety_offset_x = -150;
night_panel_satiety_offset_y = -55;
night_panel_icon_gap = 34;
night_panel_icon_size = 28;
night_panel_visible_count = 11;
night_panel_day_label_width = 150;
night_panel_day_label_height = 48;
cultist_counter_x = 53;
cultist_counter_y = 219;
cultist_counter_width = 167;
cultist_counter_height = 80;
cultist_counter_icon_x = 48;
cultist_counter_icon_y = 40;
cultist_counter_icon_height = 58;
cultist_counter_text_x = 80;
full_moon_timer_width = 360;
full_moon_timer_height = 18;
full_moon_timer_bottom = 174;
full_moon_timer_button_gap = 10;
full_moon_retreat_button_width = 190;
full_moon_retreat_button_height = 46;
full_moon_retreat_button_bottom = 218;

// Player unit counter is pinned just left of the right HUD sidebar.
unit_counter_width = 96;
unit_counter_row_height = 38;
unit_counter_gap_right = 10;
unit_counter_y = 82;
unit_counter_padding = 8;
unit_counter_row_gap = 6;
unit_counter_icon_size = 26;
unit_counter_background_alpha = 0.68;
unit_counter_row_alpha = 0.26;
unit_counter_empty_alpha = 0.36;
unit_counter_unit_objects = [
	o_archdemon,
	o_imp,
	o_brute,
	o_warlock,
	o_skeleton,
	o_pitling,
	o_goblin
];
unit_counter_unit_sprites = [
	s_cultist_01,
	s_imp,
	s_brute,
	s_warlock,
	s_skeleton,
	s_demon,
	s_goblin
];

// Compact cultist status cards shown when no focus window is open.
cultist_status_card_width = 334;
cultist_status_card_height = 152;
cultist_status_card_margin_right = 48;
cultist_status_card_y = 126;
cultist_status_card_gap = 18;
cultist_status_card_slot_count = 3;
cultist_status_card_padding_x = 24;
cultist_status_card_portrait_width = 64;
cultist_status_card_portrait_height = 90;
cultist_status_card_portrait_y = 26;
cultist_status_card_level_y = 112;
cultist_status_card_text_x = 110;
cultist_status_card_name_y = 20;
cultist_status_card_name_max_characters = 14;
cultist_status_card_bar_x = 110;
cultist_status_card_bar_y = 55;
cultist_status_card_bar_width = 130;
cultist_status_card_bar_height = 18;
cultist_status_card_bar_gap = 8;
cultist_status_card_label_gap = 7;
cultist_status_card_background_alpha = 0.3;
cultist_status_card_bar_background_color = c_black;
cultist_status_card_hp_color = COLOR_HUD_CULTIST_STATUS_HP;
cultist_status_card_exp_color = COLOR_HUD_CULTIST_STATUS_EXP;
cultist_status_card_stamina_color = COLOR_HUD_CULTIST_STATUS_STAMINA;
cultist_status_card_label_color = COLOR_HUD_TEXT;

cultist_status_card_rect_get = function(_card_index)
{
	var _gui_width = display_get_gui_width();
	var _gui_height = display_get_gui_height();
	var _card_scale = clamp(_gui_height / 1080, 0.6, 1);
	var _sidebar_width = hud_sidebar_width * _card_scale;
	var _sidebar_x = _gui_width - _sidebar_width;
	var _card_width = cultist_status_card_width * _card_scale;
	var _card_height = cultist_status_card_height * _card_scale;
	var _card_gap = cultist_status_card_gap * _card_scale;
	var _card_x = _sidebar_x + ((_sidebar_width - _card_width) * 0.5);
	var _card_y = cultist_status_card_y + ((_card_height + _card_gap) * _card_index);

	return [_card_x, _card_y, _card_width, _card_height];
};

cultist_status_card_find_at_gui = function(_mouse_x, _mouse_y)
{
	// Legacy cultist cards are hidden and must not intercept world clicks.
	return noone;

	if (!variable_global_exists("archdemons")
		|| !variable_global_exists("focus_window")
		|| global.focus_window != FOCUS_WINDOW.NOONE
		|| (variable_global_exists("tutorial_popup_active") && global.tutorial_popup_active))
	{
		return noone;
	}

	var _gui_height = display_get_gui_height();
	var _cultist_count = array_length(global.archdemons);
	var _slot_count = min(cultist_status_card_slot_count, _cultist_count);

	for (var _card_index = 0; _card_index < _slot_count; ++_card_index)
	{
		var _card_rect = cultist_status_card_rect_get(_card_index);
		var _card_x = _card_rect[0];
		var _card_y = _card_rect[1];
		var _card_width = _card_rect[2];
		var _card_height = _card_rect[3];

		if (_card_y + _card_height > _gui_height - hud_margin_y)
		{
			break;
		}

		if (_mouse_x >= _card_x
			&& _mouse_x <= _card_x + _card_width
			&& _mouse_y >= _card_y
			&& _mouse_y <= _card_y + _card_height)
		{
			var _cultist = global.archdemons[_card_index];

			if (instance_exists(_cultist))
			{
				return _cultist;
			}
		}
	}

	return noone;
};

// Minimap mirrors the current battle around the cannon in the right HUD sidebar.
minimap_size = 384;
minimap_margin_right = 48;
minimap_y = 633;
minimap_world_radius = 5600;
minimap_base_size = 74;
minimap_enemy_size = 11;
minimap_cultist_width = 24;
minimap_cultist_height = 36;
minimap_cultist_bar_width = 19;
minimap_cultist_bar_height = 7;
minimap_cultist_bar_gap = 2;
minimap_view_alpha = 0.2;
minimap_view_border_width = 4;
minimap_view_min_size = 10;
minimap_ground_update_interval = 15;
minimap_ground_update_timer = minimap_ground_update_interval;
minimap_ground_cell_xs = [];
minimap_ground_cell_ys = [];
minimap_ground_amounts = [];
minimap_ground_is_saint = [];

minimap_geometry_get = function()
{
	if (!instance_exists(o_cannon))
	{
		return noone;
	}

	var _gui_width = display_get_gui_width();
	var _gui_height = display_get_gui_height();
	var _minimap_scale = clamp(_gui_height / 1080, 0.6, 1);
	var _minimap_size = minimap_size * _minimap_scale;
	var _minimap_x = _gui_width - (minimap_margin_right * _minimap_scale) - _minimap_size;
	var _minimap_y = minimap_y * _minimap_scale;
	var _minimap_cannon = instance_find(o_cannon, 0);

	return {
		x: _minimap_x,
		y: _minimap_y,
		right: _minimap_x + _minimap_size,
		bottom: _minimap_y + _minimap_size,
		center_x: _minimap_x + (_minimap_size * 0.5),
		center_y: _minimap_y + (_minimap_size * 0.5),
		size: _minimap_size,
		scale: _minimap_scale,
		world_center_x: _minimap_cannon.x,
		world_center_y: _minimap_cannon.y,
		world_to_minimap_scale: (_minimap_size * 0.5) / max(1, minimap_world_radius)
	};
};

minimap_world_position_from_gui = function(_mouse_x, _mouse_y)
{
	var _geometry = minimap_geometry_get();

	if (!is_struct(_geometry)
		|| _mouse_x < _geometry.x
		|| _mouse_x > _geometry.right
		|| _mouse_y < _geometry.y
		|| _mouse_y > _geometry.bottom)
	{
		return [false, 0, 0];
	}

	var _clamped_mouse_x = clamp(_mouse_x, _geometry.x, _geometry.right);
	var _clamped_mouse_y = clamp(_mouse_y, _geometry.y, _geometry.bottom);
	var _world_x = _geometry.world_center_x + ((_clamped_mouse_x - _geometry.center_x) / _geometry.world_to_minimap_scale);
	var _world_y = _geometry.world_center_y + ((_clamped_mouse_y - _geometry.center_y) / _geometry.world_to_minimap_scale);

	return [true, _world_x, _world_y];
};

minimap_ground_cache_update = function()
{
	minimap_ground_cell_xs = [];
	minimap_ground_cell_ys = [];
	minimap_ground_amounts = [];
	minimap_ground_is_saint = [];

	if (!instance_exists(o_cannon) || !instance_exists(o_corruption_grid))
	{
		return;
	}

	var _cannon = instance_find(o_cannon, 0);
	var _corruption_grid_object = instance_find(o_corruption_grid, 0);
	var _corruption_cell_size = _corruption_grid_object.cell_size;
	var _left_cell = clamp(floor((_cannon.x - minimap_world_radius) / _corruption_cell_size), 0, _corruption_grid_object.grid_width - 1);
	var _right_cell = clamp(floor((_cannon.x + minimap_world_radius) / _corruption_cell_size), 0, _corruption_grid_object.grid_width - 1);
	var _top_cell = clamp(floor((_cannon.y - minimap_world_radius) / _corruption_cell_size), 0, _corruption_grid_object.grid_height - 1);
	var _bottom_cell = clamp(floor((_cannon.y + minimap_world_radius) / _corruption_cell_size), 0, _corruption_grid_object.grid_height - 1);
	var _has_saint_grid = variable_instance_exists(_corruption_grid_object, "saint_grid");
	var _fog_of_war = noone;
	var _filter_saint_by_fog = variable_global_exists("fog_of_war_visible")
		&& global.fog_of_war_visible
		&& instance_exists(o_fog_of_war);

	if (_filter_saint_by_fog)
	{
		_fog_of_war = instance_find(o_fog_of_war, 0);
		_filter_saint_by_fog = variable_instance_exists(_fog_of_war, "fog_cell_is_seen");
	}

	for (var _cell_x = _left_cell; _cell_x <= _right_cell; ++_cell_x)
	{
		for (var _cell_y = _top_cell; _cell_y <= _bottom_cell; ++_cell_y)
		{
			var _corruption = ds_grid_get(_corruption_grid_object.corruption_grid, _cell_x, _cell_y);
			var _saint = 0;

			if (_has_saint_grid)
			{
				_saint = ds_grid_get(_corruption_grid_object.saint_grid, _cell_x, _cell_y);
			}

			// Saint ground should not reveal enemy influence through unexplored fog.
			if (_saint > 0 && _filter_saint_by_fog)
			{
				var _cell_center_x = (_cell_x * _corruption_cell_size) + (_corruption_cell_size * 0.5);
				var _cell_center_y = (_cell_y * _corruption_cell_size) + (_corruption_cell_size * 0.5);

				if (!_fog_of_war.fog_cell_is_seen(_cell_center_x, _cell_center_y))
				{
					continue;
				}
			}

			if (_saint <= 0 && _corruption < _corruption_grid_object.minimum_draw_corruption)
			{
				continue;
			}

			array_push(minimap_ground_cell_xs, _cell_x);
			array_push(minimap_ground_cell_ys, _cell_y);
			array_push(minimap_ground_amounts, max(_corruption, _saint));
			array_push(minimap_ground_is_saint, _saint > 0);
		}
	}
};

// Control hints stay visible only during unobstructed gameplay.
control_hints_x = 32;
control_hints_bottom_margin = 118;
control_hints_row_height = 28;
control_hints_row_gap = 8;
control_hints_key_min_width = 112;
control_hints_key_height = 24;
control_hints_key_padding_x = 10;
control_hints_key_text_gap = 12;
control_hints_padding_x = 12;
control_hints_padding_y = 10;
control_hints_background_alpha = 0.52;
control_hints_key_alpha = 0.18;
control_hint_keys = ["SPACE", "WASD", "MOUSE WHEEL"];
control_hint_actions = ["pause", "move camera", "zoom camera"];

// Cannon satiety is filled by hauling corpses to the cannon.
cannon_satiety_width = 460;
cannon_satiety_height = 34;
cannon_satiety_bar_offset_x = 92;
cannon_satiety_bar_width = 156;
cannon_satiety_bar_height = 8;
cannon_satiety_bar_gap = 5;
cannon_satiety_bar_label_gap = 8;
cannon_satiety_reward_icon_gap = 10;
cannon_satiety_reward_icon_radius = 7;
cannon_satiety_reward_group_gap = 18;
cannon_satiety_reward_label_gap = 3;
cannon_satiety_padding_x = 14;
cannon_satiety_label = "SATIETY";

// Wall fallen notice appears when cannon HP reaches zero, without stopping the run.
wall_fallen_notice_width = 420;
wall_fallen_notice_height = 92;
wall_fallen_notice_y = 96;
wall_fallen_notice_padding = 12;
wall_fallen_title = "THE WALL HAS FALLEN";
wall_fallen_description = "You lost, but can keep playing.";

// Objective complete notice appears when enough shrines are destroyed.
objective_complete_notice_width = 420;
objective_complete_notice_height = 92;
objective_complete_notice_y = 96;
objective_complete_notice_padding = 12;
objective_complete_title = "SHRINE CLAIMED";
objective_complete_description = "One Shrine has fallen to the cannon.";

// Resource display order from left to right in the top-left corner.
resource_order = [
	RESOURCES.FLESH,
	RESOURCES.SOULS,
	RESOURCES.IRON,
	RESOURCES.IHOR
];

resource_colors = [
	COLOR_HUD_FLESH,
	COLOR_HUD_SOULS,
	COLOR_HUD_IRON,
	COLOR_HUD_IHOR
];

resource_icon_sprites = [
	s_flesh_icon,
	s_soul_icon,
	s_iron_icon,
	s_ihor_icon
];

// Taint display is derived from the ground corruption grid.
corruption_display_name = "TAINT";
corruption_display_value = 0;
corruption_display_percent = 0;
corruption_display_total_cells = 0;
corruption_display_decimals = 1;
corruption_update_interval = 0.25 * room_speed;
corruption_update_timer = corruption_update_interval;
corruption_display_color = COLOR_HUD_TEXT;
corruption_minimap_offset_y = 16;
corruption_minimap_label_scale = 0.8;

// Projectile queue display at the bottom center of the HUD.
projectile_queue_margin_bottom = 18;
projectile_day_end_button_gap = 14;
projectile_slot_width = 86;
projectile_slot_height = 74;
projectile_slot_gap = 8;
projectile_slot_background_height = 64;
projectile_building_shell_row_offset_y = 82;
projectile_circle_radius = 13;
projectile_current_circle_radius = 17;
projectile_current_scale_padding = 5;
projectile_name_offset_y = 40;
projectile_payload_offset_y = 56;
projectile_payload_icon_size = 14;
projectile_payload_icon_gap = 4;
projectile_payload_count_gap = 2;
projectile_aim_prompt_gap = 6;
projectile_key_prompt_prefix = "Press ";
projectile_day_alpha = 0.45;
projectile_description_width = 330;
projectile_description_height = 58;
projectile_description_gap = 8;
projectile_description_line_separation = 16;

projectile_names = array_create(PROJECTILE_TYPE.COUNT, "");
projectile_names[PROJECTILE_TYPE.DAMAGE] = "DAMAGE";
projectile_names[PROJECTILE_TYPE.CORRUPTION] = "TAINT COMPOST";
projectile_names[PROJECTILE_TYPE.SUMMON] = "SUMMON";
projectile_names[PROJECTILE_TYPE.RALLY] = "RALLY";
projectile_names[PROJECTILE_TYPE.CULTIST] = "CULTIST";
projectile_names[PROJECTILE_TYPE.HEAL] = "FIRST AID MEAT";
projectile_names[PROJECTILE_TYPE.BOMB] = "HELLCOW";
projectile_names[PROJECTILE_TYPE.SKELETONS] = "SKELETONS";
projectile_names[PROJECTILE_TYPE.BUILDING_SHELL] = "STRUCTURE";
projectile_names[PROJECTILE_TYPE.CLEANSE] = "CLEANSE";
projectile_names[PROJECTILE_TYPE.DOOM_BELL] = "DOOM BELL";

projectile_descriptions = array_create(PROJECTILE_TYPE.COUNT, "");
projectile_descriptions[PROJECTILE_TYPE.DAMAGE] = "Damages units and buildings inside the impact area.";
projectile_descriptions[PROJECTILE_TYPE.CORRUPTION] = "Fires a wide volley that taints the ground. Its impact radius must touch existing Taint.";
projectile_descriptions[PROJECTILE_TYPE.SUMMON] = "Summons friendly forces through valid target reactions.";
projectile_descriptions[PROJECTILE_TYPE.RALLY] = "Sends half of nearby friendly units to the impact point.";
projectile_descriptions[PROJECTILE_TYPE.CULTIST] = "Launches a cultist into battle, dealing impact damage and spawning demon form.";
projectile_descriptions[PROJECTILE_TYPE.HEAL] = "Restores " + string(BALANCE_PROJECTILE_HEAL_AMOUNT) + " health to all friendly units inside a " + string(BALANCE_PROJECTILE_HEAL_RADIUS) + " pixel base radius. Each unit can be healed only once per volley. Payload Mastery improves healing; Tight tamping of meat improves healing and radius.";
projectile_descriptions[PROJECTILE_TYPE.BOMB] = "Deals " + string(BALANCE_PROJECTILE_BOMB_DAMAGE_AMOUNT) + " damage to enemy units inside a " + string(BALANCE_PROJECTILE_BOMB_RADIUS) + " pixel radius. Payload Mastery improves it.";
projectile_descriptions[PROJECTILE_TYPE.SKELETONS] = "Summons " + string(BALANCE_PROJECTILE_SKELETON_COUNT) + " skeleton inside a " + string(BALANCE_PROJECTILE_SKELETON_RADIUS) + " pixel radius. Payload Mastery improves it.";
projectile_descriptions[PROJECTILE_TYPE.BUILDING_SHELL] = "Builds its stored structure where it lands. Must be fired onto tainted ground.";
projectile_descriptions[PROJECTILE_TYPE.CLEANSE] = "Enemy projectile that removes Taint where it lands.";
projectile_descriptions[PROJECTILE_TYPE.DOOM_BELL] = "Deals "
	+ string(BALANCE_PROJECTILE_DOOM_BELL_DAMAGE_AMOUNT)
	+ " damage and taints the ground inside a "
	+ string(BALANCE_PROJECTILE_DOOM_BELL_RADIUS)
	+ " pixel radius.";
