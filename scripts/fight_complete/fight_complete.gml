/// @description Clears the battlefield and unlocks progression or victory; controller context.
function fight_complete()
{
	if (fight_state != FIGHT_STATE.ACTIVE) return;
	fight_state = fight_number >= BALANCE_FIGHT_COUNT ? FIGHT_STATE.WON : FIGHT_STATE.CLEARED;
	// Cancel airborne damage so a cleared fight cannot kill the Cannon afterward.
	with (o_projectile) instance_destroy();
	with (o_enemy_units)
	{
		hp = 0;
		unit_death_process();
	}
	// Completion never fires the Cannon. Cancel outstanding shots and effects.
	cannon_aiming = false;
	with (o_cargo_flight)
	{
		cargo_land(payload, BALANCE_BUILDING_GRID_CENTER_X, BALANCE_BUILDING_GRID_CENTER_Y + random_range(BALANCE_CARGO_RETURN_MIN_Y, BALANCE_CARGO_RETURN_MAX_Y), false);
		instance_destroy();
	}
	with (o_cannonball) instance_destroy();
	with (o_cannon_effect) instance_destroy();
	global.pause = true;
	player_pause_active = false;
}
