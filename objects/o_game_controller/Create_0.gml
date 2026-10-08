// Global pause state used by gameplay objects.
randomise()
global.pause = true;
// Faction identity is selected before any gameplay input or simulation.
global.player_faction = FACTION.NONE;
global.faction_mana = array_create(FACTION.WILDLINGS + 1, BALANCE_MANA_STARTING_AMOUNT);
global.faction_mana_income = array_create(FACTION.WILDLINGS + 1, BALANCE_MANA_STARTING_INCOME);
faction_mana_timer = 0;
global.faction_favor = array_create(FACTION.WILDLINGS + 1, 0);
faction_favor_seconds_remaining = BALANCE_FAVOR_ROUND_SECONDS;

faction_selection_active = true;
faction_selection_release_pending = false;
// Base references and permanent defeat flags belong to the match controller.
player_base = noone;
faction_match_states = [];
faction_heroes = [];
faction_heroes_initialized = false;
faction_match_started = false;
faction_match_finished = false;
faction_match_winner = FACTION.NONE;
faction_match_winner_name = "";
player_faction_defeated = false;
faction_choices = [
	{ faction: FACTION.ORDER, name: "Order", description: "Protect the Light, no matter what the cost." },
	{ faction: FACTION.UNDEAD, name: "Undead", description: "The Eternal Army." },
	{ faction: FACTION.DEMONS, name: "Demons", description: "We come from Hell (to take you back with us)." },
	{ faction: FACTION.WILDLINGS, name: "Wildlings", description: "We just wanna destroy." }
];
global.focus_window = FOCUS_WINDOW.FACTION_SELECTION;
global.fog_of_war_visible = true;
global.cheats_enabled = BALANCE_CHEATS_ENABLED;
// F2 toggles the Cannon's automatic reaction to night damage.
global.cannon_damage_reaction_enabled = true;
global.play_music = BALANCE_PLAY_MUSIC;
global.tutorial_hints_enabled = false;
global.music_volume = 0.8;
global.ambient_volume = 0.8;
global.sound_volume = 0.8;
global.edge_scroll_enabled = true;
global.edge_scroll_speed = 0.5;
global.camera_speed = 0.5;
global.game_speed_normal = BALANCE_GAME_SPEED_NORMAL;
global.gameplay_time_scale = 1;
game_set_speed(global.game_speed_normal, gamespeed_fps);


// Per-night regular attack settings; nights after the final entry reuse that entry.
// Each inner enemy_types array defines one direction, capped by markers placed in the room.
// Example: enemy_types: [[o_enemy_peasant, o_enemy_archer], [o_enemy_knight]] defines two directions.
// An empty inner array rolls random types; an empty outer array disables regular attack directions.
// Budget is split equally between directions, then types. Waves use one type at a time, in list order.
// Supported regular types: o_enemy_peasant, o_enemy_knight, o_enemy_archer, o_enemy_mage, o_enemy_catapult.
night_attack_balance_by_day = [
	// Day 1.
	{
		difficulty_budget: 60, enemy_hp_multiplier: 1, enemy_damage_multiplier: 1.1,
		enemy_types: [
			[o_enemy_peasant]
		]
	},
	// Day 2.
	{
		difficulty_budget: 75, enemy_hp_multiplier: 1.1, enemy_damage_multiplier: 1.15,
		enemy_types: [
			[o_enemy_archer],
			[o_enemy_peasant]
		]
	},
	// Day 3.
	{
		difficulty_budget: 95, enemy_hp_multiplier: 1.2, enemy_damage_multiplier: 1.25,
		enemy_types: [
			[o_enemy_knight]
		]
	},
	// Day 4: Full Moon.
	{
		difficulty_budget: 169, enemy_hp_multiplier: 1.24, enemy_damage_multiplier: 1.3,
		enemy_types: [
			[o_enemy_knight],
			[o_enemy_knight, o_enemy_archer]
		]
	},
	// Day 5.
	{
		difficulty_budget: 160, enemy_hp_multiplier: 1.29, enemy_damage_multiplier: 1.35,
		enemy_types: [
			[o_enemy_archer, o_enemy_peasant],
			[o_enemy_knight],
			[o_enemy_peasant]
		]
	},
	// Day 6: Griffith.
	{
		difficulty_budget: 78, enemy_hp_multiplier: 1.34, enemy_damage_multiplier: 1.42,
		enemy_types: [
			[o_enemy_knight]
		]
	},
	// Day 7.
	{
		difficulty_budget: 220, enemy_hp_multiplier: 1.38, enemy_damage_multiplier: 1.5,
		enemy_types: [
			[o_enemy_mage],
			[o_enemy_mage]
		]
	},
	// Day 8: Full Moon.
	{
		difficulty_budget: 280, enemy_hp_multiplier: 1.72, enemy_damage_multiplier: 1.6,
		enemy_types: [
			[o_enemy_peasant],
			[o_enemy_mage, o_enemy_knight]
		]
	},
	// Day 9.
	{
		difficulty_budget: 230, enemy_hp_multiplier: 2, enemy_damage_multiplier: 1.9,
		enemy_types: [
			[o_enemy_catapult, o_enemy_peasant],
			[o_enemy_catapult, o_enemy_peasant],
		]
	},
	// Day 10.
	{
		difficulty_budget: 230, enemy_hp_multiplier: 2.25, enemy_damage_multiplier: 2.35,
		enemy_types: [
			[ o_enemy_knight, o_enemy_catapult],
			[ o_enemy_knight, o_enemy_mage]
		]
	},
	// Day 11: Full Moon.
	{
		difficulty_budget: 300, enemy_hp_multiplier: 2.45, enemy_damage_multiplier: 2.55,
		enemy_types: [
			[o_enemy_archer, o_enemy_knight, o_enemy_mage]
		]
	},
	// Day 12.
	{
		difficulty_budget: 230, enemy_hp_multiplier: 2.45, enemy_damage_multiplier: 2.75,
		enemy_types: [
			[o_enemy_mage, o_enemy_knight],
			[o_enemy_mage, o_enemy_knight]
		]
	},
	// Day 13: Crusader horde boss.
	{
		difficulty_budget: 132, enemy_hp_multiplier: 2.7, enemy_damage_multiplier: 2.95,
		enemy_types: [
			[o_enemy_peasant]
		]
	},
	// Day 14.
	{
		difficulty_budget: 230, enemy_hp_multiplier: 2.9, enemy_damage_multiplier: 3.2,
		enemy_types: [
			[o_enemy_knight, o_enemy_archer],
			[o_enemy_catapult, o_enemy_archer]
		]
	},
	// Day 15.
	{
		difficulty_budget: 230, enemy_hp_multiplier: 3.3, enemy_damage_multiplier: 3.3,
		enemy_types: [
			[o_enemy_peasant],
			[o_enemy_knight],
			[o_enemy_archer],
			[o_enemy_mage],
		]
	},
	// Day 16.
	{
		difficulty_budget: 230, enemy_hp_multiplier: 3.8, enemy_damage_multiplier: 3.4,
		enemy_types: [
			[o_enemy_peasant, o_enemy_catapult],
			[o_enemy_peasant, o_enemy_archer]
		]
	},
	// Day 17 and later.
	{
		difficulty_budget: 230, enemy_hp_multiplier: 4.5, enemy_damage_multiplier: 3.5,
		enemy_types: [
			[o_enemy_knight, o_enemy_archer],
			[o_enemy_peasant, o_enemy_mage]
		]
	}
];

// Q toggles double simulation speed during the night.
night_fast_forward_active = false;
night_fast_forward_multiplier = 2;

// Targeting and fast-forward scale gameplay while rendering, input, and camera remain at 60 FPS.

// Global day cycle uses fixed day and night timers.
global.day_phase = DAY_PHASE.FREEFORM;
global.day_duration = BALANCE_DAY_DURATION;
global.night_duration = BALANCE_NIGHT_DURATION;
global.day_timer = global.day_duration * global.game_speed_normal;
night_duration_current = global.night_duration;
global.night_attack_unit_count = 0;
global.full_moon_night_active = false;
global.unholy_night_active = false;
global.blood_moon_reward_popup_active = false;
global.early_upgrade_popup_active = false;
global.game_completion_popup_active = false;
global.player_tower_radius_multiplier = 1;
// Foundry tower bonuses are additive shares of each tower's base stats.
global.foundry_tower_damage_base_bonus = 0;
global.foundry_tower_radius_base_bonus = 0;
global.player_tainted_ground_healing_active = false;
global.day_cycle_enabled = false;
global.legacy_building_logic_enabled = false;
global.archdemons = array_create(0);
global.squads = [];
global.dragged_squad = noone;
// Each Unholy Shrine Rite may successfully grant its trait only once per run.
global.unholy_traits_used = array_create(UNHOLY_TRAIT.COUNT, false);
// Archdemon, Undead, and Demon squads all consume the same day-based shared slots.
global.squad_limit = BALANCE_SQUAD_LIMIT;
// Archdemons keep the existing combat and cannon lifecycle; regular cultists belong to day events.
global.event_cultists = array_create(0);
global.cultist_limit = BALANCE_STARTING_CULTIST_LIMIT;
// The possessed cannon's mood is shared by Jobs, shell recharge, and HUD systems.
global.cannon_satisfaction = BALANCE_CANNON_SATISFACTION_START;
// Shift + F8 blocks Satisfaction changes only during forced enemy cleanup and morning setup.
debug_night_skip_satisfaction_locked = false;
// Creating a regular building event immediately consumes its daily allowance.
global.building_construction_count_today = 0;
global.blood_bath_infernal_regeneration_uses = 0;
global.blood_bath_warpaint_morning_pending = false;
global.blood_bath_lingering_wounds_morning_pending = false;
global.blood_bath_warpaint_affects_unconscious = false;
global.blood_bath_lingering_wounds_affects_unconscious = false;
global.blood_bath_undying_devotion_pending = false;
global.blood_bath_undying_devotion_dead_cultists = [];
global.world_job_first_archdemon_completed = false;
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
global.ritual_lesser_gate_active = false;
global.ritual_hell_weakest_active = false;
global.ritual_hell_weakest_squad = noone;
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
global.day_event_completed_events = [];
// Personal Rites are offered once daily; their history includes ignored offers.
global.cultist_event_history = [];
global.cultist_event_generated_day = -1;
// Mastery offers use an independent FIFO queue and at most one visible offer per day.
cultist_mastery_queue = [];
cultist_mastery_event = noone;
cultist_mastery_generated_day = -1;
global.next_rite_hp_discount = 0;
global.blood_bath_daily_heal_bonus = 0;
global.day_event_executed_log_lines = [];
// Assign Rites shows this completed-day snapshot on the morning after a Shift + F8 day skip.
debug_previous_day_event_lines = [];
debug_previous_day_event_day = -1;
debug_previous_day_report_visible = false;
debug_previous_day_report_pending = false;
// Jobs actions have daily use counts; pinned events are consumed the following morning.
global.day_event_rerolls_remaining = 0;
global.day_event_pins_remaining = BALANCE_DAY_EVENT_DAILY_PIN_COUNT;
global.day_event_pinned_events = [];
global.world_event_hover_building = noone;
global.world_event_squad_selector_building = noone;
global.world_event_squad_selector_event = noone;
global.world_event_squad_selector_close_pending = false;
global.world_event_squad_selector_preserve_hover = false;
cannon_satisfaction_window_previous_pause_state = false;
cannon_satisfaction_cursor_is_hidden = false;


global.shrine_objective_complete = false;
global.first_night_cultist_projectile_fired = false;
global.tutorial_popup_active = false;
global.tutorial_welcome_closed = !global.tutorial_hints_enabled;
global.cursed_point_structure_selection_source = noone;
global.squad_point_selection_source = noone;

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

// Blood Moon preparation is queued at daybreak and waits only for unobstructed control.
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
blood_moon_reward_previous_focus_window = FOCUS_WINDOW.NOONE;
blood_moon_reward_previous_pause_state = false;
blood_moon_reward_focus_restore_pending = false;

// The final modal permanently stops the run after the survival objective is completed.
game_completion_popup_width = 760;
game_completion_popup_height = 300;
game_completion_button_width = 340;
game_completion_button_height = 58;
game_completion_button_bottom_padding = 30;
game_completion_button_hovered = false;
game_completion_input_blocked = false;
game_completion_popup_was_shown = false;
game_completion_feedback_url = "https://docs.google.com/forms/d/e/1FAIpQLSfgL-bwMH9ZA8Qg0vJVbVQYc794G50wqBUqDl-JQ_p5rO13bw/viewform";

// Permanent blessings used by morning spawning, trap activation, and unit deaths.
tainted_gifts_active = false;
twice_the_pain_active = false;
rise_again_active = false;
no_rest_for_the_dead_active = false;
no_rest_for_the_dead_used = false; // Shared by all squads; reset at nightfall.

// One permanent choice on each configured reward morning.
day_five_upgrade_choice_completed = false;
day_nine_upgrade_choice_completed = false;
early_upgrade_popup_set = DAYBREAK_UPGRADE_SET.DAY_FIVE;
early_upgrade_popup_pending = false;
early_upgrade_popup_input_blocked = false;
early_upgrade_popup_previous_focus_window = FOCUS_WINDOW.NOONE;
early_upgrade_popup_previous_pause_state = false;
early_upgrade_popup_focus_restore_pending = false;
early_upgrade_popup_hovered_choice = -1;

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
global.particle_type_status_slow = part_type_create();
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

part_type_sprite(global.particle_type_status_slow, s_slow_particle, false, false, true);
part_type_size(
	global.particle_type_status_slow,
	BALANCE_STATUS_PARTICLE_SIZE_MIN,
	BALANCE_STATUS_PARTICLE_SIZE_MAX,
	-0.005,
	0
);
part_type_color1(global.particle_type_status_slow, COLOR_HELLCOW_STICKY_TRAIL);
part_type_alpha2(global.particle_type_status_slow, 0.9, 0);
part_type_speed(
	global.particle_type_status_slow,
	BALANCE_STATUS_PARTICLE_SPEED_MIN,
	BALANCE_STATUS_PARTICLE_SPEED_MAX,
	-0.01,
	0
);
part_type_direction(global.particle_type_status_slow, 250, 290, 0, 0);
part_type_life(global.particle_type_status_slow, BALANCE_STATUS_PARTICLE_LIFE_MIN, BALANCE_STATUS_PARTICLE_LIFE_MAX);

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
global.cannon_target_direction = 0;
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
	PROJECTILE_TYPE.SKELETONS
];
global.cannon_projectile_cheat_enabled = global.cheats_enabled;
global.rally_projectile_group_id = 0;
global.cannon_satiety = 0;
global.cannon_satiety_max = BALANCE_CANNON_SATIETY_MAX;
global.cannon_corpses_delivered_today = 0;
// The selected Taint Compost enchantment and its match-long one-use event state.
global.shell_factory_taint_enchantment = TAINT_COMPOST_ENCHANTMENT.NONE;
global.shell_factory_taint_enchantment_event_completed = false;
// First Aid Meat has its own independent match-long enchantment choice.
global.shell_factory_first_aid_enchantment = FIRST_AID_MEAT_ENCHANTMENT.NONE;
global.shell_factory_first_aid_enchantment_event_completed = false;
// HellCow has its own independent match-long enchantment choice.
global.shell_factory_hellcow_enchantment = HELLCOW_ENCHANTMENT.NONE;
global.shell_factory_hellcow_enchantment_event_completed = false;
// Doom Bell has its own independent match-long enchantment choice.
global.shell_factory_doom_bell_enchantment = DOOM_BELL_ENCHANTMENT.NONE;
global.shell_factory_doom_bell_enchantment_event_completed = false;
// Shell Factory upgrades are permanent and each event can be completed once per match.
global.shell_factory_taint_bloom_event_completed = false;
global.shell_factory_opening_barrage_event_completed = false;
global.shell_factory_favored_ammunition_projectile_type = noone;
global.shell_factory_favored_ammunition_event_completed = false;

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
	ui_hover_03,
	ui_hover_05,
	
];
global.ui_confirm_sound = ui_confirm97;
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

ui_hover_candidate_get = function(_mouse_x, _mouse_y)
{
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
	player_building_ground_check_timer += global.gameplay_time_scale;

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

corpse_bonelets_raise_in_radius = function(_origin_x, _origin_y, _radius, _maximum_count)
{
	var _raise_limit = max(0, floor(_maximum_count));
	var _radius_squared = _radius * _radius;
	var _raised_count = 0;

	// Consume the nearest corpse in the impact area for each temporary Bonelet.
	for (var _raise_index = 0; _raise_index < _raise_limit; ++_raise_index)
	{
		var _nearest_corpse_index = -1;
		var _nearest_distance_squared = infinity;
		var _corpse_count = array_length(corpse_draw_data);

		for (var _corpse_index = 0; _corpse_index < _corpse_count; ++_corpse_index)
		{
			var _corpse = corpse_draw_data[_corpse_index];
			var _distance_x = _corpse.x - _origin_x;
			var _distance_y = _corpse.y - _origin_y;
			var _distance_squared = (_distance_x * _distance_x) + (_distance_y * _distance_y);

			if (_distance_squared <= _radius_squared
				&& _distance_squared < _nearest_distance_squared)
			{
				_nearest_corpse_index = _corpse_index;
				_nearest_distance_squared = _distance_squared;
			}
		}

		if (_nearest_corpse_index < 0)
		{
			break;
		}

		var _chosen_corpse = corpse_draw_data[_nearest_corpse_index];
		var _bonelet = instance_create_layer(
			_chosen_corpse.x,
			_chosen_corpse.y,
			"Instances",
			o_skeleton_bonelet
		);

		if (!instance_exists(_bonelet))
		{
			break;
		}

		// Necromedic summons are independent and expire during morning cleanup.
		_bonelet.squad = noone;
		_bonelet.squad_unit_index = -1;
		_bonelet.projectile_skeleton_dies_at_morning = true;
		_bonelet.regroup_is_active = false;
		_bonelet.rally_is_active = false;
		_bonelet.target_instance = noone;
		_bonelet.alert_target = noone;

		array_delete(corpse_draw_data, _nearest_corpse_index, 1);
		_raised_count++;
	}

	return _raised_count;
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
// The first construction window is locked to Blood Bath during onboarding.
building_blood_bath_tutorial_active = false;
building_blood_bath_tutorial_text = "Summon a Blood Bath so you can heal your Cultists.";
building_blood_bath_tutorial_max_width = 390;
building_blood_bath_tutorial_line_height = 24;
building_blood_bath_tutorial_padding_x = 14;
building_blood_bath_tutorial_padding_y = 10;
building_blood_bath_tutorial_gap_from_arrow = 20;
building_blood_bath_tutorial_background_alpha = 0.92;
building_blood_bath_tutorial_arrow_scale = 0.35;
building_blood_bath_tutorial_arrow_angle = 0;
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
building_group_gap_y = 42;
building_tooltip_width = 310;
building_tooltip_height = 120;
building_tooltip_padding = 12;
// Building event catalog is read-only and supports mouse-wheel scrolling.
building_events_window_building = noone;
building_events_window_entries = [];
building_events_window_current_event = noone;
building_events_window_name = "";
building_events_previous_pause_state = false;
building_events_input_blocked = false;
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
		building_description: "Allows performing operations with blood to heal your cultitsts.",
		iron_cost: BALANCE_BUILDING_IRON_COST
	},
	{
		building_object: o_summoning_grounds,
		building_sprite: s_ritual_circle,
		building_name: "Summoning Grounds",
		building_group: "Other",
		building_description: "Summons specialist units directly into selected squads.",
		iron_cost: BALANCE_SUMMONING_GROUNDS_BUILDING_IRON_COST
	},
	{
		building_object: o_unholy_shrine,
		building_sprite: s_unholy_shrine,
		building_name: "Unholy Shrine",
		building_group: "Other",
		building_description: "Opens access to rituals that endow squads with Unholy traits.",
		iron_cost: BALANCE_BUILDING_IRON_COST
	},
	{
		building_object: o_shell_factory,
		building_sprite: s_shell_factory,
		building_name: "Shell Factory",
		building_group: "Other",
		building_description: "Produces squad shells while staffed and offers permanent shell improvements.",
		iron_cost: BALANCE_BUILDING_IRON_COST
	},
	{
		building_object: o_foundry,
		building_sprite: s_foundry,
		building_name: "Foundry",
		building_group: "Other",
		building_description: "Allows forging Relics for squads.",
		iron_cost: BALANCE_BUILDING_IRON_COST
	}
];

foundry_shell_choices = [
	{
		building_object: o_tower_damage,
		building_sprite: s_damage_tower,
		building_name: "Damage Tower",
		building_description: "Forges a shell that summons a tower shooting enemies around itself.",
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
		building_object: o_orcs_hut,
		building_sprite: s_orks_hut,
		building_name: "Orcs Pit",
		building_description: "Forges a shell that summons a pit with two neutral corpse-hauling orcs.",
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
		building_description: "Forges a shell that summons a spire spawning Skeletons every morning.",
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
		building_description: "Forges a shell that summons an extractor collecting Ihor from nearby veins each morning.",
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
debug_menu_tab = "squads";
debug_menu_tab_ids = ["units", "squads"];
debug_menu_tab_labels = ["Units", "Squads"];

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
		label: "Taint Compost",
		projectile_type: PROJECTILE_TYPE.CORRUPTION,
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
		label: "Bone Archer",
		unit_object: o_skeleton_archer
	},
	{
		label: "Bone Mage",
		unit_object: o_skeleton_mage
	},
	{
		label: "Skeleton Healer",
		unit_object: o_skeleton_healer
	},
	{
		label: "Bone Warrior",
		unit_object: o_skeleton_warrior
	},
	{
		label: "Ripcage Cannon",
		unit_object: o_ripcage_cannon
	},
	{
		label: "Bone Bannerman",
		unit_object: o_bone_bannerman
	},
	{
		label: "Provocateur",
		unit_object: o_provocateur
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
	{ label: "BONE WARRIOR", unit_object: o_skeleton_warrior, squad_type: SQUAD_TYPE.UNDEAD, unit_count: BALANCE_SQUAD_SKELETON_COUNT },
	{ label: "BONE ARCHER", unit_object: o_skeleton_archer, squad_type: SQUAD_TYPE.UNDEAD, unit_count: BALANCE_SQUAD_SKELETON_COUNT },
	{ label: "BONE MAGE", unit_object: o_skeleton_mage, squad_type: SQUAD_TYPE.UNDEAD, unit_count: BALANCE_SQUAD_SKELETON_COUNT },
	{ label: "SKEL HEALER", unit_object: o_skeleton_healer, squad_type: SQUAD_TYPE.UNDEAD, unit_count: BALANCE_SQUAD_SKELETON_COUNT },
	{ label: "RIPCAGE CANNON", unit_object: o_ripcage_cannon, squad_type: SQUAD_TYPE.UNDEAD, unit_count: BALANCE_SQUAD_SKELETON_COUNT },
	{ label: "BONE BANNERMAN", unit_object: o_bone_bannerman, squad_type: SQUAD_TYPE.UNDEAD, unit_count: BALANCE_SQUAD_SKELETON_COUNT },
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
	return debug_menu_tab == "units" ? debug_unit_choices : debug_squad_choices;
};

debug_menu_hint_get = function()
{
	return debug_menu_tab == "units" ? "Spawn: LMB x1 / RMB x5" : "Add a squad";
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
	return is_struct(squad_create(_squad_type, _choice.unit_object, _choice.unit_count));
};

debug_unholy_bone_warrior_squad_create = function(_unholy_trait)
{
	if (_unholy_trait <= UNHOLY_TRAIT.NONE || _unholy_trait >= UNHOLY_TRAIT.COUNT)
	{
		return false;
	}

	// squad_create appends to the first free shared slot and reserves a free daytime point.
	var _squad = squad_create(
		SQUAD_TYPE.UNDEAD,
		o_skeleton_warrior,
		BALANCE_SQUAD_SKELETON_COUNT
	);

	if (!is_struct(_squad))
	{
		return false;
	}

	return squad_unholy_trait_set(_squad, _unholy_trait);
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
		_unit_was_spawned = true;
	}

	return _unit_was_spawned;
};

debug_menu_choice_activate = function(_choice, _unit_spawn_count = 1)
{
	return debug_menu_tab == "units"
		? debug_unit_spawn(_choice.unit_object, _unit_spawn_count)
		: debug_squad_create(_choice);
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

// Flag System 2 selection belongs to the controller; orders remain on their squads after deselection.
squad_flag_system_2_enabled = SQUAD_FLAG_SYSTEM_2_ENABLED;
selected_squad = noone;
squad_attack_move_armed = false;

squad_control_selection_clear = function()
{
	if (is_struct(selected_squad))
	{
		selected_squad.properties.is_selected = false;
	}
	selected_squad = noone;
	squad_attack_move_armed = false;
};

squad_flag_system_set = function(_use_system_2)
{
	squad_control_selection_clear();
	if (is_struct(global.dragged_squad))
	{
		squad_drag_end(global.dragged_squad, false);
	}
	var _squad_count = array_length(global.squads);
	for (var _index = 0; _index < _squad_count; ++_index)
	{
		squad_order_clear(global.squads[_index]);
		squad_march_end(global.squads[_index]);
	}
	squad_flag_system_2_enabled = _use_system_2;
};

// Run before other input, so a click elsewhere always deselects and Escape cannot open the menu.
squad_control_selection_update = function()
{
	if (!is_struct(selected_squad))
	{
		return false;
	}
	if (!squad_flag_system_2_enabled || global.player_faction == FACTION.NONE
		|| global.focus_window != FOCUS_WINDOW.NOONE
		|| !squad_is_player_owned(selected_squad)
		|| !squad_active_is_registered(selected_squad)
		|| squad_living_unit_count_get(selected_squad) <= 0)
	{
		squad_control_selection_clear();
		return false;
	}
	if (keyboard_check_pressed(vk_escape))
	{
		squad_control_selection_clear();
		return true;
	}
	if (mouse_check_button_pressed(mb_left))
	{
		squad_control_selection_clear();
	}
	else if (keyboard_check_pressed(ord("A")))
	{
		squad_attack_move_armed = true;
	}
	return false;
};

squad_control_pointer_over_hud = function(_mouse_x, _mouse_y)
{
	if (!instance_exists(o_hud))
	{
		return false;
	}
	var _hud = instance_find(o_hud, 0);
	var _minimap_position = _hud.minimap_world_position_from_gui(_mouse_x, _mouse_y);
	return _minimap_position[0]
		|| is_struct(_hud.hud_squad_at_gui_position(_mouse_x, _mouse_y))
		|| is_struct(_hud.projectile_slot_at_gui_position(_mouse_x, _mouse_y, id))
		|| (variable_global_exists("squad_info_window_open") && global.squad_info_window_open);
};

squad_control_world_input_update = function(_world_x, _world_y, _gui_x, _gui_y)
{
	// HUD hit testing builds slot layouts, so only do it when a click can issue a command.
	if (!mouse_check_button_pressed(mb_left) && !mouse_check_button_pressed(mb_right))
	{
		return false;
	}
	if (!squad_flag_system_2_enabled || global.player_faction == FACTION.NONE
		|| global.focus_window != FOCUS_WINDOW.NOONE
		|| instance_exists(global.dragged_cultist) || instance_exists(global.dragged_artifact)
		|| squad_control_pointer_over_hud(_gui_x, _gui_y))
	{
		return false;
	}
	if (mouse_check_button_pressed(mb_left))
	{
		var _picked = squad_marker_find_at_position(_world_x, _world_y);
		if (is_struct(_picked) && squad_living_unit_count_get(_picked) > 0)
		{
			selected_squad = _picked;
			_picked.properties.is_selected = true;
			global.sound_play_random(global.pick_worker_sounds);
			return true;
		}
	}
	else if (is_struct(selected_squad) && mouse_check_button_pressed(mb_right))
	{
		var _mode = squad_attack_move_armed ? SQUAD_ORDER.MOVE_AND_ATTACK : SQUAD_ORDER.MOVE;
		if (squad_order_issue(selected_squad, _world_x, _world_y, _mode))
		{
			squad_attack_move_armed = false;
			global.sound_play_random(global.release_worker_sounds);
			return true;
		}
	}
	return false;
};

// Cannon target selection state.
target_selection_projectile_type = PROJECTILE_TYPE.DAMAGE;
target_selection_radius = BALANCE_PROJECTILE_EFFECT_RADIUS;
target_selection_alpha = 0.35;
target_selection_outline_alpha = 0.85;
hellcow_aim_is_dragging = false;
hellcow_aim_start_x = 0;
hellcow_aim_start_y = 0;
hellcow_aim_direction = 0;
hellcow_aim_drag_distance = 0;
// Keep the confirmed range until the Cannon copies it, even after aiming is closed.
hellcow_target_charge_distance = BALANCE_PROJECTILE_HELLCOW_CHARGE_DISTANCE;
cannon_projectile_night_slots = []; // Fixed number-key assignments captured at the start of each night.

// Preview and firing share the same world-space drag limits, independently of camera zoom.


// Building shell previews use the future structure's gameplay radius when it has one.


// Building shell preview circles match the hover radius colors of built structures.

cannon_projectile_type_is_reusable = function(_projectile_type)
{
	return _projectile_type == PROJECTILE_TYPE.BOMB
		|| _projectile_type == PROJECTILE_TYPE.HEAL
		|| _projectile_type == PROJECTILE_TYPE.DOOM_BELL;
};

cannon_projectile_type_can_stack_in_hud = function(_projectile_type)
{
	return _projectile_type != PROJECTILE_TYPE.CULTIST
		&& _projectile_type != PROJECTILE_TYPE.BUILDING_SHELL
		&& !cannon_projectile_type_is_reusable(_projectile_type);
};

cannon_projectile_live_slots_get = function(_max_display_count)
{
	var _slots = array_create(0);

	if (!variable_global_exists("cannon_projectile_queue"))
	{
		return _slots;
	}

	var _projectile_queue_count = array_length(global.cannon_projectile_queue);
	var _payload_queue_count = array_length(global.cannon_projectile_payload_queue);

	for (var _queue_index = 0; _queue_index < _projectile_queue_count; ++_queue_index)
	{
		var _projectile_type = global.cannon_projectile_queue[_queue_index];
		var _display_index = -1;

		// Ignore legacy corpse-fed Taint entries from old runtime state.
		if (_projectile_type == PROJECTILE_TYPE.FEAST)
		{
			continue;
		}

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
			var _projectile_payload = noone;

			if (_queue_index < _payload_queue_count)
			{
				_projectile_payload = global.cannon_projectile_payload_queue[_queue_index];
			}

			array_push(_slots, {
				projectile_type: _projectile_type,
				queue_index: _queue_index,
				consume_queue_index: _queue_index,
				count: 1,
				payload: _projectile_payload
			});
		}
	}

	return _slots;
};

cannon_projectile_display_slots_get = function(_max_display_count)
{
	var _live_slots = cannon_projectile_live_slots_get(_max_display_count);

	if (global.player_faction == FACTION.NONE || array_length(cannon_projectile_night_slots) <= 0)
	{
		return _live_slots;
	}

	var _slots = [];
	var _live_slot_count = array_length(_live_slots);
	var _live_slot_was_used = array_create(_live_slot_count, false);
	var _fixed_slot_count = min(_max_display_count, array_length(cannon_projectile_night_slots));

	// Rebuild current queue data in the fixed order captured when the night began.
	for (var _fixed_index = 0; _fixed_index < _fixed_slot_count; ++_fixed_index)
	{
		var _fixed_slot = cannon_projectile_night_slots[_fixed_index];
		var _matching_live_index = -1;
		var _can_stack = cannon_projectile_type_can_stack_in_hud(_fixed_slot.projectile_type);

		for (var _live_index = 0; _live_index < _live_slot_count; ++_live_index)
		{
			if (_live_slot_was_used[_live_index])
			{
				continue;
			}

			var _live_slot = _live_slots[_live_index];
			var _payload_matches = _live_slot.payload == _fixed_slot.payload;

			// Relaunched squads have new units but retain their original number-key slot.
			if (!_payload_matches && is_struct(_fixed_slot.squad)
				&& instance_exists(_live_slot.payload)
				&& variable_instance_exists(_live_slot.payload, "squad"))
			{
				_payload_matches = _live_slot.payload.squad == _fixed_slot.squad;
			}

			var _slot_matches = _live_slot.projectile_type == _fixed_slot.projectile_type
				&& (_can_stack || _payload_matches);

			if (_slot_matches)
			{
				_matching_live_index = _live_index;
				break;
			}
		}

		if (_matching_live_index >= 0)
		{
			array_push(_slots, _live_slots[_matching_live_index]);
			_live_slot_was_used[_matching_live_index] = true;
		}
		else
		{
			array_push(_slots, {
				projectile_type: _fixed_slot.projectile_type,
				queue_index: -1,
				consume_queue_index: -1,
				count: 0,
				payload: _fixed_slot.payload
			});
		}
	}

	// New projectile types may use free digits without moving the fixed slots.
	var _slot_count = array_length(_slots);

	for (var _remaining_index = 0; _remaining_index < _live_slot_count; ++_remaining_index)
	{
		if (_slot_count >= _max_display_count)
		{
			break;
		}

		if (!_live_slot_was_used[_remaining_index])
		{
			array_push(_slots, _live_slots[_remaining_index]);
			_slot_count++;
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
settings_panel_height = SQUAD_FLAG_SYSTEM_SETTING_VISIBLE ? 620 : 560;
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
settings_flag_system_x = 48;
settings_flag_system_y = 468;
settings_flag_system_width = 324;
settings_flag_system_height = 36;
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

settings_flag_system_rect_get = function()
{
	return {
		x: (camera_view_width - settings_panel_width) * 0.5 + settings_flag_system_x,
		y: (camera_view_height - settings_panel_height) * 0.5 + settings_flag_system_y,
		width: settings_flag_system_width,
		height: settings_flag_system_height
	};
};

// Cultist prototype state.
starting_archdemon_count = BALANCE_STARTING_ARCHDEMON_COUNT;
starting_goblin_count = BALANCE_STARTING_GOBLIN_COUNT;
starting_event_cultist_count = BALANCE_STARTING_EVENT_CULTIST_COUNT;
cultist_reward_days = [];
next_cultist_reward_index = 0;
cultists_spawned = false;
starting_cultist_selection_pending = false;
night_phase_start_pending_after_cultist_selection = false;
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

// Cheat-only balance logging writes one session file into the game's Local AppData folder.
balance_log_file_path = "";
balance_log_has_content = false;
balance_log_text = "";

balance_log_file_save = function()
{
	if (balance_log_file_path == "")
	{
		return false;
	}

	// Write an explicit UTF-8 BOM so external text editors never guess UTF-16.
	var _utf8_bom_bytes = [0xEF, 0xBB, 0xBF];
	var _utf8_bom_byte_count = array_length(_utf8_bom_bytes);
	var _buffer_size = _utf8_bom_byte_count + string_byte_length(balance_log_text);
	var _buffer = buffer_create(_buffer_size, buffer_fixed, 1);

	if (!buffer_exists(_buffer))
	{
		return false;
	}

	for (var _byte_index = 0; _byte_index < _utf8_bom_byte_count; ++_byte_index)
	{
		buffer_write(_buffer, buffer_u8, _utf8_bom_bytes[_byte_index]);
	}

	if (balance_log_text != "")
	{
		buffer_write(_buffer, buffer_text, balance_log_text);
	}

	buffer_save(_buffer, balance_log_file_path);
	buffer_delete(_buffer);
	return file_exists(balance_log_file_path);
};

balance_log_session_start = function()
{
	if (!global.cheats_enabled)
	{
		return false;
	}

	var _session_datetime = date_current_datetime();
	var _day_text = string(date_get_day(_session_datetime));
	var _month_text = string(date_get_month(_session_datetime));
	var _hour_text = string(date_get_hour(_session_datetime));
	var _minute_text = string(date_get_minute(_session_datetime));

	if (string_length(_day_text) < 2)
	{
		_day_text = "0" + _day_text;
	}

	if (string_length(_month_text) < 2)
	{
		_month_text = "0" + _month_text;
	}

	if (string_length(_hour_text) < 2)
	{
		_hour_text = "0" + _hour_text;
	}

	if (string_length(_minute_text) < 2)
	{
		_minute_text = "0" + _minute_text;
	}

	var _file_name = "balance_log_" + _day_text + "_" + _month_text + "_" + _hour_text + _minute_text + ".txt";
	balance_log_file_path = working_directory + _file_name;
	balance_log_has_content = false;
	balance_log_text = "";

	if (!balance_log_file_save())
	{
		balance_log_file_path = "";
		return false;
	}

	return true;
};

balance_log_session_start();

// The nightly player HP snapshot is only read by the cheat balance overlay.
balance_player_hp_snapshot_id = 0;
balance_player_hp_start_total = 0;

boss_griffith_night_interval = BALANCE_BOSS_GRIFFITH_NIGHT_INTERVAL;
boss_griffith_pending_next_night = false;
boss_griffith_pending_direction = 0;
boss_griffith_force_next_night = false;
boss_griffith_night_active = false;
full_moon_night_interval = BALANCE_FULL_MOON_NIGHT_INTERVAL;
// A completed Blood Moon may queue one peaceful night when the feature is enabled.
unholy_night_pending = false;
night_force_end_timer = 0;
night_force_end_active = false;
night_attack_unit_pool = [
	o_enemy_archer,
	o_enemy_knight,
	o_enemy_mage,
	o_enemy_peasant,
	o_enemy_catapult
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

// The metaphorical Holy Cannon schedules warning strikes without a physical map instance.
holy_cannon_fire_timer = 0;

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

	var _fog_state = ds_grid_get(_fog_of_war.fog_grid, _cell_x, _cell_y);
	return _fog_state == _fog_of_war.revealed_state;
};

// Taint Compost shots must overlap existing visible Taint.

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


// Find the topmost empty building slot under a world-space point.


drag_cultist_can_be_picked = function(_cultist)
{
	if (!instance_exists(_cultist))
	{
		return false;
	}

	// Night archdemons are repositioned only through their squad flag.
	if (global.player_faction != FACTION.NONE
		&& variable_instance_exists(_cultist, "squad")
		&& is_struct(_cultist.squad)
		&& _cultist.squad.squad_type == SQUAD_TYPE.ARCHDEMON)
	{
		return false;
	}

	// Event workers are managed only through Assign Rites while the world interface is disabled.
	if (!WORLD_EVENT_INTERFACE_ENABLED
		&& _cultist.object_index == o_cultist
		&& global.day_phase == DAY_PHASE.DAY)
	{
		return false;
	}

	// Archdemons can be repositioned in combat, but are not assigned to buildings by dragging during the day.
	if (_cultist.object_index == o_archdemon && global.player_faction == FACTION.NONE)
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

close_cannon_satisfaction_window = function()
{
	if (global.focus_window != FOCUS_WINDOW.CANNON_SATISFACTION)
	{
		return false;
	}

	global.pause = cannon_satisfaction_window_previous_pause_state;
	player_pause_active = cannon_satisfaction_window_previous_pause_state;
	global.focus_window = FOCUS_WINDOW.NOONE;

	return true;
};

close_building_window = function(_force_close = false)
{
	if (building_blood_bath_tutorial_active && !_force_close)
	{
		return false;
	}

	building_window_slot = noone;
	building_window_foundry = noone;
	building_window_choices = building_choices;
	global.pause = false;
	global.focus_window = FOCUS_WINDOW.NOONE;
	return true;
};

close_building_events_window = function()
{
	building_events_window_building = noone;
	building_events_window_entries = [];
	building_events_window_current_event = noone;
	building_events_window_name = "";
	building_events_scroll_row = 0;
	building_events_input_blocked = false;
	global.pause = building_events_previous_pause_state;
	player_pause_active = building_events_previous_pause_state;
	global.focus_window = FOCUS_WINDOW.NOONE;
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

// Assign a valid worker unit to a building and snap it beside the building.

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

world_event_squad_selector_close = function()
{
	return false;
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

	// An Archdemon belonging to a squad uses that squad's reserved daytime area.
	var _uses_squad_day_point = _worker.object_index == o_archdemon
		&& variable_instance_exists(_worker, "squad")
		&& is_struct(_worker.squad)
		&& instance_exists(squad_day_point_get(_worker.squad));

	if (_uses_squad_day_point)
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
		|| (variable_instance_exists(_worker, "assigned_event") && is_struct(_worker.assigned_event))
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

		_worker.idle_wander_wait_timer -= global.gameplay_time_scale;

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

	_move_speed *= BALANCE_IDLE_WORKER_WANDER_SPEED_MULTIPLIER * global.gameplay_time_scale;

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

cannon_projectile_queue_add = function(_projectile_type, _payload = noone, _allow_reward_overflow = false)
{
	// Taint Compost is the only player-usable Taint projectile.
	if (_projectile_type == PROJECTILE_TYPE.FEAST)
	{
		return false;
	}

	// Reusable special shells occupy one permanent slot and never accumulate.
	if (cannon_projectile_type_is_reusable(_projectile_type)
		&& cannon_projectile_queue_type_count_get(_projectile_type) > 0)
	{
		return false;
	}

	if (!_allow_reward_overflow && array_length(global.cannon_projectile_queue) >= global.cannon_projectile_queue_max)
	{
		return false;
	}

	array_push(global.cannon_projectile_queue, _projectile_type);
	array_push(global.cannon_projectile_payload_queue, _payload);
	global.cannon_selected_projectile_index = clamp(global.cannon_selected_projectile_index, 0, array_length(global.cannon_projectile_queue) - 1);
	global.cannon_projectile_gain_timer = 0;

	return true;
};

cannon_projectile_queue_type_count_get = function(_projectile_type)
{
	var _matching_count = 0;
	var _projectile_count = array_length(global.cannon_projectile_queue);

	for (var _projectile_index = 0; _projectile_index < _projectile_count; ++_projectile_index)
	{
		if (global.cannon_projectile_queue[_projectile_index] == _projectile_type)
		{
			_matching_count++;
		}
	}

	return _matching_count;
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

// Open the demon selection window for a newly received cultist.
open_cultist_demon_selection = function(_selection_index, _default_name = "")
{
	cultist_selection_index = _selection_index;
	cultist_selected_demon_type = DEMON_TYPE.IMP;
	cultist_selected_starting_ability = cultist_starting_ability_default_get(cultist_selected_demon_type);
	cultist_name_input_active = true;
	keyboard_string = string_copy(_default_name, 1, 16);
	global.pause = true;
	global.focus_window = FOCUS_WINDOW.CULTIST_DEMON_SELECTION;
};

// Start the night only after every Archdemon created by daytime events has been configured.


// Add extra cultists on fixed early days.

cultist_starting_ability_default_get = function(_demon_type)
{
	var _active_abilities = cultist_demon_active_abilities_get(_demon_type);

	if (array_length(_active_abilities) <= 0)
	{
		return DEMON_ABILITY.NONE;
	}

	return _active_abilities[0];
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

night_attack_balance_get = function(_night_index)
{
	var _balance_day_count = array_length(night_attack_balance_by_day);

	if (_balance_day_count <= 0)
	{
		return {
			difficulty_budget: 0,
			enemy_hp_multiplier: 1,
			enemy_damage_multiplier: 1,
			enemy_types: []
		};
	}

	var _balance_day_index = min(max(1, _night_index), _balance_day_count) - 1;
	return night_attack_balance_by_day[_balance_day_index];
};

// Validate one direction's list against the regular unit catalog, preserving type order.

enemy_night_balance_scale_apply = function(_enemy)
{
	// RTS enemies use their base combat statistics.
};

combat_unit_matchup_get = function(_unit_object)
{
	// Keep world hover and enemy preview guidance in one shared matchup table.
	var _strong_against = [];
	var _weak_against = [];

	if (_unit_object == o_skeleton_bonelet)
	{
		_strong_against = [o_enemy_mage];
		_weak_against = [o_enemy_peasant, o_enemy_knight];
	}
	else if (_unit_object == o_skeleton)
	{
		_strong_against = [o_enemy_peasant];
		_weak_against = [o_enemy_mage];
	}
	else if (_unit_object == o_skeleton_warrior)
	{
		_strong_against = [o_enemy_peasant, o_enemy_catapult];
		_weak_against = [o_enemy_mage];
	}
	else if (_unit_object == o_skeleton_archer)
	{
		_strong_against = [o_enemy_archer, o_enemy_mage];
		_weak_against = [o_enemy_knight, o_enemy_catapult];
	}
	else if (_unit_object == o_skeleton_mage)
	{
		_strong_against = [o_enemy_knight, o_enemy_mage];
		_weak_against = [o_enemy_peasant, o_enemy_catapult];
	}
	else if (_unit_object == o_skeleton_healer
		|| _unit_object == o_bone_bannerman
		|| _unit_object == o_demon_wizard)
	{
		_strong_against = [o_enemy_mage];
		_weak_against = [o_enemy_peasant, o_enemy_catapult];
	}
	else if (_unit_object == o_zombie)
	{
		_strong_against = [o_enemy_peasant, o_enemy_knight, o_enemy_catapult];
		_weak_against = [o_enemy_mage];
	}
	else if (_unit_object == o_mawling)
	{
		_strong_against = [o_enemy_mage];
		_weak_against = [o_enemy_peasant, o_enemy_knight];
	}
	else if (_unit_object == o_pitling)
	{
		_strong_against = [o_enemy_archer];
		_weak_against = [o_enemy_mage];
	}
	else if (_unit_object == o_succubus)
	{
		_strong_against = [o_enemy_archer, o_enemy_knight];
		_weak_against = [o_enemy_peasant];
	}
	else if (_unit_object == o_balgor)
	{
		_strong_against = [o_enemy_peasant, o_enemy_knight, o_enemy_catapult];
		_weak_against = [o_enemy_archer, o_enemy_mage];
	}
	else if (_unit_object == o_imp || _unit_object == o_imp_clone)
	{
		_strong_against = [o_enemy_archer, o_enemy_mage];
		_weak_against = [o_enemy_knight];
	}
	else if (_unit_object == o_warlock)
	{
		_strong_against = [o_enemy_knight, o_enemy_mage];
		_weak_against = [o_enemy_peasant, o_enemy_catapult];
	}
	else if (_unit_object == o_brute)
	{
		_strong_against = [o_enemy_peasant, o_enemy_knight, o_enemy_catapult];
		_weak_against = [o_enemy_archer, o_enemy_mage];
	}
	else if (_unit_object == o_enemy_peasant)
	{
		_strong_against = [o_skeleton_mage, o_succubus];
		_weak_against = [o_skeleton_warrior, o_balgor];
	}
	else if (_unit_object == o_enemy_archer)
	{
		_strong_against = [o_balgor];
		_weak_against = [o_skeleton_archer, o_pitling, o_succubus];
	}
	else if (_unit_object == o_enemy_knight)
	{
		_strong_against = [o_skeleton_archer];
		_weak_against = [o_skeleton_mage, o_succubus, o_balgor];
	}
	else if (_unit_object == o_enemy_mage)
	{
		_strong_against = [o_skeleton_warrior, o_pitling, o_balgor];
		_weak_against = [o_skeleton_archer, o_skeleton_mage];
	}
	else if (_unit_object == o_enemy_catapult)
	{
		_strong_against = [o_skeleton_archer, o_skeleton_mage];
		_weak_against = [o_skeleton_warrior, o_balgor];
	}

	return {
		strong_against: _strong_against,
		weak_against: _weak_against
	};
};

player_unit_object_stats_card_draw = function(_unit_object, _hover_x, _hover_y, _card_font = -1)
{
	if (!instance_exists(o_hud))
	{
		return;
	}

	var _stats = o_hud.hud_unit_base_stats_get(_unit_object);

	if (!is_struct(_stats))
	{
		return;
	}

	var _matchup = combat_unit_matchup_get(_unit_object);
	var _strong_against = _matchup.strong_against;
	var _weak_against = _matchup.weak_against;
	var _strong_count = array_length(_strong_against);
	var _weak_count = array_length(_weak_against);
	var _matchup_row_count = (_strong_count > 0 ? 1 : 0) + (_weak_count > 0 ? 1 : 0);
	var _hover_width = 260;
	var _hover_height = 248 + (_matchup_row_count > 0 ? 12 + (48 * _matchup_row_count) : 0);
	var _hover_padding = 14;
	var _gui_width = display_get_gui_width();
	var _gui_height = display_get_gui_height();
	var _hover_margin = 18;
	var _card_x = clamp(_hover_x, _hover_margin, max(_hover_margin, _gui_width - _hover_width - _hover_margin));
	var _card_y = clamp(_hover_y, _hover_margin, max(_hover_margin, _gui_height - _hover_height - _hover_margin));
	var _damage_text = "Damage: " + string_format(_stats.damage, 0, 1);
	var _attack_speed = room_speed / max(_stats.reload_time, 1);

	// Use the caller's UI font so the card never inherits an unrelated large font.
	if (font_exists(_card_font))
	{
		draw_set_font(_card_font);
	}
	else if (variable_global_exists("ui_font") && font_exists(global.ui_font))
	{
		draw_set_font(global.ui_font);
	}

	if (_stats.magic_damage > 0)
	{
		_damage_text = "Magic damage: " + string_format(_stats.magic_damage, 0, 1);
	}

	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_alpha(0.96);
	draw_set_color(COLOR_HUD_BACKGROUND);
	draw_rectangle(_card_x, _card_y, _card_x + _hover_width, _card_y + _hover_height, false);
	draw_set_alpha(1);
	draw_set_color(COLOR_PROJECTILE_SUMMON);
	draw_rectangle(_card_x, _card_y, _card_x + _hover_width, _card_y + _hover_height, true);

	draw_set_color(COLOR_HUD_TEXT);
	draw_text(_card_x + _hover_padding, _card_y + _hover_padding, o_hud.hud_unit_display_name_get(_unit_object));

	var _line_y = 42;
	draw_text(_card_x + _hover_padding, _card_y + _line_y, "HP: " + string_format(_stats.max_hp, 0, 1) + " / " + string_format(_stats.max_hp, 0, 1));
	_line_y += 20;
	draw_text(_card_x + _hover_padding, _card_y + _line_y, _damage_text);
	_line_y += 20;
	draw_text(_card_x + _hover_padding, _card_y + _line_y, "Attack speed: " + string_format(_attack_speed, 0, 2));
	_line_y += 20;
	draw_text(_card_x + _hover_padding, _card_y + _line_y, "Attack radius: " + string_format(_stats.attack_radius, 0, 0));
	_line_y += 20;
	draw_text(_card_x + _hover_padding, _card_y + _line_y, "Move speed: " + string_format(_stats.move_speed, 0, 2));
	_line_y += 20;
	draw_text(_card_x + _hover_padding, _card_y + _line_y, "Armor: " + string_format(_stats.armor - 100, 0, 1) + "%");
	_line_y += 20;
	draw_text(_card_x + _hover_padding, _card_y + _line_y, "Magic resistance: " + string_format(_stats.magic_resistance - 100, 0, 1) + "%");
	_line_y += 30;

	// Keep matchup portraits identical to the world-hover card.
	var _matchup_icon_start_x = _card_x + 126;
	var _matchup_icon_gap = 42;
	var _matchup_icon_radius = 18;
	var _matchup_sprite_size = 28;

	if (_strong_count > 0)
	{
		draw_set_color(COLOR_PROJECTILE_SUMMON);
		draw_text(_card_x + _hover_padding, _card_y + _line_y + 8, "Strong vs");

		for (var _strong_index = 0; _strong_index < _strong_count; ++_strong_index)
		{
			var _strong_object = _strong_against[_strong_index];
			var _strong_sprite = object_get_sprite(_strong_object);
			var _strong_x = _matchup_icon_start_x + (_matchup_icon_gap * _strong_index);
			var _strong_y = _card_y + _line_y + _matchup_icon_radius;

			draw_set_alpha(0.9);
			draw_set_color(COLOR_PROJECTILE_SUMMON);
			draw_circle(_strong_x, _strong_y, _matchup_icon_radius, false);
			draw_set_alpha(1);
			draw_set_color(c_white);
			draw_circle(_strong_x, _strong_y, _matchup_icon_radius, true);

			if (sprite_exists(_strong_sprite))
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
		draw_text(_card_x + _hover_padding, _card_y + _line_y + 8, "Weak vs");

		for (var _weak_index = 0; _weak_index < _weak_count; ++_weak_index)
		{
			var _weak_object = _weak_against[_weak_index];
			var _weak_sprite = object_get_sprite(_weak_object);
			var _weak_x = _matchup_icon_start_x + (_matchup_icon_gap * _weak_index);
			var _weak_y = _card_y + _line_y + _matchup_icon_radius;

			draw_set_alpha(0.9);
			draw_set_color(COLOR_STATUS_NEGATIVE_RED);
			draw_circle(_weak_x, _weak_y, _matchup_icon_radius, false);
			draw_set_alpha(1);
			draw_set_color(c_white);
			draw_circle(_weak_x, _weak_y, _matchup_icon_radius, true);

			if (sprite_exists(_weak_sprite))
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

// Group waves by enemy type in the order listed for this direction.

// A regular wave contains only its scheduled type and spends only that type's budget.

// An active shrine remains an optional wave source, but no longer determines its direction.

night_attack_plan_create = function()
{
	return;
};

// Night skip cheat clears active enemies before forcing morning.

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

night_effect_layers_disable = function()
{
	night_effect_transition_timer = 0;
	night_effect_transition_active = false;
	night_effect_layers_set_progress(0);
	full_moon_effect_layer_set_visible(false);
};

night_effect_layers_disable();

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

// Shared wall navigation is rebuilt only when a wall is created or destroyed.
wall_navigation_cell_size = BALANCE_WALL_NAVIGATION_CELL_SIZE;
wall_navigation_grid = noone;
wall_navigation_grid_version = 0;
wall_navigation_grid_dirty = true;
wall_navigation_debug_visible = false;
wall_navigation_debug_blocked_alpha = 0.42;
wall_navigation_debug_grid_alpha = 0.2;

wall_navigation_grid_mark_dirty = function()
{
	wall_navigation_grid_dirty = true;
};

wall_navigation_grid_rebuild = function()
{
	if (wall_navigation_grid != noone)
	{
		mp_grid_destroy(wall_navigation_grid);
	}

	var _horizontal_cell_count = ceil(room_width / wall_navigation_cell_size);
	var _vertical_cell_count = ceil(room_height / wall_navigation_cell_size);

	wall_navigation_grid = mp_grid_create(
		0,
		0,
		_horizontal_cell_count,
		_vertical_cell_count,
		wall_navigation_cell_size,
		wall_navigation_cell_size
	);

	var _wall_count = instance_number(o_wall_parent);

	// A small padding keeps unit sprites from clipping corners followed by center-point paths.
	for (var _wall_index = 0; _wall_index < _wall_count; ++_wall_index)
	{
		var _wall = instance_find(o_wall_parent, _wall_index);

		if (!instance_exists(_wall) || _wall.hp <= 0)
		{
			continue;
		}

		mp_grid_add_rectangle(
			wall_navigation_grid,
			_wall.bbox_left - BALANCE_WALL_NAVIGATION_OBSTACLE_PADDING,
			_wall.bbox_top - BALANCE_WALL_NAVIGATION_OBSTACLE_PADDING,
			_wall.bbox_right + BALANCE_WALL_NAVIGATION_OBSTACLE_PADDING,
			_wall.bbox_bottom + BALANCE_WALL_NAVIGATION_OBSTACLE_PADDING
		);
	}

	wall_navigation_grid_dirty = false;
	wall_navigation_grid_version++;

	return wall_navigation_grid;
};

wall_navigation_grid_get = function()
{
	if (wall_navigation_grid_dirty || wall_navigation_grid == noone)
	{
		return wall_navigation_grid_rebuild();
	}

	return wall_navigation_grid;
};

wall_navigation_debug_draw = function()
{
	if (!global.cheats_enabled
		|| !wall_navigation_debug_visible
		|| !instance_exists(o_camera_controller))
	{
		return;
	}

	var _navigation_grid = wall_navigation_grid_get();

	if (_navigation_grid == noone)
	{
		return;
	}

	var _camera_controller = instance_find(o_camera_controller, 0);
	var _camera_x = camera_get_view_x(_camera_controller.camera_id);
	var _camera_y = camera_get_view_y(_camera_controller.camera_id);
	var _camera_width = max(1, camera_get_view_width(_camera_controller.camera_id));
	var _camera_height = max(1, camera_get_view_height(_camera_controller.camera_id));
	var _horizontal_cell_count = ceil(room_width / wall_navigation_cell_size);
	var _vertical_cell_count = ceil(room_height / wall_navigation_cell_size);

	if (_horizontal_cell_count <= 0 || _vertical_cell_count <= 0)
	{
		return;
	}

	// Restrict checks and drawing to cells intersecting the current camera view.
	var _first_cell_x = clamp(floor(_camera_x / wall_navigation_cell_size), 0, _horizontal_cell_count - 1);
	var _last_cell_x = clamp(floor((_camera_x + _camera_width) / wall_navigation_cell_size), 0, _horizontal_cell_count - 1);
	var _first_cell_y = clamp(floor(_camera_y / wall_navigation_cell_size), 0, _vertical_cell_count - 1);
	var _last_cell_y = clamp(floor((_camera_y + _camera_height) / wall_navigation_cell_size), 0, _vertical_cell_count - 1);
	var _world_to_gui_x = camera_view_width / _camera_width;
	var _world_to_gui_y = camera_view_height / _camera_height;

	// Occupied cells are filled red.
	draw_set_alpha(wall_navigation_debug_blocked_alpha);
	draw_set_color(COLOR_NAVIGATION_DEBUG_BLOCKED);

	for (var _cell_y = _first_cell_y; _cell_y <= _last_cell_y; ++_cell_y)
	{
		for (var _cell_x = _first_cell_x; _cell_x <= _last_cell_x; ++_cell_x)
		{
			if (mp_grid_get_cell(_navigation_grid, _cell_x, _cell_y) != -1)
			{
				continue;
			}

			var _cell_world_left = _cell_x * wall_navigation_cell_size;
			var _cell_world_top = _cell_y * wall_navigation_cell_size;
			var _cell_world_right = min(_cell_world_left + wall_navigation_cell_size, room_width);
			var _cell_world_bottom = min(_cell_world_top + wall_navigation_cell_size, room_height);
			var _cell_gui_left = (_cell_world_left - _camera_x) * _world_to_gui_x;
			var _cell_gui_top = (_cell_world_top - _camera_y) * _world_to_gui_y;
			var _cell_gui_right = (_cell_world_right - _camera_x) * _world_to_gui_x;
			var _cell_gui_bottom = (_cell_world_bottom - _camera_y) * _world_to_gui_y;

			draw_rectangle(
				_cell_gui_left,
				_cell_gui_top,
				_cell_gui_right,
				_cell_gui_bottom,
				false
			);
		}
	}

	// Grid lines are drawn once per visible row and column to avoid duplicate edges.
	draw_set_alpha(wall_navigation_debug_grid_alpha);
	draw_set_color(COLOR_NAVIGATION_DEBUG_GRID);
	var _grid_gui_top = ((_first_cell_y * wall_navigation_cell_size) - _camera_y) * _world_to_gui_y;
	var _grid_world_bottom = min((_last_cell_y + 1) * wall_navigation_cell_size, room_height);
	var _grid_gui_bottom = (_grid_world_bottom - _camera_y) * _world_to_gui_y;
	var _grid_gui_left = ((_first_cell_x * wall_navigation_cell_size) - _camera_x) * _world_to_gui_x;
	var _grid_world_right = min((_last_cell_x + 1) * wall_navigation_cell_size, room_width);
	var _grid_gui_right = (_grid_world_right - _camera_x) * _world_to_gui_x;

	for (var _line_cell_x = _first_cell_x; _line_cell_x <= _last_cell_x + 1; ++_line_cell_x)
	{
		var _line_world_x = min(_line_cell_x * wall_navigation_cell_size, room_width);
		var _line_gui_x = (_line_world_x - _camera_x) * _world_to_gui_x;
		draw_line(_line_gui_x, _grid_gui_top, _line_gui_x, _grid_gui_bottom);
	}

	for (var _line_cell_y = _first_cell_y; _line_cell_y <= _last_cell_y + 1; ++_line_cell_y)
	{
		var _line_world_y = min(_line_cell_y * wall_navigation_cell_size, room_height);
		var _line_gui_y = (_line_world_y - _camera_y) * _world_to_gui_y;
		draw_line(_grid_gui_left, _line_gui_y, _grid_gui_right, _line_gui_y);
	}

	// Keep a small reminder visible while the diagnostic overlay is active.
	draw_set_alpha(0.9);
	draw_set_color(COLOR_HUD_TEXT);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_text(18, 18, "F5 NAV GRID - RED CELLS ARE BLOCKED");

	// Restore the project draw defaults.
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
	draw_set_alpha(1);
};

// The first daytime preview is available immediately when the room starts.
night_effect_layers_disable();

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

// Faction summon rosters: cost and member count are per purchase.
faction_summon_options = [
	[
		{name: "Knights", unit_object: o_unit_order_knight, cost: 100, count: 4},
		{name: "Archers", unit_object: o_unit_order_archer, cost: 75, count: 5},
		{name: "Priests", unit_object: o_unit_order_priest, cost: 150, count: 4}
	],
	[
		{name: "Warriors", unit_object: o_unit_undead_warrior, cost: 75, count: 6},
		{name: "Archers", unit_object: o_unit_undead_archer, cost: 75, count: 6},
		{name: "Mages", unit_object: o_unit_undead_mage, cost: 100, count: 4}
	],
	[
		{name: "Balgors", unit_object: o_unit_demons_balgor, cost: 100, count: 3},
		{name: "Succubi", unit_object: o_unit_demons_succubus, cost: 150, count: 4},
		{name: "Wizards", unit_object: o_unit_demons_wizard, cost: 125, count: 3}
	],
	[
		{name: "Orcs", unit_object: o_unit_wildlings_orc, cost: 100, count: 5},
		{name: "Shamans", unit_object: o_unit_wildlings_shaman, cost: 100, count: 3},
		{name: "Catapult", unit_object: o_unit_wildlings_catapult, cost: 75, count: 1}
	]
];
faction_summon_selected = -1;
faction_summon_release_pending = false;
faction_summon_ai_choices = array_create(FACTION.WILDLINGS + 1, -1);
faction_summon_ai_timer = 0;
