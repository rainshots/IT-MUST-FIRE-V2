/// @description Returns health bar width expanded for high-HP targets.
/// @param {real} _base_width Normal health bar width.
/// @param {real} _max_hp Maximum HP represented by the full bar.
function health_bar_width_get(_base_width, _max_hp)
{
	var _segment_count = floor(_max_hp / BALANCE_HEALTH_BAR_SEGMENT_HP);

	if (_segment_count * BALANCE_HEALTH_BAR_SEGMENT_HP >= _max_hp)
	{
		_segment_count--;
	}

	_segment_count = max(0, _segment_count);

	if (_segment_count <= BALANCE_HEALTH_BAR_SEGMENT_WIDTH_LIMIT)
	{
		return _base_width;
	}

	return _base_width * (_segment_count / BALANCE_HEALTH_BAR_SEGMENT_WIDTH_LIMIT);
}
