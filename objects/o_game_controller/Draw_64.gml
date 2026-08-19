// The final completion message is the only visible GUI layer after the last night.
if (global.game_completion_popup_active)
{
	game_completion_popup_draw();
	exit;
}

// The Blood Moon reward is the only visible GUI layer until it is acknowledged.
if (global.blood_moon_reward_popup_active)
{
	blood_moon_reward_popup_draw();
	exit;
}

// The daybreak upgrade choice is the only visible GUI layer until a card is chosen.
if (global.early_upgrade_popup_active)
{
	early_upgrade_popup_draw();
	exit;
}

// Draw phase tint over the world while keeping HUD readable.
if (variable_global_exists("ui_font") && font_exists(global.ui_font))
{
	draw_set_font(global.ui_font);
}

if (global.day_phase == DAY_PHASE.DAY)
{
	draw_set_alpha(day_overlay_alpha);
	draw_set_color(c_black);
	draw_rectangle(0, 0, camera_view_width, camera_view_height, false);
	draw_set_alpha(1);
	draw_set_color(c_white);
}
else if (global.day_phase == DAY_PHASE.NIGHT)
{
	draw_set_alpha(night_overlay_alpha);
	draw_set_color(COLOR_NIGHT_OVERLAY);
	draw_rectangle(0, 0, camera_view_width, camera_view_height, false);
	draw_set_alpha(1);
	draw_set_color(c_white);
}

// Draw night squad markers above world units but below the rest of the GUI.
squad_night_markers_draw_gui();

// Draw attack warning arrows during the day and briefly at the start of the night.
var _game_speed_normal = variable_global_exists("game_speed_normal") ? global.game_speed_normal : room_speed;
var _night_warning_time = 10 * _game_speed_normal;
var _night_elapsed_time = (global.night_duration * _game_speed_normal) - global.day_timer;
var _night_warning_active = global.day_phase == DAY_PHASE.NIGHT
	&& _night_elapsed_time <= _night_warning_time;

if ((global.day_phase == DAY_PHASE.DAY || _night_warning_active)
	&& night_attack_plan_exists
	&& instance_exists(o_cannon)
	&& instance_exists(o_camera_controller))
{
	var _camera_controller = instance_find(o_camera_controller, 0);
	var _cannon = instance_find(o_cannon, 0);
	var _camera_x = camera_get_view_x(_camera_controller.camera_id);
	var _camera_y = camera_get_view_y(_camera_controller.camera_id);
	var _camera_width = camera_get_view_width(_camera_controller.camera_id);
	var _camera_height = camera_get_view_height(_camera_controller.camera_id);
	var _mouse_gui_x = device_mouse_x_to_gui(0);
	var _mouse_gui_y = device_mouse_y_to_gui(0);
	var _warning_hover_enemy_object = noone;
	var _warning_hover_distance = infinity;
	var _warning_alpha = 1;
	var _direction_count = array_length(night_attack_directions);

	if (global.day_phase == DAY_PHASE.NIGHT)
	{
		_warning_alpha = 1 - clamp(_night_elapsed_time / max(1, _night_warning_time), 0, 1);
	}

	for (var _direction_index = 0; _direction_index < _direction_count; ++_direction_index)
	{
		var _direction_data = night_attack_directions[_direction_index];
		var _direction = _direction_data.direction;
		var _warning_distance = BALANCE_NIGHT_ATTACK_WARNING_DISTANCE;

		if (global.day_phase == DAY_PHASE.NIGHT)
		{
			_warning_distance *= 1.15;
		}

		var _outer_world_x = _cannon.x + lengthdir_x(_warning_distance, _direction);
		var _outer_world_y = _cannon.y + lengthdir_y(_warning_distance, _direction);
		var _inner_world_x = _outer_world_x + lengthdir_x(BALANCE_NIGHT_ATTACK_WARNING_ARROW_LENGTH, _direction + 180);
		var _inner_world_y = _outer_world_y + lengthdir_y(BALANCE_NIGHT_ATTACK_WARNING_ARROW_LENGTH, _direction + 180);
		var _outer_x = ((_outer_world_x - _camera_x) / _camera_width) * camera_view_width;
		var _outer_y = ((_outer_world_y - _camera_y) / _camera_height) * camera_view_height;
		var _inner_x = ((_inner_world_x - _camera_x) / _camera_width) * camera_view_width;
		var _inner_y = ((_inner_world_y - _camera_y) / _camera_height) * camera_view_height;
		var _arrow_angle = _direction + 180;

		// Warning arrow sprite points from the attack direction toward the cannon.
		var _arrow_sprite_width = max(1, sprite_get_width(s_attack_arrow));
		var _arrow_scale = BALANCE_NIGHT_ATTACK_WARNING_ARROW_LENGTH / _arrow_sprite_width;
		var _arrow_y_scale = _arrow_scale * 0.55;

		draw_sprite_ext(s_attack_arrow, 0, _inner_x, _inner_y, _arrow_scale, _arrow_y_scale, _arrow_angle, c_white, BALANCE_ATTACK_ARROW_ALPHA * _warning_alpha);

		var _enemy_objects = _direction_data.enemy_objects;
		var _enemy_count = array_length(_enemy_objects);
		var _unit_start_offset = -((_enemy_count - 1) * BALANCE_NIGHT_ATTACK_WARNING_UNIT_GAP) * 0.5;

		for (var _enemy_index = 0; _enemy_index < _enemy_count; ++_enemy_index)
		{
			var _enemy_object = _enemy_objects[_enemy_index];
			var _enemy_sprite = object_get_sprite(_enemy_object);
			var _unit_side_offset = _unit_start_offset + (_enemy_index * BALANCE_NIGHT_ATTACK_WARNING_UNIT_GAP);
			var _unit_world_x = _outer_world_x + lengthdir_x(_unit_side_offset, _direction + 90);
			var _unit_world_y = _outer_world_y + lengthdir_y(_unit_side_offset, _direction + 90);
			var _unit_x = ((_unit_world_x - _camera_x) / _camera_width) * camera_view_width;
			var _unit_y = ((_unit_world_y - _camera_y) / _camera_height) * camera_view_height;
			var _distance_to_icon = point_distance(_mouse_gui_x, _mouse_gui_y, _unit_x, _unit_y);

			draw_set_alpha(_warning_alpha);
			draw_set_color(COLOR_ATTACK_WARNING_UNIT_BACKGROUND);
			draw_circle(_unit_x, _unit_y, BALANCE_NIGHT_ATTACK_WARNING_UNIT_CIRCLE_RADIUS, false);
			draw_set_color(c_white);
			draw_circle(_unit_x, _unit_y, BALANCE_NIGHT_ATTACK_WARNING_UNIT_CIRCLE_RADIUS, true);

			if (_enemy_sprite != -1)
			{
				var _sprite_width = sprite_get_width(_enemy_sprite);
				var _sprite_height = sprite_get_height(_enemy_sprite);
				var _sprite_size = max(_sprite_width, _sprite_height);
				var _sprite_scale = (BALANCE_NIGHT_ATTACK_WARNING_UNIT_CIRCLE_RADIUS * 1.45) / max(1, _sprite_size);
				var _sprite_frame = (current_time div 160) mod max(1, sprite_get_number(_enemy_sprite));
				var _sprite_draw_x = _unit_x + ((sprite_get_xoffset(_enemy_sprite) - (_sprite_width * 0.5)) * _sprite_scale);
				var _sprite_draw_y = _unit_y + ((sprite_get_yoffset(_enemy_sprite) - (_sprite_height * 0.5)) * _sprite_scale);

				draw_sprite_ext(_enemy_sprite, _sprite_frame, _sprite_draw_x, _sprite_draw_y, _sprite_scale, _sprite_scale, 0, c_white, _warning_alpha);
			}

			if (_distance_to_icon <= BALANCE_NIGHT_ATTACK_WARNING_UNIT_CIRCLE_RADIUS
				&& _distance_to_icon <= _warning_hover_distance)
			{
				_warning_hover_enemy_object = _enemy_object;
				_warning_hover_distance = _distance_to_icon;
			}
		}
	}

	if (global.day_phase == DAY_PHASE.DAY
		&& variable_instance_exists(id, "boss_griffith_pending_next_night")
		&& boss_griffith_pending_next_night)
	{
		var _boss_direction = boss_griffith_pending_direction;
		var _boss_enemy_objects = [o_boss_griffith, o_enemy_archer, o_enemy_knight];

		if (boss_crusader_horde_is_scheduled(night_attack_night_index))
		{
			_boss_enemy_objects = [o_crusader];
		}

		var _boss_enemy_count = array_length(_boss_enemy_objects);
		var _boss_warning_distance = BALANCE_NIGHT_ATTACK_WARNING_DISTANCE * 1.08;
		var _boss_outer_world_x = _cannon.x + lengthdir_x(_boss_warning_distance, _boss_direction);
		var _boss_outer_world_y = _cannon.y + lengthdir_y(_boss_warning_distance, _boss_direction);
		var _boss_inner_world_x = _boss_outer_world_x + lengthdir_x(BALANCE_NIGHT_ATTACK_WARNING_ARROW_LENGTH, _boss_direction + 180);
		var _boss_inner_world_y = _boss_outer_world_y + lengthdir_y(BALANCE_NIGHT_ATTACK_WARNING_ARROW_LENGTH, _boss_direction + 180);
		var _boss_inner_x = ((_boss_inner_world_x - _camera_x) / _camera_width) * camera_view_width;
		var _boss_inner_y = ((_boss_inner_world_y - _camera_y) / _camera_height) * camera_view_height;
		var _boss_arrow_angle = _boss_direction + 180;
		var _boss_arrow_sprite_width = max(1, sprite_get_width(s_attack_arrow));
		var _boss_arrow_scale = BALANCE_NIGHT_ATTACK_WARNING_ARROW_LENGTH / _boss_arrow_sprite_width;
		var _boss_arrow_y_scale = _boss_arrow_scale * 0.55;
		var _boss_unit_start_offset = -((_boss_enemy_count - 1) * BALANCE_NIGHT_ATTACK_WARNING_UNIT_GAP) * 0.5;

		draw_sprite_ext(
			s_attack_arrow,
			0,
			_boss_inner_x,
			_boss_inner_y,
			_boss_arrow_scale,
			_boss_arrow_y_scale,
			_boss_arrow_angle,
			COLOR_STATUS_NEGATIVE_RED,
			BALANCE_ATTACK_ARROW_ALPHA
		);

		for (var _boss_enemy_index = 0; _boss_enemy_index < _boss_enemy_count; ++_boss_enemy_index)
		{
			var _boss_enemy_object = _boss_enemy_objects[_boss_enemy_index];
			var _boss_enemy_sprite = object_get_sprite(_boss_enemy_object);
			var _boss_unit_side_offset = _boss_unit_start_offset + (_boss_enemy_index * BALANCE_NIGHT_ATTACK_WARNING_UNIT_GAP);
			var _boss_unit_world_x = _boss_outer_world_x + lengthdir_x(_boss_unit_side_offset, _boss_direction + 90);
			var _boss_unit_world_y = _boss_outer_world_y + lengthdir_y(_boss_unit_side_offset, _boss_direction + 90);
			var _boss_unit_x = ((_boss_unit_world_x - _camera_x) / _camera_width) * camera_view_width;
			var _boss_unit_y = ((_boss_unit_world_y - _camera_y) / _camera_height) * camera_view_height;
			var _boss_distance_to_icon = point_distance(_mouse_gui_x, _mouse_gui_y, _boss_unit_x, _boss_unit_y);

			draw_set_alpha(1);
			draw_set_color(COLOR_ATTACK_WARNING_UNIT_BACKGROUND);
			draw_circle(_boss_unit_x, _boss_unit_y, BALANCE_NIGHT_ATTACK_WARNING_UNIT_CIRCLE_RADIUS, false);
			draw_set_color(COLOR_STATUS_NEGATIVE_RED);
			draw_circle(_boss_unit_x, _boss_unit_y, BALANCE_NIGHT_ATTACK_WARNING_UNIT_CIRCLE_RADIUS, true);

			if (_boss_enemy_sprite != -1)
			{
				var _boss_sprite_width = sprite_get_width(_boss_enemy_sprite);
				var _boss_sprite_height = sprite_get_height(_boss_enemy_sprite);
				var _boss_sprite_size = max(_boss_sprite_width, _boss_sprite_height);
				var _boss_sprite_scale = (BALANCE_NIGHT_ATTACK_WARNING_UNIT_CIRCLE_RADIUS * 1.45) / max(1, _boss_sprite_size);
				var _boss_sprite_frame = (current_time div 160) mod max(1, sprite_get_number(_boss_enemy_sprite));
				var _boss_sprite_draw_x = _boss_unit_x + ((sprite_get_xoffset(_boss_enemy_sprite) - (_boss_sprite_width * 0.5)) * _boss_sprite_scale);
				var _boss_sprite_draw_y = _boss_unit_y + ((sprite_get_yoffset(_boss_enemy_sprite) - (_boss_sprite_height * 0.5)) * _boss_sprite_scale);

				draw_sprite_ext(
					_boss_enemy_sprite,
					_boss_sprite_frame,
					_boss_sprite_draw_x,
					_boss_sprite_draw_y,
					_boss_sprite_scale,
					_boss_sprite_scale,
					0,
					c_white,
					1
				);
			}

			if (_boss_distance_to_icon <= BALANCE_NIGHT_ATTACK_WARNING_UNIT_CIRCLE_RADIUS
				&& _boss_distance_to_icon <= _warning_hover_distance)
			{
				_warning_hover_enemy_object = _boss_enemy_object;
				_warning_hover_distance = _boss_distance_to_icon;
			}
		}
	}

	if (_warning_hover_enemy_object != noone)
	{
		var _card_width = 260;
		var _card_height = 316;
		var _card_margin = 18;
		var _card_x = min(_mouse_gui_x + 18, camera_view_width - _card_width - _card_margin);
		var _card_y = min(_mouse_gui_y + 18, camera_view_height - _card_height - _card_margin);

		enemy_object_stats_card_draw(_warning_hover_enemy_object, _card_x, _card_y);
	}

	draw_set_alpha(1);
	draw_set_color(c_white);
}

// Draw a short phase transition banner near the top of the screen.
if (phase_banner_timer > 0 && phase_banner_text != "")
{
	var _banner_progress = phase_banner_timer / max(1, phase_banner_duration);
	var _banner_alpha = min(1, _banner_progress * 3);
	var _banner_width = min(phase_banner_width, camera_view_width - 36);
	var _banner_height = phase_banner_height;
	var _banner_x = (camera_view_width - _banner_width) * 0.5;
	var _banner_y = phase_banner_y;
	var _banner_accent_color = COLOR_PHASE_BANNER_DAY;

	if (global.day_phase == DAY_PHASE.NIGHT)
	{
		_banner_accent_color = COLOR_PHASE_BANNER_NIGHT;
	}

	draw_set_alpha(phase_banner_background_alpha * _banner_alpha);
	draw_set_color(COLOR_HUD_BACKGROUND);
	draw_rectangle(_banner_x, _banner_y, _banner_x + _banner_width, _banner_y + _banner_height, false);

	draw_set_alpha(_banner_alpha);
	draw_set_color(_banner_accent_color);
	draw_rectangle(_banner_x, _banner_y, _banner_x + _banner_width, _banner_y + 4, false);
	draw_rectangle(_banner_x, _banner_y + _banner_height - 4, _banner_x + _banner_width, _banner_y + _banner_height, false);

	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);

	if (variable_global_exists("ui_heading_font") && font_exists(global.ui_heading_font))
	{
		draw_set_font(global.ui_heading_font);
	}

	draw_set_color(COLOR_HUD_TEXT);
	draw_text(_banner_x + (_banner_width * 0.5), _banner_y + (_banner_height * 0.5), phase_banner_text);

	if (variable_global_exists("ui_font") && font_exists(global.ui_font))
	{
		draw_set_font(global.ui_font);
	}

	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_alpha(1);
	draw_set_color(c_white);
}

// Draw a non-blocking worker assignment hint above the first Quarry.
if (!worker_assignment_hint_completed
	&& global.tutorial_hints_enabled
	&& worker_assignment_hint_delay_started
	&& worker_assignment_hint_delay_timer <= 0
	&& global.focus_window == FOCUS_WINDOW.NOONE
	&& (!variable_global_exists("tutorial_popup_active") || !global.tutorial_popup_active)
	&& instance_exists(o_camera_controller))
{
	var _hint_building = noone;

	if (instance_exists(o_quarry))
	{
		_hint_building = instance_find(o_quarry, 0);
	}

	if (instance_exists(_hint_building))
	{
		var _hint_camera_controller = instance_find(o_camera_controller, 0);
		var _hint_camera_x = camera_get_view_x(_hint_camera_controller.camera_id);
		var _hint_camera_y = camera_get_view_y(_hint_camera_controller.camera_id);
		var _hint_camera_width = camera_get_view_width(_hint_camera_controller.camera_id);
		var _hint_camera_height = camera_get_view_height(_hint_camera_controller.camera_id);
		var _hint_anchor_x = ((_hint_building.x - _hint_camera_x) / _hint_camera_width) * camera_view_width;
		var _hint_anchor_y = (((_hint_building.bbox_top - worker_assignment_hint_offset_y) - _hint_camera_y) / _hint_camera_height) * camera_view_height;
		var _hint_width = min(worker_assignment_hint_width, camera_view_width - 36);
		var _hint_text_width = _hint_width - (worker_assignment_hint_padding_x * 2);
		var _hint_height = (worker_assignment_hint_padding_y * 2)
			+ string_height_ext(worker_assignment_hint_text, worker_assignment_hint_line_height, _hint_text_width);
		var _hint_x = clamp(_hint_anchor_x - (_hint_width * 0.5), 18, camera_view_width - _hint_width - 18);
		var _hint_y = max(18, _hint_anchor_y - _hint_height);
		var _pulse = 0.88 + (sin(current_time * 0.006) * 0.08);

		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		draw_set_alpha(worker_assignment_hint_background_alpha * _pulse);
		draw_set_color(COLOR_HUD_BACKGROUND);
		draw_rectangle(_hint_x, _hint_y, _hint_x + _hint_width, _hint_y + _hint_height, false);

		draw_set_alpha(_pulse);
		draw_set_color(COLOR_HUD_TEXT);
		draw_text_ext(
			_hint_x + worker_assignment_hint_padding_x,
			_hint_y + worker_assignment_hint_padding_y,
			worker_assignment_hint_text,
			worker_assignment_hint_line_height,
			_hint_text_width
		);

		draw_set_alpha(1);
		draw_set_color(c_white);
	}
}

// Draw a non-blocking tree corruption hint above the nearest uncorrupted tree to the cannon.
if (TREE_CORRUPTION_SPREAD_ENABLED
	&& !tree_corruption_hint_completed
	&& global.tutorial_hints_enabled
	&& global.focus_window == FOCUS_WINDOW.NOONE
	&& (!variable_global_exists("tutorial_popup_active") || !global.tutorial_popup_active)
	&& instance_exists(o_camera_controller)
	&& instance_exists(o_cannon)
	&& instance_exists(o_tree))
{
	var _tree_hint_camera_controller = instance_find(o_camera_controller, 0);
	var _tree_hint_camera_x = camera_get_view_x(_tree_hint_camera_controller.camera_id);
	var _tree_hint_camera_y = camera_get_view_y(_tree_hint_camera_controller.camera_id);
	var _tree_hint_camera_width = camera_get_view_width(_tree_hint_camera_controller.camera_id);
	var _tree_hint_camera_height = camera_get_view_height(_tree_hint_camera_controller.camera_id);
	var _tree_hint_cannon = instance_find(o_cannon, 0);
	var _tree_hint_target = noone;

	if (instance_exists(tree_corruption_hint_target)
		&& !tree_corruption_hint_target.is_corrupted
		&& point_distance(
			tree_corruption_hint_target.x,
			tree_corruption_hint_target.y,
			_tree_hint_cannon.x,
			_tree_hint_cannon.y
		) >= tree_corruption_hint_min_cannon_distance)
	{
		_tree_hint_target = tree_corruption_hint_target;
	}
	else
	{
		var _tree_hint_best_distance = infinity;
		var _tree_hint_count = instance_number(o_tree);

		for (var _tree_hint_index = 0; _tree_hint_index < _tree_hint_count; ++_tree_hint_index)
		{
			var _tree_hint_tree = instance_find(o_tree, _tree_hint_index);

			if (!instance_exists(_tree_hint_tree) || _tree_hint_tree.is_corrupted)
			{
				continue;
			}

			var _tree_hint_distance = point_distance(
				_tree_hint_tree.x,
				_tree_hint_tree.y,
				_tree_hint_cannon.x,
				_tree_hint_cannon.y
			);

			if (_tree_hint_distance >= tree_corruption_hint_min_cannon_distance
				&& _tree_hint_distance < _tree_hint_best_distance)
			{
				_tree_hint_best_distance = _tree_hint_distance;
				_tree_hint_target = _tree_hint_tree;
			}
		}

		tree_corruption_hint_target = _tree_hint_target;
	}

	if (instance_exists(_tree_hint_target))
	{
		var _tree_hint_anchor_x = ((_tree_hint_target.x - _tree_hint_camera_x) / _tree_hint_camera_width) * camera_view_width;
		var _tree_hint_anchor_y = (((_tree_hint_target.bbox_top - tree_corruption_hint_offset_y) - _tree_hint_camera_y) / _tree_hint_camera_height) * camera_view_height;
		var _tree_hint_width = min(tree_corruption_hint_width, camera_view_width - 36);
		var _tree_hint_text_width = _tree_hint_width - (tree_corruption_hint_padding_x * 2);
		var _tree_hint_height = (tree_corruption_hint_padding_y * 2)
			+ string_height_ext(tree_corruption_hint_text, tree_corruption_hint_line_height, _tree_hint_text_width);
		var _tree_hint_x = clamp(_tree_hint_anchor_x - (_tree_hint_width * 0.5), 18, camera_view_width - _tree_hint_width - 18);
		var _tree_hint_y = max(18, _tree_hint_anchor_y - _tree_hint_height);
		var _tree_hint_pulse = 0.88 + (sin(current_time * 0.006) * 0.08);

		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		draw_set_alpha(tree_corruption_hint_background_alpha * _tree_hint_pulse);
		draw_set_color(COLOR_HUD_BACKGROUND);
		draw_rectangle(_tree_hint_x, _tree_hint_y, _tree_hint_x + _tree_hint_width, _tree_hint_y + _tree_hint_height, false);

		draw_set_alpha(_tree_hint_pulse);
		draw_set_color(COLOR_HUD_TEXT);
		draw_text_ext(
			_tree_hint_x + tree_corruption_hint_padding_x,
			_tree_hint_y + tree_corruption_hint_padding_y,
			tree_corruption_hint_text,
			tree_corruption_hint_line_height,
			_tree_hint_text_width
		);

		draw_set_alpha(1);
		draw_set_color(c_white);
	}
}

// Draw target selection radius under the cursor.
if (global.focus_window == FOCUS_WINDOW.TARGET_SELECTION && instance_exists(o_camera_controller))
{
	var _camera_controller = instance_find(o_camera_controller, 0);
	var _mouse_x = device_mouse_x_to_gui(0);
	var _mouse_y = device_mouse_y_to_gui(0);
	var _camera_x = camera_get_view_x(_camera_controller.camera_id);
	var _camera_y = camera_get_view_y(_camera_controller.camera_id);
	var _camera_width = camera_get_view_width(_camera_controller.camera_id);
	var _camera_height = camera_get_view_height(_camera_controller.camera_id);
	var _mouse_world_x = _camera_x + ((_mouse_x / camera_view_width) * _camera_width);
	var _mouse_world_y = _camera_y + ((_mouse_y / camera_view_height) * _camera_height);
	var _cultist_target_is_revealed = true;
	var _target_hint_text = "";
	var _target_hint_color = COLOR_STATUS_NEGATIVE_RED;
	var _radius_scale = camera_view_width / _camera_controller.view_width;
	var _draw_radius = target_selection_radius * _radius_scale;
	var _target_color = COLOR_PROJECTILE_DAMAGE;
	var _projectile_payload = noone;
	var _building_preview_radius = 0;
	var _building_preview_radius_draw = 0;

	if (target_selection_projectile_type == PROJECTILE_TYPE.CORRUPTION)
	{
		_target_color = COLOR_PROJECTILE_CORRUPTION;

		if (!taint_compost_target_touches_corruption(_mouse_world_x, _mouse_world_y))
		{
			_target_color = COLOR_STATUS_NEGATIVE_RED;
			_target_hint_text = "Must touch existing Taint";
		}
	}
	else if (target_selection_projectile_type == PROJECTILE_TYPE.SUMMON)
	{
		_target_color = COLOR_PROJECTILE_SUMMON;
	}
	else if (target_selection_projectile_type == PROJECTILE_TYPE.RALLY)
	{
		_target_color = COLOR_PROJECTILE_RALLY;
	}
	else if (target_selection_projectile_type == PROJECTILE_TYPE.CULTIST)
	{
		_target_color = COLOR_PROJECTILE_CULTIST;
		_cultist_target_is_revealed = world_position_is_revealed_by_fog(_mouse_world_x, _mouse_world_y);

		if (!_cultist_target_is_revealed)
		{
			_target_color = COLOR_STATUS_NEGATIVE_RED;
			_target_hint_text = "Aim at a revealed zone";
		}
	}
	else if (target_selection_projectile_type == PROJECTILE_TYPE.HEAL)
	{
		_target_color = COLOR_PROJECTILE_HEAL;
	}
	else if (target_selection_projectile_type == PROJECTILE_TYPE.BOMB)
	{
		_target_color = COLOR_PROJECTILE_BOMB;
		_target_hint_color = COLOR_PROJECTILE_BOMB;

		if (!hellcow_aim_is_dragging)
		{
			_target_hint_text = "Hold and drag to set charge direction";
		}
		else if (hellcow_aim_drag_distance < BALANCE_PROJECTILE_HELLCOW_AIM_MIN_DRAG)
		{
			_target_hint_text = "Drag farther to fire";
		}
	}
	else if (target_selection_projectile_type == PROJECTILE_TYPE.SKELETONS)
	{
		_target_color = COLOR_PROJECTILE_SKELETONS;
	}
	else if (target_selection_projectile_type == PROJECTILE_TYPE.UNIT_SHELL)
	{
		_target_color = COLOR_PROJECTILE_UNIT_SHELL;
	}
	else if (target_selection_projectile_type == PROJECTILE_TYPE.BUILDING_SHELL)
	{
		_target_color = COLOR_PROJECTILE_BUILDING_SHELL;
		var _projectile_queue_count = array_length(global.cannon_projectile_queue);
		var _selected_projectile_index = clamp(global.cannon_selected_projectile_index, 0, max(0, _projectile_queue_count - 1));

		if (_projectile_queue_count > 0
			&& _selected_projectile_index < array_length(global.cannon_projectile_payload_queue))
		{
			_projectile_payload = global.cannon_projectile_payload_queue[_selected_projectile_index];
			_building_preview_radius = building_shell_preview_radius_get(_projectile_payload);
			_building_preview_radius_draw = _building_preview_radius * _radius_scale;

			if (_building_preview_radius > 0)
			{
				_target_color = building_shell_preview_color_get(_projectile_payload);
				_draw_radius = _building_preview_radius_draw;
			}
		}

		if (!ground_cell_is_tainted_at_position(_mouse_world_x, _mouse_world_y))
		{
			_target_color = COLOR_STATUS_NEGATIVE_RED;
			_target_hint_text = "Must land on Taint";
		}
	}

	if (target_selection_projectile_type == PROJECTILE_TYPE.BOMB)
	{
		var _hellcow_start_world_x = _mouse_world_x;
		var _hellcow_start_world_y = _mouse_world_y;
		var _hellcow_direction = hellcow_aim_direction;

		if (hellcow_aim_is_dragging)
		{
			_hellcow_start_world_x = hellcow_aim_start_x;
			_hellcow_start_world_y = hellcow_aim_start_y;
		}
		else if (instance_exists(o_cannon))
		{
			var _hellcow_preview_cannon = instance_find(o_cannon, 0);
			_hellcow_direction = point_direction(
				_hellcow_preview_cannon.x,
				_hellcow_preview_cannon.y,
				_hellcow_start_world_x,
				_hellcow_start_world_y
			);
		}

		var _hellcow_start_x = ((_hellcow_start_world_x - _camera_x) / _camera_width) * camera_view_width;
		var _hellcow_start_y = ((_hellcow_start_world_y - _camera_y) / _camera_height) * camera_view_height;
		var _hellcow_corridor_length = BALANCE_PROJECTILE_HELLCOW_CHARGE_DISTANCE * _radius_scale;
		var _hellcow_half_width = BALANCE_PROJECTILE_HELLCOW_CORRIDOR_WIDTH * 0.5 * _radius_scale;
		var _hellcow_end_x = _hellcow_start_x + lengthdir_x(_hellcow_corridor_length, _hellcow_direction);
		var _hellcow_end_y = _hellcow_start_y + lengthdir_y(_hellcow_corridor_length, _hellcow_direction);
		var _hellcow_start_left_x = _hellcow_start_x + lengthdir_x(_hellcow_half_width, _hellcow_direction + 90);
		var _hellcow_start_left_y = _hellcow_start_y + lengthdir_y(_hellcow_half_width, _hellcow_direction + 90);
		var _hellcow_start_right_x = _hellcow_start_x + lengthdir_x(_hellcow_half_width, _hellcow_direction - 90);
		var _hellcow_start_right_y = _hellcow_start_y + lengthdir_y(_hellcow_half_width, _hellcow_direction - 90);
		var _hellcow_end_left_x = _hellcow_end_x + lengthdir_x(_hellcow_half_width, _hellcow_direction + 90);
		var _hellcow_end_left_y = _hellcow_end_y + lengthdir_y(_hellcow_half_width, _hellcow_direction + 90);
		var _hellcow_end_right_x = _hellcow_end_x + lengthdir_x(_hellcow_half_width, _hellcow_direction - 90);
		var _hellcow_end_right_y = _hellcow_end_y + lengthdir_y(_hellcow_half_width, _hellcow_direction - 90);
		var _hellcow_pulse_speed = 0.008;
		var _hellcow_pulse = 0.72 + (sin(current_time * _hellcow_pulse_speed) * 0.18);

		// The wide translucent corridor communicates every unit affected by the charge.
		draw_set_color(_target_color);
		draw_set_alpha(target_selection_alpha * _hellcow_pulse);
		draw_triangle(
			_hellcow_start_left_x,
			_hellcow_start_left_y,
			_hellcow_start_right_x,
			_hellcow_start_right_y,
			_hellcow_end_left_x,
			_hellcow_end_left_y,
			false
		);
		draw_triangle(
			_hellcow_start_right_x,
			_hellcow_start_right_y,
			_hellcow_end_right_x,
			_hellcow_end_right_y,
			_hellcow_end_left_x,
			_hellcow_end_left_y,
			false
		);

		draw_set_alpha(target_selection_outline_alpha);
		draw_line_width(_hellcow_start_left_x, _hellcow_start_left_y, _hellcow_end_left_x, _hellcow_end_left_y, 3);
		draw_line_width(_hellcow_start_right_x, _hellcow_start_right_y, _hellcow_end_right_x, _hellcow_end_right_y, 3);
		draw_line_width(_hellcow_start_left_x, _hellcow_start_left_y, _hellcow_start_right_x, _hellcow_start_right_y, 3);
		draw_line_width(_hellcow_end_left_x, _hellcow_end_left_y, _hellcow_end_right_x, _hellcow_end_right_y, 3);

		// A large center arrow reinforces that every displacement follows one direction.
		var _hellcow_arrow_start_x = _hellcow_start_x + lengthdir_x(48 * _radius_scale, _hellcow_direction);
		var _hellcow_arrow_start_y = _hellcow_start_y + lengthdir_y(48 * _radius_scale, _hellcow_direction);
		var _hellcow_arrow_head_length = 52 * _radius_scale;
		var _hellcow_arrow_head_width = 34 * _radius_scale;
		var _hellcow_arrow_base_x = _hellcow_end_x + lengthdir_x(_hellcow_arrow_head_length, _hellcow_direction + 180);
		var _hellcow_arrow_base_y = _hellcow_end_y + lengthdir_y(_hellcow_arrow_head_length, _hellcow_direction + 180);

		draw_set_alpha(0.95);
		draw_line_width(_hellcow_arrow_start_x, _hellcow_arrow_start_y, _hellcow_arrow_base_x, _hellcow_arrow_base_y, 8);
		draw_triangle(
			_hellcow_end_x,
			_hellcow_end_y,
			_hellcow_arrow_base_x + lengthdir_x(_hellcow_arrow_head_width, _hellcow_direction + 90),
			_hellcow_arrow_base_y + lengthdir_y(_hellcow_arrow_head_width, _hellcow_direction + 90),
			_hellcow_arrow_base_x + lengthdir_x(_hellcow_arrow_head_width, _hellcow_direction - 90),
			_hellcow_arrow_base_y + lengthdir_y(_hellcow_arrow_head_width, _hellcow_direction - 90),
			false
		);

		if (sprite_exists(s_cow))
		{
			draw_set_alpha(1);
			draw_sprite_ext(
				s_cow,
				0,
				_hellcow_start_x,
				_hellcow_start_y,
				0.5 * _radius_scale,
				0.5 * _radius_scale,
				_hellcow_direction,
				c_white,
				1
			);
		}

		var _hellcow_direction_x = lengthdir_x(1, _hellcow_direction);
		var _hellcow_direction_y = lengthdir_y(1, _hellcow_direction);
		var _hellcow_side_x = -_hellcow_direction_y;
		var _hellcow_side_y = _hellcow_direction_x;
		var _hellcow_world_half_width = BALANCE_PROJECTILE_HELLCOW_CORRIDOR_WIDTH * 0.5;
		var _hellcow_enemy_count = instance_number(o_enemy_units);

		// Highlight affected enemies and show an approximate pushed silhouette.
		for (var _hellcow_enemy_index = 0; _hellcow_enemy_index < _hellcow_enemy_count; ++_hellcow_enemy_index)
		{
			var _hellcow_enemy = instance_find(o_enemy_units, _hellcow_enemy_index);

			if (!instance_exists(_hellcow_enemy)
				|| (variable_instance_exists(_hellcow_enemy, "hp") && _hellcow_enemy.hp <= 0)
				|| (variable_instance_exists(_hellcow_enemy, "cached_is_hidden_by_fog")
					&& _hellcow_enemy.cached_is_hidden_by_fog))
			{
				continue;
			}

			var _hellcow_enemy_offset_x = _hellcow_enemy.x - _hellcow_start_world_x;
			var _hellcow_enemy_offset_y = _hellcow_enemy.y - _hellcow_start_world_y;
			var _hellcow_enemy_forward = (_hellcow_enemy_offset_x * _hellcow_direction_x)
				+ (_hellcow_enemy_offset_y * _hellcow_direction_y);
			var _hellcow_enemy_side = (_hellcow_enemy_offset_x * _hellcow_side_x)
				+ (_hellcow_enemy_offset_y * _hellcow_side_y);

			if (_hellcow_enemy_forward < 0
				|| _hellcow_enemy_forward > BALANCE_PROJECTILE_HELLCOW_CHARGE_DISTANCE
				|| abs(_hellcow_enemy_side) > _hellcow_world_half_width)
			{
				continue;
			}

			var _hellcow_enemy_x = ((_hellcow_enemy.x - _camera_x) / _camera_width) * camera_view_width;
			var _hellcow_enemy_y = ((_hellcow_enemy.y - _camera_y) / _camera_height) * camera_view_height;
			var _hellcow_preview_push = min(
				BALANCE_PROJECTILE_HELLCOW_PREVIEW_PUSH_DISTANCE,
				BALANCE_PROJECTILE_HELLCOW_CHARGE_DISTANCE - _hellcow_enemy_forward
			);
			var _hellcow_ghost_world_x = _hellcow_enemy.x + (_hellcow_direction_x * _hellcow_preview_push);
			var _hellcow_ghost_world_y = _hellcow_enemy.y + (_hellcow_direction_y * _hellcow_preview_push);
			var _hellcow_ghost_x = ((_hellcow_ghost_world_x - _camera_x) / _camera_width) * camera_view_width;
			var _hellcow_ghost_y = ((_hellcow_ghost_world_y - _camera_y) / _camera_height) * camera_view_height;

			if (sprite_exists(_hellcow_enemy.sprite_index))
			{
				draw_sprite_ext(
					_hellcow_enemy.sprite_index,
					_hellcow_enemy.image_index,
					_hellcow_ghost_x,
					_hellcow_ghost_y,
					_hellcow_enemy.image_xscale * _radius_scale,
					_hellcow_enemy.image_yscale * _radius_scale,
					_hellcow_enemy.image_angle,
					_target_color,
					0.2
				);
			}

			draw_set_color(_target_color);
			draw_set_alpha(0.28 + (0.12 * _hellcow_pulse));
			draw_circle(_hellcow_enemy_x, _hellcow_enemy_y, 22 * _radius_scale, false);
			draw_set_alpha(0.95);
			var _hellcow_enemy_arrow_end_x = _hellcow_enemy_x
				+ lengthdir_x(30 * _radius_scale, _hellcow_direction);
			var _hellcow_enemy_arrow_end_y = _hellcow_enemy_y
				+ lengthdir_y(30 * _radius_scale, _hellcow_direction);
			draw_line_width(
				_hellcow_enemy_x,
				_hellcow_enemy_y,
				_hellcow_enemy_arrow_end_x,
				_hellcow_enemy_arrow_end_y,
				3
			);
			draw_triangle(
				_hellcow_enemy_arrow_end_x,
				_hellcow_enemy_arrow_end_y,
				_hellcow_enemy_arrow_end_x + lengthdir_x(8 * _radius_scale, _hellcow_direction + 150),
				_hellcow_enemy_arrow_end_y + lengthdir_y(8 * _radius_scale, _hellcow_direction + 150),
				_hellcow_enemy_arrow_end_x + lengthdir_x(8 * _radius_scale, _hellcow_direction - 150),
				_hellcow_enemy_arrow_end_y + lengthdir_y(8 * _radius_scale, _hellcow_direction - 150),
				false
			);
		}

		// Tainted ground inside the path pulses without promising exact unit trajectories.
		var _hellcow_taint_step = 96;
		var _hellcow_taint_side_step = BALANCE_PROJECTILE_HELLCOW_CORRIDOR_WIDTH * 0.32;

		for (var _hellcow_taint_forward = _hellcow_taint_step;
			_hellcow_taint_forward < BALANCE_PROJECTILE_HELLCOW_CHARGE_DISTANCE;
			_hellcow_taint_forward += _hellcow_taint_step)
		{
			for (var _hellcow_taint_lane = -1; _hellcow_taint_lane <= 1; ++_hellcow_taint_lane)
			{
				var _hellcow_taint_world_x = _hellcow_start_world_x
					+ (_hellcow_direction_x * _hellcow_taint_forward)
					+ (_hellcow_side_x * _hellcow_taint_side_step * _hellcow_taint_lane);
				var _hellcow_taint_world_y = _hellcow_start_world_y
					+ (_hellcow_direction_y * _hellcow_taint_forward)
					+ (_hellcow_side_y * _hellcow_taint_side_step * _hellcow_taint_lane);

				if (!ground_cell_is_tainted_at_position(_hellcow_taint_world_x, _hellcow_taint_world_y))
				{
					continue;
				}

				var _hellcow_taint_x = ((_hellcow_taint_world_x - _camera_x) / _camera_width) * camera_view_width;
				var _hellcow_taint_y = ((_hellcow_taint_world_y - _camera_y) / _camera_height) * camera_view_height;

				draw_set_color(COLOR_PROJECTILE_CORRUPTION);
				draw_set_alpha(0.24 * _hellcow_pulse);
				draw_circle(_hellcow_taint_x, _hellcow_taint_y, 20 * _radius_scale, false);
			}
		}
	}
	else
	{
		draw_set_color(_target_color);
		draw_set_alpha(target_selection_alpha);
		draw_circle(_mouse_x, _mouse_y, _draw_radius, false);
		draw_set_alpha(target_selection_outline_alpha);
		draw_circle(_mouse_x, _mouse_y, _draw_radius, true);
	}

	if (target_selection_projectile_type == PROJECTILE_TYPE.BUILDING_SHELL)
	{
		if (is_struct(_projectile_payload)
			&& variable_struct_exists(_projectile_payload, "building_object")
			&& _projectile_payload.building_object == o_grave_spire)
		{
			var _skeleton_count = grave_spire_morning_skeleton_count_preview(_mouse_world_x, _mouse_world_y);
			var _skeleton_word = (_skeleton_count == 1) ? "skeleton" : "skeletons";
			var _count_text = string(_skeleton_count) + " " + _skeleton_word + " every morning";

			var _grave_count = instance_number(o_grave);

			for (var _grave_index = 0; _grave_index < _grave_count; ++_grave_index)
			{
				var _grave = instance_find(o_grave, _grave_index);

				if (!instance_exists(_grave)
					|| point_distance(_mouse_world_x, _mouse_world_y, _grave.x, _grave.y) > BALANCE_GRAVE_SPIRE_RADIUS)
				{
					continue;
				}

				if (variable_instance_exists(_grave, "assigned_grave_spire")
					&& instance_exists(_grave.assigned_grave_spire))
				{
					continue;
				}

				var _grave_gui_x = ((_grave.x - _camera_x) / _camera_width) * camera_view_width;
				var _grave_gui_y = ((_grave.y - _camera_y) / _camera_height) * camera_view_height;
				var _grave_highlight_radius = 14;

				draw_set_alpha(0.82);
				draw_set_color(COLOR_PROJECTILE_DAMAGE);
				draw_line_width(_mouse_x, _mouse_y, _grave_gui_x, _grave_gui_y, 2);

				draw_set_alpha(0.18);
				draw_circle(_grave_gui_x, _grave_gui_y, _grave_highlight_radius, false);

				draw_set_alpha(0.95);
				draw_circle(_grave_gui_x, _grave_gui_y, _grave_highlight_radius, true);
			}

			draw_set_alpha(1);
			draw_set_halign(fa_center);
			draw_set_valign(fa_middle);
			var _count_padding_x = 8;
			var _count_padding_y = 5;
			var _count_width = string_width(_count_text) + (_count_padding_x * 2);
			var _count_height = string_height(_count_text) + (_count_padding_y * 2);

			draw_set_alpha(0.86);
			draw_set_color(COLOR_HUD_BACKGROUND);
			draw_rectangle(
				_mouse_x - (_count_width * 0.5),
				_mouse_y - (_count_height * 0.5),
				_mouse_x + (_count_width * 0.5),
				_mouse_y + (_count_height * 0.5),
				false
			);

			draw_set_alpha(1);
			draw_set_color(COLOR_PROJECTILE_SKELETONS);
			draw_text(_mouse_x, _mouse_y, _count_text);
		}
		else if (is_struct(_projectile_payload)
			&& variable_struct_exists(_projectile_payload, "building_object")
			&& _projectile_payload.building_object == o_ihor_extractor)
		{
			var _ihor_morning_income = ihor_extractor_morning_income_preview(_mouse_world_x, _mouse_world_y);
			var _speed_text = "Morning Ihor: +" + string(_ihor_morning_income);
			var _vein_count = instance_number(o_ihor_vein);
			var _preview_radius = building_shell_preview_radius_get(_projectile_payload);

			for (var _vein_index = 0; _vein_index < _vein_count; ++_vein_index)
			{
				var _vein = instance_find(o_ihor_vein, _vein_index);

				if (!instance_exists(_vein)
					|| !variable_instance_exists(_vein, "ihor_remaining")
					|| point_distance(_mouse_world_x, _mouse_world_y, _vein.x, _vein.y) > _preview_radius)
				{
					continue;
				}

				if (variable_instance_exists(_vein, "assigned_ihor_extractor")
					&& instance_exists(_vein.assigned_ihor_extractor))
				{
					continue;
				}

				var _vein_gui_x = ((_vein.x - _camera_x) / _camera_width) * camera_view_width;
				var _vein_gui_y = ((_vein.y - _camera_y) / _camera_height) * camera_view_height;
				var _vein_highlight_radius = 14;

				draw_set_alpha(0.82);
				draw_set_color(COLOR_IHOR_EXTRACTOR_RADIUS);
				draw_line_width(_mouse_x, _mouse_y, _vein_gui_x, _vein_gui_y, 2);

				draw_set_alpha(0.18);
				draw_circle(_vein_gui_x, _vein_gui_y, _vein_highlight_radius, false);

				draw_set_alpha(0.95);
				draw_circle(_vein_gui_x, _vein_gui_y, _vein_highlight_radius, true);
			}

			draw_set_alpha(1);
			draw_set_halign(fa_center);
			draw_set_valign(fa_middle);
			var _speed_padding_x = 8;
			var _speed_padding_y = 5;
			var _speed_width = string_width(_speed_text) + (_speed_padding_x * 2);
			var _speed_height = string_height(_speed_text) + (_speed_padding_y * 2);

			draw_set_alpha(0.86);
			draw_set_color(COLOR_HUD_BACKGROUND);
			draw_rectangle(
				_mouse_x - (_speed_width * 0.5),
				_mouse_y - (_speed_height * 0.5),
				_mouse_x + (_speed_width * 0.5),
				_mouse_y + (_speed_height * 0.5),
				false
			);

			draw_set_alpha(1);
			draw_set_color(COLOR_HUD_IHOR);
			draw_text(_mouse_x, _mouse_y, _speed_text);
		}
	}

	draw_set_halign(fa_left);
	draw_set_valign(fa_top);

	if (_target_hint_text != "")
	{
		var _hint_text = _target_hint_text;
		var _hint_padding_x = 10;
		var _hint_padding_y = 6;
		var _hint_x = min(_mouse_x + 18, camera_view_width - string_width(_hint_text) - (_hint_padding_x * 2) - 12);
		var _hint_y = max(12, _mouse_y - 42);
		var _hint_width = string_width(_hint_text) + (_hint_padding_x * 2);
		var _hint_height = 26;

		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		draw_set_alpha(0.92);
		draw_set_color(COLOR_HUD_BACKGROUND);
		draw_rectangle(_hint_x, _hint_y, _hint_x + _hint_width, _hint_y + _hint_height, false);
		draw_set_alpha(1);
		draw_set_color(_target_hint_color);
		draw_rectangle(_hint_x, _hint_y, _hint_x + _hint_width, _hint_y + _hint_height, true);
		draw_set_color(COLOR_HUD_TEXT);
		draw_text(_hint_x + _hint_padding_x, _hint_y + _hint_padding_y, _hint_text);
	}

	draw_set_color(c_white);
	draw_set_alpha(1);
}

// Draw cultist demon selection window.
if (global.focus_window == FOCUS_WINDOW.CULTIST_DEMON_SELECTION)
{
	var _cultist = get_current_cultist();
	var _design_width = 1024;
	var _design_height = 836;
	var _design_scale = min(camera_view_width / _design_width, camera_view_height / _design_height);
	var _panel_x = (camera_view_width - (_design_width * _design_scale)) * 0.5;
	var _panel_y = (camera_view_height - (_design_height * _design_scale)) * 0.5;
	var _mouse_x = device_mouse_x_to_gui(0);
	var _mouse_y = device_mouse_y_to_gui(0);
	var _name_text = string_copy(keyboard_string, 1, 16);
	var _preview_name = _name_text;
	var _ability_options = cultist_demon_active_abilities_get(cultist_selected_demon_type);
	var _ability_count = array_length(_ability_options);
	var _preview_ability = cultist_selected_starting_ability;
	var _preview_ability_is_valid = false;
	var _hovered_demon_type = DEMON_TYPE.NONE;
	var _hovered_ability = DEMON_ABILITY.NONE;

	for (var _ability_validate_index = 0; _ability_validate_index < _ability_count; ++_ability_validate_index)
	{
		if (_ability_options[_ability_validate_index] == _preview_ability)
		{
			_preview_ability_is_valid = true;
			break;
		}
	}

	if (!_preview_ability_is_valid && _ability_count > 0)
	{
		_preview_ability = _ability_options[0];
	}

	if (_preview_name == "" && instance_exists(_cultist))
	{
		_preview_name = "Cultist#" + string(cultist_selection_index + 1);
	}

	// Draw the full-screen dim and the black window backing.
	draw_set_alpha(0.55);
	draw_set_color(c_black);
	draw_rectangle(0, 0, camera_view_width, camera_view_height, false);

	draw_set_alpha(0.92);
	draw_set_color(c_black);
	draw_rectangle(
		_panel_x,
		_panel_y,
		_panel_x + (_design_width * _design_scale),
		_panel_y + (_design_height * _design_scale),
		false
	);

	draw_set_alpha(0.72);
	draw_set_color(COLOR_CULTIST_SELECTION_BACKGROUND);
	draw_rectangle(
		_panel_x,
		_panel_y,
		_panel_x + (_design_width * _design_scale),
		_panel_y + (_design_height * _design_scale),
		false
	);

	draw_set_alpha(1);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(COLOR_HUD_TEXT);
	if (variable_global_exists("ui_heading_font") && font_exists(global.ui_heading_font))
	{
		draw_set_font(global.ui_heading_font);
	}

	draw_text_transformed(
		_panel_x + (56 * _design_scale),
		_panel_y + (78 * _design_scale),
		"A NEW ARCHDEMON HAS BEEN SUMMONED!",
		1.18 * _design_scale,
		1.18 * _design_scale,
		0
	);

	if (variable_global_exists("ui_font") && font_exists(global.ui_font))
	{
		draw_set_font(global.ui_font);
	}

	// Draw name input.
	var _name_label_x = _panel_x + (58 * _design_scale);
	var _name_label_y = _panel_y + (180 * _design_scale);
	var _name_input_x = _panel_x + (58 * _design_scale);
	var _name_input_y = _panel_y + (210 * _design_scale);
	var _name_input_width = 360 * _design_scale;
	var _name_input_height = 58 * _design_scale;

	draw_set_color(COLOR_HUD_TEXT);
	draw_text_transformed(_name_label_x, _name_label_y, "Cultist name", 1.1 * _design_scale, 1.1 * _design_scale, 0);
	draw_set_alpha(0.45);
	draw_set_color(c_black);
	draw_rectangle(_name_input_x, _name_input_y, _name_input_x + _name_input_width, _name_input_y + _name_input_height, false);
	draw_set_alpha(1);
	draw_set_color(c_white);
	draw_rectangle(_name_input_x, _name_input_y, _name_input_x + _name_input_width, _name_input_y + _name_input_height, true);
	draw_set_color(COLOR_HUD_TEXT);
	draw_text_transformed(_name_input_x + (16 * _design_scale), _name_input_y + (17 * _design_scale), _name_text, 1.85 * _design_scale, 1.85 * _design_scale, 0);

	if ((current_time div 500) mod 2 == 0)
	{
		var _caret_x = _name_input_x + (16 * _design_scale) + (string_width(_name_text) * 1.85 * _design_scale);
		var _caret_y = _name_input_y + (12 * _design_scale);

		draw_set_color(COLOR_HUD_TEXT);
		draw_line(_caret_x + (2 * _design_scale), _caret_y, _caret_x + (2 * _design_scale), _caret_y + (36 * _design_scale));
	}

	// Draw cultist and selected demon preview.
	var _preview_y = _panel_y + (458 * _design_scale);

	if (instance_exists(_cultist) && sprite_exists(_cultist.sprite_index))
	{
		var _cultist_sprite = _cultist.sprite_index;
		var _cultist_frame_count = max(sprite_get_number(_cultist_sprite), 1);
		var _cultist_frame = (current_time div 160) mod _cultist_frame_count;
		var _cultist_scale = 0.82 * _design_scale;

		draw_sprite_ext(_cultist_sprite, _cultist_frame, _panel_x + (98 * _design_scale), _preview_y, _cultist_scale, _cultist_scale, 0, c_white, 1);
	}

	if (sprite_exists(s_attack_arrow))
	{
		var _arrow_sprite_width = max(1, sprite_get_width(s_attack_arrow));
		var _arrow_scale = (88 * _design_scale) / _arrow_sprite_width;
		var _arrow_x = _panel_x + (220 * _design_scale);
		var _arrow_y = _panel_y + (374 * _design_scale);

		draw_sprite_ext(s_attack_arrow, 0, _arrow_x, _arrow_y, _arrow_scale, _arrow_scale * 0.72, 0, COLOR_CULTIST_SELECTION_BODY, BALANCE_ATTACK_ARROW_ALPHA);
	}

	var _preview_object = cultist_demon_object_get(cultist_selected_demon_type);
	var _preview_sprite = object_get_sprite(_preview_object);

	if (_preview_sprite != -1 && sprite_exists(_preview_sprite))
	{
		var _preview_frame_count = max(sprite_get_number(_preview_sprite), 1);
		var _preview_frame = (current_time div 120) mod _preview_frame_count;
		var _preview_scale = 2.5 * _design_scale;

		draw_sprite_ext(_preview_sprite, _preview_frame, _panel_x + (375 * _design_scale), _preview_y + (2 * _design_scale), _preview_scale, _preview_scale, 0, c_white, 1);
	}

	// Draw the stat summary with skull pips.
	if (instance_exists(_cultist))
	{
		var _body_points = _cultist.cultist_points[CULTIST_STAT.BODY];
		var _spirit_points = _cultist.cultist_points[CULTIST_STAT.SPIRIT];
		var _fervor_points = _cultist.cultist_points[CULTIST_STAT.FERVOR];
		var _stat_names = ["Body", "Fervor", "Spirit"];
		var _stat_notes = [
			"HP, Armor, Damage, Crit damage",
			"Crit chance, Attack speed, Move speed",
			"Spells reload speed, Magic damage, EXP, Magic resistance"
		];
		var _stat_points = [_body_points, _fervor_points, _spirit_points];
		var _stat_colors = [
			COLOR_CULTIST_SELECTION_BODY,
			COLOR_CULTIST_SELECTION_IMP,
			COLOR_CULTIST_SELECTION_WARLOCK
		];
		var _stat_y_values = [292, 358, 420];

		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		draw_set_color(COLOR_HUD_TEXT);
		if (variable_global_exists("ui_heading_font") && font_exists(global.ui_heading_font))
		{
			draw_set_font(global.ui_heading_font);
		}

		draw_text_transformed(_panel_x + (578 * _design_scale), _panel_y + (240 * _design_scale), _preview_name, 0.88 * _design_scale, 0.88 * _design_scale, 0);

		if (variable_global_exists("ui_font") && font_exists(global.ui_font))
		{
			draw_set_font(global.ui_font);
		}

		for (var _stat_index = 0; _stat_index < CULTIST_STAT.COUNT; ++_stat_index)
		{
			var _stat_x = _panel_x + (578 * _design_scale);
			var _stat_y = _panel_y + (_stat_y_values[_stat_index] * _design_scale);
			var _stat_color = _stat_colors[_stat_index];

			draw_set_color(_stat_color);
			if (variable_global_exists("ui_heading_font") && font_exists(global.ui_heading_font))
			{
				draw_set_font(global.ui_heading_font);
			}

			draw_text_transformed(_stat_x, _stat_y, _stat_names[_stat_index], 0.9 * _design_scale, 0.9 * _design_scale, 0);

			if (variable_global_exists("ui_font") && font_exists(global.ui_font))
			{
				draw_set_font(global.ui_font);
			}

			for (var _point_index = 0; _point_index < _stat_points[_stat_index]; ++_point_index)
			{
				var _skull_x = _panel_x + ((704 + (32 * _point_index)) * _design_scale);
				var _skull_y = _panel_y + ((_stat_y_values[_stat_index] + 5) * _design_scale);
				var _skull_size = 27 * _design_scale;

				if (sprite_exists(s_ui_scull_white))
				{
					draw_sprite_stretched_ext(s_ui_scull_white, 0, _skull_x, _skull_y, _skull_size, _skull_size, _stat_color, 1);
				}
				else
				{
					draw_rectangle(_skull_x, _skull_y, _skull_x + _skull_size, _skull_y + _skull_size, false);
				}
			}

			draw_set_alpha(0.72);
			draw_set_color(_stat_color);
			draw_text_transformed(_stat_x, _stat_y + (34 * _design_scale), _stat_notes[_stat_index], 1.15 * _design_scale, 1.15 * _design_scale, 0);
			draw_set_alpha(1);
		}
	}

	// Draw demon possession buttons.
	var _button_start_x = _panel_x + (58 * _design_scale);
	var _button_y = _panel_y + (514 * _design_scale);
	var _button_step = (cultist_selection_button_width + cultist_selection_button_gap) * _design_scale;
	var _button_count = array_length(cultist_selection_buttons);

	draw_set_color(COLOR_HUD_TEXT);
	draw_text_transformed(_panel_x + (62 * _design_scale), _panel_y + (486 * _design_scale), "Choose demon possession", 1.12 * _design_scale, 1.12 * _design_scale, 0);

	for (var _button_index = 0; _button_index < _button_count; ++_button_index)
	{
		var _demon_type = cultist_selection_buttons[_button_index];
		var _button_x = _button_start_x + (_button_step * _button_index);
		var _button_width = cultist_selection_button_width * _design_scale;
		var _button_height = cultist_selection_button_height * _design_scale;
		var _is_selected = _demon_type == cultist_selected_demon_type;
		var _is_hovered = _mouse_x >= _button_x && _mouse_x <= _button_x + _button_width
			&& _mouse_y >= _button_y && _mouse_y <= _button_y + _button_height;
		var _button_color = COLOR_CULTIST_SELECTION_BRUTE;

		if (_is_hovered)
		{
			_hovered_demon_type = _demon_type;
		}

		if (_demon_type == DEMON_TYPE.IMP)
		{
			_button_color = COLOR_CULTIST_SELECTION_IMP;
		}
		else if (_demon_type == DEMON_TYPE.WARLOCK)
		{
			_button_color = COLOR_CULTIST_SELECTION_WARLOCK;
		}

		draw_set_alpha(_is_hovered ? 1 : 0.94);
		draw_set_color(_button_color);
		draw_rectangle(_button_x, _button_y, _button_x + _button_width, _button_y + _button_height, false);
		draw_set_alpha(1);

		if (_is_selected)
		{
			draw_set_color(c_white);
			draw_rectangle(
				_button_x - (5 * _design_scale),
				_button_y - (5 * _design_scale),
				_button_x + _button_width + (5 * _design_scale),
				_button_y + _button_height + (5 * _design_scale),
				true
			);
		}

		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		draw_set_color(COLOR_HUD_TEXT);
		draw_text_transformed(_button_x + (_button_width * 0.5), _button_y + (_button_height * 0.5), cultist_demon_name_get(_demon_type), 1.12 * _design_scale, 1.12 * _design_scale, 0);
	}

	// Draw starting ability buttons.
	var _ability_button_x = _panel_x + (58 * _design_scale);
	var _ability_button_y = _panel_y + (650 * _design_scale);
	var _ability_button_width = cultist_ability_selection_button_width * _design_scale;
	var _ability_button_height = cultist_ability_selection_button_height * _design_scale;
	var _ability_button_color = COLOR_CULTIST_SELECTION_BRUTE;

	if (cultist_selected_demon_type == DEMON_TYPE.IMP)
	{
		_ability_button_color = COLOR_CULTIST_SELECTION_IMP;
	}
	else if (cultist_selected_demon_type == DEMON_TYPE.WARLOCK)
	{
		_ability_button_color = COLOR_CULTIST_SELECTION_WARLOCK;
	}

	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(COLOR_HUD_TEXT);
	draw_text_transformed(_panel_x + (62 * _design_scale), _panel_y + (614 * _design_scale), "Choose demon skill", 1.12 * _design_scale, 1.12 * _design_scale, 0);

	for (var _ability_index = 0; _ability_index < _ability_count; ++_ability_index)
	{
		var _ability = _ability_options[_ability_index];
		var _current_ability_x = _ability_button_x + ((_ability_button_width + (27 * _design_scale)) * _ability_index);
		var _is_selected_ability = _ability == _preview_ability;
		var _is_hovered_ability = _mouse_x >= _current_ability_x && _mouse_x <= _current_ability_x + _ability_button_width
			&& _mouse_y >= _ability_button_y && _mouse_y <= _ability_button_y + _ability_button_height;

		if (_is_hovered_ability)
		{
			_hovered_ability = _ability;
		}

		draw_set_alpha(_is_hovered_ability ? 1 : 0.94);
		draw_set_color(_ability_button_color);
		draw_rectangle(_current_ability_x, _ability_button_y, _current_ability_x + _ability_button_width, _ability_button_y + _ability_button_height, false);
		draw_set_alpha(1);

		if (_is_selected_ability)
		{
			draw_set_color(c_white);
			draw_rectangle(
				_current_ability_x - (5 * _design_scale),
				_ability_button_y - (5 * _design_scale),
				_current_ability_x + _ability_button_width + (5 * _design_scale),
				_ability_button_y + _ability_button_height + (5 * _design_scale),
				true
			);
		}

		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		draw_set_color(COLOR_HUD_TEXT);
		draw_text_transformed(_current_ability_x + (_ability_button_width * 0.5), _ability_button_y + (_ability_button_height * 0.5), cultist_ability_name_get(_ability), 1.05 * _design_scale, 1.05 * _design_scale, 0);
	}

	// Draw confirm button.
	var _confirm_x = _panel_x + (56 * _design_scale);
	var _confirm_y = _panel_y + (763 * _design_scale);
	var _confirm_width = 219 * _design_scale;
	var _confirm_height = 64 * _design_scale;
	var _confirm_hovered = _mouse_x >= _confirm_x && _mouse_x <= _confirm_x + _confirm_width
		&& _mouse_y >= _confirm_y && _mouse_y <= _confirm_y + _confirm_height;

	draw_set_alpha(_confirm_hovered ? 1 : 0.92);
	draw_set_color(c_black);
	draw_rectangle(_confirm_x, _confirm_y, _confirm_x + _confirm_width, _confirm_y + _confirm_height, false);
	draw_set_alpha(1);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_set_color(COLOR_HUD_TEXT);
	draw_text_transformed(_confirm_x + (_confirm_width * 0.5), _confirm_y + (_confirm_height * 0.5), "CONFIRM", 1.12 * _design_scale, 1.12 * _design_scale, 0);

	// Draw hover descriptions above the selection window.
	if (_hovered_demon_type != DEMON_TYPE.NONE || _hovered_ability != DEMON_ABILITY.NONE)
	{
		var _tooltip_width = 430 * _design_scale;
		var _tooltip_height = 310 * _design_scale;
		var _tooltip_padding = 14 * _design_scale;
		var _tooltip_x = min(_mouse_x + (18 * _design_scale), camera_view_width - _tooltip_width - (14 * _design_scale));
		var _tooltip_y = min(_mouse_y + (18 * _design_scale), camera_view_height - _tooltip_height - (14 * _design_scale));

		if (_hovered_ability != DEMON_ABILITY.NONE)
		{
			_tooltip_height = 150 * _design_scale;
			_tooltip_y = min(_mouse_y + (18 * _design_scale), camera_view_height - _tooltip_height - (14 * _design_scale));
		}

		draw_set_alpha(0.96);
		draw_set_color(c_black);
		draw_rectangle(_tooltip_x, _tooltip_y, _tooltip_x + _tooltip_width, _tooltip_y + _tooltip_height, false);
		draw_set_alpha(1);
		draw_set_color(c_white);
		draw_rectangle(_tooltip_x, _tooltip_y, _tooltip_x + _tooltip_width, _tooltip_y + _tooltip_height, true);

		draw_set_halign(fa_left);
		draw_set_valign(fa_top);

		if (_hovered_ability != DEMON_ABILITY.NONE)
		{
			draw_set_color(COLOR_HUD_TEXT);
			draw_text_transformed(
				_tooltip_x + _tooltip_padding,
				_tooltip_y + _tooltip_padding,
				cultist_ability_name_get(_hovered_ability),
				1.25 * _design_scale,
				1.25 * _design_scale,
				0
			);

			draw_set_color(COLOR_HUD_PROJECTILE_DESCRIPTION);
			draw_text_ext(
				_tooltip_x + _tooltip_padding,
				_tooltip_y + (48 * _design_scale),
				cultist_ability_description_get(_hovered_ability),
				18 * _design_scale,
				_tooltip_width - (_tooltip_padding * 2)
			);
		}
		else
		{
			draw_set_color(COLOR_HUD_TEXT);
			draw_text_transformed(
				_tooltip_x + _tooltip_padding,
				_tooltip_y + _tooltip_padding,
				cultist_demon_name_get(_hovered_demon_type),
				1.25 * _design_scale,
				1.25 * _design_scale,
				0
			);

			draw_set_color(COLOR_HUD_PROJECTILE_DESCRIPTION);
			draw_text_ext(
				_tooltip_x + _tooltip_padding,
				_tooltip_y + (46 * _design_scale),
				cultist_demon_description_get(_hovered_demon_type),
				18 * _design_scale,
				_tooltip_width - (_tooltip_padding * 2)
			);

			draw_set_color(COLOR_HUD_TEXT);
			draw_text(_tooltip_x + _tooltip_padding, _tooltip_y + (82 * _design_scale), "Stats");

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
				"Crit damage",
				"Crit chance",
				"Attack speed",
				"Move speed",
				"Ability Recharge",
				"Exp",
				"Magic power",
				"Magic resistance"
			];
			var _stat_base_values = [
				_hover_stats.hp,
				_hover_stats.armor,
				_hover_stats.damage,
				_hover_stats.crit_damage,
				_hover_stats.crit_chance,
				_hover_stats.attack_speed,
				_hover_stats.move_speed,
				_hover_stats.abilities_cd_spd,
				_hover_stats.exp_effectiveness,
				_hover_stats.magic_effectiveness,
				min(_hover_stats.resistance - 100, 90)
			];
			var _stat_bonuses = [
				_hover_stats.hp * (_hover_body * BALANCE_CULTIST_BODY_STAT_BONUS),
				_hover_stats.armor * (_hover_body * BALANCE_CULTIST_BODY_STAT_BONUS),
				_hover_stats.damage * (_hover_body * BALANCE_CULTIST_BODY_STAT_BONUS),
				_hover_body * BALANCE_CULTIST_CRIT_DAMAGE_PER_BODY,
				_hover_stats.crit_chance * (_hover_fervor * BALANCE_CULTIST_CRIT_CHANCE_STAT_BONUS),
				_hover_stats.attack_speed * (_hover_fervor * BALANCE_CULTIST_FERVOR_STAT_BONUS),
				_hover_stats.move_speed * (_hover_fervor * BALANCE_CULTIST_FERVOR_STAT_BONUS),
				_hover_stats.abilities_cd_spd * (_hover_spirit * BALANCE_CULTIST_SPIRIT_STAT_BONUS),
				_hover_stats.exp_effectiveness * (_hover_spirit * BALANCE_CULTIST_SPIRIT_STAT_BONUS),
				_hover_stats.magic_effectiveness * (_hover_spirit * BALANCE_CULTIST_SPIRIT_STAT_BONUS),
				_hover_stats.resistance * (_hover_spirit * BALANCE_CULTIST_SPIRIT_STAT_BONUS)
			];
			var _stat_colors = [
				COLOR_CULTIST_SELECTION_BODY,
				COLOR_CULTIST_SELECTION_BODY,
				COLOR_CULTIST_SELECTION_BODY,
				COLOR_CULTIST_SELECTION_BODY,
				COLOR_CULTIST_SELECTION_IMP,
				COLOR_CULTIST_SELECTION_IMP,
				COLOR_CULTIST_SELECTION_IMP,
				COLOR_CULTIST_SELECTION_WARLOCK,
				COLOR_CULTIST_SELECTION_WARLOCK,
				COLOR_CULTIST_SELECTION_WARLOCK,
				COLOR_CULTIST_SELECTION_WARLOCK
			];

			if (_hover_stats.magic_damage > 0)
			{
				_stat_labels[2] = "Magic damage";
				_stat_base_values[2] = _hover_stats.magic_damage;
				_stat_bonuses[2] = _hover_stats.magic_damage * (_hover_spirit * BALANCE_CULTIST_MAGIC_DAMAGE_STAT_BONUS);
				_stat_colors[2] = COLOR_CULTIST_SELECTION_WARLOCK;
			}

			var _stat_count = array_length(_stat_labels);
			var _stat_line_height = 16 * _design_scale;
			var _stat_value_x = _tooltip_x + _tooltip_padding;
			var _stat_bonus_gap = 6 * _design_scale;

			for (var _hover_stat_index = 0; _hover_stat_index < _stat_count; ++_hover_stat_index)
			{
				var _stat_y = _tooltip_y + (110 * _design_scale) + (_stat_line_height * _hover_stat_index);
				var _base_value = _stat_base_values[_hover_stat_index];
				var _bonus_value = _stat_bonuses[_hover_stat_index];
				var _final_value = _base_value + _bonus_value;
				var _line_text = _stat_labels[_hover_stat_index] + ": " + string_format(_final_value, 0, 2);
				var _bonus_text = " (+" + string_format(_bonus_value, 0, 2) + ")";

				if (_hover_stat_index == 4)
				{
					_line_text = _stat_labels[_hover_stat_index] + ": " + string_format(_final_value * 100, 0, 1) + "%";
					_bonus_text = " (+" + string_format(_bonus_value * 100, 0, 1) + "%)";
				}
				else if (_hover_stat_index == 3)
				{
					_line_text = _stat_labels[_hover_stat_index] + ": x" + string_format(_final_value, 0, 2);
					_bonus_text = " (+x" + string_format(_bonus_value, 0, 2) + ")";
				}
				else if (_hover_stat_index == 1)
				{
					_line_text = _stat_labels[_hover_stat_index] + ": " + string_format(_final_value - 100, 0, 1) + "%";
					_bonus_text = " (+" + string_format(_bonus_value, 0, 1) + "%)";
				}

				draw_set_color(_stat_colors[_hover_stat_index]);
				draw_text(_stat_value_x, _stat_y, _line_text);
				draw_set_color(COLOR_HEALTH_BAR);
				draw_text(_stat_value_x + string_width(_line_text) + _stat_bonus_gap, _stat_y, _bonus_text);
			}

			if (_hover_stats.aoe_radius > 0)
			{
				draw_set_color(COLOR_HUD_PROJECTILE_DESCRIPTION);
				draw_text(_stat_value_x, _tooltip_y + (110 * _design_scale) + (_stat_line_height * _stat_count), "Aoe radius: " + string(_hover_stats.aoe_radius));
			}
		}
	}

	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
	draw_set_alpha(1);

	if (!global.blood_moon_reward_popup_active)
	{
		exit;
	}
}

// Draw cultist demon selection window.
if (global.focus_window == FOCUS_WINDOW.CULTIST_DEMON_SELECTION)
{
	var _cultist = get_current_cultist();
	var _panel_width = cultist_demon_selection_panel_width;
	var _panel_x = (camera_view_width - _panel_width) * 0.5;
	var _panel_y = (camera_view_height - cultist_panel_height) * 0.5;
	var _button_start_x = _panel_x + 70;
	var _button_y = _panel_y + 360;
	var _button_step = cultist_selection_button_width + cultist_selection_button_gap;
	var _name_text = string_copy(keyboard_string, 1, 16);
	var _mouse_x = device_mouse_x_to_gui(0);
	var _mouse_y = device_mouse_y_to_gui(0);
	var _hovered_demon_type = DEMON_TYPE.NONE;
	var _ability_options = cultist_demon_active_abilities_get(cultist_selected_demon_type);
	var _ability_count = array_length(_ability_options);
	var _preview_ability = cultist_selected_starting_ability;
	var _preview_ability_is_valid = false;

	for (var _ability_validate_index = 0; _ability_validate_index < _ability_count; ++_ability_validate_index)
	{
		if (_ability_options[_ability_validate_index] == _preview_ability)
		{
			_preview_ability_is_valid = true;
			break;
		}
	}

	if (!_preview_ability_is_valid && _ability_count > 0)
	{
		_preview_ability = _ability_options[0];
	}

	draw_set_alpha(0.55);
	draw_set_color(c_black);
	draw_rectangle(0, 0, camera_view_width, camera_view_height, false);

	draw_set_alpha(1);
	draw_set_color(COLOR_HUD_BACKGROUND);
	draw_rectangle(_panel_x, _panel_y, _panel_x + _panel_width, _panel_y + cultist_panel_height, false);
	draw_set_color(c_white);
	draw_rectangle(_panel_x, _panel_y, _panel_x + _panel_width, _panel_y + cultist_panel_height, true);

	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_set_color(COLOR_CULTIST_FERVOR);
	if (variable_global_exists("ui_heading_font") && font_exists(global.ui_heading_font))
	{
		draw_set_font(global.ui_heading_font);
	}

	draw_text(_panel_x + (_panel_width * 0.5), _panel_y + 34, "A NEW ARCHDEMON HAS BEEN SUMMONED!");

	if (variable_global_exists("ui_font") && font_exists(global.ui_font))
	{
		draw_set_font(global.ui_font);
	}

	draw_set_color(COLOR_HUD_TEXT);
	draw_text(_panel_x + (_panel_width * 0.5), _panel_y + 72, "Choose Cultist Demon Form");

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
		var _stat_notes = ["HP, Armor, Physical damage", "Crit chance, Attack, Ability Recharge", "Exp, Magic damage, Magic power, Magic resistance"];
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
		var _cultist_preview_sprite = -1;

		if (instance_exists(_cultist))
		{
			_cultist_preview_sprite = _cultist.sprite_index;
		}

		var _cultist_preview_x = _panel_x + 530;
		var _preview_x = _panel_x + 720;
		var _preview_y = _panel_y + 332;
		var _preview_scale = 2.2;
		var _preview_frame_count = max(sprite_get_number(_preview_sprite), 1);
		var _preview_frame = (current_time div 120) mod _preview_frame_count;

		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		draw_set_color(COLOR_HUD_TEXT);
		draw_text(_preview_x, _panel_y + 102, _preview_name);
		draw_set_color(COLOR_HUD_PROJECTILE_DESCRIPTION);
		draw_text(_preview_x, _panel_y + 128, "Ability: " + cultist_ability_name_get(_preview_ability));

		if (_cultist_preview_sprite != -1)
		{
			var _cultist_preview_scale = 0.67;
			var _cultist_sprite_width = sprite_get_width(_cultist_preview_sprite);
			var _cultist_sprite_height = sprite_get_height(_cultist_preview_sprite);
			var _cultist_sprite_xoffset = sprite_get_xoffset(_cultist_preview_sprite);
			var _cultist_sprite_yoffset = sprite_get_yoffset(_cultist_preview_sprite);
			var _cultist_draw_x = _cultist_preview_x + ((_cultist_sprite_xoffset - (_cultist_sprite_width * 0.5)) * _cultist_preview_scale);
			var _cultist_draw_y = _preview_y + ((_cultist_sprite_yoffset - _cultist_sprite_height) * _cultist_preview_scale);
			var _cultist_frame_count = max(sprite_get_number(_cultist_preview_sprite), 1);
			var _cultist_frame = (current_time div 160) mod _cultist_frame_count;

			draw_sprite_ext(_cultist_preview_sprite, _cultist_frame, _cultist_draw_x, _cultist_draw_y, _cultist_preview_scale, _cultist_preview_scale, 0, c_white, 1);
		}

		var _preview_sprite_width = sprite_get_width(_preview_sprite);
		var _preview_sprite_height = sprite_get_height(_preview_sprite);
		var _preview_sprite_xoffset = sprite_get_xoffset(_preview_sprite);
		var _preview_sprite_yoffset = sprite_get_yoffset(_preview_sprite);
		var _preview_draw_x = _preview_x + ((_preview_sprite_xoffset - (_preview_sprite_width * 0.5)) * _preview_scale);
		var _preview_draw_y = _preview_y + ((_preview_sprite_yoffset - _preview_sprite_height) * _preview_scale);

		draw_sprite_ext(_preview_sprite, _preview_frame, _preview_draw_x, _preview_draw_y, _preview_scale, _preview_scale, 0, c_white, 1);

		var _arrow_sprite_width = max(1, sprite_get_width(s_attack_arrow));
		var _arrow_x = _preview_x - 70;
		var _arrow_scale = 72 / _arrow_sprite_width;

		draw_sprite_ext(s_attack_arrow, 0, _arrow_x, _preview_y - 50, _arrow_scale, _arrow_scale * 0.42, 0, c_white, BALANCE_ATTACK_ARROW_ALPHA);
	}

	var _ability_button_x = _panel_x + _panel_width - 300;
	var _ability_button_y = _panel_y + 154;

	draw_set_halign(fa_left);
	draw_set_color(COLOR_HUD_TEXT);
	draw_text(_ability_button_x, _panel_y + 136, "Starting ability");

	for (var _ability_index = 0; _ability_index < _ability_count; ++_ability_index)
	{
		var _ability = _ability_options[_ability_index];
		var _current_ability_y = _ability_button_y
			+ ((cultist_ability_selection_button_height + cultist_ability_selection_button_gap) * _ability_index);
		var _is_selected_ability = _ability == _preview_ability;
		var _is_hovered_ability = _mouse_x >= _ability_button_x
			&& _mouse_x <= _ability_button_x + cultist_ability_selection_button_width
			&& _mouse_y >= _current_ability_y
			&& _mouse_y <= _current_ability_y + cultist_ability_selection_button_height;

		// Draw the three starting ability options for the selected demon form.
		if (_is_selected_ability)
		{
			draw_set_color(COLOR_CULTIST_FERVOR);
			draw_rectangle(
				_ability_button_x,
				_current_ability_y,
				_ability_button_x + cultist_ability_selection_button_width,
				_current_ability_y + cultist_ability_selection_button_height,
				false
			);
			draw_set_color(c_white);
			draw_rectangle(
				_ability_button_x,
				_current_ability_y,
				_ability_button_x + cultist_ability_selection_button_width,
				_current_ability_y + cultist_ability_selection_button_height,
				true
			);
		}
		else
		{
			draw_set_color(c_black);
			draw_rectangle(
				_ability_button_x,
				_current_ability_y,
				_ability_button_x + cultist_ability_selection_button_width,
				_current_ability_y + cultist_ability_selection_button_height,
				false
			);
			draw_set_color(_is_hovered_ability ? COLOR_CULTIST_FERVOR : c_white);
			draw_rectangle(
				_ability_button_x,
				_current_ability_y,
				_ability_button_x + cultist_ability_selection_button_width,
				_current_ability_y + cultist_ability_selection_button_height,
				true
			);
		}

		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		draw_set_color(_is_selected_ability ? c_black : COLOR_HUD_TEXT);
		draw_text(
			_ability_button_x + (cultist_ability_selection_button_width * 0.5),
			_current_ability_y + (cultist_ability_selection_button_height * 0.5),
			cultist_ability_name_get(_ability)
		);
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

	var _confirm_x = _panel_x + _panel_width - 210;
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
		var _starting_ability = cultist_starting_ability_get(_cultist, _hovered_demon_type);

		if (_hovered_demon_type == cultist_selected_demon_type)
		{
			_starting_ability = _preview_ability;
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
			"Magic resistance"
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
			min(_hover_stats.resistance - 100, 90)
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
		draw_text(_ability_x, _hover_y + 70, "Starting Ability");
		draw_set_color(COLOR_HUD_PROJECTILE_DESCRIPTION);
		draw_text_ext(_ability_x, _hover_y + 94, cultist_demon_owned_abilities_text_get(_hovered_demon_type, _starting_ability), 16, _hover_width - 300);
	}

	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
	draw_set_alpha(1);

	if (!global.blood_moon_reward_popup_active)
	{
		exit;
	}
}

// Draw cultist level-up window.
if (global.focus_window == FOCUS_WINDOW.CULTIST_LEVEL_UP)
{
	var _cultist = noone;

	if (cultist_levelup_index >= 0 && cultist_levelup_index < array_length(global.archdemons))
	{
		_cultist = global.archdemons[cultist_levelup_index];
	}

	var _panel_width = cultist_panel_width;
	var _panel_height = 660;
	var _panel_x = (camera_view_width - _panel_width) * 0.5;
	var _panel_y = (camera_view_height - _panel_height) * 0.5;
	var _button_width = 150;
	var _button_height = 44;
	var _button_gap = 18;
	var _button_start_x = _panel_x + 92;
	var _attribute_button_y = _panel_y + 486;
	var _ability_button_y = _panel_y + 560;
	var _confirm_width = 210;
	var _confirm_height = 42;
	var _confirm_x = _panel_x + ((_panel_width - _confirm_width) * 0.5);
	var _confirm_y = _panel_y + 612;
	var _stat_names = ["Body", "Spirit", "Fervor"];
	var _attribute_stat_order = [CULTIST_STAT.BODY, CULTIST_STAT.FERVOR, CULTIST_STAT.SPIRIT];
	var _mouse_x = device_mouse_x_to_gui(0);
	var _mouse_y = device_mouse_y_to_gui(0);
	var _hovered_stat = -1;
	var _hovered_ability_choice = -1;
	var _ability_reward_type = -1;
	var _has_attribute_choice = false;
	var _has_ability_choice = false;

	if (instance_exists(_cultist))
	{
		ensure_cultist_levelup_options(_cultist);
		_ability_reward_type = cultist_levelup_ability_reward_type_get(_cultist);
		_has_attribute_choice = cultist_levelup_has_attribute_choice(_cultist);
		_has_ability_choice = _ability_reward_type != -1;
	}

	// Detect button hover before drawing stats so bonuses can preview the next point.
	if (_has_attribute_choice)
	{
		var _attribute_stat_count = array_length(_attribute_stat_order);

		for (var _hover_stat_index = 0; _hover_stat_index < _attribute_stat_count; ++_hover_stat_index)
		{
			var _hover_button_x = _button_start_x + ((_button_width + _button_gap) * _hover_stat_index);
			var _is_button_hovered = _mouse_x >= _hover_button_x && _mouse_x <= _hover_button_x + _button_width
				&& _mouse_y >= _attribute_button_y && _mouse_y <= _attribute_button_y + _button_height;

			if (_is_button_hovered)
			{
				_hovered_stat = _attribute_stat_order[_hover_stat_index];
			}
		}
	}

	if (_has_ability_choice && instance_exists(_cultist))
	{
		var _ability_options = cultist_levelup_ability_options_get(_cultist, _ability_reward_type);

		for (var _hover_choice_index = 0; _hover_choice_index < array_length(_ability_options); ++_hover_choice_index)
		{
			var _hover_button_x = _button_start_x + ((_button_width + _button_gap) * _hover_choice_index);
			var _is_button_hovered = _mouse_x >= _hover_button_x && _mouse_x <= _hover_button_x + _button_width
				&& _mouse_y >= _ability_button_y && _mouse_y <= _ability_button_y + _button_height;

			if (_is_button_hovered)
			{
				_hovered_ability_choice = _hover_choice_index;
			}
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
	if (variable_global_exists("ui_heading_font") && font_exists(global.ui_heading_font))
	{
		draw_set_font(global.ui_heading_font);
	}

	draw_text(_panel_x + (_panel_width * 0.5), _panel_y + 40, "Level Up");

	if (variable_global_exists("ui_font") && font_exists(global.ui_font))
	{
		draw_set_font(global.ui_font);
	}

	if (instance_exists(_cultist))
	{
		var _display_name = _cultist.cultist_name;

		if (_display_name == "")
		{
			_display_name = "Cultist " + string(cultist_levelup_index + 1);
		}

		var _cultist_level = 1;
		var _pending_level_points = 0;
		var _pending_passive_choices = 0;
		var _pending_active_choices = 0;
		var _pending_ability_upgrade_choices = 0;

		if (variable_instance_exists(_cultist, "current_lvl"))
		{
			_cultist_level = _cultist.current_lvl;
		}

		if (variable_instance_exists(_cultist, "pending_level_points"))
		{
			_pending_level_points = _cultist.pending_level_points;
		}

		if (variable_instance_exists(_cultist, "pending_passive_choices"))
		{
			_pending_passive_choices = _cultist.pending_passive_choices;
		}

		if (variable_instance_exists(_cultist, "pending_active_choices"))
		{
			_pending_active_choices = _cultist.pending_active_choices;
		}

		if (variable_instance_exists(_cultist, "pending_ability_upgrade_choices"))
		{
			_pending_ability_upgrade_choices = _cultist.pending_ability_upgrade_choices;
		}

		if (variable_global_exists("ui_heading_font") && font_exists(global.ui_heading_font))
		{
			draw_set_font(global.ui_heading_font);
		}

		draw_text(_panel_x + (_panel_width * 0.5), _panel_y + 88, "LVL " + string(_cultist_level));

		if (variable_global_exists("ui_font") && font_exists(global.ui_font))
		{
			draw_set_font(global.ui_font);
		}

		draw_text(_panel_x + (_panel_width * 0.5), _panel_y + 132, _display_name);

		// Draw only the Archdemon form in the level-up window.
		var _preview_y = _panel_y + 122;
		var _demon_preview_x = _panel_x + _panel_width - 128;

		if (variable_instance_exists(_cultist, "demon_type") && _cultist.demon_type != DEMON_TYPE.NONE)
		{
			var _demon_object = cultist_demon_object_get(_cultist.demon_type);

			if (_demon_object != noone)
			{
				var _demon_preview_sprite = object_get_sprite(_demon_object);

				if (sprite_exists(_demon_preview_sprite))
				{
					var _demon_preview_scale = cultist_demon_level_scale_get(_cultist_level);

					draw_sprite_ext(
						_demon_preview_sprite,
						0,
						_demon_preview_x,
						_preview_y,
						_demon_preview_scale,
						_demon_preview_scale,
						0,
						c_white,
						1
					);
				}

				draw_set_color(COLOR_HUD_PROJECTILE_DESCRIPTION);
				draw_text(_demon_preview_x, _panel_y + 164, cultist_demon_name_get(_cultist.demon_type));
			}
		}

		draw_set_color(COLOR_HUD_TEXT);

		var _pending_text = "";

		if (_has_attribute_choice)
		{
			_pending_text = "Attribute points: " + string(_pending_level_points);
		}

		if (_ability_reward_type == CULTIST_LEVEL_REWARD.PASSIVE)
		{
			_pending_text += (_pending_text == "" ? "" : "   ") + "Passive choices: " + string(_pending_passive_choices);
		}
		else if (_ability_reward_type == CULTIST_LEVEL_REWARD.ACTIVE)
		{
			_pending_text += (_pending_text == "" ? "" : "   ") + "Active choices: " + string(_pending_active_choices);
		}
		else if (_ability_reward_type == CULTIST_LEVEL_REWARD.ABILITY_UPGRADE)
		{
			_pending_text += (_pending_text == "" ? "" : "   ") + "Ability upgrades: " + string(_pending_ability_upgrade_choices);
		}

		draw_text(_panel_x + (_panel_width * 0.5), _panel_y + 158, _pending_text);

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
			var _preview_stat = _hovered_stat;

			if (_preview_stat < 0 && cultist_levelup_selected_stat >= 0)
			{
				_preview_stat = cultist_levelup_selected_stat;
			}

			if (_preview_stat == CULTIST_STAT.BODY)
			{
				_preview_body_points++;
			}
			else if (_preview_stat == CULTIST_STAT.SPIRIT)
			{
				_preview_spirit_points++;
			}
			else if (_preview_stat == CULTIST_STAT.FERVOR)
			{
				_preview_fervor_points++;
			}

			var _hp_bonus = _base_stats.hp * (_preview_body_points * BALANCE_CULTIST_BODY_STAT_BONUS);
			var _armor_bonus = _base_stats.armor * (_preview_body_points * BALANCE_CULTIST_BODY_STAT_BONUS);
			var _damage_bonus = _base_stats.damage * (_preview_body_points * BALANCE_CULTIST_BODY_STAT_BONUS);
			var _magic_damage_bonus = _base_stats.magic_damage * (_preview_spirit_points * BALANCE_CULTIST_MAGIC_DAMAGE_STAT_BONUS);
			var _crit_damage_bonus = _preview_body_points * BALANCE_CULTIST_CRIT_DAMAGE_PER_BODY;
			var _crit_bonus = _base_stats.crit_chance * (_preview_fervor_points * BALANCE_CULTIST_CRIT_CHANCE_STAT_BONUS);
			var _attack_speed_bonus = _base_stats.attack_speed * (_preview_fervor_points * BALANCE_CULTIST_FERVOR_STAT_BONUS);
			var _move_speed_bonus = _base_stats.move_speed * (_preview_fervor_points * BALANCE_CULTIST_FERVOR_STAT_BONUS);
			var _cooldown_bonus = _base_stats.abilities_cd_spd * (_preview_spirit_points * BALANCE_CULTIST_SPIRIT_STAT_BONUS);
			var _exp_bonus = _base_stats.exp_effectiveness * (_preview_spirit_points * BALANCE_CULTIST_SPIRIT_STAT_BONUS);
			var _magic_bonus = _base_stats.magic_effectiveness * (_preview_spirit_points * BALANCE_CULTIST_SPIRIT_STAT_BONUS);
			var _resistance_bonus = _base_stats.resistance * (_preview_spirit_points * BALANCE_CULTIST_SPIRIT_STAT_BONUS);
			var _hp_text = "HP: " + string_format(_demon_stats.hp, 0, 1);

			if (variable_instance_exists(_cultist, "hp"))
			{
				_hp_text = "HP: " + string_format(_cultist.hp, 0, 1) + " / " + string_format(_cultist.max_hp, 0, 1);
			}

			draw_set_halign(fa_left);
			draw_set_valign(fa_top);

			draw_set_color(COLOR_HUD_TEXT);
			draw_text(_stats_left_x, _panel_y + 184, "Demon: " + cultist_demon_name_get(_cultist.demon_type));

			// Draw current attribute points as compact square rows.
			var _square_start_x = _stats_right_x + 72;
			var _square_y = _panel_y + 182;
			var _square_size = 8;
			var _square_gap = 4;
			var _attribute_names = ["Body", "Spirit", "Fervor"];
			var _attribute_points = [_body_points, _spirit_points, _fervor_points];
			var _attribute_colors = [COLOR_CULTIST_BODY, COLOR_CULTIST_SPIRIT, COLOR_CULTIST_FERVOR];
			var _attribute_count = array_length(_attribute_stat_order);

			for (var _attribute_index = 0; _attribute_index < _attribute_count; ++_attribute_index)
			{
				var _attribute_stat = _attribute_stat_order[_attribute_index];
				var _row_y = _square_y + (_attribute_index * 18);

				draw_set_color(_attribute_colors[_attribute_stat]);
				draw_text(_stats_right_x, _row_y - 3, _attribute_names[_attribute_stat]);

				for (var _point_index = 0; _point_index < _attribute_points[_attribute_stat]; ++_point_index)
				{
					var _square_x = _square_start_x + ((_square_size + _square_gap) * _point_index);
					draw_rectangle(_square_x, _row_y, _square_x + _square_size, _row_y + _square_size, false);
				}

				if (_preview_stat == _attribute_stat)
				{
					var _preview_square_x = _square_start_x + ((_square_size + _square_gap) * _attribute_points[_attribute_stat]);
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

			_stat_text = "Crit damage: x" + string_format(_demon_stats.crit_damage, 0, 2);
			draw_set_color(COLOR_CULTIST_BODY);
			draw_text(_stats_left_x, _stats_y + (_line_height * 3), _stat_text);
			draw_set_color(COLOR_HEALTH_BAR);
			draw_text(_stats_left_x + string_width(_stat_text), _stats_y + (_line_height * 3), " (+x" + string_format(_crit_damage_bonus, 0, 2) + ")");

			_stat_text = "Crit chance: " + string_format(_demon_stats.crit_chance * 100, 0, 1) + "%";
			draw_set_color(COLOR_CULTIST_FERVOR);
			draw_text(_stats_left_x, _stats_y + (_line_height * 4), _stat_text);
			draw_set_color(COLOR_HEALTH_BAR);
			draw_text(_stats_left_x + string_width(_stat_text), _stats_y + (_line_height * 4), " (+" + string_format(_crit_bonus * 100, 0, 1) + "%)");

			_stat_text = "Attack speed: " + string_format(_demon_stats.attack_speed, 0, 2);
			draw_set_color(COLOR_CULTIST_FERVOR);
			draw_text(_stats_left_x, _stats_y + (_line_height * 5), _stat_text);
			draw_set_color(COLOR_HEALTH_BAR);
			draw_text(_stats_left_x + string_width(_stat_text), _stats_y + (_line_height * 5), " (+" + string_format(_attack_speed_bonus, 0, 2) + ")");

			_stat_text = "Move speed: " + string_format(_demon_stats.move_speed, 0, 2);
			draw_set_color(COLOR_CULTIST_FERVOR);
			draw_text(_stats_left_x, _stats_y + (_line_height * 6), _stat_text);
			draw_set_color(COLOR_HEALTH_BAR);
			draw_text(_stats_left_x + string_width(_stat_text), _stats_y + (_line_height * 6), " (+" + string_format(_move_speed_bonus, 0, 2) + ")");

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

			_stat_text = "Magic resistance: " + string_format(_demon_stats.magic_resistance - 100, 0, 1) + "%";
			draw_set_color(COLOR_CULTIST_SPIRIT);
			draw_text(_stats_right_x, _stats_y + (_line_height * 2), _stat_text);
			draw_set_color(COLOR_HEALTH_BAR);
			draw_text(_stats_right_x + string_width(_stat_text), _stats_y + (_line_height * 2), " (+" + string_format(_resistance_bonus, 0, 1) + "%)");

			_stat_text = "Ability Recharge: " + string_format(_demon_stats.abilities_cd_spd, 0, 2);
			draw_set_color(COLOR_CULTIST_SPIRIT);
			draw_text(_stats_right_x, _stats_y + (_line_height * 3), _stat_text);
			draw_set_color(COLOR_HEALTH_BAR);
			draw_text(_stats_right_x + string_width(_stat_text), _stats_y + (_line_height * 3), " (+" + string_format(_cooldown_bonus, 0, 2) + ")");

			if (_demon_stats.aoe_radius > 0)
			{
				draw_set_color(COLOR_HUD_TEXT);
				draw_text(_stats_right_x, _stats_y + (_line_height * 4), "Aoe radius: " + string(_demon_stats.aoe_radius));
			}

			// Draw owned passive and active abilities below the stat block.
			var _passive_list_x = _stats_left_x;
			var _active_list_x = _stats_right_x;
			var _ability_list_y = _stats_y + (_line_height * 6) + 18;
			var _ability_line_height = 18;
			var _passive_line_index = 0;
			var _active_line_index = 0;
			var _passive_abilities = cultist_demon_passive_abilities_get(_cultist.demon_type);
			var _has_passive = false;

			cultist_active_abilities_ensure(_cultist);
			draw_set_color(COLOR_CULTIST_SPIRIT);
			draw_text(_passive_list_x, _ability_list_y, "Passive abilities");
			_passive_line_index++;

			for (var _passive_index = 0; _passive_index < array_length(_passive_abilities); ++_passive_index)
			{
				var _passive_ability = _passive_abilities[_passive_index];

				if (cultist_passive_ability_has(_cultist, _passive_ability))
				{
					draw_set_color(COLOR_HUD_PROJECTILE_DESCRIPTION);
					draw_text(
						_passive_list_x,
						_ability_list_y + (_ability_line_height * _passive_line_index),
						"- " + cultist_ability_name_get(_passive_ability) + " Lv." + string(cultist_ability_level_get(_cultist, _passive_ability))
					);
					_passive_line_index++;
					_has_passive = true;
				}
			}

			if (!_has_passive)
			{
				draw_set_color(COLOR_HUD_PROJECTILE_DESCRIPTION);
				draw_text(_passive_list_x, _ability_list_y + (_ability_line_height * _passive_line_index), "- None");
				_passive_line_index++;
			}

			draw_set_color(COLOR_CULTIST_FERVOR);
			draw_text(_active_list_x, _ability_list_y, "Active abilities");
			_active_line_index++;

			for (var _active_index = 0; _active_index < array_length(_cultist.active_abilities); ++_active_index)
			{
				var _active_ability = _cultist.active_abilities[_active_index];

				draw_set_color(COLOR_HUD_PROJECTILE_DESCRIPTION);
				draw_text(
					_active_list_x,
					_ability_list_y + (_ability_line_height * _active_line_index),
					"- " + cultist_ability_name_get(_active_ability) + " Lv." + string(cultist_ability_level_get(_cultist, _active_ability))
				);
				_active_line_index++;
			}
		}
	}

	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_set_color(COLOR_HUD_TEXT);

	var _levelup_stat_colors = [COLOR_CULTIST_BODY, COLOR_CULTIST_SPIRIT, COLOR_CULTIST_FERVOR];

	if (_has_attribute_choice)
	{
		draw_text(_panel_x + (_panel_width * 0.5), _attribute_button_y - 24, "Choose one attribute point");

		var _attribute_button_count = array_length(_attribute_stat_order);

		for (var _stat_index = 0; _stat_index < _attribute_button_count; ++_stat_index)
		{
			var _button_stat = _attribute_stat_order[_stat_index];
			var _button_x = _button_start_x + ((_button_width + _button_gap) * _stat_index);
			var _is_hovered = _mouse_x >= _button_x && _mouse_x <= _button_x + _button_width
				&& _mouse_y >= _attribute_button_y && _mouse_y <= _attribute_button_y + _button_height;
			var _is_selected = cultist_levelup_selected_stat == _button_stat;

			if (_is_hovered)
			{
				_hovered_stat = _button_stat;
			}

			draw_set_halign(fa_center);
			draw_set_valign(fa_middle);
			draw_set_color(_is_selected ? _levelup_stat_colors[_button_stat] : c_white);
			draw_rectangle(_button_x, _attribute_button_y, _button_x + _button_width, _attribute_button_y + _button_height, true);
			draw_set_color(_levelup_stat_colors[_button_stat]);
			draw_text(_button_x + (_button_width * 0.5), _attribute_button_y + (_button_height * 0.5), _stat_names[_button_stat]);
		}
	}

	if (_has_ability_choice && instance_exists(_cultist))
	{
		var _ability_options = cultist_levelup_ability_options_get(_cultist, _ability_reward_type);
		var _ability_color = COLOR_CULTIST_SPIRIT;
		var _ability_header = "Choose one passive ability";

		if (_ability_reward_type == CULTIST_LEVEL_REWARD.ACTIVE)
		{
			_ability_color = COLOR_CULTIST_FERVOR;
			_ability_header = "Choose one active ability";
		}
		else if (_ability_reward_type == CULTIST_LEVEL_REWARD.ABILITY_UPGRADE)
		{
			_ability_color = COLOR_ABILITY_BAR;
			_ability_header = "Choose one ability upgrade";
		}

		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		draw_set_color(COLOR_HUD_TEXT);
		draw_text(_panel_x + (_panel_width * 0.5), _ability_button_y - 24, _ability_header);

		for (var _choice_index = 0; _choice_index < array_length(_ability_options); ++_choice_index)
		{
			var _button_x = _button_start_x + ((_button_width + _button_gap) * _choice_index);
			var _ability = _ability_options[_choice_index];
			var _button_text = cultist_ability_name_get(_ability);
			var _is_selected = cultist_levelup_selected_ability == _ability
				&& cultist_levelup_selected_reward_type == _ability_reward_type;

			if (_ability_reward_type == CULTIST_LEVEL_REWARD.ABILITY_UPGRADE)
			{
				_button_text += "\nLv." + string(cultist_ability_level_get(_cultist, _ability))
					+ " -> Lv." + string(min(4, cultist_ability_level_get(_cultist, _ability) + 1));
			}

			draw_set_halign(fa_center);
			draw_set_valign(fa_middle);
			draw_set_color(_is_selected ? _ability_color : c_white);
			draw_rectangle(_button_x, _ability_button_y, _button_x + _button_width, _ability_button_y + _button_height, true);
			draw_set_color(_ability_color);
			draw_set_halign(fa_left);
			draw_set_valign(fa_top);
			draw_text_ext(
				_button_x + 8,
				_ability_button_y + 10,
				_button_text,
				14,
				_button_width - 16
			);
		}
	}

	if (instance_exists(_cultist) && cultist_levelup_confirm_can_apply(_cultist))
	{
		var _is_confirm_hovered = _mouse_x >= _confirm_x && _mouse_x <= _confirm_x + _confirm_width
			&& _mouse_y >= _confirm_y && _mouse_y <= _confirm_y + _confirm_height;

		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		draw_set_color(_is_confirm_hovered ? COLOR_CULTIST_FERVOR : c_white);
		draw_rectangle(_confirm_x, _confirm_y, _confirm_x + _confirm_width, _confirm_y + _confirm_height, true);
		draw_set_color(COLOR_HUD_TEXT);
		draw_text(_confirm_x + (_confirm_width * 0.5), _confirm_y + (_confirm_height * 0.5), "Confirm");
	}

	if (_has_attribute_choice && _hovered_stat >= 0)
	{
		var _tooltip_width = 250;
		var _tooltip_height = 158;
		var _tooltip_x = min(_mouse_x + 18, camera_view_width - _tooltip_width - 18);
		var _tooltip_y = min(_mouse_y + 18, camera_view_height - _tooltip_height - 18);
		var _tooltip_text = "";

		if (instance_exists(_cultist) && variable_instance_exists(_cultist, "demon_type") && _cultist.demon_type != DEMON_TYPE.NONE)
		{
			var _base_stats = cultist_base_stats_get(_cultist.demon_type);

			if (_hovered_stat == CULTIST_STAT.BODY)
			{
				_tooltip_text = "Next point gives:"
					+ "\nHP +" + string_format(_base_stats.hp * BALANCE_CULTIST_BODY_STAT_BONUS, 0, 2)
					+ "\nArmor +" + string_format(_base_stats.armor * BALANCE_CULTIST_BODY_STAT_BONUS, 0, 1) + "%"
					+ "\nCrit damage +x" + string_format(BALANCE_CULTIST_CRIT_DAMAGE_PER_BODY, 0, 2);

				if (_base_stats.damage > 0)
				{
					_tooltip_text += "\nPhysical damage +" + string_format(_base_stats.damage * BALANCE_CULTIST_BODY_STAT_BONUS, 0, 2);
				}
			}
			else if (_hovered_stat == CULTIST_STAT.SPIRIT)
			{
				_tooltip_text = "Next point gives:"
					+ "\nAbility Recharge +" + string_format(_base_stats.abilities_cd_spd * BALANCE_CULTIST_SPIRIT_STAT_BONUS, 0, 2)
					+ "\nXP Gain +" + string_format(_base_stats.exp_effectiveness * BALANCE_CULTIST_SPIRIT_STAT_BONUS, 0, 2)
					+ "\nMagic power +" + string_format(_base_stats.magic_effectiveness * BALANCE_CULTIST_SPIRIT_STAT_BONUS, 0, 2)
					+ "\nMagic resistance +" + string_format(_base_stats.resistance * BALANCE_CULTIST_SPIRIT_STAT_BONUS, 0, 1) + "%";

				if (_base_stats.magic_damage > 0)
				{
					_tooltip_text += "\nMagic damage +" + string_format(_base_stats.magic_damage * BALANCE_CULTIST_MAGIC_DAMAGE_STAT_BONUS, 0, 2);
				}
			}
			else if (_hovered_stat == CULTIST_STAT.FERVOR)
			{
				_tooltip_text = "Next point gives:"
					+ "\nCrit chance +" + string_format(_base_stats.crit_chance * BALANCE_CULTIST_CRIT_CHANCE_STAT_BONUS * 100, 0, 1) + "%"
					+ "\nAttack speed +" + string_format(_base_stats.attack_speed * BALANCE_CULTIST_FERVOR_STAT_BONUS, 0, 2)
					+ "\nMove speed +" + string_format(_base_stats.move_speed * BALANCE_CULTIST_FERVOR_STAT_BONUS, 0, 2);
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
	else if (_has_ability_choice && _hovered_ability_choice >= 0 && instance_exists(_cultist))
	{
		var _ability_options = cultist_levelup_ability_options_get(_cultist, _ability_reward_type);

		if (_hovered_ability_choice < array_length(_ability_options))
		{
			var _ability = _ability_options[_hovered_ability_choice];
			var _tooltip_width = 300;
			var _tooltip_height = 118;
			var _tooltip_x = min(_mouse_x + 18, camera_view_width - _tooltip_width - 18);
			var _tooltip_y = min(_mouse_y + 18, camera_view_height - _tooltip_height - 18);

			draw_set_halign(fa_left);
			draw_set_valign(fa_top);
			draw_set_alpha(0.96);
			draw_set_color(COLOR_HUD_BACKGROUND);
			draw_rectangle(_tooltip_x, _tooltip_y, _tooltip_x + _tooltip_width, _tooltip_y + _tooltip_height, false);
			draw_set_alpha(1);
			draw_set_color(COLOR_CULTIST_FERVOR);
			draw_rectangle(_tooltip_x, _tooltip_y, _tooltip_x + _tooltip_width, _tooltip_y + _tooltip_height, true);
			draw_text(_tooltip_x + 12, _tooltip_y + 10, cultist_ability_name_get(_ability));
			draw_set_color(COLOR_HUD_TEXT);
			var _tooltip_description = cultist_ability_description_get(_ability);

			if (_ability_reward_type == CULTIST_LEVEL_REWARD.ABILITY_UPGRADE)
			{
				var _current_ability_level = cultist_ability_level_get(_cultist, _ability);
				var _target_ability_level = min(4, _current_ability_level + 1);
				_tooltip_description = "Lv." + string(_current_ability_level)
					+ " -> Lv." + string(_target_ability_level)
					+ "\n" + cultist_ability_upgrade_description_get(_ability, _target_ability_level);
			}

			draw_text_ext(_tooltip_x + 12, _tooltip_y + 34, _tooltip_description, 18, _tooltip_width - 24);
		}
	}

	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
	draw_set_alpha(1);

	if (!global.blood_moon_reward_popup_active)
	{
		exit;
	}
}

// Draw building construction window.
if (global.focus_window == FOCUS_WINDOW.BUILDING_CONSTRUCTION)
{
	var _panel_x = (camera_view_width - building_window_width) * 0.5;
	var _panel_y = (camera_view_height - building_window_height) * 0.5;
	var _mouse_x = device_mouse_x_to_gui(0);
	var _mouse_y = device_mouse_y_to_gui(0);
	var _close_size = 34;
	var _close_x = _panel_x + building_window_width - _close_size - 14;
	var _close_y = _panel_y + 14;
	var _grid_x = _panel_x + 44;
	var _is_foundry_window = instance_exists(building_window_foundry);
	var _daily_limit_reached = !_is_foundry_window
		&& !day_event_building_construction_can_start();
	var _grid_y = _panel_y + building_window_grid_y + (_is_foundry_window ? 112 : 0);
	var _foundry_current_x = _panel_x + 44;
	var _foundry_current_y = _panel_y + 118;
	var _foundry_current_width = building_window_width - 88;
	var _foundry_current_height = 78;
	var _hovered_foundry_current = _is_foundry_window
		&& instance_exists(building_window_foundry)
		&& is_struct(building_window_foundry.foundry_selected_shell)
		&& _mouse_x >= _foundry_current_x
		&& _mouse_x <= _foundry_current_x + _foundry_current_width
		&& _mouse_y >= _foundry_current_y
		&& _mouse_y <= _foundry_current_y + _foundry_current_height;
	var _choice_count = array_length(building_window_choices);
	var _hovered_choice = -1;
	var _construction_cultist_label = BALANCE_BUILDING_CONSTRUCTION_CULTIST_COST == 1
		? " Cultist"
		: " Cultists";
	var _construction_cultist_cost_text = string(BALANCE_BUILDING_CONSTRUCTION_CULTIST_COST)
		+ _construction_cultist_label;

	draw_set_alpha(0.55);
	draw_set_color(c_black);
	draw_rectangle(0, 0, camera_view_width, camera_view_height, false);

	draw_set_alpha(1);
	draw_set_color(COLOR_HUD_BACKGROUND);
	draw_rectangle(_panel_x, _panel_y, _panel_x + building_window_width, _panel_y + building_window_height, false);
	draw_set_color(c_white);
	draw_rectangle(_panel_x, _panel_y, _panel_x + building_window_width, _panel_y + building_window_height, true);

	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_set_color(COLOR_HUD_TEXT);
	if (variable_global_exists("ui_heading_font") && font_exists(global.ui_heading_font))
	{
		draw_set_font(global.ui_heading_font);
	}

	var _window_title = instance_exists(building_window_foundry) ? "Foundry" : "Construction";
	draw_text(_panel_x + (building_window_width * 0.5), _panel_y + 36, _window_title);

	if (variable_global_exists("ui_font") && font_exists(global.ui_font))
	{
		draw_set_font(global.ui_font);
	}

	if (_daily_limit_reached)
	{
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		draw_set_color(COLOR_STATUS_NEGATIVE_RED);
		draw_text(_panel_x + (building_window_width * 0.5), _panel_y + 76, "MAX 1 BUILDING PER DAY");
	}

	if (_is_foundry_window)
	{
		building_resource_summary_draw(_panel_x + (building_window_width * 0.5), _panel_y + building_window_resource_y);
	}

	draw_set_halign(fa_left);
	draw_set_color(COLOR_HUD_PROJECTILE_DESCRIPTION);
	if (instance_exists(building_window_foundry))
	{
		draw_text(_panel_x + 44, _panel_y + building_window_description_y, "Choose the structure shell this Foundry should produce");
	}

	if (_is_foundry_window)
	{
		draw_set_alpha(0.78);
		draw_set_color(c_black);
		draw_rectangle(_foundry_current_x, _foundry_current_y, _foundry_current_x + _foundry_current_width, _foundry_current_y + _foundry_current_height, false);

		draw_set_alpha(1);
		draw_set_color(_hovered_foundry_current ? COLOR_PROJECTILE_BUILDING_SHELL : COLOR_HUD_PROJECTILE_DESCRIPTION);
		draw_rectangle(_foundry_current_x, _foundry_current_y, _foundry_current_x + _foundry_current_width, _foundry_current_y + _foundry_current_height, true);

		draw_set_halign(fa_left);
		draw_set_valign(fa_middle);

		if (instance_exists(building_window_foundry)
			&& is_struct(building_window_foundry.foundry_selected_shell))
		{
			var _current_shell = building_window_foundry.foundry_selected_shell;
			var _progress = clamp(building_window_foundry.foundry_shell_progress, 0, 1);
			var _icon_size = 48;
			var _icon_x = _foundry_current_x + 16;
			var _icon_y = _foundry_current_y + ((_foundry_current_height - _icon_size) * 0.5);
			var _bar_x = _foundry_current_x + 86;
			var _bar_y = _foundry_current_y + 48;
			var _bar_width = _foundry_current_width - 188;
			var _bar_height = 10;
			var _action_text = _hovered_foundry_current ? "Cancel Forging" : "Forging";

			if (sprite_exists(_current_shell.building_sprite))
			{
				draw_sprite_stretched_ext(_current_shell.building_sprite, 0, _icon_x, _icon_y, _icon_size, _icon_size, c_white, 1);
			}

			draw_set_color(COLOR_HUD_TEXT);
			draw_text(_bar_x, _foundry_current_y + 24, _current_shell.building_name);
			draw_set_halign(fa_right);
			draw_set_color(_hovered_foundry_current ? COLOR_PROJECTILE_DAMAGE : COLOR_PROJECTILE_BUILDING_SHELL);
			draw_text(_foundry_current_x + _foundry_current_width - 16, _foundry_current_y + 24, _action_text);

			draw_set_alpha(0.85);
			draw_set_color(COLOR_HUD_BACKGROUND);
			draw_rectangle(_bar_x, _bar_y, _bar_x + _bar_width, _bar_y + _bar_height, false);
			draw_set_alpha(1);
			draw_set_color(COLOR_PROJECTILE_BUILDING_SHELL);
			draw_rectangle(_bar_x, _bar_y, _bar_x + (_bar_width * _progress), _bar_y + _bar_height, false);
			draw_set_color(COLOR_HUD_TEXT);
			draw_rectangle(_bar_x, _bar_y, _bar_x + _bar_width, _bar_y + _bar_height, true);
			draw_set_halign(fa_left);
			draw_set_color(COLOR_HUD_PROJECTILE_DESCRIPTION);
			draw_text(_bar_x, _foundry_current_y + 66, string(floor(_progress * 100)) + "% complete");
		}
		else
		{
			draw_set_color(COLOR_HUD_PROJECTILE_DESCRIPTION);
			draw_text(_foundry_current_x + 16, _foundry_current_y + (_foundry_current_height * 0.5), "No active forging");
		}

		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		draw_set_color(c_white);
		draw_set_alpha(1);
	}

	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_set_color(c_white);
	draw_rectangle(_close_x, _close_y, _close_x + _close_size, _close_y + _close_size, true);
	draw_text(_close_x + (_close_size * 0.5), _close_y + (_close_size * 0.5), "X");

	var _current_group_name = "";
	var _group_y = _grid_y;
	var _group_choice_column = 0;

	for (var _choice_index = 0; _choice_index < _choice_count; ++_choice_index)
	{
		var _choice = building_window_choices[_choice_index];
		var _choice_group_name = "";

		if (!_is_foundry_window && variable_struct_exists(_choice, "building_group"))
		{
			_choice_group_name = _choice.building_group;
		}

		if (!_is_foundry_window && _choice_group_name != _current_group_name)
		{
			if (_current_group_name != "")
			{
				_group_y += building_group_header_height + building_tile_height + building_group_gap_y;
			}

			_current_group_name = _choice_group_name;
			_group_choice_column = 0;

			draw_set_halign(fa_left);
			draw_set_valign(fa_middle);
			draw_set_alpha(1);
			draw_set_color(COLOR_HUD_IRON);
			draw_text(_grid_x, _group_y + (building_group_header_height * 0.5), _current_group_name);
		}

		var _tile_rect = building_choice_tile_rect_get(_choice_index, _is_foundry_window, _grid_x, _grid_y);
		var _tile_x = _tile_rect.x;
		var _tile_y = _tile_rect.y;
		var _is_hovered = _mouse_x >= _tile_x
			&& _mouse_x <= _tile_x + building_tile_width
			&& _mouse_y >= _tile_y
			&& _mouse_y <= _tile_y + building_tile_height;
		var _sprite = _choice.building_sprite;
		var _sprite_x = _tile_x + (building_tile_width * 0.5);
		var _sprite_y = _tile_y + 30;
		var _name_y = _tile_y + 68;
		var _cost_y = _tile_y + 94;
		var _built_count = _is_foundry_window ? 0 : instance_number(_choice.building_object);
		var _limit_count = 0;
		var _limit_max = 0;
		var _limit_reached = false;

		if (BALANCE_BUILDING_DUPLICATE_LIMIT_ENABLED)
		{
			_limit_count = building_choice_count_get(_choice);
			_limit_max = building_choice_limit_get(_choice);
			_limit_reached = _limit_count >= _limit_max;
		}

		var _choice_is_blocked = _limit_reached || _daily_limit_reached;
		var _can_pay_choice = _is_foundry_window ? building_choice_can_pay(_choice) : true;
		var _can_build_choice = _can_pay_choice && !_choice_is_blocked;
		var _requirement_text = building_choice_requirement_text_get(_choice);
		var _should_pulse_blood_bath = !_is_foundry_window
			&& _choice.building_object == o_meat_bath
			&& instance_number(o_meat_bath) <= 0;
		var _blood_bath_pulse = 1;

		if (_is_hovered)
		{
			_hovered_choice = _choice_index;
		}

		if (_should_pulse_blood_bath)
		{
			_blood_bath_pulse = 1 + (sin(current_time * 0.008) * 0.08);
		}

		draw_set_alpha(0.82);
		draw_set_color(c_black);
		draw_rectangle(_tile_x, _tile_y, _tile_x + building_tile_width, _tile_y + building_tile_height, false);

		draw_set_alpha(1);
		draw_set_color(_choice_is_blocked ? COLOR_PROJECTILE_DAMAGE : (_is_hovered ? COLOR_HUD_IRON : c_white));
		draw_rectangle(_tile_x, _tile_y, _tile_x + building_tile_width, _tile_y + building_tile_height, true);

		if (_should_pulse_blood_bath)
		{
			var _pulse_padding = 5 + ((_blood_bath_pulse - 1) * 32);

			draw_set_alpha(0.35 + ((_blood_bath_pulse - 1) * 2.2));
			draw_set_color(COLOR_CULTIST_SPIRIT);
			draw_rectangle(
				_tile_x - _pulse_padding,
				_tile_y - _pulse_padding,
				_tile_x + building_tile_width + _pulse_padding,
				_tile_y + building_tile_height + _pulse_padding,
				true
			);
			draw_set_alpha(1);
		}

		if (sprite_exists(_sprite))
		{
			var _sprite_width = sprite_get_width(_sprite);
			var _sprite_height = sprite_get_height(_sprite);
			var _sprite_scale = (building_tile_sprite_size / max(_sprite_width, _sprite_height)) * _blood_bath_pulse;
			var _sprite_draw_width = _sprite_width * _sprite_scale;
			var _sprite_draw_height = _sprite_height * _sprite_scale;

			draw_sprite_stretched_ext(
				_sprite,
				0,
				_sprite_x - (_sprite_draw_width * 0.5),
				_sprite_y - (_sprite_draw_height * 0.5),
				_sprite_draw_width,
				_sprite_draw_height,
				c_white,
				_choice_is_blocked ? 0.35 : 1
			);
		}

		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		draw_set_alpha(_can_build_choice ? 1 : 0.5);
		draw_set_color(_choice_is_blocked ? COLOR_HUD_PROJECTILE_DESCRIPTION : COLOR_HUD_TEXT);
		draw_text(_sprite_x, _name_y, _choice.building_name);
		draw_set_alpha(1);

		var _costs = _is_foundry_window ? building_choice_costs_get(_choice) : [];
		var _cost_count = array_length(_costs);
		var _cost_gap = 8;
		var _cost_total_width = 0;

		for (var _cost_measure_index = 0; _cost_measure_index < _cost_count; ++_cost_measure_index)
		{
			var _measure_cost = _costs[_cost_measure_index];
			_cost_total_width += building_tile_cost_icon_size + 4 + string_width(string(_measure_cost.cost));

			if (_cost_measure_index < _cost_count - 1)
			{
				_cost_total_width += _cost_gap;
			}
		}

		var _cost_draw_x = _sprite_x - (_cost_total_width * 0.5);

		for (var _cost_index = 0; _cost_index < _cost_count; ++_cost_index)
		{
			var _cost_data = _costs[_cost_index];
			var _cost_icon = resource_icon_get(_cost_data.resource);
			var _cost_color = resource_color_get(_cost_data.resource);
			var _cost_text = string(_cost_data.cost);
			var _has_cost_resource = global.resources[_cost_data.resource] >= _cost_data.cost;
			var _cost_item_width = (sprite_exists(_cost_icon) ? building_tile_cost_icon_size + 4 : 0) + string_width(_cost_text);

			if (sprite_exists(_cost_icon))
			{
				if (!_has_cost_resource)
				{
					draw_set_alpha(0.6);
					draw_set_color(COLOR_STATUS_NEGATIVE_RED);
					draw_rectangle(
						_cost_draw_x - 4,
						_cost_y - (building_tile_cost_icon_size * 0.5) - 3,
						_cost_draw_x + _cost_item_width + 4,
						_cost_y + (building_tile_cost_icon_size * 0.5) + 3,
						false
					);
					draw_set_alpha(1);
				}

				draw_sprite_stretched_ext(
					_cost_icon,
					0,
					_cost_draw_x,
					_cost_y - (building_tile_cost_icon_size * 0.5),
					building_tile_cost_icon_size,
					building_tile_cost_icon_size,
					c_white,
					_can_build_choice ? 1 : 0.55
				);

				_cost_draw_x += building_tile_cost_icon_size + 4;
			}
			else if (!_has_cost_resource)
			{
				draw_set_alpha(0.6);
				draw_set_color(COLOR_STATUS_NEGATIVE_RED);
				draw_rectangle(
					_cost_draw_x - 4,
					_cost_y - (building_tile_cost_icon_size * 0.5) - 3,
					_cost_draw_x + _cost_item_width + 4,
					_cost_y + (building_tile_cost_icon_size * 0.5) + 3,
					false
				);
				draw_set_alpha(1);
			}

			draw_set_color(_has_cost_resource && !_choice_is_blocked ? _cost_color : COLOR_PROJECTILE_DAMAGE);
			draw_set_halign(fa_left);
			draw_text(_cost_draw_x, _cost_y, _cost_text);
			_cost_draw_x += string_width(_cost_text) + _cost_gap;
		}

		if (!_is_foundry_window)
		{
			draw_set_halign(fa_center);
			draw_set_color(_choice_is_blocked ? COLOR_PROJECTILE_DAMAGE : COLOR_HUD_TEXT);
			draw_text(_sprite_x, _cost_y, _construction_cultist_cost_text);

			// Show only completed structures, not reserved construction events.
			draw_set_valign(fa_top);
			draw_set_color(COLOR_HUD_PROJECTILE_DESCRIPTION);
			draw_text(
				_sprite_x,
				_tile_y + building_tile_height + 4,
				"Built: " + string(_built_count)
			);
		}

		if (_requirement_text != "")
		{
			draw_set_halign(fa_center);
			draw_set_valign(fa_top);
			draw_set_alpha(1);
			draw_set_color(COLOR_STATUS_NEGATIVE_RED);
			draw_text_ext(_sprite_x, _tile_y + building_tile_height + 22, _requirement_text, 10, building_tile_width - 12);
		}

		if (!_is_foundry_window)
		{
			_group_choice_column++;
		}
	}

	if (_hovered_choice >= 0)
	{
		var _choice = building_window_choices[_hovered_choice];
		var _limit_count = 0;
		var _limit_max = 0;
		var _limit_reached = false;

		if (BALANCE_BUILDING_DUPLICATE_LIMIT_ENABLED)
		{
			_limit_count = building_choice_count_get(_choice);
			_limit_max = building_choice_limit_get(_choice);
			_limit_reached = _limit_count >= _limit_max;
		}

		var _can_build_choice = building_choice_can_pay(_choice)
			&& !_limit_reached
			&& !_daily_limit_reached;
		var _tooltip_x = min(_mouse_x + 18, camera_view_width - building_tooltip_width - 18);
		var _tooltip_y = min(_mouse_y + 18, camera_view_height - building_tooltip_height - 18);

		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		draw_set_alpha(0.96);
		draw_set_color(COLOR_HUD_BACKGROUND);
		draw_rectangle(_tooltip_x, _tooltip_y, _tooltip_x + building_tooltip_width, _tooltip_y + building_tooltip_height, false);
		draw_set_alpha(1);
		draw_set_color(COLOR_HUD_IRON);
		draw_rectangle(_tooltip_x, _tooltip_y, _tooltip_x + building_tooltip_width, _tooltip_y + building_tooltip_height, true);

		draw_set_color(COLOR_HUD_TEXT);
		draw_text(_tooltip_x + building_tooltip_padding, _tooltip_y + building_tooltip_padding, _choice.building_name);
		draw_set_color(COLOR_HUD_PROJECTILE_DESCRIPTION);
		draw_text_ext(
			_tooltip_x + building_tooltip_padding,
			_tooltip_y + building_tooltip_padding + 28,
			_choice.building_description,
			18,
			building_tooltip_width - (building_tooltip_padding * 2)
		);
		draw_set_color(_can_build_choice ? COLOR_HUD_IRON : COLOR_PROJECTILE_DAMAGE);

		if (_daily_limit_reached)
		{
			draw_text(_tooltip_x + building_tooltip_padding, _tooltip_y + building_tooltip_height - 28, "MAX 1 BUILDING PER DAY");
		}
		else if (_limit_reached)
		{
			var _limit_text = "Limit reached: " + string(_limit_count) + "/" + string(_limit_max);
			var _requirement_text = building_choice_requirement_text_get(_choice);

			if (_requirement_text != "")
			{
				_limit_text = _requirement_text;
			}

			draw_text(_tooltip_x + building_tooltip_padding, _tooltip_y + building_tooltip_height - 28, _limit_text);
		}
		else if (instance_exists(building_window_foundry))
		{
			draw_text(_tooltip_x + building_tooltip_padding, _tooltip_y + building_tooltip_height - 28, "Cost: " + building_choice_cost_text_get(_choice) + " | Click to assign shell");
		}
		else if (!BALANCE_BUILDING_DUPLICATE_LIMIT_ENABLED)
		{
			draw_text(
				_tooltip_x + building_tooltip_padding,
				_tooltip_y + building_tooltip_height - 28,
				"Cost: " + _construction_cultist_cost_text
			);
		}
		else
		{
			draw_text(
				_tooltip_x + building_tooltip_padding,
				_tooltip_y + building_tooltip_height - 28,
				"Limit: " + string(_limit_count) + "/" + string(_limit_max)
					+ " | Cost: " + _construction_cultist_cost_text
			);
		}
	}

	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
	draw_set_alpha(1);

	if (!global.blood_moon_reward_popup_active)
	{
		exit;
	}
}

// Draw the read-only catalog of every event that can originate from this building.
if (global.focus_window == FOCUS_WINDOW.BUILDING_EVENTS)
{
	var _jobs_ui = instance_find(o_jobs_ui, 0);
	var _gui_width = display_get_gui_width();
	var _gui_height = display_get_gui_height();
	var _design_width = 1920;
	var _design_height = 1080;
	var _panel_design_width = 1112;
	var _panel_design_height = 898;
	var _scale = min(_gui_width / _design_width, _gui_height / _design_height);
	var _panel_width = _panel_design_width * _scale;
	var _panel_height = _panel_design_height * _scale;
	var _panel_x = (_gui_width - _panel_width) * 0.5;
	var _panel_y = 69 * _scale;
	var _event_x = _panel_x + (206 * _scale);
	var _event_start_y = _panel_y + (141 * _scale);
	var _event_width = 700 * _scale;
	var _event_height = 108 * _scale;
	var _event_gap = 6 * _scale;
	var _current_event_gap = is_struct(building_events_window_current_event)
		? 40 * _scale
		: 0;
	var _event_step = _event_height + _event_gap;
	var _close_size = 56 * _scale;
	var _close_x = _panel_x + _panel_width - (64 * _scale);
	var _close_y = _panel_y + (10 * _scale);
	var _entry_count = array_length(building_events_window_entries);
	var _viewport_bottom = _panel_y + _panel_height - (24 * _scale);
	var _viewport_height = _viewport_bottom - _event_start_y;
	var _content_height = (_entry_count * _event_step)
		+ _current_event_gap;
	var _max_scroll_row = ceil(max(0, _content_height - _viewport_height) / max(1, _event_step));

	building_events_scroll_row = clamp(building_events_scroll_row, 0, _max_scroll_row);

	// Match the Jobs window backdrop and panel.
	draw_set_alpha(0.65);
	draw_set_color(c_black);
	draw_rectangle(0, 0, _gui_width, _gui_height, false);

	draw_set_alpha(1);
	draw_set_color(COLOR_JOBS_WINDOW_BACKGROUND);
	draw_rectangle(_panel_x, _panel_y, _panel_x + _panel_width, _panel_y + _panel_height, false);

	draw_set_halign(fa_center);
	draw_set_valign(fa_top);
	draw_set_color(COLOR_JOBS_ASSIGN_TEXT);

	if (instance_exists(_jobs_ui) && font_exists(_jobs_ui.jobs_button_font))
	{
		draw_set_font(_jobs_ui.jobs_button_font);
	}

	draw_text_transformed(
		_panel_x + (_panel_width * 0.5),
		_panel_y + (58 * _scale),
		string_upper(building_events_window_name),
		_scale,
		_scale,
		0
	);

	if (instance_exists(_jobs_ui) && font_exists(_jobs_ui.jobs_title_font))
	{
		draw_set_font(_jobs_ui.jobs_title_font);
	}

	draw_text_transformed(
		_panel_x + (_panel_width * 0.5),
		_panel_y + (95 * _scale),
		"ALL POSSIBLE JOBS",
		_scale,
		_scale,
		0
	);

	// Use the same outlined close button as Jobs.
	draw_set_color(c_white);
	draw_rectangle(_close_x, _close_y, _close_x + _close_size, _close_y + _close_size, true);
	draw_line(
		_close_x + (10 * _scale),
		_close_y + (10 * _scale),
		_close_x + _close_size - (10 * _scale),
		_close_y + _close_size - (10 * _scale)
	);
	draw_line(
		_close_x + _close_size - (10 * _scale),
		_close_y + (10 * _scale),
		_close_x + (10 * _scale),
		_close_y + _close_size - (10 * _scale)
	);

	if (_entry_count <= 0)
	{
		draw_set_valign(fa_middle);
		draw_set_color(COLOR_JOBS_SLOT_BORDER);
		draw_text(
			_panel_x + (_panel_width * 0.5),
			_panel_y + (_panel_height * 0.5),
			"THIS BUILDING HAS NO DAY EVENTS"
		);
	}
	else
	{
		var _viewport_gui = {
			x: _panel_x,
			y: _event_start_y,
			width: _panel_width,
			height: _viewport_height
		};
		var _gui_to_window_x = window_get_width() / max(1, _gui_width);
		var _gui_to_window_y = window_get_height() / max(1, _gui_height);
		var _event_scissor = {
			x: floor(_viewport_gui.x * _gui_to_window_x),
			y: floor(_viewport_gui.y * _gui_to_window_y),
			w: ceil(_viewport_gui.width * _gui_to_window_x),
			h: ceil(_viewport_gui.height * _gui_to_window_y)
		};
		var _previous_scissor = gpu_get_scissor();
		gpu_set_scissor(_event_scissor);

		for (var _entry_index = 0; _entry_index < _entry_count; ++_entry_index)
		{
			var _entry = building_events_window_entries[_entry_index];
			var _is_current = variable_struct_exists(_entry, "is_current")
				&& _entry.is_current;
			var _card_x = _event_x;
			var _card_y = _event_start_y
				+ (_entry_index * _event_step)
				+ (_entry_index > 0 ? _current_event_gap : 0)
				- (building_events_scroll_row * _event_step);

			draw_set_alpha(1);
			draw_set_color(_is_current ? COLOR_JOBS_EVENT_ACTIVE : COLOR_JOBS_EVENT_INACTIVE);
			draw_rectangle(
				_card_x,
				_card_y,
				_card_x + _event_width,
				_card_y + _event_height,
				false
			);

			// Repeat the source-building sprite in the left gutter like Jobs.
			if (instance_exists(building_events_window_building)
				&& sprite_exists(building_events_window_building.sprite_index))
			{
				var _source_sprite = building_events_window_building.sprite_index;
				var _source_frame = building_events_window_building.image_index;
				var _source_available_width = 108 * _scale;
				var _source_available_height = 76 * _scale;
				var _source_scale = min(
					_source_available_width / max(1, sprite_get_width(_source_sprite)),
					_source_available_height / max(1, sprite_get_height(_source_sprite))
				);
				var _source_width = sprite_get_width(_source_sprite) * _source_scale;
				var _source_height = sprite_get_height(_source_sprite) * _source_scale;
				var _source_center_x = _panel_x + (138 * _scale);
				var _source_x = _source_center_x - (_source_width * 0.5);
				var _source_y = _card_y + ((_event_height - _source_height) * 0.5);

				draw_sprite_stretched_ext(
					_source_sprite,
					_source_frame,
					_source_x,
					_source_y,
					_source_width,
					_source_height,
					c_white,
					1
				);
			}

			draw_set_halign(fa_left);
			draw_set_valign(fa_top);
			draw_set_color(COLOR_JOBS_ASSIGN_TEXT);

			if (instance_exists(_jobs_ui) && font_exists(_jobs_ui.jobs_title_font))
			{
				draw_set_font(_jobs_ui.jobs_title_font);
			}

			draw_text_transformed(
				_card_x + (34 * _scale),
				_card_y + (18 * _scale),
				_entry.title,
				_scale,
				_scale,
				0
			);

			if (instance_exists(_jobs_ui) && font_exists(_jobs_ui.jobs_description_font))
			{
				draw_set_font(_jobs_ui.jobs_description_font);
			}

			draw_text_ext(
				_card_x + (34 * _scale),
				_card_y + (48 * _scale),
				_entry.description,
				16 * _scale,
				380 * _scale
			);

			// Show requirement slots without cultist portraits or assignment controls.
			var _slot_count = variable_struct_exists(_entry, "cultist_cost")
				? _entry.cultist_cost
				: 1;
			var _slot_width = 44 * _scale;
			var _slot_height = 60 * _scale;
			var _slot_start_x = _card_x + (435 * _scale);
			var _slot_y = _card_y + (18 * _scale);

			for (var _slot_index = 0; _slot_index < _slot_count; ++_slot_index)
			{
				var _slot_x = _slot_start_x + (_slot_index * 65 * _scale);
				draw_set_color(COLOR_JOBS_SLOT_BORDER);
				draw_rectangle(
					_slot_x,
					_slot_y,
					_slot_x + _slot_width,
					_slot_y + _slot_height,
					true
				);
			}

			if (_is_current)
			{
				if (instance_exists(_jobs_ui) && font_exists(_jobs_ui.jobs_action_font))
				{
					draw_set_font(_jobs_ui.jobs_action_font);
				}

				draw_set_halign(fa_left);
				draw_set_valign(fa_middle);
				draw_set_color(COLOR_JOBS_ASSIGN_TEXT);
				draw_text_transformed(
					_card_x + _event_width + (16 * _scale),
					_card_y + (_event_height * 0.5),
					"Current job",
					_scale,
					_scale,
					0
				);
			}
		}

		gpu_set_scissor(_previous_scissor);
	}

	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
	draw_set_alpha(1);

	if (variable_global_exists("ui_font") && font_exists(global.ui_font))
	{
		draw_set_font(global.ui_font);
	}

	if (!global.blood_moon_reward_popup_active)
	{
		exit;
	}
}

// Legacy upgrade window remains unreachable; building clicks now open the event catalog.
if (global.focus_window == FOCUS_WINDOW.BUILDING_UPGRADE)
{
	var _panel_x = (camera_view_width - building_upgrade_window_width) * 0.5;
	var _panel_y = (camera_view_height - building_upgrade_window_height) * 0.5;
	var _mouse_x = device_mouse_x_to_gui(0);
	var _mouse_y = device_mouse_y_to_gui(0);
	var _close_size = 34;
	var _close_x = _panel_x + building_upgrade_window_width - _close_size - 14;
	var _close_y = _panel_y + 14;
	var _tile_start_x = _panel_x + 38;
	var _tile_y = _panel_y + building_upgrade_tile_y;

	draw_set_alpha(0.55);
	draw_set_color(c_black);
	draw_rectangle(0, 0, camera_view_width, camera_view_height, false);

	draw_set_alpha(1);
	draw_set_color(COLOR_HUD_BACKGROUND);
	draw_rectangle(_panel_x, _panel_y, _panel_x + building_upgrade_window_width, _panel_y + building_upgrade_window_height, false);
	draw_set_color(c_white);
	draw_rectangle(_panel_x, _panel_y, _panel_x + building_upgrade_window_width, _panel_y + building_upgrade_window_height, true);

	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_set_color(COLOR_HUD_TEXT);
	if (variable_global_exists("ui_heading_font") && font_exists(global.ui_heading_font))
	{
		draw_set_font(global.ui_heading_font);
	}

	draw_text(_panel_x + (building_upgrade_window_width * 0.5), _panel_y + 36, "Upgrade");

	if (variable_global_exists("ui_font") && font_exists(global.ui_font))
	{
		draw_set_font(global.ui_font);
	}

	building_resource_summary_draw(_panel_x + (building_upgrade_window_width * 0.5), _panel_y + building_upgrade_resource_y);

	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_set_color(c_white);
	draw_rectangle(_close_x, _close_y, _close_x + _close_size, _close_y + _close_size, true);
	draw_text(_close_x + (_close_size * 0.5), _close_y + (_close_size * 0.5), "X");

	if (instance_exists(building_upgrade_window_building))
	{
		draw_set_halign(fa_left);
		draw_set_color(COLOR_HUD_PROJECTILE_DESCRIPTION);
		draw_text(_panel_x + 38, _panel_y + building_upgrade_description_y, building_upgrade_window_building.building_tooltip_description);

		var _upgrade_count = 0;
		var _uses_levels = variable_instance_exists(building_upgrade_window_building, "building_upgrade_levels");

		if (_uses_levels)
		{
			_upgrade_count = array_length(building_upgrade_window_building.building_upgrade_levels);
		}
		else if (variable_instance_exists(building_upgrade_window_building, "building_upgrade_flags"))
		{
			_upgrade_count = array_length(building_upgrade_window_building.building_upgrade_flags);
		}

		for (var _upgrade_index = 0; _upgrade_index < _upgrade_count; ++_upgrade_index)
		{
			var _tile_x = _tile_start_x + ((building_upgrade_tile_width + building_upgrade_tile_gap) * _upgrade_index);
			var _is_hovered = _mouse_x >= _tile_x
				&& _mouse_x <= _tile_x + building_upgrade_tile_width
				&& _mouse_y >= _tile_y
				&& _mouse_y <= _tile_y + building_upgrade_tile_height;
			var _upgrade_level = 0;
			var _upgrade_level_max = 1;
			var _upgrade_display_level = 0;
			var _upgrade_display_level_max = 1;
			var _upgrade_next_display_level = 1;
			var _upgrade_description = "";
			var _upgrade_cost = 0;
			var _upgrade_cost_text = "";
			var _upgrade_resource_name = "Iron";
			var _upgrade_resource_color = COLOR_HUD_IRON;
			var _is_bought = false;

			if (_uses_levels)
			{
				_upgrade_level = building_upgrade_window_building.building_upgrade_levels[_upgrade_index];
				_upgrade_level_max = BALANCE_CANNON_UPGRADE_LEVEL_MAX;

				if (variable_instance_exists(building_upgrade_window_building, "cannon_upgrade_level_max_get"))
				{
					_upgrade_level_max = building_upgrade_window_building.cannon_upgrade_level_max_get(_upgrade_index);
				}

				_upgrade_display_level = _upgrade_level;
				_upgrade_display_level_max = _upgrade_level_max;
				_upgrade_next_display_level = _upgrade_level + 1;

				if (variable_instance_exists(building_upgrade_window_building, "cannon_upgrade_display_level_get"))
				{
					_upgrade_display_level = building_upgrade_window_building.cannon_upgrade_display_level_get(_upgrade_index);
					_upgrade_next_display_level = building_upgrade_window_building.cannon_upgrade_next_display_level_get(_upgrade_index);
					_upgrade_display_level_max = building_upgrade_window_building.cannon_upgrade_display_level_max_get(_upgrade_index);
				}

				_upgrade_description = building_upgrade_window_building.building_upgrade_description_get(_upgrade_index);
				_upgrade_cost = building_upgrade_window_building.cannon_upgrade_next_cost_get(_upgrade_index);
				_upgrade_cost_text = string(_upgrade_cost) + " " + _upgrade_resource_name;
				_is_bought = _upgrade_level >= _upgrade_level_max;

				if (variable_instance_exists(building_upgrade_window_building, "cannon_upgrade_resource_get"))
				{
					var _upgrade_resource = building_upgrade_window_building.cannon_upgrade_resource_get(_upgrade_index);
					_upgrade_resource_name = building_upgrade_window_building.resource_name_get(_upgrade_resource);
					_upgrade_resource_color = building_upgrade_window_building.resource_color_get(_upgrade_resource);
					_upgrade_cost_text = string(_upgrade_cost) + " " + _upgrade_resource_name;
				}

				if (variable_instance_exists(building_upgrade_window_building, "cannon_upgrade_cost_text_get"))
				{
					_upgrade_cost_text = building_upgrade_window_building.cannon_upgrade_cost_text_get(_upgrade_index);
				}
			}
			else
			{
				_upgrade_description = building_upgrade_window_building.building_upgrade_descriptions[_upgrade_index];
				_upgrade_cost = building_upgrade_window_building.building_upgrade_costs[_upgrade_index];
				_upgrade_cost_text = string(_upgrade_cost) + " " + _upgrade_resource_name;
				_is_bought = building_upgrade_window_building.building_upgrade_flags[_upgrade_index];

				if (variable_instance_exists(building_upgrade_window_building, "building_upgrade_resources")
					&& _upgrade_index < array_length(building_upgrade_window_building.building_upgrade_resources))
				{
					var _upgrade_resource = building_upgrade_window_building.building_upgrade_resources[_upgrade_index];
					_upgrade_resource_name = building_upgrade_window_building.resource_name_get(_upgrade_resource);
					_upgrade_resource_color = building_upgrade_window_building.resource_color_get(_upgrade_resource);
					_upgrade_cost_text = string(_upgrade_cost) + " " + _upgrade_resource_name;
				}
			}

			var _can_buy = building_upgrade_window_building.building_upgrade_can_buy(_upgrade_index);
			var _upgrade_costs = building_upgrade_costs_get(building_upgrade_window_building, _upgrade_index);
			var _outline_color = _is_hovered ? COLOR_HUD_IRON : c_white;

			if (_is_bought)
			{
				_outline_color = COLOR_HUD_PROJECTILE_DESCRIPTION;
			}
			else if (!_can_buy)
			{
				_outline_color = COLOR_PROJECTILE_DAMAGE;
			}

			draw_set_alpha(0.82);
			draw_set_color(c_black);
			draw_rectangle(_tile_x, _tile_y, _tile_x + building_upgrade_tile_width, _tile_y + building_upgrade_tile_height, false);

			draw_set_alpha(1);
			draw_set_color(_outline_color);
			draw_rectangle(_tile_x, _tile_y, _tile_x + building_upgrade_tile_width, _tile_y + building_upgrade_tile_height, true);

			draw_set_halign(fa_left);
			draw_set_valign(fa_top);
			draw_set_alpha(_can_buy ? 1 : 0.5);
			draw_set_color(COLOR_HUD_TEXT);
			draw_text(_tile_x + 12, _tile_y + 12, building_upgrade_window_building.building_upgrade_names[_upgrade_index]);
			draw_set_alpha(1);

			draw_set_color(COLOR_HUD_PROJECTILE_DESCRIPTION);
			draw_text_ext(
				_tile_x + 12,
				_tile_y + 42,
				_upgrade_description,
				18,
				building_upgrade_tile_width - 24
			);

			draw_set_valign(fa_middle);
			draw_set_color(_is_bought ? COLOR_HUD_PROJECTILE_DESCRIPTION : _upgrade_resource_color);

			if (_is_bought)
			{
				if (_uses_levels)
				{
					draw_text(_tile_x + 12, _tile_y + building_upgrade_tile_height - 24, "Level " + string(_upgrade_display_level) + "/" + string(_upgrade_display_level_max));
				}
				else
				{
					draw_text(_tile_x + 12, _tile_y + building_upgrade_tile_height - 24, "Bought");
				}
			}
			else
			{
				var _upgrade_cost_icon_size = 18;
				var _upgrade_cost_gap = 8;
				var _upgrade_cost_draw_x = _tile_x + 12;
				var _upgrade_cost_draw_y = _tile_y + building_upgrade_tile_height - 24;

				if (_uses_levels)
				{
					draw_set_color(_upgrade_resource_color);
					draw_text(_upgrade_cost_draw_x, _upgrade_cost_draw_y, "Lvl " + string(_upgrade_next_display_level) + ":");
					_upgrade_cost_draw_x += string_width("Lvl " + string(_upgrade_next_display_level) + ":") + 8;
				}
				else
				{
					draw_set_color(_upgrade_resource_color);
					draw_text(_upgrade_cost_draw_x, _upgrade_cost_draw_y, "Cost:");
					_upgrade_cost_draw_x += string_width("Cost:") + 8;
				}

				for (var _upgrade_cost_index = 0; _upgrade_cost_index < array_length(_upgrade_costs); ++_upgrade_cost_index)
				{
					var _upgrade_cost_data = _upgrade_costs[_upgrade_cost_index];
					var _upgrade_cost_icon = resource_icon_get(_upgrade_cost_data.resource);
					var _upgrade_cost_color = resource_color_get(_upgrade_cost_data.resource);
					var _upgrade_cost_value_text = string(_upgrade_cost_data.cost);
					var _has_upgrade_resource = global.resources[_upgrade_cost_data.resource] >= _upgrade_cost_data.cost;
					var _upgrade_cost_item_width = (sprite_exists(_upgrade_cost_icon) ? _upgrade_cost_icon_size + 4 : 0) + string_width(_upgrade_cost_value_text);

					if (!_has_upgrade_resource)
					{
						draw_set_alpha(0.6);
						draw_set_color(COLOR_STATUS_NEGATIVE_RED);
						draw_rectangle(
							_upgrade_cost_draw_x - 4,
							_upgrade_cost_draw_y - (_upgrade_cost_icon_size * 0.5) - 3,
							_upgrade_cost_draw_x + _upgrade_cost_item_width + 4,
							_upgrade_cost_draw_y + (_upgrade_cost_icon_size * 0.5) + 3,
							false
						);
						draw_set_alpha(1);
					}

					if (sprite_exists(_upgrade_cost_icon))
					{
						draw_sprite_stretched_ext(
							_upgrade_cost_icon,
							0,
							_upgrade_cost_draw_x,
							_upgrade_cost_draw_y - (_upgrade_cost_icon_size * 0.5),
							_upgrade_cost_icon_size,
							_upgrade_cost_icon_size,
							c_white,
							_can_buy ? 1 : 0.55
						);

						_upgrade_cost_draw_x += _upgrade_cost_icon_size + 4;
					}

					draw_set_color(_has_upgrade_resource ? _upgrade_cost_color : COLOR_HUD_TEXT);
					draw_text(_upgrade_cost_draw_x, _upgrade_cost_draw_y, _upgrade_cost_value_text);
					_upgrade_cost_draw_x += string_width(_upgrade_cost_value_text) + _upgrade_cost_gap;
				}
			}
		}
	}

	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
	draw_set_alpha(1);
	if (!global.blood_moon_reward_popup_active)
	{
		exit;
	}
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

		if (global.day_phase == DAY_PHASE.NIGHT
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
					- (BALANCE_SQUAD_MARKER_OFFSET_Y * (_drag_hand_camera_height / max(1, camera_view_height)));
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

// Construction events show their two worker slots directly at the selected build site.
if (global.day_phase == DAY_PHASE.DAY
	&& global.focus_window == FOCUS_WINDOW.NOONE
	&& variable_global_exists("day_events")
	&& instance_exists(o_camera_controller))
{
	var _construction_camera = instance_find(o_camera_controller, 0);
	var _construction_camera_x = camera_get_view_x(_construction_camera.camera_id);
	var _construction_camera_y = camera_get_view_y(_construction_camera.camera_id);
	var _construction_camera_width = camera_get_view_width(_construction_camera.camera_id);
	var _construction_camera_height = camera_get_view_height(_construction_camera.camera_id);
	var _construction_gui_width = _construction_camera.base_view_width;
	var _construction_gui_height = _construction_camera.base_view_height;
	var _construction_world_to_gui_x = _construction_gui_width / _construction_camera_width;
	var _construction_world_to_gui_y = _construction_gui_height / _construction_camera_height;

	for (var _construction_event_index = 0;
		_construction_event_index < array_length(global.day_events);
		++_construction_event_index)
	{
		var _construction_event = global.day_events[_construction_event_index];

		if (!is_struct(_construction_event)
			|| _construction_event.is_resolved
			|| !variable_struct_exists(_construction_event, "construction_site")
			|| !instance_exists(_construction_event.construction_site))
		{
			continue;
		}

		var _construction_site = _construction_event.construction_site;
		var _construction_slot_count = _construction_event.cultist_cost
			* _construction_event.activation_limit;
		var _construction_slot_row_width = (_construction_slot_count - 1)
			* BALANCE_WORLD_EVENT_SLOT_SPACING;
		var _construction_slot_start_x = _construction_site.x
			- (_construction_slot_row_width * 0.5);
		var _construction_slot_bottom_y = _construction_site.bbox_bottom + 12;

		if (variable_instance_exists(_construction_site, "worker_stand_offset_y"))
		{
			_construction_slot_bottom_y = _construction_site.bbox_bottom
				+ _construction_site.worker_stand_offset_y;
		}

		for (var _construction_slot_index = 0;
			_construction_slot_index < _construction_slot_count;
			++_construction_slot_index)
		{
			var _construction_slot_center_x = _construction_slot_start_x
				+ (_construction_slot_index * BALANCE_WORLD_EVENT_SLOT_SPACING);
			var _construction_slot_left = _construction_slot_center_x
				- (BALANCE_WORLD_EVENT_SLOT_WIDTH * 0.5);
			var _construction_slot_top = _construction_slot_bottom_y
				- BALANCE_WORLD_EVENT_SLOT_HEIGHT;
			var _construction_slot_gui_x = (_construction_slot_left - _construction_camera_x)
				* _construction_world_to_gui_x;
			var _construction_slot_gui_y = (_construction_slot_top - _construction_camera_y)
				* _construction_world_to_gui_y;
			var _construction_slot_gui_width = BALANCE_WORLD_EVENT_SLOT_WIDTH
				* _construction_world_to_gui_x;
			var _construction_slot_gui_height = BALANCE_WORLD_EVENT_SLOT_HEIGHT
				* _construction_world_to_gui_y;

			draw_set_alpha(1);
			draw_set_color(COLOR_JOBS_SLOT_BORDER);
			draw_rectangle(
				_construction_slot_gui_x,
				_construction_slot_gui_y,
				_construction_slot_gui_x + _construction_slot_gui_width,
				_construction_slot_gui_y + _construction_slot_gui_height,
				true
			);
		}
	}

	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
	draw_set_alpha(1);
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
