// Pause freezes totem lifetime and curse ticks.
if (global.pause)
{
	exit;
}

life_timer--;

if (life_timer <= 0)
{
	instance_destroy();
	exit;
}

// Curse nearby enemies on a periodic pulse.
if (curse_tick_timer > 0)
{
	curse_tick_timer--;
}

if (curse_tick_timer <= 0)
{
	hex_totem_curse_nearby_enemies();
	curse_tick_timer = BALANCE_WARLOCK_HEX_TOTEM_TICK_TIME * room_speed;
}

// Nearby meat extends the temporary totem lifetime.
if (meat_check_timer > 0)
{
	meat_check_timer--;
}

if (meat_check_timer <= 0)
{
	hex_totem_meat_absorb_try();
	meat_check_timer = BALANCE_WARLOCK_HEX_TOTEM_MEAT_CHECK_TIME * room_speed;
}
