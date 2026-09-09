/// @description Returns the next squad-slot unlock day, or -1 when no more slots will open.
/// @param {Real} current_limit Number of shared squad slots already unlocked.
function squad_limit_next_unlock_day_get(_current_limit)
{
	if (_current_limit >= BALANCE_SQUAD_LIMIT)
	{
		return -1;
	}

	// Use the unlocked limit so the upcoming slot stays visible until morning.
	var _unlock_days = [
		BALANCE_SQUAD_LIMIT_UNLOCK_DAY_1,
		BALANCE_SQUAD_LIMIT_UNLOCK_DAY_2
	];
	var _unlock_day_count = array_length(_unlock_days);
	var _next_unlock_day = -1;

	for (var _day_index = 0; _day_index < _unlock_day_count; ++_day_index)
	{
		var _unlock_day = _unlock_days[_day_index];

		if ((_next_unlock_day < 0 || _unlock_day < _next_unlock_day)
			&& squad_limit_for_day_get(_unlock_day) > _current_limit)
		{
			_next_unlock_day = _unlock_day;
		}
	}

	return _next_unlock_day;
}
