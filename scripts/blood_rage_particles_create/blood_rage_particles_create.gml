/// @description Creates a small burst of Imp Blood Rage particles.
/// @param _x Particle burst x position.
/// @param _y Particle burst y position.
/// @param _amount Optional. Particle count.
function blood_rage_particles_create(_x, _y, _amount = BALANCE_IMP_BLOOD_RAGE_PARTICLE_COUNT)
{
	if (!variable_global_exists("particle_system_effects") || !variable_global_exists("particle_type_blood_rage"))
	{
		return;
	}

	part_particles_create(global.particle_system_effects, _x, _y, global.particle_type_blood_rage, _amount);
}
