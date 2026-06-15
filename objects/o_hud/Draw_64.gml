// Draw global resources in the top-left HUD.
if (!variable_global_exists("resources"))
{
	exit;
}

draw_set_halign(fa_left);
draw_set_valign(fa_middle);

var _resource_count = array_length(resource_order);

for (var _resource_index = 0; _resource_index < _resource_count; ++_resource_index)
{
	var _resource = resource_order[_resource_index];
	var _draw_x = hud_margin_x + ((resource_item_width + resource_item_gap) * _resource_index);
	var _draw_y = hud_margin_y;
	var _value = global.resources[_resource];
	var _icon_x = _draw_x + resource_text_padding;
	var _icon_y = _draw_y + (resource_item_height * 0.5);
	var _icon_sprite = resource_icon_sprites[_resource];
	var _text_x = _icon_x + (resource_icon_size * 0.5) + resource_icon_text_gap;
	var _text_y = _icon_y;

	// Draw resource panel background.
	draw_set_alpha(0.72);
	draw_set_color(COLOR_HUD_BACKGROUND);
	draw_rectangle(_draw_x, _draw_y, _draw_x + resource_item_width, _draw_y + resource_item_height, false);

	// Draw resource icon, falling back to a color dot if the sprite is unavailable.
	draw_set_alpha(1);
	if (sprite_exists(_icon_sprite))
	{
		var _icon_left = _icon_x - (resource_icon_size * 0.5);
		var _icon_top = _icon_y - (resource_icon_size * 0.5);

		draw_sprite_stretched_ext(_icon_sprite, 0, _icon_left, _icon_top, resource_icon_size, resource_icon_size, c_white, 1);
	}
	else
	{
		draw_set_color(resource_colors[_resource]);
		draw_circle(_icon_x, _icon_y, resource_icon_radius, false);
	}

	draw_set_color(COLOR_HUD_TEXT);
	draw_text(_text_x, _text_y, string(_value));
}

// Draw derived ground corruption after regular resources.
var _corruption_index = _resource_count;
var _corruption_x = hud_margin_x + ((resource_item_width + resource_item_gap) * _corruption_index);
var _corruption_y = hud_margin_y;
var _corruption_value = string_format(corruption_display_value, 0, corruption_display_decimals);
var _corruption_label = corruption_display_name + ": " + _corruption_value;
var _corruption_icon_x = _corruption_x + resource_text_padding;
var _corruption_icon_y = _corruption_y + (resource_item_height * 0.5);
var _corruption_text_x = _corruption_x + (resource_text_padding * 1.8);
var _corruption_text_y = _corruption_icon_y;

draw_set_alpha(0.72);
draw_set_color(COLOR_HUD_BACKGROUND);
draw_rectangle(_corruption_x, _corruption_y, _corruption_x + resource_item_width, _corruption_y + resource_item_height, false);

draw_set_alpha(1);
draw_set_color(corruption_display_color);
draw_circle(_corruption_icon_x, _corruption_icon_y, resource_icon_radius, false);

draw_set_color(COLOR_HUD_TEXT);
draw_text(_corruption_text_x, _corruption_text_y, _corruption_label);

// Draw day phase in the top-right HUD.
if (variable_global_exists("day_phase"))
{
	var _gui_width = display_get_gui_width();
	var _phase_x = _gui_width - day_phase_margin_right - day_phase_item_width;
	var _phase_y = hud_margin_y;
	var _current_day = 1;
	var _day_progress = 0;
	var _shrine_corrupted_count = 0;
	var _shrine_required = BALANCE_SHRINE_OBJECTIVE_REQUIRED;
	var _shrine_total = BALANCE_SHRINE_OBJECTIVE_TOTAL;
	var _shrine_instances = noone;
	var _shrine_instance_count = 0;

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

		if (variable_instance_exists(_game_controller, "shrine_objective_total"))
		{
			_shrine_total = _game_controller.shrine_objective_total;
		}

		if (variable_instance_exists(_game_controller, "shrine_instances"))
		{
			_shrine_instances = _game_controller.shrine_instances;
			_shrine_instance_count = array_length(_shrine_instances);
		}

		if (variable_instance_exists(_game_controller, "shrine_corrupted_count_get"))
		{
			_shrine_corrupted_count = _game_controller.shrine_corrupted_count_get();
		}
	}

	if (variable_global_exists("day_cycle_enabled") && global.day_cycle_enabled)
	{
		if (global.day_phase == DAY_PHASE.DAY)
		{
			var _day_duration_frames = max(1, global.day_duration * room_speed);

			_day_progress = 1 - clamp(global.day_timer / _day_duration_frames, 0, 1);
		}
		else
		{
			_day_progress = 1;
		}
	}

	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_alpha(0.72);
	draw_set_color(COLOR_HUD_BACKGROUND);
	draw_rectangle(_phase_x, _phase_y, _phase_x + day_phase_item_width, _phase_y + day_phase_item_height, false);

	draw_set_alpha(1);
	draw_set_color(COLOR_HUD_TEXT);
	draw_text(_phase_x + day_phase_text_padding, _phase_y + 10, "DAY " + string(_current_day));

	var _shrine_goal_progress = min(_shrine_corrupted_count, _shrine_required);

	draw_text(
		_phase_x + day_phase_text_padding,
		_phase_y + 32,
		"INFECT " + string(_shrine_goal_progress) + "/" + string(_shrine_required) + " SHRINES"
	);

	var _shrine_normal_sprite = s_shrine_normal;
	var _shrine_cursed_sprite = s_shrine_cursed;
	var _shrine_icon_start_x = _phase_x + day_phase_text_padding;
	var _shrine_icon_y = _phase_y + shrine_icon_y_offset;

	for (var _shrine_icon_index = 0; _shrine_icon_index < _shrine_total; ++_shrine_icon_index)
	{
		var _shrine_icon_x = _shrine_icon_start_x + ((shrine_icon_size + shrine_icon_gap) * _shrine_icon_index);
		var _shrine_icon_sprite = _shrine_normal_sprite;
		var _shrine_is_corrupted = _shrine_icon_index < _shrine_corrupted_count;

		if (_shrine_icon_index < _shrine_instance_count)
		{
			var _shrine_instance = _shrine_instances[_shrine_icon_index];

			_shrine_is_corrupted = instance_exists(_shrine_instance)
				&& variable_instance_exists(_shrine_instance, "is_corrupted")
				&& _shrine_instance.is_corrupted;
		}

		if (_shrine_is_corrupted)
		{
			_shrine_icon_sprite = _shrine_cursed_sprite;
		}

		draw_set_alpha(0.35);
		draw_set_color(c_black);
		draw_rectangle(
			_shrine_icon_x - 2,
			_shrine_icon_y - 2,
			_shrine_icon_x + shrine_icon_size + 2,
			_shrine_icon_y + shrine_icon_size + 2,
			false
		);

		draw_set_alpha(1);
		draw_sprite_stretched_ext(
			_shrine_icon_sprite,
			0,
			_shrine_icon_x,
			_shrine_icon_y,
			shrine_icon_size,
			shrine_icon_size,
			c_white,
			1
		);
	}

	var _bar_x = _phase_x + day_phase_bar_margin_x;
	var _bar_y = _phase_y + day_phase_item_height - day_phase_bar_margin_bottom - day_phase_bar_height;
	var _bar_width = day_phase_item_width - (day_phase_bar_margin_x * 2);

	draw_set_alpha(0.55);
	draw_set_color(c_black);
	draw_rectangle(_bar_x, _bar_y, _bar_x + _bar_width, _bar_y + day_phase_bar_height, false);

	draw_set_alpha(1);
	draw_set_color(COLOR_HUD_DAY_PROGRESS);
	draw_rectangle(_bar_x, _bar_y, _bar_x + (_bar_width * _day_progress), _bar_y + day_phase_bar_height, false);
	draw_set_color(COLOR_HUD_TEXT);
	draw_rectangle(_bar_x, _bar_y, _bar_x + _bar_width, _bar_y + day_phase_bar_height, true);
}

// Draw direct Imp passive damage on the right side for balance testing.
var _imp_count = instance_number(o_imp);

if (_imp_count > 0)
{
	var _gui_width = display_get_gui_width();
	var _meter_x = _gui_width - imp_damage_meter_margin_right - imp_damage_meter_width;
	var _meter_y = imp_damage_meter_y;
	var _tracked_abilities = [
		DEMON_ABILITY.IMP_FRENZY_ECHO,
		DEMON_ABILITY.IMP_BLOOD_BLADES,
		DEMON_ABILITY.IMP_BLOOD_HUNGER
	];
	var _panel_height = imp_damage_meter_padding * 2
		+ imp_damage_meter_title_height
		+ (_imp_count * ((array_length(_tracked_abilities) + 1) * imp_damage_meter_line_height + imp_damage_meter_imp_gap));

	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_alpha(0.78);
	draw_set_color(COLOR_HUD_BACKGROUND);
	draw_rectangle(_meter_x, _meter_y, _meter_x + imp_damage_meter_width, _meter_y + _panel_height, false);

	draw_set_alpha(1);
	draw_set_color(COLOR_HUD_TEXT);
	draw_text(_meter_x + imp_damage_meter_padding, _meter_y + imp_damage_meter_padding, "IMP PASSIVE DPS");

	var _line_y = _meter_y + imp_damage_meter_padding + imp_damage_meter_title_height;

	for (var _imp_index = 0; _imp_index < _imp_count; ++_imp_index)
	{
		var _imp = instance_find(o_imp, _imp_index);

		if (!instance_exists(_imp))
		{
			continue;
		}

		var _imp_name = "Imp";

		if (variable_instance_exists(_imp, "cultist_name") && _imp.cultist_name != "")
		{
			_imp_name = _imp.cultist_name;
		}

		draw_set_color(COLOR_CULTIST_FERVOR);
		draw_text(_meter_x + imp_damage_meter_padding, _line_y, _imp_name);
		_line_y += imp_damage_meter_line_height;

		var _has_any_meter_line = false;

		for (var _ability_index = 0; _ability_index < array_length(_tracked_abilities); ++_ability_index)
		{
			var _ability = _tracked_abilities[_ability_index];
			var _ability_level = 0;
			var _total_damage = 0;
			var _recent_dps = 0;

			if (variable_instance_exists(_imp, "imp_ability_level_get"))
			{
				_ability_level = _imp.imp_ability_level_get(_ability);
			}

			if (variable_instance_exists(_imp, "imp_ability_damage_totals"))
			{
				_total_damage = _imp.imp_ability_damage_totals[_ability];
			}

			if (variable_instance_exists(_imp, "imp_ability_damage_dps_get"))
			{
				_recent_dps = _imp.imp_ability_damage_dps_get(_ability);
			}

			if (_ability_level <= 0 && _total_damage <= 0)
			{
				continue;
			}

			var _ability_text = string_copy(cultist_ability_name_get(_ability), 1, 14)
				+ " L" + string(_ability_level)
				+ " DPS " + string_format(_recent_dps, 0, 1)
				+ " DMG " + string_format(_total_damage, 0, 0);

			draw_set_color(COLOR_HUD_PROJECTILE_DESCRIPTION);
			draw_text(_meter_x + imp_damage_meter_padding, _line_y, _ability_text);
			_line_y += imp_damage_meter_line_height;
			_has_any_meter_line = true;
		}

		if (!_has_any_meter_line)
		{
			draw_set_color(COLOR_HUD_PROJECTILE_DESCRIPTION);
			draw_text(_meter_x + imp_damage_meter_padding, _line_y, imp_damage_meter_empty_text);
			_line_y += imp_damage_meter_line_height;
		}

		_line_y += imp_damage_meter_imp_gap;
	}
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
	draw_text(_notice_x + (objective_complete_notice_width * 0.5), _notice_y + objective_complete_notice_padding, objective_complete_title);

	draw_set_color(COLOR_HUD_TEXT);
	draw_text(
		_notice_x + (objective_complete_notice_width * 0.5),
		_notice_y + objective_complete_notice_padding + 28,
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
	var _satiety_bar_count = max(1, ceil(_satiety_value / _satiety_max));
	var _satiety_stack_height = cannon_satiety_height + ((_satiety_bar_count - 1) * (cannon_satiety_bar_height + cannon_satiety_bar_gap));
	var _satiety_text_x = _satiety_x + cannon_satiety_padding_x;
	var _satiety_text_y = _satiety_y + (cannon_satiety_height * 0.5);
	var _satiety_bar_x = _satiety_x + cannon_satiety_width - cannon_satiety_padding_x - cannon_satiety_bar_width;
	var _satiety_bar_y = _satiety_y + ((cannon_satiety_height - cannon_satiety_bar_height) * 0.5);

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
	}
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
		draw_text(_notice_x + (wall_fallen_notice_width * 0.5), _notice_y + wall_fallen_notice_padding, wall_fallen_title);

		draw_set_color(COLOR_HUD_TEXT);
		draw_text(
			_notice_x + (wall_fallen_notice_width * 0.5),
			_notice_y + wall_fallen_notice_padding + 32,
			wall_fallen_description
		);
	}
}

// Draw queued cannon projectiles at the bottom center of the HUD during night.
if (variable_global_exists("cannon_projectile_queue")
	&& variable_global_exists("day_phase")
	&& global.day_phase == DAY_PHASE.NIGHT)
{
	var _projectile_queue_count = array_length(global.cannon_projectile_queue);
	var _feast_projectile_count = 0;

	if (variable_global_exists("cannon_satiety") && variable_global_exists("cannon_satiety_max"))
	{
		_feast_projectile_count = floor(max(0, global.cannon_satiety) / max(1, global.cannon_satiety_max));
	}

	var _projectile_display_count = _projectile_queue_count + _feast_projectile_count;
	var _projectile_mouse_x = device_mouse_x_to_gui(0);
	var _projectile_mouse_y = device_mouse_y_to_gui(0);
	var _gui_width = display_get_gui_width();
	var _gui_height = display_get_gui_height();
	var _projectile_base_y = _gui_height - projectile_queue_margin_bottom - projectile_slot_height - projectile_name_offset_y;
	var _projectile_total_width = (projectile_slot_width * _projectile_display_count)
		+ (projectile_slot_gap * max(0, _projectile_display_count - 1));
	var _projectile_start_x = (_gui_width - _projectile_total_width) * 0.5;
	var _hovered_projectile_index = -1;
	var _projectile_payload_data = array_create(_projectile_display_count, noone);
	var _deploy_preview_units = array_create(0);
	var _deploy_preview_cursor = 0;
	var _remaining_cultist_projectile_count = 0;

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
		var _is_current_projectile = _projectile_index == 0;
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

		draw_set_alpha(0.76);
		draw_set_color(COLOR_HUD_BACKGROUND);
		draw_rectangle(_slot_x, _slot_y, _slot_x + _slot_width, _slot_y + _slot_height, false);

		if (_is_current_projectile)
		{
			draw_set_alpha(1);
			draw_set_color(COLOR_HUD_PROJECTILE_SELECTED);
			draw_rectangle(_slot_x, _slot_y, _slot_x + _slot_width, _slot_y + _slot_height, true);
		}

		draw_set_alpha(1);
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
					1
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
						1
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
						1
					);
				}
			}

			draw_set_halign(fa_center);
			draw_set_valign(fa_middle);
		}

		if (_is_current_projectile)
		{
			draw_set_color(COLOR_HUD_PROJECTILE_DESCRIPTION);
			draw_text(
				_slot_x + (_slot_width * 0.5),
				_slot_y + _slot_height + projectile_aim_prompt_gap,
				projectile_aim_prompt_text
			);
		}
	}

	var _description_projectile_index = _hovered_projectile_index;

	if (_description_projectile_index < 0 && _projectile_display_count > 0)
	{
		_description_projectile_index = 0;
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

		if (_hovered_projectile_index >= 0
			&& _description_type == PROJECTILE_TYPE.CULTIST
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
			draw_set_alpha(0.84);
			draw_set_color(COLOR_HUD_BACKGROUND);
			draw_rectangle(
				_description_x,
				_description_y,
				_description_x + projectile_description_width,
				_description_y + projectile_description_height,
				false
			);

			draw_set_alpha(1);
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
