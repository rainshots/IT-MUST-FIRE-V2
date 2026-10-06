/// @description Positions battle controls alongside the original squad and projectile HUD.
function battle_ui_layout_get()
{
	var _scale = min(display_get_gui_width() / 1366, display_get_gui_height() / 768);
	var _margin = 18 * _scale;
	// Match END DAY's dimensions at its original 1920 by 1080 design resolution.
	var _button_scale = min(display_get_gui_width() / 1920, display_get_gui_height() / 1080);
	var _button_width = 353 * _button_scale;
	var _button_height = 88 * _button_scale;
	var _roster_scale = clamp(display_get_gui_height() / 1080, 0.6, 1);
	var _layout = {
		scale: _scale,
		card_x: 53 * _roster_scale, card_y: 58 * _roster_scale,
		card_width: 112 * _roster_scale, card_height: 145 * _roster_scale,
		gap: 19 * _roster_scale,
		button_x: display_get_gui_width() - _margin - _button_width,
		button_y: display_get_gui_height() - _margin - _button_height,
		button_width: _button_width, button_height: _button_height,
		button_scale: _button_scale,
		mouse_is_over_ui: false
	};

	// Empty roster slots also block world commands; projectile input uses the original HUD hit test.
	var _mouse_x = device_mouse_x_to_gui(0);
	var _mouse_y = device_mouse_y_to_gui(0);
	var _roster_width = (BALANCE_BATTLE_ROSTER_LIMIT * (_layout.card_width + _layout.gap)) - _layout.gap;
	_layout.mouse_is_over_ui = ui_mouse_is_inside_rect(_mouse_x, _mouse_y,
		_layout.card_x, _layout.card_y, _roster_width, _layout.card_height)
		|| ui_mouse_is_inside_rect(_mouse_x, _mouse_y,
			_layout.button_x, _layout.button_y, _layout.button_width, _layout.button_height);
	if (!_layout.mouse_is_over_ui && instance_exists(o_game_controller))
	{
		_layout.mouse_is_over_ui = is_struct(battle_shell_slot_at_gui(
			_mouse_x, _mouse_y, instance_find(o_game_controller, 0)));
	}
	return _layout;
}
