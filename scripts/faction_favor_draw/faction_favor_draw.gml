/// @description Draws all faction Favor scores at the top right with the elimination clock below the faction list; controller context.
function faction_favor_draw()
{
	if (!faction_match_started || faction_selection_active || faction_selection_release_pending) return;
	var _width = display_get_gui_width();
	var _height = display_get_gui_height();
	var _scale = clamp(_height / 1080, 0.6, 1);
	var _right = _width - 20 * _scale;
	var _left = _right - 285 * _scale;
	var _top = 20 * _scale;
	draw_set_alpha(0.8);
	draw_set_color(c_black);
	draw_rectangle(_left, _top, _right, _top + 170 * _scale, false);
	draw_set_alpha(1);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(COLOR_HUD_TEXT);
	draw_text_transformed(_left + 12 * _scale, _top + 10 * _scale, "FAVOR", _scale, _scale, 0);
	for (var _index = 0; _index < array_length(faction_match_states); ++_index)
	{
		var _state = faction_match_states[_index];
		var _y = _top + (42 + _index * 30) * _scale;
		draw_set_color(corruption_color_get(_state.faction));
		draw_set_halign(fa_left);
		draw_text_transformed(_left + 12 * _scale, _y, _state.name + (_state.defeated ? " (out)" : ""), _scale, _scale, 0);
		draw_set_halign(fa_right);
		draw_set_color(COLOR_HUD_TEXT);
		draw_text_transformed(_right - 12 * _scale, _y, string(global.faction_favor[_state.faction]), _scale, _scale, 0);
	}
	if (!faction_match_finished)
	{
		var _seconds = ceil(faction_favor_seconds_remaining);
		var _clock = string(floor(_seconds / 60)) + ":" + string_format(_seconds mod 60, 2, 0);
		_clock = string_replace_all(_clock, " ", "0");
		var _cx = (_left + _right) * 0.5;
		var _cy = _top + (170 + 10 + 35) * _scale;
		draw_set_alpha(0.7);
		draw_set_color(c_black);
		draw_rectangle(_left, _cy - 35 * _scale, _right, _cy + 35 * _scale, false);
		draw_set_alpha(1);
		draw_set_color(COLOR_HUD_TEXT);
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		draw_text_transformed(_cx, _cy - 12 * _scale, "Next elimination", _scale, _scale, 0);
		draw_text_transformed(_cx, _cy + 14 * _scale, _clock, _scale, _scale, 0);
	}
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
	draw_set_alpha(1);
}
