// Pause freezes terrain dependency and production.
if (global.pause)
{
	exit;
}

// Shell-built buildings stop working when their ground is cleansed.
corruption_check_timer++;

if (corruption_check_timer >= corruption_check_interval)
{
	corruption_check_timer = 0;
	corruption = ground_cell_corruption_get(x, y) * max_corruption;
	is_captured = corruption > 0;
}

ihor_extractor_morning_income_preview_get();
