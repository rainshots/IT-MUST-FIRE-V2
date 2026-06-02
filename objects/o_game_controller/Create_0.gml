// Global pause state used by gameplay objects.
randomise()
global.pause = false;
global.focus_window = FOCUS_WINDOW.NOONE;
global.fog_of_war_visible = true;

// Global day cycle: day has a fixed timer, night ends when released holy troops die.
global.day_phase = DAY_PHASE.DAY;
global.day_duration = BALANCE_DAY_DURATION;
global.day_timer = global.day_duration * room_speed;
global.night_attack_unit_count = 0;
global.day_cycle_enabled = false;
global.legacy_building_logic_enabled = false;
global.cultists = array_create(0);

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
global.particle_type_brute_heal = part_type_create();
global.particle_type_brute_rotten_aura = part_type_create();
global.particle_type_brute_grave_slam_smoke = part_type_create();
global.particle_type_brute_meat_explosion_smoke = part_type_create();
global.particle_type_warlock_curseweaver_smoke = part_type_create();
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
	BALANCE_BRUTE_ABILITY_PARTICLE_SIZE_MIN,
	BALANCE_BRUTE_ABILITY_PARTICLE_SIZE_MAX,
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
part_type_life(global.particle_type_imp_blood_frenzy_smoke, BALANCE_BRUTE_PASSIVE_PARTICLE_LIFE_MIN, BALANCE_BRUTE_PASSIVE_PARTICLE_LIFE_MAX);

part_type_sprite(global.particle_type_brute_heal, s_heal_particle, false, false, true);
part_type_size(
	global.particle_type_brute_heal,
	BALANCE_BRUTE_HEAL_PARTICLE_SIZE_MIN,
	BALANCE_BRUTE_HEAL_PARTICLE_SIZE_MAX,
	-0.006,
	0
);
part_type_color1(global.particle_type_brute_heal, COLOR_STATUS_SOUL_MARK);
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
	BALANCE_BRUTE_ROTTEN_AURA_PARTICLE_SIZE_MIN,
	BALANCE_BRUTE_ROTTEN_AURA_PARTICLE_SIZE_MAX,
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
part_type_life(global.particle_type_brute_rotten_aura, BALANCE_BRUTE_PASSIVE_PARTICLE_LIFE_MIN, BALANCE_BRUTE_PASSIVE_PARTICLE_LIFE_MAX);

part_type_sprite(global.particle_type_brute_grave_slam_smoke, s_smoke_small_particle, false, false, true);
part_type_size(
	global.particle_type_brute_grave_slam_smoke,
	BALANCE_BRUTE_ABILITY_PARTICLE_SIZE_MIN,
	BALANCE_BRUTE_ABILITY_PARTICLE_SIZE_MAX,
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
part_type_life(global.particle_type_brute_grave_slam_smoke, BALANCE_BRUTE_PASSIVE_PARTICLE_LIFE_MIN, BALANCE_BRUTE_PASSIVE_PARTICLE_LIFE_MAX);

part_type_sprite(global.particle_type_brute_meat_explosion_smoke, s_smoke_small_particle, false, false, true);
part_type_size(
	global.particle_type_brute_meat_explosion_smoke,
	BALANCE_BRUTE_ABILITY_PARTICLE_SIZE_MIN,
	BALANCE_BRUTE_ABILITY_PARTICLE_SIZE_MAX,
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
part_type_life(global.particle_type_brute_meat_explosion_smoke, BALANCE_BRUTE_PASSIVE_PARTICLE_LIFE_MIN, BALANCE_BRUTE_PASSIVE_PARTICLE_LIFE_MAX);

part_type_sprite(global.particle_type_warlock_curseweaver_smoke, s_smoke_small_particle, false, false, true);
part_type_size(
	global.particle_type_warlock_curseweaver_smoke,
	BALANCE_WARLOCK_PASSIVE_PARTICLE_SIZE_MIN,
	BALANCE_WARLOCK_PASSIVE_PARTICLE_SIZE_MAX,
	-0.02,
	0
);
part_type_color1(global.particle_type_warlock_curseweaver_smoke, COLOR_WARLOCK_CURSEWEAVER);
part_type_alpha2(global.particle_type_warlock_curseweaver_smoke, 0.75, 0);
part_type_speed(
	global.particle_type_warlock_curseweaver_smoke,
	BALANCE_BRUTE_PASSIVE_PARTICLE_SPEED_MIN,
	BALANCE_BRUTE_PASSIVE_PARTICLE_SPEED_MAX,
	-0.01,
	0
);
part_type_direction(global.particle_type_warlock_curseweaver_smoke, 0, 359, 0, 0);
part_type_life(global.particle_type_warlock_curseweaver_smoke, BALANCE_BRUTE_PASSIVE_PARTICLE_LIFE_MIN, BALANCE_BRUTE_PASSIVE_PARTICLE_LIFE_MAX);

// Global cannon target selected through the target selection mode.
global.cannon_target_exists = false;
global.cannon_target_x = 0;
global.cannon_target_y = 0;
global.cannon_target_projectile_type = PROJECTILE_TYPE.DAMAGE;
global.cannon_target_version = 0;

// Global cannon projectile queue consumed from the first slot.
global.cannon_projectile_queue = [
	PROJECTILE_TYPE.DAMAGE,
	PROJECTILE_TYPE.CORRUPTION,
	PROJECTILE_TYPE.SUMMON,
	PROJECTILE_TYPE.RALLY
];
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
global.cannon_projectile_cheat_enabled = false;
global.rally_projectile_group_id = 0;

// Global resource storage used by HUD and economy systems.
global.resources = array_create(RESOURCES.COUNT, 0);
global.resources[RESOURCES.FLESH] = 0;
global.resources[RESOURCES.SOULS] = 0;
global.resources[RESOURCES.IRON] = 0;

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

// Pause menu button data.
continue_button_index = 0;
settings_button_index = 1;
quit_button_index = 2;
pause_button_labels = ["CONTINUE", "SETTINGS", "QUIT"];
pause_button_count = array_length(pause_button_labels);

// Menu visual settings.
overlay_alpha = 0.45;
night_overlay_alpha = BALANCE_NIGHT_OVERLAY_ALPHA;
button_width = 280;
button_height = 58;
button_gap = 18;
settings_panel_width = 420;
settings_panel_height = 220;
fullscreen_toggle_size = 34;
settings_toggle_right_padding = 82;
settings_toggle_top_padding = 84;
settings_close_bottom_padding = 28;

// Cultist prototype state.
cultist_start_count = BALANCE_STARTING_CULTIST_COUNT;
cultists_spawned = false;
cultist_spawn_spacing = 54;
cultist_spawn_offset_x = -96;
cultist_spawn_offset_y = 76;
cultist_selection_index = 0;
cultist_selected_demon_type = DEMON_TYPE.IMP;
cultist_name_input_active = true;
cultist_selection_buttons = [
	DEMON_TYPE.IMP,
	DEMON_TYPE.WARLOCK,
	DEMON_TYPE.BRUTE
];
cultist_selection_button_width = 128;
cultist_selection_button_height = 42;
cultist_selection_button_gap = 14;
cultist_panel_width = 720;
cultist_panel_height = 520;
cultist_levelup_open = false;
cultist_levelup_index = 0;
cultist_drag_lift_offset_y = -30;
cultist_drag_drop_offset_y = 30;
global.cultist_drag_shadow_width = 46;
global.cultist_drag_shadow_height = 14;
global.dragged_cultist = noone;
global.cultist_assignment_preview_building = noone;

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

clear_cultist_building_assignment = function(_cultist)
{
	if (!instance_exists(_cultist) || !variable_instance_exists(_cultist, "assigned_building"))
	{
		return;
	}

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

// Assign a day-form cultist to a worker building and snap them beside it.
assign_cultist_to_worker_building = function(_cultist, _building)
{
	if (!instance_exists(_cultist) || !instance_exists(_building) || _cultist.object_index != o_cultist)
	{
		return false;
	}

	clear_cultist_building_assignment(_cultist);

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
	arrange_resource_building_workers(_building);

	if (variable_instance_exists(_building, "recalculate_production_speed_multiplier"))
	{
		_building.recalculate_production_speed_multiplier();
	}

	return true;
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

spawn_starting_cultists = function()
{
	if (!instance_exists(o_cannon))
	{
		return;
	}

	var _cannon = instance_find(o_cannon, 0);
	global.cultists = array_create(0);

	for (var _cultist_index = 0; _cultist_index < cultist_start_count; ++_cultist_index)
	{
		var _spawn_x = _cannon.x + cultist_spawn_offset_x + (_cultist_index * cultist_spawn_spacing);
		var _spawn_y = _cannon.y + cultist_spawn_offset_y;
		var _cultist = instance_create_layer(_spawn_x, _spawn_y, "Instances", o_cultist);

		array_push(global.cultists, _cultist);
	}

	cultists_spawned = true;
	global.pause = true;
	global.focus_window = FOCUS_WINDOW.CULTIST_DEMON_SELECTION;
	keyboard_string = "";
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
	_cultist.demon_ability = cultist_starting_ability_get(_cultist, cultist_selected_demon_type);
	_cultist.active_abilities = [_cultist.demon_ability];
	cultist_day_health_apply(_cultist, true);

	cultist_selection_index++;
	keyboard_string = "";
	cultist_selected_demon_type = DEMON_TYPE.IMP;

	if (cultist_selection_index >= array_length(global.cultists))
	{
		global.pause = false;
		global.focus_window = FOCUS_WINDOW.NOONE;
	}
};

transform_cultists_to_demons = function()
{
	var _cultist_count = array_length(global.cultists);
	var _new_units = array_create(0);

	for (var _cultist_index = 0; _cultist_index < _cultist_count; ++_cultist_index)
	{
		var _cultist = global.cultists[_cultist_index];

		if (!instance_exists(_cultist) || _cultist.object_index != o_cultist || _cultist.demon_type == DEMON_TYPE.NONE)
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

		_demon.cultist_name = _cultist.cultist_name;
		_demon.cultist_points = _cultist.cultist_points;
		_demon.demon_type = _cultist.demon_type;
		_demon.demon_ability = _cultist.demon_ability;

		_demon.current_exp = _cultist.current_exp;
		_demon.current_lvl = _cultist.current_lvl;
		_demon.pending_level_points = _cultist.pending_level_points;
		_demon.pending_passive_choices = _cultist.pending_passive_choices;
		_demon.pending_active_choices = _cultist.pending_active_choices;
		_demon.passive_choice_options = _cultist.passive_choice_options;
		_demon.active_choice_options = _cultist.active_choice_options;
		_demon.active_abilities = _cultist.active_abilities;
		_demon.has_imp_blood_frenzy = _cultist.has_imp_blood_frenzy;
		_demon.has_imp_hellbleed = _cultist.has_imp_hellbleed;
		_demon.has_imp_taste_of_fear = _cultist.has_imp_taste_of_fear;
		_demon.has_brute_corpse_eater = _cultist.has_brute_corpse_eater;
		_demon.has_brute_rotten_aura = _cultist.has_brute_rotten_aura;
		_demon.has_brute_cursed_flesh = _cultist.has_brute_cursed_flesh;
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

cultist_levelup_find_next = function(_start_index)
{
	var _cultist_count = array_length(global.cultists);

	for (var _cultist_index = max(0, _start_index); _cultist_index < _cultist_count; ++_cultist_index)
	{
		var _cultist = global.cultists[_cultist_index];

		if (instance_exists(_cultist)
			&& ((variable_instance_exists(_cultist, "pending_level_points") && _cultist.pending_level_points > 0)
				|| (variable_instance_exists(_cultist, "pending_passive_choices") && _cultist.pending_passive_choices > 0)
				|| (variable_instance_exists(_cultist, "pending_active_choices") && _cultist.pending_active_choices > 0)))
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

	for (var _cultist_index = 0; _cultist_index < _cultist_count; ++_cultist_index)
	{
		var _cultist = global.cultists[_cultist_index];

		if (cultist_exp_add(_cultist, BALANCE_CULTIST_NIGHT_EXP_REWARD))
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
			_friendly_unit.summon_nights_remaining--;

			if (_friendly_unit.summon_nights_remaining <= 0)
			{
				instance_destroy(_friendly_unit);
			}
		}
	}
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

	cultist_levelup_index = cultist_levelup_find_next(cultist_levelup_index);

	if (cultist_levelup_index < 0)
	{
		cultist_levelup_open = false;
		global.pause = false;
		global.focus_window = FOCUS_WINDOW.NOONE;
	}
};

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
