// Draw shared unit visuals first.
event_inherited();

// Draw remaining-night markers under the health bar.
if (variable_instance_exists(id, "summon_nights_remaining"))
{
	var _square_size = 4;
	var _square_gap = 3;
	var _square_count = max(0, summon_nights_remaining);
	var _total_width = (_square_count * _square_size) + (max(0, _square_count - 1) * _square_gap);
	var _start_x = x - (_total_width * 0.5);
	var _square_y = y - bar_offset_y + bar_height + 4;

	draw_set_alpha(1);
	draw_set_color(COLOR_HUD_SOULS);

	for (var _square_index = 0; _square_index < _square_count; ++_square_index)
	{
		var _square_x = _start_x + ((_square_size + _square_gap) * _square_index);

		draw_rectangle(_square_x, _square_y, _square_x + _square_size, _square_y + _square_size, false);
	}
}

// Restore default draw state.
draw_set_color(c_white);
draw_set_alpha(1);
