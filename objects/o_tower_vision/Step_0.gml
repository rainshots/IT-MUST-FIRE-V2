// Pause freezes tower capture.
map_building_warning_update();
map_object_unit_fade_update();

if (global.pause)
{
	exit;
}

// Check whether the ground under the tower has fully corrupted.
tower_capture_update();
