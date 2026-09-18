/// @description Rewards surviving upgraded trees, then removes all garden entities before morning or victory.
function dark_garden_night_end()
{
	with (o_dark_tree)
	{
		if (global.day_phase == DAY_PHASE.NIGHT && hp > 0 && instance_exists(source_cannon)
			&& source_cannon.dark_garden_upgrade == DARK_GARDEN_UPGRADE.CORRUPTION)
		{
			corrupt_circle(x, y, BALANCE_DARK_GARDEN_CORRUPTION_RADIUS,
				BALANCE_DARK_GARDEN_CORRUPTION_AMOUNT, true);
		}
		instance_destroy();
	}
	with (o_dark_seed) instance_destroy();
	with (o_dark_berry) instance_destroy();
	with (o_projectile)
	{
		if (projectile_type == PROJECTILE_TYPE.DARK_GARDEN) instance_destroy();
	}
}
