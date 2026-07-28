// Configure a deterministic room that uses the regular unit combat code.
global.balance_test_active = true;
global.balance_test_manual_tick_active = false;
global.pause = false;
global.day_phase = DAY_PHASE.NIGHT;
global.fog_of_war_visible = false;
global.archdemons = [];

// Every matchup uses the same three fixed random sequences on every test run.
simulation_random_seeds = [
	BALANCE_TEST_RANDOM_SEED_1,
	BALANCE_TEST_RANDOM_SEED_2,
	BALANCE_TEST_RANDOM_SEED_3
];
simulation_count = array_length(simulation_random_seeds);
current_simulation_index = 0;

// Optional support is selected before a complete test run starts.
optional_test_configs = [
	{ option_id: "skeleton_healer", label: "1 Skeleton Healer", enabled: false, object_index: o_skeleton_healer, option_type: "unit" },
	{ option_id: "demon_wizard", label: "1 Demon Wizard", enabled: false, object_index: o_demon_wizard, option_type: "unit" },
	{ option_id: "heal_tower", label: "1 Heal Tower", enabled: false, object_index: o_tower_heal, option_type: "tower" },
	{ option_id: "damage_tower", label: "1 Damage Tower", enabled: false, object_index: o_tower_damage, option_type: "tower" },
	{ option_id: "magic_tower", label: "1 Magic Tower", enabled: false, object_index: o_magic_tower, option_type: "tower" }
];
configuration_is_confirmed = false;
configuration_panel_width = 520;
configuration_panel_height = 500;
configuration_option_height = 48;
configuration_option_gap = 8;
configuration_start_width = 220;
configuration_start_height = 54;

balance_test_configuration_option_rect_get = function(_option_index)
{
	var _gui_width = display_get_gui_width();
	var _gui_height = display_get_gui_height();
	var _panel_x = (_gui_width - configuration_panel_width) * 0.5;
	var _panel_y = (_gui_height - configuration_panel_height) * 0.5;

	return {
		x: _panel_x + 44,
		y: _panel_y + 92 + (_option_index * (configuration_option_height + configuration_option_gap)),
		width: configuration_panel_width - 88,
		height: configuration_option_height
	};
};

balance_test_configuration_start_rect_get = function()
{
	var _gui_width = display_get_gui_width();
	var _gui_height = display_get_gui_height();
	var _panel_y = (_gui_height - configuration_panel_height) * 0.5;

	return {
		x: (_gui_width - configuration_start_width) * 0.5,
		y: _panel_y + configuration_panel_height - configuration_start_height - 30,
		width: configuration_start_width,
		height: configuration_start_height
	};
};

balance_test_option_enabled_get = function(_option_id)
{
	for (var _option_index = 0; _option_index < array_length(optional_test_configs); ++_option_index)
	{
		var _option = optional_test_configs[_option_index];

		if (_option.option_id == _option_id)
		{
			return _option.enabled;
		}
	}

	return false;
};

// The game controller initializes shared globals and functions, then remains inactive here.
with (o_jobs_ui)
{
	instance_destroy();
}

with (o_tutorial_controller)
{
	instance_destroy();
}

instance_deactivate_object(o_game_controller);
global.sound_play_random = function(_sounds, _priority = 0)
{
	return noone;
};

friendly_test_units = [
	{ name: "SKELETON BONELET", object_index: o_skeleton_bonelet, count: 10 },
	{ name: "SKELETON WARRIOR", object_index: o_skeleton_warrior, count: 10 },
	{ name: "SKELETON ARCHER", object_index: o_skeleton_archer, count: 10 },
	{ name: "SKELETON MAGE", object_index: o_skeleton_mage, count: 10 },
	{ name: "MAWLING", object_index: o_mawling, count: 5 },
	{ name: "PITLING", object_index: o_pitling, count: 5 },
	{ name: "SUCCUBUS", object_index: o_succubus, count: 5 },
	{ name: "BALGOR", object_index: o_balgor, count: 5 }
];

enemy_test_units = [
	{ name: "PEASANT", object_index: o_enemy_peasant, count: 25 },
	{ name: "KNIGHT", object_index: o_enemy_knight, count: 8 },
	{ name: "ARCHER", object_index: o_enemy_archer, count: 8 },
	{ name: "MAGE", object_index: o_enemy_mage, count: 8 },
	{ name: "CATAPULT", object_index: o_enemy_catapult, count: 4 }
];

friendly_test_unit_count = array_length(friendly_test_units);
enemy_test_unit_count = array_length(enemy_test_units);
test_results = array_create(friendly_test_unit_count);
test_score_totals = array_create(friendly_test_unit_count);

for (var _row_index = 0; _row_index < friendly_test_unit_count; ++_row_index)
{
	test_results[_row_index] = array_create(enemy_test_unit_count, "");
	test_score_totals[_row_index] = array_create(enemy_test_unit_count, 0);
}

current_row = 0;
row_is_running = false;
row_start_timer = 1;
row_elapsed_frames = 0;
completed_match_count = 0;
total_match_count = friendly_test_unit_count * enemy_test_unit_count * simulation_count;
test_is_complete = false;
active_friendly_groups = array_create(enemy_test_unit_count);
active_enemy_groups = array_create(enemy_test_unit_count);
active_optional_friendly_groups = array_create(enemy_test_unit_count);
active_heal_towers = array_create(enemy_test_unit_count, noone);
active_damage_towers = array_create(enemy_test_unit_count, noone);
active_magic_towers = array_create(enemy_test_unit_count, noone);
active_match_finished = array_create(enemy_test_unit_count, false);
status_message = "Preparing balance test...";
copy_feedback_timer = 0;
selected_arena_index = 0;
table_is_visible = false;
simulation_speed_multiplier = BALANCE_TEST_SIMULATION_SPEED;

// A dedicated camera lets the player watch any of the five parallel arenas.
balance_test_camera_width = 1000;
balance_test_camera_height = 620;
balance_test_camera = camera_create_view(0, 0, balance_test_camera_width, balance_test_camera_height);
view_camera[0] = balance_test_camera;
view_visible[0] = true;

balance_test_unit_configure = function(_unit, _match_id)
{
	if (!instance_exists(_unit))
	{
		return;
	}

	_unit.balance_test_match_id = _match_id;
	_unit.balance_test_simulation_finished = false;
	_unit.debug_combat_spawned = true;
	_unit.regroup_is_active = false;
	_unit.rally_is_active = false;
	_unit.friendly_guard_cannon_enabled = false;
	_unit.unit_can_attack_cannon = false;
	_unit.corpse_visual_created = true;
	_unit.target_detection_radius = max(_unit.target_detection_radius, BALANCE_TEST_TARGET_DETECTION_RADIUS);
	_unit.vision_radius = max(_unit.vision_radius, BALANCE_TEST_TARGET_DETECTION_RADIUS);
	_unit.target_instance = noone;
	_unit.alert_target = noone;
	_unit.visible = true;
};

balance_test_group_spawn = function(_unit_object, _unit_count, _center_x, _center_y, _match_id)
{
	var _units = array_create(_unit_count);
	var _column_count = ceil(sqrt(_unit_count));
	var _row_count = ceil(_unit_count / _column_count);
	var _start_x = _center_x - ((_column_count - 1) * BALANCE_TEST_UNIT_SPACING * 0.5);
	var _start_y = _center_y - ((_row_count - 1) * BALANCE_TEST_UNIT_SPACING * 0.5);

	for (var _unit_index = 0; _unit_index < _unit_count; ++_unit_index)
	{
		var _column = _unit_index mod _column_count;
		var _row = floor(_unit_index / _column_count);
		var _unit_x = _start_x + (_column * BALANCE_TEST_UNIT_SPACING);
		var _unit_y = _start_y + (_row * BALANCE_TEST_UNIT_SPACING);
		var _unit = instance_create_layer(_unit_x, _unit_y, "Instances", _unit_object);

		balance_test_unit_configure(_unit, _match_id);
		_units[_unit_index] = _unit;
	}

	return _units;
};

balance_test_group_equivalent_get = function(_units)
{
	var _equivalent_count = 0;
	var _unit_count = array_length(_units);

	for (var _unit_index = 0; _unit_index < _unit_count; ++_unit_index)
	{
		var _unit = _units[_unit_index];

		if (instance_exists(_unit) && _unit.hp > 0 && _unit.max_hp > 0)
		{
			_equivalent_count += clamp(_unit.hp / _unit.max_hp, 0, 1);
		}
	}

	return _equivalent_count;
};

balance_test_group_destroy = function(_units)
{
	var _unit_count = array_length(_units);

	for (var _unit_index = 0; _unit_index < _unit_count; ++_unit_index)
	{
		var _unit = _units[_unit_index];

		if (instance_exists(_unit))
		{
			with (_unit)
			{
				instance_destroy();
			}
		}
	}
};

balance_test_group_freeze = function(_units)
{
	var _unit_count = array_length(_units);

	for (var _unit_index = 0; _unit_index < _unit_count; ++_unit_index)
	{
		var _unit = _units[_unit_index];

		if (instance_exists(_unit))
		{
			_unit.balance_test_simulation_finished = true;
			_unit.is_walking = false;
			_unit.is_attacking_target = false;
		}
	}
};

balance_test_run_score_get = function(
	_friendly_equivalent,
	_enemy_equivalent,
	_friendly_start_count,
	_enemy_start_count
)
{
	var _friendly_hp_percent = (_friendly_equivalent / max(1, _friendly_start_count)) * 100;
	var _enemy_hp_percent = (_enemy_equivalent / max(1, _enemy_start_count)) * 100;

	return _friendly_hp_percent - _enemy_hp_percent;
};

balance_test_result_text_get = function(_average_score)
{
	if (_average_score > 0)
	{
		return "+" + string_format(_average_score, 0, 2) + "%";
	}

	if (_average_score < 0)
	{
		return string_format(_average_score, 0, 2) + "%";
	}

	return "0.00%";
};

balance_test_row_start = function(_row_index)
{
	var _friendly_config = friendly_test_units[_row_index];
	var _group_half_distance = BALANCE_TEST_GROUP_DISTANCE * 0.5;
	var _simulation_number = current_simulation_index + 1;

	// Reset randomness before each pass so the three generation codes stay reproducible.
	random_set_seed(simulation_random_seeds[current_simulation_index]);

	for (var _column_index = 0; _column_index < enemy_test_unit_count; ++_column_index)
	{
		var _enemy_config = enemy_test_units[_column_index];
		var _arena_center_x = 700 + (_column_index * BALANCE_TEST_ARENA_SPACING);
		var _arena_center_y = 700;
		var _match_id = ((_row_index * simulation_count + current_simulation_index) * enemy_test_unit_count) + _column_index;

		active_friendly_groups[_column_index] = balance_test_group_spawn(
			_friendly_config.object_index,
			_friendly_config.count,
			_arena_center_x - _group_half_distance,
			_arena_center_y,
			_match_id
		);

		// Spawn selected support units without changing the measured primary army.
		var _optional_units = [];
		var _support_unit_y = _arena_center_y - 50;

		for (var _option_index = 0; _option_index < array_length(optional_test_configs); ++_option_index)
		{
			var _option = optional_test_configs[_option_index];

			if (!_option.enabled || _option.option_type != "unit")
			{
				continue;
			}

			var _support_unit = instance_create_layer(
				_arena_center_x - _group_half_distance - 70,
				_support_unit_y,
				"Instances",
				_option.object_index
			);
			balance_test_unit_configure(_support_unit, _match_id);
			array_push(_optional_units, _support_unit);
			_support_unit_y += 100;
		}

		active_optional_friendly_groups[_column_index] = _optional_units;

		// Spawn the selected captured towers behind the friendly army.
		var _tower_x = _arena_center_x - _group_half_distance - BALANCE_TEST_DAMAGE_TOWER_FRIENDLY_OFFSET;

		if (balance_test_option_enabled_get("damage_tower"))
		{
			var _damage_tower = instance_create_layer(
				_tower_x,
				_arena_center_y - BALANCE_TEST_TOWER_VERTICAL_OFFSET,
				"Instances",
				o_tower_damage
			);
			_damage_tower.balance_test_match_id = _match_id;
			_damage_tower.balance_test_simulation_finished = false;
			_damage_tower.tower_capture_enabled = false;
			_damage_tower.is_captured = true;
			_damage_tower.sprite_index = _damage_tower.captured_sprite_index;
			_damage_tower.image_speed = 0;
			active_damage_towers[_column_index] = _damage_tower;
		}

		if (balance_test_option_enabled_get("magic_tower"))
		{
			var _magic_tower = instance_create_layer(
				_tower_x,
				_arena_center_y + BALANCE_TEST_TOWER_VERTICAL_OFFSET,
				"Instances",
				o_magic_tower
			);
			_magic_tower.balance_test_match_id = _match_id;
			_magic_tower.balance_test_simulation_finished = false;
			_magic_tower.tower_capture_enabled = false;
			_magic_tower.is_captured = true;
			_magic_tower.sprite_index = _magic_tower.captured_sprite_index;
			_magic_tower.image_speed = 0;
			active_magic_towers[_column_index] = _magic_tower;
		}

		if (balance_test_option_enabled_get("heal_tower"))
		{
			var _heal_tower = instance_create_layer(
				_tower_x - 90,
				_arena_center_y,
				"Instances",
				o_tower_heal
			);
			_heal_tower.balance_test_match_id = _match_id;
			_heal_tower.balance_test_simulation_finished = false;
			_heal_tower.tower_capture_enabled = false;
			_heal_tower.is_captured = true;
			_heal_tower.sprite_index = _heal_tower.captured_sprite_index;
			_heal_tower.image_speed = 0;
			active_heal_towers[_column_index] = _heal_tower;
		}

		active_enemy_groups[_column_index] = balance_test_group_spawn(
			_enemy_config.object_index,
			_enemy_config.count,
			_arena_center_x + _group_half_distance,
			_arena_center_y,
			_match_id
		);
		active_match_finished[_column_index] = false;
	}

	row_elapsed_frames = 0;
	row_is_running = true;
	status_message = "Testing " + _friendly_config.name + " (run "
		+ string(_simulation_number) + "/" + string(simulation_count) + ")...";
};

balance_test_tsv_get = function()
{
	var _text = "Number\tUnit name";

	for (var _column_index = 0; _column_index < enemy_test_unit_count; ++_column_index)
	{
		var _enemy_config = enemy_test_units[_column_index];
		_text += "\t" + string(_enemy_config.count) + " " + _enemy_config.name;
	}

	for (var _row_index = 0; _row_index < friendly_test_unit_count; ++_row_index)
	{
		var _friendly_config = friendly_test_units[_row_index];
		_text += "\n" + string(_friendly_config.count) + "\t" + _friendly_config.name;

		for (var _column_index = 0; _column_index < enemy_test_unit_count; ++_column_index)
		{
			var _result = test_results[_row_index][_column_index];
			var _copied_result = _result;

			// Spreadsheet output uses signed numbers without plus signs or percent symbols.
			if (string_pos("+", _result) == 1 || string_pos("-", _result) == 1 || _result == "0.00%")
			{
				var _numeric_text = string_replace_all(_result, "%", "");

				if (string_pos("+", _numeric_text) == 1)
				{
					_numeric_text = string_delete(_numeric_text, 1, 1);
				}

				_copied_result = string_replace_all(string(real(_numeric_text)), ".", ",");
			}

			_text += "\t" + _copied_result;
		}
	}

	return _text;
};
