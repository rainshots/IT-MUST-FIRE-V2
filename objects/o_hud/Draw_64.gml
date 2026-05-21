// Draw global resources in the top-left HUD.
if (!variable_global_exists("resources"))
{
	exit;
}

draw_set_halign(fa_left);
draw_set_valign(fa_middle);

var _resource_count = array_length(resource_order);

for (var _resource_index = 0; _resource_index < _resource_count; ++_resource_index)
{
	var _resource = resource_order[_resource_index];
	var _draw_x = hud_margin_x + ((resource_item_width + resource_item_gap) * _resource_index);
	var _draw_y = hud_margin_y;
	var _value = global.resources[_resource];
	var _label = resource_names[_resource] + ": " + string(_value);
	var _icon_x = _draw_x + resource_text_padding;
	var _icon_y = _draw_y + (resource_item_height * 0.5);
	var _text_x = _draw_x + (resource_text_padding * 1.8);
	var _text_y = _icon_y;

	draw_set_alpha(0.72);
	draw_set_color(COLOR_HUD_BACKGROUND);
	draw_rectangle(_draw_x, _draw_y, _draw_x + resource_item_width, _draw_y + resource_item_height, false);

	draw_set_alpha(1);
	draw_set_color(resource_colors[_resource]);
	draw_circle(_icon_x, _icon_y, resource_icon_radius, false);

	draw_set_color(COLOR_HUD_TEXT);
	draw_text(_text_x, _text_y, _label);
}

// Draw derived ground corruption after regular resources.
var _corruption_index = _resource_count;
var _corruption_x = hud_margin_x + ((resource_item_width + resource_item_gap) * _corruption_index);
var _corruption_y = hud_margin_y;
var _corruption_value = string_format(corruption_display_value, 0, corruption_display_decimals);
var _corruption_label = corruption_display_name + ": " + _corruption_value;
var _corruption_icon_x = _corruption_x + resource_text_padding;
var _corruption_icon_y = _corruption_y + (resource_item_height * 0.5);
var _corruption_text_x = _corruption_x + (resource_text_padding * 1.8);
var _corruption_text_y = _corruption_icon_y;

draw_set_alpha(0.72);
draw_set_color(COLOR_HUD_BACKGROUND);
draw_rectangle(_corruption_x, _corruption_y, _corruption_x + resource_item_width, _corruption_y + resource_item_height, false);

draw_set_alpha(1);
draw_set_color(corruption_display_color);
draw_circle(_corruption_icon_x, _corruption_icon_y, resource_icon_radius, false);

draw_set_color(COLOR_HUD_TEXT);
draw_text(_corruption_text_x, _corruption_text_y, _corruption_label);

// Restore default draw state.
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);
