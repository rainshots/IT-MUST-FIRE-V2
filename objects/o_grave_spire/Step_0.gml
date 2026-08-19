// Pause freezes the spire's terrain dependency check.
if (global.pause)
{
	exit;
}

var _time_scale = variable_global_exists("gameplay_time_scale") ? global.gameplay_time_scale : 1;
corruption_check_timer += _time_scale;

if (corruption_check_timer < corruption_check_interval)
{
	exit;
}

corruption_check_timer = 0;
corruption = ground_cell_corruption_get(x, y) * max_corruption;
is_captured = corruption > 0;
