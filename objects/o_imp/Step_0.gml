// Run shared movement, combat, and status effects first.
event_inherited();

if (global.pause || hp <= 0)
{
	exit;
}

if (is_being_dragged || is_stunned)
{
	exit;
}

// Active ability timers continue while the Imp can act.
if (leap_visual_timer > 0)
{
	leap_visual_timer--;
}

if (demon_leap_timer > 0)
{
	demon_leap_timer--;
}

if (demon_leap_retry_timer > 0)
{
	demon_leap_retry_timer--;
}

if (sacrificial_rush_timer > 0)
{
	sacrificial_rush_timer--;
}

if (sacrificial_rush_retry_timer > 0)
{
	sacrificial_rush_retry_timer--;
}

if (sacrificial_rush_active_timer > 0)
{
	sacrificial_rush_active_timer--;
}

if (bloody_clone_timer > 0)
{
	bloody_clone_timer--;
}

if (bloody_clone_retry_timer > 0)
{
	bloody_clone_retry_timer--;
}

// Blood Frenzy stacks expire independently.
for (var _stack_index = 0; _stack_index < array_length(blood_frenzy_stack_timers); ++_stack_index)
{
	if (blood_frenzy_stack_timers[_stack_index] > 0)
	{
		blood_frenzy_stack_timers[_stack_index]--;
	}
}

// Active Blood Frenzy emits blue smoke across the Imp body.
if (imp_blood_frenzy_stack_count_get() > 0)
{
	blood_frenzy_particle_timer--;

	if (blood_frenzy_particle_timer <= 0)
	{
		imp_blood_frenzy_particles_create();
		blood_frenzy_particle_timer = BALANCE_IMP_BLOOD_FRENZY_SMOKE_INTERVAL;
	}
}
else
{
	blood_frenzy_particle_timer = 0;
}

// Use only the active ability this Imp currently owns.
if (cultist_active_ability_has(id, DEMON_ABILITY.IMP_DEMON_LEAP)
	&& demon_leap_timer <= 0
	&& demon_leap_retry_timer <= 0)
{
	if (imp_demon_leap_use())
	{
		demon_leap_timer = ability_cooldown_time_get(demon_leap_cooldown);

		if (demon_leap_refund_pending)
		{
			demon_leap_timer *= 1 - BALANCE_IMP_DEMON_LEAP_REFUND_ON_KILL;
			demon_leap_refund_pending = false;
		}
	}
	else
	{
		demon_leap_retry_timer = BALANCE_ABILITY_FAILED_RETRY_TIME * room_speed;
	}
}

if (cultist_active_ability_has(id, DEMON_ABILITY.IMP_SACRIFICIAL_RUSH)
	&& sacrificial_rush_timer <= 0
	&& sacrificial_rush_active_timer <= 0
	&& sacrificial_rush_retry_timer <= 0)
{
	if (imp_sacrificial_rush_use())
	{
		sacrificial_rush_timer = ability_cooldown_time_get(sacrificial_rush_cooldown);
	}
	else
	{
		sacrificial_rush_retry_timer = BALANCE_ABILITY_FAILED_RETRY_TIME * room_speed;
	}
}

if (cultist_active_ability_has(id, DEMON_ABILITY.IMP_BLOODY_CLONE)
	&& bloody_clone_timer <= 0
	&& bloody_clone_retry_timer <= 0)
{
	if (imp_bloody_clone_use())
	{
		bloody_clone_timer = ability_cooldown_time_get(bloody_clone_cooldown);
	}
	else
	{
		bloody_clone_retry_timer = BALANCE_ABILITY_FAILED_RETRY_TIME * room_speed;
	}
}
