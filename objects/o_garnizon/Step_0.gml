// Pause freezes garnizon spawning.
if (global.pause)
{
	exit;
}

// Activate when damaged or when corrupted ground gets close enough.
if (hp < previous_hp)
{
	activate_garnizon();
}

previous_hp = hp;
activation_check_timer++;

if (!is_activated && activation_check_timer >= activation_check_interval)
{
	activation_check_timer = 0;

	if (has_corrupted_cell_nearby())
	{
		activate_garnizon();
	}
}

// Activated garnizons release their prepared troops during the current night.
if (global.day_phase == DAY_PHASE.NIGHT)
{
	if (is_activated && !has_released_current_night)
	{
		release_owned_units();
	}

	exit;
}

has_released_current_night = false;

// Spawn one guard at a fixed interval for the next attack wave.
spawn_timer--;
if (spawn_timer <= 0)
{
	spawn_guard_unit();
	spawn_timer = spawn_interval;
}
