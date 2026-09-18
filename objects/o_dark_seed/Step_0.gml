// Garden entities exist only during the night; timers use scaled, unpaused gameplay time.
if (global.day_phase != DAY_PHASE.NIGHT)
{
	instance_destroy();
	exit;
}
if (global.pause)
{
	exit;
}

growth_remaining -= global.gameplay_time_scale;
if (growth_remaining <= 0)
{
	var _tree = instance_create_layer(x, y, "Instances", o_dark_tree);
	_tree.source_cannon = source_cannon;
	instance_destroy();
}
