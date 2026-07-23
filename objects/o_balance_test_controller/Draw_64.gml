// Draw the complete result matrix in GUI space.
var _gui_width = display_get_gui_width();
var _margin = 18;
var _label_width = 210;
var _column_width = (_gui_width - (_margin * 2) - _label_width) / enemy_test_unit_count;
var _header_y = 92;
var _header_height = 54;
var _row_height = 54;
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

		if (string_pos("+", _result) == 1)
		{
			draw_set_color(COLOR_BALANCE_TEST_PLAYER_WIN);
		}
		else if (string_pos("-", _result) == 1)
		{
			draw_set_color(COLOR_BALANCE_TEST_ENEMY_WIN);
		}
		else
		{
			draw_set_color(COLOR_BALANCE_TEST_NEUTRAL);
		}

		draw_text(_column_x + 7, _row_y + 18, _result);
	}
}

draw_set_color(COLOR_BALANCE_TEST_MUTED_TEXT);
draw_text(_margin, _header_y + _header_height + (friendly_test_unit_count * _row_height) + 18,
	"Result = average remaining-army HP advantage across 3 fixed-seed simulations.");
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
