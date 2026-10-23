// Measure and draw with identical wrapping and font settings.
var _layout = hint_layout_get();
var _old_font = draw_get_font();
draw_set_font(font_exists(global.ui_font) ? global.ui_font : -1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_alpha(hint_background_alpha);
draw_set_color(COLOR_HUD_BACKGROUND);
draw_rectangle(_layout.left, _layout.top, _layout.left + hint_width, _layout.top + _layout.height, false);
draw_set_alpha(hint_border_alpha);
draw_set_color(COLOR_CORRUPTION_MAX);
draw_rectangle(_layout.left, _layout.top, _layout.left + hint_width, _layout.top + _layout.height, true);

var _text_x = _layout.left + hint_padding_x;
var _text_y = _layout.top + hint_padding_y;
draw_set_alpha(hint_text_alpha);
draw_text_ext(_text_x, _text_y, hint_title, _layout.spacing, _layout.wrap);
_text_y += _layout.title_height + hint_title_gap;
draw_set_color(COLOR_HUD_TEXT);
for (var _i = 0; _i < array_length(hint_lines); ++_i)
{
	draw_text_ext(_text_x, _text_y, hint_lines[_i], _layout.spacing, _layout.wrap);
	_text_y += _layout.body_heights[_i];
}

// Cross button occupies the reserved column, clear of all wrapped text.
var _left = _layout.close_left;
var _top = _layout.close_top;
draw_rectangle(_left, _top, _left + hint_close_size, _top + hint_close_size, true);
draw_line(_left + hint_close_inset, _top + hint_close_inset,
	_left + hint_close_size - hint_close_inset, _top + hint_close_size - hint_close_inset);
draw_line(_left + hint_close_size - hint_close_inset, _top + hint_close_inset,
	_left + hint_close_inset, _top + hint_close_size - hint_close_inset);
draw_set_font(_old_font);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);
