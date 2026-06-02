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

if (variable_global_exists("particle_type_status_bleed") && global.particle_type_status_bleed != noone)
{
	part_type_destroy(global.particle_type_status_bleed);
	global.particle_type_status_bleed = noone;
}

if (variable_global_exists("particle_type_status_web_red") && global.particle_type_status_web_red != noone)
{
	part_type_destroy(global.particle_type_status_web_red);
	global.particle_type_status_web_red = noone;
}

if (variable_global_exists("particle_type_status_soul_mark") && global.particle_type_status_soul_mark != noone)
{
	part_type_destroy(global.particle_type_status_soul_mark);
	global.particle_type_status_soul_mark = noone;
}

if (variable_global_exists("particle_type_status_curse") && global.particle_type_status_curse != noone)
{
	part_type_destroy(global.particle_type_status_curse);
	global.particle_type_status_curse = noone;
}

if (variable_global_exists("particle_type_status_stun") && global.particle_type_status_stun != noone)
{
	part_type_destroy(global.particle_type_status_stun);
	global.particle_type_status_stun = noone;
}

if (variable_global_exists("particle_type_imp_blood_frenzy_smoke") && global.particle_type_imp_blood_frenzy_smoke != noone)
{
	part_type_destroy(global.particle_type_imp_blood_frenzy_smoke);
	global.particle_type_imp_blood_frenzy_smoke = noone;
}

if (variable_global_exists("particle_type_brute_heal") && global.particle_type_brute_heal != noone)
{
	part_type_destroy(global.particle_type_brute_heal);
	global.particle_type_brute_heal = noone;
}

if (variable_global_exists("particle_type_brute_rotten_aura") && global.particle_type_brute_rotten_aura != noone)
{
	part_type_destroy(global.particle_type_brute_rotten_aura);
	global.particle_type_brute_rotten_aura = noone;
}

if (variable_global_exists("particle_type_brute_grave_slam_smoke") && global.particle_type_brute_grave_slam_smoke != noone)
{
	part_type_destroy(global.particle_type_brute_grave_slam_smoke);
	global.particle_type_brute_grave_slam_smoke = noone;
}

if (variable_global_exists("particle_type_brute_meat_explosion_smoke") && global.particle_type_brute_meat_explosion_smoke != noone)
{
	part_type_destroy(global.particle_type_brute_meat_explosion_smoke);
	global.particle_type_brute_meat_explosion_smoke = noone;
}

if (variable_global_exists("particle_type_warlock_curseweaver_smoke") && global.particle_type_warlock_curseweaver_smoke != noone)
{
	part_type_destroy(global.particle_type_warlock_curseweaver_smoke);
	global.particle_type_warlock_curseweaver_smoke = noone;
}

if (variable_global_exists("particle_system_effects") && global.particle_system_effects != noone)
{
	part_system_destroy(global.particle_system_effects);
	global.particle_system_effects = noone;
}
