// The field pulses once per second until its five-second lifetime ends.
life_duration = BALANCE_SUBZERO_FIELD_DURATION * room_speed;
life_timer = 0;
pulse_interval = max(1, BALANCE_SUBZERO_FIELD_PULSE_INTERVAL * room_speed);
pulse_count = 0;
effect_radius = BALANCE_SUBZERO_FIELD_RADIUS;
damage_amount = BALANCE_SUBZERO_FIELD_DAMAGE;
source_instance = noone;
slow_amount = BALANCE_SUBZERO_FIELD_SLOW_AMOUNT;
slow_duration = BALANCE_SUBZERO_FIELD_SLOW_DURATION;

subzero_field_pulse = function()
{
	// Area effects hit invisible enemies and use the shared magic-resistance calculation.
	with (o_enemy_units)
	{
		if (hp > 0 && unit_faction == UNIT_FACTION.ENEMY
			&& point_distance(x, y, other.x, other.y) <= other.effect_radius)
		{
			var _magic_damage = magic_damage_after_resistance(other.damage_amount, id);
			unit_damage_receive(_magic_damage, UNIT_FACTION.FRIENDLY, false, true, other.source_instance);
			if (hp > 0)
			{
				status_effect_apply(STATUS_EFFECT.SLOW, other.slow_duration, other.slow_amount);
			}
		}
	}
};