// Trees are decorative, so expensive checks run on staggered timers for large forests.
if (!world_map_decoration && variable_global_exists("pause") && global.pause)
{
	exit;
}

if (!world_map_decoration)
{
	tree_unit_occlusion_update();
	unit_fade_alpha = lerp(unit_fade_alpha, unit_fade_target_alpha, BALANCE_TREE_UNIT_FADE_LERP_SPEED);
	image_alpha = unit_fade_alpha;
}

if (is_corrupted)
{
	exit;
}

var _time_scale = 1;
if (!world_map_decoration && variable_global_exists("gameplay_time_scale"))
{
	_time_scale = global.gameplay_time_scale;
}
corruption_check_timer += _time_scale;

if (corruption_check_timer < corruption_check_interval)
{
	exit;
}

corruption_check_timer = 0;
tree_corruption_update();
