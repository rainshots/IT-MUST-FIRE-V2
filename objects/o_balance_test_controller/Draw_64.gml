if (variable_global_exists("blood_moon_reward_popup_active")
	&& global.blood_moon_reward_popup_active)
{
	exit;
}

// Draw the optional support selector before any simulations begin.
if (!configuration_is_confirmed)
{
	var _gui_width = display_get_gui_width();
	var _gui_height = display_get_gui_height();
	var _panel_x = (_gui_width - configuration_panel_width) * 0.5;
	var _panel_y = (_gui_height - configuration_panel_height) * 0.5;
	var _mouse_x = device_mouse_x_to_gui(0);
	var _mouse_y = device_mouse_y_to_gui(0);

	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_alpha(0.96);
	draw_set_color(COLOR_BALANCE_TEST_BACKGROUND);
	draw_rectangle(0, 0, _gui_width, _gui_height, false);
	draw_set_alpha(1);
	draw_set_color(COLOR_BALANCE_TEST_HEADER);
	draw_rectangle(
		_panel_x,
		_panel_y,
		_panel_x + configuration_panel_width,
		_panel_y + configuration_panel_height,
		false
	);
	draw_set_color(c_white);
	draw_text(_panel_x + configuration_column_margin, _panel_y + 24, "BALANCE TEST SETUP");
	draw_set_color(COLOR_BALANCE_TEST_MUTED_TEXT);
	draw_text(_panel_x + configuration_column_margin, _panel_y + 76, "REGULAR UNIT TESTS");
	draw_text(
		_panel_x + configuration_column_margin + configuration_column_width + configuration_column_gap,
		_panel_y + 76,
		"ARCHDEMON TESTS (+ Warrior + Archer)"
	);
	draw_text(
		_panel_x + configuration_column_margin
			+ ((configuration_column_width + configuration_column_gap) * 2),
		_panel_y + 76,
		"OPTIONAL SUPPORT FOR EVERY FIGHT"
	);

	for (var _regular_option_index = 0; _regular_option_index < array_length(regular_test_configs); ++_regular_option_index)
	{
		var _regular_option = regular_test_configs[_regular_option_index];
		var _regular_option_rect = balance_test_regular_option_rect_get(_regular_option_index);
		var _regular_is_hovered = point_in_rectangle(
			_mouse_x,
			_mouse_y,
			_regular_option_rect.x,
			_regular_option_rect.y,
			_regular_option_rect.x + _regular_option_rect.width,
			_regular_option_rect.y + _regular_option_rect.height
		);

		draw_set_color(_regular_is_hovered ? COLOR_BALANCE_TEST_ROW_ALTERNATE : COLOR_BALANCE_TEST_ROW);
		draw_rectangle(
			_regular_option_rect.x,
			_regular_option_rect.y,
			_regular_option_rect.x + _regular_option_rect.width,
			_regular_option_rect.y + _regular_option_rect.height,
			false
		);
		draw_set_color(_regular_option.enabled ? COLOR_BALANCE_TEST_PLAYER_WIN : COLOR_BALANCE_TEST_MUTED_TEXT);
		draw_text(_regular_option_rect.x + 16, _regular_option_rect.y + 10, _regular_option.enabled ? "[X]" : "[ ]");
		draw_set_color(c_white);
		draw_text(_regular_option_rect.x + 58, _regular_option_rect.y + 10, _regular_option.label);
	}

	for (var _option_index = 0; _option_index < array_length(demon_test_configs); ++_option_index)
	{
		var _option = demon_test_configs[_option_index];
		var _option_rect = balance_test_demon_option_rect_get(_option_index);
		var _is_hovered = point_in_rectangle(
			_mouse_x,
			_mouse_y,
			_option_rect.x,
			_option_rect.y,
			_option_rect.x + _option_rect.width,
			_option_rect.y + _option_rect.height
		);

		draw_set_color(_is_hovered ? COLOR_BALANCE_TEST_ROW_ALTERNATE : COLOR_BALANCE_TEST_ROW);
		draw_rectangle(
			_option_rect.x,
			_option_rect.y,
			_option_rect.x + _option_rect.width,
			_option_rect.y + _option_rect.height,
			false
		);
		draw_set_color(_option.enabled ? COLOR_BALANCE_TEST_PLAYER_WIN : COLOR_BALANCE_TEST_MUTED_TEXT);
		draw_text(_option_rect.x + 16, _option_rect.y + 10, _option.enabled ? "[X]" : "[ ]");
		draw_set_color(c_white);
		draw_text(_option_rect.x + 58, _option_rect.y + 10, _option.label);
	}

	for (var _support_option_index = 0; _support_option_index < array_length(optional_test_configs); ++_support_option_index)
	{
		var _support_option = optional_test_configs[_support_option_index];
		var _support_option_rect = balance_test_configuration_option_rect_get(_support_option_index);
		var _support_is_hovered = point_in_rectangle(
			_mouse_x,
			_mouse_y,
			_support_option_rect.x,
			_support_option_rect.y,
			_support_option_rect.x + _support_option_rect.width,
			_support_option_rect.y + _support_option_rect.height
		);

		draw_set_color(_support_is_hovered ? COLOR_BALANCE_TEST_ROW_ALTERNATE : COLOR_BALANCE_TEST_ROW);
		draw_rectangle(
			_support_option_rect.x,
			_support_option_rect.y,
			_support_option_rect.x + _support_option_rect.width,
			_support_option_rect.y + _support_option_rect.height,
			false
		);
		draw_set_color(_support_option.enabled ? COLOR_BALANCE_TEST_PLAYER_WIN : COLOR_BALANCE_TEST_MUTED_TEXT);
		draw_text(_support_option_rect.x + 16, _support_option_rect.y + 10, _support_option.enabled ? "[X]" : "[ ]");
		draw_set_color(c_white);
		draw_text(_support_option_rect.x + 58, _support_option_rect.y + 10, _support_option.label);
	}

	var _start_rect = balance_test_configuration_start_rect_get();
	var _start_is_hovered = point_in_rectangle(
		_mouse_x,
		_mouse_y,
		_start_rect.x,
		_start_rect.y,
		_start_rect.x + _start_rect.width,
		_start_rect.y + _start_rect.height
	);

	draw_set_color(_start_is_hovered ? COLOR_BALANCE_TEST_PLAYER_WIN : COLOR_BALANCE_TEST_ROW_ALTERNATE);
	draw_rectangle(
		_start_rect.x,
		_start_rect.y,
		_start_rect.x + _start_rect.width,
		_start_rect.y + _start_rect.height,
		false
	);
	draw_set_color(c_white);
	draw_set_halign(fa_center);
	draw_text(_start_rect.x + (_start_rect.width * 0.5), _start_rect.y + 17, "START TESTS");
	draw_set_halign(fa_left);
	draw_set_color(COLOR_BALANCE_TEST_MUTED_TEXT);
	draw_text(_panel_x + configuration_column_margin, _panel_y + 570, status_message);
	draw_text(
		_panel_x + configuration_column_margin,
		_panel_y + configuration_panel_height - 20,
		"Enter/Space: start    Esc: return"
	);

	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
	draw_set_alpha(1);
	exit;
}

// Draw the complete result matrix in GUI space.
var _gui_width = display_get_gui_width();
var _margin = 18;
var _label_width = 210;
var _column_width = (_gui_width - (_margin * 2) - _label_width) / enemy_test_unit_count;
var _header_y = 92;
var _header_height = 54;
var _table_footer_height = 78;
var _available_rows_height = display_get_gui_height()
	- _header_y
	- _header_height
	- _table_footer_height;
var _row_height = min(54, floor(_available_rows_height / max(1, friendly_test_unit_count)));
var _table_width = _label_width + (_column_width * enemy_test_unit_count);

draw_set_halign(fa_left);
draw_set_valign(fa_top);

// Keep only a compact control bar visible while watching a fight.
if (!table_is_visible && !test_is_complete)
{
	draw_set_alpha(0.88);
	draw_set_color(COLOR_BALANCE_TEST_BACKGROUND);
	draw_rectangle(12, 12, _gui_width - 12, 84, false);
	draw_set_alpha(1);
	draw_set_color(c_white);
	draw_text(26, 24, status_message + "  |  Arena " + string(selected_arena_index + 1)
		+ "  |  Speed " + string(simulation_speed_multiplier) + "x");
	draw_text(26, 50, "1-5: watch arena    F: 1x/" + string(BALANCE_TEST_SIMULATION_SPEED)
		+ "x    Tab: table    C: copy    R: restart    Esc: return");
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
	draw_set_alpha(1);
	exit;
}

draw_set_alpha(0.96);
draw_set_color(COLOR_BALANCE_TEST_BACKGROUND);
draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
draw_set_alpha(1);
draw_set_color(c_white);
draw_text(_margin, 16, "AUTOMATED BALANCE TEST");
draw_text(_margin, 42, status_message);
draw_text(_margin, 66, "Progress: " + string(completed_match_count) + " / " + string(total_match_count)
	+ "    Speed: " + string(simulation_speed_multiplier) + "x");

// Enemy headers include the number of units used in every matchup.
draw_set_color(COLOR_BALANCE_TEST_HEADER);
draw_rectangle(_margin, _header_y, _margin + _table_width, _header_y + _header_height, false);
draw_set_color(c_white);
draw_text(_margin + 8, _header_y + 8, "PLAYER UNITS");

for (var _column_index = 0; _column_index < enemy_test_unit_count; ++_column_index)
{
	var _enemy_config = enemy_test_units[_column_index];
	var _column_x = _margin + _label_width + (_column_index * _column_width);

	draw_text(_column_x + 7, _header_y + 7, string(_enemy_config.count));
	draw_text(_column_x + 7, _header_y + 29, _enemy_config.name);
}

// Rows show live results while each matchup finishes.
for (var _row_index = 0; _row_index < friendly_test_unit_count; ++_row_index)
{
	var _friendly_config = friendly_test_units[_row_index];
	var _row_y = _header_y + _header_height + (_row_index * _row_height);
	var _row_color = COLOR_BALANCE_TEST_ROW;

	if (_row_index mod 2 == 1)
	{
		_row_color = COLOR_BALANCE_TEST_ROW_ALTERNATE;
	}

	draw_set_color(_row_color);
	draw_rectangle(_margin, _row_y, _margin + _table_width, _row_y + _row_height, false);
	draw_set_color(c_white);
	draw_text(_margin + 8, _row_y + 7, string(_friendly_config.count) + "  " + _friendly_config.name);

	for (var _column_index = 0; _column_index < enemy_test_unit_count; ++_column_index)
	{
		var _result = test_results[_row_index][_column_index];
		var _column_x = _margin + _label_width + (_column_index * _column_width);

		if (_friendly_config.test_type == "unit" && string_pos("+", _result) == 1)
		{
			draw_set_color(COLOR_BALANCE_TEST_PLAYER_WIN);
		}
		else if (_friendly_config.test_type == "unit" && string_pos("-", _result) == 1)
		{
			draw_set_color(COLOR_BALANCE_TEST_ENEMY_WIN);
		}
		else if (_friendly_config.test_type == "archdemon" && string_pos("%", _result) > 0)
		{
			var _hp_percent = real(string_replace_all(_result, "%", ""));
			draw_set_color(_hp_percent > 0 ? COLOR_BALANCE_TEST_PLAYER_WIN : COLOR_BALANCE_TEST_ENEMY_WIN);
		}
		else
		{
			draw_set_color(COLOR_BALANCE_TEST_NEUTRAL);
		}

		draw_text(_column_x + 7, _row_y + ((_row_height - 18) * 0.5), _result);
	}
}

draw_set_color(COLOR_BALANCE_TEST_MUTED_TEXT);
draw_text(_margin, _header_y + _header_height + (friendly_test_unit_count * _row_height) + 18,
	"Regular rows = average remaining-army HP advantage. Archdemon rows = average Archdemon HP remaining.");
draw_text(_margin, _header_y + _header_height + (friendly_test_unit_count * _row_height) + 42,
	"1-5: watch arena    F: 1x/" + string(BALANCE_TEST_SIMULATION_SPEED)
		+ "x    Tab: hide table    C: copy TSV    R: restart    Esc: return");

if (copy_feedback_timer > 0)
{
	draw_set_color(COLOR_BALANCE_TEST_PLAYER_WIN);
	draw_text(_gui_width - 190, 18, "TSV copied");
}

// Restore default draw state.
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);
