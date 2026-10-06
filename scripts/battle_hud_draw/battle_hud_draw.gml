/// @description Draws battle world previews and phase controls alongside the original HUD.
function battle_hud_draw(_controller)
{
	// The original structure selection window draws its own modal GUI.
	if (global.focus_window == FOCUS_WINDOW.CURSED_POINT_STRUCTURE_SELECTION)
	{
		return;
	}

	var _layout = battle_ui_layout_get();
	var _scale = _layout.scale;
	var _phase = _controller.battle_phase;
	var _preparing = _phase == BATTLE_PHASE.PREPARATION;
	var _finished = _phase == BATTLE_PHASE.VICTORY || _phase == BATTLE_PHASE.DEFEAT;
	var _camera = view_camera[0];
	var _camera_x = camera_get_view_x(_camera);
	var _camera_y = camera_get_view_y(_camera);
	var _world_scale = display_get_gui_width() / camera_get_view_width(_camera);
	draw_set_font(global.ui_font);
	draw_set_alpha(1);

	// Reuse the original F5 overlay beneath squad markers and battle controls.
	_controller.wall_navigation_debug_draw();

	// Existing night flags remain the combat interface; preparation flags use the same hit positions.
	var _squads = global.squads;
	var _squad_count = array_length(_squads);
	if (!_preparing)
	{
		squad_orders_draw_gui();
		squad_night_markers_draw_gui();
		draw_set_font(global.ui_font);
	}
	else
	{
		for (var _index = 0; _index < _squad_count; ++_index)
		{
			var _squad = _squads[_index];
			if (!_squad.properties.battle_deployed) continue;
			var _x = (_squad.properties.marker_x - _camera_x) * _world_scale;
			var _y = (_squad.properties.marker_y - _camera_y) * _world_scale;
			draw_set_color(COLOR_BATTLE_TAINT);
			draw_circle(_x, _y, 20 * _scale, true);
			draw_text(_x, _y - (38 * _scale), _squad.name);
		}
	}

	// Preview every member of a dragged squad; colors match the actual placement validator.
	var _positions = _controller.battle_preview_positions;
	var _preview_count = array_length(_positions);
	for (var _index = 0; _index < _preview_count; ++_index)
	{
		var _position = _positions[_index];
		draw_set_color(_controller.battle_preview_valid ? COLOR_BATTLE_TAINT : COLOR_BATTLE_INVALID);
		draw_set_alpha(0.65);
		draw_circle((_position.x - _camera_x) * _world_scale, (_position.y - _camera_y) * _world_scale,
			BALANCE_BATTLE_UNIT_MARGIN * _world_scale, false);
	}
	draw_set_alpha(1);

	// Use the original shell radii, Hellcow corridor, and aiming hints.
	cannon_target_draw_gui(_controller);

	// Keep the phase controls compact; o_hud draws the unchanged roster and ammunition.
	var _phase_name = _preparing ? "PREPARATION PHASE" : "BATTLE PHASE";
	if (_finished)
	{
		_phase_name = _phase == BATTLE_PHASE.VICTORY ? "VICTORY" : "DEFEAT";
	}
	var _status = _preparing
		? "Squads: " + string(_controller.battle_deployed_count) + " / " + string(BALANCE_BATTLE_DEPLOYMENT_LIMIT)
		: "Enemies: " + string(_controller.battle_enemy_count) + "    " + string(floor(_controller.battle_elapsed_seconds)) + "s";
	var _control_center_x = _layout.button_x + (_layout.button_width * 0.5);
	var _text_gap = 12 * _scale;
	draw_set_halign(fa_center);
	draw_set_valign(fa_bottom);
	draw_set_color(COLOR_HUD_TEXT);
	draw_text(_control_center_x, _layout.button_y - _text_gap, _phase_name + "\n" + _status);

	// Preparation feedback sits below the original roster instead of a full-width toolbar.
	if (_preparing && _controller.battle_feedback != "")
	{
		var _roster_width = (BALANCE_BATTLE_ROSTER_LIMIT * (_layout.card_width + _layout.gap)) - _layout.gap;
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		var _damage_label_height = string_height("Damage: 0.0");
		draw_text_ext(_layout.card_x, _layout.card_y + _layout.card_height + _damage_label_height + (_text_gap * 2),
			_controller.battle_feedback, -1, _roster_width);
	}

	// Start matches END DAY: red fill, double frame, bold text, pulse, and hover enlargement.
	if (_preparing)
	{
		var _button_hovered = ui_mouse_is_inside_rect(device_mouse_x_to_gui(0), device_mouse_y_to_gui(0),
			_layout.button_x, _layout.button_y, _layout.button_width, _layout.button_height);
		var _pulse_period = 260;
		var _pulse_scale_min = 0.98;
		var _pulse_scale_range = 0.04;
		var _hover_scale = 1.06;
		var _pulse = 0.5 + (sin(current_time / _pulse_period) * 0.5);
		var _visual_scale = (_pulse_scale_min + (_pulse * _pulse_scale_range))
			* (_button_hovered ? _hover_scale : 1);
		var _center_y = _layout.button_y + (_layout.button_height * 0.5);
		var _visual_width = _layout.button_width * _visual_scale;
		var _visual_height = _layout.button_height * _visual_scale;
		var _visual_x = _control_center_x - (_visual_width * 0.5);
		var _visual_y = _center_y - (_visual_height * 0.5);
		var _border_width = 2;

		draw_set_alpha(1);
		draw_set_color(COLOR_JOBS_ASSIGN_BACKGROUND);
		draw_rectangle(_visual_x, _visual_y, _visual_x + _visual_width, _visual_y + _visual_height, false);
		draw_set_color(COLOR_JOBS_ASSIGN_BORDER);
		for (var _border_index = 0; _border_index < _border_width; ++_border_index)
		{
			draw_rectangle(_visual_x + _border_index, _visual_y + _border_index,
				_visual_x + _visual_width - _border_index, _visual_y + _visual_height - _border_index, true);
		}

		// Fit the longer battle label with the same padding and font as END DAY.
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		draw_set_color(COLOR_JOBS_ASSIGN_TEXT);
		draw_set_font(_controller.battle_button_font);
		var _button_text = "START THE BATTLE";
		var _text_padding_x = 20 * _layout.button_scale;
		var _text_padding_y = 12 * _layout.button_scale;
		var _text_scale = _layout.button_scale * _visual_scale;
		var _text_width = string_width(_button_text) * _text_scale;
		var _text_height = string_height(_button_text) * _text_scale;
		var _text_fit = min(1, min(
			(_visual_width - (_text_padding_x * 2)) / max(1, _text_width),
			(_visual_height - (_text_padding_y * 2)) / max(1, _text_height)));
		_text_scale *= _text_fit;
		draw_text_transformed(_control_center_x, _center_y, _button_text, _text_scale, _text_scale, 0);
		draw_set_font(global.ui_font);
	}
	else if (_finished)
	{
		draw_set_alpha(0.94);
		draw_set_color(COLOR_HUD_BACKGROUND);
		draw_rectangle(_layout.button_x, _layout.button_y,
			_layout.button_x + _layout.button_width, _layout.button_y + _layout.button_height, false);
		draw_set_alpha(1);
		draw_set_color(COLOR_PROJECTILE_SUMMON);
		draw_rectangle(_layout.button_x, _layout.button_y,
			_layout.button_x + _layout.button_width, _layout.button_y + _layout.button_height, true);
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		draw_set_color(COLOR_HUD_TEXT);
		var _button_text = "RETURN TO WORLD MAP";
		draw_text(_control_center_x, _layout.button_y + (_layout.button_height * 0.5), _button_text);
	}
	else
	{
		draw_set_halign(fa_center);
		draw_set_valign(fa_top);
		draw_text(_control_center_x, _layout.button_y,
			_controller.night_fast_forward_active ? "Q: SPEED x2" : "Q: SPEED x1");
	}
	if (global.pause && !_finished)
	{
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		draw_set_color(COLOR_HUD_TEXT);
		draw_text(display_get_gui_width() * 0.5, display_get_gui_height() * 0.5, "PAUSED - Space / Esc to resume");
	}

	// Restore project draw defaults.
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
	draw_set_alpha(1);
}
