// Pause freezes capture checks.
if (global.pause)
{
	exit;
}

// Check whether the ground under the boneyard has fully corrupted.
tower_capture_update();
