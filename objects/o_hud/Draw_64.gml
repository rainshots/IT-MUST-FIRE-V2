// Draw global resources in the right HUD sidebar.
if (!variable_global_exists("resources"))
{
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

	// Draw the right-side HUD panel from the concept layout.
	draw_set_alpha(1);
	draw_set_color(COLOR_HUD_SIDEBAR);
	draw_rectangle(_sidebar_x, 0, _sidebar_gui_width, _sidebar_gui_height, false);

	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);

	var _resource_count = array_length(resource_order);

	for (var _resource_index = 0; _resource_index < _resource_count; ++_resource_index)
	{
		var _resource = resource_order[_resource_index];
		var _value = global.resources[_resource];
		var _icon_x = _sidebar_x + ((resource_sidebar_first_icon_offset_x + (resource_sidebar_item_gap * _resource_index)) * _sidebar_scale);
		var _icon_y = resource_sidebar_y * _sidebar_scale;
		var _icon_sprite = resource_icon_sprites[_resource];
		var _icon_size = resource_sidebar_icon_size * _sidebar_scale;
		var _text_x = _icon_x + (resource_sidebar_value_offset_x * _sidebar_scale);
		var _text_y = _icon_y;

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
		draw_text(_text_x, _text_y, string(_value));
	}

	// Draw day phase and shrine objective inside the right HUD sidebar.
	if (variable_global_exists("day_phase"))
	{
		var _current_day = 1;
		var _day_progress = 0;
		var _shrine_required = BALANCE_SHRINE_OBJECTIVE_REQUIRED;

		if (instance_exists(o_game_controller))
		{
			var _game_controller = instance_find(o_game_controller, 0);

			if (variable_instance_exists(_game_controller, "night_attack_night_index"))
			{
				_current_day = max(1, _game_controller.night_attack_night_index);
			}

			if (variable_instance_exists(_game_controller, "shrine_objective_required"))
			{
				_shrine_required = _game_controller.shrine_objective_required;
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
		var _objective_text_x = _sidebar_x + (_sidebar_width * 0.5);
		var _objective_text_y = day_phase_objective_y * _sidebar_scale;

		draw_set_halign(fa_center);
		draw_set_valign(fa_top);
		draw_set_alpha(1);
		draw_set_color(COLOR_HUD_TEXT);
		draw_text(_day_text_x, _day_text_y, "DAY " + string(_current_day));

		var _objective_label = "TAINT AT LEAST " + string(_shrine_required) + " SHRINE";

		if (_shrine_required != 1)
		{
			_objective_label = "TAINT AT LEAST " + string(_shrine_required) + " SHRINES";
		}

		draw_set_alpha(0.8);
		draw_set_color(c_black);
		draw_rectangle(_day_bar_x, _day_bar_y, _day_bar_x + _day_bar_width, _day_bar_y + _day_bar_height, false);

		draw_set_alpha(1);
		draw_set_color(COLOR_HUD_DAY_PROGRESS);
		draw_rectangle(_day_bar_x, _day_bar_y, _day_bar_x + (_day_bar_width * _day_progress), _day_bar_y + _day_bar_height, false);

		draw_set_color(COLOR_HUD_TEXT);
		draw_text(_objective_text_x, _objective_text_y, _objective_label);
	}

	// Draw compact cultist status cards while gameplay is unobstructed.
	if (variable_global_exists("cultists")
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
	var _cultist_card_count = array_length(global.cultists);
	var _cultist_card_slot_count = cultist_status_card_slot_count;

	for (var _cultist_card_index = 0; _cultist_card_index < _cultist_card_slot_count; ++_cultist_card_index)
	{
		var _cultist = noone;

		if (_cultist_card_index < _cultist_card_count)
		{
			_cultist = global.cultists[_cultist_card_index];
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

// Draw minimap in the lower part of the right HUD sidebar.
if (instance_exists(o_cannon))
{
	var _minimap_gui_width = display_get_gui_width();
	var _minimap_gui_height = display_get_gui_height();
	var _minimap_scale = clamp(_minimap_gui_height / 1080, 0.6, 1);
	var _minimap_sidebar_width = hud_sidebar_width * _minimap_scale;
	var _minimap_sidebar_x = _minimap_gui_width - _minimap_sidebar_width;
	var _minimap_size = minimap_size * _minimap_scale;
	var _minimap_x = _minimap_sidebar_x + ((_minimap_sidebar_width - _minimap_size) * 0.5);
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

	// Draw tainted ground cells under minimap units.
	if (instance_exists(o_corruption_grid))
	{
		var _corruption_grid_object = instance_find(o_corruption_grid, 0);
		var _corruption_cell_size = _corruption_grid_object.cell_size;
		var _corruption_left_cell = clamp(floor((_world_center_x - minimap_world_radius) / _corruption_cell_size), 0, _corruption_grid_object.grid_width - 1);
		var _corruption_right_cell = clamp(floor((_world_center_x + minimap_world_radius) / _corruption_cell_size), 0, _corruption_grid_object.grid_width - 1);
		var _corruption_top_cell = clamp(floor((_world_center_y - minimap_world_radius) / _corruption_cell_size), 0, _corruption_grid_object.grid_height - 1);
		var _corruption_bottom_cell = clamp(floor((_world_center_y + minimap_world_radius) / _corruption_cell_size), 0, _corruption_grid_object.grid_height - 1);

		draw_set_color(COLOR_HUD_MINIMAP_TAINT);

		for (var _corruption_cell_x = _corruption_left_cell; _corruption_cell_x <= _corruption_right_cell; ++_corruption_cell_x)
		{
			for (var _corruption_cell_y = _corruption_top_cell; _corruption_cell_y <= _corruption_bottom_cell; ++_corruption_cell_y)
			{
				var _corruption = ds_grid_get(_corruption_grid_object.corruption_grid, _corruption_cell_x, _corruption_cell_y);

				if (_corruption < _corruption_grid_object.minimum_draw_corruption)
				{
					continue;
				}

				var _taint_left = _minimap_center_x + (((_corruption_cell_x * _corruption_cell_size) - _world_center_x) * _world_to_minimap_scale);
				var _taint_top = _minimap_center_y + (((_corruption_cell_y * _corruption_cell_size) - _world_center_y) * _world_to_minimap_scale);
				var _taint_right = _minimap_center_x + (((_corruption_cell_x + 1) * _corruption_cell_size - _world_center_x) * _world_to_minimap_scale);
				var _taint_bottom = _minimap_center_y + (((_corruption_cell_y + 1) * _corruption_cell_size - _world_center_y) * _world_to_minimap_scale);

				_taint_left = clamp(_taint_left, _minimap_x, _minimap_right);
				_taint_top = clamp(_taint_top, _minimap_y, _minimap_bottom);
				_taint_right = clamp(_taint_right, _minimap_x, _minimap_right);
				_taint_bottom = clamp(_taint_bottom, _minimap_y, _minimap_bottom);

				draw_set_alpha(clamp(_corruption, 0.35, 1));
				draw_rectangle(_taint_left, _taint_top, _taint_right, _taint_bottom, false);
			}
		}

		draw_set_alpha(1);
	}

	// Draw objective shrines as fixed landmarks.
	var _shrine_count = instance_number(o_shrine);
	var _shrine_size = minimap_shrine_size * _minimap_scale;
	var _shrine_half_size = _shrine_size * 0.5;
	var _shrine_outline_size = minimap_shrine_outline_size * _minimap_scale;
	var _shrine_half_outline_size = _shrine_outline_size * 0.5;

	for (var _shrine_index = 0; _shrine_index < _shrine_count; ++_shrine_index)
	{
		var _shrine = instance_find(o_shrine, _shrine_index);

		if (!instance_exists(_shrine))
		{
			continue;
		}

		var _shrine_map_x = _minimap_center_x + ((_shrine.x - _world_center_x) * _world_to_minimap_scale);
		var _shrine_map_y = _minimap_center_y + ((_shrine.y - _world_center_y) * _world_to_minimap_scale);

		_shrine_map_x = clamp(_shrine_map_x, _minimap_x + _shrine_half_outline_size, _minimap_right - _shrine_half_outline_size);
		_shrine_map_y = clamp(_shrine_map_y, _minimap_y + _shrine_half_outline_size, _minimap_bottom - _shrine_half_outline_size);

		var _shrine_sprite = s_shrine_normal;
		var _shrine_color = c_white;

		if (variable_instance_exists(_shrine, "is_corrupted") && _shrine.is_corrupted)
		{
			_shrine_sprite = s_shrine_cursed;
			_shrine_color = COLOR_HUD_MINIMAP_TAINT;
		}

		draw_set_alpha(0.88);
		draw_set_color(c_black);
		draw_rectangle(
			_shrine_map_x - _shrine_half_outline_size,
			_shrine_map_y - _shrine_half_outline_size,
			_shrine_map_x + _shrine_half_outline_size,
			_shrine_map_y + _shrine_half_outline_size,
			false
		);

		draw_set_alpha(1);

		if (sprite_exists(_shrine_sprite))
		{
			draw_sprite_stretched_ext(
				_shrine_sprite,
				0,
				_shrine_map_x - _shrine_half_size,
				_shrine_map_y - _shrine_half_size,
				_shrine_size,
				_shrine_size,
				_shrine_color,
				1
			);
		}
		else
		{
			draw_set_color(_shrine_color);
			draw_line_width(_shrine_map_x, _shrine_map_y - _shrine_half_size, _shrine_map_x + _shrine_half_size, _shrine_map_y, 2);
			draw_line_width(_shrine_map_x + _shrine_half_size, _shrine_map_y, _shrine_map_x, _shrine_map_y + _shrine_half_size, 2);
			draw_line_width(_shrine_map_x, _shrine_map_y + _shrine_half_size, _shrine_map_x - _shrine_half_size, _shrine_map_y, 2);
			draw_line_width(_shrine_map_x - _shrine_half_size, _shrine_map_y, _shrine_map_x, _shrine_map_y - _shrine_half_size, 2);
		}
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
	if (variable_global_exists("cultists"))
	{
		var _minimap_cultist_count = array_length(global.cultists);
		var _cultist_width = minimap_cultist_width * _minimap_scale;
		var _cultist_height = minimap_cultist_height * _minimap_scale;
		var _cultist_half_width = _cultist_width * 0.5;
		var _cultist_half_height = _cultist_height * 0.5;
		var _cultist_bar_width = minimap_cultist_bar_width * _minimap_scale;
		var _cultist_bar_height = minimap_cultist_bar_height * _minimap_scale;
		var _cultist_bar_gap = minimap_cultist_bar_gap * _minimap_scale;

		for (var _minimap_cultist_index = 0; _minimap_cultist_index < _minimap_cultist_count; ++_minimap_cultist_index)
		{
			var _minimap_cultist = global.cultists[_minimap_cultist_index];

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

// Draw cannon satiety in the top-center HUD.
if (global.focus_window == FOCUS_WINDOW.NOONE
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
	var _satiety_bonus_count = 0;
	var _satiety_pending_bonus_type = noone;

	if (variable_global_exists("cannon_satiety_bonus_projectile_types"))
	{
		_satiety_bonus_count = array_length(global.cannon_satiety_bonus_projectile_types);
	}

	if (variable_global_exists("cannon_satiety_pending_bonus_projectile_type"))
	{
		_satiety_pending_bonus_type = global.cannon_satiety_pending_bonus_projectile_type;
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
		var _satiety_reward_projectile_type = noone;
		var _satiety_reward_alpha = 0.35;

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

		if (_satiety_bar_index < _satiety_bonus_count)
		{
			_satiety_reward_projectile_type = global.cannon_satiety_bonus_projectile_types[_satiety_bar_index];
			_satiety_reward_alpha = 1;
		}
		else if (_satiety_bar_index == _satiety_bonus_count)
		{
			_satiety_reward_projectile_type = _satiety_pending_bonus_type;
		}

		if (_satiety_reward_projectile_type != noone)
		{
			var _satiety_reward_start_x = _satiety_bar_label_x
				+ string_width(_satiety_bar_label)
				+ cannon_satiety_reward_icon_gap
				+ 18;
			var _satiety_reward_y = _satiety_current_bar_y + (cannon_satiety_bar_height * 0.5);
			var _taint_shell_icon_x = _satiety_reward_start_x
				+ string_width("+1")
				+ cannon_satiety_reward_label_gap
				+ cannon_satiety_reward_icon_radius;
			var _bonus_icon_x = _taint_shell_icon_x
				+ (cannon_satiety_reward_icon_radius * 2)
				+ cannon_satiety_reward_group_gap
				+ string_width("+1")
				+ cannon_satiety_reward_label_gap
				+ cannon_satiety_reward_icon_radius;
			var _satiety_reward_color = COLOR_PROJECTILE_DAMAGE;

			if (_satiety_reward_projectile_type == PROJECTILE_TYPE.CORRUPTION
				|| _satiety_reward_projectile_type == PROJECTILE_TYPE.FEAST)
			{
				_satiety_reward_color = COLOR_PROJECTILE_CORRUPTION;
			}
			else if (_satiety_reward_projectile_type == PROJECTILE_TYPE.SUMMON)
			{
				_satiety_reward_color = COLOR_PROJECTILE_SUMMON;
			}
			else if (_satiety_reward_projectile_type == PROJECTILE_TYPE.RALLY)
			{
				_satiety_reward_color = COLOR_PROJECTILE_RALLY;
			}
			else if (_satiety_reward_projectile_type == PROJECTILE_TYPE.CULTIST)
			{
				_satiety_reward_color = COLOR_PROJECTILE_CULTIST;
			}
			else if (_satiety_reward_projectile_type == PROJECTILE_TYPE.HEAL)
			{
				_satiety_reward_color = COLOR_PROJECTILE_HEAL;
			}
			else if (_satiety_reward_projectile_type == PROJECTILE_TYPE.BOMB)
			{
				_satiety_reward_color = COLOR_PROJECTILE_BOMB;
			}
			else if (_satiety_reward_projectile_type == PROJECTILE_TYPE.SKELETONS)
			{
				_satiety_reward_color = COLOR_PROJECTILE_SKELETONS;
			}

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

			var _bonus_label_x = _taint_shell_icon_x
				+ cannon_satiety_reward_icon_radius
				+ cannon_satiety_reward_group_gap;

			draw_set_color(COLOR_HUD_TEXT);
			draw_text(_bonus_label_x, _satiety_reward_y, "+1");

			draw_set_color(_satiety_reward_color);
			draw_circle(
				_bonus_icon_x,
				_satiety_reward_y,
				cannon_satiety_reward_icon_radius,
				false
			);
		}
	}

	draw_set_alpha(1);
}

// Draw defeat notice when the cannon wall has no HP left.
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

// Draw the cannon HP as a wide bottom HUD bar.
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
		var _fill_y = _gui_height - (_gui_height * cannon_hp_bottom_margin_share) - _fill_height;
		var _background_y = _fill_y + (_gui_height * cannon_hp_background_offset_share);
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

		if (variable_global_exists("ui_font") && font_exists(global.ui_font))
		{
			draw_set_font(global.ui_font);
		}
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
	var _feast_projectile_count = 0;

	if (variable_global_exists("cannon_satiety") && variable_global_exists("cannon_satiety_max"))
	{
		_feast_projectile_count = floor(max(0, global.cannon_satiety) / max(1, global.cannon_satiety_max));
	}

	var _projectile_display_count = min(_projectile_queue_count + _feast_projectile_count, 9);
	var _projectile_queue_display_count = min(_projectile_queue_count, _projectile_display_count);
	var _projectile_mouse_x = device_mouse_x_to_gui(0);
	var _projectile_mouse_y = device_mouse_y_to_gui(0);
	var _gui_width = display_get_gui_width();
	var _gui_height = display_get_gui_height();
	var _projectile_base_y = _gui_height - projectile_queue_margin_bottom - projectile_slot_height - projectile_name_offset_y;
	var _has_building_shell_projectile = false;

	for (var _building_shell_check_index = 0; _building_shell_check_index < _projectile_queue_display_count; ++_building_shell_check_index)
	{
		if (global.cannon_projectile_queue[_building_shell_check_index] == PROJECTILE_TYPE.BUILDING_SHELL)
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
	var _hovered_projectile_index = -1;
	var _projectile_payload_data = array_create(_projectile_display_count, noone);
	var _deploy_preview_units = array_create(0);
	var _deploy_preview_cursor = 0;
	var _remaining_cultist_projectile_count = 0;
	var _selected_projectile_index = 0;

	if (_projectile_display_count > 0 && variable_global_exists("cannon_selected_projectile_index"))
	{
		_selected_projectile_index = clamp(global.cannon_selected_projectile_index, 0, _projectile_display_count - 1);
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

			if (!instance_exists(_friendly_unit)
				|| !variable_instance_exists(_friendly_unit, "summon_nights_remaining")
				|| !variable_instance_exists(_friendly_unit, "cultist_projectile_deploy_assigned")
				|| _friendly_unit.cultist_projectile_deploy_assigned
				|| (_friendly_unit.object_index != o_skeleton && _friendly_unit.object_index != o_pitling))
			{
				continue;
			}

			array_push(_deploy_preview_units, _friendly_unit.object_index);
		}
	}

	for (var _preview_projectile_index = 0; _preview_projectile_index < _projectile_queue_display_count; ++_preview_projectile_index)
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

	for (var _projectile_index = 0; _projectile_index < _projectile_display_count; ++_projectile_index)
	{
		var _projectile_type = PROJECTILE_TYPE.FEAST;

		if (_projectile_index < _projectile_queue_count)
		{
			_projectile_type = global.cannon_projectile_queue[_projectile_index];
		}

		var _slot_x = _projectile_start_x + ((projectile_slot_width + projectile_slot_gap) * _projectile_index);
		var _slot_y = _projectile_base_y;
		var _slot_width = projectile_slot_width;
		var _slot_height = projectile_slot_background_height;
		var _is_current_projectile = _projectile_index == _selected_projectile_index;
		var _projectile_color = COLOR_PROJECTILE_DAMAGE;
		var _circle_radius = projectile_circle_radius;

		if (_projectile_type == PROJECTILE_TYPE.CORRUPTION)
		{
			_projectile_color = COLOR_PROJECTILE_CORRUPTION;
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
		}
		else if (_projectile_type == PROJECTILE_TYPE.FEAST)
		{
			_projectile_color = COLOR_PROJECTILE_CORRUPTION;
		}
		else if (_projectile_type == PROJECTILE_TYPE.HEAL)
		{
			_projectile_color = COLOR_PROJECTILE_HEAL;
		}
		else if (_projectile_type == PROJECTILE_TYPE.BOMB)
		{
			_projectile_color = COLOR_PROJECTILE_BOMB;
		}
		else if (_projectile_type == PROJECTILE_TYPE.SKELETONS)
		{
			_projectile_color = COLOR_PROJECTILE_SKELETONS;
		}
		else if (_projectile_type == PROJECTILE_TYPE.BUILDING_SHELL)
		{
			_projectile_color = COLOR_PROJECTILE_BUILDING_SHELL;
		}

		var _projectile_is_active = _combat_projectiles_are_active
			|| _projectile_type == PROJECTILE_TYPE.BUILDING_SHELL;
		var _projectile_draw_alpha = _projectile_is_active ? 1 : projectile_day_alpha;

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

		if (_projectile_mouse_x >= _slot_x && _projectile_mouse_x <= _slot_x + _slot_width
			&& _projectile_mouse_y >= _slot_y && _projectile_mouse_y <= _slot_y + _slot_height)
		{
			_hovered_projectile_index = _projectile_index;
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
		draw_set_color(_projectile_color);
		draw_circle(_slot_x + (_slot_width * 0.5), _slot_y + 22, _circle_radius, false);

		draw_set_color(COLOR_HUD_TEXT);
		var _projectile_name = projectile_names[_projectile_type];

		if (_projectile_type == PROJECTILE_TYPE.CULTIST
			&& variable_global_exists("cannon_projectile_payload_queue")
			&& _projectile_index < array_length(global.cannon_projectile_payload_queue))
		{
			var _cultist_payload = global.cannon_projectile_payload_queue[_projectile_index];

			if (instance_exists(_cultist_payload)
				&& variable_instance_exists(_cultist_payload, "cultist_name")
				&& _cultist_payload.cultist_name != "")
			{
				_projectile_name = string_copy(_cultist_payload.cultist_name, 1, 10);
			}
		}
		else if (_projectile_type == PROJECTILE_TYPE.BUILDING_SHELL
			&& variable_global_exists("cannon_projectile_payload_queue")
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

		if (_projectile_payload_data[_projectile_index] != noone)
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

		if (_projectile_is_active)
		{
			var _key_prompt_text = projectile_key_prompt_prefix + string(_projectile_index + 1);

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

	var _description_projectile_index = _hovered_projectile_index;

	if (_description_projectile_index < 0 && _projectile_display_count > 0)
	{
		_description_projectile_index = _selected_projectile_index;
	}

	if (_description_projectile_index >= 0)
	{
		var _description_type = PROJECTILE_TYPE.FEAST;
		var _description_payload = noone;
		var _draw_cultist_payload_card = false;

		if (_description_projectile_index < _projectile_queue_count)
		{
			_description_type = global.cannon_projectile_queue[_description_projectile_index];
		}

		var _description_projectile_is_active = _combat_projectiles_are_active
			|| _description_type == PROJECTILE_TYPE.BUILDING_SHELL;
		var _description_draw_alpha = _description_projectile_is_active ? 1 : projectile_day_alpha;

		if (_hovered_projectile_index >= 0
			&& _description_type == PROJECTILE_TYPE.CULTIST
			&& _combat_projectiles_are_active
			&& variable_global_exists("cannon_projectile_payload_queue")
			&& _description_projectile_index < array_length(global.cannon_projectile_payload_queue))
		{
			_description_payload = global.cannon_projectile_payload_queue[_description_projectile_index];
			_draw_cultist_payload_card = instance_exists(_description_payload)
				&& variable_instance_exists(_description_payload, "cultist_points");
		}

		var _description_x = (_gui_width - projectile_description_width) * 0.5;
		var _description_y = _projectile_base_y - projectile_description_height - projectile_description_gap;

		if (_draw_cultist_payload_card && instance_exists(o_game_controller))
		{
			var _card_width = min(300, _gui_width - 36);
			var _card_height = 570;
			var _card_margin = 18;
			var _card_x = min(_projectile_mouse_x + 18, _gui_width - _card_width - _card_margin);
			var _card_y = max(_card_margin, _projectile_base_y - _card_height - projectile_description_gap);
			var _game_controller = instance_find(o_game_controller, 0);

			if (variable_instance_exists(_game_controller, "cultist_stats_card_draw"))
			{
				_game_controller.cultist_stats_card_draw(_description_payload, _card_x, _card_y);
			}
		}
		else
		{
			draw_set_halign(fa_left);
			draw_set_valign(fa_top);
			draw_set_alpha(0.84 * _description_draw_alpha);
			draw_set_color(COLOR_HUD_BACKGROUND);
			draw_rectangle(
				_description_x,
				_description_y,
				_description_x + projectile_description_width,
				_description_y + projectile_description_height,
				false
			);

			draw_set_alpha(_description_draw_alpha);
			draw_set_color(COLOR_HUD_TEXT);
			var _description_name = projectile_names[_description_type];

			if (_description_type == PROJECTILE_TYPE.CULTIST
				&& variable_global_exists("cannon_projectile_payload_queue")
				&& _description_projectile_index < array_length(global.cannon_projectile_payload_queue))
			{
				_description_payload = global.cannon_projectile_payload_queue[_description_projectile_index];

				if (instance_exists(_description_payload)
					&& variable_instance_exists(_description_payload, "cultist_name")
					&& _description_payload.cultist_name != "")
				{
					_description_name = _description_payload.cultist_name;
				}
			}
			else if (_description_type == PROJECTILE_TYPE.BUILDING_SHELL
				&& variable_global_exists("cannon_projectile_payload_queue")
				&& _description_projectile_index < array_length(global.cannon_projectile_payload_queue))
			{
				_description_payload = global.cannon_projectile_payload_queue[_description_projectile_index];

				if (is_struct(_description_payload)
					&& variable_struct_exists(_description_payload, "building_name"))
				{
					_description_name = _description_payload.building_name;
				}
			}

			draw_text(_description_x + 10, _description_y + 8, _description_name);

			draw_set_color(COLOR_HUD_PROJECTILE_DESCRIPTION);
			draw_text_ext(
				_description_x + 10,
				_description_y + 28,
				projectile_descriptions[_description_type],
				projectile_description_line_separation,
				projectile_description_width - 20
			);
		}
	}
}

// Restore default draw state.
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);
