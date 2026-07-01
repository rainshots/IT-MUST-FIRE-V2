// Pause freezes capture checks.
map_building_warning_update();

if (global.pause)
{
	exit;
}

// Check whether the ground under the Pitlings House has fully corrupted.
tower_capture_update();
