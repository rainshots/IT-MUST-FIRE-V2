// Trees are decorative, so corruption is checked on a staggered timer for large forests.
if (global.pause || is_corrupted)
{
	exit;
}

corruption_check_timer++;

if (corruption_check_timer < corruption_check_interval)
{
	exit;
}

corruption_check_timer = 0;
tree_corruption_update();
