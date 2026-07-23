// Room controls remain available while the automated matches are running.
if (keyboard_check_pressed(vk_escape))
{
	room_goto(Room1);
	exit;
}

if (keyboard_check_pressed(ord("R")))
{
	room_restart();
	exit;
}

if (keyboard_check_pressed(ord("C")))
{
	clipboard_set_text(balance_test_tsv_get());
	copy_feedback_timer = room_speed * 2;
}

if (keyboard_check_pressed(vk_tab))
{
	table_is_visible = !table_is_visible;
}

if (keyboard_check_pressed(ord("F")))
{
	simulation_speed_multiplier = simulation_speed_multiplier == 1
		? BALANCE_TEST_SIMULATION_SPEED
		: 1;
}

// Number keys switch the camera between the five fights in the active row.
for (var _arena_key_index = 0; _arena_key_index < enemy_test_unit_count; ++_arena_key_index)
{
	if (keyboard_check_pressed(ord(string(_arena_key_index + 1))))
	{
		selected_arena_index = _arena_key_index;
		table_is_visible = false;
	}
}

var _selected_arena_center_x = 700 + (selected_arena_index * BALANCE_TEST_ARENA_SPACING);
var _selected_arena_center_y = 700;
camera_set_view_pos(
	balance_test_camera,
	_selected_arena_center_x - (balance_test_camera_width * 0.5),
	_selected_arena_center_y - (balance_test_camera_height * 0.5)
);

if (copy_feedback_timer > 0)
{
	copy_feedback_timer--;
}

if (test_is_complete)
{
	exit;
}

if (!row_is_running)
{
	row_start_timer -= simulation_speed_multiplier;

	if (row_start_timer <= 0)
	{
		balance_test_row_start(current_row);
	}

	exit;
}

var _finished_match_count = 0;

// The controller runs every combat tick at both x1 and accelerated speeds.
for (var _simulation_tick = 0; _simulation_tick < simulation_speed_multiplier; ++_simulation_tick)
{
	// Snapshot projectiles so shells created this tick start moving on the next tick.
	var _existing_projectile_count = instance_number(o_projectile);
	var _existing_projectiles = array_create(_existing_projectile_count);

	for (var _projectile_index = 0; _projectile_index < _existing_projectile_count; ++_projectile_index)
	{
		_existing_projectiles[_projectile_index] = instance_find(o_projectile, _projectile_index);
	}

	global.balance_test_manual_tick_active = true;

	with (o_units_parent)
	{
		event_perform(ev_step, ev_step_normal);
	}

	for (var _projectile_index = 0; _projectile_index < _existing_projectile_count; ++_projectile_index)
	{
		var _projectile = _existing_projectiles[_projectile_index];

		if (instance_exists(_projectile))
		{
			with (_projectile)
			{
				event_perform(ev_step, ev_step_normal);
			}
		}
	}

	global.balance_test_manual_tick_active = false;
	row_elapsed_frames++;
	_finished_match_count = 0;
	var _row_timed_out = row_elapsed_frames >= BALANCE_TEST_MATCH_TIMEOUT * room_speed;

	// Evaluate and freeze finished arenas after every simulated tick.
	for (var _column_index = 0; _column_index < enemy_test_unit_count; ++_column_index)
	{
		if (active_match_finished[_column_index])
		{
			_finished_match_count++;
			continue;
		}

		var _friendly_equivalent = balance_test_group_equivalent_get(active_friendly_groups[_column_index]);
		var _enemy_equivalent = balance_test_group_equivalent_get(active_enemy_groups[_column_index]);
		var _match_id = ((current_row * simulation_count + current_simulation_index) * enemy_test_unit_count) + _column_index;
		var _match_has_projectile = false;
		var _projectile_count = instance_number(o_projectile);

		for (var _projectile_index = 0; _projectile_index < _projectile_count; ++_projectile_index)
		{
			var _projectile = instance_find(o_projectile, _projectile_index);

			if (instance_exists(_projectile)
				&& variable_instance_exists(_projectile, "balance_test_match_id")
				&& _projectile.balance_test_match_id == _match_id)
			{
				_match_has_projectile = true;
				break;
			}
		}

		var _side_was_defeated = _friendly_equivalent <= 0 || _enemy_equivalent <= 0;
		var _match_is_finished = (_side_was_defeated && !_match_has_projectile) || _row_timed_out;

		if (!_match_is_finished)
		{
			continue;
		}

		var _run_score = balance_test_run_score_get(
			_friendly_equivalent,
			_enemy_equivalent,
			friendly_test_units[current_row].count,
			enemy_test_units[_column_index].count
		);

		test_score_totals[current_row][_column_index] += _run_score;

		if (current_simulation_index + 1 >= simulation_count)
		{
			var _average_score = test_score_totals[current_row][_column_index] / simulation_count;
			test_results[current_row][_column_index] = balance_test_result_text_get(_average_score);
		}
		else
		{
			test_results[current_row][_column_index] = string(current_simulation_index + 1)
				+ "/" + string(simulation_count);
		}

		active_match_finished[_column_index] = true;
		completed_match_count++;
		_finished_match_count++;
		balance_test_group_freeze(active_friendly_groups[_column_index]);
		balance_test_group_freeze(active_enemy_groups[_column_index]);
	}

	if (_finished_match_count >= enemy_test_unit_count)
	{
		break;
	}
}

if (_finished_match_count < enemy_test_unit_count)
{
	exit;
}

// Remove transient effects before starting the next row of isolated arenas.
for (var _column_index = 0; _column_index < enemy_test_unit_count; ++_column_index)
{
	balance_test_group_destroy(active_friendly_groups[_column_index]);
	balance_test_group_destroy(active_enemy_groups[_column_index]);
}

with (o_projectile)
{
	instance_destroy();
}

with (o_damage_popup)
{
	instance_destroy();
}

with (o_particle_smoke)
{
	instance_destroy();
}

with (o_particle_explosion)
{
	instance_destroy();
}

row_is_running = false;

if (current_simulation_index + 1 < simulation_count)
{
	current_simulation_index++;
	row_start_timer = max(1, BALANCE_TEST_ROW_START_DELAY * room_speed);
	exit;
}

current_simulation_index = 0;
current_row++;

if (current_row >= friendly_test_unit_count)
{
	test_is_complete = true;
	table_is_visible = true;
	status_message = "Complete. Press C to copy TSV, R to restart, Esc to return.";
}
else
{
	row_start_timer = max(1, BALANCE_TEST_ROW_START_DELAY * room_speed);
}
