/// @description Draws a large daytime cannon countdown at the bottom center. Call from Draw GUI.
function cannon_day_shot_hud_draw()
{
	// Read the firing cannon's timer so pausing and restarting the cycle stay synchronized.
	if (global.day_phase != DAY_PHASE.DAY || !instance_exists(o_player) || !instance_exists(o_cannon))
	{
		return;
	}

	var _cannon = instance_find(o_cannon, 0);
	var _interval = max(1 / max(1, room_speed), BALANCE_CANNON_DAY_SHOT_INTERVAL_SECONDS);
	var _remaining = clamp(_cannon.day_shot_remaining, 0, _interval);
	var _progress = 1 - (_remaining / _interval);
	var _warning_active = _remaining <= BALANCE_CANNON_DAY_SHOT_WARNING_SECONDS;

	// Fit below the End Day button using the same vertical scaling as the existing HUD.
	var _gui_width = display_get_gui_width();
	var _gui_height = display_get_gui_height();
	var _reference_height = 1080;
	var _minimum_scale = 0.6;
	var _scale = clamp(_gui_height / _reference_height, _minimum_scale, 1);
	var _bottom_margin = 8 * _scale;
	var _maximum_width = 760;
	var _screen_width_share = 0.6;
	var _bar_width = min(_maximum_width, _gui_width * _screen_width_share);
	var _bar_height = 44 * _scale;
	var _border_width = 2;
	var _bar_x = (_gui_width - _bar_width) * 0.5;
	var _bar_y = _gui_height - _bottom_margin - _bar_height;
	var _previous_font = draw_get_font();
	var _fill_color = _warning_active ? COLOR_CANNON_DAY_TARGET : COLOR_HUD_FLESH;

	if (variable_global_exists("ui_font") && font_exists(global.ui_font))
	{
		draw_set_font(global.ui_font);
	}

	// Fill toward the shot on an opaque background so the countdown stays readable.
	draw_set_alpha(1);
	draw_set_color(COLOR_HUD_BACKGROUND);
	draw_rectangle(_bar_x, _bar_y, _bar_x + _bar_width, _bar_y + _bar_height, false);
	draw_set_color(_fill_color);
	var _fill_width = (_bar_width - _border_width * 2) * _progress;

	if (_fill_width > 0)
	{
		draw_rectangle(
			_bar_x + _border_width,
			_bar_y + _border_width,
			_bar_x + _border_width + _fill_width,
			_bar_y + _bar_height - _border_width,
			false
		);
	}

	draw_rectangle(_bar_x, _bar_y, _bar_x + _bar_width, _bar_y + _bar_height, true);
	// Center a larger countdown inside the bar, with a shadow over the colored fill.
	var _label = "NEXT SHOT: " + string(ceil(_remaining)) + "s";
	var _avatar = instance_find(o_player, 0);
	if (_avatar.is_disassembled)
	{
		_label = "CANNON PAUSED - PARTS: " + string(_avatar.body_parts_collected) + "/" + string(array_length(_avatar.body_parts));
	}
	var _label_scale = 1.4;
	var _label_height_share = 0.7;
	_label_scale = min(_label_scale, (_bar_height * _label_height_share) / max(1, string_height(_label)));
	var _label_x = _gui_width * 0.5;
	var _label_y = _bar_y + _bar_height * 0.5;
	var _shadow_offset = 2;
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_set_color(COLOR_HUD_BACKGROUND);
	draw_text_transformed(_label_x + _shadow_offset, _label_y + _shadow_offset, _label, _label_scale, _label_scale, 0);
	draw_set_color(COLOR_HUD_TEXT);
	draw_text_transformed(_label_x, _label_y, _label, _label_scale, _label_scale, 0);

	// Restore the font and project draw defaults for other HUD elements.
	draw_set_font(_previous_font);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
	draw_set_alpha(1);
}
