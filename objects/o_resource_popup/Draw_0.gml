// Calculate popup bounds from current text size.
var _text_width = string_width(popup_text);
var _text_height = string_height(popup_text);
var _popup_width = _text_width + (background_padding_x * 2);
var _popup_height = _text_height + (background_padding_y * 2);
var _popup_left = x - (_popup_width * 0.5);
var _popup_top = y + text_offset_y - (_popup_height * 0.5);
var _popup_right = _popup_left + _popup_width;
var _popup_bottom = _popup_top + _popup_height;

// Draw translucent popup plate.
draw_set_alpha(background_alpha * current_alpha);
draw_set_color(background_color);
draw_roundrect(_popup_left, _popup_top, _popup_right, _popup_bottom, false);

// Draw resource gain text.
draw_set_alpha(current_alpha);
draw_set_color(popup_color);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text(x, y + text_offset_y, popup_text);

// Restore default draw state.
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);
