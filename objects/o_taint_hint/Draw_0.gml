// Draw a readable world-space hint near the base.
var _line_count = array_length(hint_lines);
var _box_width = hint_width;
var _box_height = (hint_padding_y * 2)
	+ string_height(hint_title)
	+ hint_title_gap
	+ (_line_count * hint_line_height);
var _box_left = x - (_box_width * 0.5);
var _box_top = y - (_box_height * 0.5);
var _text_x = _box_left + hint_padding_x;
var _text_y = _box_top + hint_padding_y;

draw_set_alpha(hint_background_alpha);
draw_set_color(COLOR_HUD_BACKGROUND);
draw_rectangle(_box_left, _box_top, _box_left + _box_width, _box_top + _box_height, false);

draw_set_alpha(hint_border_alpha);
draw_set_color(COLOR_CORRUPTION_MAX);
draw_rectangle(_box_left, _box_top, _box_left + _box_width, _box_top + _box_height, true);

draw_set_alpha(hint_text_alpha);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(COLOR_CORRUPTION_MAX);
draw_text(_text_x, _text_y, hint_title);

draw_set_color(COLOR_HUD_TEXT);
_text_y += string_height(hint_title) + hint_title_gap;

for (var _line_index = 0; _line_index < _line_count; ++_line_index)
{
	draw_text(_text_x, _text_y + (_line_index * hint_line_height), hint_lines[_line_index]);
}

// Restore default draw state.
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);
