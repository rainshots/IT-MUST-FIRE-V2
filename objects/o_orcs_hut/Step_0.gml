// Pause freezes capture and hut worker management.
if (global.pause)
{
	exit;
}

// Check whether the ground under the hut has fully corrupted.
tower_capture_update();

if (!is_captured)
{
	exit;
}

orcs_hut_spawn_orcs();
orcs_hut_recall_orcs();
