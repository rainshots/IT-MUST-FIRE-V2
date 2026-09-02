/// @description Provides Cannon Satisfaction tiers and their gameplay modifiers.

function cannon_satisfaction_get()
{
	if (!variable_global_exists("cannon_satisfaction"))
	{
		return BALANCE_CANNON_SATISFACTION_START;
	}

	return clamp(global.cannon_satisfaction, 0, BALANCE_CANNON_SATISFACTION_MAX);
}

function cannon_satisfaction_add(_amount)
{
	var _previous_level = cannon_satisfaction_level_get();
	global.cannon_satisfaction = clamp(
		cannon_satisfaction_get() + _amount,
		0,
		BALANCE_CANNON_SATISFACTION_MAX
	);
	var _current_level = cannon_satisfaction_level_get();

	if (_current_level != _previous_level)
	{
		cannon_satisfaction_level_effects_refresh(_previous_level, _current_level);
	}

	return global.cannon_satisfaction;
}

function cannon_satisfaction_level_get()
{
	var _satisfaction = cannon_satisfaction_get();

	if (_satisfaction >= BALANCE_CANNON_SATISFACTION_IT_MUST_FIRE_MIN)
	{
		return CANNON_SATISFACTION_LEVEL.IT_MUST_FIRE;
	}
	else if (_satisfaction >= BALANCE_CANNON_SATISFACTION_ECSTATIC_MIN)
	{
		return CANNON_SATISFACTION_LEVEL.ECSTATIC;
	}
	else if (_satisfaction >= BALANCE_CANNON_SATISFACTION_PLAYFUL_MIN)
	{
		return CANNON_SATISFACTION_LEVEL.PLAYFUL;
	}
	else if (_satisfaction >= BALANCE_CANNON_SATISFACTION_AWAKE_MIN)
	{
		return CANNON_SATISFACTION_LEVEL.AWAKE;
	}

	return CANNON_SATISFACTION_LEVEL.SULKING;
}

function cannon_satisfaction_sprite_get(_level = cannon_satisfaction_level_get())
{
	switch (_level)
	{
		case CANNON_SATISFACTION_LEVEL.SULKING:
			return s_cannon_angry;

		case CANNON_SATISFACTION_LEVEL.ECSTATIC:
		case CANNON_SATISFACTION_LEVEL.IT_MUST_FIRE:
			return s_cannon_pleased;
	}

	return s_cannon_awake;
}

function cannon_satisfaction_level_name_get(_level = cannon_satisfaction_level_get())
{
	switch (_level)
	{
		case CANNON_SATISFACTION_LEVEL.SULKING:
			return "Sulking";

		case CANNON_SATISFACTION_LEVEL.AWAKE:
			return "Awake";

		case CANNON_SATISFACTION_LEVEL.PLAYFUL:
			return "Playful";

		case CANNON_SATISFACTION_LEVEL.ECSTATIC:
			return "Ecstatic";

		case CANNON_SATISFACTION_LEVEL.IT_MUST_FIRE:
			return "It Must Fire";
	}

	return "Awake";
}

function cannon_satisfaction_effect_text_get(_level = cannon_satisfaction_level_get())
{
	switch (_level)
	{
		case CANNON_SATISFACTION_LEVEL.SULKING:
			return "- All events cost an additional 5 Cultist HP.\n- Cannon reload time is 30% slower.";

		case CANNON_SATISFACTION_LEVEL.AWAKE:
			return "- No effects.";

		case CANNON_SATISFACTION_LEVEL.PLAYFUL:
			return "- Cannon reload time is 15% faster.\n- You can reroll 1 building Rite per day.";

		case CANNON_SATISFACTION_LEVEL.ECSTATIC:
			return "- Cannon reload time is 20% faster.\n- You can reroll 1 building Rite per day.";

		case CANNON_SATISFACTION_LEVEL.IT_MUST_FIRE:
			return "- The Cannon fires at enemies every 20 seconds without consuming player shells.\n- Cannon reload time is 25% faster.\n- You can reroll 2 building Rites per day.";
	}

	return "- No effects.";
}

function cannon_satisfaction_reload_time_multiplier_get()
{
	switch (cannon_satisfaction_level_get())
	{
		case CANNON_SATISFACTION_LEVEL.SULKING:
			return BALANCE_CANNON_SATISFACTION_SULKING_RELOAD_TIME_MULTIPLIER;

		case CANNON_SATISFACTION_LEVEL.PLAYFUL:
			return 1 / BALANCE_CANNON_SATISFACTION_PLAYFUL_RELOAD_SPEED_MULTIPLIER;

		case CANNON_SATISFACTION_LEVEL.ECSTATIC:
			return 1 / BALANCE_CANNON_SATISFACTION_ECSTATIC_RELOAD_SPEED_MULTIPLIER;

		case CANNON_SATISFACTION_LEVEL.IT_MUST_FIRE:
			return 1 / BALANCE_CANNON_SATISFACTION_IT_MUST_FIRE_RELOAD_SPEED_MULTIPLIER;
	}

	return 1;
}

function cannon_satisfaction_daily_reroll_count_for_level_get(_level)
{
	if (_level >= CANNON_SATISFACTION_LEVEL.IT_MUST_FIRE)
	{
		return BALANCE_CANNON_SATISFACTION_IT_MUST_FIRE_DAILY_REROLL_COUNT;
	}

	if (_level >= CANNON_SATISFACTION_LEVEL.PLAYFUL)
	{
		return BALANCE_CANNON_SATISFACTION_PLAYFUL_DAILY_REROLL_COUNT;
	}

	return 0;
}

function cannon_satisfaction_daily_reroll_count_get()
{
	return cannon_satisfaction_daily_reroll_count_for_level_get(cannon_satisfaction_level_get());
}

function cannon_satisfaction_level_effects_refresh(_previous_level, _current_level)
{
	if (_previous_level == _current_level)
	{
		return false;
	}

	// Preserve active reload progress while applying the new tier multiplier.
	if (instance_exists(o_cannon))
	{
		var _cannon = instance_find(o_cannon, 0);
		_cannon.sprite_index = cannon_satisfaction_sprite_get(_current_level);
		_cannon.image_index = 0;

		if (variable_instance_exists(_cannon, "cannon_reload_satisfaction_recalculate"))
		{
			_cannon.cannon_reload_satisfaction_recalculate();
		}
	}

	// Satisfaction tier changes update today's still-available Rerolls immediately.
	if (variable_global_exists("day_event_rerolls_remaining"))
	{
		var _previous_reroll_count = cannon_satisfaction_daily_reroll_count_for_level_get(_previous_level);
		var _current_reroll_count = cannon_satisfaction_daily_reroll_count_for_level_get(_current_level);
		var _reroll_count_change = _current_reroll_count - _previous_reroll_count;
		global.day_event_rerolls_remaining = max(
			global.day_event_rerolls_remaining + _reroll_count_change,
			0
		);
	}

	return true;
}

function cannon_satisfaction_event_hp_cost_get()
{
	return cannon_satisfaction_level_get() == CANNON_SATISFACTION_LEVEL.SULKING
		? BALANCE_CANNON_SATISFACTION_SULKING_EVENT_HP_COST
		: 0;
}
