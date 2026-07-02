/// @description Draws balance-defined HP separators over a health bar.
/// @param {real} _bar_x Left side of the health bar.
/// @param {real} _bar_y Top side of the health bar.
/// @param {real} _bar_width Health bar width.
/// @param {real} _bar_height Health bar height.
/// @param {real} _max_hp Maximum HP represented by the full bar.
function health_bar_segments_draw(_bar_x, _bar_y, _bar_width, _bar_height, _max_hp)
{
	if (_max_hp <= BALANCE_HEALTH_BAR_SEGMENT_HP)
	{
		return;
	}

	var _segment_count = floor(_max_hp / BALANCE_HEALTH_BAR_SEGMENT_HP);
	var _line_width = 1;

	for (var _segment_index = 1; _segment_index <= _segment_count; ++_segment_index)
	{
		var _segment_hp = _segment_index * BALANCE_HEALTH_BAR_SEGMENT_HP;

		if (_segment_hp >= _max_hp)
		{
			break;
		}

		var _segment_x = _bar_x + (_bar_width * (_segment_hp / _max_hp));

		draw_line_width(
			_segment_x,
			_bar_y,
			_segment_x,
			_bar_y + _bar_height,
			_line_width
		);
	}
}
