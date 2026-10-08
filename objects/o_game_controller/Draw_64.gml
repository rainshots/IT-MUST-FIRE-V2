if (faction_selection_active || faction_selection_release_pending)
{
	exit;
}

if (font_exists(global.ui_font)) draw_set_font(global.ui_font);
// Cheat overlay shows only navigation cells intersecting the current camera.
wall_navigation_debug_draw();
faction_favor_draw();

// Draw night squad markers above world units but below the rest of the GUI.
squad_orders_draw_gui();
squad_night_markers_draw_gui();

if (squad_flag_system_2_enabled && is_struct(selected_squad) && squad_attack_move_armed
	&& global.player_faction != FACTION.NONE && global.focus_window == FOCUS_WINDOW.NOONE)
{
	var _order_hint_offset = 18;
	var _order_hint_scale = 0.7;
	draw_set_color(COLOR_SQUAD_ORDER_MOVE);
	draw_set_alpha(1);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_text_transformed(device_mouse_x_to_gui(0) + _order_hint_offset,
		device_mouse_y_to_gui(0) + _order_hint_offset, "Move And Attack", _order_hint_scale, _order_hint_scale, 0);
	draw_set_color(c_white);
}

// Draw cultist stat hover in regular gameplay.
if (global.focus_window == FOCUS_WINDOW.NOONE
	&& variable_global_exists("archdemons")
	&& instance_exists(o_camera_controller)
	&& (!variable_global_exists("tutorial_popup_active") || !global.tutorial_popup_active))
{
	var _levelup_cultist_count = array_length(global.archdemons);

	for (var _levelup_cultist_index = 0; _levelup_cultist_index < _levelup_cultist_count; ++_levelup_cultist_index)
	{
		var _levelup_cultist = global.archdemons[_levelup_cultist_index];

		if (!cultist_has_pending_levelup(_levelup_cultist)
			|| (variable_instance_exists(_levelup_cultist, "hp") && _levelup_cultist.hp <= 0)
			|| (variable_instance_exists(_levelup_cultist, "cannon_loading") && _levelup_cultist.cannon_loading)
			|| (variable_instance_exists(_levelup_cultist, "cannon_loaded") && _levelup_cultist.cannon_loaded))
		{
			continue;
		}

		var _button_rect = cultist_levelup_button_rect_get(_levelup_cultist);
		var _button_x = _button_rect[0];
		var _button_y = _button_rect[1];
		var _button_width = _button_rect[2];
		var _button_height = _button_rect[3];
		var _mouse_x = device_mouse_x_to_gui(0);
		var _mouse_y = device_mouse_y_to_gui(0);
		var _is_hovered = _mouse_x >= _button_x
			&& _mouse_x <= _button_x + _button_width
			&& _mouse_y >= _button_y
			&& _mouse_y <= _button_y + _button_height;

		draw_set_alpha(0.94);
		draw_set_color(_is_hovered ? COLOR_HUD_LEVEL_UP_HOVER : COLOR_HUD_LEVEL_UP);
		draw_rectangle(_button_x, _button_y, _button_x + _button_width, _button_y + _button_height, false);

		draw_set_alpha(1);
		draw_set_color(c_black);
		draw_rectangle(_button_x, _button_y, _button_x + _button_width, _button_y + _button_height, true);

		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		draw_set_color(c_black);
		draw_text(_button_x + (_button_width * 0.5), _button_y + (_button_height * 0.5), "LEVEL UP");
	}

	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
	draw_set_alpha(1);
}



// Draw lightweight gameplay pause indicator without blocking hover info.
if (player_pause_active
	&& (global.focus_window == FOCUS_WINDOW.NOONE
		|| global.focus_window == FOCUS_WINDOW.TARGET_SELECTION))
{
	var _pause_margin = 10;
	var _pause_label_width = 144;
	var _pause_label_height = 34;
	var _pause_label_x = (camera_view_width - _pause_label_width) * 0.5;
	var _pause_label_y = 24;

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

// Draw pickup hand over the cursor when a draggable unit can be grabbed or is being dragged.
if (global.focus_window == FOCUS_WINDOW.NOONE
	&& variable_global_exists("archdemons")
	&& (!variable_global_exists("tutorial_popup_active") || !global.tutorial_popup_active))
{
	var _artifact_is_dragged = variable_global_exists("dragged_artifact") && instance_exists(global.dragged_artifact);
	var _squad_is_dragged = variable_global_exists("dragged_squad") && is_struct(global.dragged_squad);
	var _should_draw_pickup_hand = instance_exists(global.dragged_cultist) || _artifact_is_dragged || _squad_is_dragged;
	var _should_draw_whip_prompt = false;
	var _hovered_artifact = noone;

	if (!_should_draw_pickup_hand
		&& instance_exists(o_camera_controller))
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
		var _whip_target = find_worker_whip_target_at_position(_mouse_world_x, _mouse_world_y);
		var _cultist_count = array_length(global.archdemons);

		_should_draw_whip_prompt = instance_exists(_whip_target);

		if (global.player_faction != FACTION.NONE
			&& is_struct(squad_marker_find_at_position(_mouse_world_x, _mouse_world_y)))
		{
			_should_draw_pickup_hand = true;
		}

		if (instance_exists(o_artifact))
		{
			var _artifact_count = instance_number(o_artifact);

			for (var _artifact_index = 0; _artifact_index < _artifact_count; ++_artifact_index)
			{
				var _artifact = instance_find(o_artifact, _artifact_index);

				if (!instance_exists(_artifact))
				{
					continue;
				}

				var _artifact_pickup_radius = 0;

				if (variable_instance_exists(_artifact, "artifact_pickup_radius"))
				{
					_artifact_pickup_radius = _artifact.artifact_pickup_radius;
				}

				var _artifact_is_hovered = (_mouse_world_x >= _artifact.bbox_left
						&& _mouse_world_x <= _artifact.bbox_right
						&& _mouse_world_y >= _artifact.bbox_top
						&& _mouse_world_y <= _artifact.bbox_bottom)
					|| point_distance(_mouse_world_x, _mouse_world_y, _artifact.x, _artifact.y) <= _artifact_pickup_radius;

				if (_artifact_is_hovered)
				{
					_should_draw_pickup_hand = true;
					_hovered_artifact = _artifact;
					break;
				}
			}
		}

		for (var _cultist_index = 0; _cultist_index < _cultist_count; ++_cultist_index)
		{
			var _cultist = global.archdemons[_cultist_index];

			if (drag_cultist_can_be_picked(_cultist)
				&& _mouse_world_x >= _cultist.bbox_left
				&& _mouse_world_x <= _cultist.bbox_right
				&& _mouse_world_y >= _cultist.bbox_top
				&& _mouse_world_y <= _cultist.bbox_bottom)
			{
				_should_draw_pickup_hand = true;
				break;
			}
		}

		// Regular daytime cultists use the same pickup hand as every other draggable worker.
		if (!_should_draw_pickup_hand
			&& global.day_phase == DAY_PHASE.DAY
			&& variable_global_exists("event_cultists")
			&& is_array(global.event_cultists))
		{
			var _event_cultist_count = array_length(global.event_cultists);

			for (var _event_cultist_index = 0; _event_cultist_index < _event_cultist_count; ++_event_cultist_index)
			{
				var _event_cultist = global.event_cultists[_event_cultist_index];

				if (drag_cultist_can_be_picked(_event_cultist)
					&& _mouse_world_x >= _event_cultist.bbox_left
					&& _mouse_world_x <= _event_cultist.bbox_right
					&& _mouse_world_y >= _event_cultist.bbox_top
					&& _mouse_world_y <= _event_cultist.bbox_bottom)
				{
					_should_draw_pickup_hand = true;
					break;
				}
			}
		}

		if (!_should_draw_pickup_hand)
		{
			var _worker_unit_objects = [o_goblin];

			for (var _worker_object_index = 0; _worker_object_index < array_length(_worker_unit_objects); ++_worker_object_index)
			{
				var _worker_object = _worker_unit_objects[_worker_object_index];
				var _worker_unit_count = instance_number(_worker_object);

				for (var _worker_unit_index = 0; _worker_unit_index < _worker_unit_count; ++_worker_unit_index)
				{
					var _worker_unit = instance_find(_worker_object, _worker_unit_index);

					if (instance_exists(_worker_unit)
						&& _mouse_world_x >= _worker_unit.bbox_left
						&& _mouse_world_x <= _worker_unit.bbox_right
						&& _mouse_world_y >= _worker_unit.bbox_top
						&& _mouse_world_y <= _worker_unit.bbox_bottom)
					{
						_should_draw_pickup_hand = true;
						break;
					}
				}

				if (_should_draw_pickup_hand)
				{
					break;
				}
			}
		}
	}

	if (instance_exists(_hovered_artifact) && !_artifact_is_dragged)
	{
		var _artifact_tooltip_width = 270;
		var _artifact_tooltip_height = 104;
		var _artifact_tooltip_padding = 14;
		var _artifact_tooltip_line_height = 22;
		var _artifact_tooltip_x = _artifact_tooltip_padding;
		var _artifact_tooltip_y = 84;
		var _artifact_stat = _hovered_artifact.artifact_stat;
		var _artifact_stat_color = COLOR_CULTIST_FERVOR;
		var _artifact_stat_name = "Fervor";
		var _artifact_apply_text = "Drag onto a cultist to apply.";

		if (_artifact_stat == CULTIST_STAT.BODY)
		{
			_artifact_stat_color = COLOR_CULTIST_BODY;
			_artifact_stat_name = "Body";
		}
		else if (_artifact_stat == CULTIST_STAT.SPIRIT)
		{
			_artifact_stat_color = COLOR_CULTIST_SPIRIT;
			_artifact_stat_name = "Spirit";
		}

		var _artifact_bonus_text = "Grants +1 " + _artifact_stat_name;

		draw_set_alpha(0.9);
		draw_set_color(COLOR_HUD_BACKGROUND);
		draw_rectangle(
			_artifact_tooltip_x,
			_artifact_tooltip_y,
			_artifact_tooltip_x + _artifact_tooltip_width,
			_artifact_tooltip_y + _artifact_tooltip_height,
			false
		);

		draw_set_alpha(1);
		draw_set_color(_artifact_stat_color);
		draw_rectangle(
			_artifact_tooltip_x,
			_artifact_tooltip_y,
			_artifact_tooltip_x + _artifact_tooltip_width,
			_artifact_tooltip_y + _artifact_tooltip_height,
			true
		);

		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		draw_set_color(COLOR_HUD_TEXT);
		draw_text(_artifact_tooltip_x + _artifact_tooltip_padding, _artifact_tooltip_y + _artifact_tooltip_padding, "Artifact");

		draw_set_color(_artifact_stat_color);
		draw_text(
			_artifact_tooltip_x + _artifact_tooltip_padding,
			_artifact_tooltip_y + _artifact_tooltip_padding + _artifact_tooltip_line_height,
			_artifact_bonus_text
		);

		draw_set_color(COLOR_HUD_TEXT);
		draw_text(
			_artifact_tooltip_x + _artifact_tooltip_padding,
			_artifact_tooltip_y + _artifact_tooltip_padding + (_artifact_tooltip_line_height * 2),
			_artifact_apply_text
		);
	}

	if (_should_draw_pickup_hand)
	{
		var _hand_x = device_mouse_x_to_gui(0);
		var _hand_y = device_mouse_y_to_gui(0);
		var _hand_scale = 0.33;

		if ((instance_exists(global.dragged_cultist) || _artifact_is_dragged || _squad_is_dragged)
			&& instance_exists(o_camera_controller))
		{
			var _drag_hand_camera = instance_find(o_camera_controller, 0);
			var _drag_hand_camera_x = camera_get_view_x(_drag_hand_camera.camera_id);
			var _drag_hand_camera_y = camera_get_view_y(_drag_hand_camera.camera_id);
			var _drag_hand_camera_width = camera_get_view_width(_drag_hand_camera.camera_id);
			var _drag_hand_camera_height = camera_get_view_height(_drag_hand_camera.camera_id);
			var _hand_world_x = 0;
			var _hand_world_y = 0;

			if (_squad_is_dragged)
			{
				_hand_world_x = global.dragged_squad.properties.marker_x;
				_hand_world_y = global.dragged_squad.properties.marker_y
					- (BALANCE_SQUAD_MARKER_DRAG_TARGET_OFFSET_Y
						* (_drag_hand_camera_height / max(1, camera_view_height)));
			}
			else
			{
				var _dragged_instance = _artifact_is_dragged ? global.dragged_artifact : global.dragged_cultist;
				_hand_world_x = _dragged_instance.x;
				_hand_world_y = _dragged_instance.bbox_bottom - pickup_hand_drag_offset_y;
			}

			_hand_x = ((_hand_world_x - _drag_hand_camera_x) / _drag_hand_camera_width) * camera_view_width;
			_hand_y = ((_hand_world_y - _drag_hand_camera_y) / _drag_hand_camera_height) * camera_view_height;
		}

		draw_set_alpha(1);
		draw_set_color(c_white);
		draw_sprite_ext(s_hand, 0, _hand_x, _hand_y, _hand_scale, _hand_scale, 0, c_white, 1);

		if (variable_global_exists("ui_font") && font_exists(global.ui_font))
		{
			draw_set_font(global.ui_font);
		}

		draw_set_halign(fa_center);
		draw_set_valign(fa_top);
		draw_set_color(COLOR_HUD_TEXT);

		if (!instance_exists(global.dragged_cultist) && !_artifact_is_dragged && !_squad_is_dragged)
		{
			draw_text(_hand_x, _hand_y + 28, "PRESS LMB");
		}

		if (_should_draw_whip_prompt && sprite_exists(s_whip))
		{
			var _whip_scale = 1;
			var _whip_gap = 134;
			var _whip_x = _hand_x + _whip_gap;
			var _whip_y = _hand_y;
			var _whip_text = "PRESS RMB";
			var _whip_text_y = _whip_y + 28;

			draw_sprite_ext(s_whip, 0, _whip_x, _whip_y, _whip_scale, _whip_scale, 0, c_white, 1);

			draw_set_color(COLOR_HUD_TEXT);
			draw_text(_whip_x, _whip_text_y, _whip_text);
		}

		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		draw_set_color(c_white);
		draw_set_alpha(1);
	}
}

// Draw demon health bars above world objects so the player can find them in combat.
if (variable_global_exists("archdemons") && instance_exists(o_camera_controller))
{
	var _camera_controller = instance_find(o_camera_controller, 0);
	var _camera_x = camera_get_view_x(_camera_controller.camera_id);
	var _camera_y = camera_get_view_y(_camera_controller.camera_id);
	var _camera_width = camera_get_view_width(_camera_controller.camera_id);
	var _camera_height = camera_get_view_height(_camera_controller.camera_id);
	var _cultist_count = array_length(global.archdemons);
	var _demon_bar_width = 62;
	var _demon_bar_height = 8;
	var _demon_bar_offset_y = 12;
	var _cooldown_bar_height = 4;
	var _cooldown_bar_gap = 2;
	var _cooldown_bar_top_gap = 2;

	for (var _cultist_index = 0; _cultist_index < _cultist_count; ++_cultist_index)
	{
		var _cultist = global.archdemons[_cultist_index];

		if (!instance_exists(_cultist)
			|| _cultist.object_index == o_archdemon
			|| !variable_instance_exists(_cultist, "demon_type")
			|| _cultist.demon_type == DEMON_TYPE.NONE
			|| !variable_instance_exists(_cultist, "hp")
			|| !variable_instance_exists(_cultist, "max_hp")
			|| _cultist.max_hp <= 0
			|| _cultist.hp <= 0)
		{
			continue;
		}

		var _demon_gui_x = ((_cultist.x - _camera_x) / _camera_width) * camera_view_width;
		var _demon_gui_y = ((_cultist.y - _demon_bar_offset_y - _camera_y) / _camera_height) * camera_view_height;
		var _health_bar_width = health_bar_width_get(_demon_bar_width, _cultist.max_hp);
		var _bar_x = _demon_gui_x - (_health_bar_width * 0.5);
		var _bar_y = _demon_gui_y;
		var _hp_progress = clamp(_cultist.hp / _cultist.max_hp, 0, 1);

		draw_set_alpha(0.9);
		draw_set_color(c_black);
		draw_rectangle(_bar_x, _bar_y, _bar_x + _health_bar_width, _bar_y + _demon_bar_height, false);

		draw_set_alpha(1);
		draw_set_color(COLOR_HEALTH_BAR);
		draw_rectangle(_bar_x, _bar_y, _bar_x + (_health_bar_width * _hp_progress), _bar_y + _demon_bar_height, false);
		draw_set_color(c_black);
		health_bar_segments_draw(_bar_x, _bar_y, _health_bar_width, _demon_bar_height, _cultist.max_hp);
		draw_set_color(c_white);
		draw_rectangle(_bar_x, _bar_y, _bar_x + _health_bar_width, _bar_y + _demon_bar_height, true);

		// Draw active ability cooldowns directly under the demon health bar.
		var _cooldown_timers = [];
		var _cooldown_maxes = [];
		var _cooldown_colors = [];

		if (_cultist.object_index == o_imp)
		{
			if (cultist_active_ability_has(_cultist, DEMON_ABILITY.IMP_DEMON_LEAP))
			{
				array_push(_cooldown_timers, _cultist.demon_leap_timer);
				array_push(_cooldown_maxes, _cultist.ability_cooldown_time_get(_cultist.demon_leap_cooldown));
				array_push(_cooldown_colors, COLOR_COOLDOWN_IMP_DEMON_LEAP);
			}

			if (cultist_active_ability_has(_cultist, DEMON_ABILITY.IMP_CRIMSON_GUILLOTINE))
			{
				array_push(_cooldown_timers, _cultist.crimson_guillotine_timer);
				array_push(_cooldown_maxes, _cultist.ability_cooldown_time_get(_cultist.crimson_guillotine_cooldown));
				array_push(_cooldown_colors, COLOR_COOLDOWN_IMP_CRIMSON_GUILLOTINE);
			}

			if (cultist_active_ability_has(_cultist, DEMON_ABILITY.IMP_BLOODY_CLONE))
			{
				array_push(_cooldown_timers, _cultist.bloody_clone_timer);
				array_push(_cooldown_maxes, _cultist.ability_cooldown_time_get(_cultist.bloody_clone_cooldown));
				array_push(_cooldown_colors, COLOR_COOLDOWN_IMP_BLOODY_CLONE);
			}
		}
		else if (_cultist.object_index == o_brute)
		{
			if (cultist_active_ability_has(_cultist, DEMON_ABILITY.BRUTE_GRAVE_SLAM))
			{
				array_push(_cooldown_timers, _cultist.grave_slam_timer);
				array_push(_cooldown_maxes, _cultist.ability_cooldown_time_get(_cultist.grave_slam_cooldown));
				array_push(_cooldown_colors, COLOR_COOLDOWN_BRUTE_GRAVE_SLAM);
			}

			if (cultist_active_ability_has(_cultist, DEMON_ABILITY.BRUTE_BUTCHER_CHAINS))
			{
				array_push(_cooldown_timers, _cultist.butcher_chains_timer);
				array_push(_cooldown_maxes, _cultist.ability_cooldown_time_get(_cultist.butcher_chains_cooldown));
				array_push(_cooldown_colors, COLOR_COOLDOWN_BRUTE_BUTCHER_CHAINS);
			}

			if (cultist_active_ability_has(_cultist, DEMON_ABILITY.BRUTE_CORPSE_ARMOR))
			{
				array_push(_cooldown_timers, _cultist.corpse_armor_ability_timer);
				array_push(_cooldown_maxes, _cultist.ability_cooldown_time_get(_cultist.corpse_armor_cooldown));
				array_push(_cooldown_colors, COLOR_COOLDOWN_BRUTE_CORPSE_ARMOR);
			}
		}
		else if (_cultist.object_index == o_warlock)
		{
			if (cultist_active_ability_has(_cultist, DEMON_ABILITY.WARLOCK_RAISE_LESSER_DEMON))
			{
				array_push(_cooldown_timers, _cultist.raise_lesser_demon_timer);
				array_push(_cooldown_maxes, _cultist.ability_cooldown_time_get(_cultist.raise_lesser_demon_cooldown));
				array_push(_cooldown_colors, COLOR_COOLDOWN_WARLOCK_RAISE_LESSER_DEMON);
			}

			if (cultist_active_ability_has(_cultist, DEMON_ABILITY.WARLOCK_SOUL_CHAIN))
			{
				array_push(_cooldown_timers, _cultist.soul_chain_cooldown_timer);
				array_push(_cooldown_maxes, _cultist.ability_cooldown_time_get(_cultist.soul_chain_cooldown));
				array_push(_cooldown_colors, COLOR_COOLDOWN_WARLOCK_SOUL_CHAIN);
			}

			if (cultist_active_ability_has(_cultist, DEMON_ABILITY.WARLOCK_HEX_TOTEM))
			{
				array_push(_cooldown_timers, _cultist.hex_totem_timer);
				array_push(_cooldown_maxes, _cultist.ability_cooldown_time_get(_cultist.hex_totem_cooldown));
				array_push(_cooldown_colors, COLOR_COOLDOWN_WARLOCK_HEX_TOTEM);
			}
		}

		for (var _cooldown_index = 0; _cooldown_index < array_length(_cooldown_timers); ++_cooldown_index)
		{
			var _cooldown_y = _bar_y
				+ _demon_bar_height
				+ _cooldown_bar_top_gap
				+ ((_cooldown_bar_height + _cooldown_bar_gap) * _cooldown_index);
			var _cooldown_progress = 1 - clamp(
				_cooldown_timers[_cooldown_index] / max(1, _cooldown_maxes[_cooldown_index]),
				0,
				1
			);

			draw_set_alpha(0.88);
			draw_set_color(c_black);
			draw_rectangle(_bar_x, _cooldown_y, _bar_x + _health_bar_width, _cooldown_y + _cooldown_bar_height, false);

			draw_set_alpha(1);
			draw_set_color(_cooldown_colors[_cooldown_index]);
			draw_rectangle(
				_bar_x,
				_cooldown_y,
				_bar_x + (_health_bar_width * _cooldown_progress),
				_cooldown_y + _cooldown_bar_height,
				false
			);

			draw_set_alpha(0.95);
			draw_set_color(c_white);
			draw_rectangle(_bar_x, _cooldown_y, _bar_x + _health_bar_width, _cooldown_y + _cooldown_bar_height, true);
		}
	}

	draw_set_alpha(1);
	draw_set_color(c_white);
}

// Draw Soul Chain links above world objects and health bars.
if (instance_exists(o_warlock) && instance_exists(o_camera_controller))
{
	var _camera_controller = instance_find(o_camera_controller, 0);
	var _camera_x = camera_get_view_x(_camera_controller.camera_id);
	var _camera_y = camera_get_view_y(_camera_controller.camera_id);
	var _camera_width = camera_get_view_width(_camera_controller.camera_id);
	var _camera_height = camera_get_view_height(_camera_controller.camera_id);
	var _chain_line_offset_y = -20;
	var _warlock_count = instance_number(o_warlock);

	for (var _warlock_index = 0; _warlock_index < _warlock_count; ++_warlock_index)
	{
		var _warlock = instance_find(o_warlock, _warlock_index);

		if (!instance_exists(_warlock) || !variable_instance_exists(_warlock, "soul_chain_groups"))
		{
			continue;
		}

		for (var _chain_index = 0; _chain_index < array_length(_warlock.soul_chain_groups); ++_chain_index)
		{
			var _chain = _warlock.soul_chain_groups[_chain_index];
			var _members = _chain.members;
			var _previous_member = noone;

			for (var _member_index = 0; _member_index < array_length(_members); ++_member_index)
			{
				var _member = _members[_member_index];

				if (!instance_exists(_member)
					|| !variable_instance_exists(_member, "hp")
					|| _member.hp <= 0
					|| !variable_instance_exists(_member, "soul_chain_id")
					|| _member.soul_chain_id != _chain.chain_id)
				{
					continue;
				}

				if (instance_exists(_previous_member))
				{
					var _chain_width = 3;
					var _chain_alpha = 0.9;

					if ((variable_instance_exists(_member, "soul_chain_death_flash_timer") && _member.soul_chain_death_flash_timer > 0)
						|| (variable_instance_exists(_previous_member, "soul_chain_death_flash_timer") && _previous_member.soul_chain_death_flash_timer > 0))
					{
						_chain_width = 5;
						_chain_alpha = 1;
					}

					var _from_x = ((_previous_member.x - _camera_x) / _camera_width) * camera_view_width;
					var _from_y = ((_previous_member.y + _chain_line_offset_y - _camera_y) / _camera_height) * camera_view_height;
					var _to_x = ((_member.x - _camera_x) / _camera_width) * camera_view_width;
					var _to_y = ((_member.y + _chain_line_offset_y - _camera_y) / _camera_height) * camera_view_height;

					draw_set_color(COLOR_WARLOCK_SOUL_CHAIN);
					draw_set_alpha(_chain_alpha);
					draw_line_width(_from_x, _from_y, _to_x, _to_y, _chain_width);
				}

				_previous_member = _member;
			}
		}
	}

	draw_set_alpha(1);
	draw_set_color(c_white);
}

// Draw pause windows only while the pause menu is open.
if (pause_menu_open)
{
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
	for (var _button_index = 0; _button_index < pause_button_count; ++_button_index)
	{
		var _button_x = pause_button_x_get(_button_index);
		var _button_y = pause_button_y_get(_button_index);
		var _button_width = pause_button_width_get(_button_index);
		var _button_height = pause_button_height_get(_button_index);

		draw_set_color(c_white);
		draw_rectangle(_button_x, _button_y, _button_x + _button_width, _button_y + _button_height, false);

		draw_set_color(c_black);
		draw_text(_button_x + (_button_width * 0.5), _button_y + (_button_height * 0.5), pause_button_labels[_button_index]);
	}
	}
	else
	{
	// Draw settings panel.
	var _panel_x = (camera_view_width - settings_panel_width) * 0.5;
	var _panel_y = (camera_view_height - settings_panel_height) * 0.5;
	var _close_button_x = _panel_x + ((settings_panel_width - button_width) * 0.5);
	var _close_button_y = _panel_y + settings_panel_height - button_height - settings_close_bottom_padding;

	draw_set_color(c_white);
	draw_rectangle(_panel_x, _panel_y, _panel_x + settings_panel_width, _panel_y + settings_panel_height, false);

	draw_set_color(c_black);
	if (variable_global_exists("ui_heading_font") && font_exists(global.ui_heading_font))
	{
		draw_set_font(global.ui_heading_font);
	}

	draw_text(_panel_x + (settings_panel_width * 0.5), _panel_y + 34, "SETTINGS");

	if (variable_global_exists("ui_font") && font_exists(global.ui_font))
	{
		draw_set_font(global.ui_font);
	}

	draw_set_halign(fa_left);
	draw_set_valign(fa_middle);

	for (var _slider_index = 0; _slider_index < settings_slider_count; ++_slider_index)
	{
		var _slider_rect = settings_slider_rect_get(_slider_index);
		var _slider_value = settings_slider_value_get(_slider_index);
		var _slider_label_x = _panel_x + 48;
		var _slider_label_y = _slider_rect.y + (settings_slider_height * 0.5);
		var _knob_x = _slider_rect.x + (_slider_rect.width * _slider_value);
		var _knob_y = _slider_rect.y + (settings_slider_height * 0.5);
		var _percent_text = string(round(_slider_value * 100)) + "%";

		draw_set_color(c_black);
		draw_text(_slider_label_x, _slider_label_y, settings_slider_labels[_slider_index]);
		draw_text(_slider_rect.x + _slider_rect.width + 22, _slider_label_y, _percent_text);

		draw_set_alpha(0.55);
		draw_rectangle(
			_slider_rect.x,
			_slider_rect.y,
			_slider_rect.x + _slider_rect.width,
			_slider_rect.y + _slider_rect.height,
			false
		);

		draw_set_alpha(1);
		draw_set_color(COLOR_PROJECTILE_BUILDING_SHELL);
		draw_rectangle(
			_slider_rect.x,
			_slider_rect.y,
			_knob_x,
			_slider_rect.y + _slider_rect.height,
			false
		);

		draw_set_color(c_black);
		draw_rectangle(
			_slider_rect.x,
			_slider_rect.y,
			_slider_rect.x + _slider_rect.width,
			_slider_rect.y + _slider_rect.height,
			true
		);

		draw_set_color(c_white);
		draw_circle(_knob_x, _knob_y, settings_slider_knob_radius, false);
		draw_set_color(c_black);
		draw_circle(_knob_x, _knob_y, settings_slider_knob_radius, true);
	}

	var _edge_toggle_rect = settings_edge_toggle_rect_get();
	var _edge_toggle_label_y = _edge_toggle_rect.y + (_edge_toggle_rect.height * 0.5);

	draw_set_halign(fa_left);
	draw_set_valign(fa_middle);
	draw_set_color(c_black);
	draw_text(_panel_x + 48, _edge_toggle_label_y, "Edge Scroll");
	draw_rectangle(
		_edge_toggle_rect.x,
		_edge_toggle_rect.y,
		_edge_toggle_rect.x + _edge_toggle_rect.width,
		_edge_toggle_rect.y + _edge_toggle_rect.height,
		true
	);

	if (global.edge_scroll_enabled)
	{
		var _check_padding = 5;

		draw_set_color(COLOR_PROJECTILE_BUILDING_SHELL);
		draw_rectangle(
			_edge_toggle_rect.x + _check_padding,
			_edge_toggle_rect.y + _check_padding,
			_edge_toggle_rect.x + _edge_toggle_rect.width - _check_padding,
			_edge_toggle_rect.y + _edge_toggle_rect.height - _check_padding,
			false
		);
	}

	// The experimental control switch stays hidden until explicitly enabled again.
	if (SQUAD_FLAG_SYSTEM_SETTING_VISIBLE)
	{
		var _flag_system_rect = settings_flag_system_rect_get();
		draw_set_color(c_black);
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		draw_rectangle(_flag_system_rect.x, _flag_system_rect.y,
			_flag_system_rect.x + _flag_system_rect.width, _flag_system_rect.y + _flag_system_rect.height, true);
		draw_text(_flag_system_rect.x + _flag_system_rect.width * 0.5,
			_flag_system_rect.y + _flag_system_rect.height * 0.5,
			squad_flag_system_2_enabled ? "Flag System 2" : "Flag System 1");
	}

	draw_set_halign(fa_center);
	draw_rectangle(_close_button_x, _close_button_y, _close_button_x + button_width, _close_button_y + button_height, true);
	draw_text(_close_button_x + (button_width * 0.5), _close_button_y + (button_height * 0.5), "BACK");
	}

}

// Restore default draw state.
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);

faction_summon_draw();
