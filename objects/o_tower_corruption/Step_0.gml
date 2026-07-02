// Pause freezes tower capture and spreading.
map_building_warning_update();

if (global.pause)
{
	exit;
}

// Check whether the ground under the tower has fully corrupted.
tower_capture_update();
