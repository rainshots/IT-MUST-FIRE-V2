// Run shared movement and combat first.
event_inherited();

if (global.pause || hp <= 0)
{
	exit;
}

if (is_being_dragged)
{
	exit;
}

// Active frenzy doubles attack speed for a short burst.
if (ability_active_timer > 0)
{
	ability_active_timer--;
	reload_time = max(base_reload_time * active_reload_multiplier, 1);
	frenzy_particle_timer--;

	if (demon_ability == DEMON_ABILITY.IMP_FRENZY && frenzy_particle_timer <= 0)
	{
		frenzy_particles_create(x, y);
		frenzy_particle_timer = BALANCE_IMP_FRENZY_PARTICLE_INTERVAL;
	}
}
else
{
	reload_time = base_reload_time;
	active_reload_multiplier = 1;
	frenzy_particle_timer = 0;
}

// Blood Rage is active while this Imp is below its HP threshold.
var _blood_rage_should_be_active = demon_ability == DEMON_ABILITY.IMP_BLOOD_RAGE
	&& hp < max_hp * BALANCE_ABILITY_IMP_BLOOD_RAGE_HP_THRESHOLD;

if (_blood_rage_should_be_active)
{
	if (!blood_rage_active)
	{
		ability_popup_create(x, y, demon_ability);
		blood_rage_active = true;
	}

	blood_rage_particle_timer--;

	if (blood_rage_particle_timer <= 0)
	{
		blood_rage_particles_create(x, y);
		blood_rage_particle_timer = BALANCE_IMP_BLOOD_RAGE_PARTICLE_INTERVAL;
	}
}
else
{
	blood_rage_active = false;
	blood_rage_particle_timer = 0;
}

// Trigger the active frenzy ability when ready.
if (demon_ability == DEMON_ABILITY.IMP_FRENZY)
{
	ability_timer--;

	if (ability_timer <= 0)
	{
		ability_duration = BALANCE_ABILITY_IMP_FRENZY_DURATION * room_speed;
		active_reload_multiplier = BALANCE_ABILITY_IMP_FRENZY_RELOAD_MULTIPLIER;
		ability_active_timer = ability_duration;
		ability_timer = max(ability_cooldown / abilities_cd_spd, 1);
		ability_popup_create(x, y, demon_ability);
	}
}
else if (demon_ability == DEMON_ABILITY.IMP_CANNON_ECHO && variable_global_exists("cannon_fire_version"))
{
	if (tracked_cannon_fire_version < 0)
	{
		tracked_cannon_fire_version = global.cannon_fire_version;
	}
	else if (tracked_cannon_fire_version != global.cannon_fire_version)
	{
		tracked_cannon_fire_version = global.cannon_fire_version;
		ability_duration = BALANCE_ABILITY_IMP_CANNON_ECHO_DURATION * room_speed;
		active_reload_multiplier = BALANCE_ABILITY_IMP_CANNON_ECHO_RELOAD_MULTIPLIER;
		ability_active_timer = ability_duration;
		ability_popup_create(x, y, demon_ability);
	}
}
