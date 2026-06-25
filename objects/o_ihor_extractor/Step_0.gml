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

var _production_speed = ihor_extractor_production_speed_get();

if (!is_captured
	|| _production_speed <= 0
	|| !variable_global_exists("day_phase")
	|| global.day_phase != DAY_PHASE.DAY)
{
	exit;
}

// Active veins speed up the production cycle.
ihor_production_progress += _production_speed / max(1, ihor_production_time);

if (ihor_production_progress >= 1)
{
	ihor_production_progress -= 1;
	ihor_extractor_consume_active_vein();
	global.resources[RESOURCES.IHOR] += 1;
	resource_popup_create(x, y - ihor_popup_offset_y, RESOURCES.IHOR, 1);
}
