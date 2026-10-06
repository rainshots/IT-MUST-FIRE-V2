/// @description Draws the original cannon aiming previews and hints. Requires o_game_controller.
function cannon_target_draw_gui(_controller)
{
	if (!instance_exists(_controller)
		|| global.focus_window != FOCUS_WINDOW.TARGET_SELECTION
		|| !instance_exists(o_camera_controller))
	{
		return;
	}

	// Both gameplay modes share the original projectile-specific presentation.
	with (_controller)
	{
		if (variable_global_exists("ui_font") && font_exists(global.ui_font))
		{
			draw_set_font(global.ui_font);
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
				_target_color = global.shell_factory_first_aid_enchantment
					== FIRST_AID_MEAT_ENCHANTMENT.NECROMEDIC
					? COLOR_PROJECTILE_SKELETONS
					: COLOR_PROJECTILE_HEAL;
			}
			else if (target_selection_projectile_type == PROJECTILE_TYPE.BOMB)
			{
				_target_color = COLOR_PROJECTILE_BOMB;
				_target_hint_color = COLOR_PROJECTILE_BOMB;

				if (!hellcow_aim_is_dragging)
				{
					_target_hint_text = "Hold and drag to set direction and distance";
				}
				else if (hellcow_aim_drag_distance < BALANCE_PROJECTILE_HELLCOW_AIM_MIN_DRAG)
				{
					_target_hint_text = "Drag farther to fire";
				}
				else
				{
					var _hellcow_range_percent = round(hellcow_aim_charge_distance_get()
						/ BALANCE_PROJECTILE_HELLCOW_CHARGE_DISTANCE * 100);
					_target_hint_text = "Release to fire | Range: " + string(_hellcow_range_percent) + "%";
				}
			}
			else if (target_selection_projectile_type == PROJECTILE_TYPE.SKELETONS)
			{
				_target_color = COLOR_PROJECTILE_SKELETONS;
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
				var _hellcow_charge_distance = hellcow_aim_charge_distance_get();
				// Enemies stop ahead of the cows, so include the push front in the shown boundary.
				var _hellcow_corridor_length = (_hellcow_charge_distance
					+ BALANCE_PROJECTILE_HELLCOW_PUSH_FRONT_DISTANCE) * _radius_scale;
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

				// Tainted ground inside the path pulses without promising exact unit trajectories.
				var _hellcow_taint_step = 96;
				var _hellcow_taint_side_step = BALANCE_PROJECTILE_HELLCOW_CORRIDOR_WIDTH * 0.32;

				for (var _hellcow_taint_forward = _hellcow_taint_step;
					_hellcow_taint_forward < _hellcow_charge_distance;
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
				if (target_selection_projectile_type == PROJECTILE_TYPE.HEAL
					&& global.shell_factory_first_aid_enchantment == FIRST_AID_MEAT_ENCHANTMENT.EMERGENCY_PULL)
				{
					var _first_aid_extra_radius = BALANCE_FIRST_AID_MEAT_PULL_RADIUS;
					var _first_aid_extra_color = COLOR_COOLDOWN_BRUTE_BUTCHER_CHAINS;
					var _first_aid_extra_draw_radius = _first_aid_extra_radius * _radius_scale;

					// Emergency Pull shows its rescue range instead of a landing effect radius.
					draw_set_color(_first_aid_extra_color);
					draw_set_alpha(BALANCE_FIRST_AID_MEAT_EXTRA_RADIUS_FILL_ALPHA);
					draw_circle(_mouse_x, _mouse_y, _first_aid_extra_draw_radius, false);
					draw_set_alpha(BALANCE_FIRST_AID_MEAT_EXTRA_RADIUS_OUTLINE_ALPHA);
					draw_circle(_mouse_x, _mouse_y, _first_aid_extra_draw_radius, true);
				}

				if (target_selection_projectile_type == PROJECTILE_TYPE.CORRUPTION
					&& global.shell_factory_taint_enchantment == TAINT_COMPOST_ENCHANTMENT.SWEET_ROT)
				{
					// Sweet Rot previews its attraction radius behind the normal corruption radius.
					var _sweet_rot_draw_radius = BALANCE_TAINT_COMPOST_SWEET_ROT_RADIUS * _radius_scale;
					draw_set_color(COLOR_TAINT_SPREADER_RADIUS);
					draw_set_alpha(target_selection_alpha * BALANCE_TAINT_COMPOST_SWEET_ROT_AIM_FILL_ALPHA_MULTIPLIER);
					draw_circle(_mouse_x, _mouse_y, _sweet_rot_draw_radius, false);
					draw_set_alpha(target_selection_outline_alpha);
					draw_circle(_mouse_x, _mouse_y, _sweet_rot_draw_radius, true);
				}

				var _draw_primary_radius = target_selection_projectile_type != PROJECTILE_TYPE.HEAL
					|| global.shell_factory_first_aid_enchantment != FIRST_AID_MEAT_ENCHANTMENT.EMERGENCY_PULL;

				if (_draw_primary_radius)
				{
					draw_set_color(_target_color);
					draw_set_alpha(target_selection_alpha);
					draw_circle(_mouse_x, _mouse_y, _draw_radius, false);
					draw_set_alpha(target_selection_outline_alpha);
					draw_circle(_mouse_x, _mouse_y, _draw_radius, true);
				}
			}

			// Necromedic previews the exact number of Bonelets created at the aimed position.
			if (target_selection_projectile_type == PROJECTILE_TYPE.HEAL
				&& global.shell_factory_first_aid_enchantment == FIRST_AID_MEAT_ENCHANTMENT.NECROMEDIC)
			{
				var _necromedic_bonelet_count = corpse_count_inside_radius_get(
					_mouse_world_x,
					_mouse_world_y,
					target_selection_radius,
					BALANCE_FIRST_AID_MEAT_NECROMEDIC_MAX_CORPSES
				);
				var _necromedic_count_text = "Bonelets: " + string(_necromedic_bonelet_count);
				var _necromedic_count_padding_x = 8;
				var _necromedic_count_padding_y = 5;
				var _necromedic_count_width = string_width(_necromedic_count_text)
					+ (_necromedic_count_padding_x * 2);
				var _necromedic_count_height = string_height(_necromedic_count_text)
					+ (_necromedic_count_padding_y * 2);

				draw_set_halign(fa_center);
				draw_set_valign(fa_middle);
				draw_set_alpha(0.86);
				draw_set_color(COLOR_HUD_BACKGROUND);
				draw_rectangle(
					_mouse_x - (_necromedic_count_width * 0.5),
					_mouse_y - (_necromedic_count_height * 0.5),
					_mouse_x + (_necromedic_count_width * 0.5),
					_mouse_y + (_necromedic_count_height * 0.5),
					false
				);

				draw_set_alpha(1);
				draw_set_color(COLOR_PROJECTILE_SKELETONS);
				draw_text(_mouse_x, _mouse_y, _necromedic_count_text);
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
	}
}
