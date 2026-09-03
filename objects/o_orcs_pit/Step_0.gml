// Pause freezes habitat presentation and destruction handling.
map_building_warning_update();
map_object_unit_fade_update();

if (global.pause)
{
	exit;
}

// A destroyed habitat stays inert until its morning repair.
if (player_map_building_destroy_if_needed())
{
	exit;
}
