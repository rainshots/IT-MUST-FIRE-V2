// Garden entities exist only during the night; timers use scaled, unpaused gameplay time.
if (global.day_phase != DAY_PHASE.NIGHT)
{
	instance_destroy();
	exit;
}
if (global.pause)
{
	exit;
}

if (hp <= 0)
{
	instance_destroy();
	exit;
}
berry_remaining -= global.gameplay_time_scale;
if (berry_remaining <= 0)
{
	berry_remaining += BALANCE_DARK_GARDEN_BERRY_TIME * room_speed;
	dark_garden_spawn_near(id, o_dark_berry);
}
// Only the selected upgrade enables attempts; a failed roll still resets the clock.
if (instance_exists(source_cannon)
	&& source_cannon.dark_garden_upgrade == DARK_GARDEN_UPGRADE.PROPAGATION)
{
	propagation_remaining -= global.gameplay_time_scale;
	if (propagation_remaining <= 0)
	{
		propagation_remaining += random_range(BALANCE_DARK_GARDEN_PROPAGATION_MIN_TIME,
			BALANCE_DARK_GARDEN_PROPAGATION_MAX_TIME) * room_speed;
		if (random(1) < BALANCE_DARK_GARDEN_PROPAGATION_CHANCE)
		{
			dark_garden_spawn_near(id, o_dark_seed);
		}
	}
}
