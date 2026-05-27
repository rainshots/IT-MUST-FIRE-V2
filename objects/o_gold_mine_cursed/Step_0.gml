// Cursed gold mines produce gold passively during the day.
if (global.pause)
{
	exit;
}

// V13 keeps legacy economy building conditions disabled for now.
if (variable_global_exists("legacy_building_logic_enabled") && !global.legacy_building_logic_enabled)
{
	exit;
}

if (global.day_phase != DAY_PHASE.DAY)
{
	day_reward_timer = day_reward_interval;
	exit;
}

day_reward_timer--;

if (day_reward_timer <= 0)
{
	give_gold_reward(day_gold_reward);
	day_reward_timer = day_reward_interval;
}
