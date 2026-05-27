/// @description Creates a short burst of blood particles at a world position.
/// @param _x Particle burst x position.
/// @param _y Particle burst y position.
/// @param _amount Optional. Particle count.
function blood_particles_create(_x, _y, _amount = BALANCE_BLOOD_PARTICLE_COUNT)
{
	if (!variable_global_exists("particle_system_effects") || !variable_global_exists("particle_type_blood"))
	{
		return;
	}

	part_particles_create(global.particle_system_effects, _x, _y, global.particle_type_blood, _amount);
}
