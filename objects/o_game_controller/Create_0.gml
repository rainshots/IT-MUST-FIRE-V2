// Global pause state used by gameplay objects.
randomise()
global.pause = false;
global.focus_window = FOCUS_WINDOW.NOONE;
global.fog_of_war_visible = true;
global.cheats_enabled = BALANCE_CHEATS_ENABLED;
global.play_music = BALANCE_PLAY_MUSIC;

// Global day cycle uses fixed day and night timers.
global.day_phase = DAY_PHASE.DAY;
global.day_duration = BALANCE_DAY_DURATION;
global.night_duration = BALANCE_NIGHT_DURATION;
global.day_timer = global.day_duration * room_speed;
global.night_attack_unit_count = 0;
global.day_cycle_enabled = true;
global.legacy_building_logic_enabled = false;
global.cultists = array_create(0);
global.shrine_objective_complete = false;
global.tutorial_popup_active = false;
global.tutorial_welcome_closed = false;
global.cursed_point_structure_selection_source = noone;

// Tutorial controller owns onboarding popups and pauses gameplay while they are open.
if (!instance_exists(o_tutorial_controller))
{
	instance_create_layer(0, 0, "Instances", o_tutorial_controller);
}

// Shrine objective state is owned by the game controller and displayed by the HUD.
shrine_instances = array_create(0);
shrines_spawned = false;
shrine_objective_total = BALANCE_SHRINE_OBJECTIVE_TOTAL;
shrine_objective_required = BALANCE_SHRINE_OBJECTIVE_REQUIRED;
shrine_spawn_distances = [
	BALANCE_SHRINE_DISTANCE_NEAR,
	BALANCE_SHRINE_DISTANCE_FAR,
	BALANCE_SHRINE_DISTANCE_MID
];
shrine_spawn_angle_ranges = [
	[BALANCE_SHRINE_ANGLE_FIRST_MIN, BALANCE_SHRINE_ANGLE_FIRST_MAX],
	[BALANCE_SHRINE_ANGLE_SECOND_MIN, BALANCE_SHRINE_ANGLE_SECOND_MAX],
	[BALANCE_SHRINE_ANGLE_THIRD_MIN, BALANCE_SHRINE_ANGLE_THIRD_MAX]
];

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
part_type_alpha2(global.particle_type_imp_blood_frenzy_smoke, 0.75, 0);
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

part_type_sprite(global.particle_type_brute_rotten_aura, s_smoke_small_particle, false, false, true);
part_type_size(
	global.particle_type_brute_rotten_aura,
	BALANCE_BRUTE_ROTTEN_AURA_PARTICLE_SIZE_MIN * BALANCE_SMOKE_PARTICLE_SIZE_MULTIPLIER,
	BALANCE_BRUTE_ROTTEN_AURA_PARTICLE_SIZE_MAX * BALANCE_SMOKE_PARTICLE_SIZE_MULTIPLIER,
	-0.004,
	0
);
part_type_color1(global.particle_type_brute_rotten_aura, COLOR_STATUS_SOUL_MARK);
part_type_alpha2(global.particle_type_brute_rotten_aura, 0.45, 0);
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

// Global cannon projectile queue consumed from the first slot.
global.cannon_projectile_queue = [];
global.cannon_projectile_payload_queue = [];
global.cannon_projectile_queue_max = BALANCE_CANNON_PROJECTILE_QUEUE_MAX;
global.cannon_projectile_gain_time = BALANCE_CANNON_PROJECTILE_GAIN_TIME;
global.cannon_projectile_gain_timer = 0;
global.cannon_projectile_gain_enabled = false;
global.cannon_projectile_drop_types = [
	PROJECTILE_TYPE.DAMAGE,
	PROJECTILE_TYPE.CORRUPTION,
	PROJECTILE_TYPE.SUMMON,
	PROJECTILE_TYPE.RALLY
];
global.cannon_projectile_cheat_enabled = global.cheats_enabled;
global.rally_projectile_group_id = 0;
global.cannon_satiety = 0;
global.cannon_satiety_max = BALANCE_CANNON_SATIETY_MAX;

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
	whip_sound04,
	whip_sound05,
	whip_sound06,
	whip_sound07
];
global.cannon_shot_sounds = [
	cannon_shot01,
	cannon_shot02,
	cannon_shot03
];
global.construction_sounds = [
	construction_sound01,
	construction_sound02,
	construction_sound03
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

	var _sound = _sounds[irandom(_sound_count - 1)];
	return audio_play_sound(_sound, _priority, false);
};

global.sound_play_random_with_gain = function(_sounds, _gain, _priority = global.sound_priority_gameplay)
{
	var _handle = global.sound_play_random(_sounds, _priority);

	if (_handle != noone)
	{
		audio_sound_gain(_handle, _gain, 0);
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

// UI audio is centralized so hover sounds fire once when entering a button.
ui_hover_button_key = "";

ui_mouse_is_inside_rect = function(_mouse_x, _mouse_y, _left, _top, _width, _height)
{
	return _mouse_x >= _left
		&& _mouse_x <= _left + _width
		&& _mouse_y >= _top
		&& _mouse_y <= _top + _height;
};

ui_hover_candidate_get = function(_mouse_x, _mouse_y)
{
	if (pause_menu_open)
	{
		var _button_x = (camera_view_width - button_width) * 0.5;
		var _button_y = (camera_view_height - ((button_height * pause_button_count) + (button_gap * (pause_button_count - 1)))) * 0.5;
		var _button_step = button_height + button_gap;

		if (!settings_open)
		{
			if (_mouse_x >= _button_x && _mouse_x <= _button_x + button_width)
			{
				for (var _pause_button_index = 0; _pause_button_index < pause_button_count; ++_pause_button_index)
				{
					var _pause_button_y = _button_y + (_button_step * _pause_button_index);

					if (_mouse_y >= _pause_button_y && _mouse_y <= _pause_button_y + button_height)
					{
						return "pause_" + string(_pause_button_index);
					}
				}
			}
		}
		else
		{
			var _settings_panel_x = (camera_view_width - settings_panel_width) * 0.5;
			var _settings_panel_y = (camera_view_height - settings_panel_height) * 0.5;
			var _close_button_x = _settings_panel_x + ((settings_panel_width - button_width) * 0.5);
			var _close_button_y = _settings_panel_y + settings_panel_height - button_height - settings_close_bottom_padding;

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
		var _grid_x = _construction_panel_x + 44;
		var _grid_y = _construction_panel_y + 94;
		var _choice_count = array_length(building_choices);

		if (ui_mouse_is_inside_rect(_mouse_x, _mouse_y, _construction_close_x, _construction_close_y, _construction_close_size, _construction_close_size))
		{
			return "building_close";
		}

		for (var _choice_index = 0; _choice_index < _choice_count; ++_choice_index)
		{
			var _choice_column = _choice_index mod building_tile_columns;
			var _choice_row = _choice_index div building_tile_columns;
			var _tile_x = _grid_x + ((building_tile_width + building_tile_gap) * _choice_column);
			var _tile_y = _grid_y + ((building_tile_height + building_tile_gap) * _choice_row);

			if (ui_mouse_is_inside_rect(_mouse_x, _mouse_y, _tile_x, _tile_y, building_tile_width, building_tile_height))
			{
				return "building_choice_" + string(_choice_index);
			}
		}
	}
	else if (global.focus_window == FOCUS_WINDOW.BUILDING_UPGRADE)
	{
		var _upgrade_panel_x = (camera_view_width - building_upgrade_window_width) * 0.5;
		var _upgrade_panel_y = (camera_view_height - building_upgrade_window_height) * 0.5;
		var _upgrade_close_size = 34;
		var _upgrade_close_x = _upgrade_panel_x + building_upgrade_window_width - _upgrade_close_size - 14;
		var _upgrade_close_y = _upgrade_panel_y + 14;
		var _upgrade_tile_start_x = _upgrade_panel_x + 38;
		var _upgrade_tile_y = _upgrade_panel_y + 104;

		if (ui_mouse_is_inside_rect(_mouse_x, _mouse_y, _upgrade_close_x, _upgrade_close_y, _upgrade_close_size, _upgrade_close_size))
		{
			return "upgrade_close";
		}

		if (instance_exists(building_upgrade_window_building))
		{
			var _upgrade_count = 0;

			if (variable_instance_exists(building_upgrade_window_building, "building_upgrade_levels"))
			{
				_upgrade_count = array_length(building_upgrade_window_building.building_upgrade_levels);
			}
			else if (variable_instance_exists(building_upgrade_window_building, "building_upgrade_flags"))
			{
				_upgrade_count = array_length(building_upgrade_window_building.building_upgrade_flags);
			}

			for (var _upgrade_index = 0; _upgrade_index < _upgrade_count; ++_upgrade_index)
			{
				var _upgrade_tile_x = _upgrade_tile_start_x + ((building_upgrade_tile_width + building_upgrade_tile_gap) * _upgrade_index);

				if (ui_mouse_is_inside_rect(_mouse_x, _mouse_y, _upgrade_tile_x, _upgrade_tile_y, building_upgrade_tile_width, building_upgrade_tile_height))
				{
					return "upgrade_choice_" + string(_upgrade_index);
				}
			}
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
		var _level_button_y = _level_panel_y + 550;
		var _level_button_width = 150;
		var _level_button_height = 44;
		var _level_button_gap = 18;
		var _level_button_start_x = _level_panel_x + 92;
		var _cultist = noone;

		if (cultist_levelup_index >= 0 && cultist_levelup_index < array_length(global.cultists))
		{
			_cultist = global.cultists[cultist_levelup_index];
		}

		if (instance_exists(_cultist))
		{
			ensure_cultist_levelup_options(_cultist);
			var _reward_type = cultist_level_reward_type_get(_cultist);
			var _button_count = 3;

			if (_reward_type == CULTIST_LEVEL_REWARD.PASSIVE)
			{
				_button_count = array_length(_cultist.passive_choice_options);
			}
			else if (_reward_type == CULTIST_LEVEL_REWARD.ACTIVE)
			{
				_button_count = array_length(_cultist.active_choice_options);
			}
			else if (_reward_type == CULTIST_LEVEL_REWARD.ABILITY_UPGRADE)
			{
				_button_count = array_length(_cultist.ability_upgrade_choice_options);
			}

			for (var _choice_index = 0; _choice_index < _button_count; ++_choice_index)
			{
				var _level_button_x = _level_button_start_x + ((_level_button_width + _level_button_gap) * _choice_index);

				if (ui_mouse_is_inside_rect(_mouse_x, _mouse_y, _level_button_x, _level_button_y, _level_button_width, _level_button_height))
				{
					return "level_choice_" + string(_choice_index);
				}
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

	return "";
};

ui_audio_update = function()
{
	var _mouse_x = device_mouse_x_to_gui(0);
	var _mouse_y = device_mouse_y_to_gui(0);
	var _hover_button_key = ui_hover_candidate_get(_mouse_x, _mouse_y);

	if (_hover_button_key != "" && _hover_button_key != ui_hover_button_key)
	{
		global.sound_play_random(global.ui_hover_sounds, global.sound_priority_ui);
	}

	if (_hover_button_key != "" && mouse_check_button_pressed(mb_left))
	{
		audio_play_sound(global.ui_confirm_sound, global.sound_priority_ui, false);
	}

	ui_hover_button_key = _hover_button_key;
};

// Global resource storage used by HUD and economy systems.
global.resources = array_create(RESOURCES.COUNT, 0);
global.resources[RESOURCES.FLESH] = BALANCE_STARTING_FLESH;
global.resources[RESOURCES.SOULS] = BALANCE_STARTING_SOULS;
global.resources[RESOURCES.IRON] = BALANCE_STARTING_IRON;

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
building_window_input_blocked = false;
building_window_width = 760;
building_window_height = 560;
building_tile_width = 150;
building_tile_height = 178;
building_tile_gap = 18;
building_tile_columns = 4;
building_tile_sprite_size = 76;
building_tile_cost_icon_size = 18;
building_tooltip_width = 310;
building_tooltip_height = 120;
building_tooltip_padding = 12;
building_upgrade_window_building = noone;
building_upgrade_previous_pause_state = false;
building_upgrade_window_width = 760;
building_upgrade_window_height = 350;
building_upgrade_tile_width = 220;
building_upgrade_tile_height = 170;
building_upgrade_tile_gap = 18;
building_choices = [
	{
		building_object: o_slaughter_table,
		building_sprite: s_slaughter_table,
		building_name: "Slaughter Table",
		building_description: "Produces Flesh when assigned cultists work here.",
		iron_cost: BALANCE_BUILDING_IRON_COST
	},
	{
		building_object: o_quarry,
		building_sprite: s_quarry,
		building_name: "Quarry",
		building_description: "Produces Iron when assigned cultists work here.",
		iron_cost: BALANCE_BUILDING_IRON_COST
	},
	{
		building_object: o_souls_well,
		building_sprite: s_souls_well,
		building_name: "Souls Well",
		building_description: "Produces Souls when assigned cultists work here.",
		iron_cost: BALANCE_BUILDING_IRON_COST
	},
	{
		building_object: o_meat_bath,
		building_sprite: s_meat_bath,
		building_name: "Meat Bath",
		building_description: "Heals assigned cultists by spending Flesh.",
		iron_cost: BALANCE_BUILDING_IRON_COST
	},
	{
		building_object: o_ritual_circle,
		building_sprite: s_ritual_circle,
		building_name: "Ritual Circle",
		building_description: "Gives assigned cultists XP over time.",
		iron_cost: BALANCE_BUILDING_IRON_COST
	},
	{
		building_object: o_workshop,
		building_sprite: s_workshop,
		building_name: "Workshop",
		building_description: "Repairs the cannon wall by spending Iron.",
		iron_cost: BALANCE_BUILDING_IRON_COST
	},
	{
		building_object: o_graveyardv13,
		building_sprite: s_graveyard30,
		building_name: "Graveyard",
		building_description: "Summons Skeletons(they can fight 1 night) by spending Souls.",
		iron_cost: BALANCE_BUILDING_IRON_COST
	},
	{
		building_object: o_hell_pit,
		building_sprite: s_hell_pit,
		building_name: "Hell Pit",
		building_description: "Summons Pitlings(they fight at night) by spending Souls.",
		iron_cost: BALANCE_BUILDING_IRON_COST
	},
	{
		building_object: o_goblins_pit,
		building_sprite: s_goblins_pit,
		building_name: "Goblins Pit",
		building_description: "Summons Goblins(they only work) by spending Souls.",
		iron_cost: BALANCE_BUILDING_IRON_COST
	}
];

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

	return BALANCE_PROJECTILE_EFFECT_RADIUS;
};

// Pause menu button data.
continue_button_index = 0;
settings_button_index = 1;
quit_button_index = 2;
pause_button_labels = ["CONTINUE", "SETTINGS", "QUIT"];
pause_button_count = array_length(pause_button_labels);

// Menu visual settings.
overlay_alpha = 0.45;
day_overlay_alpha = BALANCE_DAY_OVERLAY_ALPHA;
night_overlay_alpha = BALANCE_NIGHT_OVERLAY_ALPHA;
button_width = 280;
button_height = 58;
button_gap = 18;
settings_panel_width = 420;
settings_panel_height = 220;
settings_close_bottom_padding = 28;

// Cultist prototype state.
cultist_start_count = BALANCE_STARTING_CULTIST_COUNT;
starting_goblin_count = BALANCE_STARTING_GOBLIN_COUNT;
cultist_reward_days = [
	BALANCE_SECOND_CULTIST_REWARD_DAY,
	BALANCE_THIRD_CULTIST_REWARD_DAY
];
next_cultist_reward_index = 0;
cultists_spawned = false;
starting_cultist_selection_pending = false;
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
night_attack_unit_pool = [
	o_enemy_archer,
	o_enemy_knight,
	o_enemy_mage,
	o_enemy_peasant
];

// Adaptive difficulty is a separate soft modifier applied to future night attack plans.
adaptive_difficulty_multiplier = 1;
adaptive_night_cannon_hp_start = 0;
adaptive_last_night_cannon_hp_loss_share = 0;
adaptive_last_night_low_hp_cultists = 0;
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

		var _corruption = ds_grid_get(_corruption_grid.corruption_grid, _cell_x, _cell_y);

		if (_corruption < _corruption_grid.full_corruption_value)
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
		&& _unit.object_index != o_cultist;
};

unit_is_blocked_by_cannon_wall = function(_unit)
{
	if (!instance_exists(_unit))
	{
		return false;
	}

	var _is_summoned_night_unit = variable_instance_exists(_unit, "summon_nights_remaining")
		&& global.day_phase == DAY_PHASE.NIGHT;

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

worker_whip_target_is_valid = function(_unit)
{
	if (!instance_exists(_unit)
		|| (_unit.object_index != o_cultist && _unit.object_index != o_goblin)
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

	var _damage_amount = _unit.max_hp * BALANCE_WORKER_WHIP_MAX_HP_DAMAGE_SHARE;
	return _unit.hp > _damage_amount;
};

find_worker_whip_target_at_position = function(_world_x, _world_y)
{
	var _target_unit = noone;
	var _target_depth = infinity;
	var _cultist_count = array_length(global.cultists);

	for (var _cultist_index = 0; _cultist_index < _cultist_count; ++_cultist_index)
	{
		var _cultist = global.cultists[_cultist_index];

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
	var _damage_amount = _unit.max_hp * BALANCE_WORKER_WHIP_MAX_HP_DAMAGE_SHARE;
	var _whip_was_inactive = _unit.whip_timer <= 0;

	_unit.hp -= _damage_amount;
	_unit.whip_duration = _whip_duration_frames;
	_unit.whip_timer = min(_unit.whip_timer + _whip_gain_frames, _unit.whip_duration);
	_unit.whip_work_multiplier = BALANCE_WORKER_WHIP_SPEED_MULTIPLIER;

	var _damage_popup = instance_create_layer(_unit.x, _unit.y, "Instances", o_damage_popup);
	_damage_popup.popup_text = string(ceil(_damage_amount));
	_damage_popup.popup_color = COLOR_DAMAGE_FRIENDLY;
	_damage_popup.is_critical = false;

	if (_whip_was_inactive)
	{
		var _productivity_popup = instance_create_layer(_unit.x, _unit.bbox_top - 12, "Instances", o_damage_popup);
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
	var _cultist_count = array_length(global.cultists);

	for (var _cultist_index = 0; _cultist_index < _cultist_count; ++_cultist_index)
	{
		worker_whip_unit_update(global.cultists[_cultist_index]);
	}

	var _goblin_count = instance_number(o_goblin);

	for (var _goblin_index = 0; _goblin_index < _goblin_count; ++_goblin_index)
	{
		worker_whip_unit_update(instance_find(o_goblin, _goblin_index));
	}
};

find_upgrade_building_at_position = function(_world_x, _world_y)
{
	var _building_count = instance_number(o_v13buildings_parent);
	var _target_building = noone;
	var _target_depth = infinity;
	var _cannon_count = instance_number(o_cannon);

	for (var _cannon_index = 0; _cannon_index < _cannon_count; ++_cannon_index)
	{
		var _cannon = instance_find(o_cannon, _cannon_index);

		if (instance_exists(_cannon)
			&& variable_instance_exists(_cannon, "building_has_upgrades")
			&& _cannon.building_has_upgrades
			&& _world_x >= _cannon.bbox_left
			&& _world_x <= _cannon.bbox_right
			&& _world_y >= _cannon.bbox_top
			&& _world_y <= _cannon.bbox_bottom
			&& _cannon.depth < _target_depth)
		{
			_target_building = _cannon;
			_target_depth = _cannon.depth;
		}
	}

	for (var _building_index = 0; _building_index < _building_count; ++_building_index)
	{
		var _building = instance_find(o_v13buildings_parent, _building_index);

		if (instance_exists(_building)
			&& variable_instance_exists(_building, "building_has_upgrades")
			&& _building.building_has_upgrades
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

open_building_window = function(_slot)
{
	if (!instance_exists(_slot))
	{
		return false;
	}

	building_window_slot = _slot;
	building_window_input_blocked = true;
	player_pause_active = false;
	global.pause = true;
	global.focus_window = FOCUS_WINDOW.BUILDING_CONSTRUCTION;

	return true;
};

open_building_upgrade_window = function(_building)
{
	if (!instance_exists(_building)
		|| !variable_instance_exists(_building, "building_has_upgrades")
		|| !_building.building_has_upgrades)
	{
		return false;
	}

	building_upgrade_window_building = _building;
	building_upgrade_previous_pause_state = global.pause;
	global.pause = true;
	global.focus_window = FOCUS_WINDOW.BUILDING_UPGRADE;

	return true;
};

close_building_window = function()
{
	building_window_slot = noone;
	global.pause = false;
	global.focus_window = FOCUS_WINDOW.NOONE;
};

close_building_upgrade_window = function()
{
	building_upgrade_window_building = noone;
	global.pause = building_upgrade_previous_pause_state;
	player_pause_active = building_upgrade_previous_pause_state;
	global.focus_window = FOCUS_WINDOW.NOONE;
};

construct_building_from_choice = function(_choice)
{
	if (!instance_exists(building_window_slot))
	{
		close_building_window();
		return false;
	}

	if (global.resources[RESOURCES.IRON] < _choice.iron_cost)
	{
		return false;
	}

	var _slot = building_window_slot;
	var _built_object = instance_create_layer(_slot.x, _slot.y, "Instances", _choice.building_object);

	global.resources[RESOURCES.IRON] -= _choice.iron_cost;
	resource_popup_create(_slot.x, _slot.y - 84, RESOURCES.IRON, -_choice.iron_cost);

	if (instance_exists(_built_object))
	{
		_built_object.depth = _slot.depth;
	}

	global.sound_play_random(global.construction_sounds);

	if (variable_global_exists("tutorial_hint_trigger"))
	{
		global.tutorial_hint_trigger("workers");
	}

	instance_destroy(_slot);
	close_building_window();

	return true;
};

// Assign a valid worker unit to a building and snap it beside the building.
assign_cultist_to_worker_building = function(_cultist, _building)
{
	if (!instance_exists(_cultist)
		|| !instance_exists(_building)
		|| (_cultist.object_index != o_cultist && !variable_instance_exists(_cultist, "worker_speed_multiplier")))
	{
		return false;
	}

	clear_cultist_building_assignment(_cultist);

	if (_cultist.object_index == o_goblin && global.day_phase == DAY_PHASE.NIGHT)
	{
		return false;
	}

	if (!variable_instance_exists(_building, "building_accepts_workers")
		|| !_building.building_accepts_workers
		|| !variable_instance_exists(_building, "worker_cultists")
		|| (_building.object_index != o_cannon && array_length(_building.worker_cultists) >= _building.worker_max))
	{
		return false;
	}

	array_push(_building.worker_cultists, _cultist);
	_cultist.assigned_building = _building;
	_cultist.is_assigned_to_building = true;

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

cannon_satiety_add = function(_amount)
{
	global.cannon_satiety = max(0, global.cannon_satiety + _amount);
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

cannon_feast_projectile_queue_add = function()
{
	array_push(global.cannon_projectile_queue, PROJECTILE_TYPE.FEAST);
	array_push(global.cannon_projectile_payload_queue, noone);
	global.cannon_projectile_gain_timer = 0;
};

cannon_feast_projectile_try_queue = function()
{
	if (global.cannon_satiety < global.cannon_satiety_max)
	{
		return false;
	}

	global.cannon_satiety -= global.cannon_satiety_max;
	cannon_feast_projectile_queue_add();

	return true;
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

	var _carried_corpse_count = cannon_worker_carried_corpse_count_get(_worker);

	if (_carried_corpse_count > 0)
	{
		var _deliver_distance = point_distance(_worker.x, _worker.y, _cannon.x, _cannon.y);

		if (_deliver_distance <= BALANCE_CANNON_CORPSE_DELIVER_RADIUS)
		{
			cannon_satiety_add(BALANCE_CANNON_SATIETY_PER_CORPSE * _carried_corpse_count);
			_worker.carried_corpses = [];
			_worker.carried_corpse = noone;
			_worker.reserved_corpse_id = noone;
			return true;
		}

		// After the first corpse, take a second only if it is closer than the cannon.
		if (_carried_corpse_count < _worker.corpse_carry_capacity)
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

		var _idle_distance = point_distance(_worker.x, _worker.y, _cannon.x, _cannon.y);

		if (_idle_distance > BALANCE_CANNON_CORPSE_DELIVER_RADIUS)
		{
			cannon_worker_move_towards(_worker, _cannon.x, _cannon.y);
		}

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
	var _write_index = 0;

	for (var _worker_index = 0; _worker_index < _worker_count; ++_worker_index)
	{
		var _worker = _cannon.worker_cultists[_worker_index];

		if (!instance_exists(_worker)
			|| !variable_instance_exists(_worker, "assigned_building")
			|| _worker.assigned_building != _cannon)
		{
			continue;
		}

		_cannon.worker_cultists[_write_index] = _worker;
		_write_index++;
		cannon_corpse_worker_update(_worker, _cannon);
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

	var _cultist_count = array_length(global.cultists);

	for (var _cultist_index = 0; _cultist_index < _cultist_count; ++_cultist_index)
	{
		var _cultist = global.cultists[_cultist_index];

		if (instance_exists(_cultist))
		{
			cannon_corpse_worker_drop(_cultist);
		}
	}
};

// Runtime UI font includes Cyrillic glyphs for cultist names.
var _ui_font_size = 11;
var _should_create_ui_font = !variable_global_exists("ui_font") || !font_exists(global.ui_font);

if (!_should_create_ui_font && (!variable_global_exists("ui_font_size") || global.ui_font_size != _ui_font_size))
{
	font_delete(global.ui_font);
	_should_create_ui_font = true;
}

if (_should_create_ui_font)
{
	global.ui_font = font_add("Arial", _ui_font_size, false, false, 32, 1279);
	global.ui_font_size = _ui_font_size;
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

	global.cultists = array_create(0);
	var _starting_unit_count = cultist_start_count + starting_goblin_count;

	// Spawn initial cultists and workers together so they do not overlap.
	for (var _cultist_index = 0; _cultist_index < cultist_start_count; ++_cultist_index)
	{
		var _spawn_position = cannon_inner_position_get(_cultist_index, _starting_unit_count);
		var _spawn_x = _spawn_position[0];
		var _spawn_y = _spawn_position[1];
		var _cultist = instance_create_layer(_spawn_x, _spawn_y, "Instances", o_cultist);

		array_push(global.cultists, _cultist);
	}

	for (var _goblin_index = 0; _goblin_index < starting_goblin_count; ++_goblin_index)
	{
		var _unit_index = cultist_start_count + _goblin_index;
		var _spawn_position = cannon_inner_position_get(_unit_index, _starting_unit_count);
		var _spawn_x = _spawn_position[0];
		var _spawn_y = _spawn_position[1];
		instance_create_layer(_spawn_x, _spawn_y, "Instances", o_goblin);
	}

	cultists_spawned = true;
	starting_cultist_selection_pending = true;
	open_starting_cultist_selection();
};

spawn_objective_shrines = function()
{
	if (shrines_spawned || !instance_exists(o_cannon))
	{
		return;
	}

	var _cannon = instance_find(o_cannon, 0);
	shrine_instances = array_create(0);

	for (var _shrine_index = 0; _shrine_index < shrine_objective_total; ++_shrine_index)
	{
		var _angle_range = shrine_spawn_angle_ranges[_shrine_index];
		var _angle = random_range(_angle_range[0], _angle_range[1]);
		var _distance = shrine_spawn_distances[_shrine_index];
		var _spawn_x = _cannon.x + lengthdir_x(_distance, _angle);
		var _spawn_y = _cannon.y + lengthdir_y(_distance, _angle);
		var _shrine = instance_create_layer(_spawn_x, _spawn_y, "Instances", o_shrine);

		array_push(shrine_instances, _shrine);
	}

	shrines_spawned = true;
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
	var _selection_start_index = -1;
	var _reward_count = array_length(cultist_reward_days);

	for (var _reward_index = next_cultist_reward_index; _reward_index < _reward_count; ++_reward_index)
	{
		var _reward_day = cultist_reward_days[_reward_index];

		if (night_attack_night_index < _reward_day)
		{
			break;
		}

		var _new_cultist_index = array_length(global.cultists);
		var _spawn_position = cannon_inner_position_get(_new_cultist_index, _new_cultist_index + 1);
		var _spawn_x = _spawn_position[0];
		var _spawn_y = _spawn_position[1];
		var _cultist = instance_create_layer(_spawn_x, _spawn_y, "Instances", o_cultist);

		array_push(global.cultists, _cultist);

		if (_selection_start_index < 0)
		{
			_selection_start_index = _new_cultist_index;
		}

		next_cultist_reward_index = _reward_index + 1;
	}

	if (_selection_start_index >= 0)
	{
		move_cultists_to_cannon_inner();
		open_cultist_demon_selection(_selection_start_index);
	}
};

get_current_cultist = function()
{
	if (cultist_selection_index >= 0 && cultist_selection_index < array_length(global.cultists))
	{
		var _cultist = global.cultists[cultist_selection_index];

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

	cultist_selection_index++;
	keyboard_string = "";
	cultist_selected_demon_type = DEMON_TYPE.IMP;
	cultist_selected_starting_ability = cultist_starting_ability_default_get(cultist_selected_demon_type);

	if (cultist_selection_index >= array_length(global.cultists))
	{
		if (cultist_levelup_find_next(0) >= 0)
		{
			open_cultist_levelup();
		}
		else
		{
			global.pause = false;
			global.focus_window = FOCUS_WINDOW.NOONE;

			if (variable_global_exists("tutorial_hint_trigger"))
			{
				global.tutorial_hint_trigger("construction_start");
			}
		}
	}
};

transform_cultists_to_demons = function()
{
	var _cultist_count = array_length(global.cultists);
	var _new_units = array_create(0);

	for (var _cultist_index = 0; _cultist_index < _cultist_count; ++_cultist_index)
	{
		var _cultist = global.cultists[_cultist_index];

		if (!instance_exists(_cultist)
			|| _cultist.object_index != o_cultist
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
		_demon.fatigue_amount = 0;

		if (variable_instance_exists(_cultist, "fatigue_amount"))
		{
			_demon.fatigue_amount = _cultist.fatigue_amount;
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

	global.cultists = _new_units;
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

clear_cannon_projectile_queues = function()
{
	cultist_projectile_deploy_assignments_reset();
	global.cannon_projectile_queue = [];
	global.cannon_projectile_payload_queue = [];
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
	return true;
};

start_cultists_loading_into_cannon = function()
{
	clear_cannon_projectile_queues();

	var _cultist_count = array_length(global.cultists);

	for (var _cultist_index = 0; _cultist_index < _cultist_count; ++_cultist_index)
	{
		var _cultist = global.cultists[_cultist_index];

		if (!instance_exists(_cultist)
			|| _cultist.object_index != o_cultist
			|| _cultist.demon_type == DEMON_TYPE.NONE)
		{
			continue;
		}

		clear_cultist_building_assignment(_cultist);
		_cultist.cannon_loading = true;
		_cultist.cannon_loaded = false;
		_cultist.visible = true;
		_cultist.is_being_dragged = false;
	}
};

update_cultists_loading_into_cannon = function()
{
	if (global.pause || global.day_phase != DAY_PHASE.NIGHT || !instance_exists(o_cannon))
	{
		return;
	}

	var _cannon = instance_find(o_cannon, 0);
	var _cultist_count = array_length(global.cultists);

	for (var _cultist_index = 0; _cultist_index < _cultist_count; ++_cultist_index)
	{
		var _cultist = global.cultists[_cultist_index];

		if (!instance_exists(_cultist)
			|| _cultist.object_index != o_cultist
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
			queue_cultist_projectile(_cultist);
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

	var _cultist_count = array_length(global.cultists);

	for (var _cultist_index = 0; _cultist_index < _cultist_count; ++_cultist_index)
	{
		var _cultist = global.cultists[_cultist_index];

		if (instance_exists(_cultist)
			&& _cultist.object_index == o_cultist
			&& variable_instance_exists(_cultist, "cannon_loading"))
		{
			_cultist.cannon_loading = false;
			_cultist.cannon_loaded = false;
			_cultist.visible = true;
		}
	}

	clear_cannon_projectile_queues();
};

cannon_inner_position_get = function(_unit_index, _unit_count)
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
	var _regroup_x = _cannon.x - (((_safe_column_count - 1) * BALANCE_DAY_CANNON_REGROUP_SPACING) * 0.5);
	var _regroup_y = _cannon.y + BALANCE_DAY_CANNON_REGROUP_OFFSET_Y;

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

	var _position = cannon_inner_position_get(_unit_index, _unit_count);

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

	for (var _friendly_index = 0; _friendly_index < _friendly_count; ++_friendly_index)
	{
		var _friendly_unit = instance_find(o_friendly_units, _friendly_index);

		if (instance_exists(_friendly_unit)
			&& variable_instance_exists(_friendly_unit, "summon_nights_remaining"))
		{
			_summoned_count++;
		}
	}

	var _unit_index = max(0, _summoned_count - 1);
	var _position = cannon_inner_position_get(_unit_index, max(1, _summoned_count));

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
	var _summoned_units = array_create(0);

	for (var _friendly_index = 0; _friendly_index < _friendly_count; ++_friendly_index)
	{
		var _friendly_unit = instance_find(o_friendly_units, _friendly_index);

		if (instance_exists(_friendly_unit)
			&& variable_instance_exists(_friendly_unit, "summon_nights_remaining"))
		{
			clear_cultist_building_assignment(_friendly_unit);
			array_push(_summoned_units, _friendly_unit);
		}
	}

	var _summoned_count = array_length(_summoned_units);

	for (var _summoned_index = 0; _summoned_index < _summoned_count; ++_summoned_index)
	{
		move_unit_to_cannon_inner(_summoned_units[_summoned_index], _summoned_index, _summoned_count);
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
	var _cultist_count = array_length(global.cultists);

	for (var _cultist_index = 0; _cultist_index < _cultist_count; ++_cultist_index)
	{
		var _cultist = global.cultists[_cultist_index];

		if (instance_exists(_cultist))
		{
			clear_cultist_building_assignment(_cultist);
			move_unit_to_cannon_inner(_cultist, _cultist_index, _cultist_count);
		}
	}
};

restore_dead_cultists_at_morning = function()
{
	var _cultist_count = array_length(global.cultists);

	for (var _cultist_index = 0; _cultist_index < _cultist_count; ++_cultist_index)
	{
		var _cultist = global.cultists[_cultist_index];

		if (!instance_exists(_cultist)
			|| !variable_instance_exists(_cultist, "morning_respawn_pending")
			|| !_cultist.morning_respawn_pending)
		{
			continue;
		}

		cultist_day_health_apply(_cultist, false);
		_cultist.hp = _cultist.max_hp * BALANCE_CULTIST_MORNING_RESPAWN_HP_SHARE;
		_cultist.visible = true;
		_cultist.image_alpha = 1;
		_cultist.image_angle = 0;
		_cultist.morning_respawn_pending = false;
		_cultist.corpse_visual_created = false;
	}
};

clear_dragged_unit = function()
{
	if (instance_exists(global.dragged_cultist))
	{
		global.dragged_cultist.is_being_dragged = false;
	}

	global.dragged_cultist = noone;
	global.cultist_assignment_preview_building = noone;
};

transform_demons_to_cultists = function()
{
	var _unit_count = array_length(global.cultists);
	var _new_cultists = array_create(0);

	for (var _unit_index = 0; _unit_index < _unit_count; ++_unit_index)
	{
		var _unit = global.cultists[_unit_index];

		if (!instance_exists(_unit))
		{
			continue;
		}

		if (_unit.object_index == o_cultist || !variable_instance_exists(_unit, "demon_type") || _unit.demon_type == DEMON_TYPE.NONE)
		{
			array_push(_new_cultists, _unit);
			continue;
		}

		clear_cultist_building_assignment(_unit);

		global.cultist_sprite_randomization_enabled = false;
		var _cultist = instance_create_layer(_unit.x, _unit.y, "Instances", o_cultist);
		global.cultist_sprite_randomization_enabled = true;
		var _unit_hp = _unit.hp;
		var _was_dead = _unit_hp <= 0;

		_cultist.cultist_name = _unit.cultist_name;
		_cultist.cultist_points = _unit.cultist_points;
		_cultist.demon_type = _unit.demon_type;
		_cultist.demon_ability = _unit.demon_ability;

		if (variable_instance_exists(_unit, "fatigue_amount"))
		{
			_cultist.fatigue_amount = _unit.fatigue_amount;
		}

		if (variable_instance_exists(_unit, "cultist_sprite_index"))
		{
			_cultist.cultist_sprite_index = _unit.cultist_sprite_index;
			_cultist.sprite_index = _unit.cultist_sprite_index;
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

		if (_was_dead)
		{
			_cultist.hp = _cultist.max_hp * BALANCE_CULTIST_MORNING_RESPAWN_HP_SHARE;
			_cultist.morning_respawn_pending = true;
		}

		array_push(_new_cultists, _cultist);
		instance_destroy(_unit);
	}

	global.cultists = _new_cultists;
};

cultist_levelup_find_next = function(_start_index)
{
	var _cultist_count = array_length(global.cultists);

	for (var _cultist_index = max(0, _start_index); _cultist_index < _cultist_count; ++_cultist_index)
	{
		var _cultist = global.cultists[_cultist_index];

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

open_cultist_levelup = function()
{
	var _next_levelup_index = cultist_levelup_find_next(0);

	if (_next_levelup_index < 0)
	{
		return false;
	}

	cultist_levelup_open = true;
	cultist_levelup_index = _next_levelup_index;
	player_pause_active = false;
	global.pause = true;
	global.focus_window = FOCUS_WINDOW.CULTIST_LEVEL_UP;

	return true;
};

award_cultist_night_exp = function()
{
	var _has_levelup = false;
	var _cultist_count = array_length(global.cultists);
	var _valid_cultists = [];

	for (var _cultist_index = 0; _cultist_index < _cultist_count; ++_cultist_index)
	{
		var _cultist = global.cultists[_cultist_index];

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
		var _cultist = global.cultists[_cultist_index];
		var _exp_reward = BALANCE_CULTIST_NIGHT_EXP_MINOR_REWARD;

		if (_cultist == _full_reward_cultist)
		{
			_exp_reward = BALANCE_CULTIST_NIGHT_EXP_REWARD;
		}

		if (cultist_exp_add(_cultist, _exp_reward))
		{
			_has_levelup = true;
		}
	}

	if (_has_levelup)
	{
		open_cultist_levelup();
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

night_attack_total_difficulty_get = function()
{
	var _extra_cultist_count = max(0, array_length(global.cultists) - BALANCE_STARTING_CULTIST_COUNT);
	var _night_index = max(1, night_attack_night_index);
	var _early_night_count = max(0, min(_night_index - 1, BALANCE_NIGHT_ATTACK_DIFFICULTY_LATE_START_NIGHT - 2));
	var _late_night_count = max(0, _night_index - BALANCE_NIGHT_ATTACK_DIFFICULTY_LATE_START_NIGHT + 1);

	var _difficulty = BALANCE_NIGHT_ATTACK_DIFFICULTY_BASE
		+ (_early_night_count * BALANCE_NIGHT_ATTACK_DIFFICULTY_INCREASE_PER_NIGHT)
		+ (_late_night_count * BALANCE_NIGHT_ATTACK_DIFFICULTY_LATE_INCREASE_PER_NIGHT)
		+ (_extra_cultist_count * BALANCE_NIGHT_ATTACK_DIFFICULTY_PER_EXTRA_CULTIST);

	if (BALANCE_ADAPTIVE_DIFFICULTY_ENABLED)
	{
		_difficulty *= adaptive_difficulty_multiplier;
	}

	return _difficulty;
};

adaptive_difficulty_low_hp_cultist_count_get = function()
{
	var _low_hp_count = 0;
	var _cultist_count = array_length(global.cultists);

	for (var _cultist_index = 0; _cultist_index < _cultist_count; ++_cultist_index)
	{
		var _cultist = global.cultists[_cultist_index];

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

adaptive_difficulty_evaluate_night = function()
{
	if (!BALANCE_ADAPTIVE_DIFFICULTY_ENABLED)
	{
		return;
	}

	var _difficulty_delta = 0;
	var _cannon_hp_loss_share = 0;

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
		}
		else if (_cannon_hp_loss_share > BALANCE_ADAPTIVE_DIFFICULTY_CANNON_HARD_HP_LOSS_SHARE)
		{
			_difficulty_delta -= BALANCE_ADAPTIVE_DIFFICULTY_HARD_DECREASE;
		}
		else
		{
			_difficulty_delta += BALANCE_ADAPTIVE_DIFFICULTY_NORMAL_INCREASE;
		}
	}

	var _low_hp_cultist_count = adaptive_difficulty_low_hp_cultist_count_get();

	if (_low_hp_cultist_count <= 0)
	{
		_difficulty_delta += BALANCE_ADAPTIVE_DIFFICULTY_EASY_INCREASE;
	}
	else if (_low_hp_cultist_count > BALANCE_ADAPTIVE_DIFFICULTY_CULTIST_NORMAL_LOW_HP_MAX)
	{
		_difficulty_delta -= BALANCE_ADAPTIVE_DIFFICULTY_HARD_DECREASE;
	}
	else
	{
		_difficulty_delta += BALANCE_ADAPTIVE_DIFFICULTY_NORMAL_INCREASE;
	}

	adaptive_difficulty_multiplier = clamp(
		adaptive_difficulty_multiplier + _difficulty_delta,
		BALANCE_ADAPTIVE_DIFFICULTY_MIN_MULTIPLIER,
		BALANCE_ADAPTIVE_DIFFICULTY_MAX_MULTIPLIER
	);
	adaptive_last_night_cannon_hp_loss_share = _cannon_hp_loss_share;
	adaptive_last_night_low_hp_cultists = _low_hp_cultist_count;
	adaptive_last_night_delta = _difficulty_delta;
};

enemy_night_hp_multiplier_get = function()
{
	return 1 + (max(1, night_attack_night_index) - 1) * BALANCE_ENEMY_HP_INCREASE_PER_NIGHT;
};

enemy_night_hp_scale_apply = function(_enemy)
{
	if (!instance_exists(_enemy)
		|| !variable_instance_exists(_enemy, "max_hp")
		|| !variable_instance_exists(_enemy, "hp"))
	{
		return;
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

night_attack_plan_create = function()
{
	var _direction_count = max(1, BALANCE_NIGHT_ATTACK_DIRECTION_COUNT);

	if (night_attack_night_index == 1)
	{
		_direction_count = max(1, BALANCE_FIRST_NIGHT_ATTACK_DIRECTION_COUNT);
	}

	var _total_difficulty = night_attack_total_difficulty_get();
	var _direction_difficulty = min(
		_total_difficulty / _direction_count,
		BALANCE_NIGHT_ATTACK_DIRECTION_DIFFICULTY_MAX
	);
	var _first_direction = random(360);
	var _second_direction_offset = random_range(
		BALANCE_NIGHT_ATTACK_DIRECTION_MIN_ANGLE,
		BALANCE_NIGHT_ATTACK_DIRECTION_MAX_ANGLE
	);

	if (choose(true, false))
	{
		_second_direction_offset = -_second_direction_offset;
	}

	var _directions = [_first_direction];

	if (_direction_count > 1)
	{
		array_push(_directions, (_first_direction + _second_direction_offset + 360) mod 360);
	}

	night_attack_directions = [];

	var _previous_pair = [];

	for (var _direction_index = 0; _direction_index < _direction_count; ++_direction_index)
	{
		var _direction = _directions[_direction_index mod array_length(_directions)];
		var _enemy_objects = night_attack_unit_pair_roll(_previous_pair);
		var _wave_count = night_attack_wave_count_get(_direction_difficulty, _enemy_objects);

		_previous_pair = _enemy_objects;

		array_push(
			night_attack_directions,
			{
				direction: _direction,
				enemy_objects: _enemy_objects,
				direction_difficulty: _direction_difficulty,
				wave_count: _wave_count,
				wave_difficulty: _direction_difficulty / _wave_count,
				remaining_difficulty: _direction_difficulty,
				remaining_enemy_difficulties: night_attack_enemy_difficulty_share_create(_enemy_objects, _direction_difficulty),
				wave_index: 0,
				wave_timer: 0,
				spawn_timer: 0,
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
	_direction_data.remaining_difficulty = max(
		0,
		night_attack_array_sum(_direction_data.remaining_enemy_difficulties)
	);
	_direction_data.current_wave_spawn_index = 0;
	_direction_data.spawn_timer = 0;
	night_attack_directions[_direction_index] = _direction_data;
};

night_attack_enemy_spawn = function(_direction_data, _enemy_object)
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
	_enemy.owner_garnizon = noone;
	_enemy.guard_target = noone;
	enemy_night_hp_scale_apply(_enemy);
	global.night_attack_unit_count++;
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

		for (var _batch_index = 0; _batch_index < BALANCE_NIGHT_ATTACK_SPAWN_BATCH_COUNT; ++_batch_index)
		{
			if (_direction_data.current_wave_spawn_index >= _wave_unit_count)
			{
				break;
			}

			var _enemy_object = _direction_data.current_wave_units[_direction_data.current_wave_spawn_index];

			night_attack_enemy_spawn(_direction_data, _enemy_object);
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

night_attack_is_complete = function()
{
	return night_attack_all_waves_spawned()
		&& !night_attack_alive_enemy_exists();
};

start_night_phase = function()
{
	clear_dragged_unit();
	cannon_corpse_workers_drop_all();
	global.day_phase = DAY_PHASE.NIGHT;
	global.day_timer = global.night_duration * room_speed;
	global.night_attack_unit_count = 0;
	global.sound_play_random(global.night_start_sounds);
	move_goblins_to_cannon_inner();

	if (instance_exists(o_cannon))
	{
		var _cannon = instance_find(o_cannon, 0);
		adaptive_night_cannon_hp_start = _cannon.hp;
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
};

start_day_phase = function()
{
	clear_dragged_unit();
	global.day_phase = DAY_PHASE.DAY;
	global.day_timer = global.day_duration * room_speed;
	global.night_attack_unit_count = 0;
	adaptive_difficulty_evaluate_night();
	night_attack_night_index++;

	fade_out_morning_meat();
	corpse_decay_at_morning();
	update_summoned_unit_night_life();

	cultist_projectile_deploy_assignments_reset();
	unload_cultist_projectiles_to_day();
	transform_demons_to_cultists();
	restore_dead_cultists_at_morning();
	move_cultists_to_cannon_inner();
	move_summoned_units_to_cannon_inner();

	with (o_boneyard)
	{
		boneyard_spawn_morning_units();
	}

	with (o_pitlings_house)
	{
		pitlings_house_spawn_morning_units();
	}

	with (o_ritual_circle)
	{
		if (variable_instance_exists(id, "ritual_circle_daily_exp_remaining"))
		{
			ritual_circle_daily_exp_remaining = BALANCE_RITUAL_CIRCLE_DAILY_EXP_LIMIT;
		}
	}

	award_cultist_night_exp();
	award_day_cultists();
	night_attack_plan_create();
};

fade_out_morning_meat = function()
{
	with (o_meat)
	{
		fade_out_start();
	}
};

add_cultist_level_point = function(_stat_index)
{
	if (cultist_levelup_index < 0 || cultist_levelup_index >= array_length(global.cultists))
	{
		return;
	}

	var _cultist = global.cultists[cultist_levelup_index];

	if (instance_exists(_cultist) && variable_instance_exists(_cultist, "cultist_points"))
	{
		if (!variable_instance_exists(_cultist, "pending_level_points")
			|| _cultist.pending_level_points <= 0)
		{
			return;
		}

		_cultist.cultist_points[_stat_index]++;

		if (variable_instance_exists(_cultist, "pending_level_points"))
		{
			_cultist.pending_level_points = max(_cultist.pending_level_points - 1, 0);
		}

		if (variable_instance_exists(_cultist, "demon_type") && _cultist.demon_type != DEMON_TYPE.NONE && _cultist.object_index != o_cultist)
		{
			var _cultist_hp = _cultist.hp;

			cultist_stats_apply(_cultist);
			_cultist.hp = clamp(_cultist_hp, 0, _cultist.max_hp);
		}
		else if (variable_instance_exists(_cultist, "demon_type") && _cultist.demon_type != DEMON_TYPE.NONE)
		{
			cultist_day_health_apply(_cultist, false);
		}
	}

	cultist_levelup_index = cultist_levelup_find_next(cultist_levelup_index);

	if (cultist_levelup_index < 0)
	{
		cultist_levelup_open = false;
		global.pause = false;
		global.focus_window = FOCUS_WINDOW.NOONE;
	}
};

ensure_cultist_levelup_options = function(_cultist)
{
	if (!instance_exists(_cultist))
	{
		return;
	}

	var _reward_type = cultist_level_reward_type_get(_cultist);

	if (_reward_type == CULTIST_LEVEL_REWARD.PASSIVE
		&& (!variable_instance_exists(_cultist, "passive_choice_options")
			|| array_length(_cultist.passive_choice_options) <= 0))
	{
		_cultist.passive_choice_options = cultist_ability_options_roll(_cultist, true);
	}
	else if (_reward_type == CULTIST_LEVEL_REWARD.ACTIVE
		&& (!variable_instance_exists(_cultist, "active_choice_options")
			|| array_length(_cultist.active_choice_options) <= 0))
	{
		_cultist.active_choice_options = cultist_ability_options_roll(_cultist, false);
	}
	else if (_reward_type == CULTIST_LEVEL_REWARD.ABILITY_UPGRADE
		&& (!variable_instance_exists(_cultist, "ability_upgrade_choice_options")
			|| array_length(_cultist.ability_upgrade_choice_options) <= 0))
	{
		_cultist.ability_upgrade_choice_options = cultist_ability_upgrade_options_roll(_cultist);
	}
};

add_cultist_level_ability = function(_ability)
{
	if (cultist_levelup_index < 0 || cultist_levelup_index >= array_length(global.cultists))
	{
		return;
	}

	var _cultist = global.cultists[cultist_levelup_index];

	if (!instance_exists(_cultist))
	{
		return;
	}

	var _reward_type = cultist_level_reward_type_get(_cultist);

	if (_reward_type == CULTIST_LEVEL_REWARD.PASSIVE && cultist_passive_ability_unlock(_cultist, _ability))
	{
		_cultist.pending_passive_choices = max(_cultist.pending_passive_choices - 1, 0);
		_cultist.passive_choice_options = [];
	}
	else if (_reward_type == CULTIST_LEVEL_REWARD.ACTIVE && cultist_active_ability_unlock(_cultist, _ability))
	{
		_cultist.pending_active_choices = max(_cultist.pending_active_choices - 1, 0);
		_cultist.active_choice_options = [];
	}
	else if (_reward_type == CULTIST_LEVEL_REWARD.ABILITY_UPGRADE && cultist_ability_level_add(_cultist, _ability))
	{
		_cultist.pending_ability_upgrade_choices = max(_cultist.pending_ability_upgrade_choices - 1, 0);
		_cultist.ability_upgrade_choice_options = [];
	}

	cultist_levelup_index = cultist_levelup_find_next(cultist_levelup_index);

	if (cultist_levelup_index < 0)
	{
		cultist_levelup_open = false;
		global.pause = false;
		global.focus_window = FOCUS_WINDOW.NOONE;
	}
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
