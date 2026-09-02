// The balance controller owns simulation ticks during deterministic test runs.
if (variable_global_exists("balance_test_active")
	&& global.balance_test_active
	&& (!variable_global_exists("balance_test_manual_tick_active")
		|| !global.balance_test_manual_tick_active))
{
	exit;
}

if (global.pause)
{
	exit;
}

// Healing and lifetime follow scaled gameplay time.
var _time_scale = variable_global_exists("gameplay_time_scale")
	? global.gameplay_time_scale
	: 1;
var _previous_life_timer = life_timer;

if (first_aid_meat_enchantment == FIRST_AID_MEAT_ENCHANTMENT.EMERGENCY_PULL)
{
	first_aid_meat_pull_update(_time_scale);
}

life_timer = min(life_timer + _time_scale, life_duration);
heal_timer += life_timer - _previous_life_timer;

// Process every elapsed one-second pulse, including the final pulse at four seconds.
var _heal_tick_count = floor(heal_timer / heal_interval);

if (_heal_tick_count > 0)
{
	heal_timer -= _heal_tick_count * heal_interval;

	for (var _heal_tick_index = 0; _heal_tick_index < _heal_tick_count; ++_heal_tick_index)
	{
		first_aid_meat_heal_nearby_units();
	}
}

if (life_timer >= life_duration)
{
	instance_destroy();
}
