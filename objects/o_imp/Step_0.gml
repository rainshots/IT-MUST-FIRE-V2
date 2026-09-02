// Player-issued squad movement immediately overrides Demon Leap.
var _squad_march_is_active = is_struct(squad) && squad_is_marching(squad);

if (_squad_march_is_active && demon_leap_is_active)
{
	imp_demon_leap_cancel_for_march();
}

// Shared movement and attacks pause while active leaps control Imp position.
if (!demon_leap_is_active && crimson_guillotine_strike_timer <= 0)
{
	event_inherited();
}
else if (hp <= 0)
{
	imp_active_ability_cancel_for_death();
	event_inherited();
	exit;
}

if (unholy_savage_leap_active || global.pause || hp <= 0)
{
	exit;
}

gameplay_time_scale = variable_global_exists("gameplay_time_scale") ? global.gameplay_time_scale : 1;
var _time_scale = gameplay_time_scale;

imp_ability_damage_meter_update();

if (is_being_dragged
	|| (is_stunned && !demon_leap_is_active && crimson_guillotine_strike_timer <= 0))
{
	exit;
}

// Active ability timers continue while the Imp can act.
if (leap_visual_timer > 0)
{
	leap_visual_timer -= _time_scale;
}

for (var _leap_segment_index = array_length(leap_visual_segments) - 1; _leap_segment_index >= 0; --_leap_segment_index)
{
	var _leap_segment = leap_visual_segments[_leap_segment_index];
	_leap_segment.timer -= _time_scale;

	if (_leap_segment.timer <= 0)
	{
		array_delete(leap_visual_segments, _leap_segment_index, 1);
	}
	else
	{
		leap_visual_segments[_leap_segment_index] = _leap_segment;
	}
}

if (demon_leap_timer > 0)
{
	demon_leap_timer -= _time_scale;
}

if (demon_leap_retry_timer > 0)
{
	demon_leap_retry_timer -= _time_scale;
}

if (crimson_guillotine_timer > 0)
{
	crimson_guillotine_timer -= _time_scale;
}

if (crimson_guillotine_retry_timer > 0)
{
	crimson_guillotine_retry_timer -= _time_scale;
}

if (crimson_guillotine_strike_timer > 0)
{
	crimson_guillotine_strike_timer -= _time_scale;

	if (crimson_guillotine_strike_timer <= 0)
	{
		imp_crimson_guillotine_strike();
	}
}

if (crimson_guillotine_strike_timer > 0)
{
	exit;
}

if (bloody_clone_timer > 0)
{
	bloody_clone_timer -= _time_scale;
}

if (bloody_clone_retry_timer > 0)
{
	bloody_clone_retry_timer -= _time_scale;
}

if (blood_hunger_frenzy_timer > 0)
{
	blood_hunger_frenzy_timer -= _time_scale;
}

// Blood Hunger stacks expire independently.
for (var _stack_index = 0; _stack_index < array_length(blood_frenzy_stack_timers); ++_stack_index)
{
	if (blood_frenzy_stack_timers[_stack_index] > 0)
	{
		blood_frenzy_stack_timers[_stack_index] -= _time_scale;
	}
}

// Active Blood Hunger emits red smoke across the Imp body.
if (imp_blood_frenzy_stack_count_get() > 0)
{
	blood_frenzy_particle_timer -= _time_scale;

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

imp_blood_pool_update();
imp_blood_blades_update();

if (frenzy_echo_visual_timer > 0)
{
	frenzy_echo_visual_timer -= _time_scale;
}

if (demon_leap_is_active)
{
	imp_demon_leap_update();
	exit;
}

// Use only the active ability this Imp currently owns.
if (cultist_active_ability_has(id, DEMON_ABILITY.IMP_DEMON_LEAP)
	&& !_squad_march_is_active
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

if (cultist_active_ability_has(id, DEMON_ABILITY.IMP_CRIMSON_GUILLOTINE)
	&& crimson_guillotine_timer <= 0
	&& crimson_guillotine_strike_timer <= 0
	&& crimson_guillotine_retry_timer <= 0)
{
	if (imp_crimson_guillotine_use())
	{
		crimson_guillotine_timer = ability_cooldown_time_get(crimson_guillotine_cooldown);
	}
	else
	{
		crimson_guillotine_retry_timer = BALANCE_ABILITY_FAILED_RETRY_TIME * room_speed;
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
