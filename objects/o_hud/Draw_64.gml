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

// Hide regular HUD while modal windows are visible, but keep projectile choices during aiming.
var _tutorial_popup_blocks_hud = variable_global_exists("tutorial_popup_active") && global.tutorial_popup_active;
var _projectile_queue_stays_visible = global.focus_window == FOCUS_WINDOW.TARGET_SELECTION
	&& !_tutorial_popup_blocks_hud;
var _regular_hud_is_visible = (global.focus_window == FOCUS_WINDOW.NOONE || global.focus_window == FOCUS_WINDOW.SUMMON)
	&& !_tutorial_popup_blocks_hud;

if (!_regular_hud_is_visible && !_projectile_queue_stays_visible)
{
	exit;
}

if (_regular_hud_is_visible)
{
	faction_mana_draw();
	var _sidebar_gui_width = display_get_gui_width();
	var _sidebar_gui_height = display_get_gui_height();
	var _sidebar_scale = clamp(_sidebar_gui_height / 1080, 0.6, 1);
	var _sidebar_width = hud_sidebar_width * _sidebar_scale;
	var _sidebar_x = _sidebar_gui_width - _sidebar_width;

	// Draw squad cards, shared empty slots, and the next locked slot.
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
			if (_squad_type == SQUAD_TYPE.HERO) _type_name = "HERO";
			if (_squad_type == SQUAD_TYPE.ARMY) _type_name = "SQUAD";

			for (var _squad_index = 0; _squad_index < array_length(global.squads); ++_squad_index)
			{
				var _squad = global.squads[_squad_index];
				if (!squad_is_player_owned(_squad) || _squad.squad_type != _squad_type) continue;
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
				draw_text_transformed(_card_center_x, _squad_card_y + (109 * _sidebar_scale), (_squad.is_hero && _squad.hero_respawn_remaining > 0
					? "Respawn: " + string(ceil(_squad.hero_respawn_remaining)) + "s"
					: squad_name_display_get(_squad.name)), 0.75 * _sidebar_scale, 0.75 * _sidebar_scale, 0);
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
		draw_set_color(c_white);
		draw_set_alpha(1);
	}

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

			draw_set_color(corruption_color_get(minimap_ground_factions[_ground_cell_index]));
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
			|| (variable_instance_exists(_enemy, "hp") && _enemy.hp <= 0)
			|| (variable_instance_exists(_enemy, "cached_is_hidden_by_fog")
				&& _enemy.cached_is_hidden_by_fog))
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
	faction_mana_draw();
	var _control_hint_gui_height = display_get_gui_height();
	var _control_hint_scale = clamp(_control_hint_gui_height / 1080, 0.6, 1);
	var _base_control_hint_count = array_length(control_hint_keys);
	var _show_night_speed_hint = false;
	var _night_speed_action = control_hint_speed_up_action;

	if (_show_night_speed_hint)
	{
		var _speed_hint_controller = instance_find(o_game_controller, 0);
		if (_speed_hint_controller.night_fast_forward_active)
		{
			_night_speed_action = control_hint_slow_down_action;
		}
	}

	var _control_hint_count = _base_control_hint_count + (_show_night_speed_hint ? 1 : 0);
	var _control_hint_x = control_hints_x * _control_hint_scale;
	var _control_hint_row_height = control_hints_row_height * _control_hint_scale;
	var _control_hint_row_gap = control_hints_row_gap * _control_hint_scale;
	var _control_hint_key_height = control_hints_key_height * _control_hint_scale;
	var _control_hint_key_padding_x = control_hints_key_padding_x * _control_hint_scale;
	var _control_hint_key_text_gap = control_hints_key_text_gap * _control_hint_scale;
	var _control_hint_padding_x = control_hints_padding_x * _control_hint_scale;
	var _control_hint_padding_y = control_hints_padding_y * _control_hint_scale;
	var _control_hint_action_width = control_hints_action_min_width * _control_hint_scale;
	var _control_hint_key_width = control_hints_key_min_width * _control_hint_scale;

	for (var _control_hint_measure_index = 0; _control_hint_measure_index < _control_hint_count; ++_control_hint_measure_index)
	{
		var _measure_key = _control_hint_measure_index < _base_control_hint_count
			? control_hint_keys[_control_hint_measure_index] : control_hint_night_speed_key;
		var _measure_action = _control_hint_measure_index < _base_control_hint_count
			? control_hint_actions[_control_hint_measure_index] : _night_speed_action;
		_control_hint_key_width = max(
			_control_hint_key_width,
			string_width(_measure_key) + (_control_hint_key_padding_x * 2)
		);
		_control_hint_action_width = max(_control_hint_action_width, string_width(_measure_action));
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
		var _control_hint_key = _control_hint_index < _base_control_hint_count
			? control_hint_keys[_control_hint_index] : control_hint_night_speed_key;
		var _control_hint_action = _control_hint_index < _base_control_hint_count
			? control_hint_actions[_control_hint_index] : _night_speed_action;
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
			_control_hint_key
		);

		draw_set_color(COLOR_HUD_PROJECTILE_DESCRIPTION);
		draw_text(
			_control_hint_key_x + _control_hint_key_width + _control_hint_key_text_gap,
			_control_hint_row_y + (_control_hint_row_height * 0.5),
			_control_hint_action
		);
	}

	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
	draw_set_alpha(1);
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


// Restore default draw state.
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);
