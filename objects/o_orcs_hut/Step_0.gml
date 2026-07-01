// Pause freezes capture and hut worker management.
map_building_warning_update();

if (global.pause)
{
	exit;
}

// Check whether the ground under the hut has fully corrupted.
tower_capture_update();

if (variable_instance_exists(id, "building_constructed_by_shell") && building_constructed_by_shell)
{
	corruption = ground_cell_corruption_get(x, y) * max_corruption;
	is_captured = corruption > 0;

	if (is_captured)
	{
		sprite_index = captured_sprite_index;
	}
	else
	{
		sprite_index = uncaptured_sprite_index;
	}
}

if (!is_captured)
{
	exit;
}

orcs_hut_spawn_orcs();
orcs_hut_recall_orcs();
