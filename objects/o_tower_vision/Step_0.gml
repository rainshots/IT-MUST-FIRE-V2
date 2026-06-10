// Pause freezes tower capture.
if (global.pause)
{
	exit;
}

// Check whether the ground under the tower has fully corrupted.
tower_capture_update();
