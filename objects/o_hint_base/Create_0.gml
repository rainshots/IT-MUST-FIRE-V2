// Hint text teaches why Taint matters near the starting base.
hint_title = "TAINT IS YOUR TERRITORY";
hint_lines = [
	"Taint spreads every 2 days.",
	"Your troops move faster on tainted ground and enemies move slower.",
];
hint_width = 430;
hint_padding_x = 14;
hint_padding_y = 10;
hint_line_height = 18;
hint_title_gap = 8;
hint_background_alpha = 0.82;
hint_border_alpha = 0.75;
hint_text_alpha = 0.95;

// Reserve a separate right-hand column for the close button.
hint_close_size = 24;
hint_close_gap = 10;
hint_close_inset = 6;
hint_layout_get = function()
{
	var _old_font = draw_get_font();
	draw_set_font(font_exists(global.ui_font) ? global.ui_font : -1);
	var _wrap = max(1, hint_width - hint_padding_x * 2 - hint_close_size - hint_close_gap);
	var _spacing = max(hint_line_height, string_height("Ag"));
	var _title_height = string_height_ext(hint_title, _spacing, _wrap);
	var _body_heights = [];
	var _height = _title_height + hint_title_gap;
	for (var _i = 0; _i < array_length(hint_lines); ++_i)
	{
		var _line_height = string_height_ext(hint_lines[_i], _spacing, _wrap);
		array_push(_body_heights, _line_height);
		_height += _line_height;
	}
	_height = max(_height, hint_close_size) + hint_padding_y * 2;
	var _left = x - hint_width * 0.5;
	var _top = y - _height * 0.5;
	draw_set_font(_old_font);
	return {left: _left, top: _top, height: _height, wrap: _wrap, spacing: _spacing,
		title_height: _title_height, body_heights: _body_heights,
		close_left: _left + hint_width - hint_padding_x - hint_close_size,
		close_top: y - hint_close_size * 0.5};
};
