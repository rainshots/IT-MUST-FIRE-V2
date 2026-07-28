// Global pause state used by gameplay objects.
randomise()
global.pause = false;
global.focus_window = FOCUS_WINDOW.NOONE;
global.fog_of_war_visible = true;
global.cheats_enabled = BALANCE_CHEATS_ENABLED;
global.play_music = BALANCE_PLAY_MUSIC;
global.tutorial_hints_enabled = BALANCE_TUTORIAL_HINTS_ENABLED;
global.music_volume = 0.8;
global.ambient_volume = 0.8;
global.sound_volume = 0.8;
global.edge_scroll_enabled = true;
global.edge_scroll_speed = 0.5;
global.camera_speed = 0.5;
global.game_speed_normal = BALANCE_GAME_SPEED_NORMAL;
game_set_speed(global.game_speed_normal, gamespeed_fps);

// Global day cycle uses fixed day and night timers.
global.day_phase = DAY_PHASE.DAY;
global.day_duration = BALANCE_DAY_DURATION;
global.night_duration = BALANCE_NIGHT_DURATION;
global.day_timer = global.day_duration * global.game_speed_normal;
global.night_attack_unit_count = 0;
global.full_moon_night_active = false;
global.full_moon_attack_direction = 0;
global.blood_moon_reward_popup_active = false;
global.day_cycle_enabled = true;
global.legacy_building_logic_enabled = false;
global.archdemons = array_create(0);
global.squads = [];
global.dragged_squad = noone;
global.squad_limits = [BALANCE_SQUAD_ARCHDEMON_LIMIT, BALANCE_SQUAD_UNDEAD_LIMIT, BALANCE_SQUAD_DEMON_LIMIT];
// Archdemons keep the existing combat and cannon lifecycle; regular cultists belong to day events.
global.event_cultists = array_create(0);
global.cultist_limit = BALANCE_STARTING_CULTIST_LIMIT;
// Creating a construction event immediately consumes the current day's building allowance.
global.building_construction_count_today = 0;
global.blood_bath_crimson_baptism_uses = 0;
global.blood_bath_harden_vessel_used = false;
global.cult_must_grow_last_activation_day = -BALANCE_CULT_MUST_GROW_COOLDOWN_DAYS;
global.world_job_second_archdemon_completed = false;
global.world_job_third_archdemon_completed = false;
global.ritual_black_pilgrimage_active = false;
global.ritual_grasping_soil_active = false;
global.ritual_awaken_taint_active = false;
global.ritual_rust_righteous_active = false;
global.ritual_silence_choir_active = false;
global.ritual_blood_night_active = false;
global.ritual_invite_worthy_active = false;
global.ritual_invite_worthy_reward_pending = false;
global.ritual_extra_building_event_active = false;
global.ritual_trial_cannon_active = false;
global.ritual_lesser_gate_active = false;
global.ritual_hell_weakest_active = false;
global.ritual_hell_weakest_squad = noone;
global.squad_blood_warpaint_pending = false;
global.foundry_demon_health_multiplier = 1;
global.foundry_demon_damage_multiplier = 1;
global.foundry_undead_health_multiplier = 1;
global.foundry_undead_attack_speed_multiplier = 1;
global.event_cultist_names = [
	"Alden", "Bram", "Corvin", "Dorian", "Edric", "Fenric",
	"Garrick", "Hadrian", "Ivor", "Jareth", "Kael", "Lucan",
	"Marek", "Nolan", "Orin", "Perrin", "Quill", "Roderic",
	"Silas", "Theron", "Ulric", "Varen", "Wystan", "Xander",
	"Yorick", "Zevran", "Alaric", "Cedric", "Leoric", "Mordren"
];
global.day_events = array_create(0);
// Jobs actions allow one reroll per day and one building event pinned for tomorrow.
global.day_event_reroll_used_today = false;
global.day_event_pinned_event_id = "";
global.day_event_pinned_source_building = noone;

if (!instance_exists(o_jobs_ui))
{
	instance_create_layer(0, 0, "Instances", o_jobs_ui);
}
global.shrine_objective_complete = false;
global.first_night_cultist_projectile_fired = false;
global.tutorial_popup_active = false;
global.tutorial_welcome_closed = !global.tutorial_hints_enabled;
global.cursed_point_structure_selection_source = noone;

// Player buildings react to cleansed ground in a throttled shared pass.
player_building_ground_check_interval = BALANCE_PLAYER_BUILDING_CORRUPTION_CHECK_INTERVAL;
player_building_ground_check_timer = irandom(player_building_ground_check_interval - 1);

// World hint for the first worker assignment.
worker_assignment_hint_completed = true;
first_day_timer_waiting_for_worker_assignment = false;
worker_assignment_hint_delay_started = false;
worker_assignment_hint_delay_time = 2 * room_speed;
worker_assignment_hint_delay_timer = -1;
worker_assignment_hint_text = "Drag a worker onto a building to assign him for work.\nHover the worker, hold LMB, then release over the building.";
worker_assignment_hint_width = 360;
worker_assignment_hint_padding_x = 10;
worker_assignment_hint_padding_y = 7;
worker_assignment_hint_line_height = 16;
worker_assignment_hint_offset_y = 150;
worker_assignment_hint_background_alpha = 0.86;

// World hint for tree corruption spread.
tree_corruption_hint_completed = false;
tree_corruption_hint_target = noone;
tree_corruption_hint_min_cannon_distance = 1200;
tree_corruption_hint_text = "Infect the ground under a tree to make it spread Taint farther.";
tree_corruption_hint_width = 330;
tree_corruption_hint_padding_x = 10;
tree_corruption_hint_padding_y = 7;
tree_corruption_hint_line_height = 16;
tree_corruption_hint_offset_y = 58;
tree_corruption_hint_background_alpha = 0.86;

// Full moon tutorial appears after the player has seen unobstructed daytime gameplay.
full_moon_hint_delay_time = BALANCE_FULL_MOON_HINT_DELAY * room_speed;
full_moon_hint_delay_timer = -1;
full_moon_hint_delay_pending = false;

// Blood Moon morning reward popup lists the cultists that actually fit under the limit.
blood_moon_reward_cultists = [];
blood_moon_reward_popup_width = 620;
blood_moon_reward_popup_height = 330;
blood_moon_reward_icon_width = 72;
blood_moon_reward_icon_height = 112;
blood_moon_reward_icon_gap = 34;
blood_moon_reward_button_width = 210;
blood_moon_reward_button_height = 44;
blood_moon_reward_button_hovered = false;
blood_moon_reward_input_blocked = false;

blood_moon_reward_popup_show = function(_cultists)
{
	blood_moon_reward_cultists = _cultists;
	blood_moon_reward_button_hovered = false;
	blood_moon_reward_input_blocked = true;
	debug_menu_open = false;
	global.blood_moon_reward_popup_active = true;
	global.pause = true;
	return true;
};

blood_moon_reward_popup_close = function()
{
	blood_moon_reward_cultists = [];
	blood_moon_reward_button_hovered = false;
	blood_moon_reward_input_blocked = false;
	global.blood_moon_reward_popup_active = false;
	global.pause = variable_global_exists("tutorial_popup_active")
		&& global.tutorial_popup_active;
};

// Phase banner briefly announces day and night transitions.
phase_banner_text = "";
phase_banner_timer = 0;
phase_banner_duration = 1.5 * room_speed;
phase_banner_width = 340;
phase_banner_height = 62;
phase_banner_y = 158;
phase_banner_background_alpha = 0.86;

// Night effect layers are enabled in sequence so night settles in gradually.
night_effect_layer_names = [
	"NightEffect",
	"NightEffect2",
	"NightEffect3"
];
full_moon_effect_layer_name = "FullMoon_effect";
night_effect_transition_duration = 6 * room_speed;
night_effect_transition_timer = 0;
night_effect_transition_active = false;

// Tutorial controller owns onboarding popups and pauses gameplay while they are open.
if (global.tutorial_hints_enabled && !instance_exists(o_tutorial_controller))
{
	instance_create_layer(0, 0, "Instances", o_tutorial_controller);
}

// Shrine objective state is owned by the game controller and displayed by the HUD.
shrine_instances = array_create(0);
shrines_spawned = false;
shrine_objective_total = BALANCE_SHRINE_OBJECTIVE_TOTAL;
shrine_objective_required = BALANCE_SHRINE_OBJECTIVE_REQUIRED;

// Global particle system used by lightweight world effects.
global.particle_system_effects = part_system_create();
global.particle_type_blood = part_type_create();
global.particle_type_frenzy = part_type_create();
global.particle_type_blood_rage = part_type_create();
global.particle_type_status_bleed = part_type_create();
global.particle_type_status_web_red = part_type_create();
global.particle_type_status_soul_mark = part_type_create();
global.particle_type_status_curse = part_type_create();
global.particle_type_status_stun = part_type_create();
global.particle_type_imp_blood_frenzy_smoke = part_type_create();
global.particle_type_heal = part_type_create();
global.particle_type_brute_heal = part_type_create();
global.particle_type_brute_rotten_aura = part_type_create();
global.particle_type_brute_grave_slam_smoke = part_type_create();
global.particle_type_brute_meat_explosion_smoke = part_type_create();
global.particle_type_warlock_curseweaver_smoke = part_type_create();
global.particle_type_warlock_summon_skeleton_smoke = part_type_create();
part_system_depth(global.particle_system_effects, BALANCE_PARTICLE_SYSTEM_TOP_DEPTH);
part_system_automatic_update(global.particle_system_effects, true);
part_system_automatic_draw(global.particle_system_effects, true);
part_type_shape(global.particle_type_blood, pt_shape_square);
part_type_size(
	global.particle_type_blood,
	BALANCE_BLOOD_PARTICLE_SIZE_MIN,
	BALANCE_BLOOD_PARTICLE_SIZE_MAX,
	-0.01,
	0
);
part_type_color1(global.particle_type_blood, COLOR_PARTICLE_BLOOD);
part_type_alpha2(global.particle_type_blood, 1, 0);
part_type_speed(
	global.particle_type_blood,
	BALANCE_BLOOD_PARTICLE_SPEED_MIN,
	BALANCE_BLOOD_PARTICLE_SPEED_MAX,
	-0.05,
	0
);
part_type_direction(global.particle_type_blood, 0, 359, 0, 0);
part_type_life(global.particle_type_blood, BALANCE_BLOOD_PARTICLE_LIFE_MIN, BALANCE_BLOOD_PARTICLE_LIFE_MAX);

part_type_shape(global.particle_type_frenzy, pt_shape_square);
part_type_size(
	global.particle_type_frenzy,
	BALANCE_IMP_FRENZY_PARTICLE_SIZE_MIN,
	BALANCE_IMP_FRENZY_PARTICLE_SIZE_MAX,
	-0.01,
	0
);
part_type_color1(global.particle_type_frenzy, COLOR_PARTICLE_FRENZY);
part_type_alpha2(global.particle_type_frenzy, 0.8, 0);
part_type_speed(
	global.particle_type_frenzy,
	BALANCE_IMP_FRENZY_PARTICLE_SPEED_MIN,
	BALANCE_IMP_FRENZY_PARTICLE_SPEED_MAX,
	-0.03,
	0
);
part_type_direction(global.particle_type_frenzy, 160, 200, 0, 0);
part_type_life(global.particle_type_frenzy, BALANCE_IMP_FRENZY_PARTICLE_LIFE_MIN, BALANCE_IMP_FRENZY_PARTICLE_LIFE_MAX);

part_type_shape(global.particle_type_blood_rage, pt_shape_square);
part_type_size(
	global.particle_type_blood_rage,
	BALANCE_IMP_BLOOD_RAGE_PARTICLE_SIZE_MIN,
	BALANCE_IMP_BLOOD_RAGE_PARTICLE_SIZE_MAX,
	-0.01,
	0
);
part_type_color1(global.particle_type_blood_rage, COLOR_PARTICLE_BLOOD_RAGE);
part_type_alpha2(global.particle_type_blood_rage, 0.9, 0);
part_type_speed(
	global.particle_type_blood_rage,
	BALANCE_IMP_BLOOD_RAGE_PARTICLE_SPEED_MIN,
	BALANCE_IMP_BLOOD_RAGE_PARTICLE_SPEED_MAX,
	-0.02,
	0
);
part_type_direction(global.particle_type_blood_rage, 0, 359, 0, 0);
part_type_life(global.particle_type_blood_rage, BALANCE_IMP_BLOOD_RAGE_PARTICLE_LIFE_MIN, BALANCE_IMP_BLOOD_RAGE_PARTICLE_LIFE_MAX);

// Status particles use white sprites tinted by particle color.
part_type_sprite(global.particle_type_status_bleed, s_bleed_particle, false, false, true);
part_type_size(
	global.particle_type_status_bleed,
	BALANCE_STATUS_BLEED_PARTICLE_SIZE_MIN,
	BALANCE_STATUS_BLEED_PARTICLE_SIZE_MAX,
	-0.005,
	0
);
part_type_color1(global.particle_type_status_bleed, COLOR_STATUS_NEGATIVE_RED);
part_type_alpha2(global.particle_type_status_bleed, 0.9, 0);
part_type_speed(
	global.particle_type_status_bleed,
	BALANCE_STATUS_PARTICLE_SPEED_MIN,
	BALANCE_STATUS_PARTICLE_SPEED_MAX,
	-0.01,
	0
);
part_type_direction(global.particle_type_status_bleed, 250, 290, 0, 0);
part_type_life(global.particle_type_status_bleed, BALANCE_STATUS_PARTICLE_LIFE_MIN, BALANCE_STATUS_PARTICLE_LIFE_MAX);

part_type_sprite(global.particle_type_status_web_red, s_web_particle_01, false, false, true);
part_type_size(
	global.particle_type_status_web_red,
	BALANCE_STATUS_PARTICLE_SIZE_MIN,
	BALANCE_STATUS_PARTICLE_SIZE_MAX,
	-0.005,
	0
);
part_type_color1(global.particle_type_status_web_red, COLOR_STATUS_NEGATIVE_RED);
part_type_alpha2(global.particle_type_status_web_red, 0.9, 0);
part_type_speed(
	global.particle_type_status_web_red,
	BALANCE_STATUS_PARTICLE_SPEED_MIN,
	BALANCE_STATUS_PARTICLE_SPEED_MAX,
	-0.01,
	0
);
part_type_direction(global.particle_type_status_web_red, 250, 290, 0, 0);
part_type_life(global.particle_type_status_web_red, BALANCE_STATUS_PARTICLE_LIFE_MIN, BALANCE_STATUS_PARTICLE_LIFE_MAX);

part_type_sprite(global.particle_type_status_soul_mark, s_sight_particle, false, false, true);
part_type_size(
	global.particle_type_status_soul_mark,
	BALANCE_STATUS_SOUL_MARK_PARTICLE_SIZE_MIN,
	BALANCE_STATUS_SOUL_MARK_PARTICLE_SIZE_MAX,
	-0.005,
	0
);
part_type_color1(global.particle_type_status_soul_mark, COLOR_STATUS_SOUL_MARK);
part_type_alpha2(global.particle_type_status_soul_mark, 0.9, 0);
part_type_speed(
	global.particle_type_status_soul_mark,
	BALANCE_STATUS_PARTICLE_SPEED_MIN,
	BALANCE_STATUS_PARTICLE_SPEED_MAX,
	-0.01,
	0
);
part_type_direction(global.particle_type_status_soul_mark, 250, 290, 0, 0);
part_type_life(global.particle_type_status_soul_mark, BALANCE_STATUS_PARTICLE_LIFE_MIN, BALANCE_STATUS_PARTICLE_LIFE_MAX);

part_type_sprite(global.particle_type_status_curse, s_poison_particle, false, false, true);
part_type_size(
	global.particle_type_status_curse,
	BALANCE_STATUS_CURSE_PARTICLE_SIZE_MIN,
	BALANCE_STATUS_CURSE_PARTICLE_SIZE_MAX,
	-0.005,
	0
);
part_type_color1(global.particle_type_status_curse, COLOR_STATUS_CURSE);
part_type_alpha2(global.particle_type_status_curse, 0.9, 0);
part_type_speed(
	global.particle_type_status_curse,
	BALANCE_STATUS_PARTICLE_SPEED_MIN,
	BALANCE_STATUS_PARTICLE_SPEED_MAX,
	-0.01,
	0
);
part_type_direction(global.particle_type_status_curse, 250, 290, 0, 0);
part_type_life(global.particle_type_status_curse, BALANCE_STATUS_PARTICLE_LIFE_MIN, BALANCE_STATUS_PARTICLE_LIFE_MAX);

part_type_sprite(global.particle_type_status_stun, s_stop_particle, false, false, true);
part_type_size(
	global.particle_type_status_stun,
	BALANCE_STATUS_PARTICLE_SIZE_MIN,
	BALANCE_STATUS_PARTICLE_SIZE_MAX,
	-0.005,
	0
);
part_type_color1(global.particle_type_status_stun, COLOR_STATUS_NEGATIVE_RED);
part_type_alpha2(global.particle_type_status_stun, 0.9, 0);
part_type_speed(
	global.particle_type_status_stun,
	BALANCE_STATUS_PARTICLE_SPEED_MIN,
	BALANCE_STATUS_PARTICLE_SPEED_MAX,
	-0.01,
	0
);
part_type_direction(global.particle_type_status_stun, 250, 290, 0, 0);
part_type_life(global.particle_type_status_stun, BALANCE_STATUS_PARTICLE_LIFE_MIN, BALANCE_STATUS_PARTICLE_LIFE_MAX);

part_type_sprite(global.particle_type_imp_blood_frenzy_smoke, s_smoke_small_particle, false, false, true);
part_type_size(
	global.particle_type_imp_blood_frenzy_smoke,
	BALANCE_BRUTE_ABILITY_PARTICLE_SIZE_MIN * BALANCE_SMOKE_PARTICLE_SIZE_MULTIPLIER,
	BALANCE_BRUTE_ABILITY_PARTICLE_SIZE_MAX * BALANCE_SMOKE_PARTICLE_SIZE_MULTIPLIER,
	-0.02,
	0
);
part_type_color1(global.particle_type_imp_blood_frenzy_smoke, COLOR_IMP_BLOOD_FRENZY);
part_type_alpha2(global.particle_type_imp_blood_frenzy_smoke, BALANCE_IMP_BLOOD_FRENZY_SMOKE_MAX_ALPHA, 0);
part_type_speed(
	global.particle_type_imp_blood_frenzy_smoke,
	BALANCE_BRUTE_PASSIVE_PARTICLE_SPEED_MIN,
	BALANCE_BRUTE_PASSIVE_PARTICLE_SPEED_MAX,
	-0.01,
	0
);
part_type_direction(global.particle_type_imp_blood_frenzy_smoke, 0, 359, 0, 0);
part_type_life(
	global.particle_type_imp_blood_frenzy_smoke,
	BALANCE_BRUTE_PASSIVE_PARTICLE_LIFE_MIN * BALANCE_SMOKE_PARTICLE_LIFE_MULTIPLIER,
	BALANCE_BRUTE_PASSIVE_PARTICLE_LIFE_MAX * BALANCE_SMOKE_PARTICLE_LIFE_MULTIPLIER
);

part_type_sprite(global.particle_type_heal, s_heal_particle, false, false, true);
part_type_size(
	global.particle_type_heal,
	BALANCE_HEAL_FEEDBACK_PARTICLE_SIZE_MIN,
	BALANCE_HEAL_FEEDBACK_PARTICLE_SIZE_MAX,
	-0.006,
	0
);
part_type_color1(global.particle_type_heal, COLOR_PARTICLE_HEAL);
part_type_alpha2(global.particle_type_heal, 0.95, 0);
part_type_speed(
	global.particle_type_heal,
	BALANCE_BRUTE_PASSIVE_PARTICLE_SPEED_MIN,
	BALANCE_BRUTE_PASSIVE_PARTICLE_SPEED_MAX,
	-0.01,
	0
);
part_type_direction(global.particle_type_heal, 250, 290, 0, 0);
part_type_life(global.particle_type_heal, BALANCE_BRUTE_PASSIVE_PARTICLE_LIFE_MIN, BALANCE_BRUTE_PASSIVE_PARTICLE_LIFE_MAX);

part_type_sprite(global.particle_type_brute_heal, s_heal_particle, false, false, true);
part_type_size(
	global.particle_type_brute_heal,
	BALANCE_BRUTE_HEAL_PARTICLE_SIZE_MIN,
	BALANCE_BRUTE_HEAL_PARTICLE_SIZE_MAX,
	-0.006,
	0
);
part_type_color1(global.particle_type_brute_heal, COLOR_PARTICLE_HEAL);
part_type_alpha2(global.particle_type_brute_heal, 0.95, 0);
part_type_speed(
	global.particle_type_brute_heal,
	BALANCE_BRUTE_PASSIVE_PARTICLE_SPEED_MIN,
	BALANCE_BRUTE_PASSIVE_PARTICLE_SPEED_MAX,
	-0.01,
	0
);
part_type_direction(global.particle_type_brute_heal, 250, 290, 0, 0);
part_type_life(global.particle_type_brute_heal, BALANCE_BRUTE_PASSIVE_PARTICLE_LIFE_MIN, BALANCE_BRUTE_PASSIVE_PARTICLE_LIFE_MAX);

part_type_sprite(global.particle_type_brute_rotten_aura, s_poison_particle, false, false, true);
part_type_size(
	global.particle_type_brute_rotten_aura,
	BALANCE_BRUTE_ROTTEN_AURA_PARTICLE_SIZE_MIN * BALANCE_SMOKE_PARTICLE_SIZE_MULTIPLIER,
	BALANCE_BRUTE_ROTTEN_AURA_PARTICLE_SIZE_MAX * BALANCE_SMOKE_PARTICLE_SIZE_MULTIPLIER,
	-0.004,
	0
);
part_type_color1(global.particle_type_brute_rotten_aura, COLOR_BRUTE_ROTTEN_AURA);
part_type_alpha2(global.particle_type_brute_rotten_aura, BALANCE_BRUTE_ROTTEN_AURA_PARTICLE_MAX_ALPHA, 0);
part_type_speed(
	global.particle_type_brute_rotten_aura,
	BALANCE_BRUTE_PASSIVE_PARTICLE_SPEED_MIN,
	BALANCE_BRUTE_PASSIVE_PARTICLE_SPEED_MAX,
	-0.008,
	0
);
part_type_direction(global.particle_type_brute_rotten_aura, 0, 359, 0, 0);
part_type_life(
	global.particle_type_brute_rotten_aura,
	BALANCE_BRUTE_PASSIVE_PARTICLE_LIFE_MIN * BALANCE_SMOKE_PARTICLE_LIFE_MULTIPLIER,
	BALANCE_BRUTE_PASSIVE_PARTICLE_LIFE_MAX * BALANCE_SMOKE_PARTICLE_LIFE_MULTIPLIER
);

part_type_sprite(global.particle_type_brute_grave_slam_smoke, s_smoke_small_particle, false, false, true);
part_type_size(
	global.particle_type_brute_grave_slam_smoke,
	BALANCE_BRUTE_ABILITY_PARTICLE_SIZE_MIN * BALANCE_SMOKE_PARTICLE_SIZE_MULTIPLIER,
	BALANCE_BRUTE_ABILITY_PARTICLE_SIZE_MAX * BALANCE_SMOKE_PARTICLE_SIZE_MULTIPLIER,
	-0.02,
	0
);
part_type_color1(global.particle_type_brute_grave_slam_smoke, COLOR_BRUTE_GRAVE_SLAM);
part_type_alpha2(global.particle_type_brute_grave_slam_smoke, 0.65, 0);
part_type_speed(
	global.particle_type_brute_grave_slam_smoke,
	BALANCE_BRUTE_PASSIVE_PARTICLE_SPEED_MIN,
	BALANCE_BRUTE_PASSIVE_PARTICLE_SPEED_MAX,
	-0.01,
	0
);
part_type_direction(global.particle_type_brute_grave_slam_smoke, 0, 359, 0, 0);
part_type_life(
	global.particle_type_brute_grave_slam_smoke,
	BALANCE_BRUTE_PASSIVE_PARTICLE_LIFE_MIN * BALANCE_SMOKE_PARTICLE_LIFE_MULTIPLIER,
	BALANCE_BRUTE_PASSIVE_PARTICLE_LIFE_MAX * BALANCE_SMOKE_PARTICLE_LIFE_MULTIPLIER
);

part_type_sprite(global.particle_type_brute_meat_explosion_smoke, s_smoke_small_particle, false, false, true);
part_type_size(
	global.particle_type_brute_meat_explosion_smoke,
	BALANCE_BRUTE_ABILITY_PARTICLE_SIZE_MIN * BALANCE_SMOKE_PARTICLE_SIZE_MULTIPLIER,
	BALANCE_BRUTE_ABILITY_PARTICLE_SIZE_MAX * BALANCE_SMOKE_PARTICLE_SIZE_MULTIPLIER,
	-0.02,
	0
);
part_type_color1(global.particle_type_brute_meat_explosion_smoke, COLOR_BRUTE_MEAT_EXPLOSION);
part_type_alpha2(global.particle_type_brute_meat_explosion_smoke, 0.75, 0);
part_type_speed(
	global.particle_type_brute_meat_explosion_smoke,
	BALANCE_BRUTE_PASSIVE_PARTICLE_SPEED_MIN,
	BALANCE_BRUTE_PASSIVE_PARTICLE_SPEED_MAX,
	-0.01,
	0
);
part_type_direction(global.particle_type_brute_meat_explosion_smoke, 0, 359, 0, 0);
part_type_life(
	global.particle_type_brute_meat_explosion_smoke,
	BALANCE_BRUTE_PASSIVE_PARTICLE_LIFE_MIN * BALANCE_SMOKE_PARTICLE_LIFE_MULTIPLIER,
	BALANCE_BRUTE_PASSIVE_PARTICLE_LIFE_MAX * BALANCE_SMOKE_PARTICLE_LIFE_MULTIPLIER
);

part_type_sprite(global.particle_type_warlock_curseweaver_smoke, s_smoke_small_particle, false, false, true);
part_type_size(
	global.particle_type_warlock_curseweaver_smoke,
	BALANCE_WARLOCK_PASSIVE_PARTICLE_SIZE_MIN * BALANCE_SMOKE_PARTICLE_SIZE_MULTIPLIER,
	BALANCE_WARLOCK_PASSIVE_PARTICLE_SIZE_MAX * BALANCE_SMOKE_PARTICLE_SIZE_MULTIPLIER,
	-0.02,
	0
);
part_type_color1(global.particle_type_warlock_curseweaver_smoke, COLOR_WARLOCK_SOUL_ENGINE);
part_type_alpha2(global.particle_type_warlock_curseweaver_smoke, 0.75, 0);
part_type_speed(
	global.particle_type_warlock_curseweaver_smoke,
	BALANCE_BRUTE_PASSIVE_PARTICLE_SPEED_MIN,
	BALANCE_BRUTE_PASSIVE_PARTICLE_SPEED_MAX,
	-0.01,
	0
);
part_type_direction(global.particle_type_warlock_curseweaver_smoke, 0, 359, 0, 0);
part_type_life(
	global.particle_type_warlock_curseweaver_smoke,
	BALANCE_BRUTE_PASSIVE_PARTICLE_LIFE_MIN * BALANCE_SMOKE_PARTICLE_LIFE_MULTIPLIER,
	BALANCE_BRUTE_PASSIVE_PARTICLE_LIFE_MAX * BALANCE_SMOKE_PARTICLE_LIFE_MULTIPLIER
);

part_type_sprite(global.particle_type_warlock_summon_skeleton_smoke, s_smoke_small_particle, false, false, true);
part_type_size(
	global.particle_type_warlock_summon_skeleton_smoke,
	BALANCE_WARLOCK_PASSIVE_PARTICLE_SIZE_MIN * BALANCE_SMOKE_PARTICLE_SIZE_MULTIPLIER,
	BALANCE_WARLOCK_PASSIVE_PARTICLE_SIZE_MAX * BALANCE_SMOKE_PARTICLE_SIZE_MULTIPLIER,
	-0.02,
	0
);
part_type_color1(global.particle_type_warlock_summon_skeleton_smoke, COLOR_STATUS_SOUL_MARK);
part_type_alpha2(global.particle_type_warlock_summon_skeleton_smoke, 0.75, 0);
part_type_speed(
	global.particle_type_warlock_summon_skeleton_smoke,
	BALANCE_BRUTE_PASSIVE_PARTICLE_SPEED_MIN,
	BALANCE_BRUTE_PASSIVE_PARTICLE_SPEED_MAX,
	-0.01,
	0
);
part_type_direction(global.particle_type_warlock_summon_skeleton_smoke, 0, 359, 0, 0);
part_type_life(
	global.particle_type_warlock_summon_skeleton_smoke,
	BALANCE_BRUTE_PASSIVE_PARTICLE_LIFE_MIN * BALANCE_SMOKE_PARTICLE_LIFE_MULTIPLIER,
	BALANCE_BRUTE_PASSIVE_PARTICLE_LIFE_MAX * BALANCE_SMOKE_PARTICLE_LIFE_MULTIPLIER
);

// Global cannon target selected through the target selection mode.
global.cannon_target_exists = false;
global.cannon_target_x = 0;
global.cannon_target_y = 0;
global.cannon_target_projectile_type = PROJECTILE_TYPE.DAMAGE;
global.cannon_target_version = 0;
global.cannon_target_consumes_projectile_queue = true;
global.cannon_target_projectile_queue_index = 0;
global.dragged_artifact = noone;

// Global cannon projectile queue consumed from the selected slot.
global.cannon_projectile_queue = [];
global.cannon_projectile_payload_queue = [];
global.cannon_selected_projectile_index = 0;
global.cannon_projectile_queue_max = BALANCE_CANNON_PROJECTILE_QUEUE_MAX;
global.cannon_projectile_gain_time = BALANCE_CANNON_PROJECTILE_GAIN_TIME;
global.cannon_projectile_gain_timer = 0;
global.cannon_projectile_gain_enabled = false;
global.cannon_projectile_drop_types = [
	PROJECTILE_TYPE.DAMAGE,
	PROJECTILE_TYPE.SUMMON,
	PROJECTILE_TYPE.RALLY
];
global.cannon_feast_bonus_projectile_types = [
	PROJECTILE_TYPE.HEAL,
	PROJECTILE_TYPE.BOMB,
	PROJECTILE_TYPE.SKELETONS
];
global.cannon_projectile_cheat_enabled = global.cheats_enabled;
global.cannon_taint_projectiles_fired = 0;
global.rally_projectile_group_id = 0;
global.cannon_satiety = 0;
global.cannon_satiety_max = BALANCE_CANNON_SATIETY_MAX;
global.cannon_corpses_delivered_today = 0;
global.shell_factory_hellcow_damage_upgrade_count = 0;
global.shell_factory_first_aid_heal_upgrade_count = 0;

// Global one-shot sound groups used by gameplay feedback.
global.night_start_sounds = [
	night_start01,
	night_start02,
	night_start03
];
global.pick_worker_sounds = [
	pick_worker01,
	pick_worker02,
	pick_worker03,
	pick_worker04,
	pick_worker05,
	pick_worker06,
	pick_worker07,
	pick_worker08,
	pick_worker09,
	pick_worker10,
	pick_worker11
];
global.release_worker_sounds = [
	release_worker01,
	release_worker02,
	release_worker03,
	release_worker04,
	release_worker05,
	release_worker06,
	release_worker07,
	release_worker08,
	release_worker09,
	release_worker10,
	release_worker11
];
global.whip_sounds = [
	whip_sound01,
	whip_sound02,
	whip_sound03,
	whip_sound04
];
global.cannon_shot_sounds = [
	cannon_shot01,
	cannon_shot02,
	cannon_shot03
];
global.cannon_damage_sounds = [
	cannon_damage_01,
	cannon_damage_02,
	cannon_damage_03,
	cannon_damage_04,
	cannon_damage_05,
	cannon_damage_06
];
global.cannon_agony_sounds = [
	cannon_agony_01,
	cannon_agony_02,
	cannon_agony_03,
	cannon_agony_04
];
global.construction_sounds = [
	construction_sound01,
	construction_sound02,
	construction_sound03
];
global.death_sounds = [
	death_sound01,
	death_sound02,
	death_sound03,
	death_sound04,
	death_sound05,
	death_sound06,
	death_sound07,
	death_sound08
];
global.explosion_sounds = [
	explosion_sound01,
	explosion_sound02,
	explosion_sound03,
	explosion_sound04
];
global.ui_hover_sounds = [
	ui_hover_01,
	ui_hover_02
];
global.ui_confirm_sound = ui_confirm;
global.damage_sounds = [
	sword_sound01,
	sword_sound02,
	sword_sound03,
	sword_sound04,
	sword_sound05,
	sword_sound06,
	sword_sound07,
	sword_sound08
];
global.sound_priority_gameplay = 50;
global.sound_priority_ui = 60;
global.damage_sound_handle = noone;
global.damage_sound_gain = 1;
global.damage_sound_overlap_gain = 0.32;

global.sound_play_random = function(_sounds, _priority = global.sound_priority_gameplay)
{
	var _sound_count = array_length(_sounds);

	if (_sound_count <= 0)
	{
		return noone;
	}

	var _start_index = irandom(_sound_count - 1);

	for (var _sound_offset = 0; _sound_offset < _sound_count; ++_sound_offset)
	{
		var _sound_index = (_start_index + _sound_offset) mod _sound_count;
		var _sound = _sounds[_sound_index];

		if (audio_exists(_sound))
		{
			var _handle = audio_play_sound(_sound, _priority, false);

			if (_handle >= 0)
			{
				audio_sound_gain(_handle, global.sound_volume, 0);
			}

			return _handle;
		}
	}

	return noone;
};

global.sound_play_random_with_gain = function(_sounds, _gain, _priority = global.sound_priority_gameplay)
{
	var _handle = global.sound_play_random(_sounds, _priority);

	if (_handle >= 0)
	{
		audio_sound_gain(_handle, _gain * global.sound_volume, 0);
	}

	return _handle;
};

global.damage_sound_play = function()
{
	var _gain = global.damage_sound_gain;

	if (global.damage_sound_handle != noone && audio_is_playing(global.damage_sound_handle))
	{
		_gain = global.damage_sound_overlap_gain;
	}

	global.damage_sound_handle = global.sound_play_random_with_gain(global.damage_sounds, _gain);
};

global.ui_confirm_sound_play = function()
{
	if (audio_exists(global.ui_confirm_sound))
	{
		var _handle = audio_play_sound(global.ui_confirm_sound, global.sound_priority_ui, false);

		if (_handle >= 0)
		{
			audio_sound_gain(_handle, global.sound_volume, 0);
		}
	}
};

global.construction_sound_play = function()
{
	global.sound_play_random(global.construction_sounds, global.sound_priority_gameplay);
};

// UI audio is centralized so hover sounds fire once when entering a button.
ui_hover_button_key = "";
ui_click_sound_blocked = false;

ui_mouse_is_inside_rect = function(_mouse_x, _mouse_y, _left, _top, _width, _height)
{
	return _mouse_x >= _left
		&& _mouse_x <= _left + _width
		&& _mouse_y >= _top
		&& _mouse_y <= _top + _height;
};

building_choice_tile_rect_get = function(_choice_index, _is_foundry_window, _grid_x, _grid_y)
{
	if (_is_foundry_window)
	{
		var _foundry_column = _choice_index mod building_tile_columns;
		var _foundry_row = _choice_index div building_tile_columns;

		return {
			x: _grid_x + ((building_tile_width + building_tile_gap) * _foundry_column),
			y: _grid_y + ((building_tile_height + building_tile_gap) * _foundry_row),
			width: building_tile_width,
			height: building_tile_height
		};
	}

	var _current_group_name = "";
	var _group_y = _grid_y;
	var _group_choice_column = 0;

	for (var _layout_index = 0; _layout_index <= _choice_index; ++_layout_index)
	{
		var _choice = building_window_choices[_layout_index];
		var _choice_group_name = "";

		if (variable_struct_exists(_choice, "building_group"))
		{
			_choice_group_name = _choice.building_group;
		}

		if (_choice_group_name != _current_group_name)
		{
			if (_current_group_name != "")
			{
				_group_y += building_group_header_height + building_tile_height + building_group_gap_y;
			}

			_current_group_name = _choice_group_name;
			_group_choice_column = 0;
		}

		if (_layout_index == _choice_index)
		{
			return {
				x: _grid_x + ((building_tile_width + building_tile_gap) * _group_choice_column),
				y: _group_y + building_group_header_height,
				width: building_tile_width,
				height: building_tile_height
			};
		}

		_group_choice_column++;
	}

	return noone;
};

ui_hover_candidate_get = function(_mouse_x, _mouse_y)
{
	if (pause_menu_open)
	{
		if (!settings_open)
		{
			for (var _pause_button_index = 0; _pause_button_index < pause_button_count; ++_pause_button_index)
			{
				var _pause_button_x = pause_button_x_get(_pause_button_index);
				var _pause_button_y = pause_button_y_get(_pause_button_index);
				var _pause_button_width = pause_button_width_get(_pause_button_index);
				var _pause_button_height = pause_button_height_get(_pause_button_index);

				if (ui_mouse_is_inside_rect(_mouse_x, _mouse_y, _pause_button_x, _pause_button_y, _pause_button_width, _pause_button_height))
				{
					return "pause_" + string(_pause_button_index);
				}
			}
		}
		else
		{
			var _settings_panel_x = (camera_view_width - settings_panel_width) * 0.5;
			var _settings_panel_y = (camera_view_height - settings_panel_height) * 0.5;
			var _close_button_x = _settings_panel_x + ((settings_panel_width - button_width) * 0.5);
			var _close_button_y = _settings_panel_y + settings_panel_height - button_height - settings_close_bottom_padding;
			var _edge_toggle_rect = settings_edge_toggle_rect_get();
			var _settings_slider_index = settings_slider_find_at_gui(_mouse_x, _mouse_y);

			if (_settings_slider_index >= 0)
			{
				return "settings_slider_" + string(_settings_slider_index);
			}

			if (ui_mouse_is_inside_rect(_mouse_x, _mouse_y, _edge_toggle_rect.x, _edge_toggle_rect.y, _edge_toggle_rect.width, _edge_toggle_rect.height))
			{
				return "settings_edge_scroll_toggle";
			}

			if (ui_mouse_is_inside_rect(_mouse_x, _mouse_y, _close_button_x, _close_button_y, button_width, button_height))
			{
				return "settings_close";
			}
		}
	}

	if (global.focus_window == FOCUS_WINDOW.BUILDING_CONSTRUCTION)
	{
		var _construction_panel_x = (camera_view_width - building_window_width) * 0.5;
		var _construction_panel_y = (camera_view_height - building_window_height) * 0.5;
		var _construction_close_size = 34;
		var _construction_close_x = _construction_panel_x + building_window_width - _construction_close_size - 14;
		var _construction_close_y = _construction_panel_y + 14;
		var _is_foundry_window = instance_exists(building_window_foundry);
		var _grid_x = _construction_panel_x + 44;
		var _grid_y = _construction_panel_y + building_window_grid_y + (_is_foundry_window ? 112 : 0);
		var _foundry_current_x = _construction_panel_x + 44;
		var _foundry_current_y = _construction_panel_y + 118;
		var _foundry_current_width = building_window_width - 88;
		var _foundry_current_height = 78;
		var _choice_count = array_length(building_window_choices);

		if (ui_mouse_is_inside_rect(_mouse_x, _mouse_y, _construction_close_x, _construction_close_y, _construction_close_size, _construction_close_size))
		{
			return "building_close";
		}

		if (_is_foundry_window
			&& instance_exists(building_window_foundry)
			&& is_struct(building_window_foundry.foundry_selected_shell)
			&& ui_mouse_is_inside_rect(_mouse_x, _mouse_y, _foundry_current_x, _foundry_current_y, _foundry_current_width, _foundry_current_height))
		{
			return "foundry_cancel_forging";
		}

		for (var _choice_index = 0; _choice_index < _choice_count; ++_choice_index)
		{
			var _tile_rect = building_choice_tile_rect_get(_choice_index, _is_foundry_window, _grid_x, _grid_y);

			if (is_struct(_tile_rect)
				&& ui_mouse_is_inside_rect(_mouse_x, _mouse_y, _tile_rect.x, _tile_rect.y, _tile_rect.width, _tile_rect.height))
			{
				return "building_choice_" + string(_choice_index);
			}
		}
	}
	else if (global.focus_window == FOCUS_WINDOW.BUILDING_EVENTS)
	{
		var _events_panel_x = (camera_view_width - building_events_window_width) * 0.5;
		var _events_panel_y = (camera_view_height - building_events_window_height) * 0.5;
		var _events_close_size = 34;
		var _events_close_x = _events_panel_x + building_events_window_width - _events_close_size - 14;
		var _events_close_y = _events_panel_y + 14;

		if (ui_mouse_is_inside_rect(_mouse_x, _mouse_y, _events_close_x, _events_close_y, _events_close_size, _events_close_size))
		{
			return "building_events_close";
		}
	}
	else if (global.focus_window == FOCUS_WINDOW.CULTIST_DEMON_SELECTION)
	{
		var _design_width = 1024;
		var _design_height = 836;
		var _design_scale = min(camera_view_width / _design_width, camera_view_height / _design_height);
		var _selection_panel_x = (camera_view_width - (_design_width * _design_scale)) * 0.5;
		var _selection_panel_y = (camera_view_height - (_design_height * _design_scale)) * 0.5;
		var _button_start_x = _selection_panel_x + (58 * _design_scale);
		var _button_y = _selection_panel_y + (514 * _design_scale);
		var _button_step = cultist_selection_button_width + cultist_selection_button_gap;
		var _button_count = array_length(cultist_selection_buttons);

		for (var _button_index = 0; _button_index < _button_count; ++_button_index)
		{
			var _button_x = _button_start_x + ((_button_step * _button_index) * _design_scale);
			var _button_width = cultist_selection_button_width * _design_scale;
			var _button_height = cultist_selection_button_height * _design_scale;

			if (ui_mouse_is_inside_rect(_mouse_x, _mouse_y, _button_x, _button_y, _button_width, _button_height))
			{
				return "cultist_type_" + string(_button_index);
			}
		}

		var _ability_options = cultist_demon_active_abilities_get(cultist_selected_demon_type);
		var _ability_count = array_length(_ability_options);
		var _ability_button_x = _selection_panel_x + (58 * _design_scale);
		var _ability_button_y = _selection_panel_y + (650 * _design_scale);
		var _ability_button_width = cultist_ability_selection_button_width * _design_scale;
		var _ability_button_height = cultist_ability_selection_button_height * _design_scale;

		for (var _ability_index = 0; _ability_index < _ability_count; ++_ability_index)
		{
			var _current_ability_x = _ability_button_x
				+ (((cultist_ability_selection_button_width + cultist_ability_selection_button_gap) * _ability_index) * _design_scale);

			if (ui_mouse_is_inside_rect(_mouse_x, _mouse_y, _current_ability_x, _ability_button_y, _ability_button_width, _ability_button_height))
			{
				return "cultist_ability_" + string(_ability_index);
			}
		}

		var _confirm_x = _selection_panel_x + (56 * _design_scale);
		var _confirm_y = _selection_panel_y + (763 * _design_scale);
		var _confirm_width = 219 * _design_scale;
		var _confirm_height = 64 * _design_scale;

		if (ui_mouse_is_inside_rect(_mouse_x, _mouse_y, _confirm_x, _confirm_y, _confirm_width, _confirm_height))
		{
			return "cultist_confirm";
		}
	}
	else if (global.focus_window == FOCUS_WINDOW.CULTIST_LEVEL_UP)
	{
		var _level_panel_x = (camera_view_width - cultist_panel_width) * 0.5;
		var _level_panel_y = (camera_view_height - 660) * 0.5;
		var _level_attribute_button_y = _level_panel_y + 486;
		var _level_ability_button_y = _level_panel_y + 560;
		var _level_button_width = 150;
		var _level_button_height = 44;
		var _level_button_gap = 18;
		var _level_button_start_x = _level_panel_x + 92;
		var _level_confirm_width = 210;
		var _level_confirm_height = 42;
		var _level_confirm_x = _level_panel_x + ((cultist_panel_width - _level_confirm_width) * 0.5);
		var _level_confirm_y = _level_panel_y + 612;
		var _cultist = noone;

		if (cultist_levelup_index >= 0 && cultist_levelup_index < array_length(global.archdemons))
		{
			_cultist = global.archdemons[cultist_levelup_index];
		}

		if (instance_exists(_cultist))
		{
			ensure_cultist_levelup_options(_cultist);
			var _ability_reward_type = cultist_levelup_ability_reward_type_get(_cultist);

			if (cultist_levelup_has_attribute_choice(_cultist))
			{
				for (var _attribute_choice_index = 0; _attribute_choice_index < 3; ++_attribute_choice_index)
				{
					var _attribute_button_x = _level_button_start_x + ((_level_button_width + _level_button_gap) * _attribute_choice_index);

					if (ui_mouse_is_inside_rect(_mouse_x, _mouse_y, _attribute_button_x, _level_attribute_button_y, _level_button_width, _level_button_height))
					{
						return "level_attribute_" + string(_attribute_choice_index);
					}
				}
			}

			if (_ability_reward_type != -1)
			{
				var _ability_options = cultist_levelup_ability_options_get(_cultist, _ability_reward_type);
				var _ability_button_count = array_length(_ability_options);

				for (var _ability_choice_index = 0; _ability_choice_index < _ability_button_count; ++_ability_choice_index)
				{
					var _ability_button_x = _level_button_start_x + ((_level_button_width + _level_button_gap) * _ability_choice_index);

					if (ui_mouse_is_inside_rect(_mouse_x, _mouse_y, _ability_button_x, _level_ability_button_y, _level_button_width, _level_button_height))
					{
						return "level_ability_" + string(_ability_choice_index);
					}
				}
			}

			if (cultist_levelup_confirm_can_apply(_cultist)
				&& ui_mouse_is_inside_rect(_mouse_x, _mouse_y, _level_confirm_x, _level_confirm_y, _level_confirm_width, _level_confirm_height))
			{
				return "level_confirm";
			}
		}
	}
	else if (global.focus_window == FOCUS_WINDOW.CURSED_POINT_STRUCTURE_SELECTION)
	{
		if (variable_global_exists("cursed_point_structure_selection_source")
			&& instance_exists(global.cursed_point_structure_selection_source)
			&& variable_instance_exists(global.cursed_point_structure_selection_source, "cursed_point_structure_choice_hover_key_get"))
		{
			var _cursed_point = global.cursed_point_structure_selection_source;
			return _cursed_point.cursed_point_structure_choice_hover_key_get(_mouse_x, _mouse_y);
		}
	}
	else if (global.focus_window == FOCUS_WINDOW.NOONE
		&& !instance_exists(global.dragged_cultist)
		&& instance_exists(o_camera_controller))
	{
		var _levelup_cultist = cultist_levelup_button_find_at_gui(_mouse_x, _mouse_y);

		if (instance_exists(_levelup_cultist))
		{
			return "cultist_levelup_" + string(_levelup_cultist);
		}

		if (global.pause)
		{
			return "";
		}

		var _camera_controller = instance_find(o_camera_controller, 0);
		var _camera_x = camera_get_view_x(_camera_controller.camera_id);
		var _camera_y = camera_get_view_y(_camera_controller.camera_id);
		var _camera_width = camera_get_view_width(_camera_controller.camera_id);
		var _camera_height = camera_get_view_height(_camera_controller.camera_id);
		var _mouse_world_x = _camera_x + ((_mouse_x / camera_view_width) * _camera_width);
		var _mouse_world_y = _camera_y + ((_mouse_y / camera_view_height) * _camera_height);
		var _building_slot = find_building_slot_at_position(_mouse_world_x, _mouse_world_y);

		if (instance_exists(_building_slot))
		{
			return "building_slot_" + string(_building_slot);
		}
	}

	return "";
};

ui_audio_update = function()
{
	var _mouse_x = device_mouse_x_to_gui(0);
	var _mouse_y = device_mouse_y_to_gui(0);
	var _mouse_pressed = mouse_check_button_pressed(mb_left);
	var _hover_button_key = ui_hover_candidate_get(_mouse_x, _mouse_y);

	if (_hover_button_key != "" && _hover_button_key != ui_hover_button_key)
	{
		global.sound_play_random(global.ui_hover_sounds, global.sound_priority_ui);
	}

	if (_mouse_pressed && ui_click_sound_blocked)
	{
		ui_click_sound_blocked = false;
	}
	else if (_hover_button_key != "" && _mouse_pressed)
	{
		global.ui_confirm_sound_play();
	}

	ui_hover_button_key = _hover_button_key;
};

// Global resource storage used by HUD and economy systems.
global.resources = array_create(RESOURCES.COUNT, 0);
global.resources[RESOURCES.FLESH] = BALANCE_STARTING_FLESH;
global.resources[RESOURCES.SOULS] = BALANCE_STARTING_SOULS;
global.resources[RESOURCES.IRON] = BALANCE_STARTING_IRON;
global.resources[RESOURCES.IHOR] = BALANCE_STARTING_IHOR;

resource_max_get = function(_resource)
{
	if (_resource == RESOURCES.IHOR)
	{
		return infinity;
	}

	return BALANCE_PLAYER_RESOURCE_MAX;
};

resource_capacity_get = function(_resource)
{
	return max(0, resource_max_get(_resource) - global.resources[_resource]);
};

resource_add = function(_resource, _amount)
{
	var _amount_to_add = min(_amount, resource_capacity_get(_resource));
	global.resources[_resource] += _amount_to_add;

	return _amount_to_add;
};

resources_clamp_to_max = function()
{
	for (var _resource = 0; _resource < RESOURCES.COUNT; ++_resource)
	{
		global.resources[_resource] = min(global.resources[_resource], resource_max_get(_resource));
	}
};

player_building_ground_state_update = function()
{
	player_building_ground_check_timer++;

	if (player_building_ground_check_timer < player_building_ground_check_interval)
	{
		return;
	}

	player_building_ground_check_timer = 0;

	with (o_map_objects_parent)
	{
		if (variable_instance_exists(id, "player_building_ground_state_update"))
		{
			player_building_ground_state_update();
		}
	}
};

// Corpses are inert sprite snapshots, not gameplay instances.
corpse_draw_data = [];
corpse_next_id = 1;

corpse_snapshot_add = function(_unit)
{
	if (!instance_exists(_unit) || !sprite_exists(_unit.sprite_index))
	{
		return;
	}

	var _corpse_x = _unit.x;
	var _corpse_y = _unit.y;
	var _corpse_id = corpse_next_id;

	corpse_next_id++;

	if (variable_instance_exists(_unit, "visual_attack_offset_x"))
	{
		_corpse_x += _unit.visual_attack_offset_x;
		_corpse_y += _unit.visual_attack_offset_y;
	}

	array_push(
		corpse_draw_data,
		{
			corpse_id: _corpse_id,
			source_object_index: _unit.object_index,
			sprite_index: _unit.sprite_index,
			image_index: floor(_unit.image_index),
			x: _corpse_x,
			y: _corpse_y,
			image_xscale: _unit.image_xscale,
			image_yscale: _unit.image_yscale,
			image_angle: _unit.image_angle + 90,
			image_blend: _unit.image_blend,
			image_alpha: _unit.image_alpha,
			days_remaining: BALANCE_CORPSE_DAY_LIFE,
			max_days: BALANCE_CORPSE_DAY_LIFE,
			reserved_by: noone
		}
	);
};

corpse_decay_at_morning = function()
{
	cannon_morning_skeletons_raise();

	var _corpse_count = array_length(corpse_draw_data);
	var _write_index = 0;

	for (var _corpse_index = 0; _corpse_index < _corpse_count; ++_corpse_index)
	{
		var _corpse = corpse_draw_data[_corpse_index];

		_corpse.days_remaining--;

		if (_corpse.days_remaining > 0)
		{
			corpse_draw_data[_write_index] = _corpse;
			_write_index++;
		}
	}

	array_resize(corpse_draw_data, _write_index);
};

corpse_available_for_hauling_exists = function()
{
	if (cannon_corpse_delivery_limit_reached())
	{
		return false;
	}

	var _corpse_count = array_length(corpse_draw_data);

	for (var _corpse_index = 0; _corpse_index < _corpse_count; ++_corpse_index)
	{
		var _corpse = corpse_draw_data[_corpse_index];
		var _corpse_is_reserved = variable_struct_exists(_corpse, "reserved_by")
			&& instance_exists(_corpse.reserved_by);
		var _corpse_is_skeleton = variable_struct_exists(_corpse, "source_object_index")
			&& _corpse.source_object_index == o_skeleton;

		if (!_corpse_is_reserved && !_corpse_is_skeleton)
		{
			return true;
		}
	}

	return false;
};

cannon_morning_skeletons_raise = function()
{
	if (!instance_exists(o_cannon))
	{
		return;
	}

	var _cannon = instance_find(o_cannon, 0);

	if (!variable_instance_exists(_cannon, "cannon_morning_skeleton_count_range_get"))
	{
		return;
	}

	var _skeleton_range = _cannon.cannon_morning_skeleton_count_range_get();
	var _skeleton_count = irandom_range(_skeleton_range[0], _skeleton_range[1]);

	if (_skeleton_count <= 0)
	{
		return;
	}

	for (var _skeleton_index = 0; _skeleton_index < _skeleton_count; ++_skeleton_index)
	{
		var _candidate_indices = [];
		var _corpse_count = array_length(corpse_draw_data);

		for (var _corpse_index = 0; _corpse_index < _corpse_count; ++_corpse_index)
		{
			var _corpse = corpse_draw_data[_corpse_index];
			var _corpse_is_reserved = variable_struct_exists(_corpse, "reserved_by")
				&& instance_exists(_corpse.reserved_by);
			var _corpse_is_skeleton = variable_struct_exists(_corpse, "source_object_index")
				&& _corpse.source_object_index == o_skeleton;

			if (!_corpse_is_reserved && !_corpse_is_skeleton)
			{
				array_push(_candidate_indices, _corpse_index);
			}
		}

		var _candidate_count = array_length(_candidate_indices);

		if (_candidate_count <= 0)
		{
			return;
		}

		var _chosen_candidate_index = _candidate_indices[irandom(_candidate_count - 1)];
		var _chosen_corpse = corpse_draw_data[_chosen_candidate_index];
		var _skeleton = instance_create_layer(_chosen_corpse.x, _chosen_corpse.y, "Instances", o_skeleton);

		array_delete(corpse_draw_data, _chosen_candidate_index, 1);

		if (instance_exists(_skeleton))
		{
			move_spawned_summoned_unit_to_cannon_inner(_skeleton);
		}
	}
};

corpse_nearest_take = function(_origin_x, _origin_y)
{
	var _corpse_count = array_length(corpse_draw_data);
	var _nearest_corpse_index = -1;
	var _nearest_corpse_distance = infinity;

	for (var _corpse_index = 0; _corpse_index < _corpse_count; ++_corpse_index)
	{
		var _corpse = corpse_draw_data[_corpse_index];
		var _corpse_is_reserved = variable_struct_exists(_corpse, "reserved_by")
			&& instance_exists(_corpse.reserved_by);
		var _corpse_is_skeleton = variable_struct_exists(_corpse, "source_object_index")
			&& _corpse.source_object_index == o_skeleton;

		if (_corpse_is_reserved || _corpse_is_skeleton)
		{
			continue;
		}

		var _corpse_distance = point_distance(_origin_x, _origin_y, _corpse.x, _corpse.y);

		if (_corpse_distance < _nearest_corpse_distance)
		{
			_nearest_corpse_distance = _corpse_distance;
			_nearest_corpse_index = _corpse_index;
		}
	}

	if (_nearest_corpse_index < 0)
	{
		return noone;
	}

	var _nearest_corpse = corpse_draw_data[_nearest_corpse_index];
	array_delete(corpse_draw_data, _nearest_corpse_index, 1);

	return _nearest_corpse;
};

corpse_index_find = function(_corpse_id)
{
	var _corpse_count = array_length(corpse_draw_data);

	for (var _corpse_index = 0; _corpse_index < _corpse_count; ++_corpse_index)
	{
		var _corpse = corpse_draw_data[_corpse_index];

		if (variable_struct_exists(_corpse, "corpse_id") && _corpse.corpse_id == _corpse_id)
		{
			return _corpse_index;
		}
	}

	return -1;
};

corpse_get_by_id = function(_corpse_id)
{
	var _corpse_index = corpse_index_find(_corpse_id);

	if (_corpse_index < 0)
	{
		return noone;
	}

	return corpse_draw_data[_corpse_index];
};

corpse_nearest_reserve = function(_origin_x, _origin_y, _worker)
{
	if (!instance_exists(_worker))
	{
		return noone;
	}

	var _corpse_count = array_length(corpse_draw_data);
	var _nearest_corpse_index = -1;
	var _nearest_corpse_distance = infinity;

	for (var _corpse_index = 0; _corpse_index < _corpse_count; ++_corpse_index)
	{
		var _corpse = corpse_draw_data[_corpse_index];
		var _reserved_by = noone;

		if (variable_struct_exists(_corpse, "reserved_by"))
		{
			_reserved_by = _corpse.reserved_by;
		}

		if (instance_exists(_reserved_by) && _reserved_by != _worker)
		{
			continue;
		}

		var _corpse_distance = point_distance(_origin_x, _origin_y, _corpse.x, _corpse.y);
		var _corpse_is_inside_worker_search = true;

		if (variable_instance_exists(_worker, "corpse_search_radius"))
		{
			var _search_center_x = _worker.x;
			var _search_center_y = _worker.y;

			if (variable_instance_exists(_worker, "corpse_search_center_x"))
			{
				_search_center_x = _worker.corpse_search_center_x;
			}

			if (variable_instance_exists(_worker, "corpse_search_center_y"))
			{
				_search_center_y = _worker.corpse_search_center_y;
			}

			_corpse_is_inside_worker_search = point_distance(_search_center_x, _search_center_y, _corpse.x, _corpse.y) <= _worker.corpse_search_radius;
		}

		if (!_corpse_is_inside_worker_search)
		{
			continue;
		}

		if (_corpse_distance < _nearest_corpse_distance)
		{
			_nearest_corpse_distance = _corpse_distance;
			_nearest_corpse_index = _corpse_index;
		}
	}

	if (_nearest_corpse_index < 0)
	{
		return noone;
	}

	var _nearest_corpse = corpse_draw_data[_nearest_corpse_index];

	_nearest_corpse.reserved_by = _worker;
	corpse_draw_data[_nearest_corpse_index] = _nearest_corpse;

	return _nearest_corpse;
};

corpse_nearest_reserve_inside_distance = function(_origin_x, _origin_y, _worker, _max_distance)
{
	if (!instance_exists(_worker))
	{
		return noone;
	}

	// Reserve the nearest free corpse only when it is worth detouring from the cannon route.
	var _corpse_count = array_length(corpse_draw_data);
	var _nearest_corpse_index = -1;
	var _nearest_corpse_distance = _max_distance;

	for (var _corpse_index = 0; _corpse_index < _corpse_count; ++_corpse_index)
	{
		var _corpse = corpse_draw_data[_corpse_index];
		var _reserved_by = noone;

		if (variable_struct_exists(_corpse, "reserved_by"))
		{
			_reserved_by = _corpse.reserved_by;
		}

		if (instance_exists(_reserved_by) && _reserved_by != _worker)
		{
			continue;
		}

		var _corpse_distance = point_distance(_origin_x, _origin_y, _corpse.x, _corpse.y);
		var _corpse_is_inside_worker_search = true;

		if (variable_instance_exists(_worker, "corpse_search_radius"))
		{
			var _search_center_x = _worker.x;
			var _search_center_y = _worker.y;

			if (variable_instance_exists(_worker, "corpse_search_center_x"))
			{
				_search_center_x = _worker.corpse_search_center_x;
			}

			if (variable_instance_exists(_worker, "corpse_search_center_y"))
			{
				_search_center_y = _worker.corpse_search_center_y;
			}

			_corpse_is_inside_worker_search = point_distance(_search_center_x, _search_center_y, _corpse.x, _corpse.y) <= _worker.corpse_search_radius;
		}

		if (!_corpse_is_inside_worker_search)
		{
			continue;
		}

		if (_corpse_distance < _nearest_corpse_distance)
		{
			_nearest_corpse_distance = _corpse_distance;
			_nearest_corpse_index = _corpse_index;
		}
	}

	if (_nearest_corpse_index < 0)
	{
		return noone;
	}

	var _nearest_corpse = corpse_draw_data[_nearest_corpse_index];

	_nearest_corpse.reserved_by = _worker;
	corpse_draw_data[_nearest_corpse_index] = _nearest_corpse;

	return _nearest_corpse;
};

corpse_reserved_take = function(_corpse_id, _worker)
{
	var _corpse_index = corpse_index_find(_corpse_id);

	if (_corpse_index < 0 || !instance_exists(_worker))
	{
		return noone;
	}

	var _corpse = corpse_draw_data[_corpse_index];
	var _reserved_by = noone;

	if (variable_struct_exists(_corpse, "reserved_by"))
	{
		_reserved_by = _corpse.reserved_by;
	}

	if (instance_exists(_reserved_by) && _reserved_by != _worker)
	{
		return noone;
	}

	array_delete(corpse_draw_data, _corpse_index, 1);
	_corpse.reserved_by = noone;

	return _corpse;
};

corpse_reservation_clear = function(_corpse_id, _worker)
{
	var _corpse_index = corpse_index_find(_corpse_id);

	if (_corpse_index < 0)
	{
		return;
	}

	var _corpse = corpse_draw_data[_corpse_index];

	if (!variable_struct_exists(_corpse, "reserved_by")
		|| !instance_exists(_corpse.reserved_by)
		|| _corpse.reserved_by == _worker)
	{
		_corpse.reserved_by = noone;
		corpse_draw_data[_corpse_index] = _corpse;
	}
};

corpse_drop_at_position = function(_corpse, _world_x, _world_y)
{
	if (!is_struct(_corpse))
	{
		return;
	}

	_corpse.x = _world_x;
	_corpse.y = _world_y;
	_corpse.reserved_by = noone;
	array_push(corpse_draw_data, _corpse);
};

cannon_worker_carried_corpses_sync = function(_worker)
{
	if (!instance_exists(_worker))
	{
		return;
	}

	if (!variable_instance_exists(_worker, "carried_corpses"))
	{
		_worker.carried_corpses = [];
	}

	if (array_length(_worker.carried_corpses) <= 0
		&& variable_instance_exists(_worker, "carried_corpse")
		&& is_struct(_worker.carried_corpse))
	{
		array_push(_worker.carried_corpses, _worker.carried_corpse);
	}

	if (array_length(_worker.carried_corpses) > 0)
	{
		_worker.carried_corpse = _worker.carried_corpses[0];
	}
	else
	{
		_worker.carried_corpse = noone;
	}
};

cannon_worker_carried_corpse_count_get = function(_worker)
{
	cannon_worker_carried_corpses_sync(_worker);
	return array_length(_worker.carried_corpses);
};

cannon_worker_carried_corpse_add = function(_worker, _corpse)
{
	if (!instance_exists(_worker) || !is_struct(_corpse))
	{
		return;
	}

	cannon_worker_carried_corpses_sync(_worker);
	array_push(_worker.carried_corpses, _corpse);
	cannon_worker_carried_corpses_sync(_worker);
};

// Building construction menu stores the clicked slot and available building tiles.
building_window_slot = noone;
building_window_foundry = noone;
building_window_choices = [];
building_window_input_blocked = false;
building_window_width = 930;
building_window_height = 590;
building_window_resource_y = 68;
building_window_description_y = 92;
building_window_grid_y = 124;
building_tile_width = 150;
building_tile_height = 108;
building_tile_gap = 18;
building_tile_columns = 5;
building_tile_sprite_size = 44;
building_tile_cost_icon_size = 18;
building_group_header_height = 18;
building_group_gap_y = 24;
building_tooltip_width = 310;
building_tooltip_height = 120;
building_tooltip_padding = 12;
// Building event catalog is read-only and supports mouse-wheel scrolling.
building_events_window_building = noone;
building_events_window_entries = [];
building_events_window_name = "";
building_events_previous_pause_state = false;
building_events_input_blocked = false;
building_events_window_width = 930;
building_events_window_height = 620;
building_events_card_columns = 2;
building_events_card_width = 407;
building_events_card_height = 130;
building_events_card_gap_x = 18;
building_events_card_gap_y = 16;
building_events_card_start_y = 108;
building_events_scroll_row = 0;
building_choices = [
	{
		building_object: o_pitlings_pit2,
		building_sprite: s_hell_pit,
		building_name: "Demons Pit",
		building_group: "Units",
		building_description: "Allows summoning and upgrading demons.",
		construction_costs: [
			{
				resource: RESOURCES.IRON,
				cost: BALANCE_BUILDING_IRON_COST
			},
			{
				resource: RESOURCES.FLESH,
				cost: BALANCE_HELL_PIT_BUILDING_FLESH_COST
			}
		]
	},
	{
		building_object: o_graveyard2,
		building_sprite: s_graveyard30,
		building_name: "Graveyard",
		building_group: "Units",
		building_description: "Allows raising and upgrading undead.",
		construction_costs: [
			{
				resource: RESOURCES.IRON,
				cost: BALANCE_GRAVEYARD_BUILDING_IRON_COST
			},
			{
				resource: RESOURCES.SOULS,
				cost: BALANCE_GRAVEYARD_BUILDING_SOUL_COST
			}
		]
	},
	{
		building_object: o_meat_bath,
		building_sprite: s_meat_bath,
		building_name: "Blood Bath",
		building_group: "Other",
		building_description: "Allows performing operations with blood.",
		iron_cost: BALANCE_BUILDING_IRON_COST
	},
	{
		building_object: o_ritual_circle,
		building_sprite: s_ritual_circle,
		building_name: "Ritual Circle",
		building_group: "Other",
		building_description: "Allows performing rituals that affect the next night.",
		iron_cost: BALANCE_RITUAL_CIRCLE_BUILDING_IRON_COST
	},
	{
		building_object: o_shell_factory,
		building_sprite: s_shell_factory,
		building_name: "Shell Factory",
		building_group: "Other",
		building_description: "Allows producing and upgrading shells for the Cannon.",
		iron_cost: BALANCE_BUILDING_IRON_COST
	},
	{
		building_object: o_foundry,
		building_sprite: s_foundry,
		building_name: "Foundry",
		building_group: "Other",
		building_description: "Allows upgrading archdemons, demons, and undead.",
		iron_cost: BALANCE_BUILDING_IRON_COST
	}
];

foundry_shell_choices = [
	{
		building_object: o_tower_damage,
		building_sprite: s_damage_tower,
		building_name: "Damage Tower",
		building_description: "Forges a shell that builds a tower shooting enemies around itself.",
		construction_costs: [
			{
				resource: RESOURCES.IRON,
				cost: BALANCE_FOUNDRY_DAMAGE_TOWER_SHELL_IRON_COST
			},
			{
				resource: RESOURCES.IHOR,
				cost: BALANCE_FOUNDRY_DAMAGE_TOWER_SHELL_IHOR_COST
			}
		]
	},
	{
		building_object: o_tower_heal,
		building_sprite: s_heal_tower,
		building_name: "Heal Tower",
		building_description: "Forges a shell that builds a tower healing friendly troops nearby.",
		construction_costs: [
			{
				resource: RESOURCES.SOULS,
				cost: BALANCE_FOUNDRY_HEAL_TOWER_SHELL_SOUL_COST
			},
			{
				resource: RESOURCES.IHOR,
				cost: BALANCE_FOUNDRY_HEAL_TOWER_SHELL_IHOR_COST
			}
		]
	},
	{
		building_object: o_orcs_hut,
		building_sprite: s_orks_hut,
		building_name: "Orcs Pit",
		building_description: "Forges a shell that builds a pit with two neutral corpse-hauling orcs.",
		construction_costs: [
			{
				resource: RESOURCES.FLESH,
				cost: BALANCE_FOUNDRY_ORCS_PIT_SHELL_FLESH_COST
			},
			{
				resource: RESOURCES.IRON,
				cost: BALANCE_FOUNDRY_ORCS_PIT_SHELL_IRON_COST
			}
		]
	},
	{
		building_object: o_grave_spire,
		building_sprite: s_grave_spire,
		building_name: "Grave Spire",
		building_description: "Forges a shell that builds a spire spawning Skeletons every morning.",
		construction_costs: [
			{
				resource: RESOURCES.SOULS,
				cost: BALANCE_FOUNDRY_GRAVE_SPIRE_SHELL_SOUL_COST
			},
			{
				resource: RESOURCES.IHOR,
				cost: BALANCE_FOUNDRY_GRAVE_SPIRE_SHELL_IHOR_COST
			}
		]
	},
	{
		building_object: o_ihor_extractor,
		building_sprite: s_ihor_extractor,
		building_name: "Ihor Extractor",
		building_description: "Forges a shell that builds an extractor collecting Ihor from nearby veins each morning.",
		construction_costs: [
			{
				resource: RESOURCES.SOULS,
				cost: BALANCE_FOUNDRY_IHOR_EXTRACTOR_SHELL_SOUL_COST
			}
		]
	}
];

building_window_choices = building_choices;

// Debug menu gives projectiles, units, and persistent squads for fast gameplay testing.
debug_menu_open = false;
debug_menu_width = 330;
debug_menu_padding = 14;
debug_menu_button_width = 142;
debug_menu_button_height = 32;
debug_menu_button_gap = 8;
debug_menu_section_gap = 36;
debug_menu_x = 18;
debug_menu_y = 84;
debug_menu_title_height = 34;
debug_menu_tab_height = 30;
debug_menu_tab = "shells";
debug_menu_tab_ids = ["shells", "units", "squads", "events"];
debug_menu_tab_labels = ["Shells", "Units", "Squads", "Events"];

debug_shell_choices = [
	{
		label: "Damage",
		projectile_type: PROJECTILE_TYPE.DAMAGE,
		payload: noone
	},
	{
		label: "Heal",
		projectile_type: PROJECTILE_TYPE.HEAL,
		payload: noone
	},
	{
		label: "Bomb",
		projectile_type: PROJECTILE_TYPE.BOMB,
		payload: noone
	},
	{
		label: "Skeletons",
		projectile_type: PROJECTILE_TYPE.SKELETONS,
		payload: noone
	},
	{
		label: "Taint",
		projectile_type: PROJECTILE_TYPE.FEAST,
		payload: noone
	},
	{
		label: "Damage Tower",
		projectile_type: PROJECTILE_TYPE.BUILDING_SHELL,
		payload: {
			building_object: o_tower_damage,
			building_sprite: s_damage_tower,
			building_name: "Damage Tower"
		}
	},
	{
		label: "Heal Tower",
		projectile_type: PROJECTILE_TYPE.BUILDING_SHELL,
		payload: {
			building_object: o_tower_heal,
			building_sprite: s_heal_tower,
			building_name: "Heal Tower"
		}
	},
	{
		label: "Orcs Pit",
		projectile_type: PROJECTILE_TYPE.BUILDING_SHELL,
		payload: {
			building_object: o_orcs_hut,
			building_sprite: s_orks_hut,
			building_name: "Orcs Pit"
		}
	},
	{
		label: "Grave Spire",
		projectile_type: PROJECTILE_TYPE.BUILDING_SHELL,
		payload: {
			building_object: o_grave_spire,
			building_sprite: s_grave_spire,
			building_name: "Grave Spire"
		}
	},
	{
		label: "Ihor Extractor",
		projectile_type: PROJECTILE_TYPE.BUILDING_SHELL,
		payload: {
			building_object: o_ihor_extractor,
			building_sprite: s_ihor_extractor,
			building_name: "Ihor Extractor"
		}
	},
	{
		label: "Crusade",
		debug_action: "crusade",
		payload: noone
	},
	{
		label: "Boss Next Night",
		debug_action: "boss_next_night",
		payload: noone
	}
];

debug_unit_choices = [
	{
		label: "Skeleton",
		unit_object: o_skeleton
	},
	{
		label: "Skeleton Bonelet",
		unit_object: o_skeleton_bonelet
	},
	{
		label: "Skeleton Archer",
		unit_object: o_skeleton_archer
	},
	{
		label: "Skeleton Mage",
		unit_object: o_skeleton_mage
	},
	{
		label: "Skeleton Healer",
		unit_object: o_skeleton_healer
	},
	{
		label: "Skeleton Warrior",
		unit_object: o_skeleton_warrior
	},
	{
		label: "Zombie",
		unit_object: o_zombie
	},
	{
		label: "Succubus",
		unit_object: o_succubus
	},
	{
		label: "Mawling",
		unit_object: o_mawling
	},
	{
		label: "Demon Wizard (Buffer)",
		unit_object: o_demon_wizard
	},
	{
		label: "Balgor",
		unit_object: o_balgor
	},
	{
		label: "Peasant",
		unit_object: o_enemy_peasant
	},
	{
		label: "Knight",
		unit_object: o_enemy_knight
	},
	{
		label: "Archer",
		unit_object: o_enemy_archer
	},
	{
		label: "Mage",
		unit_object: o_enemy_mage
	},
	{
		label: "Catapult",
		unit_object: o_enemy_catapult
	},
	{
		label: "Crusader",
		unit_object: o_crusader
	},
	{
		label: "Griffith",
		unit_object: o_boss_griffith
	}
];

debug_squad_choices = [
	{ label: "SKEL BONELET", unit_object: o_skeleton_bonelet, squad_type: SQUAD_TYPE.UNDEAD, unit_count: BALANCE_SQUAD_SKELETON_COUNT },
	{ label: "SKEL WARRIOR", unit_object: o_skeleton_warrior, squad_type: SQUAD_TYPE.UNDEAD, unit_count: BALANCE_SQUAD_SKELETON_COUNT },
	{ label: "SKEL ARCHER", unit_object: o_skeleton_archer, squad_type: SQUAD_TYPE.UNDEAD, unit_count: BALANCE_SQUAD_SKELETON_COUNT },
	{ label: "SKEL MAGE", unit_object: o_skeleton_mage, squad_type: SQUAD_TYPE.UNDEAD, unit_count: BALANCE_SQUAD_SKELETON_COUNT },
	{ label: "SKEL HEALER", unit_object: o_skeleton_healer, squad_type: SQUAD_TYPE.UNDEAD, unit_count: BALANCE_SQUAD_SKELETON_COUNT },
	{ label: "MAWLING", unit_object: o_mawling, squad_type: SQUAD_TYPE.DEMON, unit_count: BALANCE_SQUAD_PITLING_COUNT },
	{ label: "DEMON WIZARD", unit_object: o_demon_wizard, squad_type: SQUAD_TYPE.DEMON, unit_count: BALANCE_SQUAD_PITLING_COUNT },
	{ label: "PITLING", unit_object: o_pitling, squad_type: SQUAD_TYPE.DEMON, unit_count: BALANCE_SQUAD_PITLING_COUNT },
	{ label: "SUCCUBUS", unit_object: o_succubus, squad_type: SQUAD_TYPE.DEMON, unit_count: BALANCE_SQUAD_PITLING_COUNT },
	{ label: "BALGOR", unit_object: o_balgor, squad_type: SQUAD_TYPE.DEMON, unit_count: BALANCE_SQUAD_PITLING_COUNT }
];

debug_event_choices = [
	{
		label: "All Events (F6)",
		debug_action: "all_events"
	}
];

debug_menu_choices_get = function()
{
	if (debug_menu_tab == "units")
	{
		return debug_unit_choices;
	}

	if (debug_menu_tab == "squads")
	{
		return debug_squad_choices;
	}

	if (debug_menu_tab == "events")
	{
		return debug_event_choices;
	}

	return debug_shell_choices;
};

debug_menu_hint_get = function()
{
	if (debug_menu_tab == "units")
	{
		return "Spawn: LMB x1 / RMB x5";
	}

	if (debug_menu_tab == "squads")
	{
		return "Add one squad (limit grows automatically)";
	}

	if (debug_menu_tab == "events")
	{
		return "Replace daily cards with all available events";
	}

	var _queue_count = variable_global_exists("cannon_projectile_queue")
		? array_length(global.cannon_projectile_queue)
		: 0;
	var _queue_max = variable_global_exists("cannon_projectile_queue_max")
		? global.cannon_projectile_queue_max
		: 0;
	return "Give Shell  |  Queue: " + string(_queue_count) + "/" + string(_queue_max);
};

debug_menu_height_get = function()
{
	var _button_count = array_length(debug_menu_choices_get());
	var _column_count = 2;
	var _row_count = ceil(_button_count / _column_count);
	return debug_menu_padding
		+ debug_menu_title_height
		+ debug_menu_tab_height
		+ debug_menu_button_gap
		+ debug_menu_section_gap
		+ (_row_count * debug_menu_button_height)
		+ (max(0, _row_count - 1) * debug_menu_button_gap)
		+ debug_menu_padding;
};

debug_shell_choice_rect_get = function(_choice_index)
{
	var _column_count = 2;
	var _column = _choice_index mod _column_count;
	var _row = _choice_index div _column_count;
	var _button_x = debug_menu_x + debug_menu_padding + ((debug_menu_button_width + debug_menu_button_gap) * _column);
	var _button_y = debug_menu_y + debug_menu_padding + debug_menu_title_height + debug_menu_tab_height
		+ debug_menu_button_gap + debug_menu_section_gap
		+ ((debug_menu_button_height + debug_menu_button_gap) * _row);

	return {
		x: _button_x,
		y: _button_y,
		width: debug_menu_button_width,
		height: debug_menu_button_height
	};
};

debug_menu_tab_rect_get = function(_tab_index)
{
	var _tab_count = array_length(debug_menu_tab_ids);
	var _available_width = debug_menu_width
		- (debug_menu_padding * 2)
		- (debug_menu_button_gap * (_tab_count - 1));
	var _tab_width = _available_width / _tab_count;

	return {
		x: debug_menu_x + debug_menu_padding + ((_tab_width + debug_menu_button_gap) * _tab_index),
		y: debug_menu_y + debug_menu_padding + debug_menu_title_height,
		width: _tab_width,
		height: debug_menu_tab_height
	};
};

debug_squad_create = function(_choice)
{
	if (!variable_struct_exists(_choice, "unit_object")
		|| !variable_struct_exists(_choice, "squad_type")
		|| !variable_struct_exists(_choice, "unit_count"))
	{
		return false;
	}

	var _squad_type = _choice.squad_type;
	var _squad_count = squad_type_count_get(_squad_type);

	// The cheat is allowed to exceed the limit and permanently grows it to fit the new squad.
	if (_squad_count >= global.squad_limits[_squad_type])
	{
		global.squad_limits[_squad_type] = _squad_count + 1;
	}

	return is_struct(squad_create(_squad_type, _choice.unit_object, _choice.unit_count));
};

debug_unit_spawn = function(_unit_object, _spawn_count = 1)
{
	if (!object_exists(_unit_object))
	{
		return false;
	}

	var _spawn_x = room_width * 0.5;
	var _spawn_y = room_height * 0.5;

	if (instance_exists(o_camera_controller))
	{
		var _camera_controller = instance_find(o_camera_controller, 0);
		_spawn_x = camera_get_view_x(_camera_controller.camera_id)
			+ (camera_get_view_width(_camera_controller.camera_id) * 0.5);
		_spawn_y = camera_get_view_y(_camera_controller.camera_id)
			+ (camera_get_view_height(_camera_controller.camera_id) * 0.5);
	}

	var _safe_spawn_count = max(1, floor(_spawn_count));
	var _unit_was_spawned = false;

	for (var _spawn_index = 0; _spawn_index < _safe_spawn_count; ++_spawn_index)
	{
		var _unit_x = _spawn_x;
		var _unit_y = _spawn_y;

		if (_safe_spawn_count > 1)
		{
			var _spawn_direction = 360 * (_spawn_index / _safe_spawn_count);
			_unit_x += lengthdir_x(BALANCE_DEBUG_UNIT_GROUP_SPAWN_RADIUS, _spawn_direction);
			_unit_y += lengthdir_y(BALANCE_DEBUG_UNIT_GROUP_SPAWN_RADIUS, _spawn_direction);
		}

		var _unit = instance_create_layer(_unit_x, _unit_y, "Instances", _unit_object);

		if (!instance_exists(_unit))
		{
			continue;
		}

		// Match a unit deployed into combat while keeping cheats out of persistent squads.
		_unit.debug_combat_spawned = true;
		_unit.target_instance = noone;
		_unit.alert_target = noone;
		_unit.forced_attack_target = noone;
		_unit.forced_attack_target_timer = 0;
		_unit.regroup_is_active = false;
		_unit.rally_is_active = false;
		_unit.rally_is_returning = false;
		_unit.rally_has_arrived = false;
		_unit.target_search_update_timer = _unit.target_search_update_interval;
		_unit.clamp_outside_cannon_wall();
		_unit_was_spawned = true;
	}

	return _unit_was_spawned;
};

debug_all_events_give = function()
{
	var _jobs_ui = noone;

	if (instance_exists(o_jobs_ui))
	{
		_jobs_ui = instance_find(o_jobs_ui, 0);

		if (global.focus_window == FOCUS_WINDOW.JOBS)
		{
			_jobs_ui.jobs_window_close();
		}
	}

	var _event_count = day_event_debug_all_events_generate();

	debug_menu_open = false;

	if (instance_exists(_jobs_ui)
		&& global.day_phase == DAY_PHASE.DAY
		&& global.focus_window == FOCUS_WINDOW.NOONE)
	{
		_jobs_ui.jobs_window_open();
	}

	if (variable_global_exists("ui_confirm_sound_play"))
	{
		global.ui_confirm_sound_play();
	}

	return _event_count;
};

debug_menu_choice_activate = function(_choice, _unit_spawn_count = 1)
{
	if (debug_menu_tab == "squads")
	{
		return debug_squad_create(_choice);
	}

	if (debug_menu_tab == "units" && variable_struct_exists(_choice, "unit_object"))
	{
		return debug_unit_spawn(_choice.unit_object, _unit_spawn_count);
	}

	return debug_shell_give(_choice);
};

debug_shell_give = function(_choice)
{
	if (variable_struct_exists(_choice, "debug_action"))
	{
		if (_choice.debug_action == "all_events")
		{
			debug_all_events_give();
			return true;
		}
		else if (_choice.debug_action == "crusade")
		{
			crusade_spawn(random(360));
			return true;
		}
		else if (_choice.debug_action == "boss_next_night")
		{
			boss_griffith_force_next_night = true;
			boss_griffith_pending_next_night = false;
			night_attack_plan_exists = false;
			night_attack_plan_create();
			return true;
		}
	}

	if (!variable_struct_exists(_choice, "projectile_type"))
	{
		return false;
	}

	var _payload = noone;

	if (variable_struct_exists(_choice, "payload"))
	{
		_payload = _choice.payload;
	}

	// Taint is owned by satiety, so cheats fill it just like corpse delivery.
	if (_choice.projectile_type == PROJECTILE_TYPE.FEAST)
	{
		var _satiety_to_next_feast = global.cannon_satiety_max - (global.cannon_satiety mod global.cannon_satiety_max);

		if (_satiety_to_next_feast <= 0)
		{
			_satiety_to_next_feast = global.cannon_satiety_max;
		}

		cannon_satiety_add(_satiety_to_next_feast);
		return true;
	}

	return cannon_projectile_queue_add(_choice.projectile_type, _payload);
};

debug_menu_draw = function()
{
	if (!global.cheats_enabled || !debug_menu_open)
	{
		return;
	}

	var _mouse_x = device_mouse_x_to_gui(0);
	var _mouse_y = device_mouse_y_to_gui(0);
	var _menu_height = debug_menu_height_get();
	var _choices = debug_menu_choices_get();
	var _choice_count = array_length(_choices);
	var _queue_count = 0;

	if (variable_global_exists("cannon_projectile_queue"))
	{
		_queue_count = array_length(global.cannon_projectile_queue);
	}

	draw_set_alpha(0.9);
	draw_set_color(COLOR_HUD_BACKGROUND);
	draw_rectangle(debug_menu_x, debug_menu_y, debug_menu_x + debug_menu_width, debug_menu_y + _menu_height, false);

	draw_set_alpha(1);
	draw_set_color(COLOR_PROJECTILE_BUILDING_SHELL);
	draw_rectangle(debug_menu_x, debug_menu_y, debug_menu_x + debug_menu_width, debug_menu_y + _menu_height, true);

	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(COLOR_HUD_TEXT);

	if (variable_global_exists("ui_heading_font") && font_exists(global.ui_heading_font))
	{
		draw_set_font(global.ui_heading_font);
	}

	draw_text(debug_menu_x + debug_menu_padding, debug_menu_y + debug_menu_padding, "Debug Menu");

	if (variable_global_exists("ui_font") && font_exists(global.ui_font))
	{
		draw_set_font(global.ui_font);
	}

	var _tab_count = array_length(debug_menu_tab_ids);

	for (var _tab_index = 0; _tab_index < _tab_count; ++_tab_index)
	{
		var _tab_rect = debug_menu_tab_rect_get(_tab_index);
		var _tab_is_active = debug_menu_tab == debug_menu_tab_ids[_tab_index];
		var _tab_is_hovered = _mouse_x >= _tab_rect.x
			&& _mouse_x <= _tab_rect.x + _tab_rect.width
			&& _mouse_y >= _tab_rect.y
			&& _mouse_y <= _tab_rect.y + _tab_rect.height;

		draw_set_alpha(_tab_is_active ? 0.9 : 0.55);
		draw_set_color(c_black);
		draw_rectangle(_tab_rect.x, _tab_rect.y, _tab_rect.x + _tab_rect.width, _tab_rect.y + _tab_rect.height, false);

		draw_set_alpha(1);
		draw_set_color(_tab_is_active || _tab_is_hovered ? COLOR_PROJECTILE_BUILDING_SHELL : COLOR_HUD_PROJECTILE_DESCRIPTION);
		draw_rectangle(_tab_rect.x, _tab_rect.y, _tab_rect.x + _tab_rect.width, _tab_rect.y + _tab_rect.height, true);

		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		draw_set_color(COLOR_HUD_TEXT);
		draw_text(
			_tab_rect.x + (_tab_rect.width * 0.5),
			_tab_rect.y + (_tab_rect.height * 0.5),
			debug_menu_tab_labels[_tab_index]
		);
	}

	draw_set_color(COLOR_PROJECTILE_BUILDING_SHELL);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_text(
		debug_menu_x + debug_menu_padding,
		debug_menu_y + debug_menu_padding + debug_menu_title_height + debug_menu_tab_height + debug_menu_button_gap + 10,
		debug_menu_hint_get()
	);

	for (var _choice_index = 0; _choice_index < _choice_count; ++_choice_index)
	{
		var _choice = _choices[_choice_index];
		var _rect = debug_shell_choice_rect_get(_choice_index);
		var _is_hovered = _mouse_x >= _rect.x
			&& _mouse_x <= _rect.x + _rect.width
			&& _mouse_y >= _rect.y
			&& _mouse_y <= _rect.y + _rect.height;
		var _uses_projectile_queue = variable_struct_exists(_choice, "projectile_type");
		var _queue_full = _uses_projectile_queue && _queue_count >= global.cannon_projectile_queue_max;

		draw_set_alpha(_queue_full ? 0.42 : 0.78);
		draw_set_color(c_black);
		draw_rectangle(_rect.x, _rect.y, _rect.x + _rect.width, _rect.y + _rect.height, false);

		draw_set_alpha(1);
		draw_set_color(_queue_full ? COLOR_HUD_PROJECTILE_DESCRIPTION : (_is_hovered ? COLOR_PROJECTILE_BUILDING_SHELL : c_white));
		draw_rectangle(_rect.x, _rect.y, _rect.x + _rect.width, _rect.y + _rect.height, true);

		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		draw_set_color(_queue_full ? COLOR_HUD_PROJECTILE_DESCRIPTION : COLOR_HUD_TEXT);
		draw_text(_rect.x + (_rect.width * 0.5), _rect.y + (_rect.height * 0.5), _choice.label);
	}

	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
	draw_set_alpha(1);
};

// Base window and GUI size for the strategy view.
base_view_width = 1366;
base_view_height = 768;
target_aspect_ratio = base_view_width / base_view_height;

// Camera view keeps fixed proportions to prevent visual stretching.
camera_view_width = base_view_width;
camera_view_height = base_view_height;

// Window and GUI size follow the actual player window.
main_view_index = 0;
current_view_width = base_view_width;
current_view_height = base_view_height;
windowed_view_width = base_view_width;
windowed_view_height = base_view_height;
previous_window_width = base_view_width;
previous_window_height = base_view_height;
application_surface_ready = false;

// Pause menu state.
pause_menu_open = false;
settings_open = false;
player_pause_active = false;
fullscreen_enabled = window_get_fullscreen();

// Target selection state.
target_selection_projectile_type = PROJECTILE_TYPE.DAMAGE;
target_selection_radius = BALANCE_PROJECTILE_EFFECT_RADIUS;
target_selection_alpha = 0.35;
target_selection_outline_alpha = 0.85;

// Building shell previews use the future structure's gameplay radius when it has one.
building_shell_preview_radius_get = function(_building_payload)
{
	if (!is_struct(_building_payload)
		|| !variable_struct_exists(_building_payload, "building_object"))
	{
		return 0;
	}

	if (_building_payload.building_object == o_tower_damage)
	{
		return BALANCE_TOWER_DAMAGE_RADIUS;
	}

	if (_building_payload.building_object == o_tower_heal)
	{
		return BALANCE_TOWER_HEAL_RADIUS;
	}

	if (_building_payload.building_object == o_orcs_hut)
	{
		return BALANCE_ORCS_HUT_CORPSE_SEARCH_RADIUS;
	}

	if (_building_payload.building_object == o_grave_spire)
	{
		return BALANCE_GRAVE_SPIRE_RADIUS;
	}

	if (_building_payload.building_object == o_ihor_extractor)
	{
		return BALANCE_IHOR_EXTRACTOR_RADIUS;
	}

	return 0;
};

// Building shell preview circles match the hover radius colors of built structures.
building_shell_preview_color_get = function(_building_payload)
{
	if (!is_struct(_building_payload)
		|| !variable_struct_exists(_building_payload, "building_object"))
	{
		return COLOR_PROJECTILE_BUILDING_SHELL;
	}

	if (_building_payload.building_object == o_tower_damage)
	{
		return COLOR_TOWER_DAMAGE_RADIUS;
	}

	if (_building_payload.building_object == o_tower_heal)
	{
		return COLOR_TOWER_HEAL_RADIUS;
	}

	if (_building_payload.building_object == o_orcs_hut)
	{
		return COLOR_ORCS_HUT_RADIUS;
	}

	if (_building_payload.building_object == o_grave_spire)
	{
		return COLOR_PROJECTILE_DAMAGE;
	}

	if (_building_payload.building_object == o_ihor_extractor)
	{
		return COLOR_IHOR_EXTRACTOR_RADIUS;
	}

	return COLOR_PROJECTILE_BUILDING_SHELL;
};

projectile_target_selection_radius_get = function(_projectile_type)
{
	if (_projectile_type == PROJECTILE_TYPE.FEAST)
	{
		if (instance_exists(o_cannon))
		{
			var _cannon = instance_find(o_cannon, 0);

			if (variable_instance_exists(_cannon, "cannon_feast_radius_get"))
			{
				return _cannon.cannon_feast_radius_get();
			}
		}

		return BALANCE_CANNON_FEAST_RADIUS;
	}

	if (_projectile_type == PROJECTILE_TYPE.CULTIST)
	{
		return BALANCE_CULTIST_PROJECTILE_EFFECT_RADIUS;
	}

	if (_projectile_type == PROJECTILE_TYPE.HEAL)
	{
		return BALANCE_PROJECTILE_HEAL_RADIUS;
	}

	if (_projectile_type == PROJECTILE_TYPE.BOMB)
	{
		return BALANCE_PROJECTILE_BOMB_RADIUS;
	}

	if (_projectile_type == PROJECTILE_TYPE.DOOM_BELL)
	{
		return BALANCE_PROJECTILE_DOOM_BELL_RADIUS;
	}

	if (_projectile_type == PROJECTILE_TYPE.SKELETONS)
	{
		return BALANCE_PROJECTILE_SKELETON_RADIUS;
	}

	if (_projectile_type == PROJECTILE_TYPE.BUILDING_SHELL)
	{
		return BALANCE_PROJECTILE_EFFECT_RADIUS;
	}

	return BALANCE_PROJECTILE_EFFECT_RADIUS;
};

cannon_projectile_type_can_stack_in_hud = function(_projectile_type)
{
	return _projectile_type != PROJECTILE_TYPE.CULTIST
		&& _projectile_type != PROJECTILE_TYPE.BUILDING_SHELL;
};

cannon_projectile_display_slots_get = function(_max_display_count)
{
	var _slots = array_create(0);

	if (!variable_global_exists("cannon_projectile_queue"))
	{
		return _slots;
	}

	var _projectile_queue_count = array_length(global.cannon_projectile_queue);

	for (var _queue_index = 0; _queue_index < _projectile_queue_count; ++_queue_index)
	{
		var _projectile_type = global.cannon_projectile_queue[_queue_index];
		var _display_index = -1;

		if (cannon_projectile_type_can_stack_in_hud(_projectile_type))
		{
			var _slot_count = array_length(_slots);

			for (var _slot_index = 0; _slot_index < _slot_count; ++_slot_index)
			{
				var _slot = _slots[_slot_index];

				if (_slot.projectile_type == _projectile_type && _slot.queue_index >= 0)
				{
					_display_index = _slot_index;
					break;
				}
			}
		}

		if (_display_index >= 0)
		{
			var _stack_slot = _slots[_display_index];
			_stack_slot.count += 1;
			_stack_slot.consume_queue_index = _queue_index;
			_slots[_display_index] = _stack_slot;
		}
		else if (array_length(_slots) < _max_display_count)
		{
			array_push(_slots, {
				projectile_type: _projectile_type,
				queue_index: _queue_index,
				consume_queue_index: _queue_index,
				count: 1
			});
		}
	}

	if (variable_global_exists("cannon_satiety") && variable_global_exists("cannon_satiety_max"))
	{
		var _feast_count = floor(max(0, global.cannon_satiety) / max(1, global.cannon_satiety_max));

		if (_feast_count > 0 && array_length(_slots) < _max_display_count)
		{
			array_push(_slots, {
				projectile_type: PROJECTILE_TYPE.FEAST,
				queue_index: _projectile_queue_count,
				consume_queue_index: _projectile_queue_count,
				count: _feast_count
			});
		}
	}

	return _slots;
};

// Pause menu button data.
continue_button_index = 0;
settings_button_index = 1;
feedback_button_index = 2;
quit_button_index = 3;
pause_feedback_url = "https://forms.gle/MfkpVuGar52YaUfm6";

// Menu visual settings.
overlay_alpha = 0.45;
day_overlay_alpha = BALANCE_DAY_OVERLAY_ALPHA;
night_overlay_alpha = BALANCE_NIGHT_OVERLAY_ALPHA;
button_width = 280;
button_height = 58;
button_gap = 18;
settings_panel_width = 420;
settings_panel_height = 560;
settings_close_bottom_padding = 28;
settings_slider_count = 5;
settings_slider_labels = ["Music", "Ambient", "Sounds", "Edge Speed", "Camera Speed"];
settings_slider_x = 150;
settings_slider_y = 104;
settings_slider_width = 200;
settings_slider_height = 12;
settings_slider_gap_y = 54;
settings_slider_knob_radius = 10;
settings_drag_slider_index = -1;
settings_edge_toggle_x = 150;
settings_edge_toggle_y = 426;
settings_edge_toggle_size = 24;
pause_feedback_button_width = 460;
pause_feedback_button_height = 76;
pause_button_labels = ["CONTINUE", "SETTINGS", "PLEASE LEAVE A FEEDBACK", "QUIT"];
pause_button_widths = [button_width, button_width, pause_feedback_button_width, button_width];
pause_button_heights = [button_height, button_height, pause_feedback_button_height, button_height];
pause_button_count = array_length(pause_button_labels);

pause_button_width_get = function(_button_index)
{
	return pause_button_widths[_button_index];
};

pause_button_height_get = function(_button_index)
{
	return pause_button_heights[_button_index];
};

pause_button_total_height_get = function()
{
	var _total_height = 0;

	for (var _button_index = 0; _button_index < pause_button_count; ++_button_index)
	{
		_total_height += pause_button_height_get(_button_index);
	}

	var _gap_count = max(0, pause_button_count - 1);
	_total_height += button_gap * _gap_count;

	return _total_height;
};

pause_button_y_get = function(_button_index)
{
	var _button_y = (camera_view_height - pause_button_total_height_get()) * 0.5;

	for (var _previous_button_index = 0; _previous_button_index < _button_index; ++_previous_button_index)
	{
		_button_y += pause_button_height_get(_previous_button_index) + button_gap;
	}

	return _button_y;
};

pause_button_x_get = function(_button_index)
{
	return (camera_view_width - pause_button_width_get(_button_index)) * 0.5;
};

settings_slider_rect_get = function(_slider_index)
{
	var _panel_x = (camera_view_width - settings_panel_width) * 0.5;
	var _panel_y = (camera_view_height - settings_panel_height) * 0.5;
	var _slider_x = _panel_x + settings_slider_x;
	var _slider_y = _panel_y + settings_slider_y + ((settings_slider_height + settings_slider_gap_y) * _slider_index);

	return {
		x: _slider_x,
		y: _slider_y,
		width: settings_slider_width,
		height: settings_slider_height
	};
};

settings_slider_value_get = function(_slider_index)
{
	if (_slider_index == 0)
	{
		return global.music_volume;
	}

	if (_slider_index == 1)
	{
		return global.ambient_volume;
	}

	if (_slider_index == 2)
	{
		return global.sound_volume;
	}

	if (_slider_index == 3)
	{
		return global.edge_scroll_speed;
	}

	return global.camera_speed;
};

settings_slider_value_set = function(_slider_index, _value)
{
	var _clamped_value = clamp(_value, 0, 1);

	if (_slider_index == 0)
	{
		global.music_volume = _clamped_value;
	}
	else if (_slider_index == 1)
	{
		global.ambient_volume = _clamped_value;
	}
	else if (_slider_index == 2)
	{
		global.sound_volume = _clamped_value;
	}
	else if (_slider_index == 3)
	{
		global.edge_scroll_speed = _clamped_value;
	}
	else
	{
		global.camera_speed = _clamped_value;
	}
};

settings_slider_find_at_gui = function(_mouse_x, _mouse_y)
{
	for (var _slider_index = 0; _slider_index < settings_slider_count; ++_slider_index)
	{
		var _rect = settings_slider_rect_get(_slider_index);
		var _hit_padding = settings_slider_knob_radius + 4;

		if (ui_mouse_is_inside_rect(
			_mouse_x,
			_mouse_y,
			_rect.x - _hit_padding,
			_rect.y - _hit_padding,
			_rect.width + (_hit_padding * 2),
			_rect.height + (_hit_padding * 2)
		))
		{
			return _slider_index;
		}
	}

	return -1;
};

settings_slider_value_from_gui = function(_slider_index, _mouse_x)
{
	var _rect = settings_slider_rect_get(_slider_index);
	return clamp((_mouse_x - _rect.x) / max(1, _rect.width), 0, 1);
};

settings_edge_toggle_rect_get = function()
{
	var _panel_x = (camera_view_width - settings_panel_width) * 0.5;
	var _panel_y = (camera_view_height - settings_panel_height) * 0.5;

	return {
		x: _panel_x + settings_edge_toggle_x,
		y: _panel_y + settings_edge_toggle_y,
		width: settings_edge_toggle_size,
		height: settings_edge_toggle_size
	};
};

// Cultist prototype state.
cultist_start_count = BALANCE_STARTING_CULTIST_COUNT;
starting_goblin_count = BALANCE_STARTING_GOBLIN_COUNT;
starting_event_cultist_count = BALANCE_STARTING_EVENT_CULTIST_COUNT;
cultist_reward_days = [];
next_cultist_reward_index = 0;
cultists_spawned = false;
starting_cultist_selection_pending = false;
starting_goblins_bound_to_first_pit = false;
cultist_selection_index = 0;
cultist_selected_demon_type = DEMON_TYPE.IMP;
cultist_selected_starting_ability = DEMON_ABILITY.IMP_DEMON_LEAP;
cultist_name_input_active = true;
cultist_selection_buttons = [
	DEMON_TYPE.BRUTE,
	DEMON_TYPE.IMP,
	DEMON_TYPE.WARLOCK
];
cultist_selection_button_width = 135;
cultist_selection_button_height = 58;
cultist_selection_button_gap = 27;
cultist_ability_selection_button_width = 135;
cultist_ability_selection_button_height = 59;
cultist_ability_selection_button_gap = 27;
cultist_panel_width = 720;
cultist_demon_selection_panel_width = 900;
cultist_panel_height = 836;
cultist_levelup_open = false;
cultist_levelup_index = 0;
cultist_levelup_previous_pause_state = false;
cultist_levelup_previous_player_pause_state = false;
cultist_levelup_selected_stat = -1;
cultist_levelup_selected_ability = DEMON_ABILITY.NONE;
cultist_levelup_selected_reward_type = CULTIST_LEVEL_REWARD.ATTRIBUTE;
cultist_levelup_button_width = 92;
cultist_levelup_button_height = 28;
cultist_levelup_button_offset_y = 48;
cultist_levelup_button_pulse_amount = 0.16;
cultist_levelup_button_pulse_speed = 0.008;
cultist_drag_lift_offset_y = -30;
cultist_drag_drop_offset_y = 30;
pickup_hand_drag_offset_y = BALANCE_PICKUP_HAND_DRAG_OFFSET_Y;
global.cultist_drag_shadow_width = 46;
global.cultist_drag_shadow_height = 14;
global.dragged_cultist = noone;
global.cultist_assignment_preview_building = noone;
global.cultist_sprite_randomization_enabled = true;
global.cultist_all_sprite_indices = [
	s_cultist_01,
	s_cultist_02,
	s_cultist_03,
	s_cultist_04
];
global.cultist_available_sprite_indices = global.cultist_all_sprite_indices;

// Night attack state stores the planned directions shown during the next day.
night_attack_night_index = 1;
night_attack_plan_exists = false;
night_attack_directions = [];
boss_griffith_night_interval = BALANCE_BOSS_GRIFFITH_NIGHT_INTERVAL;
boss_griffith_pending_next_night = false;
boss_griffith_pending_direction = 0;
boss_griffith_force_next_night = false;
full_moon_night_interval = BALANCE_FULL_MOON_NIGHT_INTERVAL;
crusade_taint_trigger_amount = BALANCE_ENEMY_CATAPULT_CRUSADE_TAINT_TRIGGER_AMOUNT;
crusade_pending_count = 0;
crusade_pending_directions = [];
crusade_taint_threshold_index = 0;
crusade_taint_tracking_initialized = false;
crusade_corruption_check_interval = BALANCE_PLAYER_BUILDING_CORRUPTION_CHECK_INTERVAL;
crusade_corruption_check_timer = irandom(crusade_corruption_check_interval - 1);
night_force_end_timer = 0;
night_force_end_active = false;
night_attack_unit_pool = [
	o_enemy_archer,
	o_enemy_knight,
	o_enemy_mage,
	o_enemy_peasant
];

// Adaptive difficulty is a separate soft modifier applied to future night attack plans.
adaptive_difficulty_multiplier = 1;
adaptive_night_cannon_hp_start = 0;
adaptive_night_tracked_cultist_count = 0;
adaptive_last_night_cannon_hp_loss_share = 0;
adaptive_last_night_low_hp_cultists = 0;
adaptive_last_night_heavy_damage_cultists = 0;
adaptive_last_night_cultist_knocked_out = false;
adaptive_night_cultist_knocked_out = false;
adaptive_last_night_delta = 0;
cannon_corrupted_ground_damage_timer = 0;

// Fog visibility helper is used by abilities that require a revealed target point.
world_position_is_revealed_by_fog = function(_world_x, _world_y)
{
	if (!global.fog_of_war_visible || !instance_exists(o_fog_of_war))
	{
		return true;
	}

	var _fog_of_war = instance_find(o_fog_of_war, 0);

	if (!variable_instance_exists(_fog_of_war, "fog_grid"))
	{
		return true;
	}

	var _cell_x = floor(_world_x / _fog_of_war.cell_size);
	var _cell_y = floor(_world_y / _fog_of_war.cell_size);
	var _is_inside_fog_grid = _cell_x >= 0
		&& _cell_x < _fog_of_war.grid_width
		&& _cell_y >= 0
		&& _cell_y < _fog_of_war.grid_height;

	if (!_is_inside_fog_grid)
	{
		return false;
	}

	var _fog_alpha = ds_grid_get(_fog_of_war.fog_grid, _cell_x, _cell_y);
	return _fog_alpha <= _fog_of_war.revealed_alpha;
};

// Feast shots must expand from existing fully corrupted ground.
feast_target_touches_corruption = function(_world_x, _world_y)
{
	if (!instance_exists(o_corruption_grid))
	{
		return false;
	}

	var _corruption_grid = instance_find(o_corruption_grid, 0);

	if (!variable_instance_exists(_corruption_grid, "circle_has_full_corruption"))
	{
		return false;
	}

	var _feast_radius = BALANCE_CANNON_FEAST_RADIUS;

	if (instance_exists(o_cannon))
	{
		var _cannon = instance_find(o_cannon, 0);

		if (variable_instance_exists(_cannon, "cannon_feast_radius_get"))
		{
			_feast_radius = _cannon.cannon_feast_radius_get();
		}
	}

	return _corruption_grid.circle_has_full_corruption(_world_x, _world_y, _feast_radius);
};

cannon_corrupted_ground_damage_update = function()
{
	if (global.pause || !instance_exists(o_cannon) || !instance_exists(o_corruption_grid))
	{
		return;
	}

	var _cannon = instance_find(o_cannon, 0);

	if (!variable_instance_exists(_cannon, "cannon_corrupted_ground_damage_get"))
	{
		return;
	}

	var _damage_per_second = _cannon.cannon_corrupted_ground_damage_get();

	if (_damage_per_second <= 0)
	{
		return;
	}

	cannon_corrupted_ground_damage_timer--;

	if (cannon_corrupted_ground_damage_timer > 0)
	{
		return;
	}

	cannon_corrupted_ground_damage_timer = BALANCE_CANNON_CORRUPTED_GROUND_DAMAGE_TICK_TIME * room_speed;

	var _corruption_grid = instance_find(o_corruption_grid, 0);
	var _tick_damage = _damage_per_second * BALANCE_CANNON_CORRUPTED_GROUND_DAMAGE_TICK_TIME;
	var _enemy_count = instance_number(o_enemy_units);

	for (var _enemy_index = 0; _enemy_index < _enemy_count; ++_enemy_index)
	{
		var _enemy = instance_find(o_enemy_units, _enemy_index);

		if (!instance_exists(_enemy)
			|| !variable_instance_exists(_enemy, "hp")
			|| _enemy.hp <= 0)
		{
			continue;
		}

		var _cell_x = floor(_enemy.x / _corruption_grid.cell_size);
		var _cell_y = floor(_enemy.y / _corruption_grid.cell_size);
		var _is_inside_grid = _cell_x >= 0
			&& _cell_x < _corruption_grid.grid_width
			&& _cell_y >= 0
			&& _cell_y < _corruption_grid.grid_height;

		if (!_is_inside_grid)
		{
			continue;
		}

		var _saint = 0;
		var _corruption = ds_grid_get(_corruption_grid.corruption_grid, _cell_x, _cell_y);

		if (variable_instance_exists(_corruption_grid, "saint_grid"))
		{
			_saint = ds_grid_get(_corruption_grid.saint_grid, _cell_x, _cell_y);
		}

		if (_saint > 0 || _corruption <= 0)
		{
			continue;
		}

		if (variable_instance_exists(_enemy, "unit_damage_receive"))
		{
			_enemy.unit_damage_receive(_tick_damage, UNIT_FACTION.NOONE);
		}
		else
		{
			_enemy.hp = max(_enemy.hp - _tick_damage, 0);
			damage_popup_create(_enemy.x, _enemy.y, _tick_damage, UNIT_FACTION.ENEMY);
		}
	}
};

// Cannon wall helpers keep demon-form cultists outside the cannon safe zone.
cannon_wall_is_active = function()
{
	return global.day_phase == DAY_PHASE.NIGHT && instance_exists(o_cannon);
};

unit_is_demon_form = function(_unit)
{
	return instance_exists(_unit)
		&& variable_instance_exists(_unit, "demon_type")
		&& _unit.demon_type != DEMON_TYPE.NONE
		&& _unit.object_index != o_archdemon;
};

unit_is_blocked_by_cannon_wall = function(_unit)
{
	if (!instance_exists(_unit))
	{
		return false;
	}

	var _is_summoned_night_unit = global.day_phase == DAY_PHASE.NIGHT
		&& (variable_instance_exists(_unit, "summon_nights_remaining")
			|| (variable_instance_exists(_unit, "squad")
				&& is_struct(_unit.squad)
				&& _unit.squad.squad_type != SQUAD_TYPE.ARCHDEMON));

	return unit_is_demon_form(_unit) || _is_summoned_night_unit;
};

cannon_wall_position_clamp = function(_world_x, _world_y)
{
	if (!instance_exists(o_cannon))
	{
		return [_world_x, _world_y];
	}

	var _cannon = instance_find(o_cannon, 0);
	var _distance_to_cannon = point_distance(_world_x, _world_y, _cannon.x, _cannon.y);

	if (_distance_to_cannon >= BALANCE_CANNON_WALL_RADIUS)
	{
		return [_world_x, _world_y];
	}

	var _direction_from_cannon = point_direction(_cannon.x, _cannon.y, _world_x, _world_y);

	if (_distance_to_cannon <= 0)
	{
		_direction_from_cannon = 0;
	}

	return [
		_cannon.x + lengthdir_x(BALANCE_CANNON_WALL_RADIUS, _direction_from_cannon),
		_cannon.y + lengthdir_y(BALANCE_CANNON_WALL_RADIUS, _direction_from_cannon)
	];
};

// Worker assignment helpers connect day-form cultists to production buildings.
arrange_resource_building_workers = function(_building)
{
	if (!instance_exists(_building) || !variable_instance_exists(_building, "worker_cultists"))
	{
		return;
	}

	if (_building.object_index == o_cannon)
	{
		return;
	}

	var _worker_count = array_length(_building.worker_cultists);

	for (var _worker_index = 0; _worker_index < _worker_count; ++_worker_index)
	{
		var _worker = _building.worker_cultists[_worker_index];

		if (!instance_exists(_worker))
		{
			continue;
		}

		var _worker_offset = (_worker_index - ((_worker_count - 1) * 0.5)) * _building.worker_stand_spacing;

		_worker.x = _building.x + _worker_offset;
		_worker.y = _building.bbox_bottom + _building.worker_stand_offset_y;
		_worker.drag_drop_x = _worker.x;
		_worker.drag_drop_y = _worker.y;
	}
};

cannon_corpse_worker_drop = function(_worker)
{
	if (!instance_exists(_worker))
	{
		return;
	}

	cannon_worker_carried_corpses_sync(_worker);

	if (variable_instance_exists(_worker, "carried_corpses"))
	{
		var _carried_count = array_length(_worker.carried_corpses);

		for (var _corpse_index = 0; _corpse_index < _carried_count; ++_corpse_index)
		{
			var _carried_corpse = _worker.carried_corpses[_corpse_index];
			var _drop_x = _worker.x + ((_corpse_index - ((_carried_count - 1) * 0.5)) * 18);
			var _drop_y = _worker.y + (_corpse_index * 8);

			corpse_drop_at_position(_carried_corpse, _drop_x, _drop_y);
		}

		_worker.carried_corpses = [];
		_worker.carried_corpse = noone;
	}

	if (variable_instance_exists(_worker, "reserved_corpse_id") && _worker.reserved_corpse_id != noone)
	{
		corpse_reservation_clear(_worker.reserved_corpse_id, _worker);
		_worker.reserved_corpse_id = noone;
	}

	if (variable_instance_exists(_worker, "cannon_no_corpse_warning_active"))
	{
		_worker.cannon_no_corpse_warning_active = false;
	}
};

clear_cultist_building_assignment = function(_cultist)
{
	if (!instance_exists(_cultist) || !variable_instance_exists(_cultist, "assigned_building"))
	{
		return;
	}

	cannon_corpse_worker_drop(_cultist);

	var _assigned_building = _cultist.assigned_building;

	if (instance_exists(_assigned_building)
		&& variable_instance_exists(_assigned_building, "worker_cultists"))
	{
		var _worker_count = array_length(_assigned_building.worker_cultists);
		var _write_index = 0;

		for (var _worker_index = 0; _worker_index < _worker_count; ++_worker_index)
		{
			var _worker = _assigned_building.worker_cultists[_worker_index];

			if (_worker != _cultist)
			{
				_assigned_building.worker_cultists[_write_index] = _worker;
				_write_index++;
			}
		}

		array_resize(_assigned_building.worker_cultists, _write_index);
		arrange_resource_building_workers(_assigned_building);

		if (variable_instance_exists(_assigned_building, "recalculate_production_speed_multiplier"))
		{
			_assigned_building.recalculate_production_speed_multiplier();
		}
	}

	_cultist.assigned_building = noone;
	_cultist.is_assigned_to_building = false;
};

// Find the first worker building under a world-space point.
find_worker_building_at_position = function(_world_x, _world_y)
{
	if (instance_exists(o_cannon))
	{
		var _cannon = instance_find(o_cannon, 0);

		if (instance_exists(_cannon)
			&& variable_instance_exists(_cannon, "building_accepts_workers")
			&& _cannon.building_accepts_workers
			&& variable_instance_exists(_cannon, "worker_cultists")
			&& array_length(_cannon.worker_cultists) < _cannon.worker_max
			&& _world_x >= _cannon.bbox_left
			&& _world_x <= _cannon.bbox_right
			&& _world_y >= _cannon.bbox_top
			&& _world_y <= _cannon.bbox_bottom)
		{
			return _cannon;
		}
	}

	var _building_count = instance_number(o_v13buildings_parent);

	for (var _building_index = 0; _building_index < _building_count; ++_building_index)
	{
		var _building = instance_find(o_v13buildings_parent, _building_index);

		if (instance_exists(_building)
			&& variable_instance_exists(_building, "building_accepts_workers")
			&& _building.building_accepts_workers
			&& variable_instance_exists(_building, "worker_cultists")
			&& array_length(_building.worker_cultists) < _building.worker_max
			&& _world_x >= _building.bbox_left
			&& _world_x <= _building.bbox_right
			&& _world_y >= _building.bbox_top
			&& _world_y <= _building.bbox_bottom)
		{
			return _building;
		}
	}

	return noone;
};

// Find the topmost empty building slot under a world-space point.
find_building_slot_at_position = function(_world_x, _world_y)
{
	var _slot_count = instance_number(o_building_slot);
	var _target_slot = noone;
	var _target_depth = infinity;

	for (var _slot_index = 0; _slot_index < _slot_count; ++_slot_index)
	{
		var _slot = instance_find(o_building_slot, _slot_index);

		if (instance_exists(_slot)
			&& (!variable_instance_exists(_slot, "construction_event_pending")
				|| !_slot.construction_event_pending)
			&& _world_x >= _slot.bbox_left
			&& _world_x <= _slot.bbox_right
			&& _world_y >= _slot.bbox_top
			&& _world_y <= _slot.bbox_bottom
			&& _slot.depth < _target_depth)
		{
			_target_slot = _slot;
			_target_depth = _slot.depth;
		}
	}

	return _target_slot;
};

drag_cultist_can_be_picked = function(_cultist)
{
	if (!instance_exists(_cultist))
	{
		return false;
	}

	// Archdemons can be repositioned in combat, but are not assigned to buildings by dragging during the day.
	if (_cultist.object_index == o_archdemon && global.day_phase != DAY_PHASE.NIGHT)
	{
		return false;
	}

	var _is_knocked_out = variable_instance_exists(_cultist, "is_knocked_out")
		&& _cultist.is_knocked_out;
	var _has_usable_hp = !variable_instance_exists(_cultist, "hp")
		|| _cultist.hp > 0
		|| _is_knocked_out;

	if (!_has_usable_hp)
	{
		return false;
	}

	if (variable_instance_exists(_cultist, "cannon_loading") && _cultist.cannon_loading)
	{
		return false;
	}

	if (variable_instance_exists(_cultist, "cannon_loaded") && _cultist.cannon_loaded)
	{
		return false;
	}

	return true;
};

worker_whip_target_is_valid = function(_unit)
{
	if (!instance_exists(_unit)
		|| (_unit.object_index != o_archdemon && _unit.object_index != o_goblin)
		|| !variable_instance_exists(_unit, "hp")
		|| !variable_instance_exists(_unit, "max_hp")
		|| _unit.hp <= 0)
	{
		return false;
	}

	if (variable_instance_exists(_unit, "is_being_dragged") && _unit.is_being_dragged)
	{
		return false;
	}

	if (variable_instance_exists(_unit, "cannon_loading") && _unit.cannon_loading)
	{
		return false;
	}

	if (variable_instance_exists(_unit, "cannon_loaded") && _unit.cannon_loaded)
	{
		return false;
	}

	return true;
};

worker_whip_target_can_be_hit = function(_unit)
{
	if (!worker_whip_target_is_valid(_unit) || global.day_phase != DAY_PHASE.DAY)
	{
		return false;
	}

	var _damage_multiplier = 1;

	if (_unit.object_index == o_goblin)
	{
		_damage_multiplier = BALANCE_WORKER_WHIP_GOBLIN_DAMAGE_MULTIPLIER;
	}

	var _damage_amount = _unit.max_hp * BALANCE_WORKER_WHIP_MAX_HP_DAMAGE_SHARE * _damage_multiplier;
	return _unit.hp > _damage_amount;
};

find_worker_whip_target_at_position = function(_world_x, _world_y)
{
	var _target_unit = noone;
	var _target_depth = infinity;
	var _cultist_count = array_length(global.archdemons);

	for (var _cultist_index = 0; _cultist_index < _cultist_count; ++_cultist_index)
	{
		var _cultist = global.archdemons[_cultist_index];

		if (worker_whip_target_can_be_hit(_cultist)
			&& _world_x >= _cultist.bbox_left
			&& _world_x <= _cultist.bbox_right
			&& _world_y >= _cultist.bbox_top
			&& _world_y <= _cultist.bbox_bottom
			&& _cultist.depth < _target_depth)
		{
			_target_unit = _cultist;
			_target_depth = _cultist.depth;
		}
	}

	var _goblin_count = instance_number(o_goblin);

	for (var _goblin_index = 0; _goblin_index < _goblin_count; ++_goblin_index)
	{
		var _goblin = instance_find(o_goblin, _goblin_index);

		if (worker_whip_target_can_be_hit(_goblin)
			&& _world_x >= _goblin.bbox_left
			&& _world_x <= _goblin.bbox_right
			&& _world_y >= _goblin.bbox_top
			&& _world_y <= _goblin.bbox_bottom
			&& _goblin.depth < _target_depth)
		{
			_target_unit = _goblin;
			_target_depth = _goblin.depth;
		}
	}

	return _target_unit;
};

worker_whip_apply = function(_unit)
{
	if (!worker_whip_target_can_be_hit(_unit))
	{
		return false;
	}

	var _whip_duration_frames = max(1, BALANCE_WORKER_WHIP_DURATION * room_speed);
	var _whip_gain_frames = max(1, BALANCE_WORKER_WHIP_HIT_DURATION_GAIN * room_speed);
	var _damage_multiplier = 1;

	if (_unit.object_index == o_goblin)
	{
		_damage_multiplier = BALANCE_WORKER_WHIP_GOBLIN_DAMAGE_MULTIPLIER;
	}

	var _damage_amount = _unit.max_hp * BALANCE_WORKER_WHIP_MAX_HP_DAMAGE_SHARE * _damage_multiplier;
	var _whip_was_inactive = _unit.whip_timer <= 0;

	_unit.hp -= _damage_amount;
	_unit.whip_duration = _whip_duration_frames;

	// Each hit adds a chunk of boost time up to the shared maximum duration.
	_unit.whip_timer = min(_unit.whip_timer + _whip_gain_frames, _unit.whip_duration);

	_unit.whip_work_multiplier = BALANCE_WORKER_WHIP_SPEED_MULTIPLIER;

	var _damage_popup = instance_create_layer(_unit.x, _unit.y, "Instances", o_damage_popup);
	_damage_popup.popup_text = string(ceil(_damage_amount));
	_damage_popup.popup_color = COLOR_DAMAGE_FRIENDLY;
	_damage_popup.is_critical = false;

	if (_whip_was_inactive)
	{
		var _productivity_popup_offset_y = 200; // Keeps productivity feedback below modal/HUD elements.
		var _productivity_popup = instance_create_layer(_unit.x, _unit.bbox_top - 12 + _productivity_popup_offset_y, "Instances", o_damage_popup);
		_productivity_popup.popup_text = "PRODUCTIVITY x" + string(BALANCE_WORKER_WHIP_SPEED_MULTIPLIER) + "!";
		_productivity_popup.popup_color = COLOR_CULTIST_FERVOR;
		_productivity_popup.is_critical = false;
	}

	blood_particles_create(_unit.x, _unit.y);
	global.sound_play_random(global.whip_sounds);

	if (instance_exists(_unit.assigned_building)
		&& variable_instance_exists(_unit.assigned_building, "recalculate_production_speed_multiplier"))
	{
		_unit.assigned_building.recalculate_production_speed_multiplier();
	}

	return true;
};

worker_whip_unit_update = function(_unit)
{
	if (!instance_exists(_unit) || !variable_instance_exists(_unit, "whip_timer"))
	{
		return;
	}

	if (_unit.whip_timer <= 0)
	{
		return;
	}

	_unit.whip_timer--;

	if (_unit.whip_timer <= 0)
	{
		_unit.whip_work_multiplier = 1;

		if (instance_exists(_unit.assigned_building)
			&& variable_instance_exists(_unit.assigned_building, "recalculate_production_speed_multiplier"))
		{
			_unit.assigned_building.recalculate_production_speed_multiplier();
		}
	}
};

worker_whip_effects_update = function()
{
	var _cultist_count = array_length(global.archdemons);

	for (var _cultist_index = 0; _cultist_index < _cultist_count; ++_cultist_index)
	{
		worker_whip_unit_update(global.archdemons[_cultist_index]);
	}

	var _goblin_count = instance_number(o_goblin);

	for (var _goblin_index = 0; _goblin_index < _goblin_count; ++_goblin_index)
	{
		worker_whip_unit_update(instance_find(o_goblin, _goblin_index));
	}
};

find_building_events_at_position = function(_world_x, _world_y)
{
	var _building_count = instance_number(o_v13buildings_parent);
	var _target_building = noone;
	var _target_depth = infinity;

	for (var _building_index = 0; _building_index < _building_count; ++_building_index)
	{
		var _building = instance_find(o_v13buildings_parent, _building_index);

		if (instance_exists(_building)
			&& _world_x >= _building.bbox_left
			&& _world_x <= _building.bbox_right
			&& _world_y >= _building.bbox_top
			&& _world_y <= _building.bbox_bottom
			&& _building.depth < _target_depth)
		{
			_target_building = _building;
			_target_depth = _building.depth;
		}
	}

	return _target_building;
};

find_demolishable_building_at_position = function(_world_x, _world_y)
{
	var _building_count = instance_number(o_v13buildings_parent);
	var _target_building = noone;
	var _target_depth = infinity;

	for (var _building_index = 0; _building_index < _building_count; ++_building_index)
	{
		var _building = instance_find(o_v13buildings_parent, _building_index);

		if (instance_exists(_building)
			&& variable_instance_exists(_building, "building_demolish")
			&& _world_x >= _building.bbox_left
			&& _world_x <= _building.bbox_right
			&& _world_y >= _building.bbox_top
			&& _world_y <= _building.bbox_bottom
			&& _building.depth < _target_depth)
		{
			_target_building = _building;
			_target_depth = _building.depth;
		}
	}

	return _target_building;
};

find_foundry_at_position = function(_world_x, _world_y)
{
	var _foundry_count = instance_number(o_foundry);
	var _target_foundry = noone;
	var _target_depth = infinity;

	for (var _foundry_index = 0; _foundry_index < _foundry_count; ++_foundry_index)
	{
		var _foundry = instance_find(o_foundry, _foundry_index);

		if (instance_exists(_foundry)
			&& _world_x >= _foundry.bbox_left
			&& _world_x <= _foundry.bbox_right
			&& _world_y >= _foundry.bbox_top
			&& _world_y <= _foundry.bbox_bottom
			&& _foundry.depth < _target_depth)
		{
			_target_foundry = _foundry;
			_target_depth = _foundry.depth;
		}
	}

	return _target_foundry;
};

ground_cell_has_full_corruption_at_position = function(_world_x, _world_y)
{
	if (!instance_exists(o_corruption_grid))
	{
		return false;
	}

	var _corruption_grid_object = instance_find(o_corruption_grid, 0);
	var _cell_x = floor(_world_x / _corruption_grid_object.cell_size);
	var _cell_y = floor(_world_y / _corruption_grid_object.cell_size);
	var _is_inside_grid = _cell_x >= 0
		&& _cell_x < _corruption_grid_object.grid_width
		&& _cell_y >= 0
		&& _cell_y < _corruption_grid_object.grid_height;

	if (!_is_inside_grid)
	{
		return false;
	}

	if (variable_instance_exists(_corruption_grid_object, "saint_grid")
		&& ds_grid_get(_corruption_grid_object.saint_grid, _cell_x, _cell_y) > 0)
	{
		return false;
	}

	return ds_grid_get(_corruption_grid_object.corruption_grid, _cell_x, _cell_y)
		>= _corruption_grid_object.full_corruption_value;
};

ground_cell_is_tainted_at_position = function(_world_x, _world_y)
{
	if (!instance_exists(o_corruption_grid))
	{
		return false;
	}

	var _corruption_grid_object = instance_find(o_corruption_grid, 0);
	var _cell_x = floor(_world_x / _corruption_grid_object.cell_size);
	var _cell_y = floor(_world_y / _corruption_grid_object.cell_size);
	var _is_inside_grid = _cell_x >= 0
		&& _cell_x < _corruption_grid_object.grid_width
		&& _cell_y >= 0
		&& _cell_y < _corruption_grid_object.grid_height;

	if (!_is_inside_grid)
	{
		return false;
	}

	if (variable_instance_exists(_corruption_grid_object, "saint_grid")
		&& ds_grid_get(_corruption_grid_object.saint_grid, _cell_x, _cell_y) > 0)
	{
		return false;
	}

	return ds_grid_get(_corruption_grid_object.corruption_grid, _cell_x, _cell_y) > 0;
};

grave_spire_morning_skeleton_count_preview = function(_world_x, _world_y)
{
	var _skeleton_count = BALANCE_GRAVE_SPIRE_BASE_SKELETON_COUNT;
	var _grave_count = instance_number(o_grave);

	for (var _grave_index = 0; _grave_index < _grave_count; ++_grave_index)
	{
		var _grave = instance_find(o_grave, _grave_index);

		if (!instance_exists(_grave)
			|| point_distance(_world_x, _world_y, _grave.x, _grave.y) > BALANCE_GRAVE_SPIRE_RADIUS)
		{
			continue;
		}

		if (!variable_instance_exists(_grave, "assigned_grave_spire")
			|| !instance_exists(_grave.assigned_grave_spire))
		{
			_skeleton_count += BALANCE_GRAVE_SPIRE_SKELETONS_PER_GRAVE;
		}
	}

	return _skeleton_count;
};

ihor_extractor_morning_income_preview = function(_world_x, _world_y)
{
	var _morning_income = 0;
	var _vein_count = instance_number(o_ihor_vein);

	for (var _vein_index = 0; _vein_index < _vein_count; ++_vein_index)
	{
		var _vein = instance_find(o_ihor_vein, _vein_index);

		if (!instance_exists(_vein)
			|| !variable_instance_exists(_vein, "ihor_remaining")
			|| point_distance(_world_x, _world_y, _vein.x, _vein.y) > BALANCE_IHOR_EXTRACTOR_RADIUS)
		{
			continue;
		}

		if (!variable_instance_exists(_vein, "assigned_ihor_extractor")
			|| !instance_exists(_vein.assigned_ihor_extractor))
		{
			_morning_income += (_vein.ihor_remaining > 0)
				? BALANCE_IHOR_EXTRACTOR_FULL_VEIN_MORNING_IHOR
				: BALANCE_IHOR_EXTRACTOR_EMPTY_VEIN_MORNING_IHOR;
		}
	}

	return _morning_income;
};

open_building_window = function(_slot)
{
	if (!instance_exists(_slot))
	{
		return false;
	}

	building_window_slot = _slot;
	building_window_foundry = noone;
	building_window_choices = building_choices;
	building_window_input_blocked = true;
	player_pause_active = false;
	global.pause = true;
	global.focus_window = FOCUS_WINDOW.BUILDING_CONSTRUCTION;
	global.ui_confirm_sound_play();
	ui_click_sound_blocked = true;

	return true;
};

open_foundry_window = function(_foundry)
{
	if (!instance_exists(_foundry)
		|| _foundry.object_index != o_foundry)
	{
		return false;
	}

	building_window_slot = noone;
	building_window_foundry = _foundry;
	building_window_choices = foundry_shell_choices;
	building_window_input_blocked = true;
	player_pause_active = false;
	global.pause = true;
	global.focus_window = FOCUS_WINDOW.BUILDING_CONSTRUCTION;
	global.ui_confirm_sound_play();
	ui_click_sound_blocked = true;

	return true;
};

building_display_name_get = function(_building)
{
	if (!instance_exists(_building))
	{
		return "";
	}

	for (var _choice_index = 0; _choice_index < array_length(building_choices); ++_choice_index)
	{
		var _choice = building_choices[_choice_index];

		if (_choice.building_object == _building.object_index)
		{
			return _choice.building_name;
		}
	}

	if (_building.object_index == o_foundry)
	{
		return "Foundry";
	}

	return string_replace_all(object_get_name(_building.object_index), "_", " ");
};

open_building_events_window = function(_building)
{
	if (!instance_exists(_building))
	{
		return false;
	}

	building_events_window_building = _building;
	building_events_window_entries = day_event_building_catalog_get(_building.object_index);
	building_events_window_name = building_display_name_get(_building);
	building_events_scroll_row = 0;
	building_events_previous_pause_state = global.pause;
	building_events_input_blocked = true;
	global.pause = true;
	global.focus_window = FOCUS_WINDOW.BUILDING_EVENTS;
	global.ui_confirm_sound_play();
	ui_click_sound_blocked = true;

	return true;
};

close_building_window = function()
{
	building_window_slot = noone;
	building_window_foundry = noone;
	building_window_choices = building_choices;
	global.pause = false;
	global.focus_window = FOCUS_WINDOW.NOONE;
};

close_building_events_window = function()
{
	building_events_window_building = noone;
	building_events_window_entries = [];
	building_events_window_name = "";
	building_events_scroll_row = 0;
	building_events_input_blocked = false;
	global.pause = building_events_previous_pause_state;
	player_pause_active = building_events_previous_pause_state;
	global.focus_window = FOCUS_WINDOW.NOONE;
};

settlement_expansion_is_purchased = function()
{
	if (!instance_exists(o_cannon))
	{
		return false;
	}

	var _cannon = instance_find(o_cannon, 0);

	return variable_instance_exists(_cannon, "building_upgrade_levels")
		&& array_length(_cannon.building_upgrade_levels) > CANNON_UPGRADE.SETTLEMENT_EXPANSION
		&& _cannon.building_upgrade_levels[CANNON_UPGRADE.SETTLEMENT_EXPANSION] > 0;
};

building_choice_uses_expansion_limit = function(_choice)
{
	return _choice.building_object == o_slaughter_table
		|| _choice.building_object == o_quarry
		|| _choice.building_object == o_souls_well
		|| _choice.building_object == o_shell_factory
		|| _choice.building_object == o_graveyard2
		|| _choice.building_object == o_pitlings_pit2;
};

building_choice_limit_get = function(_choice)
{
	if (instance_exists(building_window_foundry))
	{
		return 999;
	}

	if (_choice.building_object == o_goblins_pit)
	{
		if (settlement_expansion_is_purchased())
		{
			return BALANCE_BUILDING_GOBLINS_PIT_LIMIT;
		}

		return BALANCE_BUILDING_GOBLINS_PIT_LIMIT_BEFORE_EXPANSION;
	}

	// One Foundry is placed in the starting settlement; allow another to be constructed.
	if (_choice.building_object == o_foundry)
	{
		return BALANCE_BUILDING_FOUNDRY_LIMIT;
	}

	if (building_choice_uses_expansion_limit(_choice)
		&& settlement_expansion_is_purchased())
	{
		return BALANCE_BUILDING_RESOURCE_LIMIT_AFTER_EXPANSION;
	}

	return BALANCE_BUILDING_DEFAULT_LIMIT;
};

building_choice_count_get = function(_choice)
{
	if (instance_exists(building_window_foundry))
	{
		return 0;
	}

	var _building_count = instance_number(_choice.building_object);

	// Reserved construction sites count toward the same building limit.
	for (var _event_index = 0; _event_index < array_length(global.day_events); ++_event_index)
	{
		var _event = global.day_events[_event_index];

		if (!is_struct(_event)
			|| !variable_struct_exists(_event, "actions")
			|| array_length(_event.actions) <= 0)
		{
			continue;
		}

		var _action = _event.actions[0];

		if (is_struct(_action)
			&& _action.action_type == "construct_building"
			&& is_struct(_action.data)
			&& _action.data.building_object == _choice.building_object)
		{
			_building_count++;
		}
	}

	return _building_count;
};

building_choice_can_construct = function(_choice)
{
	return building_choice_count_get(_choice) < building_choice_limit_get(_choice);
};

resource_name_get = function(_resource)
{
	if (_resource == RESOURCES.FLESH)
	{
		return "Flesh";
	}

	if (_resource == RESOURCES.SOULS)
	{
		return "Souls";
	}

	if (_resource == RESOURCES.IRON)
	{
		return "Iron";
	}

	if (_resource == RESOURCES.IHOR)
	{
		return "Ihor";
	}

	return "";
};

resource_icon_get = function(_resource)
{
	if (_resource == RESOURCES.FLESH)
	{
		return s_flesh_icon;
	}

	if (_resource == RESOURCES.SOULS)
	{
		return s_soul_icon;
	}

	if (_resource == RESOURCES.IRON)
	{
		return s_iron_icon;
	}

	if (_resource == RESOURCES.IHOR)
	{
		return s_ihor_icon;
	}

	return noone;
};

resource_color_get = function(_resource)
{
	if (_resource == RESOURCES.FLESH)
	{
		return COLOR_HUD_FLESH;
	}

	if (_resource == RESOURCES.SOULS)
	{
		return COLOR_HUD_SOULS;
	}

	if (_resource == RESOURCES.IRON)
	{
		return COLOR_HUD_IRON;
	}

	if (_resource == RESOURCES.IHOR)
	{
		return COLOR_HUD_IHOR;
	}

	return c_white;
};

building_resource_summary_draw = function(_center_x, _y)
{
	if (!variable_global_exists("resources"))
	{
		return;
	}

	// Draw current resources inside modal windows where the regular HUD is hidden.
	var _resource_order = [RESOURCES.FLESH, RESOURCES.SOULS, RESOURCES.IRON, RESOURCES.IHOR];
	var _resource_count = array_length(_resource_order);
	var _icon_size = 22;
	var _icon_text_gap = 6;
	var _item_gap = 28;
	var _item_widths = array_create(_resource_count, 0);
	var _total_width = 0;

	for (var _resource_index = 0; _resource_index < _resource_count; ++_resource_index)
	{
		var _resource = _resource_order[_resource_index];
		var _resource_value_text = string(global.resources[_resource]);

		if (_resource != RESOURCES.IHOR)
		{
			_resource_value_text += "/" + string(resource_max_get(_resource));
		}

		var _item_width = _icon_size + _icon_text_gap + string_width(_resource_value_text);

		_item_widths[_resource_index] = _item_width;
		_total_width += _item_width;

		if (_resource_index < _resource_count - 1)
		{
			_total_width += _item_gap;
		}
	}

	var _draw_x = _center_x - (_total_width * 0.5);

	draw_set_halign(fa_left);
	draw_set_valign(fa_middle);
	draw_set_alpha(1);

	for (var _resource_index = 0; _resource_index < _resource_count; ++_resource_index)
	{
		var _resource = _resource_order[_resource_index];
		var _resource_icon = resource_icon_get(_resource);
		var _resource_color = resource_color_get(_resource);
		var _resource_value_text = string(global.resources[_resource]);

		if (_resource != RESOURCES.IHOR)
		{
			_resource_value_text += "/" + string(resource_max_get(_resource));
		}

		var _icon_y = _y - (_icon_size * 0.5);

		if (_resource_icon != noone && sprite_exists(_resource_icon))
		{
			draw_sprite_stretched_ext(_resource_icon, 0, _draw_x, _icon_y, _icon_size, _icon_size, c_white, 1);
		}
		else
		{
			draw_set_color(_resource_color);
			draw_circle(_draw_x + (_icon_size * 0.5), _y, _icon_size * 0.35, false);
		}

		draw_set_color(COLOR_HUD_TEXT);
		draw_text(_draw_x + _icon_size + _icon_text_gap, _y, _resource_value_text);

		_draw_x += _item_widths[_resource_index] + _item_gap;
	}
};

building_choice_costs_get = function(_choice)
{
	var _cost_multiplier = 1;

	// Duplicate base buildings cost more, while Foundry shell choices keep their own prices.
	if (!instance_exists(building_window_foundry)
		&& building_choice_count_get(_choice) > 0)
	{
		_cost_multiplier = 2;
	}

	var _costs = [];

	if (variable_struct_exists(_choice, "construction_costs"))
	{
		var _construction_cost_count = array_length(_choice.construction_costs);

		for (var _cost_index = 0; _cost_index < _construction_cost_count; ++_cost_index)
		{
			var _cost_data = _choice.construction_costs[_cost_index];

			array_push(
				_costs,
				{
					resource: _cost_data.resource,
					cost: _cost_data.cost * _cost_multiplier
				}
			);
		}

		return _costs;
	}

	return [
		{
			resource: RESOURCES.IRON,
			cost: _choice.iron_cost * _cost_multiplier
		}
	];
};

building_costs_text_get = function(_costs)
{
	var _cost_count = array_length(_costs);
	var _cost_text = "";

	for (var _cost_index = 0; _cost_index < _cost_count; ++_cost_index)
	{
		var _cost_data = _costs[_cost_index];

		if (_cost_index > 0)
		{
			_cost_text += " + ";
		}

		_cost_text += string(_cost_data.cost) + " " + resource_name_get(_cost_data.resource);
	}

	return _cost_text;
};

building_choice_cost_text_get = function(_choice)
{
	var _costs = building_choice_costs_get(_choice);

	return building_costs_text_get(_costs);
};

building_costs_can_pay = function(_costs)
{
	var _cost_count = array_length(_costs);

	for (var _cost_index = 0; _cost_index < _cost_count; ++_cost_index)
	{
		var _cost_data = _costs[_cost_index];

		if (global.resources[_cost_data.resource] < _cost_data.cost)
		{
			return false;
		}
	}

	return true;
};

building_choice_can_pay = function(_choice)
{
	var _costs = building_choice_costs_get(_choice);

	return building_costs_can_pay(_costs);
};

building_choice_requirement_text_get = function(_choice)
{
	var _limit_count = building_choice_count_get(_choice);
	var _limit_max = building_choice_limit_get(_choice);

	if (_limit_count < _limit_max || instance_exists(building_window_foundry))
	{
		return "";
	}

	if (_choice.building_object == o_goblins_pit
		&& _limit_max < BALANCE_BUILDING_GOBLINS_PIT_LIMIT)
	{
		return "Limit reached.\nBuy Settlement Expansion";
	}

	if (building_choice_uses_expansion_limit(_choice)
		&& _limit_max < BALANCE_BUILDING_RESOURCE_LIMIT_AFTER_EXPANSION)
	{
		return "Limit reached.\nBuy Settlement Expansion";
	}

	return "";
};

building_upgrade_costs_get = function(_building, _upgrade_index)
{
	if (!instance_exists(_building))
	{
		return [];
	}

	if (_building.object_index == o_shell_factory
		&& variable_instance_exists(_building, "shell_factory_upgrade_iron_cost_get")
		&& variable_instance_exists(_building, "shell_factory_upgrade_flesh_cost_get"))
	{
		return [
			{
				resource: RESOURCES.IRON,
				cost: _building.shell_factory_upgrade_iron_cost_get(_upgrade_index)
			},
			{
				resource: RESOURCES.FLESH,
				cost: _building.shell_factory_upgrade_flesh_cost_get(_upgrade_index)
			}
		];
	}

	if (variable_instance_exists(_building, "cannon_upgrade_costs_get"))
	{
		return _building.cannon_upgrade_costs_get(_upgrade_index);
	}

	if (variable_instance_exists(_building, "building_upgrade_levels"))
	{
		return [
			{
				resource: _building.cannon_upgrade_resource_get(_upgrade_index),
				cost: _building.cannon_upgrade_next_cost_get(_upgrade_index)
			}
		];
	}

	if (variable_instance_exists(_building, "building_upgrade_costs")
		&& _upgrade_index >= 0
		&& _upgrade_index < array_length(_building.building_upgrade_costs))
	{
		var _upgrade_resource = RESOURCES.IRON;

		if (variable_instance_exists(_building, "building_upgrade_resources")
			&& _upgrade_index < array_length(_building.building_upgrade_resources))
		{
			_upgrade_resource = _building.building_upgrade_resources[_upgrade_index];
		}

		return [
			{
				resource: _upgrade_resource,
				cost: _building.building_upgrade_costs[_upgrade_index]
			}
		];
	}

	return [];
};

building_choice_costs_pay = function(_choice, _popup_x, _popup_y)
{
	building_costs_pay(building_choice_costs_get(_choice), _popup_x, _popup_y);
};

building_costs_pay = function(_costs, _popup_x, _popup_y)
{
	var _cost_count = array_length(_costs);
	var _popup_gap = 46;
	var _popup_start_x = _popup_x - ((_cost_count - 1) * _popup_gap * 0.5);

	for (var _cost_index = 0; _cost_index < _cost_count; ++_cost_index)
	{
		var _cost_data = _costs[_cost_index];
		var _resource = _cost_data.resource;
		var _cost = _cost_data.cost;
		var _cost_popup_x = _popup_start_x + (_cost_index * _popup_gap);

		global.resources[_resource] -= _cost;
		resource_popup_create(_cost_popup_x, _popup_y, _resource, -_cost);
	}
};

starting_goblins_bind_to_first_pit = function(_goblins_pit)
{
	if (starting_goblins_bound_to_first_pit || !instance_exists(_goblins_pit))
	{
		return;
	}

	var _bound_count = 0;
	var _target_count = min(2, starting_goblin_count);
	var _goblin_count = instance_number(o_goblin);

	for (var _goblin_index = 0; _goblin_index < _goblin_count; ++_goblin_index)
	{
		if (_bound_count >= _target_count)
		{
			break;
		}

		var _goblin = instance_find(o_goblin, _goblin_index);

		if (!instance_exists(_goblin)
			|| !variable_instance_exists(_goblin, "owner_goblins_pit")
			|| instance_exists(_goblin.owner_goblins_pit)
			|| (variable_instance_exists(_goblin, "hp") && _goblin.hp <= 0))
		{
			continue;
		}

		_goblin.owner_goblins_pit = _goblins_pit;
		_goblin.home_offset_x = _goblin.x - _goblins_pit.x;
		_goblin.home_offset_y = _goblin.y - _goblins_pit.y;
		_bound_count++;
	}

	starting_goblins_bound_to_first_pit = true;
};

construct_building_from_choice = function(_choice)
{
	if (instance_exists(building_window_foundry))
	{
		if (variable_instance_exists(building_window_foundry, "foundry_shell_cancel")
			&& is_struct(building_window_foundry.foundry_selected_shell))
		{
			building_window_foundry.foundry_shell_cancel(true);
		}

		if (!building_choice_can_pay(_choice))
		{
			return false;
		}

		if (variable_instance_exists(building_window_foundry, "foundry_shell_select"))
		{
			building_choice_costs_pay(_choice, building_window_foundry.x, building_window_foundry.y - 40);
			building_window_foundry.foundry_shell_select(_choice);
			close_building_window();
			return true;
		}

		close_building_window();
		return false;
	}

	if (!instance_exists(building_window_slot))
	{
		close_building_window();
		return false;
	}

	if (!day_event_building_construction_can_start()
		|| !building_choice_can_construct(_choice))
	{
		return false;
	}

	var _slot = building_window_slot;
	close_building_window();

	var _construction_event = day_event_building_construction_create(_slot, _choice, false);

	if (!is_struct(_construction_event))
	{
		return false;
	}

	if (instance_exists(o_jobs_ui))
	{
		var _jobs_ui = instance_find(o_jobs_ui, 0);
		_jobs_ui.jobs_window_open();
	}

	return true;
};

// Assign a valid worker unit to a building and snap it beside the building.
assign_cultist_to_worker_building = function(_cultist, _building)
{
	if (!instance_exists(_cultist)
		|| !instance_exists(_building)
		|| (_cultist.object_index != o_archdemon && !variable_instance_exists(_cultist, "worker_speed_multiplier"))
		|| (variable_instance_exists(_cultist, "hp") && _cultist.hp <= 0))
	{
		return false;
	}

	clear_cultist_building_assignment(_cultist);

	if (day_worker_is_out_of_stamina(_cultist)
		&& _building.object_index != o_ritual_circle
		&& _building.object_index != o_meat_bath)
	{
		if (variable_instance_exists(_building, "building_warning_show"))
		{
			_building.building_warning_show("NO STAMINA", COLOR_STATUS_NEGATIVE_RED);
		}

		return false;
	}

	if (_cultist.object_index == o_goblin && global.day_phase == DAY_PHASE.NIGHT)
	{
		return false;
	}

	if (_cultist.object_index == o_goblin && _building.object_index == o_ritual_circle)
	{
		return false;
	}

	if (!variable_instance_exists(_building, "building_accepts_workers")
		|| !_building.building_accepts_workers
		|| !variable_instance_exists(_building, "worker_cultists")
		|| array_length(_building.worker_cultists) >= _building.worker_max)
	{
		return false;
	}

	array_push(_building.worker_cultists, _cultist);
	_cultist.assigned_building = _building;
	_cultist.is_assigned_to_building = true;
	worker_assignment_hint_completed = true;
	first_day_timer_waiting_for_worker_assignment = false;

	if (variable_instance_exists(_cultist, "target_instance"))
	{
		_cultist.target_instance = noone;
		_cultist.alert_target = noone;
		_cultist.forced_attack_target = noone;
		_cultist.rally_is_active = false;
		_cultist.rally_is_returning = false;
		_cultist.rally_has_arrived = false;
	}

	arrange_resource_building_workers(_building);

	if (variable_instance_exists(_building, "recalculate_production_speed_multiplier"))
	{
		_building.recalculate_production_speed_multiplier();
	}

	return true;
};

demon_manual_structure_target_assign_near_drop = function(_unit)
{
	if (!instance_exists(_unit)
		|| !variable_instance_exists(_unit, "demon_type")
		|| _unit.demon_type == DEMON_TYPE.NONE
		|| !variable_instance_exists(_unit, "find_nearest_enemy_object_from_point")
		|| !variable_instance_exists(_unit, "manual_structure_target"))
	{
		return;
	}

	_unit.manual_structure_target = noone;

	var _structure_target = _unit.find_nearest_enemy_object_from_point(
		_unit.x,
		_unit.y,
		BALANCE_DEMON_DROP_STRUCTURE_PRIORITY_RADIUS
	);

	if (instance_exists(_structure_target))
	{
		_unit.manual_structure_target = _structure_target;
		_unit.target_instance = _structure_target;
		_unit.target_search_update_timer = 0;
	}
};

worker_idle_wander_target_pick = function(_worker)
{
	if (!instance_exists(_worker) || !instance_exists(o_cannon))
	{
		return;
	}

	var _cannon = instance_find(o_cannon, 0);
	var _wander_direction = random_range(
		BALANCE_IDLE_WORKER_WANDER_DIRECTION_MIN,
		BALANCE_IDLE_WORKER_WANDER_DIRECTION_MAX
	);
	var _wander_distance = random(BALANCE_IDLE_WORKER_WANDER_RADIUS);

	_worker.idle_wander_target_x = _cannon.x + lengthdir_x(_wander_distance, _wander_direction);
	_worker.idle_wander_target_y = _cannon.y + BALANCE_DAY_CANNON_REGROUP_OFFSET_Y + lengthdir_y(_wander_distance, _wander_direction);
	_worker.idle_wander_wait_timer = irandom_range(
		round(BALANCE_IDLE_WORKER_WANDER_WAIT_MIN * room_speed),
		round(BALANCE_IDLE_WORKER_WANDER_WAIT_MAX * room_speed)
	);
};

worker_idle_wander_can_update = function(_worker, _allow_cannon_assignment = false)
{
	if (!instance_exists(_worker)
		|| global.day_phase != DAY_PHASE.DAY
		|| (_worker.object_index != o_archdemon && _worker.object_index != o_goblin)
		|| !variable_instance_exists(_worker, "hp")
		|| _worker.hp <= 0)
	{
		return false;
	}

	var _is_assigned_to_building = variable_instance_exists(_worker, "is_assigned_to_building")
		&& _worker.is_assigned_to_building;
	var _can_wander_while_assigned_to_cannon = _allow_cannon_assignment
		&& _is_assigned_to_building
		&& variable_instance_exists(_worker, "assigned_building")
		&& instance_exists(_worker.assigned_building)
		&& _worker.assigned_building.object_index == o_cannon;

	if ((variable_instance_exists(_worker, "is_being_dragged") && _worker.is_being_dragged)
		|| (_is_assigned_to_building && !_can_wander_while_assigned_to_cannon)
		|| (variable_instance_exists(_worker, "cannon_loading") && _worker.cannon_loading)
		|| (variable_instance_exists(_worker, "cannon_loaded") && _worker.cannon_loaded))
	{
		return false;
	}

	return instance_exists(o_cannon);
};

worker_idle_wander_update = function(_worker, _allow_cannon_assignment = false)
{
	if (!worker_idle_wander_can_update(_worker, _allow_cannon_assignment))
	{
		return false;
	}

	if (!variable_instance_exists(_worker, "idle_wander_target_x")
		|| !variable_instance_exists(_worker, "idle_wander_target_y")
		|| !variable_instance_exists(_worker, "idle_wander_wait_timer"))
	{
		worker_idle_wander_target_pick(_worker);
	}

	var _cannon = instance_find(o_cannon, 0);

	if (variable_instance_exists(_cannon, "cannon_worker_is_behind_sprite")
		&& _cannon.cannon_worker_is_behind_sprite(_worker)
		&& _worker.idle_wander_target_y < _cannon.y + BALANCE_DAY_CANNON_REGROUP_OFFSET_Y)
	{
		worker_idle_wander_target_pick(_worker);
		_worker.idle_wander_wait_timer = 0;
	}

	var _distance = point_distance(_worker.x, _worker.y, _worker.idle_wander_target_x, _worker.idle_wander_target_y);

	if (_distance <= BALANCE_IDLE_WORKER_WANDER_REACH_DISTANCE)
	{
		if (variable_instance_exists(_worker, "is_walking"))
		{
			_worker.is_walking = false;
		}

		_worker.idle_wander_wait_timer--;

		if (_worker.idle_wander_wait_timer <= 0)
		{
			worker_idle_wander_target_pick(_worker);
		}

		return true;
	}

	var _move_speed = BALANCE_GOBLIN_MOVE_SPEED;

	if (variable_instance_exists(_worker, "move_speed"))
	{
		_move_speed = _worker.move_speed;
	}

	if (variable_instance_exists(_worker, "whip_timer")
		&& _worker.whip_timer > 0
		&& variable_instance_exists(_worker, "whip_work_multiplier"))
	{
		_move_speed *= _worker.whip_work_multiplier;
	}

	_move_speed *= BALANCE_IDLE_WORKER_WANDER_SPEED_MULTIPLIER;

	var _move_distance = min(_move_speed, _distance);
	var _move_direction = point_direction(_worker.x, _worker.y, _worker.idle_wander_target_x, _worker.idle_wander_target_y);

	_worker.x += lengthdir_x(_move_distance, _move_direction);
	_worker.y += lengthdir_y(_move_distance, _move_direction);
	_worker.drag_drop_x = _worker.x;
	_worker.drag_drop_y = _worker.y;

	if (variable_instance_exists(_worker, "is_walking"))
	{
		_worker.is_walking = true;
	}

	if (variable_instance_exists(_worker, "face_world_x"))
	{
		_worker.face_world_x(_worker.idle_wander_target_x);
	}
	else
	{
		_worker.image_xscale = abs(_worker.image_xscale) * (_worker.idle_wander_target_x >= _worker.x ? 1 : -1);
	}

	return true;
};

day_worker_is_out_of_stamina = function(_worker)
{
	return instance_exists(_worker)
		&& variable_instance_exists(_worker, "stamina_amount")
		&& _worker.stamina_amount <= 0;
};

day_worker_stamina_spend = function(_worker, _drain_multiplier = 1)
{
	if (global.day_phase != DAY_PHASE.DAY
		|| !instance_exists(_worker)
		|| !variable_instance_exists(_worker, "stamina_amount"))
	{
		return false;
	}

	var _stamina_delta = -BALANCE_CULTIST_STAMINA_DRAIN_PER_SECOND
		* _drain_multiplier
		/ max(1, room_speed);

	var _stamina_max = BALANCE_CULTIST_STAMINA_MAX;

	if (variable_instance_exists(_worker, "stamina_max"))
	{
		_stamina_max = _worker.stamina_max;
	}

	var _stamina_before = _worker.stamina_amount;
	_worker.stamina_amount = clamp(_worker.stamina_amount + _stamina_delta, 0, _stamina_max);

	if (_stamina_before > 0
		&& _worker.stamina_amount <= 0
		&& variable_global_exists("tutorial_hint_trigger"))
	{
		global.tutorial_hint_trigger("stamina");
	}

	if (_stamina_before > 0 && _worker.stamina_amount <= 0)
	{
		clear_cultist_building_assignment(_worker);
		return true;
	}

	return false;
};

day_idle_cultists_wander_update = function()
{
	if (!variable_global_exists("archdemons"))
	{
		return;
	}

	var _cultist_count = array_length(global.archdemons);

	for (var _cultist_index = 0; _cultist_index < _cultist_count; ++_cultist_index)
	{
		worker_idle_wander_update(global.archdemons[_cultist_index]);
	}
};

cannon_satiety_add = function(_amount)
{
	global.cannon_satiety = max(0, global.cannon_satiety + _amount);
};

cannon_corpse_delivery_remaining_get = function()
{
	return max(0, BALANCE_CANNON_CORPSE_DAILY_DELIVERY_LIMIT - global.cannon_corpses_delivered_today);
};

cannon_corpse_delivery_limit_reached = function()
{
	return cannon_corpse_delivery_remaining_get() <= 0;
};

cannon_corpses_deliver = function(_corpse_count)
{
	var _accepted_corpse_count = min(max(0, _corpse_count), cannon_corpse_delivery_remaining_get());

	if (_accepted_corpse_count <= 0)
	{
		return 0;
	}

	global.cannon_corpses_delivered_today += _accepted_corpse_count;
	cannon_satiety_add(BALANCE_CANNON_SATIETY_PER_CORPSE * _accepted_corpse_count);

	return _accepted_corpse_count;
};

cannon_satiety_can_fire_feast = function()
{
	return global.cannon_satiety >= global.cannon_satiety_max;
};

cannon_satiety_spend_feast = function()
{
	if (!cannon_satiety_can_fire_feast())
	{
		return false;
	}

	global.cannon_satiety -= global.cannon_satiety_max;

	return true;
};

cannon_projectile_queue_add = function(_projectile_type, _payload = noone)
{
	if (array_length(global.cannon_projectile_queue) >= global.cannon_projectile_queue_max)
	{
		return false;
	}

	array_push(global.cannon_projectile_queue, _projectile_type);
	array_push(global.cannon_projectile_payload_queue, _payload);
	global.cannon_selected_projectile_index = clamp(global.cannon_selected_projectile_index, 0, array_length(global.cannon_projectile_queue) - 1);
	global.cannon_projectile_gain_timer = 0;

	return true;
};

cannon_feast_bonus_projectile_roll = function()
{
	var _bonus_projectile_count = array_length(global.cannon_feast_bonus_projectile_types);

	if (_bonus_projectile_count <= 0)
	{
		return noone;
	}

	return global.cannon_feast_bonus_projectile_types[irandom(_bonus_projectile_count - 1)];
};

cannon_worker_move_towards = function(_worker, _target_x, _target_y)
{
	if (!instance_exists(_worker))
	{
		return false;
	}

	var _distance = point_distance(_worker.x, _worker.y, _target_x, _target_y);

	if (_distance <= 0)
	{
		return true;
	}

	var _move_speed = BALANCE_CANNON_CORPSE_WORKER_MOVE_SPEED;

	if (variable_instance_exists(_worker, "move_speed"))
	{
		_move_speed = max(_move_speed, _worker.move_speed);
	}

	if (variable_instance_exists(_worker, "whip_timer") && _worker.whip_timer > 0)
	{
		_move_speed *= _worker.whip_work_multiplier;
	}

	if (variable_instance_exists(_worker, "stamina_amount") && _worker.stamina_amount <= 0)
	{
		_move_speed *= BALANCE_CULTIST_STAMINA_EMPTY_EFFICIENCY;
	}

	var _move_distance = min(_move_speed, _distance);
	var _move_direction = point_direction(_worker.x, _worker.y, _target_x, _target_y);

	_worker.x += lengthdir_x(_move_distance, _move_direction);
	_worker.y += lengthdir_y(_move_distance, _move_direction);
	_worker.drag_drop_x = _worker.x;
	_worker.drag_drop_y = _worker.y;
	_worker.is_walking = true;

	if (variable_instance_exists(_worker, "face_world_x"))
	{
		_worker.face_world_x(_target_x);
	}

	return _distance <= _move_speed;
};

cannon_corpse_worker_update = function(_worker, _cannon)
{
	if (!instance_exists(_worker) || !instance_exists(_cannon))
	{
		return false;
	}

	if (!variable_instance_exists(_worker, "hp") || _worker.hp <= 0)
	{
		cannon_corpse_worker_drop(_worker);
		return false;
	}

	if (!variable_instance_exists(_worker, "carried_corpse"))
	{
		_worker.carried_corpse = noone;
	}

	if (!variable_instance_exists(_worker, "carried_corpses"))
	{
		_worker.carried_corpses = [];
	}

	if (!variable_instance_exists(_worker, "corpse_carry_capacity"))
	{
		_worker.corpse_carry_capacity = BALANCE_CANNON_CORPSE_CARRY_CAPACITY;
	}

	if (!variable_instance_exists(_worker, "reserved_corpse_id"))
	{
		_worker.reserved_corpse_id = noone;
	}

	cannon_worker_carried_corpses_sync(_worker);

	if (variable_instance_exists(_worker, "cannon_no_corpse_warning_active"))
	{
		_worker.cannon_no_corpse_warning_active = false;
	}

	_worker.target_instance = noone;
	_worker.is_attacking_target = false;
	_worker.is_walking = false;

	if (day_worker_stamina_spend(_worker))
	{
		return false;
	}

	var _carried_corpse_count = cannon_worker_carried_corpse_count_get(_worker);

	if (_carried_corpse_count > 0)
	{
		var _deliver_distance = point_distance(_worker.x, _worker.y, _cannon.x, _cannon.y);

		if (_deliver_distance <= BALANCE_CANNON_CORPSE_DELIVER_RADIUS)
		{
			var _accepted_corpse_count = cannon_corpses_deliver(_carried_corpse_count);

			for (var _corpse_index = _accepted_corpse_count; _corpse_index < _carried_corpse_count; ++_corpse_index)
			{
				corpse_drop_at_position(_worker.carried_corpses[_corpse_index], _worker.x, _worker.y);
			}

			_worker.carried_corpses = [];
			_worker.carried_corpse = noone;
			_worker.reserved_corpse_id = noone;
			return true;
		}

		// After the first corpse, take a second only if it is closer than the cannon.
		var _remaining_delivery_count = cannon_corpse_delivery_remaining_get();

		if (_carried_corpse_count < min(_worker.corpse_carry_capacity, _remaining_delivery_count))
		{
			var _second_corpse = noone;

			if (_worker.reserved_corpse_id != noone)
			{
				_second_corpse = corpse_get_by_id(_worker.reserved_corpse_id);
			}

			if (!is_struct(_second_corpse))
			{
				_second_corpse = corpse_nearest_reserve_inside_distance(_worker.x, _worker.y, _worker, _deliver_distance);

				if (is_struct(_second_corpse) && variable_struct_exists(_second_corpse, "corpse_id"))
				{
					_worker.reserved_corpse_id = _second_corpse.corpse_id;
				}
				else
				{
					_worker.reserved_corpse_id = noone;
				}
			}

			if (is_struct(_second_corpse))
			{
				var _second_pickup_distance = point_distance(_worker.x, _worker.y, _second_corpse.x, _second_corpse.y);

				if (_second_pickup_distance <= BALANCE_CANNON_CORPSE_PICKUP_RADIUS)
				{
					var _taken_second_corpse = corpse_reserved_take(_worker.reserved_corpse_id, _worker);

					if (is_struct(_taken_second_corpse))
					{
						cannon_worker_carried_corpse_add(_worker, _taken_second_corpse);
					}

					_worker.reserved_corpse_id = noone;
				}
				else
				{
					cannon_worker_move_towards(_worker, _second_corpse.x, _second_corpse.y);
				}

				return true;
			}
		}

		cannon_worker_move_towards(_worker, _cannon.x, _cannon.y);
		return true;
	}

	var _reserved_corpse = noone;

	if (cannon_corpse_delivery_limit_reached())
	{
		corpse_reservation_clear(_worker.reserved_corpse_id, _worker);
		_worker.reserved_corpse_id = noone;
		cannon_worker_move_towards(_worker, _cannon.x, _cannon.y);
		return true;
	}

	if (_worker.reserved_corpse_id != noone)
	{
		_reserved_corpse = corpse_get_by_id(_worker.reserved_corpse_id);
	}

	if (!is_struct(_reserved_corpse))
	{
		_reserved_corpse = corpse_nearest_reserve(_worker.x, _worker.y, _worker);

		if (is_struct(_reserved_corpse) && variable_struct_exists(_reserved_corpse, "corpse_id"))
		{
			_worker.reserved_corpse_id = _reserved_corpse.corpse_id;
		}
		else
		{
			_worker.reserved_corpse_id = noone;
		}
	}

	if (!is_struct(_reserved_corpse))
	{
		if (variable_instance_exists(_worker, "cannon_no_corpse_warning_active"))
		{
			_worker.cannon_no_corpse_warning_active = true;
		}

		worker_idle_wander_update(_worker, true);

		return true;
	}

	var _pickup_distance = point_distance(_worker.x, _worker.y, _reserved_corpse.x, _reserved_corpse.y);

	if (_pickup_distance <= BALANCE_CANNON_CORPSE_PICKUP_RADIUS)
	{
		var _taken_corpse = corpse_reserved_take(_worker.reserved_corpse_id, _worker);

		if (is_struct(_taken_corpse))
		{
			cannon_worker_carried_corpse_add(_worker, _taken_corpse);
			_worker.reserved_corpse_id = noone;
		}
		else
		{
			_worker.reserved_corpse_id = noone;
		}

		return true;
	}

	cannon_worker_move_towards(_worker, _reserved_corpse.x, _reserved_corpse.y);
	return true;
};

cannon_corpse_workers_update = function()
{
	if (global.pause || global.day_phase != DAY_PHASE.DAY || !instance_exists(o_cannon))
	{
		return;
	}

	var _cannon = instance_find(o_cannon, 0);

	if (!variable_instance_exists(_cannon, "worker_cultists"))
	{
		return;
	}

	var _worker_count = array_length(_cannon.worker_cultists);
	var _workers = array_create(_worker_count);
	var _write_index = 0;

	for (var _copy_index = 0; _copy_index < _worker_count; ++_copy_index)
	{
		_workers[_copy_index] = _cannon.worker_cultists[_copy_index];
	}

	for (var _worker_index = 0; _worker_index < _worker_count; ++_worker_index)
	{
		var _worker = _workers[_worker_index];

		if (!instance_exists(_worker)
			|| !variable_instance_exists(_worker, "assigned_building")
			|| _worker.assigned_building != _cannon)
		{
			continue;
		}

		cannon_corpse_worker_update(_worker, _cannon);

		if (instance_exists(_worker)
			&& variable_instance_exists(_worker, "assigned_building")
			&& _worker.assigned_building == _cannon)
		{
			_cannon.worker_cultists[_write_index] = _worker;
			_write_index++;
		}
	}

	array_resize(_cannon.worker_cultists, _write_index);
};

cannon_corpse_workers_drop_all = function()
{
	var _friendly_count = instance_number(o_friendly_units);

	for (var _friendly_index = 0; _friendly_index < _friendly_count; ++_friendly_index)
	{
		var _friendly_unit = instance_find(o_friendly_units, _friendly_index);

		if (instance_exists(_friendly_unit))
		{
			cannon_corpse_worker_drop(_friendly_unit);
		}
	}

	var _cultist_count = array_length(global.archdemons);

	for (var _cultist_index = 0; _cultist_index < _cultist_count; ++_cultist_index)
	{
		var _cultist = global.archdemons[_cultist_index];

		if (instance_exists(_cultist))
		{
			cannon_corpse_worker_drop(_cultist);
		}
	}
};

// Runtime UI font includes Cyrillic glyphs for cultist names.
var _ui_font_size = 11;
var _ui_heading_font_size = 28;
var _building_speed_font_size = 44;
var _should_create_ui_font = !variable_global_exists("ui_font") || !font_exists(global.ui_font);
var _should_create_ui_heading_font = !variable_global_exists("ui_heading_font") || !font_exists(global.ui_heading_font);
var _should_create_building_speed_font = !variable_global_exists("building_speed_font") || !font_exists(global.building_speed_font);

if (!_should_create_ui_font && (!variable_global_exists("ui_font_size") || global.ui_font_size != _ui_font_size))
{
	font_delete(global.ui_font);
	_should_create_ui_font = true;
}

if (!_should_create_ui_heading_font
	&& (!variable_global_exists("ui_heading_font_size") || global.ui_heading_font_size != _ui_heading_font_size))
{
	font_delete(global.ui_heading_font);
	_should_create_ui_heading_font = true;
}

if (!_should_create_building_speed_font
	&& (!variable_global_exists("building_speed_font_size") || global.building_speed_font_size != _building_speed_font_size))
{
	font_delete(global.building_speed_font);
	_should_create_building_speed_font = true;
}

if (_should_create_ui_font)
{
	global.ui_font = font_add("Arial", _ui_font_size, false, false, 32, 1279);
	global.ui_font_size = _ui_font_size;
}

if (_should_create_ui_heading_font)
{
	global.ui_heading_font = font_add("Arial", _ui_heading_font_size, true, false, 32, 1279);
	global.ui_heading_font_size = _ui_heading_font_size;
}

if (_should_create_building_speed_font)
{
	global.building_speed_font = font_add("Arial Black", _building_speed_font_size, true, false, 32, 1279);
	global.building_speed_font_size = _building_speed_font_size;
}

open_starting_cultist_selection = function()
{
	if (!cultists_spawned
		|| !starting_cultist_selection_pending
		|| !global.tutorial_welcome_closed
		|| global.focus_window != FOCUS_WINDOW.NOONE
		|| (variable_global_exists("tutorial_popup_active") && global.tutorial_popup_active))
	{
		return;
	}

	starting_cultist_selection_pending = false;
	open_cultist_demon_selection(0);
};

spawn_starting_cultists = function()
{
	if (!instance_exists(o_cannon))
	{
		return;
	}

	global.archdemons = array_create(0);
	global.event_cultists = array_create(0);
	var _starting_unit_count = cultist_start_count + starting_event_cultist_count;

	// Spawn the single archdemon before placing regular cultists around the cannon.
	for (var _cultist_index = 0; _cultist_index < cultist_start_count; ++_cultist_index)
	{
		var _spawn_position = cannon_inner_position_get(_cultist_index, _starting_unit_count);
		var _spawn_x = _spawn_position[0];
		var _spawn_y = _spawn_position[1];
		var _cultist = instance_create_layer(_spawn_x, _spawn_y, "Instances", o_archdemon);

		array_push(global.archdemons, _cultist);
		squad_register_existing_unit(SQUAD_TYPE.ARCHDEMON, _cultist);
	}

	// Spawn regular cultists separately from the single archdemon.
	var _cannon = instance_find(o_cannon, 0);
	var _cultist_spacing = (BALANCE_EVENT_CULTIST_WANDER_HORIZONTAL_DISTANCE * 2)
		/ max(1, starting_event_cultist_count - 1);

	var _starting_event_cultist_count = min(starting_event_cultist_count, global.cultist_limit);

	for (var _event_cultist_index = 0; _event_cultist_index < _starting_event_cultist_count; ++_event_cultist_index)
	{
		var _spawn_x = _cannon.x - BALANCE_EVENT_CULTIST_WANDER_HORIZONTAL_DISTANCE
			+ (_cultist_spacing * _event_cultist_index);
		var _spawn_y = _cannon.y + BALANCE_EVENT_CULTIST_WANDER_VERTICAL_DISTANCE_MIN;
		var _event_cultist = instance_create_layer(_spawn_x, _spawn_y, "Instances", o_cultist);
		_event_cultist.cultist_name = day_event_cultist_random_name_get();
		array_push(global.event_cultists, _event_cultist);
	}

	// Buildings provide their random daily event after the starting roster exists.
	day_event_generate_for_buildings();

	cultists_spawned = true;
	starting_cultist_selection_pending = true;
	open_starting_cultist_selection();
};

spawn_shrine_holy_towers = function(_shrine, _cannon)
{
	if (!instance_exists(_shrine) || !instance_exists(_cannon))
	{
		return;
	}

	var _tower_count = max(0, BALANCE_SHRINE_HOLY_TOWER_COUNT);

	if (_tower_count <= 0)
	{
		return;
	}

	var _tower_distance = BALANCE_SHRINE_HOLY_TOWER_DISTANCE;
	var _base_angle = point_direction(_cannon.x, _cannon.y, _shrine.x, _shrine.y);

	for (var _tower_index = 0; _tower_index < _tower_count; ++_tower_index)
	{
		var _tower_angle = _base_angle + 90 + ((360 / _tower_count) * _tower_index);
		var _tower_x = _shrine.x + lengthdir_x(_tower_distance, _tower_angle);
		var _tower_y = _shrine.y + lengthdir_y(_tower_distance, _tower_angle);

		var _tower = instance_create_layer(_tower_x, _tower_y, "Instances", o_holy_tower);

		if (instance_exists(_tower))
		{
			_tower.owner_shrine = _shrine;

			if (variable_instance_exists(_shrine, "shrine_protection_tower_add"))
			{
				_shrine.shrine_protection_tower_add(_tower);
			}
		}
	}
};

shrine_position_is_far_enough = function(_position_x, _position_y, _positions)
{
	for (var _position_index = 0; _position_index < array_length(_positions); ++_position_index)
	{
		var _position = _positions[_position_index];

		if (point_distance(_position_x, _position_y, _position.x, _position.y) < BALANCE_SHRINE_MIN_SPACING)
		{
			return false;
		}
	}

	return true;
};

shrine_random_position_roll = function(_cannon, _shrine_index, _shrine_count, _positions)
{
	var _sector_size = 360 / max(1, _shrine_count);
	var _base_angle = (_sector_size * _shrine_index) + random(_sector_size);
	var _map_margin = BALANCE_SHRINE_HOLY_TOWER_DISTANCE + 160;
	var _fallback_x = _cannon.x + lengthdir_x(BALANCE_SHRINE_DISTANCE_MIN, _base_angle);
	var _fallback_y = _cannon.y + lengthdir_y(BALANCE_SHRINE_DISTANCE_MIN, _base_angle);

	_fallback_x = clamp(_fallback_x, _map_margin, room_width - _map_margin);
	_fallback_y = clamp(_fallback_y, _map_margin, room_height - _map_margin);

	for (var _attempt_index = 0; _attempt_index < BALANCE_SHRINE_RANDOM_POSITION_ATTEMPTS; ++_attempt_index)
	{
		var _angle = (_sector_size * _shrine_index) + random(_sector_size);
		var _distance = random_range(BALANCE_SHRINE_DISTANCE_MIN, BALANCE_SHRINE_DISTANCE_MAX);
		var _position_x = _cannon.x + lengthdir_x(_distance, _angle);
		var _position_y = _cannon.y + lengthdir_y(_distance, _angle);

		_position_x = clamp(_position_x, _map_margin, room_width - _map_margin);
		_position_y = clamp(_position_y, _map_margin, room_height - _map_margin);

		if (shrine_position_is_far_enough(_position_x, _position_y, _positions))
		{
			return {
				x: _position_x,
				y: _position_y
			};
		}
	}

	return {
		x: _fallback_x,
		y: _fallback_y
	};
};

spawn_objective_shrines = function()
{
	if (shrines_spawned || !instance_exists(o_cannon))
	{
		return;
	}

	var _cannon = instance_find(o_cannon, 0);
	var _shrine_count = max(0, BALANCE_SHRINE_OBJECTIVE_TOTAL);
	var _shrine_positions = [];
	shrine_instances = array_create(0);
	shrine_objective_total = _shrine_count;
	shrine_objective_required = min(BALANCE_SHRINE_OBJECTIVE_REQUIRED, shrine_objective_total);

	// Remove old hand-placed objective markers before rolling runtime shrine positions.
	with (o_shrine_spot)
	{
		instance_destroy();
	}

	for (var _shrine_index = 0; _shrine_index < _shrine_count; ++_shrine_index)
	{
		var _shrine_position = shrine_random_position_roll(_cannon, _shrine_index, _shrine_count, _shrine_positions);
		array_push(_shrine_positions, _shrine_position);
		var _shrine = instance_create_layer(_shrine_position.x, _shrine_position.y, "Instances", o_shrine);

		if (instance_exists(_shrine))
		{
			array_push(shrine_instances, _shrine);
			spawn_shrine_holy_towers(_shrine, _cannon);
		}
	}

	shrines_spawned = true;
	night_attack_plan_create();
};

shrine_corrupted_count_get = function()
{
	var _corrupted_count = 0;
	var _shrine_count = array_length(shrine_instances);

	for (var _shrine_index = 0; _shrine_index < _shrine_count; ++_shrine_index)
	{
		var _shrine = shrine_instances[_shrine_index];

		if (instance_exists(_shrine)
			&& variable_instance_exists(_shrine, "is_corrupted")
			&& _shrine.is_corrupted)
		{
			_corrupted_count++;
		}
	}

	return _corrupted_count;
};

shrine_can_spawn_night_attack = function(_shrine)
{
	return instance_exists(_shrine)
		&& (!variable_instance_exists(_shrine, "is_corrupted") || !_shrine.is_corrupted);
};

shrine_objective_update = function()
{
	if (global.shrine_objective_complete)
	{
		return;
	}

	if (shrine_corrupted_count_get() >= shrine_objective_required)
	{
		global.shrine_objective_complete = true;
	}
};

// Open the demon selection window for a newly received cultist.
open_cultist_demon_selection = function(_selection_index)
{
	cultist_selection_index = _selection_index;
	cultist_selected_demon_type = DEMON_TYPE.IMP;
	cultist_selected_starting_ability = cultist_starting_ability_default_get(cultist_selected_demon_type);
	cultist_name_input_active = true;
	keyboard_string = "";
	global.pause = true;
	global.focus_window = FOCUS_WINDOW.CULTIST_DEMON_SELECTION;
};

// Add extra cultists on fixed early days.
award_day_cultists = function()
{
	var _reward_count = array_length(cultist_reward_days);

	for (var _reward_index = next_cultist_reward_index; _reward_index < _reward_count; ++_reward_index)
	{
		var _reward_day = cultist_reward_days[_reward_index];

		if (night_attack_night_index < _reward_day)
		{
			break;
		}

		// Blood Moon replaces a fixed day reward so its morning arrivals stay grouped.
		if (full_moon_night_is_scheduled(night_attack_night_index))
		{
			next_cultist_reward_index = _reward_index + 1;
			continue;
		}

		// New followers are regular event workers, never additional archdemons.
		var _new_cultist = day_event_cultist_add();

		if (!instance_exists(_new_cultist))
		{
			break;
		}

		next_cultist_reward_index = _reward_index + 1;
	}
};

get_current_cultist = function()
{
	if (cultist_selection_index >= 0 && cultist_selection_index < array_length(global.archdemons))
	{
		var _cultist = global.archdemons[cultist_selection_index];

		if (instance_exists(_cultist))
		{
			return _cultist;
		}
	}

	return noone;
};

cultist_starting_ability_default_get = function(_demon_type)
{
	var _active_abilities = cultist_demon_active_abilities_get(_demon_type);

	if (array_length(_active_abilities) <= 0)
	{
		return DEMON_ABILITY.NONE;
	}

	return _active_abilities[0];
};

cultist_selected_starting_ability_validate = function()
{
	var _active_abilities = cultist_demon_active_abilities_get(cultist_selected_demon_type);
	var _ability_count = array_length(_active_abilities);

	for (var _ability_index = 0; _ability_index < _ability_count; ++_ability_index)
	{
		if (_active_abilities[_ability_index] == cultist_selected_starting_ability)
		{
			return;
		}
	}

	cultist_selected_starting_ability = cultist_starting_ability_default_get(cultist_selected_demon_type);
};

worker_assignment_hint_delay_start = function()
{
	if (worker_assignment_hint_completed || worker_assignment_hint_delay_started)
	{
		return;
	}

	worker_assignment_hint_delay_started = true;
	worker_assignment_hint_delay_timer = worker_assignment_hint_delay_time;
};

full_moon_hint_delay_start = function()
{
	if (!global.tutorial_hints_enabled)
	{
		return;
	}

	full_moon_hint_delay_pending = true;
	full_moon_hint_delay_timer = full_moon_hint_delay_time;
};

full_moon_hint_delay_update = function()
{
	if (!full_moon_hint_delay_pending)
	{
		return;
	}

	if (global.day_phase != DAY_PHASE.DAY)
	{
		full_moon_hint_delay_pending = false;
		full_moon_hint_delay_timer = -1;
		return;
	}

	if (global.pause
		|| global.focus_window != FOCUS_WINDOW.NOONE
		|| (variable_global_exists("tutorial_popup_active") && global.tutorial_popup_active))
	{
		return;
	}

	full_moon_hint_delay_timer--;

	if (full_moon_hint_delay_timer > 0)
	{
		return;
	}

	full_moon_hint_delay_pending = false;
	full_moon_hint_delay_timer = -1;

	if (variable_global_exists("tutorial_hint_trigger"))
	{
		global.tutorial_hint_trigger("full_moon_night");
	}
};

assign_current_cultist_demon = function()
{
	var _cultist = get_current_cultist();

	if (!instance_exists(_cultist))
	{
		return;
	}

	var _typed_name = string_trim(keyboard_string);

	if (_typed_name == "")
	{
		_typed_name = "Cultist " + string(cultist_selection_index + 1);
	}

	_cultist.cultist_name = string_copy(_typed_name, 1, 16);

	if (variable_instance_exists(_cultist, "squad") && is_struct(_cultist.squad))
	{
		_cultist.squad.name = _cultist.cultist_name;
	}
	_cultist.demon_type = cultist_selected_demon_type;
	cultist_selected_starting_ability_validate();
	_cultist.demon_ability = cultist_selected_starting_ability;

	if (variable_instance_exists(_cultist, "cultist_starting_abilities")
		&& cultist_selected_demon_type >= 0
		&& cultist_selected_demon_type < array_length(_cultist.cultist_starting_abilities))
	{
		_cultist.cultist_starting_abilities[cultist_selected_demon_type] = cultist_selected_starting_ability;
	}

	_cultist.active_abilities = [_cultist.demon_ability];
	cultist_ability_level_set(_cultist, _cultist.demon_ability, 1);
	cultist_day_health_apply(_cultist, true);

	if (variable_instance_exists(_cultist, "archdemon_visual_apply"))
	{
		_cultist.archdemon_visual_apply();
	}

	cultist_selection_index++;
	keyboard_string = "";
	cultist_selected_demon_type = DEMON_TYPE.IMP;
	cultist_selected_starting_ability = cultist_starting_ability_default_get(cultist_selected_demon_type);

	if (cultist_selection_index >= array_length(global.archdemons))
	{
		global.pause = false;
		global.focus_window = FOCUS_WINDOW.NOONE;
		worker_assignment_hint_delay_start();
	}
};

transform_cultists_to_demons = function()
{
	var _cultist_count = array_length(global.archdemons);
	var _new_units = array_create(0);

	for (var _cultist_index = 0; _cultist_index < _cultist_count; ++_cultist_index)
	{
		var _cultist = global.archdemons[_cultist_index];

		if (!instance_exists(_cultist)
			|| _cultist.object_index != o_archdemon
			|| _cultist.demon_type == DEMON_TYPE.NONE
			|| _cultist.hp <= 0
			|| (variable_instance_exists(_cultist, "morning_respawn_pending") && _cultist.morning_respawn_pending))
		{
			if (instance_exists(_cultist))
			{
				array_push(_new_units, _cultist);
			}

			continue;
		}

		var _demon_object = cultist_demon_object_get(_cultist.demon_type);

		if (_demon_object == noone)
		{
			continue;
		}

		var _demon = instance_create_layer(_cultist.x, _cultist.y, "Instances", _demon_object);
		var _cultist_hp = _cultist.hp;

		clear_cultist_building_assignment(_cultist);
		_demon.cultist_name = _cultist.cultist_name;
		_demon.cultist_points = _cultist.cultist_points;
		_demon.cultist_sprite_index = _cultist.cultist_sprite_index;
		_demon.demon_type = _cultist.demon_type;
		_demon.demon_ability = _cultist.demon_ability;

		if (variable_instance_exists(_cultist, "stamina_amount"))
		{
			_demon.stamina_amount = _cultist.stamina_amount;
		}

		if (variable_instance_exists(_cultist, "stamina_max"))
		{
			_demon.stamina_max = _cultist.stamina_max;
		}

		if (variable_instance_exists(_cultist, "adaptive_night_hp_start"))
		{
			_demon.adaptive_night_hp_start = _cultist.adaptive_night_hp_start;
		}

		if (variable_instance_exists(_cultist, "adaptive_night_damage_taken"))
		{
			_demon.adaptive_night_damage_taken = _cultist.adaptive_night_damage_taken;
		}

		_demon.cultist_starting_abilities = _cultist.cultist_starting_abilities;

		_demon.current_exp = _cultist.current_exp;
		_demon.current_lvl = _cultist.current_lvl;
		cultist_demon_scale_apply(_demon);
		_demon.pending_level_points = _cultist.pending_level_points;
		_demon.pending_passive_choices = _cultist.pending_passive_choices;
		_demon.pending_active_choices = _cultist.pending_active_choices;
		_demon.pending_ability_upgrade_choices = _cultist.pending_ability_upgrade_choices;
		_demon.passive_choice_options = _cultist.passive_choice_options;
		_demon.active_choice_options = _cultist.active_choice_options;
		_demon.ability_upgrade_choice_options = _cultist.ability_upgrade_choice_options;
		_demon.active_abilities = _cultist.active_abilities;
		_demon.ability_levels = _cultist.ability_levels;
		_demon.has_brute_corpse_eater = _cultist.has_brute_corpse_eater;
		_demon.has_brute_rotten_aura = _cultist.has_brute_rotten_aura;
		_demon.has_brute_blood_anvil = _cultist.has_brute_blood_anvil;
		_demon.has_warlock_soul_harvester = _cultist.has_warlock_soul_harvester;
		_demon.has_warlock_curseweaver = _cultist.has_warlock_curseweaver;
		_demon.has_warlock_demonic_infusion = _cultist.has_warlock_demonic_infusion;
		cultist_stats_apply(_demon);
		_demon.hp = clamp(_cultist_hp, 0, _demon.max_hp);

		if (variable_instance_exists(_demon, "ability_cooldown"))
		{
			_demon.ability_cooldown = cultist_ability_cooldown_get(_demon.demon_ability) * room_speed;
			_demon.ability_timer = _demon.ability_cooldown;
			_demon.base_reload_time = _demon.reload_time;
		}

		array_push(_new_units, _demon);
		instance_destroy(_cultist);
	}

	global.archdemons = _new_units;
};

cultist_projectile_deploy_assignments_reset = function()
{
	var _friendly_count = instance_number(o_friendly_units);

	for (var _friendly_index = 0; _friendly_index < _friendly_count; ++_friendly_index)
	{
		var _friendly_unit = instance_find(o_friendly_units, _friendly_index);

		if (instance_exists(_friendly_unit)
			&& variable_instance_exists(_friendly_unit, "cultist_projectile_deploy_assigned")
			&& variable_instance_exists(_friendly_unit, "cultist_projectile_deploy_waiting")
			&& (_friendly_unit.object_index == o_skeleton || _friendly_unit.object_index == o_pitling))
		{
			_friendly_unit.cultist_projectile_deploy_assigned = false;
			_friendly_unit.cultist_projectile_deploy_waiting = false;
			_friendly_unit.visible = true;
		}
	}
};

cultist_projectile_deploy_unit_hide = function(_unit)
{
	if (!instance_exists(_unit))
	{
		return;
	}

	_unit.visible = false;
	_unit.x = 0;
	_unit.y = 0;
	_unit.drag_drop_x = 0;
	_unit.drag_drop_y = 0;
	_unit.target_instance = noone;
	_unit.alert_target = noone;
	_unit.is_attacking_target = false;
	_unit.is_walking = false;
	_unit.regroup_is_active = false;
	_unit.rally_is_active = false;
	_unit.rally_is_returning = false;
	_unit.rally_has_arrived = false;
};

summoned_combat_units_prepare_for_cultist_projectiles = function()
{
	var _friendly_count = instance_number(o_friendly_units);

	for (var _friendly_index = 0; _friendly_index < _friendly_count; ++_friendly_index)
	{
		var _friendly_unit = instance_find(o_friendly_units, _friendly_index);

		if (!instance_exists(_friendly_unit)
			|| !variable_instance_exists(_friendly_unit, "summon_nights_remaining")
			|| !variable_instance_exists(_friendly_unit, "cultist_projectile_deploy_waiting")
			|| (_friendly_unit.object_index != o_skeleton && _friendly_unit.object_index != o_pitling))
		{
			continue;
		}

		clear_cultist_building_assignment(_friendly_unit);
		_friendly_unit.cultist_projectile_deploy_waiting = true;
		_friendly_unit.cultist_projectile_deploy_assigned = false;
		cultist_projectile_deploy_unit_hide(_friendly_unit);
	}
};

clear_cannon_projectile_queues = function(_clear_all = true)
{
	cultist_projectile_deploy_assignments_reset();

	if (_clear_all)
	{
		global.cannon_projectile_queue = [];
		global.cannon_projectile_payload_queue = [];
		global.cannon_selected_projectile_index = 0;
		global.cannon_projectile_gain_timer = 0;
		return;
	}

	var _projectile_count = array_length(global.cannon_projectile_queue);
	var _payload_count = array_length(global.cannon_projectile_payload_queue);
	var _kept_projectiles = [];
	var _kept_payloads = [];

	for (var _projectile_index = 0; _projectile_index < _projectile_count; ++_projectile_index)
	{
		var _projectile_type = global.cannon_projectile_queue[_projectile_index];

		if (_projectile_type == PROJECTILE_TYPE.CULTIST)
		{
			continue;
		}

		var _payload = noone;

		if (_projectile_index < _payload_count)
		{
			_payload = global.cannon_projectile_payload_queue[_projectile_index];
		}

		array_push(_kept_projectiles, _projectile_type);
		array_push(_kept_payloads, _payload);
	}

	global.cannon_projectile_queue = _kept_projectiles;
	global.cannon_projectile_payload_queue = _kept_payloads;
	global.cannon_selected_projectile_index = clamp(global.cannon_selected_projectile_index, 0, max(0, array_length(global.cannon_projectile_queue) - 1));
	global.cannon_projectile_gain_timer = 0;
};

cultist_projectile_deploy_candidate_collect = function()
{
	var _deploy_units = array_create(0);
	var _friendly_count = instance_number(o_friendly_units);

	for (var _friendly_index = 0; _friendly_index < _friendly_count; ++_friendly_index)
	{
		var _friendly_unit = instance_find(o_friendly_units, _friendly_index);

		if (!instance_exists(_friendly_unit)
			|| !variable_instance_exists(_friendly_unit, "summon_nights_remaining")
			|| !variable_instance_exists(_friendly_unit, "cultist_projectile_deploy_assigned")
			|| _friendly_unit.cultist_projectile_deploy_assigned
			|| (_friendly_unit.object_index != o_skeleton && _friendly_unit.object_index != o_pitling))
		{
			continue;
		}

		array_push(_deploy_units, _friendly_unit);
	}

	return _deploy_units;
};

cultist_projectile_deploy_units_take = function(_remaining_cultist_projectile_count)
{
	var _deploy_units = cultist_projectile_deploy_candidate_collect();
	var _deploy_unit_count = array_length(_deploy_units);
	var _safe_projectile_count = max(1, _remaining_cultist_projectile_count);
	var _take_count = min(_deploy_unit_count, ceil(_deploy_unit_count / _safe_projectile_count));
	var _taken_units = array_create(0);

	for (var _deploy_index = 0; _deploy_index < _take_count; ++_deploy_index)
	{
		var _deploy_unit = _deploy_units[_deploy_index];

		if (!instance_exists(_deploy_unit))
		{
			continue;
		}

		_deploy_unit.cultist_projectile_deploy_assigned = true;
		_deploy_unit.cultist_projectile_deploy_waiting = false;
		cultist_projectile_deploy_unit_hide(_deploy_unit);
		array_push(_taken_units, _deploy_unit);
	}

	return _taken_units;
};

squad_projectile_deploy_units_take = function(_primary_unit)
{
	var _deploy_units = [];

	if (!instance_exists(_primary_unit) || !variable_instance_exists(_primary_unit, "squad") || !is_struct(_primary_unit.squad))
	{
		return cultist_projectile_deploy_units_take(1);
	}

	var _squad_units = _primary_unit.squad.units;

	for (var _unit_index = 0; _unit_index < array_length(_squad_units); ++_unit_index)
	{
		var _unit = _squad_units[_unit_index];
		if (!instance_exists(_unit) || _unit == _primary_unit) continue;
		cultist_projectile_deploy_unit_hide(_unit);
		_unit.cultist_projectile_deploy_assigned = true;
		array_push(_deploy_units, _unit);
	}

	return _deploy_units;
};

queue_cultist_projectile = function(_cultist)
{
	if (!instance_exists(_cultist))
	{
		return false;
	}

	var _projectile_queue_count = array_length(global.cannon_projectile_queue);
	var _payload_queue_count = array_length(global.cannon_projectile_payload_queue);
	var _insert_index = 0;

	for (var _leading_index = 0; _leading_index < _projectile_queue_count; ++_leading_index)
	{
		if (global.cannon_projectile_queue[_leading_index] != PROJECTILE_TYPE.CULTIST)
		{
			break;
		}

		_insert_index++;
	}

	var _updated_projectile_queue = array_create(_projectile_queue_count + 1);
	var _updated_payload_queue = array_create(_projectile_queue_count + 1);

	for (var _copy_index = 0; _copy_index < _insert_index; ++_copy_index)
	{
		var _copy_payload = noone;

		if (_copy_index < _payload_queue_count)
		{
			_copy_payload = global.cannon_projectile_payload_queue[_copy_index];
		}

		_updated_projectile_queue[_copy_index] = global.cannon_projectile_queue[_copy_index];
		_updated_payload_queue[_copy_index] = _copy_payload;
	}

	_updated_projectile_queue[_insert_index] = PROJECTILE_TYPE.CULTIST;
	_updated_payload_queue[_insert_index] = _cultist;

	for (var _shift_index = _insert_index; _shift_index < _projectile_queue_count; ++_shift_index)
	{
		var _shift_payload = noone;

		if (_shift_index < _payload_queue_count)
		{
			_shift_payload = global.cannon_projectile_payload_queue[_shift_index];
		}

		_updated_projectile_queue[_shift_index + 1] = global.cannon_projectile_queue[_shift_index];
		_updated_payload_queue[_shift_index + 1] = _shift_payload;
	}

	global.cannon_projectile_queue = _updated_projectile_queue;
	global.cannon_projectile_payload_queue = _updated_payload_queue;
	global.cannon_selected_projectile_index = clamp(global.cannon_selected_projectile_index, 0, array_length(global.cannon_projectile_queue) - 1);
	return true;
};

start_cultists_loading_into_cannon = function()
{
	clear_cannon_projectile_queues(false);

	for (var _squad_index = 0; _squad_index < array_length(global.squads); ++_squad_index)
	{
		var _squad = global.squads[_squad_index];

		if (_squad.squad_type == SQUAD_TYPE.ARCHDEMON
			|| (global.ritual_hell_weakest_active
				&& _squad == global.ritual_hell_weakest_squad))
		{
			continue;
		}

		var _primary_unit = noone;

		for (var _unit_index = 0; _unit_index < array_length(_squad.units); ++_unit_index)
		{
			var _unit = _squad.units[_unit_index];
			if (!instance_exists(_unit)) continue;
			if (!instance_exists(_primary_unit)) _primary_unit = _unit;
			cultist_projectile_deploy_unit_hide(_unit);
		}

		if (instance_exists(_primary_unit))
		{
			_primary_unit.cannon_loading = true;
			_primary_unit.cannon_loaded = false;
			queue_cultist_projectile(_primary_unit);
		}
	}

	var _cultist_count = array_length(global.archdemons);

	for (var _cultist_index = 0; _cultist_index < _cultist_count; ++_cultist_index)
	{
		var _cultist = global.archdemons[_cultist_index];

		if (!instance_exists(_cultist)
			|| _cultist.object_index != o_archdemon
			|| _cultist.demon_type == DEMON_TYPE.NONE
			|| (global.ritual_hell_weakest_active
				&& variable_instance_exists(_cultist, "squad")
				&& _cultist.squad == global.ritual_hell_weakest_squad))
		{
			continue;
		}

		clear_cultist_building_assignment(_cultist);
		_cultist.cannon_loading = true;
		_cultist.cannon_loaded = false;
		_cultist.visible = true;
		_cultist.is_being_dragged = false;
		queue_cultist_projectile(_cultist);
	}
};

update_cultists_loading_into_cannon = function()
{
	if (global.pause || global.day_phase != DAY_PHASE.NIGHT || !instance_exists(o_cannon))
	{
		return;
	}

	var _cannon = instance_find(o_cannon, 0);
	var _cultist_count = array_length(global.archdemons);

	for (var _cultist_index = 0; _cultist_index < _cultist_count; ++_cultist_index)
	{
		var _cultist = global.archdemons[_cultist_index];

		if (!instance_exists(_cultist)
			|| _cultist.object_index != o_archdemon
			|| !variable_instance_exists(_cultist, "cannon_loading")
			|| !_cultist.cannon_loading
			|| _cultist.cannon_loaded)
		{
			continue;
		}

		var _distance_to_cannon = point_distance(_cultist.x, _cultist.y, _cannon.x, _cannon.y);

		if (_distance_to_cannon <= BALANCE_CULTIST_CANNON_LOAD_ARRIVE_RADIUS)
		{
			_cultist.cannon_loading = false;
			_cultist.cannon_loaded = true;
			_cultist.visible = false;
			_cultist.x = _cannon.x;
			_cultist.y = _cannon.y;
			_cultist.drag_drop_x = _cannon.x;
			_cultist.drag_drop_y = _cannon.y;
			continue;
		}

		var _move_distance = min(BALANCE_CULTIST_CANNON_LOAD_SPEED, _distance_to_cannon);
		var _move_direction = point_direction(_cultist.x, _cultist.y, _cannon.x, _cannon.y);

		_cultist.x += lengthdir_x(_move_distance, _move_direction);
		_cultist.y += lengthdir_y(_move_distance, _move_direction);
		_cultist.drag_drop_x = _cultist.x;
		_cultist.drag_drop_y = _cultist.y;
	}
};

unload_cultist_projectiles_to_day = function()
{
	var _payload_count = array_length(global.cannon_projectile_payload_queue);

	for (var _payload_index = 0; _payload_index < _payload_count; ++_payload_index)
	{
		var _cultist = global.cannon_projectile_payload_queue[_payload_index];

		if (instance_exists(_cultist)
			&& variable_instance_exists(_cultist, "cannon_loaded"))
		{
			_cultist.cannon_loading = false;
			_cultist.cannon_loaded = false;
			_cultist.visible = true;
		}
	}

	var _cultist_count = array_length(global.archdemons);

	for (var _cultist_index = 0; _cultist_index < _cultist_count; ++_cultist_index)
	{
		var _cultist = global.archdemons[_cultist_index];

		if (instance_exists(_cultist)
			&& _cultist.object_index == o_archdemon
			&& variable_instance_exists(_cultist, "cannon_loading"))
		{
			_cultist.cannon_loading = false;
			_cultist.cannon_loaded = false;
			_cultist.visible = true;
		}
	}

	clear_cannon_projectile_queues(false);
};

cannon_inner_regroup_offset_x_get = function(_unit_object)
{
	if (_unit_object == o_skeleton)
	{
		return BALANCE_DAY_CANNON_SKELETON_REGROUP_OFFSET_X;
	}

	if (_unit_object == o_pitling)
	{
		return BALANCE_DAY_CANNON_PITLING_REGROUP_OFFSET_X;
	}

	return 0;
};

cannon_inner_regroup_offset_y_get = function(_unit_object)
{
	if (_unit_object == o_skeleton || _unit_object == o_pitling)
	{
		return BALANCE_DAY_CANNON_COMBAT_REGROUP_OFFSET_Y;
	}

	return 0;
};

cannon_inner_position_get = function(_unit_index, _unit_count, _unit_object = noone)
{
	if (!instance_exists(o_cannon))
	{
		return [0, 0];
	}

	var _cannon = instance_find(o_cannon, 0);
	var _safe_column_count = min(BALANCE_DAY_CANNON_REGROUP_COLUMNS, max(1, _unit_count));
	var _column = _unit_index mod _safe_column_count;
	var _row = _unit_index div _safe_column_count;
	var _row_count = ceil(max(1, _unit_count) / _safe_column_count);
	var _regroup_offset_x = cannon_inner_regroup_offset_x_get(_unit_object);
	var _regroup_offset_y = cannon_inner_regroup_offset_y_get(_unit_object);
	var _regroup_x = _cannon.x + _regroup_offset_x - (((_safe_column_count - 1) * BALANCE_DAY_CANNON_REGROUP_SPACING) * 0.5);
	var _regroup_y = _cannon.y + BALANCE_DAY_CANNON_REGROUP_OFFSET_Y + _regroup_offset_y;

	return [
		_regroup_x + (_column * BALANCE_DAY_CANNON_REGROUP_SPACING),
		_regroup_y + ((_row - ((_row_count - 1) * 0.5)) * BALANCE_DAY_CANNON_REGROUP_SPACING)
	];
};

move_unit_to_cannon_inner = function(_unit, _unit_index, _unit_count)
{
	if (!instance_exists(_unit) || !instance_exists(o_cannon))
	{
		return;
	}

	var _position = cannon_inner_position_get(_unit_index, _unit_count, _unit.object_index);

	_unit.x = _position[0];
	_unit.y = _position[1];
	_unit.drag_drop_x = _unit.x;
	_unit.drag_drop_y = _unit.y;
};

move_spawned_summoned_unit_to_cannon_inner = function(_unit)
{
	if (!instance_exists(_unit) || !instance_exists(o_cannon))
	{
		return;
	}

	var _friendly_count = instance_number(o_friendly_units);
	var _summoned_count = 0;
	var _regroup_object = _unit.object_index;

	if (_regroup_object != o_skeleton && _regroup_object != o_pitling)
	{
		_regroup_object = noone;
	}

	for (var _friendly_index = 0; _friendly_index < _friendly_count; ++_friendly_index)
	{
		var _friendly_unit = instance_find(o_friendly_units, _friendly_index);

		if (instance_exists(_friendly_unit)
			&& variable_instance_exists(_friendly_unit, "summon_nights_remaining")
			&& (_regroup_object == noone || _friendly_unit.object_index == _regroup_object))
		{
			_summoned_count++;
		}
	}

	var _unit_index = max(0, _summoned_count - 1);
	var _position = cannon_inner_position_get(_unit_index, max(1, _summoned_count), _unit.object_index);

	clear_cultist_building_assignment(_unit);

	if (variable_instance_exists(_unit, "regroup_is_active"))
	{
		_unit.regroup_is_active = true;
		_unit.regroup_target_x = _position[0];
		_unit.regroup_target_y = _position[1];
		_unit.rally_is_active = false;
		_unit.rally_is_returning = false;
		_unit.rally_has_arrived = false;
		_unit.drag_drop_x = _position[0];
		_unit.drag_drop_y = _position[1];
	}
};

move_unit_outside_cannon_wall = function(_unit, _unit_index, _unit_count)
{
	if (!instance_exists(_unit) || !instance_exists(o_cannon))
	{
		return;
	}

	var _cannon = instance_find(o_cannon, 0);
	var _safe_unit_count = max(1, _unit_count);
	var _angle = 360 * (_unit_index / _safe_unit_count);
	var _outside_radius = BALANCE_CANNON_WALL_RADIUS + 84 + (18 * (_unit_index mod 3));

	_unit.x = _cannon.x + lengthdir_x(_outside_radius, _angle);
	_unit.y = _cannon.y + lengthdir_y(_outside_radius, _angle);
	_unit.drag_drop_x = _unit.x;
	_unit.drag_drop_y = _unit.y;
};

move_summoned_units_to_cannon_inner = function()
{
	var _friendly_count = instance_number(o_friendly_units);
	var _skeleton_units = array_create(0);
	var _pitling_units = array_create(0);
	var _other_summoned_units = array_create(0);

	for (var _friendly_index = 0; _friendly_index < _friendly_count; ++_friendly_index)
	{
		var _friendly_unit = instance_find(o_friendly_units, _friendly_index);

		if (instance_exists(_friendly_unit)
			&& variable_instance_exists(_friendly_unit, "summon_nights_remaining"))
		{
			clear_cultist_building_assignment(_friendly_unit);

			if (_friendly_unit.object_index == o_skeleton)
			{
				array_push(_skeleton_units, _friendly_unit);
			}
			else if (_friendly_unit.object_index == o_pitling)
			{
				array_push(_pitling_units, _friendly_unit);
			}
			else
			{
				array_push(_other_summoned_units, _friendly_unit);
			}
		}
	}

	var _skeleton_count = array_length(_skeleton_units);
	var _pitling_count = array_length(_pitling_units);
	var _other_summoned_count = array_length(_other_summoned_units);

	for (var _skeleton_index = 0; _skeleton_index < _skeleton_count; ++_skeleton_index)
	{
		move_unit_to_cannon_inner(_skeleton_units[_skeleton_index], _skeleton_index, _skeleton_count);
	}

	for (var _pitling_index = 0; _pitling_index < _pitling_count; ++_pitling_index)
	{
		move_unit_to_cannon_inner(_pitling_units[_pitling_index], _pitling_index, _pitling_count);
	}

	for (var _other_summoned_index = 0; _other_summoned_index < _other_summoned_count; ++_other_summoned_index)
	{
		move_unit_to_cannon_inner(_other_summoned_units[_other_summoned_index], _other_summoned_index, _other_summoned_count);
	}
};

move_goblins_to_cannon_inner = function()
{
	if (!instance_exists(o_cannon))
	{
		return;
	}

	var _goblins = array_create(0);
	var _goblin_count = instance_number(o_goblin);

	for (var _goblin_index = 0; _goblin_index < _goblin_count; ++_goblin_index)
	{
		var _goblin = instance_find(o_goblin, _goblin_index);

		if (!instance_exists(_goblin))
		{
			continue;
		}

		clear_cultist_building_assignment(_goblin);
		array_push(_goblins, _goblin);
	}

	var _active_goblin_count = array_length(_goblins);

	for (var _assigned_index = 0; _assigned_index < _active_goblin_count; ++_assigned_index)
	{
		var _assigned_goblin = _goblins[_assigned_index];

		if (!instance_exists(_assigned_goblin))
		{
			continue;
		}

		var _position = cannon_inner_position_get(_assigned_index, _active_goblin_count);

		_assigned_goblin.regroup_is_active = true;
		_assigned_goblin.regroup_target_x = _position[0];
		_assigned_goblin.regroup_target_y = _position[1];
		_assigned_goblin.rally_is_active = false;
		_assigned_goblin.rally_is_returning = false;
		_assigned_goblin.rally_has_arrived = false;
		_assigned_goblin.drag_drop_x = _position[0];
		_assigned_goblin.drag_drop_y = _position[1];
	}
};

move_summoned_units_outside_cannon_wall = function()
{
	var _friendly_count = instance_number(o_friendly_units);
	var _summoned_units = array_create(0);
	var _outside_units = array_create(0);

	for (var _friendly_index = 0; _friendly_index < _friendly_count; ++_friendly_index)
	{
		var _friendly_unit = instance_find(o_friendly_units, _friendly_index);

		if (instance_exists(_friendly_unit)
			&& variable_instance_exists(_friendly_unit, "summon_nights_remaining"))
		{
			clear_cultist_building_assignment(_friendly_unit);
			array_push(_summoned_units, _friendly_unit);

			if (_friendly_unit.object_index != o_goblin)
			{
				array_push(_outside_units, _friendly_unit);
			}
		}
	}

	var _summoned_count = array_length(_summoned_units);
	var _outside_count = array_length(_outside_units);

	for (var _summoned_index = 0; _summoned_index < _summoned_count; ++_summoned_index)
	{
		var _summoned_unit = _summoned_units[_summoned_index];

		if (!instance_exists(_summoned_unit) || _summoned_unit.object_index != o_goblin)
		{
			continue;
		}

		var _position = cannon_inner_position_get(_summoned_index, _summoned_count);

		_summoned_unit.regroup_is_active = true;
		_summoned_unit.regroup_target_x = _position[0];
		_summoned_unit.regroup_target_y = _position[1];
		_summoned_unit.rally_is_active = false;
		_summoned_unit.rally_is_returning = false;
		_summoned_unit.rally_has_arrived = false;
		_summoned_unit.drag_drop_x = _position[0];
		_summoned_unit.drag_drop_y = _position[1];
	}

	for (var _outside_index = 0; _outside_index < _outside_count; ++_outside_index)
	{
		move_unit_outside_cannon_wall(_outside_units[_outside_index], _outside_index, _outside_count);
	}
};

move_cultists_to_cannon_inner = function()
{
	var _cultist_count = array_length(global.archdemons);

	for (var _cultist_index = 0; _cultist_index < _cultist_count; ++_cultist_index)
	{
		var _cultist = global.archdemons[_cultist_index];

		if (instance_exists(_cultist))
		{
			clear_cultist_building_assignment(_cultist);
			move_unit_to_cannon_inner(_cultist, _cultist_index, _cultist_count);
		}
	}
};

restore_dead_cultists_at_morning = function()
{
	var _cultist_count = array_length(global.archdemons);

	for (var _cultist_index = 0; _cultist_index < _cultist_count; ++_cultist_index)
	{
		var _cultist = global.archdemons[_cultist_index];

		if (!instance_exists(_cultist)
			|| !variable_instance_exists(_cultist, "morning_respawn_pending")
			|| !_cultist.morning_respawn_pending)
		{
			continue;
		}

		var _stamina_max = BALANCE_CULTIST_STAMINA_MAX;

		if (variable_instance_exists(_cultist, "stamina_max"))
		{
			_stamina_max = _cultist.stamina_max;
		}

		cultist_day_health_apply(_cultist, false);
		_cultist.stamina_max = _stamina_max;
		_cultist.hp = _cultist.max_hp * BALANCE_CULTIST_MORNING_RESPAWN_HP_SHARE;
		_cultist.visible = true;
		_cultist.image_alpha = 1;
		_cultist.image_angle = 0;
		_cultist.is_knocked_out = false;
		_cultist.knockout_timer = 0;
		_cultist.morning_respawn_pending = false;
		_cultist.corpse_visual_created = false;
	}
};

clear_dragged_unit = function()
{
	if (is_struct(global.dragged_squad))
	{
		squad_drag_end(global.dragged_squad, false);
	}

	if (instance_exists(global.dragged_cultist))
	{
		global.dragged_cultist.is_being_dragged = false;
	}

	global.dragged_cultist = noone;
	global.cultist_assignment_preview_building = noone;
};

transform_demons_to_archdemons = function()
{
	var _unit_count = array_length(global.archdemons);
	var _new_cultists = array_create(0);

	for (var _unit_index = 0; _unit_index < _unit_count; ++_unit_index)
	{
		var _unit = global.archdemons[_unit_index];

		if (!instance_exists(_unit))
		{
			continue;
		}

		if (_unit.object_index == o_archdemon || !variable_instance_exists(_unit, "demon_type") || _unit.demon_type == DEMON_TYPE.NONE)
		{
			array_push(_new_cultists, _unit);
			continue;
		}

		clear_cultist_building_assignment(_unit);

		global.cultist_sprite_randomization_enabled = false;
		var _cultist = instance_create_layer(_unit.x, _unit.y, "Instances", o_archdemon);
		global.cultist_sprite_randomization_enabled = true;
		var _unit_hp = _unit.hp;
		var _was_dead = _unit_hp <= 0;

		_cultist.cultist_name = _unit.cultist_name;
		_cultist.cultist_points = _unit.cultist_points;
		_cultist.demon_type = _unit.demon_type;
		_cultist.demon_ability = _unit.demon_ability;

		if (variable_instance_exists(_unit, "stamina_amount"))
		{
			_cultist.stamina_amount = _unit.stamina_amount;
		}

		if (variable_instance_exists(_unit, "stamina_max"))
		{
			_cultist.stamina_max = _unit.stamina_max;
		}

		if (variable_instance_exists(_unit, "adaptive_night_hp_start"))
		{
			_cultist.adaptive_night_hp_start = _unit.adaptive_night_hp_start;
		}

		if (variable_instance_exists(_unit, "adaptive_night_damage_taken"))
		{
			_cultist.adaptive_night_damage_taken = _unit.adaptive_night_damage_taken;
		}

		if (variable_instance_exists(_unit, "cultist_sprite_index"))
		{
			_cultist.cultist_sprite_index = _unit.cultist_sprite_index;
			_cultist.sprite_index = _unit.cultist_sprite_index;
		}

		if (variable_instance_exists(_cultist, "archdemon_visual_apply"))
		{
			_cultist.archdemon_visual_apply();
		}

		if (variable_instance_exists(_unit, "cultist_starting_abilities"))
		{
			_cultist.cultist_starting_abilities = _unit.cultist_starting_abilities;
		}

		_cultist.current_exp = _unit.current_exp;
		_cultist.current_lvl = _unit.current_lvl;
		_cultist.pending_level_points = _unit.pending_level_points;
		_cultist.pending_passive_choices = _unit.pending_passive_choices;
		_cultist.pending_active_choices = _unit.pending_active_choices;
		_cultist.pending_ability_upgrade_choices = _unit.pending_ability_upgrade_choices;
		_cultist.passive_choice_options = _unit.passive_choice_options;
		_cultist.active_choice_options = _unit.active_choice_options;
		_cultist.ability_upgrade_choice_options = _unit.ability_upgrade_choice_options;
		_cultist.active_abilities = _unit.active_abilities;
		_cultist.ability_levels = _unit.ability_levels;
		_cultist.has_brute_corpse_eater = _unit.has_brute_corpse_eater;
		_cultist.has_brute_rotten_aura = _unit.has_brute_rotten_aura;
		_cultist.has_brute_blood_anvil = _unit.has_brute_blood_anvil;
		_cultist.has_warlock_soul_harvester = _unit.has_warlock_soul_harvester;
		_cultist.has_warlock_curseweaver = _unit.has_warlock_curseweaver;
		_cultist.has_warlock_demonic_infusion = _unit.has_warlock_demonic_infusion;
		_cultist.hp = _unit_hp;
		cultist_day_health_apply(_cultist, false);
		squad_unit_reference_replace(_unit, _cultist);

		if (_was_dead)
		{
			_cultist.hp = _cultist.max_hp * BALANCE_CULTIST_KNOCKOUT_RECOVERY_HP_SHARE;
			_cultist.is_knocked_out = false;
			_cultist.knockout_timer = 0;
			_cultist.morning_respawn_pending = false;
		}

		array_push(_new_cultists, _cultist);
		instance_destroy(_unit);
	}

	global.archdemons = _new_cultists;
};

cultist_levelup_find_next = function(_start_index)
{
	var _cultist_count = array_length(global.archdemons);

	for (var _cultist_index = max(0, _start_index); _cultist_index < _cultist_count; ++_cultist_index)
	{
		var _cultist = global.archdemons[_cultist_index];

		if (instance_exists(_cultist)
			&& variable_instance_exists(_cultist, "pending_ability_upgrade_choices")
			&& _cultist.pending_ability_upgrade_choices > 0
			&& array_length(cultist_ability_upgrade_options_roll(_cultist)) <= 0)
		{
			_cultist.pending_ability_upgrade_choices = 0;
		}

		if (instance_exists(_cultist)
			&& ((variable_instance_exists(_cultist, "pending_level_points") && _cultist.pending_level_points > 0)
				|| (variable_instance_exists(_cultist, "pending_passive_choices") && _cultist.pending_passive_choices > 0)
				|| (variable_instance_exists(_cultist, "pending_active_choices") && _cultist.pending_active_choices > 0)
				|| (variable_instance_exists(_cultist, "pending_ability_upgrade_choices") && _cultist.pending_ability_upgrade_choices > 0)))
		{
			return _cultist_index;
		}
	}

	return -1;
};

cultist_has_pending_levelup = function(_cultist)
{
	if (!instance_exists(_cultist))
	{
		return false;
	}

	if (variable_instance_exists(_cultist, "pending_ability_upgrade_choices")
		&& _cultist.pending_ability_upgrade_choices > 0
		&& array_length(cultist_ability_upgrade_options_roll(_cultist)) <= 0)
	{
		_cultist.pending_ability_upgrade_choices = 0;
	}

	return (variable_instance_exists(_cultist, "pending_level_points") && _cultist.pending_level_points > 0)
		|| (variable_instance_exists(_cultist, "pending_passive_choices") && _cultist.pending_passive_choices > 0)
		|| (variable_instance_exists(_cultist, "pending_active_choices") && _cultist.pending_active_choices > 0)
		|| (variable_instance_exists(_cultist, "pending_ability_upgrade_choices") && _cultist.pending_ability_upgrade_choices > 0);
};

cultist_levelup_selection_reset = function()
{
	cultist_levelup_selected_stat = -1;
	cultist_levelup_selected_ability = DEMON_ABILITY.NONE;
	cultist_levelup_selected_reward_type = CULTIST_LEVEL_REWARD.ATTRIBUTE;
};

cultist_levelup_close = function()
{
	cultist_levelup_open = false;
	cultist_levelup_index = -1;
	cultist_levelup_selection_reset();
	global.pause = cultist_levelup_previous_pause_state;
	player_pause_active = cultist_levelup_previous_player_pause_state;
	global.focus_window = FOCUS_WINDOW.NOONE;
};

cultist_levelup_has_attribute_choice = function(_cultist)
{
	return instance_exists(_cultist)
		&& variable_instance_exists(_cultist, "pending_level_points")
		&& _cultist.pending_level_points > 0;
};

cultist_levelup_ability_reward_type_get = function(_cultist)
{
	if (!instance_exists(_cultist))
	{
		return -1;
	}

	if (variable_instance_exists(_cultist, "pending_passive_choices")
		&& _cultist.pending_passive_choices > 0)
	{
		return CULTIST_LEVEL_REWARD.PASSIVE;
	}

	if (variable_instance_exists(_cultist, "pending_active_choices")
		&& _cultist.pending_active_choices > 0)
	{
		return CULTIST_LEVEL_REWARD.ACTIVE;
	}

	if (variable_instance_exists(_cultist, "pending_ability_upgrade_choices")
		&& _cultist.pending_ability_upgrade_choices > 0)
	{
		if (array_length(cultist_ability_upgrade_options_roll(_cultist)) > 0)
		{
			return CULTIST_LEVEL_REWARD.ABILITY_UPGRADE;
		}

		_cultist.pending_ability_upgrade_choices = 0;
	}

	return -1;
};

cultist_levelup_ability_options_get = function(_cultist, _reward_type)
{
	if (!instance_exists(_cultist))
	{
		return [];
	}

	if (_reward_type == CULTIST_LEVEL_REWARD.PASSIVE)
	{
		return _cultist.passive_choice_options;
	}

	if (_reward_type == CULTIST_LEVEL_REWARD.ACTIVE)
	{
		return _cultist.active_choice_options;
	}

	if (_reward_type == CULTIST_LEVEL_REWARD.ABILITY_UPGRADE)
	{
		return _cultist.ability_upgrade_choice_options;
	}

	return [];
};

cultist_levelup_confirm_can_apply = function(_cultist)
{
	if (!instance_exists(_cultist))
	{
		return false;
	}

	var _has_attribute_choice = cultist_levelup_has_attribute_choice(_cultist);
	var _ability_reward_type = cultist_levelup_ability_reward_type_get(_cultist);
	var _has_ability_choice = _ability_reward_type != -1;
	var _has_selected_stat = !_has_attribute_choice || cultist_levelup_selected_stat >= 0;
	var _has_selected_ability = !_has_ability_choice
		|| (cultist_levelup_selected_ability != DEMON_ABILITY.NONE
			&& cultist_levelup_selected_reward_type == _ability_reward_type);

	return (_has_attribute_choice || _has_ability_choice)
		&& _has_selected_stat
		&& _has_selected_ability;
};

cultist_levelup_button_rect_get = function(_cultist)
{
	if (!instance_exists(_cultist) || !instance_exists(o_camera_controller))
	{
		return [0, 0, 0, 0];
	}

	var _camera_controller = instance_find(o_camera_controller, 0);
	var _camera_x = camera_get_view_x(_camera_controller.camera_id);
	var _camera_y = camera_get_view_y(_camera_controller.camera_id);
	var _camera_width = camera_get_view_width(_camera_controller.camera_id);
	var _camera_height = camera_get_view_height(_camera_controller.camera_id);
	var _anchor_world_x = _cultist.x;
	var _anchor_world_y = _cultist.bbox_top - cultist_levelup_button_offset_y;
	var _anchor_gui_x = ((_anchor_world_x - _camera_x) / _camera_width) * camera_view_width;
	var _anchor_gui_y = ((_anchor_world_y - _camera_y) / _camera_height) * camera_view_height;
	var _pulse = 1 + (sin(current_time * cultist_levelup_button_pulse_speed) * cultist_levelup_button_pulse_amount);
	var _button_width = cultist_levelup_button_width * _pulse;
	var _button_height = cultist_levelup_button_height * _pulse;
	var _button_x = _anchor_gui_x - (_button_width * 0.5);
	var _button_y = _anchor_gui_y - (_button_height * 0.5);

	return [_button_x, _button_y, _button_width, _button_height];
};

cultist_levelup_button_find_at_gui = function(_mouse_x, _mouse_y)
{
	if (!variable_global_exists("archdemons"))
	{
		return noone;
	}

	var _cultist_count = array_length(global.archdemons);
	var _target_cultist = noone;
	var _target_depth = infinity;

	for (var _cultist_index = 0; _cultist_index < _cultist_count; ++_cultist_index)
	{
		var _cultist = global.archdemons[_cultist_index];

		if (!cultist_has_pending_levelup(_cultist)
			|| (variable_instance_exists(_cultist, "hp") && _cultist.hp <= 0)
			|| (variable_instance_exists(_cultist, "cannon_loading") && _cultist.cannon_loading)
			|| (variable_instance_exists(_cultist, "cannon_loaded") && _cultist.cannon_loaded))
		{
			continue;
		}

		var _button_rect = cultist_levelup_button_rect_get(_cultist);

		if (_mouse_x >= _button_rect[0]
			&& _mouse_x <= _button_rect[0] + _button_rect[2]
			&& _mouse_y >= _button_rect[1]
			&& _mouse_y <= _button_rect[1] + _button_rect[3]
			&& _cultist.depth < _target_depth)
		{
			_target_cultist = _cultist;
			_target_depth = _cultist.depth;
		}
	}

	return _target_cultist;
};

open_cultist_levelup_for_cultist = function(_cultist)
{
	if (!cultist_has_pending_levelup(_cultist))
	{
		return false;
	}

	var _cultist_count = array_length(global.archdemons);

	for (var _cultist_index = 0; _cultist_index < _cultist_count; ++_cultist_index)
	{
		if (global.archdemons[_cultist_index] == _cultist)
		{
			cultist_levelup_open = true;
			cultist_levelup_index = _cultist_index;
			cultist_levelup_selection_reset();
			cultist_levelup_previous_pause_state = global.pause;
			cultist_levelup_previous_player_pause_state = player_pause_active;
			player_pause_active = false;
			global.pause = true;
			global.focus_window = FOCUS_WINDOW.CULTIST_LEVEL_UP;
			global.ui_confirm_sound_play();
			return true;
		}
	}

	return false;
};

open_cultist_levelup = function()
{
	var _next_levelup_index = cultist_levelup_find_next(0);

	if (_next_levelup_index < 0)
	{
		return false;
	}

	cultist_levelup_open = true;
	cultist_levelup_index = _next_levelup_index;
	cultist_levelup_selection_reset();
	cultist_levelup_previous_pause_state = global.pause;
	cultist_levelup_previous_player_pause_state = player_pause_active;
	player_pause_active = false;
	global.pause = true;
	global.focus_window = FOCUS_WINDOW.CULTIST_LEVEL_UP;

	return true;
};

award_cultist_night_exp = function()
{
	var _cultist_count = array_length(global.archdemons);
	var _valid_cultists = [];

	for (var _cultist_index = 0; _cultist_index < _cultist_count; ++_cultist_index)
	{
		var _cultist = global.archdemons[_cultist_index];

		if (instance_exists(_cultist)
			&& variable_instance_exists(_cultist, "current_exp")
			&& variable_instance_exists(_cultist, "current_lvl"))
		{
			array_push(_valid_cultists, _cultist);
		}
	}

	var _full_reward_cultist = noone;
	var _valid_cultist_count = array_length(_valid_cultists);

	if (_valid_cultist_count > 0)
	{
		_full_reward_cultist = _valid_cultists[irandom(_valid_cultist_count - 1)];
	}

	for (var _cultist_index = 0; _cultist_index < _cultist_count; ++_cultist_index)
	{
		var _cultist = global.archdemons[_cultist_index];
		var _exp_reward = BALANCE_CULTIST_NIGHT_EXP_MINOR_REWARD;

		if (_cultist == _full_reward_cultist)
		{
			_exp_reward = BALANCE_CULTIST_NIGHT_EXP_REWARD;
		}

		if (cultist_exp_add(_cultist, _exp_reward))
		{
			ensure_cultist_levelup_options(_cultist);
		}
	}
};

update_summoned_unit_night_life = function()
{
	var _friendly_count = instance_number(o_friendly_units);

	for (var _friendly_index = _friendly_count - 1; _friendly_index >= 0; --_friendly_index)
	{
		var _friendly_unit = instance_find(o_friendly_units, _friendly_index);

		if (instance_exists(_friendly_unit)
			&& variable_instance_exists(_friendly_unit, "summon_nights_remaining"))
		{
			if (variable_instance_exists(_friendly_unit, "settlement_garrison_unit")
				&& _friendly_unit.settlement_garrison_unit)
			{
				continue;
			}

			if (_friendly_unit.object_index == o_goblin)
			{
				continue;
			}

			if (variable_instance_exists(_friendly_unit, "warlock_skeleton_dies_at_morning")
				&& _friendly_unit.warlock_skeleton_dies_at_morning)
			{
				cannon_corpse_worker_drop(_friendly_unit);

				if (variable_instance_exists(_friendly_unit, "unit_corpse_snapshot_create"))
				{
					_friendly_unit.unit_corpse_snapshot_create();
				}

				instance_destroy(_friendly_unit);
				continue;
			}

			_friendly_unit.summon_nights_remaining--;

			if (_friendly_unit.summon_nights_remaining <= 0)
			{
				cannon_corpse_worker_drop(_friendly_unit);

				if (variable_instance_exists(_friendly_unit, "unit_corpse_snapshot_create"))
				{
					_friendly_unit.unit_corpse_snapshot_create();
				}

				instance_destroy(_friendly_unit);
			}
		}
	}
};

settlement_garrison_units_destroy_at_morning = function()
{
	var _friendly_count = instance_number(o_friendly_units);

	for (var _friendly_index = _friendly_count - 1; _friendly_index >= 0; --_friendly_index)
	{
		var _friendly_unit = instance_find(o_friendly_units, _friendly_index);

		if (instance_exists(_friendly_unit)
			&& variable_instance_exists(_friendly_unit, "settlement_garrison_unit")
			&& _friendly_unit.settlement_garrison_unit)
		{
			cannon_corpse_worker_drop(_friendly_unit);
			clear_cultist_building_assignment(_friendly_unit);
			instance_destroy(_friendly_unit);
		}
	}
};

destroyed_house_units_destroy_at_morning = function()
{
	var _enemy_count = instance_number(o_enemy_units);

	for (var _enemy_index = _enemy_count - 1; _enemy_index >= 0; --_enemy_index)
	{
		var _enemy = instance_find(o_enemy_units, _enemy_index);

		if (instance_exists(_enemy)
			&& variable_instance_exists(_enemy, "destroyed_house_unit")
			&& _enemy.destroyed_house_unit)
		{
			instance_destroy(_enemy);
		}
	}
};

settlement_garrison_buildings_spawn_morning_units = function()
{
	with (o_v13buildings_parent)
	{
		if (variable_instance_exists(id, "garrison_morning_spawn_units"))
		{
			garrison_morning_spawn_units();
		}
	}
};

update_goblin_evening_life = function()
{
	var _goblin_count = instance_number(o_goblin);

	for (var _goblin_index = _goblin_count - 1; _goblin_index >= 0; --_goblin_index)
	{
		var _goblin = instance_find(o_goblin, _goblin_index);

		if (!instance_exists(_goblin)
			|| !variable_instance_exists(_goblin, "summon_nights_remaining"))
		{
			continue;
		}

		_goblin.summon_nights_remaining--;

		if (_goblin.summon_nights_remaining <= 0)
		{
			cannon_corpse_worker_drop(_goblin);
			clear_cultist_building_assignment(_goblin);

			if (variable_instance_exists(_goblin, "unit_corpse_snapshot_create"))
			{
				_goblin.unit_corpse_snapshot_create();
			}

			instance_destroy(_goblin);
		}
	}
};

night_attack_total_difficulty_get = function()
{
	var _extra_cultist_count = max(0, array_length(global.archdemons) - BALANCE_STARTING_CULTIST_COUNT);
	var _night_index = max(1, night_attack_night_index);
	var _early_night_count = max(0, min(_night_index - 1, BALANCE_NIGHT_ATTACK_DIFFICULTY_LATE_START_NIGHT - 2));
	var _late_night_count = max(0, _night_index - BALANCE_NIGHT_ATTACK_DIFFICULTY_LATE_START_NIGHT + 1);
	var _captured_shrine_count = shrine_corrupted_count_get();

	var _difficulty = BALANCE_NIGHT_ATTACK_DIFFICULTY_BASE
		+ (_early_night_count * BALANCE_NIGHT_ATTACK_DIFFICULTY_INCREASE_PER_NIGHT)
		+ (_late_night_count * BALANCE_NIGHT_ATTACK_DIFFICULTY_LATE_INCREASE_PER_NIGHT)
		+ (_extra_cultist_count * BALANCE_NIGHT_ATTACK_DIFFICULTY_PER_EXTRA_CULTIST)
		+ (_captured_shrine_count * BALANCE_SHRINE_CAPTURED_NIGHT_DIFFICULTY_BONUS);

	if (full_moon_night_is_scheduled(_night_index))
	{
		_difficulty *= BALANCE_FULL_MOON_DIFFICULTY_MULTIPLIER;
	}

	return _difficulty;
};

night_attack_difficulty_debug_log = function(_total_difficulty, _direction_count, _direction_difficulty)
{
	if (!global.cheats_enabled)
	{
		return;
	}

	var _extra_cultist_count = max(0, array_length(global.archdemons) - BALANCE_STARTING_CULTIST_COUNT);
	var _night_index = max(1, night_attack_night_index);
	var _early_night_count = max(0, min(_night_index - 1, BALANCE_NIGHT_ATTACK_DIFFICULTY_LATE_START_NIGHT - 2));
	var _late_night_count = max(0, _night_index - BALANCE_NIGHT_ATTACK_DIFFICULTY_LATE_START_NIGHT + 1);
	var _base_difficulty = BALANCE_NIGHT_ATTACK_DIFFICULTY_BASE;
	var _early_night_difficulty = _early_night_count * BALANCE_NIGHT_ATTACK_DIFFICULTY_INCREASE_PER_NIGHT;
	var _late_night_difficulty = _late_night_count * BALANCE_NIGHT_ATTACK_DIFFICULTY_LATE_INCREASE_PER_NIGHT;
	var _extra_cultist_difficulty = _extra_cultist_count * BALANCE_NIGHT_ATTACK_DIFFICULTY_PER_EXTRA_CULTIST;
	var _captured_shrine_count = shrine_corrupted_count_get();
	var _captured_shrine_difficulty = _captured_shrine_count * BALANCE_SHRINE_CAPTURED_NIGHT_DIFFICULTY_BONUS;
	var _raw_difficulty = _base_difficulty
		+ _early_night_difficulty
		+ _late_night_difficulty
		+ _extra_cultist_difficulty
		+ _captured_shrine_difficulty;
	var _full_moon_difficulty_multiplier = full_moon_night_is_scheduled(_night_index)
		? BALANCE_FULL_MOON_DIFFICULTY_MULTIPLIER
		: 1;
	var _enemy_hp_multiplier = enemy_night_hp_multiplier_get();
	var _enemy_hp_night_multiplier = 1 + (_night_index - 1) * BALANCE_ENEMY_HP_INCREASE_PER_NIGHT;

	var _difficulty_text = "[Night Difficulty] Night " + string(_night_index)
		+ "\n  Base: +" + string_format(_base_difficulty, 0, 2)
		+ "\n  Early nights: +" + string_format(_early_night_difficulty, 0, 2)
		+ " (" + string(_early_night_count) + " x " + string_format(BALANCE_NIGHT_ATTACK_DIFFICULTY_INCREASE_PER_NIGHT, 0, 2) + ")"
		+ "\n  Late nights: +" + string_format(_late_night_difficulty, 0, 2)
		+ " (" + string(_late_night_count) + " x " + string_format(BALANCE_NIGHT_ATTACK_DIFFICULTY_LATE_INCREASE_PER_NIGHT, 0, 2) + ")"
		+ "\n  Extra cultists: +" + string_format(_extra_cultist_difficulty, 0, 2)
		+ " (" + string(_extra_cultist_count) + " x " + string_format(BALANCE_NIGHT_ATTACK_DIFFICULTY_PER_EXTRA_CULTIST, 0, 2) + ")"
		+ "\n  Captured shrines: +" + string_format(_captured_shrine_difficulty, 0, 2)
		+ " (" + string(_captured_shrine_count) + " x " + string_format(BALANCE_SHRINE_CAPTURED_NIGHT_DIFFICULTY_BONUS, 0, 2) + ")"
		+ "\n  Adaptive unit-count modifier: none"
		+ "\n  Full moon multiplier: x" + string_format(_full_moon_difficulty_multiplier, 0, 2)
		+ "\n  Raw difficulty: " + string_format(_raw_difficulty, 0, 2);

	_difficulty_text += "\n  Total difficulty: " + string_format(_total_difficulty, 0, 2)
		+ "\n  Directions: " + string(_direction_count)
		+ "\n  Difficulty per direction: " + string_format(_direction_difficulty, 0, 2)
		+ " (cap " + string_format(BALANCE_NIGHT_ATTACK_DIRECTION_DIFFICULTY_MAX * _full_moon_difficulty_multiplier, 0, 2) + ")"
		+ "\n  Enemy HP night multiplier: x" + string_format(_enemy_hp_night_multiplier, 0, 2);

	if (BALANCE_ADAPTIVE_DIFFICULTY_ENABLED)
	{
		_difficulty_text += "\n  Enemy HP adaptive multiplier: x" + string_format(adaptive_difficulty_multiplier, 0, 2);
	}
	else
	{
		_difficulty_text += "\n  Enemy HP adaptive multiplier: disabled";
	}

	_difficulty_text += "\n  Enemy HP total multiplier: x" + string_format(_enemy_hp_multiplier, 0, 2);

	show_debug_message(_difficulty_text);
};

adaptive_difficulty_low_hp_cultist_count_get = function()
{
	var _low_hp_count = 0;
	var _cultist_count = array_length(global.archdemons);

	for (var _cultist_index = 0; _cultist_index < _cultist_count; ++_cultist_index)
	{
		var _cultist = global.archdemons[_cultist_index];

		if (!instance_exists(_cultist)
			|| !variable_instance_exists(_cultist, "hp")
			|| !variable_instance_exists(_cultist, "max_hp")
			|| _cultist.max_hp <= 0)
		{
			continue;
		}

		if (_cultist.hp / _cultist.max_hp < BALANCE_ADAPTIVE_DIFFICULTY_CULTIST_LOW_HP_SHARE)
		{
			_low_hp_count++;
		}
	}

	return _low_hp_count;
};

adaptive_difficulty_night_hp_start_store = function()
{
	adaptive_night_tracked_cultist_count = 0;
	var _cultist_count = array_length(global.archdemons);

	for (var _cultist_index = 0; _cultist_index < _cultist_count; ++_cultist_index)
	{
		var _cultist = global.archdemons[_cultist_index];

		if (!instance_exists(_cultist)
			|| !variable_instance_exists(_cultist, "hp")
			|| !variable_instance_exists(_cultist, "demon_type")
			|| _cultist.demon_type == DEMON_TYPE.NONE)
		{
			continue;
		}

		_cultist.adaptive_night_hp_start = max(0, _cultist.hp);
		_cultist.adaptive_night_damage_taken = 0;
		adaptive_night_tracked_cultist_count++;
	}
};

adaptive_difficulty_heavy_damage_cultist_count_get = function()
{
	var _heavy_damage_count = 0;
	var _cultist_count = array_length(global.archdemons);

	for (var _cultist_index = 0; _cultist_index < _cultist_count; ++_cultist_index)
	{
		var _cultist = global.archdemons[_cultist_index];

		if (!instance_exists(_cultist)
			|| !variable_instance_exists(_cultist, "hp")
			|| !variable_instance_exists(_cultist, "adaptive_night_hp_start"))
		{
			continue;
		}

		var _hp_start = _cultist.adaptive_night_hp_start;

		if (_hp_start <= 0)
		{
			continue;
		}

		var _damage_taken = max(0, _hp_start - _cultist.hp);

		if (variable_instance_exists(_cultist, "adaptive_night_damage_taken"))
		{
			_damage_taken = max(_damage_taken, _cultist.adaptive_night_damage_taken);
		}

		var _hp_loss_share = _damage_taken / _hp_start;

		if (_hp_loss_share > BALANCE_ADAPTIVE_DIFFICULTY_CULTIST_HEAVY_HP_LOSS_SHARE)
		{
			_heavy_damage_count++;
		}
	}

	return _heavy_damage_count;
};

adaptive_difficulty_evaluate_night = function()
{
	if (!BALANCE_ADAPTIVE_DIFFICULTY_ENABLED)
	{
		return;
	}

	var _difficulty_delta = 0;
	var _cannon_hp_loss_share = 0;
	var _debug_delta_lines = [];

	if (instance_exists(o_cannon))
	{
		var _cannon = instance_find(o_cannon, 0);
		var _cannon_hp_start = adaptive_night_cannon_hp_start;

		if (_cannon_hp_start <= 0 && variable_instance_exists(_cannon, "max_hp"))
		{
			_cannon_hp_start = _cannon.max_hp;
		}

		_cannon_hp_loss_share = max(0, _cannon_hp_start - _cannon.hp) / max(1, _cannon_hp_start);

		if (_cannon_hp_loss_share <= 0)
		{
			_difficulty_delta += BALANCE_ADAPTIVE_DIFFICULTY_EASY_INCREASE;
			array_push(_debug_delta_lines, "Cannon took no damage: +" + string_format(BALANCE_ADAPTIVE_DIFFICULTY_EASY_INCREASE, 0, 2));
		}
		else if (_cannon_hp_loss_share > BALANCE_ADAPTIVE_DIFFICULTY_CANNON_HARD_HP_LOSS_SHARE)
		{
			_difficulty_delta -= BALANCE_ADAPTIVE_DIFFICULTY_HARD_DECREASE;
			array_push(_debug_delta_lines, "Cannon lost " + string_format(_cannon_hp_loss_share * 100, 0, 1) + "% HP: -" + string_format(BALANCE_ADAPTIVE_DIFFICULTY_HARD_DECREASE, 0, 2));
		}
		else
		{
			_difficulty_delta += BALANCE_ADAPTIVE_DIFFICULTY_NORMAL_INCREASE;
			array_push(_debug_delta_lines, "Cannon damage was moderate: +" + string_format(BALANCE_ADAPTIVE_DIFFICULTY_NORMAL_INCREASE, 0, 2));
		}
	}

	var _low_hp_cultist_count = adaptive_difficulty_low_hp_cultist_count_get();

	if (_low_hp_cultist_count <= 0)
	{
		_difficulty_delta += BALANCE_ADAPTIVE_DIFFICULTY_EASY_INCREASE;
		array_push(_debug_delta_lines, "No low HP cultists: +" + string_format(BALANCE_ADAPTIVE_DIFFICULTY_EASY_INCREASE, 0, 2));
	}
	else if (_low_hp_cultist_count > BALANCE_ADAPTIVE_DIFFICULTY_CULTIST_NORMAL_LOW_HP_MAX)
	{
		_difficulty_delta -= BALANCE_ADAPTIVE_DIFFICULTY_HARD_DECREASE;
		array_push(_debug_delta_lines, string(_low_hp_cultist_count) + " low HP cultists: -" + string_format(BALANCE_ADAPTIVE_DIFFICULTY_HARD_DECREASE, 0, 2));
	}
	else
	{
		_difficulty_delta += BALANCE_ADAPTIVE_DIFFICULTY_NORMAL_INCREASE;
		array_push(_debug_delta_lines, string(_low_hp_cultist_count) + " low HP cultists: +" + string_format(BALANCE_ADAPTIVE_DIFFICULTY_NORMAL_INCREASE, 0, 2));
	}

	var _heavy_damage_cultist_count = adaptive_difficulty_heavy_damage_cultist_count_get();

	if (adaptive_night_tracked_cultist_count > 0 && _heavy_damage_cultist_count <= 0)
	{
		_difficulty_delta += BALANCE_ADAPTIVE_DIFFICULTY_NO_HEAVY_CULTIST_DAMAGE_INCREASE;
		array_push(_debug_delta_lines, "No heavy cultist damage: +" + string_format(BALANCE_ADAPTIVE_DIFFICULTY_NO_HEAVY_CULTIST_DAMAGE_INCREASE, 0, 2));
	}

	var _difficulty_delta_before_knockout_cap = _difficulty_delta;

	// A knockout means the previous night was already punishing enough.
	if (adaptive_night_cultist_knocked_out && _difficulty_delta > BALANCE_ADAPTIVE_DIFFICULTY_KNOCKOUT_MAX_INCREASE)
	{
		_difficulty_delta = BALANCE_ADAPTIVE_DIFFICULTY_KNOCKOUT_MAX_INCREASE;
		array_push(
			_debug_delta_lines,
			"Cultist knockout cap: "
				+ string_format(_difficulty_delta_before_knockout_cap, 0, 2)
				+ " -> "
				+ string_format(BALANCE_ADAPTIVE_DIFFICULTY_KNOCKOUT_MAX_INCREASE, 0, 2)
		);
	}

	var _adaptive_difficulty_multiplier_before = adaptive_difficulty_multiplier;

	adaptive_difficulty_multiplier = clamp(
		adaptive_difficulty_multiplier + _difficulty_delta,
		BALANCE_ADAPTIVE_DIFFICULTY_MIN_MULTIPLIER,
		BALANCE_ADAPTIVE_DIFFICULTY_MAX_MULTIPLIER
	);
	adaptive_last_night_cannon_hp_loss_share = _cannon_hp_loss_share;
	adaptive_last_night_low_hp_cultists = _low_hp_cultist_count;
	adaptive_last_night_heavy_damage_cultists = _heavy_damage_cultist_count;
	adaptive_last_night_cultist_knocked_out = adaptive_night_cultist_knocked_out;
	adaptive_last_night_delta = _difficulty_delta;

	if (global.cheats_enabled)
	{
		var _debug_text = "[Adaptive Difficulty] Previous night result"
			+ "\n  Cannon HP loss: " + string_format(_cannon_hp_loss_share * 100, 0, 1) + "%"
			+ "\n  Low HP cultists: " + string(_low_hp_cultist_count)
			+ "\n  Heavy damage cultists: " + string(_heavy_damage_cultist_count)
			+ "\n  Cultist knocked out: " + string(adaptive_night_cultist_knocked_out);
		var _debug_line_count = array_length(_debug_delta_lines);

		for (var _debug_line_index = 0; _debug_line_index < _debug_line_count; ++_debug_line_index)
		{
			_debug_text += "\n  " + _debug_delta_lines[_debug_line_index];
		}

		_debug_text += "\n  Total multiplier delta: " + string_format(_difficulty_delta, 0, 2)
			+ "\n  Multiplier: "
			+ string_format(_adaptive_difficulty_multiplier_before, 0, 2)
			+ " -> "
			+ string_format(adaptive_difficulty_multiplier, 0, 2);

		show_debug_message(_debug_text);
	}
};

enemy_night_hp_multiplier_get = function()
{
	var _night_hp_multiplier = 1 + (max(1, night_attack_night_index) - 1) * BALANCE_ENEMY_HP_INCREASE_PER_NIGHT;

	if (BALANCE_ADAPTIVE_DIFFICULTY_ENABLED)
	{
		_night_hp_multiplier *= adaptive_difficulty_multiplier;
	}

	return _night_hp_multiplier;
};

enemy_night_hp_scale_apply = function(_enemy)
{
	if (!instance_exists(_enemy)
		|| !variable_instance_exists(_enemy, "max_hp")
		|| !variable_instance_exists(_enemy, "hp"))
	{
		return;
	}

	if (global.ritual_rust_righteous_active
		&& variable_instance_exists(_enemy, "armor")
		&& !variable_instance_exists(_enemy, "ritual_armor_reduction_applied"))
	{
		_enemy.armor = max(0, _enemy.armor - BALANCE_RITUAL_ENEMY_ARMOR_REDUCTION);
		_enemy.ritual_armor_reduction_applied = true;
	}

	if (global.ritual_silence_choir_active
		&& variable_instance_exists(_enemy, "magic_resistance")
		&& !variable_instance_exists(_enemy, "ritual_magic_resistance_reduction_applied"))
	{
		_enemy.magic_resistance = max(
			0,
			_enemy.magic_resistance - BALANCE_RITUAL_ENEMY_MAGIC_RESISTANCE_REDUCTION
		);
		_enemy.ritual_magic_resistance_reduction_applied = true;
	}

	var _scale_index = max(1, night_attack_night_index);

	if (variable_instance_exists(_enemy, "night_hp_scale_index_applied")
		&& _enemy.night_hp_scale_index_applied >= _scale_index)
	{
		return;
	}

	var _hp_share = _enemy.hp / max(1, _enemy.max_hp);

	if (!variable_instance_exists(_enemy, "base_max_hp"))
	{
		_enemy.base_max_hp = _enemy.max_hp;
	}

	_enemy.max_hp = _enemy.base_max_hp * enemy_night_hp_multiplier_get();
	_enemy.hp = clamp(_enemy.max_hp * _hp_share, 0, _enemy.max_hp);
	_enemy.night_hp_scale_index_applied = _scale_index;
};

enemy_object_name_get = function(_enemy_object)
{
	if (_enemy_object == o_enemy_peasant)
	{
		return "Peasant";
	}
	else if (_enemy_object == o_enemy_archer)
	{
		return "Archer";
	}
	else if (_enemy_object == o_enemy_knight)
	{
		return "Knight";
	}
	else if (_enemy_object == o_enemy_mage)
	{
		return "Mage";
	}
	else if (_enemy_object == o_enemy_catapult)
	{
		return "Holy Catapult";
	}
	else if (_enemy_object == o_crusader)
	{
		return "Crusader";
	}
	else if (_enemy_object == o_boss_griffith)
	{
		return "Griffith";
	}

	return object_get_name(_enemy_object);
};

enemy_object_stats_get = function(_enemy_object)
{
	var _stats = {
		hp: BALANCE_ENEMY_PEASANT_HP,
		armor: BALANCE_ENEMY_PEASANT_ARMOR,
		magic_resistance: BALANCE_ENEMY_PEASANT_MAGIC_RESISTANCE,
		damage: BALANCE_ENEMY_PEASANT_DAMAGE,
		magic_damage: BALANCE_ENEMY_PEASANT_MAGIC_DAMAGE,
		reload_time: BALANCE_ENEMY_PEASANT_RELOAD_TIME * room_speed,
		attack_radius: BALANCE_ENEMY_PEASANT_ATTACK_RADIUS,
		move_speed: BALANCE_ENEMY_PEASANT_MOVE_SPEED
	};

	if (_enemy_object == o_enemy_archer)
	{
		_stats.hp = BALANCE_ENEMY_ARCHER_HP;
		_stats.armor = BALANCE_ENEMY_ARCHER_ARMOR;
		_stats.magic_resistance = BALANCE_ENEMY_ARCHER_MAGIC_RESISTANCE;
		_stats.damage = BALANCE_ENEMY_ARCHER_DAMAGE;
		_stats.magic_damage = BALANCE_ENEMY_ARCHER_MAGIC_DAMAGE;
		_stats.reload_time = BALANCE_ENEMY_ARCHER_RELOAD_TIME * room_speed;
		_stats.attack_radius = BALANCE_ENEMY_ARCHER_ATTACK_RADIUS;
		_stats.move_speed = BALANCE_ENEMY_ARCHER_MOVE_SPEED;
	}
	else if (_enemy_object == o_enemy_knight)
	{
		_stats.hp = BALANCE_ENEMY_KNIGHT_HP;
		_stats.armor = BALANCE_ENEMY_KNIGHT_ARMOR;
		_stats.magic_resistance = BALANCE_ENEMY_KNIGHT_MAGIC_RESISTANCE;
		_stats.damage = BALANCE_ENEMY_KNIGHT_DAMAGE;
		_stats.magic_damage = BALANCE_ENEMY_KNIGHT_MAGIC_DAMAGE;
		_stats.reload_time = BALANCE_ENEMY_KNIGHT_RELOAD_TIME * room_speed;
		_stats.attack_radius = BALANCE_ENEMY_KNIGHT_ATTACK_RADIUS;
		_stats.move_speed = BALANCE_ENEMY_KNIGHT_MOVE_SPEED;
	}
	else if (_enemy_object == o_enemy_mage)
	{
		_stats.hp = BALANCE_ENEMY_MAGE_HP;
		_stats.armor = BALANCE_ENEMY_MAGE_ARMOR;
		_stats.magic_resistance = BALANCE_ENEMY_MAGE_MAGIC_RESISTANCE;
		_stats.damage = BALANCE_ENEMY_MAGE_DAMAGE;
		_stats.magic_damage = BALANCE_ENEMY_MAGE_MAGIC_DAMAGE;
		_stats.reload_time = BALANCE_ENEMY_MAGE_RELOAD_TIME * room_speed;
		_stats.attack_radius = BALANCE_ENEMY_MAGE_ATTACK_RADIUS;
		_stats.move_speed = BALANCE_ENEMY_MAGE_MOVE_SPEED;
	}
	else if (_enemy_object == o_enemy_catapult)
	{
		_stats.hp = BALANCE_ENEMY_CATAPULT_HP;
		_stats.armor = BALANCE_ENEMY_CATAPULT_ARMOR;
		_stats.magic_resistance = BALANCE_ENEMY_CATAPULT_MAGIC_RESISTANCE;
		_stats.damage = BALANCE_ENEMY_CATAPULT_DAMAGE;
		_stats.magic_damage = BALANCE_ENEMY_CATAPULT_MAGIC_DAMAGE;
		_stats.reload_time = BALANCE_ENEMY_CATAPULT_RELOAD_TIME * room_speed;
		_stats.attack_radius = BALANCE_ENEMY_CATAPULT_ATTACK_RADIUS;
		_stats.move_speed = BALANCE_ENEMY_CATAPULT_MOVE_SPEED;
	}
	else if (_enemy_object == o_crusader)
	{
		_stats.hp = BALANCE_CRUSADER_HP;
		_stats.armor = BALANCE_CRUSADER_ARMOR;
		_stats.magic_resistance = BALANCE_CRUSADER_MAGIC_RESISTANCE;
		_stats.damage = BALANCE_CRUSADER_DAMAGE;
		_stats.magic_damage = BALANCE_CRUSADER_MAGIC_DAMAGE;
		_stats.reload_time = BALANCE_CRUSADER_RELOAD_TIME * room_speed;
		_stats.attack_radius = BALANCE_CRUSADER_ATTACK_RADIUS;
		_stats.move_speed = BALANCE_CRUSADER_MOVE_SPEED;
	}
	else if (_enemy_object == o_boss_griffith)
	{
		_stats.hp = BALANCE_BOSS_GRIFFITH_HP;
		_stats.armor = BALANCE_BOSS_GRIFFITH_ARMOR;
		_stats.magic_resistance = BALANCE_BOSS_GRIFFITH_MAGIC_RESISTANCE;
		_stats.damage = BALANCE_BOSS_GRIFFITH_DAMAGE * 0.5;
		_stats.magic_damage = BALANCE_BOSS_GRIFFITH_DAMAGE * 0.5;
		_stats.reload_time = BALANCE_BOSS_GRIFFITH_RELOAD_TIME * room_speed;
		_stats.attack_radius = BALANCE_BOSS_GRIFFITH_ATTACK_RADIUS;
		_stats.move_speed = BALANCE_BOSS_GRIFFITH_MOVE_SPEED;
	}

	_stats.hp *= enemy_night_hp_multiplier_get();
	return _stats;
};

enemy_object_stats_card_draw = function(_enemy_object, _hover_x, _hover_y)
{
	var _stats = enemy_object_stats_get(_enemy_object);
	var _strong_against = [];
	var _weak_against = [];

	// Mirror the same matchup relationships shown when hovering units in the world.
	if (_enemy_object == o_enemy_peasant)
	{
		_strong_against = [o_skeleton_mage, o_succubus];
		_weak_against = [o_skeleton_warrior, o_balgor];
	}
	else if (_enemy_object == o_enemy_archer)
	{
		_strong_against = [o_balgor];
		_weak_against = [o_skeleton_archer, o_pitling, o_succubus];
	}
	else if (_enemy_object == o_enemy_knight)
	{
		_strong_against = [o_skeleton_archer];
		_weak_against = [o_skeleton_mage, o_succubus, o_balgor];
	}
	else if (_enemy_object == o_enemy_mage)
	{
		_strong_against = [o_skeleton_warrior, o_pitling, o_balgor];
		_weak_against = [o_skeleton_archer, o_skeleton_mage];
	}
	else if (_enemy_object == o_enemy_catapult)
	{
		_strong_against = [o_skeleton_archer, o_skeleton_mage];
		_weak_against = [o_skeleton_warrior, o_balgor];
	}

	var _strong_count = array_length(_strong_against);
	var _weak_count = array_length(_weak_against);
	var _matchup_row_count = (_strong_count > 0 ? 1 : 0) + (_weak_count > 0 ? 1 : 0);
	var _hover_width = 260;
	var _hover_height = 208 + (_matchup_row_count * 48) + (_matchup_row_count > 0 ? 12 : 0);
	var _hover_padding = 14;
	var _line_y = 42;
	var _damage_text = "Damage: " + string_format(_stats.damage, 0, 1);
	var _attack_speed = room_speed / max(_stats.reload_time, 1);

	if (_stats.magic_damage > 0)
	{
		_damage_text = "Magic damage: " + string_format(_stats.magic_damage, 0, 1);
	}

	if (_stats.damage > 0 && _stats.magic_damage > 0)
	{
		_damage_text = "Damage: " + string_format(_stats.damage, 0, 1)
			+ " physical + " + string_format(_stats.magic_damage, 0, 1)
			+ " magic";
	}

	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_alpha(0.96);
	draw_set_color(COLOR_HUD_BACKGROUND);
	draw_rectangle(_hover_x, _hover_y, _hover_x + _hover_width, _hover_y + _hover_height, false);
	draw_set_alpha(1);
	draw_set_color(COLOR_DAMAGE_ENEMY);
	draw_rectangle(_hover_x, _hover_y, _hover_x + _hover_width, _hover_y + _hover_height, true);

	draw_set_color(COLOR_HUD_TEXT);
	draw_text(_hover_x + _hover_padding, _hover_y + _hover_padding, enemy_object_name_get(_enemy_object));
	draw_text(_hover_x + _hover_padding, _hover_y + _line_y, "HP: " + string_format(_stats.hp, 0, 1));
	_line_y += 20;
	draw_text(_hover_x + _hover_padding, _hover_y + _line_y, _damage_text);
	_line_y += 20;
	draw_text(_hover_x + _hover_padding, _hover_y + _line_y, "Attack speed: " + string_format(_attack_speed, 0, 2));
	_line_y += 20;
	draw_text(_hover_x + _hover_padding, _hover_y + _line_y, "Attack radius: " + string_format(_stats.attack_radius, 0, 0));
	_line_y += 20;
	draw_text(_hover_x + _hover_padding, _hover_y + _line_y, "Move speed: " + string_format(_stats.move_speed, 0, 2));
	_line_y += 20;
	draw_text(_hover_x + _hover_padding, _hover_y + _line_y, "Armor: " + string_format(_stats.armor - 100, 0, 1) + "%");
	_line_y += 20;
	draw_text(_hover_x + _hover_padding, _hover_y + _line_y, "Magic resistance: " + string_format(_stats.magic_resistance - 100, 0, 1) + "%");
	_line_y += 30;

	// Draw player-unit portraits on green and red matchup circles.
	var _matchup_icon_start_x = _hover_x + 126;
	var _matchup_icon_gap = 42;
	var _matchup_icon_radius = 18;
	var _matchup_sprite_size = 28;

	if (_strong_count > 0)
	{
		draw_set_color(COLOR_PROJECTILE_SUMMON);
		draw_text(_hover_x + _hover_padding, _hover_y + _line_y + 8, "Strong vs");

		for (var _strong_index = 0; _strong_index < _strong_count; ++_strong_index)
		{
			var _strong_object = _strong_against[_strong_index];
			var _strong_sprite = object_get_sprite(_strong_object);
			var _strong_x = _matchup_icon_start_x + (_matchup_icon_gap * _strong_index);
			var _strong_y = _hover_y + _line_y + _matchup_icon_radius;

			draw_set_alpha(0.9);
			draw_set_color(COLOR_PROJECTILE_SUMMON);
			draw_circle(_strong_x, _strong_y, _matchup_icon_radius, false);
			draw_set_alpha(1);
			draw_set_color(c_white);
			draw_circle(_strong_x, _strong_y, _matchup_icon_radius, true);

			if (_strong_sprite != -1)
			{
				var _strong_sprite_width = max(1, sprite_get_width(_strong_sprite));
				var _strong_sprite_height = max(1, sprite_get_height(_strong_sprite));
				var _strong_sprite_scale = min(_matchup_sprite_size / _strong_sprite_width, _matchup_sprite_size / _strong_sprite_height);
				var _strong_draw_x = _strong_x + ((sprite_get_xoffset(_strong_sprite) - (_strong_sprite_width * 0.5)) * _strong_sprite_scale);
				var _strong_draw_y = _strong_y + ((sprite_get_yoffset(_strong_sprite) - (_strong_sprite_height * 0.5)) * _strong_sprite_scale);

				draw_sprite_ext(_strong_sprite, 0, _strong_draw_x, _strong_draw_y, _strong_sprite_scale, _strong_sprite_scale, 0, c_white, 1);
			}
		}

		_line_y += 48;
	}

	if (_weak_count > 0)
	{
		draw_set_color(COLOR_STATUS_NEGATIVE_RED);
		draw_text(_hover_x + _hover_padding, _hover_y + _line_y + 8, "Weak vs");

		for (var _weak_index = 0; _weak_index < _weak_count; ++_weak_index)
		{
			var _weak_object = _weak_against[_weak_index];
			var _weak_sprite = object_get_sprite(_weak_object);
			var _weak_x = _matchup_icon_start_x + (_matchup_icon_gap * _weak_index);
			var _weak_y = _hover_y + _line_y + _matchup_icon_radius;

			draw_set_alpha(0.9);
			draw_set_color(COLOR_STATUS_NEGATIVE_RED);
			draw_circle(_weak_x, _weak_y, _matchup_icon_radius, false);
			draw_set_alpha(1);
			draw_set_color(c_white);
			draw_circle(_weak_x, _weak_y, _matchup_icon_radius, true);

			if (_weak_sprite != -1)
			{
				var _weak_sprite_width = max(1, sprite_get_width(_weak_sprite));
				var _weak_sprite_height = max(1, sprite_get_height(_weak_sprite));
				var _weak_sprite_scale = min(_matchup_sprite_size / _weak_sprite_width, _matchup_sprite_size / _weak_sprite_height);
				var _weak_draw_x = _weak_x + ((sprite_get_xoffset(_weak_sprite) - (_weak_sprite_width * 0.5)) * _weak_sprite_scale);
				var _weak_draw_y = _weak_y + ((sprite_get_yoffset(_weak_sprite) - (_weak_sprite_height * 0.5)) * _weak_sprite_scale);

				draw_sprite_ext(_weak_sprite, 0, _weak_draw_x, _weak_draw_y, _weak_sprite_scale, _weak_sprite_scale, 0, c_white, 1);
			}
		}
	}

	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
	draw_set_alpha(1);
};

cultist_stats_card_draw = function(_cultist, _hover_x, _hover_y)
{
	if (!instance_exists(_cultist)
		|| !variable_instance_exists(_cultist, "cultist_points")
		|| !variable_instance_exists(_cultist, "demon_type"))
	{
		return;
	}

	var _hover_width = min(300, display_get_gui_width() - 36);
	var _hover_height = 570;
	var _hover_padding = 14;
	var _ability_width = _hover_width - (_hover_padding * 2);
	var _points = _cultist.cultist_points;
	var _demon_type = _cultist.demon_type;
	var _base_stats = cultist_base_stats_get(_demon_type);
	var _demon_stats = cultist_calculated_stats_get(_demon_type, _points);
	var _display_name = _cultist.cultist_name;
	var _abilities_text = cultist_owned_abilities_text_get(_cultist);
	var _body_points = _points[CULTIST_STAT.BODY];
	var _spirit_points = _points[CULTIST_STAT.SPIRIT];
	var _fervor_points = _points[CULTIST_STAT.FERVOR];
	var _current_level = _cultist.current_lvl;
	var _current_exp = _cultist.current_exp;
	var _required_exp = cultist_level_exp_required_get(_current_level);
	var _exp_progress = clamp(_current_exp / max(1, _required_exp), 0, 1);
	var _exp_bar_width = 180;
	var _exp_bar_height = 5;
	var _exp_bar_x = _hover_x + _hover_padding;
	var _exp_bar_y = _hover_y + 60;
	var _level_text = "Level: " + string(_current_level)
		+ " (" + string_format(_current_exp, 0, 0)
		+ "/" + string_format(_required_exp, 0, 0) + " exp)";

	if (_display_name == "")
	{
		_display_name = "Unnamed";
	}

	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_alpha(0.96);
	draw_set_color(COLOR_HUD_BACKGROUND);
	draw_rectangle(_hover_x, _hover_y, _hover_x + _hover_width, _hover_y + _hover_height, false);
	draw_set_alpha(1);
	draw_set_color(COLOR_CULTIST_FERVOR);
	draw_rectangle(_hover_x, _hover_y, _hover_x + _hover_width, _hover_y + _hover_height, true);

	draw_set_color(COLOR_HUD_TEXT);
	draw_text(_hover_x + _hover_padding, _hover_y + _hover_padding, _display_name);
	draw_text(_hover_x + _hover_padding, _hover_y + 38, _level_text);

	draw_set_alpha(0.75);
	draw_set_color(c_black);
	draw_rectangle(_exp_bar_x, _exp_bar_y, _exp_bar_x + _exp_bar_width, _exp_bar_y + _exp_bar_height, false);
	draw_set_alpha(1);
	draw_set_color(COLOR_HEALTH_BAR);
	draw_rectangle(_exp_bar_x, _exp_bar_y, _exp_bar_x + (_exp_bar_width * _exp_progress), _exp_bar_y + _exp_bar_height, false);

	draw_set_color(COLOR_HUD_PROJECTILE_DESCRIPTION);
	draw_text(_hover_x + _hover_padding, _hover_y + 78, "Demon: " + cultist_demon_name_get(_demon_type));

	var _attribute_names = ["Body", "Spirit", "Fervor"];
	var _attribute_points = [_body_points, _spirit_points, _fervor_points];
	var _attribute_colors = [COLOR_CULTIST_BODY, COLOR_CULTIST_SPIRIT, COLOR_CULTIST_FERVOR];
	var _attribute_stat_order = [CULTIST_STAT.BODY, CULTIST_STAT.FERVOR, CULTIST_STAT.SPIRIT];
	var _attribute_x = _hover_x + _hover_padding;
	var _attribute_y = _hover_y + 112;
	var _attribute_gap = 24;
	var _box_size = 8;
	var _box_gap = 4;
	var _attribute_count = array_length(_attribute_stat_order);

	for (var _attribute_index = 0; _attribute_index < _attribute_count; ++_attribute_index)
	{
		var _attribute_stat = _attribute_stat_order[_attribute_index];
		var _draw_y = _attribute_y + (_attribute_gap * _attribute_index);

		draw_set_color(_attribute_colors[_attribute_stat]);
		draw_text(_attribute_x, _draw_y, _attribute_names[_attribute_stat]);

		for (var _point_index = 0; _point_index < _attribute_points[_attribute_stat]; ++_point_index)
		{
			var _box_x = _attribute_x + 68 + ((_box_size + _box_gap) * _point_index);
			var _box_y = _draw_y + 4;

			draw_rectangle(_box_x, _box_y, _box_x + _box_size, _box_y + _box_size, false);
		}
	}

	var _stats_x = _hover_x + _hover_padding;
	var _stats_y = _hover_y + 194;
	var _line_height = 18;
	var _stat_line_index = 0;
	var _hp_text = "HP: " + string_format(_demon_stats.hp, 0, 1);
	var _hp_bonus = _base_stats.hp * (_body_points * BALANCE_CULTIST_BODY_STAT_BONUS);
	var _armor_bonus = _base_stats.armor * (_body_points * BALANCE_CULTIST_BODY_STAT_BONUS);
	var _damage_bonus = _base_stats.damage * (_body_points * BALANCE_CULTIST_BODY_STAT_BONUS);
	var _magic_damage_bonus = _base_stats.magic_damage * (_spirit_points * BALANCE_CULTIST_MAGIC_DAMAGE_STAT_BONUS);
	var _crit_damage_bonus = _body_points * BALANCE_CULTIST_CRIT_DAMAGE_PER_BODY;
	var _crit_bonus = _base_stats.crit_chance * (_fervor_points * BALANCE_CULTIST_CRIT_CHANCE_STAT_BONUS);
	var _attack_speed_bonus = _base_stats.attack_speed * (_fervor_points * BALANCE_CULTIST_FERVOR_STAT_BONUS);
	var _move_speed_bonus = _base_stats.move_speed * (_fervor_points * BALANCE_CULTIST_FERVOR_STAT_BONUS);
	var _shown_attack_speed = _demon_stats.attack_speed;
	var _has_demonic_infusion = variable_instance_exists(_cultist, "demonic_infusion_timer")
		&& _cultist.demonic_infusion_timer > 0;

	if (_has_demonic_infusion && variable_instance_exists(_cultist, "effective_attack_speed_get"))
	{
		_shown_attack_speed = _cultist.effective_attack_speed_get();
	}

	var _cooldown_bonus = _base_stats.abilities_cd_spd * (_spirit_points * BALANCE_CULTIST_SPIRIT_STAT_BONUS);
	var _exp_bonus = _base_stats.exp_effectiveness * (_spirit_points * BALANCE_CULTIST_SPIRIT_STAT_BONUS);
	var _magic_bonus = _base_stats.magic_effectiveness * (_spirit_points * BALANCE_CULTIST_SPIRIT_STAT_BONUS);
	var _resistance_bonus = _base_stats.resistance * (_spirit_points * BALANCE_CULTIST_SPIRIT_STAT_BONUS);

	if (variable_instance_exists(_cultist, "hp"))
	{
		_hp_text = "HP: " + string_format(_cultist.hp, 0, 1) + " / " + string_format(_cultist.max_hp, 0, 1);
	}

	draw_set_color(COLOR_CULTIST_BODY);
	draw_text(_stats_x, _stats_y + (_line_height * _stat_line_index), _hp_text);
	draw_set_color(COLOR_HEALTH_BAR);
	draw_text(_stats_x + string_width(_hp_text), _stats_y + (_line_height * _stat_line_index), " (+" + string_format(_hp_bonus, 0, 1) + ")");
	_stat_line_index++;

	var _shown_armor = _demon_stats.armor;

	if (variable_instance_exists(_cultist, "armor"))
	{
		_shown_armor = _cultist.armor;
	}

	var _stat_text = "Armor: " + string_format(_shown_armor - 100, 0, 1) + "%";
	draw_set_color(COLOR_CULTIST_BODY);
	draw_text(_stats_x, _stats_y + (_line_height * _stat_line_index), _stat_text);
	draw_set_color(COLOR_HEALTH_BAR);
	draw_text(_stats_x + string_width(_stat_text), _stats_y + (_line_height * _stat_line_index), " (+" + string_format(_armor_bonus, 0, 1) + "%)");
	_stat_line_index++;

	_stat_text = "Phys dmg: " + string_format(_demon_stats.damage, 0, 2);
	var _damage_color = COLOR_CULTIST_BODY;
	var _shown_damage_bonus = _damage_bonus;

	if (_demon_stats.magic_damage > 0)
	{
		_stat_text = "Magic dmg: " + string_format(_demon_stats.magic_damage, 0, 2);
		_damage_color = COLOR_CULTIST_SPIRIT;
		_shown_damage_bonus = _magic_damage_bonus;
	}

	draw_set_color(_damage_color);
	draw_text(_stats_x, _stats_y + (_line_height * _stat_line_index), _stat_text);
	draw_set_color(COLOR_HEALTH_BAR);
	draw_text(_stats_x + string_width(_stat_text), _stats_y + (_line_height * _stat_line_index), " (+" + string_format(_shown_damage_bonus, 0, 2) + ")");
	_stat_line_index++;

	_stat_text = "Crit dmg: x" + string_format(_demon_stats.crit_damage, 0, 2);
	draw_set_color(COLOR_CULTIST_BODY);
	draw_text(_stats_x, _stats_y + (_line_height * _stat_line_index), _stat_text);
	draw_set_color(COLOR_HEALTH_BAR);
	draw_text(_stats_x + string_width(_stat_text), _stats_y + (_line_height * _stat_line_index), " (+x" + string_format(_crit_damage_bonus, 0, 2) + ")");
	_stat_line_index++;

	_stat_text = "Crit chance: " + string_format(_demon_stats.crit_chance * 100, 0, 1) + "%";
	draw_set_color(COLOR_CULTIST_FERVOR);
	draw_text(_stats_x, _stats_y + (_line_height * _stat_line_index), _stat_text);
	draw_set_color(COLOR_HEALTH_BAR);
	draw_text(_stats_x + string_width(_stat_text), _stats_y + (_line_height * _stat_line_index), " (+" + string_format(_crit_bonus * 100, 0, 1) + "%)");
	_stat_line_index++;

	_stat_text = "Attack speed: " + string_format(_shown_attack_speed, 0, 2);
	draw_set_color(COLOR_CULTIST_FERVOR);
	draw_text(_stats_x, _stats_y + (_line_height * _stat_line_index), _stat_text);
	draw_set_color(COLOR_HEALTH_BAR);

	if (_has_demonic_infusion)
	{
		draw_text(_stats_x + string_width(_stat_text), _stats_y + (_line_height * _stat_line_index), " (Demonic Infusion)");
	}
	else
	{
		draw_text(_stats_x + string_width(_stat_text), _stats_y + (_line_height * _stat_line_index), " (+" + string_format(_attack_speed_bonus, 0, 2) + ")");
	}

	_stat_line_index++;

	_stat_text = "Move speed: " + string_format(_demon_stats.move_speed, 0, 2);
	draw_set_color(COLOR_CULTIST_FERVOR);
	draw_text(_stats_x, _stats_y + (_line_height * _stat_line_index), _stat_text);
	draw_set_color(COLOR_HEALTH_BAR);
	draw_text(_stats_x + string_width(_stat_text), _stats_y + (_line_height * _stat_line_index), " (+" + string_format(_move_speed_bonus, 0, 2) + ")");
	_stat_line_index++;

	_stat_text = "Ability rec: " + string_format(_demon_stats.abilities_cd_spd, 0, 2);
	draw_set_color(COLOR_CULTIST_SPIRIT);
	draw_text(_stats_x, _stats_y + (_line_height * _stat_line_index), _stat_text);
	draw_set_color(COLOR_HEALTH_BAR);
	draw_text(_stats_x + string_width(_stat_text), _stats_y + (_line_height * _stat_line_index), " (+" + string_format(_cooldown_bonus, 0, 2) + ")");
	_stat_line_index++;

	_stat_text = "XP Gain: " + string_format(_demon_stats.exp_effectiveness, 0, 2);
	draw_set_color(COLOR_CULTIST_SPIRIT);
	draw_text(_stats_x, _stats_y + (_line_height * _stat_line_index), _stat_text);
	draw_set_color(COLOR_HEALTH_BAR);
	draw_text(_stats_x + string_width(_stat_text), _stats_y + (_line_height * _stat_line_index), " (+" + string_format(_exp_bonus, 0, 2) + ")");
	_stat_line_index++;

	_stat_text = "Magic power: " + string_format(_demon_stats.magic_effectiveness, 0, 2);
	draw_set_color(COLOR_CULTIST_SPIRIT);
	draw_text(_stats_x, _stats_y + (_line_height * _stat_line_index), _stat_text);
	draw_set_color(COLOR_HEALTH_BAR);
	draw_text(_stats_x + string_width(_stat_text), _stats_y + (_line_height * _stat_line_index), " (+" + string_format(_magic_bonus, 0, 2) + ")");
	_stat_line_index++;

	_stat_text = "Magic resistance: " + string_format(_demon_stats.magic_resistance - 100, 0, 1) + "%";
	draw_set_color(COLOR_CULTIST_SPIRIT);
	draw_text(_stats_x, _stats_y + (_line_height * _stat_line_index), _stat_text);
	draw_set_color(COLOR_HEALTH_BAR);
	draw_text(_stats_x + string_width(_stat_text), _stats_y + (_line_height * _stat_line_index), " (+" + string_format(_resistance_bonus, 0, 1) + "%)");
	_stat_line_index++;

	if (_demon_stats.aoe_radius > 0)
	{
		draw_set_color(COLOR_HUD_TEXT);
		draw_text(_stats_x, _stats_y + (_line_height * _stat_line_index), "Aoe radius: " + string(_demon_stats.aoe_radius));
		_stat_line_index++;
	}

	var _abilities_y = _stats_y + (_line_height * _stat_line_index) + 18;

	draw_set_color(COLOR_HUD_PROJECTILE_DESCRIPTION);
	draw_text(_hover_x + _hover_padding, _abilities_y, "Abilities");
	draw_text_ext(_hover_x + _hover_padding, _abilities_y + 22, _abilities_text, 16, _ability_width);

	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
	draw_set_alpha(1);
};

night_attack_enemy_difficulty_get = function(_enemy_object)
{
	if (_enemy_object == o_enemy_peasant)
	{
		return BALANCE_ENEMY_PEASANT_DIFFICULTY;
	}
	else if (_enemy_object == o_enemy_archer)
	{
		return BALANCE_ENEMY_ARCHER_DIFFICULTY;
	}
	else if (_enemy_object == o_enemy_knight)
	{
		return BALANCE_ENEMY_KNIGHT_DIFFICULTY;
	}
	else if (_enemy_object == o_enemy_mage)
	{
		return BALANCE_ENEMY_MAGE_DIFFICULTY;
	}
	else if (_enemy_object == o_enemy_catapult)
	{
		return BALANCE_ENEMY_CATAPULT_DIFFICULTY;
	}

	return 1;
};

night_attack_min_enemy_difficulty_get = function(_enemy_objects)
{
	var _enemy_count = array_length(_enemy_objects);
	var _min_difficulty = infinity;

	for (var _enemy_index = 0; _enemy_index < _enemy_count; ++_enemy_index)
	{
		_min_difficulty = min(_min_difficulty, night_attack_enemy_difficulty_get(_enemy_objects[_enemy_index]));
	}

	return max(1, _min_difficulty);
};

night_attack_array_sum = function(_values)
{
	var _total = 0;
	var _value_count = array_length(_values);

	for (var _value_index = 0; _value_index < _value_count; ++_value_index)
	{
		_total += _values[_value_index];
	}

	return _total;
};

night_attack_second_unit_candidates_get = function(_first_object)
{
	var _unit_count = array_length(night_attack_unit_pool);
	var _first_difficulty = night_attack_enemy_difficulty_get(_first_object);
	var _second_candidates = [];

	for (var _candidate_index = 0; _candidate_index < _unit_count; ++_candidate_index)
	{
		var _candidate_object = night_attack_unit_pool[_candidate_index];

		if (_candidate_object != _first_object
			&& night_attack_enemy_difficulty_get(_candidate_object) != _first_difficulty)
		{
			array_push(_second_candidates, _candidate_object);
		}
	}

	if (array_length(_second_candidates) > 0)
	{
		return _second_candidates;
	}

	for (var _fallback_index = 0; _fallback_index < _unit_count; ++_fallback_index)
	{
		var _fallback_object = night_attack_unit_pool[_fallback_index];

		if (_fallback_object != _first_object)
		{
			array_push(_second_candidates, _fallback_object);
		}
	}

	return _second_candidates;
};

night_attack_unit_pair_roll = function(_previous_pair)
{
	var _unit_count = array_length(night_attack_unit_pool);
	var _first_index = irandom(_unit_count - 1);
	var _first_object = night_attack_unit_pool[_first_index];
	var _second_candidates = night_attack_second_unit_candidates_get(_first_object);

	var _pair = [
		_first_object,
		_second_candidates[irandom(array_length(_second_candidates) - 1)]
	];

	if (array_length(_previous_pair) <= 0)
	{
		return _pair;
	}

	// Reroll a few times so both directions do not advertise the same unit set.
	for (var _attempt_index = 0; _attempt_index < 20; ++_attempt_index)
	{
		var _has_same_pair = (_pair[0] == _previous_pair[0] && _pair[1] == _previous_pair[1])
			|| (_pair[0] == _previous_pair[1] && _pair[1] == _previous_pair[0]);

		if (!_has_same_pair)
		{
			break;
		}

		_first_index = irandom(_unit_count - 1);
		_first_object = night_attack_unit_pool[_first_index];
		_second_candidates = night_attack_second_unit_candidates_get(_first_object);

		_pair = [
			_first_object,
			_second_candidates[irandom(array_length(_second_candidates) - 1)]
		];
	}

	return _pair;
};

night_attack_enemy_type_count_roll = function(_enemy_pair)
{
	if (array_length(_enemy_pair) <= 1 || random(1) >= BALANCE_NIGHT_ATTACK_SINGLE_TYPE_CHANCE)
	{
		return _enemy_pair;
	}

	// Some directions advertise and spawn only one enemy type.
	var _enemy_index = irandom(array_length(_enemy_pair) - 1);

	return [_enemy_pair[_enemy_index]];
};

night_attack_wave_count_get = function(_direction_difficulty, _enemy_objects)
{
	var _wave_count = max(1, BALANCE_NIGHT_ATTACK_WAVE_COUNT);
	var _wave_difficulty = _direction_difficulty / _wave_count;
	var _min_difficulty = night_attack_min_enemy_difficulty_get(_enemy_objects);
	var _estimated_enemy_count = floor(_wave_difficulty / _min_difficulty);

	if (_estimated_enemy_count < BALANCE_NIGHT_ATTACK_MIN_UNITS_PER_WAVE)
	{
		_wave_count = max(1, BALANCE_NIGHT_ATTACK_LOW_UNIT_WAVE_COUNT);
	}

	return _wave_count;
};

night_attack_enemy_difficulty_share_create = function(_enemy_objects, _direction_difficulty)
{
	var _enemy_count = array_length(_enemy_objects);
	var _difficulty_share = _direction_difficulty / max(1, _enemy_count);
	var _enemy_difficulties = array_create(_enemy_count, 0);

	for (var _enemy_index = 0; _enemy_index < _enemy_count; ++_enemy_index)
	{
		_enemy_difficulties[_enemy_index] = _difficulty_share;
	}

	return _enemy_difficulties;
};

night_attack_wave_units_shuffle = function(_wave_units)
{
	var _wave_unit_count = array_length(_wave_units);

	for (var _unit_index = _wave_unit_count - 1; _unit_index > 0; --_unit_index)
	{
		var _swap_index = irandom(_unit_index);
		var _swap_unit = _wave_units[_swap_index];

		_wave_units[_swap_index] = _wave_units[_unit_index];
		_wave_units[_unit_index] = _swap_unit;
	}

	return _wave_units;
};

night_attack_wave_units_create = function(_enemy_objects, _enemy_difficulties, _remaining_wave_count)
{
	var _wave_units = [];
	var _enemy_count = array_length(_enemy_objects);
	var _safe_remaining_wave_count = max(1, _remaining_wave_count);

	for (var _enemy_index = 0; _enemy_index < _enemy_count; ++_enemy_index)
	{
		var _enemy_object = _enemy_objects[_enemy_index];
		var _enemy_difficulty = night_attack_enemy_difficulty_get(_enemy_object);
		var _target_difficulty = _enemy_difficulties[_enemy_index] / _safe_remaining_wave_count;
		var _unit_count = round(_target_difficulty / _enemy_difficulty);

		if (_enemy_difficulties[_enemy_index] > 0 && _unit_count <= 0)
		{
			_unit_count = 1;
		}

		for (var _unit_index = 0; _unit_index < _unit_count; ++_unit_index)
		{
			array_push(_wave_units, _enemy_object);
		}
	}

	return night_attack_wave_units_shuffle(_wave_units);
};

night_attack_enemy_difficulties_spend = function(_enemy_objects, _enemy_difficulties, _wave_units)
{
	var _enemy_count = array_length(_enemy_objects);
	var _wave_unit_count = array_length(_wave_units);

	for (var _wave_unit_index = 0; _wave_unit_index < _wave_unit_count; ++_wave_unit_index)
	{
		var _wave_unit_object = _wave_units[_wave_unit_index];

		for (var _enemy_index = 0; _enemy_index < _enemy_count; ++_enemy_index)
		{
			if (_enemy_objects[_enemy_index] == _wave_unit_object)
			{
				_enemy_difficulties[_enemy_index] = max(
					0,
					_enemy_difficulties[_enemy_index] - night_attack_enemy_difficulty_get(_wave_unit_object)
				);
				break;
			}
		}
	}

	return _enemy_difficulties;
};

// Night attacks come from the direction of a random active shrine with a small angle drift.
night_attack_shrine_source_roll = function()
{
	var _shrine_count = array_length(shrine_instances);

	if (_shrine_count <= 0)
	{
		return noone;
	}

	var _start_index = irandom(_shrine_count - 1);

	for (var _offset = 0; _offset < _shrine_count; ++_offset)
	{
		var _shrine_index = (_start_index + _offset) mod _shrine_count;
		var _shrine = shrine_instances[_shrine_index];

		if (shrine_can_spawn_night_attack(_shrine))
		{
			return _shrine;
		}
	}

	return noone;
};

night_attack_shrine_direction_roll = function(_shrine)
{
	if (!instance_exists(o_cannon) || !instance_exists(_shrine))
	{
		return random(360);
	}

	var _cannon = instance_find(o_cannon, 0);
	var _shrine_direction = point_direction(_cannon.x, _cannon.y, _shrine.x, _shrine.y);
	var _random_angle = BALANCE_NIGHT_ATTACK_SHRINE_DIRECTION_RANDOM_ANGLE;

	return (_shrine_direction + random_range(-_random_angle, _random_angle) + 360) mod 360;
};

night_attack_plan_create = function()
{
	boss_griffith_prepare_next_night();

	var _direction_count = max(1, BALANCE_NIGHT_ATTACK_DIRECTION_COUNT);

	if (boss_griffith_pending_next_night)
	{
		_direction_count = 1;
	}
	else if (night_attack_night_index == 1)
	{
		_direction_count = max(1, BALANCE_FIRST_NIGHT_ATTACK_DIRECTION_COUNT);
	}

	var _total_difficulty = night_attack_total_difficulty_get();
	var _directions = [];

	for (var _roll_index = 0; _roll_index < _direction_count; ++_roll_index)
	{
		var _source_shrine = night_attack_shrine_source_roll();

		if (!instance_exists(_source_shrine))
		{
			continue;
		}

		array_push(
			_directions,
			{
				direction: night_attack_shrine_direction_roll(_source_shrine),
				source_shrine: _source_shrine
			}
		);
	}

	night_attack_directions = [];

	var _active_direction_count = array_length(_directions);

	if (_active_direction_count <= 0)
	{
		night_attack_plan_exists = true;
		return;
	}

	if (boss_griffith_pending_next_night)
	{
		boss_griffith_pending_direction = _directions[0].direction;
	}

	var _direction_difficulty_cap = BALANCE_NIGHT_ATTACK_DIRECTION_DIFFICULTY_MAX;

	if (full_moon_night_is_scheduled(night_attack_night_index))
	{
		_direction_difficulty_cap *= BALANCE_FULL_MOON_DIFFICULTY_MULTIPLIER;
	}

	var _direction_difficulty = min(
		_total_difficulty / _active_direction_count,
		_direction_difficulty_cap
	);
	var _previous_pair = [];
	var _remaining_enemy_type_slots = BALANCE_NIGHT_ATTACK_MAX_ENEMY_TYPES;
	var _selected_enemy_types = [];

	night_attack_difficulty_debug_log(_total_difficulty, _active_direction_count, _direction_difficulty);

	for (var _direction_index = 0; _direction_index < _active_direction_count; ++_direction_index)
	{
		var _direction_source = _directions[_direction_index];
		var _enemy_pair = night_attack_unit_pair_roll(_previous_pair);
		var _enemy_objects = night_attack_enemy_type_count_roll(_enemy_pair);

		if (_remaining_enemy_type_slots <= 0)
		{
			_enemy_objects = [_selected_enemy_types[irandom(array_length(_selected_enemy_types) - 1)]];
		}
		else if (array_length(_enemy_objects) > _remaining_enemy_type_slots)
		{
			_enemy_objects = [_enemy_objects[irandom(array_length(_enemy_objects) - 1)]];
		}

		for (var _enemy_type_index = 0; _enemy_type_index < array_length(_enemy_objects); ++_enemy_type_index)
		{
			var _enemy_type = _enemy_objects[_enemy_type_index];
			var _enemy_type_is_new = true;

			for (var _selected_type_index = 0; _selected_type_index < array_length(_selected_enemy_types); ++_selected_type_index)
			{
				if (_selected_enemy_types[_selected_type_index] == _enemy_type)
				{
					_enemy_type_is_new = false;
					break;
				}
			}

			if (_enemy_type_is_new)
			{
				array_push(_selected_enemy_types, _enemy_type);
			}
		}

		_remaining_enemy_type_slots -= array_length(_enemy_objects);
		var _wave_count = night_attack_wave_count_get(_direction_difficulty, _enemy_objects);

		_previous_pair = _enemy_pair;

		array_push(
			night_attack_directions,
			{
				direction: _direction_source.direction,
				source_shrine: _direction_source.source_shrine,
				enemy_objects: _enemy_objects,
				direction_difficulty: _direction_difficulty,
				wave_count: _wave_count,
				wave_difficulty: _direction_difficulty / _wave_count,
				remaining_difficulty: _direction_difficulty,
				remaining_enemy_difficulties: night_attack_enemy_difficulty_share_create(_enemy_objects, _direction_difficulty),
				wave_index: 0,
				wave_timer: 0,
				spawn_timer: 0,
				spawn_limit_wait_timer: 0,
				current_wave_units: [],
				current_wave_spawn_index: 0
			}
		);
	}

	night_attack_plan_exists = true;
};

night_attack_direction_wave_start = function(_direction_index)
{
	var _direction_data = night_attack_directions[_direction_index];
	var _remaining_wave_count = max(1, _direction_data.wave_count - _direction_data.wave_index);

	_direction_data.wave_difficulty = _direction_data.remaining_difficulty / _remaining_wave_count;
	_direction_data.current_wave_units = night_attack_wave_units_create(
		_direction_data.enemy_objects,
		_direction_data.remaining_enemy_difficulties,
		_remaining_wave_count
	);
	_direction_data.remaining_enemy_difficulties = night_attack_enemy_difficulties_spend(
		_direction_data.enemy_objects,
		_direction_data.remaining_enemy_difficulties,
		_direction_data.current_wave_units
	);

	// Bonus guests do not consume the regular night difficulty budget.
	if (global.ritual_invite_worthy_active && array_length(_direction_data.current_wave_units) > 0)
	{
		var _base_unit_count = array_length(_direction_data.current_wave_units);
		var _extra_unit_count = round(
			_base_unit_count * (BALANCE_RITUAL_INVITE_WORTHY_ENEMY_MULTIPLIER - 1)
		);

		for (var _extra_index = 0; _extra_index < _extra_unit_count; ++_extra_index)
		{
			array_push(
				_direction_data.current_wave_units,
				_direction_data.current_wave_units[irandom(_base_unit_count - 1)]
			);
		}

		_direction_data.current_wave_units = night_attack_wave_units_shuffle(
			_direction_data.current_wave_units
		);
	}

	_direction_data.remaining_difficulty = max(
		0,
		night_attack_array_sum(_direction_data.remaining_enemy_difficulties)
	);
	_direction_data.current_wave_spawn_index = 0;
	_direction_data.spawn_timer = 0;
	_direction_data.spawn_limit_wait_timer = 0;
	night_attack_directions[_direction_index] = _direction_data;
};

night_attack_direction_alive_enemy_count_get = function(_direction_index)
{
	var _alive_count = 0;
	var _enemy_count = instance_number(o_enemy_units);

	for (var _enemy_index = 0; _enemy_index < _enemy_count; ++_enemy_index)
	{
		var _enemy = instance_find(o_enemy_units, _enemy_index);

		if (instance_exists(_enemy)
			&& variable_instance_exists(_enemy, "hp")
			&& _enemy.hp > 0
			&& variable_instance_exists(_enemy, "is_night_attack_unit")
			&& _enemy.is_night_attack_unit
			&& variable_instance_exists(_enemy, "night_attack_direction_index")
			&& _enemy.night_attack_direction_index == _direction_index)
		{
			_alive_count++;
		}
	}

	return _alive_count;
};

night_attack_enemy_spawn = function(_direction_index, _direction_data, _enemy_object)
{
	if (!instance_exists(o_cannon))
	{
		return;
	}

	var _cannon = instance_find(o_cannon, 0);
	var _spawn_x = _cannon.x + lengthdir_x(BALANCE_NIGHT_ATTACK_SPAWN_DISTANCE, _direction_data.direction);
	var _spawn_y = _cannon.y + lengthdir_y(BALANCE_NIGHT_ATTACK_SPAWN_DISTANCE, _direction_data.direction);
	var _side_offset = random_range(-BALANCE_NIGHT_ATTACK_SPAWN_SPREAD_RADIUS, BALANCE_NIGHT_ATTACK_SPAWN_SPREAD_RADIUS);
	var _forward_offset = random_range(
		-BALANCE_NIGHT_ATTACK_SPAWN_SPREAD_RADIUS * 0.25,
		BALANCE_NIGHT_ATTACK_SPAWN_SPREAD_RADIUS * 0.25
	);

	_spawn_x += lengthdir_x(_side_offset, _direction_data.direction + 90)
		+ lengthdir_x(_forward_offset, _direction_data.direction);
	_spawn_y += lengthdir_y(_side_offset, _direction_data.direction + 90)
		+ lengthdir_y(_forward_offset, _direction_data.direction);

	var _enemy = instance_create_layer(_spawn_x, _spawn_y, "Instances", _enemy_object);

	_enemy.unit_can_attack_cannon = true;
	_enemy.is_night_attack_unit = true;
	_enemy.night_attack_direction_index = _direction_index;
	_enemy.owner_garnizon = noone;
	_enemy.guard_target = noone;
	enemy_night_hp_scale_apply(_enemy);
	global.night_attack_unit_count++;
};

boss_griffith_night_is_scheduled = function(_night_index)
{
	if (boss_griffith_force_next_night)
	{
		return true;
	}

	return _night_index > 0 && (_night_index mod boss_griffith_night_interval) == 0;
};

full_moon_night_is_scheduled = function(_night_index)
{
	if (boss_griffith_night_is_scheduled(_night_index))
	{
		return false;
	}

	return _night_index > 0 && (_night_index mod full_moon_night_interval) == 0;
};

boss_griffith_prepare_next_night = function()
{
	if (boss_griffith_pending_next_night)
	{
		return;
	}

	if (!boss_griffith_force_next_night
		&& !boss_griffith_night_is_scheduled(night_attack_night_index))
	{
		return;
	}

	boss_griffith_pending_next_night = true;
	boss_griffith_pending_direction = random(360);
};

boss_griffith_spawn_enemy = function(_origin_x, _origin_y, _enemy_object, _radius_min, _radius_max)
{
	var _spawn_direction = random(360);
	var _spawn_distance = random_range(_radius_min, _radius_max);
	var _spawn_x = _origin_x + lengthdir_x(_spawn_distance, _spawn_direction);
	var _spawn_y = _origin_y + lengthdir_y(_spawn_distance, _spawn_direction);
	var _enemy = instance_create_layer(_spawn_x, _spawn_y, "Instances", _enemy_object);

	if (!instance_exists(_enemy))
	{
		return noone;
	}

	_enemy.unit_can_attack_cannon = true;
	_enemy.is_night_attack_unit = true;
	_enemy.owner_garnizon = noone;
	_enemy.guard_target = noone;
	enemy_night_hp_scale_apply(_enemy);
	global.night_attack_unit_count++;

	return _enemy;
};

boss_griffith_spawn_for_night = function()
{
	if (!instance_exists(o_cannon) || !boss_griffith_pending_next_night)
	{
		return noone;
	}

	var _cannon = instance_find(o_cannon, 0);
	var _spawn_x = _cannon.x + lengthdir_x(BALANCE_NIGHT_ATTACK_SPAWN_DISTANCE, boss_griffith_pending_direction);
	var _spawn_y = _cannon.y + lengthdir_y(BALANCE_NIGHT_ATTACK_SPAWN_DISTANCE, boss_griffith_pending_direction);
	var _boss = instance_create_layer(_spawn_x, _spawn_y, "Instances", o_boss_griffith);

	if (!instance_exists(_boss))
	{
		return noone;
	}

	_boss.unit_can_attack_cannon = true;
	_boss.is_night_attack_unit = true;
	_boss.owner_garnizon = noone;
	_boss.guard_target = noone;
	enemy_night_hp_scale_apply(_boss);
	global.night_attack_unit_count++;

	for (var _archer_index = 0; _archer_index < BALANCE_BOSS_GRIFFITH_ENTOURAGE_ARCHER_COUNT; ++_archer_index)
	{
		boss_griffith_spawn_enemy(
			_boss.x,
			_boss.y,
			o_enemy_archer,
			BALANCE_BOSS_GRIFFITH_ENTOURAGE_SPAWN_RADIUS_MIN,
			BALANCE_BOSS_GRIFFITH_ENTOURAGE_SPAWN_RADIUS_MAX
		);
	}

	for (var _knight_index = 0; _knight_index < BALANCE_BOSS_GRIFFITH_ENTOURAGE_KNIGHT_COUNT; ++_knight_index)
	{
		boss_griffith_spawn_enemy(
			_boss.x,
			_boss.y,
			o_enemy_knight,
			BALANCE_BOSS_GRIFFITH_ENTOURAGE_SPAWN_RADIUS_MIN,
			BALANCE_BOSS_GRIFFITH_ENTOURAGE_SPAWN_RADIUS_MAX
		);
	}

	boss_griffith_pending_next_night = false;
	boss_griffith_force_next_night = false;

	return _boss;
};

crusade_spawn = function(_direction)
{
	if (!instance_exists(o_cannon))
	{
		return noone;
	}

	var _cannon = instance_find(o_cannon, 0);
	var _spawn_x = _cannon.x + lengthdir_x(BALANCE_NIGHT_ATTACK_SPAWN_DISTANCE, _direction);
	var _spawn_y = _cannon.y + lengthdir_y(BALANCE_NIGHT_ATTACK_SPAWN_DISTANCE, _direction);
	var _catapult = instance_create_layer(_spawn_x, _spawn_y, "Instances", o_enemy_catapult);

	if (!instance_exists(_catapult))
	{
		return noone;
	}

	_catapult.unit_can_attack_cannon = true;
	_catapult.is_night_attack_unit = true;
	_catapult.owner_garnizon = noone;
	_catapult.guard_target = noone;
	enemy_night_hp_scale_apply(_catapult);
	global.night_attack_unit_count++;

	for (var _crusader_index = 0; _crusader_index < BALANCE_ENEMY_CATAPULT_CRUSADE_CRUSADER_COUNT; ++_crusader_index)
	{
		var _crusader_angle = 360 * (_crusader_index / max(1, BALANCE_ENEMY_CATAPULT_CRUSADE_CRUSADER_COUNT));
		var _crusader_x = _catapult.x + lengthdir_x(BALANCE_ENEMY_CATAPULT_CRUSADE_SPAWN_RADIUS, _crusader_angle);
		var _crusader_y = _catapult.y + lengthdir_y(BALANCE_ENEMY_CATAPULT_CRUSADE_SPAWN_RADIUS, _crusader_angle);
		var _crusader = instance_create_layer(_crusader_x, _crusader_y, "Instances", o_crusader);

		if (instance_exists(_crusader))
		{
			_crusader.catapult_escort_target = _catapult;
			_crusader.catapult_escort_angle = _crusader_angle;
			_crusader.unit_can_attack_cannon = false;
			_crusader.is_night_attack_unit = true;
			_crusader.owner_garnizon = noone;
			_crusader.guard_target = noone;
			enemy_night_hp_scale_apply(_crusader);
			global.night_attack_unit_count++;
		}
	}

	return _catapult;
};

crusade_corruption_total_get = function()
{
	if (!instance_exists(o_corruption_grid))
	{
		return 0;
	}

	var _corruption_grid = instance_find(o_corruption_grid, 0);
	var _total_corruption = 0;

	for (var _cell_x = 0; _cell_x < _corruption_grid.grid_width; ++_cell_x)
	{
		for (var _cell_y = 0; _cell_y < _corruption_grid.grid_height; ++_cell_y)
		{
			var _saint = 0;

			if (variable_instance_exists(_corruption_grid, "saint_grid"))
			{
				_saint = ds_grid_get(_corruption_grid.saint_grid, _cell_x, _cell_y);
			}

			if (_saint <= 0)
			{
				_total_corruption += ds_grid_get(_corruption_grid.corruption_grid, _cell_x, _cell_y);
			}
		}
	}

	return _total_corruption;
};

crusade_taint_tracking_init = function()
{
	if (!instance_exists(o_corruption_grid))
	{
		return;
	}

	var _corruption_total = crusade_corruption_total_get();
	crusade_taint_threshold_index = floor(_corruption_total / max(1, crusade_taint_trigger_amount));
	crusade_taint_tracking_initialized = true;
	crusade_corruption_check_timer = 0;
};

crusade_taint_threshold_update = function()
{
	if (global.pause || global.day_phase != DAY_PHASE.DAY)
	{
		return;
	}

	crusade_corruption_check_timer++;

	if (crusade_corruption_check_timer < crusade_corruption_check_interval)
	{
		return;
	}

	crusade_corruption_check_timer = 0;

	if (!instance_exists(o_corruption_grid))
	{
		return;
	}

	var _corruption_total = crusade_corruption_total_get();

	if (!crusade_taint_tracking_initialized)
	{
		crusade_taint_tracking_init();
		return;
	}

	var _new_threshold_index = floor(_corruption_total / max(1, crusade_taint_trigger_amount));
	var _new_crusade_count = max(0, _new_threshold_index - crusade_taint_threshold_index);

	if (_new_crusade_count > 0)
	{
		for (var _new_crusade_index = 0; _new_crusade_index < _new_crusade_count; ++_new_crusade_index)
		{
			array_push(crusade_pending_directions, random(360));
		}

		crusade_pending_count = array_length(crusade_pending_directions);
		crusade_taint_threshold_index = _new_threshold_index;
	}
};

crusade_spawn_pending_for_night = function()
{
	var _pending_direction_count = array_length(crusade_pending_directions);

	for (var _crusade_index = 0; _crusade_index < _pending_direction_count; ++_crusade_index)
	{
		crusade_spawn(crusade_pending_directions[_crusade_index]);
	}

	crusade_pending_count = 0;
	crusade_pending_directions = [];
};

night_attack_spawning_update = function()
{
	if (global.pause || global.day_phase != DAY_PHASE.NIGHT || !night_attack_plan_exists)
	{
		return;
	}

	var _direction_count = array_length(night_attack_directions);

	for (var _direction_index = 0; _direction_index < _direction_count; ++_direction_index)
	{
		var _direction_data = night_attack_directions[_direction_index];

		if (variable_struct_exists(_direction_data, "source_shrine")
			&& !shrine_can_spawn_night_attack(_direction_data.source_shrine))
		{
			_direction_data.wave_index = _direction_data.wave_count;
			_direction_data.current_wave_units = [];
			_direction_data.current_wave_spawn_index = 0;
			night_attack_directions[_direction_index] = _direction_data;
			continue;
		}

		if (_direction_data.wave_index >= _direction_data.wave_count)
		{
			continue;
		}

		if (_direction_data.wave_timer > 0)
		{
			_direction_data.wave_timer--;
			night_attack_directions[_direction_index] = _direction_data;
			continue;
		}

		if (array_length(_direction_data.current_wave_units) <= 0)
		{
			night_attack_direction_wave_start(_direction_index);
			_direction_data = night_attack_directions[_direction_index];
		}

		if (_direction_data.spawn_timer > 0)
		{
			_direction_data.spawn_timer--;
			night_attack_directions[_direction_index] = _direction_data;
			continue;
		}

		var _wave_unit_count = array_length(_direction_data.current_wave_units);
		var _alive_enemy_count = night_attack_direction_alive_enemy_count_get(_direction_index);
		var _soft_limit = BALANCE_NIGHT_ATTACK_DIRECTION_ALIVE_ENEMY_LIMIT;
		var _hard_limit = max(_soft_limit, BALANCE_NIGHT_ATTACK_DIRECTION_HARD_ALIVE_ENEMY_LIMIT);
		var _spawn_slot_count = max(0, _soft_limit - _alive_enemy_count);
		var _spawn_limit_check_time = BALANCE_NIGHT_ATTACK_UNIT_SPAWN_INTERVAL * room_speed;
		var _max_limit_wait_time = BALANCE_NIGHT_ATTACK_MAX_LIMIT_WAIT_TIME * room_speed;
		var _limit_wait_is_over = _direction_data.spawn_limit_wait_timer >= _max_limit_wait_time;
		var _batch_spawn_count = 0;

		if (_alive_enemy_count < _soft_limit)
		{
			_direction_data.spawn_limit_wait_timer = 0;
			_batch_spawn_count = min(BALANCE_NIGHT_ATTACK_SPAWN_BATCH_COUNT, _spawn_slot_count);
		}
		else if (_alive_enemy_count < _hard_limit || _limit_wait_is_over)
		{
			_direction_data.spawn_limit_wait_timer = 0;
			_batch_spawn_count = BALANCE_NIGHT_ATTACK_SOFT_LIMIT_BATCH_COUNT;
		}
		else
		{
			_direction_data.spawn_limit_wait_timer += _spawn_limit_check_time;
			_direction_data.spawn_timer = BALANCE_NIGHT_ATTACK_UNIT_SPAWN_INTERVAL * room_speed;
			night_attack_directions[_direction_index] = _direction_data;
			continue;
		}

		_batch_spawn_count = max(0, _batch_spawn_count);

		for (var _batch_index = 0; _batch_index < _batch_spawn_count; ++_batch_index)
		{
			if (_direction_data.current_wave_spawn_index >= _wave_unit_count)
			{
				break;
			}

			var _enemy_object = _direction_data.current_wave_units[_direction_data.current_wave_spawn_index];

			night_attack_enemy_spawn(_direction_index, _direction_data, _enemy_object);
			_direction_data.current_wave_spawn_index++;
		}

		if (_direction_data.current_wave_spawn_index >= _wave_unit_count)
		{
			_direction_data.wave_index++;
			_direction_data.current_wave_units = [];
			_direction_data.current_wave_spawn_index = 0;

			if (_direction_data.wave_index < _direction_data.wave_count)
			{
				_direction_data.wave_timer = BALANCE_NIGHT_ATTACK_WAVE_INTERVAL * room_speed;
			}
		}

		_direction_data.spawn_timer = BALANCE_NIGHT_ATTACK_UNIT_SPAWN_INTERVAL * room_speed;
		night_attack_directions[_direction_index] = _direction_data;
	}
};

night_attack_all_waves_spawned = function()
{
	if (!night_attack_plan_exists)
	{
		return false;
	}

	var _direction_count = array_length(night_attack_directions);

	for (var _direction_index = 0; _direction_index < _direction_count; ++_direction_index)
	{
		var _direction_data = night_attack_directions[_direction_index];

		if (_direction_data.wave_index < _direction_data.wave_count)
		{
			return false;
		}
	}

	return true;
};

night_attack_alive_enemy_exists = function()
{
	var _enemy_count = instance_number(o_enemy_units);

	for (var _enemy_index = 0; _enemy_index < _enemy_count; ++_enemy_index)
	{
		var _enemy = instance_find(o_enemy_units, _enemy_index);

		if (instance_exists(_enemy)
			&& (!variable_instance_exists(_enemy, "ignored_for_night_end")
				|| !_enemy.ignored_for_night_end)
			&& (!variable_instance_exists(_enemy, "hp") || _enemy.hp > 0))
		{
			return true;
		}
	}

	return false;
};

// Night skip cheat clears active enemies before forcing morning.
debug_kill_all_enemies = function()
{
	var _enemy_count = instance_number(o_enemy_units);

	for (var _enemy_index = _enemy_count - 1; _enemy_index >= 0; --_enemy_index)
	{
		var _enemy = instance_find(o_enemy_units, _enemy_index);

		if (!instance_exists(_enemy))
		{
			continue;
		}

		if (variable_instance_exists(_enemy, "unit_damage_receive")
			&& variable_instance_exists(_enemy, "hp")
			&& _enemy.hp > 0)
		{
			_enemy.unit_damage_receive(_enemy.hp, UNIT_FACTION.NOONE);
		}
		else if (variable_instance_exists(_enemy, "hp"))
		{
			_enemy.hp = 0;
		}

		if (instance_exists(_enemy))
		{
			if (variable_instance_exists(_enemy, "unit_death_process"))
			{
				_enemy.unit_death_process();
			}
			else
			{
				instance_destroy(_enemy);
			}
		}
	}
};

night_timeout_enemy_retreat_start = function()
{
	var _camera_center_x = 0;
	var _camera_center_y = 0;
	var _camera_escape_distance = BALANCE_NIGHT_ATTACK_SPAWN_DISTANCE;

	if (instance_exists(o_camera_controller))
	{
		var _camera_controller = instance_find(o_camera_controller, 0);
		var _camera_x = camera_get_view_x(_camera_controller.camera_id);
		var _camera_y = camera_get_view_y(_camera_controller.camera_id);
		var _camera_width = camera_get_view_width(_camera_controller.camera_id);
		var _camera_height = camera_get_view_height(_camera_controller.camera_id);

		_camera_center_x = _camera_x + (_camera_width * 0.5);
		_camera_center_y = _camera_y + (_camera_height * 0.5);
		_camera_escape_distance = max(_camera_width, _camera_height) + BALANCE_NIGHT_TIMEOUT_RETREAT_DISTANCE;
	}
	else if (instance_exists(o_cannon))
	{
		var _cannon = instance_find(o_cannon, 0);

		_camera_center_x = _cannon.x;
		_camera_center_y = _cannon.y;
	}

	var _enemy_count = instance_number(o_enemy_units);

	for (var _enemy_index = _enemy_count - 1; _enemy_index >= 0; --_enemy_index)
	{
		var _enemy = instance_find(o_enemy_units, _enemy_index);

		if (!instance_exists(_enemy))
		{
			continue;
		}

		if (variable_instance_exists(_enemy, "ignored_for_night_end")
			&& _enemy.ignored_for_night_end)
		{
			continue;
		}

		var _retreat_direction = point_direction(_camera_center_x, _camera_center_y, _enemy.x, _enemy.y);

		if (point_distance(_camera_center_x, _camera_center_y, _enemy.x, _enemy.y) <= 0)
		{
			_retreat_direction = irandom(359);
		}

		var _retreat_target_x = _camera_center_x + lengthdir_x(_camera_escape_distance, _retreat_direction);
		var _retreat_target_y = _camera_center_y + lengthdir_y(_camera_escape_distance, _retreat_direction);

		if (variable_instance_exists(_enemy, "forced_retreat_start"))
		{
			_enemy.forced_retreat_start(
				_retreat_target_x,
				_retreat_target_y,
				BALANCE_NIGHT_TIMEOUT_RETREAT_SPEED_MULTIPLIER
			);
		}
		else
		{
			instance_destroy(_enemy);
		}
	}
};

night_attack_is_complete = function()
{
	return night_attack_all_waves_spawned()
		&& !night_attack_alive_enemy_exists();
};

phase_banner_show = function(_text)
{
	phase_banner_text = _text;
	phase_banner_timer = phase_banner_duration;
};

full_moon_effect_layer_set_visible = function(_is_visible)
{
	var _layer_id = layer_get_id(full_moon_effect_layer_name);

	if (_layer_id != -1)
	{
		layer_set_visible(_layer_id, _is_visible);
	}
};

night_effect_layers_set_progress = function(_progress)
{
	var _layer_count = array_length(night_effect_layer_names);
	var _clamped_progress = clamp(_progress, 0, 1);

	for (var _layer_index = 0; _layer_index < _layer_count; ++_layer_index)
	{
		var _layer_id = layer_get_id(night_effect_layer_names[_layer_index]);

		if (_layer_id == -1)
		{
			continue;
		}

		var _layer_threshold = _layer_index / max(1, _layer_count);
		layer_set_visible(_layer_id, _clamped_progress > _layer_threshold);
	}
};

night_effect_transition_start = function()
{
	night_effect_transition_timer = 0;
	night_effect_transition_active = true;
	night_effect_layers_set_progress(0);
	full_moon_effect_layer_set_visible(global.full_moon_night_active);
};

night_effect_layers_disable = function()
{
	night_effect_transition_timer = 0;
	night_effect_transition_active = false;
	night_effect_layers_set_progress(0);
	full_moon_effect_layer_set_visible(false);
};

night_effect_layers_disable();

start_night_phase = function()
{
	clear_dragged_unit();
	cannon_corpse_workers_drop_all();
	squad_blood_warpaint_start_night();
	var _is_full_moon_night = full_moon_night_is_scheduled(night_attack_night_index);
	global.day_phase = DAY_PHASE.NIGHT;
	global.full_moon_night_active = _is_full_moon_night;
	global.day_timer = global.night_duration * global.game_speed_normal;
	global.night_attack_unit_count = 0;
	night_force_end_timer = BALANCE_NIGHT_FORCE_END_TIME * room_speed;
	night_force_end_active = false;
	adaptive_night_cultist_knocked_out = false;
	phase_banner_show(_is_full_moon_night ? "BLOOD MOON" : "NIGHT FALLS");

	night_effect_transition_start();
	global.sound_play_random(global.night_start_sounds);
	update_goblin_evening_life();
	move_goblins_to_cannon_inner();

	// Apply temporary squad health before any units are loaded into the cannon.
	if (global.ritual_hell_weakest_active)
	{
		for (var _squad_index = 0; _squad_index < array_length(global.squads); ++_squad_index)
		{
			var _squad = global.squads[_squad_index];

			if (_squad == global.ritual_hell_weakest_squad)
			{
				// Keep the sacrificed squad completely outside combat for this night.
				for (var _undeployed_index = 0; _undeployed_index < array_length(_squad.units); ++_undeployed_index)
				{
					var _undeployed_unit = _squad.units[_undeployed_index];

					if (instance_exists(_undeployed_unit))
					{
						_undeployed_unit.ritual_hell_undeployed = true;
						_undeployed_unit.is_attackable = false;
						_undeployed_unit.visible = false;
					}
				}

				continue;
			}

			for (var _unit_index = 0; _unit_index < array_length(_squad.units); ++_unit_index)
			{
				var _unit = _squad.units[_unit_index];

				if (instance_exists(_unit) && !variable_instance_exists(_unit, "ritual_hell_health_bonus_applied"))
				{
					_unit.ritual_hell_health_bonus_applied = true;
					_unit.max_hp *= BALANCE_RITUAL_HELL_WEAKEST_HEALTH_MULTIPLIER;
					_unit.hp *= BALANCE_RITUAL_HELL_WEAKEST_HEALTH_MULTIPLIER;
				}
			}
		}
	}

	if (instance_exists(o_cannon))
	{
		var _cannon = instance_find(o_cannon, 0);

		if (global.ritual_trial_cannon_active)
		{
			_cannon.hp = max(
				0,
				_cannon.hp - (_cannon.max_hp * BALANCE_RITUAL_TRIAL_CANNON_HP_LOSS_SHARE)
			);
		}

		if (global.ritual_lesser_gate_active && !instance_exists(o_lesser_gate))
		{
			var _gate_direction = irandom(359);
			var _gate_x = _cannon.x + lengthdir_x(BALANCE_RITUAL_LESSER_GATE_CANNON_DISTANCE, _gate_direction);
			var _gate_y = _cannon.y + lengthdir_y(BALANCE_RITUAL_LESSER_GATE_CANNON_DISTANCE, _gate_direction);
			instance_create_layer(_gate_x, _gate_y, "Instances", o_lesser_gate);
		}

		adaptive_night_cannon_hp_start = _cannon.hp;

		if (variable_instance_exists(_cannon, "cannon_night_damage_tracking_start"))
		{
			_cannon.cannon_night_damage_tracking_start();
		}
	}

	adaptive_difficulty_night_hp_start_store();

	if (global.ritual_invite_worthy_active)
	{
		night_attack_plan_exists = false;
	}

	if (!night_attack_plan_exists)
	{
		night_attack_plan_create();
	}

	start_cultists_loading_into_cannon();
	summoned_combat_units_prepare_for_cultist_projectiles();

	with (o_garnizon)
	{
		if (is_activated)
		{
			release_owned_units();
		}
	}

	var _released_enemy_count = instance_number(o_enemy_units);

	for (var _enemy_index = 0; _enemy_index < _released_enemy_count; ++_enemy_index)
	{
		var _enemy = instance_find(o_enemy_units, _enemy_index);

		if (instance_exists(_enemy)
			&& variable_instance_exists(_enemy, "owner_garnizon")
			&& instance_exists(_enemy.owner_garnizon)
			&& _enemy.owner_garnizon.is_activated)
		{
			_enemy.unit_can_attack_cannon = true;
			_enemy.is_night_attack_unit = true;
			_enemy.guard_target = noone;
			_enemy.owner_garnizon = noone;
			enemy_night_hp_scale_apply(_enemy);
		}
	}

	var _existing_enemy_count = instance_number(o_enemy_units);

	for (var _existing_enemy_index = 0; _existing_enemy_index < _existing_enemy_count; ++_existing_enemy_index)
	{
		var _existing_enemy = instance_find(o_enemy_units, _existing_enemy_index);

		enemy_night_hp_scale_apply(_existing_enemy);
	}

	if (boss_griffith_pending_next_night)
	{
		boss_griffith_spawn_for_night();
	}
	else
	{
		crusade_spawn_pending_for_night();
	}
};

start_day_phase = function()
{
	clear_dragged_unit();
	squad_blood_warpaint_end_night();
	var _previous_night_was_full_moon = global.full_moon_night_active;
	var _blood_moon_reward_cultists = [];

	with (o_lesser_gate)
	{
		instance_destroy();
	}

	// Previous day event cards and their assignments never carry into a new day.
	day_event_new_day_reset();

	if (_previous_night_was_full_moon)
	{
		for (var _reward_index = 0; _reward_index < BALANCE_FULL_MOON_MORNING_CULTIST_REWARD; ++_reward_index)
		{
			var _reward_cultist = day_event_cultist_add();

			if (!instance_exists(_reward_cultist))
			{
				break;
			}

			array_push(_blood_moon_reward_cultists, _reward_cultist);
		}
	}

	global.ritual_extra_building_event_active = global.ritual_invite_worthy_reward_pending
		&& instance_exists(o_cannon);
	global.ritual_invite_worthy_reward_pending = false;
	day_event_generate_for_buildings();
	global.day_phase = DAY_PHASE.DAY;
	global.cannon_corpses_delivered_today = 0;
	global.full_moon_night_active = false;
	global.day_timer = global.day_duration * global.game_speed_normal;
	global.night_attack_unit_count = 0;
	night_force_end_timer = 0;
	night_force_end_active = false;
	phase_banner_show("DAY BREAKS");
	night_effect_layers_disable();
	adaptive_difficulty_evaluate_night();
	night_attack_night_index++;

	if (full_moon_night_is_scheduled(night_attack_night_index))
	{
		full_moon_hint_delay_start();
	}
	else
	{
		full_moon_hint_delay_pending = false;
		full_moon_hint_delay_timer = -1;
	}

	if (!crusade_taint_tracking_initialized)
	{
		crusade_taint_tracking_init();
	}

	fade_out_morning_meat();
	corpse_decay_at_morning();
	update_summoned_unit_night_life();
	settlement_garrison_units_destroy_at_morning();
	destroyed_house_units_destroy_at_morning();

	cultist_projectile_deploy_assignments_reset();
	unload_cultist_projectiles_to_day();
	transform_demons_to_archdemons();
	restore_dead_cultists_at_morning();
	squad_units_restore_morning();

	with (o_units_parent)
	{
		if (variable_instance_exists(id, "ritual_hell_undeployed")
			&& ritual_hell_undeployed)
		{
			is_attackable = true;
			ritual_hell_undeployed = false;
		}

		if (variable_instance_exists(id, "ritual_hell_health_bonus_applied")
			&& ritual_hell_health_bonus_applied)
		{
			max_hp /= BALANCE_RITUAL_HELL_WEAKEST_HEALTH_MULTIPLIER;
			hp = min(hp, max_hp);
			ritual_hell_health_bonus_applied = false;
		}

		visible = true;
	}

	global.ritual_black_pilgrimage_active = false;
	global.ritual_grasping_soil_active = false;
	global.ritual_awaken_taint_active = false;
	global.ritual_rust_righteous_active = false;
	global.ritual_silence_choir_active = false;
	global.ritual_blood_night_active = false;
	global.ritual_invite_worthy_active = false;
	global.ritual_trial_cannon_active = false;
	global.ritual_lesser_gate_active = false;
	global.ritual_hell_weakest_active = false;
	global.ritual_hell_weakest_squad = noone;

	move_cultists_to_cannon_inner();
	settlement_garrison_buildings_spawn_morning_units();
	move_summoned_units_to_cannon_inner();

	with (o_boneyard)
	{
		boneyard_spawn_morning_units();
	}

	with (o_pitlings_house)
	{
		pitlings_house_spawn_morning_units();
	}

	with (o_house)
	{
		house_morning_spawn_units();
	}

	with (o_grave_spire)
	{
		grave_spire_spawn_morning_units();
	}

	with (o_tower_corruption)
	{
		if (variable_instance_exists(id, "tower_corruption_morning_projectiles_fire"))
		{
			tower_corruption_morning_projectiles_fire();
		}
	}

	with (o_ihor_extractor)
	{
		ihor_extractor_morning_income_collect();
	}

	with (o_ritual_circle)
	{
		if (variable_instance_exists(id, "ritual_circle_daily_exp_remaining"))
		{
			ritual_circle_daily_exp_remaining = ritual_circle_daily_exp_limit_get();
		}
	}

	with (o_v13buildings_parent)
	{
		if (variable_instance_exists(id, "production_daily_limit")
			&& production_daily_limit > 0
			&& variable_instance_exists(id, "production_daily_remaining"))
		{
			production_daily_remaining = production_daily_limit;
		}
	}

	award_cultist_night_exp();
	award_day_cultists();
	night_attack_plan_create();

	if (_previous_night_was_full_moon)
	{
		blood_moon_reward_popup_show(_blood_moon_reward_cultists);
	}
};

fade_out_morning_meat = function()
{
	with (o_meat)
	{
		fade_out_start();
	}
};

cultist_level_point_apply = function(_cultist, _stat_index)
{
	if (!instance_exists(_cultist) || !variable_instance_exists(_cultist, "cultist_points"))
	{
		return false;
	}

	if (!variable_instance_exists(_cultist, "pending_level_points")
		|| _cultist.pending_level_points <= 0)
	{
		return false;
	}

	_cultist.cultist_points[_stat_index]++;
	_cultist.pending_level_points = max(_cultist.pending_level_points - 1, 0);

	if (variable_instance_exists(_cultist, "demon_type") && _cultist.demon_type != DEMON_TYPE.NONE && _cultist.object_index != o_archdemon)
	{
		var _cultist_hp = _cultist.hp;

		cultist_stats_apply(_cultist);
		_cultist.hp = clamp(_cultist_hp, 0, _cultist.max_hp);
	}
	else if (variable_instance_exists(_cultist, "demon_type") && _cultist.demon_type != DEMON_TYPE.NONE)
	{
		cultist_day_health_apply(_cultist, false);
	}

	return true;
};

cultist_level_ability_apply = function(_cultist, _reward_type, _ability)
{
	if (!instance_exists(_cultist))
	{
		return false;
	}

	if (_reward_type == CULTIST_LEVEL_REWARD.PASSIVE && cultist_passive_ability_unlock(_cultist, _ability))
	{
		_cultist.pending_passive_choices = max(_cultist.pending_passive_choices - 1, 0);
		_cultist.passive_choice_options = [];
		return true;
	}

	if (_reward_type == CULTIST_LEVEL_REWARD.ACTIVE && cultist_active_ability_unlock(_cultist, _ability))
	{
		_cultist.pending_active_choices = max(_cultist.pending_active_choices - 1, 0);
		_cultist.active_choice_options = [];
		return true;
	}

	if (_reward_type == CULTIST_LEVEL_REWARD.ABILITY_UPGRADE && cultist_ability_level_add(_cultist, _ability))
	{
		_cultist.pending_ability_upgrade_choices = max(_cultist.pending_ability_upgrade_choices - 1, 0);
		_cultist.ability_upgrade_choice_options = [];
		return true;
	}

	return false;
};

add_cultist_level_point = function(_stat_index)
{
	if (cultist_levelup_index < 0 || cultist_levelup_index >= array_length(global.archdemons))
	{
		return;
	}

	var _cultist = global.archdemons[cultist_levelup_index];

	if (cultist_level_point_apply(_cultist, _stat_index))
	{
		cultist_levelup_close();
	}
};

ensure_cultist_levelup_options = function(_cultist)
{
	if (!instance_exists(_cultist))
	{
		return;
	}

	if (variable_instance_exists(_cultist, "pending_passive_choices")
		&& _cultist.pending_passive_choices > 0
		&& (!variable_instance_exists(_cultist, "passive_choice_options") || array_length(_cultist.passive_choice_options) <= 0))
	{
		_cultist.passive_choice_options = cultist_ability_options_roll(_cultist, true);
	}

	if (variable_instance_exists(_cultist, "pending_active_choices")
		&& _cultist.pending_active_choices > 0
		&& (!variable_instance_exists(_cultist, "active_choice_options") || array_length(_cultist.active_choice_options) <= 0))
	{
		_cultist.active_choice_options = cultist_ability_options_roll(_cultist, false);
	}

	if (variable_instance_exists(_cultist, "pending_ability_upgrade_choices")
		&& _cultist.pending_ability_upgrade_choices > 0
		&& (!variable_instance_exists(_cultist, "ability_upgrade_choice_options") || array_length(_cultist.ability_upgrade_choice_options) <= 0))
	{
		_cultist.ability_upgrade_choice_options = cultist_ability_upgrade_options_roll(_cultist);
	}
};

add_cultist_level_ability = function(_ability)
{
	if (cultist_levelup_index < 0 || cultist_levelup_index >= array_length(global.archdemons))
	{
		return;
	}

	var _cultist = global.archdemons[cultist_levelup_index];

	if (!instance_exists(_cultist))
	{
		return;
	}

	var _reward_type = cultist_levelup_ability_reward_type_get(_cultist);

	if (cultist_level_ability_apply(_cultist, _reward_type, _ability))
	{
		cultist_levelup_close();
	}
};

cultist_levelup_apply_selected = function()
{
	if (cultist_levelup_index < 0 || cultist_levelup_index >= array_length(global.archdemons))
	{
		return false;
	}

	var _cultist = global.archdemons[cultist_levelup_index];

	if (!cultist_levelup_confirm_can_apply(_cultist))
	{
		return false;
	}

	var _has_attribute_choice = cultist_levelup_has_attribute_choice(_cultist);
	var _ability_reward_type = cultist_levelup_ability_reward_type_get(_cultist);
	var _has_ability_choice = _ability_reward_type != -1;
	var _applied_any_reward = false;

	if (_has_attribute_choice)
	{
		_applied_any_reward = cultist_level_point_apply(_cultist, cultist_levelup_selected_stat) || _applied_any_reward;
	}

	if (_has_ability_choice)
	{
		_applied_any_reward = cultist_level_ability_apply(_cultist, _ability_reward_type, cultist_levelup_selected_ability) || _applied_any_reward;
	}

	if (_applied_any_reward)
	{
		cultist_levelup_close();
	}

	return _applied_any_reward;
};

// The first daytime preview is available immediately when the room starts.
night_attack_plan_create();

// Window setup for a non-stretched 16:9 camera.
window_set_size(base_view_width, base_view_height);
display_set_gui_size(camera_view_width, camera_view_height);
application_surface_draw_enable(true);
view_xport[main_view_index] = 0;
view_yport[main_view_index] = 0;
view_wport[main_view_index] = camera_view_width;
view_hport[main_view_index] = camera_view_height;

if (surface_exists(application_surface))
{
	surface_resize(application_surface, camera_view_width, camera_view_height);
	application_surface_ready = true;
}
