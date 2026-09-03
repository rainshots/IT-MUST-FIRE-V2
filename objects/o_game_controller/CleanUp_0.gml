// Do not leave an empty balance file when a cheat session ends before its first completed day.
if (variable_instance_exists(id, "cannon_satisfaction_cursor_is_hidden")
	&& cannon_satisfaction_cursor_is_hidden)
{
	window_set_cursor(cr_default);
}

if (variable_instance_exists(id, "balance_log_file_path")
	&& variable_instance_exists(id, "balance_log_has_content")
	&& balance_log_file_path != ""
	&& !balance_log_has_content
	&& file_exists(balance_log_file_path))
{
	file_delete(balance_log_file_path);
}

// Destroy the shared wall navigation grid created by the game controller.
if (variable_instance_exists(id, "wall_navigation_grid") && wall_navigation_grid != noone)
{
	mp_grid_destroy(wall_navigation_grid);
	wall_navigation_grid = noone;
}

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

if (variable_global_exists("particle_type_status_slow") && global.particle_type_status_slow != noone)
{
	part_type_destroy(global.particle_type_status_slow);
	global.particle_type_status_slow = noone;
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

if (variable_global_exists("particle_type_heal") && global.particle_type_heal != noone)
{
	part_type_destroy(global.particle_type_heal);
	global.particle_type_heal = noone;
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

if (variable_global_exists("particle_type_warlock_summon_skeleton_smoke") && global.particle_type_warlock_summon_skeleton_smoke != noone)
{
	part_type_destroy(global.particle_type_warlock_summon_skeleton_smoke);
	global.particle_type_warlock_summon_skeleton_smoke = noone;
}

if (variable_global_exists("particle_system_effects") && global.particle_system_effects != noone)
{
	part_system_destroy(global.particle_system_effects);
	global.particle_system_effects = noone;
}
