// Pause freezes garnizon spawning.
if (global.pause)
{
	exit;
}

// Release guards when the group grows large enough.
var _owned_unit_count = count_owned_units();
if (_owned_unit_count > release_unit_count)
{
	release_owned_units();
}

// Spawn one guard at a fixed interval for the next attack wave.
spawn_timer--;
if (spawn_timer <= 0)
{
	spawn_guard_unit();
	spawn_timer = spawn_interval;
}
