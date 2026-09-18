/// @description Cancels Curing Spit fields and airborne shells before morning or final victory.
function curing_spit_night_end()
{
	with (o_curing_spit)
	{
		instance_destroy();
	}
	with (o_projectile)
	{
		if (projectile_type == PROJECTILE_TYPE.CURING_SPIT)
		{
			instance_destroy();
		}
	}
}
