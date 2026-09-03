// Pause freezes tower capture and spreading.
map_building_warning_update();
map_object_unit_fade_update();

if (global.pause)
{
	exit;
}

// A destroyed tower stays inert until its morning repair.
if (player_map_building_destroy_if_needed())
{
	exit;
}

// Check whether the ground under the tower has fully corrupted.
tower_capture_update();
