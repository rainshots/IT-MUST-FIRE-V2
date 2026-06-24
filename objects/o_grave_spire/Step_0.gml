// Pause freezes the spire's terrain dependency check.
if (global.pause)
{
	exit;
}

corruption_check_timer++;

if (corruption_check_timer < corruption_check_interval)
{
	exit;
}

corruption_check_timer = 0;
corruption = ground_cell_corruption_get(x, y) * max_corruption;
is_captured = corruption > 0;
