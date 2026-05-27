// Destroy shared particle resources created by the game controller.
if (variable_global_exists("particle_type_blood") && global.particle_type_blood != noone)
{
	part_type_destroy(global.particle_type_blood);
	global.particle_type_blood = noone;
}

if (variable_global_exists("particle_type_frenzy") && global.particle_type_frenzy != noone)
{
	part_type_destroy(global.particle_type_frenzy);
	global.particle_type_frenzy = noone;
}

if (variable_global_exists("particle_type_blood_rage") && global.particle_type_blood_rage != noone)
{
	part_type_destroy(global.particle_type_blood_rage);
	global.particle_type_blood_rage = noone;
}

if (variable_global_exists("particle_system_effects") && global.particle_system_effects != noone)
{
	part_system_destroy(global.particle_system_effects);
	global.particle_system_effects = noone;
}
