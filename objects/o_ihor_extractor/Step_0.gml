// Pause freezes terrain dependency and production.
if (global.pause)
{
	exit;
}

// Shell-built buildings stop working when their ground is cleansed.
var _time_scale = variable_global_exists("gameplay_time_scale") ? global.gameplay_time_scale : 1;
corruption_check_timer += _time_scale;

if (corruption_check_timer >= corruption_check_interval)
{
	corruption_check_timer = 0;
	corruption = ground_cell_corruption_get(x, y) * max_corruption;
	is_captured = corruption > 0;
}

ihor_extractor_morning_income_preview_get();
