// Trees are decorative, so expensive checks run on staggered timers for large forests.
if (global.pause)
{
	exit;
}

tree_unit_occlusion_update();
unit_fade_alpha = lerp(unit_fade_alpha, unit_fade_target_alpha, BALANCE_TREE_UNIT_FADE_LERP_SPEED);
image_alpha = unit_fade_alpha;

if (is_corrupted)
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
