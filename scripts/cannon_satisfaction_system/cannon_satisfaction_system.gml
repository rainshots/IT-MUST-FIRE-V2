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
	global.cannon_satisfaction = clamp(
		cannon_satisfaction_get() + _amount,
		0,
		BALANCE_CANNON_SATISFACTION_MAX
	);

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
			return "- All events cost an additional 5 Cultist HP.";

		case CANNON_SATISFACTION_LEVEL.AWAKE:
			return "- No effects.";

		case CANNON_SATISFACTION_LEVEL.PLAYFUL:
			return "- Hellcow and First Aid Meat shells recharge 15% faster.";

		case CANNON_SATISFACTION_LEVEL.ECSTATIC:
			return "- Hellcow and First Aid Meat shells recharge 25% faster.\n- Grants +1 Reroll each day.";

		case CANNON_SATISFACTION_LEVEL.IT_MUST_FIRE:
			return "- The Cannon fires at enemies every 20 seconds without consuming shells.\n- Hellcow and First Aid Meat shells recharge 30% faster.\n- Grants +1 Reroll each day.";
	}

	return "- No effects.";
}

function cannon_satisfaction_shell_recharge_multiplier_get()
{
	switch (cannon_satisfaction_level_get())
	{
		case CANNON_SATISFACTION_LEVEL.PLAYFUL:
			return 1.15;

		case CANNON_SATISFACTION_LEVEL.ECSTATIC:
			return 1.25;

		case CANNON_SATISFACTION_LEVEL.IT_MUST_FIRE:
			return 1.3;
	}

	return 1;
}

function cannon_satisfaction_daily_reroll_bonus_get()
{
	return cannon_satisfaction_level_get() >= CANNON_SATISFACTION_LEVEL.ECSTATIC
		? BALANCE_CANNON_SATISFACTION_DAILY_REROLL_BONUS
		: 0;
}

function cannon_satisfaction_event_hp_cost_get()
{
	return cannon_satisfaction_level_get() == CANNON_SATISFACTION_LEVEL.SULKING
		? BALANCE_CANNON_SATISFACTION_SULKING_EVENT_HP_COST
		: 0;
}
