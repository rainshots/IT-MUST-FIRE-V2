/// @description Draws a wrapped hover description above the Shop; controller context.
function shop_tooltip_draw()
{
	if (instance_exists(shop_preview) || global.focus_window != FOCUS_WINDOW.NOONE) return;
	var _mouse_x = device_mouse_x_to_gui(0);
	var _mouse_y = device_mouse_y_to_gui(0);
	var _count = array_length(shop_options);
	for (var _i = -1; _i < _count; ++_i)
	{
		var _button = shop_offer_rect(_i);
		if (!point_in_rectangle(_mouse_x, _mouse_y, _button.x, _button.y,
			_button.x + _button.width, _button.y + _button.height)) continue;
		var _text = "Refresh\nReplaces all five Shop offers for " + string(shop_refresh_cost) + " Mana.";
		if (_i >= 0)
		{
			var _offer = shop_options[_i];
			if (!is_struct(_offer)) return;
			if (!variable_struct_exists(_offer, "description")) return;
			_text = _offer.name + "\n" + _offer.description;
		}
		var _scale = _button.scale;
		var _padding = BALANCE_SHOP_TOOLTIP_PADDING * _scale;
		var _width = min(BALANCE_SHOP_TOOLTIP_WIDTH * _scale, display_get_gui_width() - _padding * 2);
		var _text_scale = BALANCE_SHOP_TOOLTIP_TEXT_SCALE * _scale;
		var _wrap_width = (_width - _padding * 2) / _text_scale;
		var _height = string_height_ext(_text, -1, _wrap_width) * _text_scale + _padding * 2;
		var _left = clamp(_button.x + (_button.width - _width) * 0.5, _padding, display_get_gui_width() - _width - _padding);
		var _top = max(_padding, _button.y - BALANCE_SHOP_TOOLTIP_GAP * _scale - _height);
		draw_set_alpha(1);
		draw_set_color(COLOR_HUD_BACKGROUND);
		draw_rectangle(_left, _top, _left + _width, _top + _height, false);
		draw_set_color(COLOR_HUD_TEXT);
		draw_rectangle(_left, _top, _left + _width, _top + _height, true);
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		draw_text_ext_transformed(_left + _padding, _top + _padding, _text, -1, _wrap_width, _text_scale, _text_scale, 0);
		break;
	}
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
	draw_set_alpha(1);
}
