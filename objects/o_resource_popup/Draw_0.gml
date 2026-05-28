// Calculate popup bounds from current text size.
var _text_width = string_width(popup_text);
var _text_height = string_height(popup_text);
var _has_icon = sprite_exists(popup_icon);
var _content_width = _text_width;
var _content_height = _text_height;

if (_has_icon)
{
	_content_width += icon_gap + icon_size;
	_content_height = max(_content_height, icon_size);
}

var _popup_width = _content_width + (background_padding_x * 2);
var _popup_height = _content_height + (background_padding_y * 2);
var _popup_left = x - (_popup_width * 0.5);
var _popup_top = y + text_offset_y - (_popup_height * 0.5);
var _popup_right = _popup_left + _popup_width;
var _popup_bottom = _popup_top + _popup_height;
var _content_left = x - (_content_width * 0.5);
var _content_y = y + text_offset_y;

// Draw translucent popup plate.
draw_set_alpha(background_alpha * current_alpha);
draw_set_color(background_color);
draw_roundrect(_popup_left, _popup_top, _popup_right, _popup_bottom, false);

// Draw resource gain text.
draw_set_alpha(current_alpha);
draw_set_color(popup_color);
draw_set_halign(fa_left);
draw_set_valign(fa_middle);
draw_text(_content_left, _content_y, popup_text);

if (_has_icon)
{
	draw_sprite_stretched_ext(
		popup_icon,
		0,
		_content_left + _text_width + icon_gap,
		_content_y - (icon_size * 0.5),
		icon_size,
		icon_size,
		c_white,
		current_alpha
	);
}

// Restore default draw state.
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);
