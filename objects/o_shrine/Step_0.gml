// Pause freezes shrine corruption checks.
if (global.pause)
{
	exit;
}

if (is_corrupted)
{
	exit;
}

shrine_defender_spawner_update();

// A shrine is infected when the ground directly beneath it becomes fully corrupted.
corruption = ground_cell_corruption_get(x, y) * max_corruption;

if (ground_cell_has_full_corruption(x, y))
{
	shrine_corrupt();
}
