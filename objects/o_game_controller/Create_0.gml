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
	DEMON_TYPE.ZOMBIE
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

// Find the first empty resource building under a world-space point.
find_resource_building_at_position = function(_world_x, _world_y)
{
	var _building_count = instance_number(o_v13buildings_parent);

	for (var _building_index = 0; _building_index < _building_count; ++_building_index)
	{
		var _building = instance_find(o_v13buildings_parent, _building_index);

		if (instance_exists(_building)
			&& variable_instance_exists(_building, "production_resource")
			&& _building.production_resource != noone
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

// Assign a day-form cultist to a resource building and snap them beside it.
assign_cultist_to_resource_building = function(_cultist, _building)
{
	if (!instance_exists(_cultist) || !instance_exists(_building) || _cultist.object_index != o_cultist)
	{
		return false;
	}

	clear_cultist_building_assignment(_cultist);

	if (!variable_instance_exists(_building, "worker_cultists")
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
	_cultist.demon_ability = cultist_ability_roll(cultist_selected_demon_type);

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
		_demon.cultist_name = _cultist.cultist_name;
		_demon.cultist_points = _cultist.cultist_points;
		_demon.demon_type = _cultist.demon_type;
		_demon.demon_ability = _cultist.demon_ability;
		_demon.current_exp = _cultist.current_exp;
		_demon.current_lvl = _cultist.current_lvl;
		cultist_stats_apply(_demon);

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

open_cultist_levelup = function()
{
	cultist_levelup_open = true;
	cultist_levelup_index = 0;
	global.pause = true;
	global.focus_window = FOCUS_WINDOW.CULTIST_LEVEL_UP;
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
		_cultist.current_lvl++;

		if (variable_instance_exists(_cultist, "demon_type") && _cultist.demon_type != DEMON_TYPE.NONE && _cultist.object_index != o_cultist)
		{
			cultist_stats_apply(_cultist);
		}
	}

	cultist_levelup_index++;

	if (cultist_levelup_index >= array_length(global.cultists))
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
