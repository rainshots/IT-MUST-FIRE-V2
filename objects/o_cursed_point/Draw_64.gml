if (!structure_selection_open
	|| global.focus_window != FOCUS_WINDOW.CURSED_POINT_STRUCTURE_SELECTION
	|| !variable_global_exists("cursed_point_structure_selection_source")
	|| global.cursed_point_structure_selection_source != id)
{
	if (!is_captured && map_object_is_hovered() && !global.pause)
	{
		var _camera_controller = instance_find(o_camera_controller, 0);
		var _camera_x = camera_get_view_x(_camera_controller.camera_id);
		var _camera_y = camera_get_view_y(_camera_controller.camera_id);
		var _camera_width = camera_get_view_width(_camera_controller.camera_id);
		var _camera_height = camera_get_view_height(_camera_controller.camera_id);
		var _tooltip_gui_size = cursed_point_gui_size_get();
		var _tooltip_gui_width = _tooltip_gui_size[0];
		var _tooltip_gui_height = _tooltip_gui_size[1];
		var _object_gui_x = ((x - _camera_x) / _camera_width) * _tooltip_gui_width;
		var _object_gui_y = ((y - _camera_y) / _camera_height) * _tooltip_gui_height;
		var _line_count = array_length(tooltip_lines);
		var _tooltip_height = (tooltip_padding * 2) + (tooltip_line_height * _line_count);
		var _tooltip_x = clamp(_object_gui_x - (tooltip_width * 0.5), tooltip_padding, _tooltip_gui_width - tooltip_width - tooltip_padding);
		var _tooltip_y = max(tooltip_padding, _object_gui_y - tooltip_offset_y - _tooltip_height);

		draw_set_alpha(0.86);
		draw_set_color(COLOR_HUD_BACKGROUND);
		draw_rectangle(_tooltip_x, _tooltip_y, _tooltip_x + tooltip_width, _tooltip_y + _tooltip_height, false);

		draw_set_alpha(1);
		draw_set_color(COLOR_HUD_TEXT);
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);

		for (var _line_index = 0; _line_index < _line_count; ++_line_index)
		{
			var _line_x = _tooltip_x + tooltip_padding;
			var _line_y = _tooltip_y + tooltip_padding + (tooltip_line_height * _line_index);

			draw_text(_line_x, _line_y, tooltip_lines[_line_index]);
		}

		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		draw_set_color(c_white);
		draw_set_alpha(1);
	}

	exit;
}

// Draw the blocking structure choice modal.
var _gui_size = cursed_point_gui_size_get();
var _gui_width = _gui_size[0];
var _gui_height = _gui_size[1];
var _panel_x = (_gui_width - structure_choice_window_width) * 0.5;
var _panel_y = (_gui_height - structure_choice_window_height) * 0.5;
var _mouse_x = device_mouse_x_to_gui(0);
var _mouse_y = device_mouse_y_to_gui(0);
var _hovered_choice = cursed_point_structure_choice_hover_index_get(_mouse_x, _mouse_y);

draw_set_alpha(0.55);
draw_set_color(c_black);
draw_rectangle(0, 0, _gui_width, _gui_height, false);

draw_set_alpha(1);
draw_set_color(COLOR_HUD_BACKGROUND);
draw_rectangle(_panel_x, _panel_y, _panel_x + structure_choice_window_width, _panel_y + structure_choice_window_height, false);
draw_set_color(c_white);
draw_rectangle(_panel_x, _panel_y, _panel_x + structure_choice_window_width, _panel_y + structure_choice_window_height, true);

draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(COLOR_HUD_TEXT);
draw_text(_panel_x + (structure_choice_window_width * 0.5), _panel_y + 38, "Summon Structure");

draw_set_color(COLOR_HUD_PROJECTILE_DESCRIPTION);
draw_text(_panel_x + (structure_choice_window_width * 0.5), _panel_y + 68, "Choose one captured structure");

for (var _choice_index = 0; _choice_index < array_length(structure_choice_options); ++_choice_index)
{
	var _choice = structure_choice_options[_choice_index];
	var _choice_rect = cursed_point_structure_choice_rect_get(_choice_index);
	var _tile_x = _choice_rect[0];
	var _tile_y = _choice_rect[1];
	var _is_hovered = _choice_index == _hovered_choice;
	var _can_pay_choice = cursed_point_structure_choice_can_pay(_choice);
	var _sprite = object_get_sprite(_choice.building_object);

	draw_set_alpha(0.82);
	draw_set_color(c_black);
	draw_rectangle(_tile_x, _tile_y, _tile_x + structure_choice_tile_width, _tile_y + structure_choice_tile_height, false);

	draw_set_alpha(1);
	draw_set_color(_is_hovered ? COLOR_PROJECTILE_SUMMON : c_white);
	draw_rectangle(_tile_x, _tile_y, _tile_x + structure_choice_tile_width, _tile_y + structure_choice_tile_height, true);

	if (_sprite != -1 && sprite_exists(_sprite))
	{
		var _sprite_width = sprite_get_width(_sprite);
		var _sprite_height = sprite_get_height(_sprite);
		var _sprite_scale = structure_choice_sprite_size / max(_sprite_width, _sprite_height);
		var _sprite_draw_width = _sprite_width * _sprite_scale;
		var _sprite_draw_height = _sprite_height * _sprite_scale;
		var _sprite_x = _tile_x + (structure_choice_tile_width * 0.5);
		var _sprite_y = _tile_y + 58;

		draw_sprite_stretched_ext(
			_sprite,
			0,
			_sprite_x - (_sprite_draw_width * 0.5),
			_sprite_y - (_sprite_draw_height * 0.5),
			_sprite_draw_width,
			_sprite_draw_height,
			c_white,
			1
		);
	}

	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_set_alpha(_can_pay_choice ? 1 : 0.5);
	draw_set_color(COLOR_HUD_TEXT);
	draw_text(_tile_x + (structure_choice_tile_width * 0.5), _tile_y + 124, _choice.building_name);
	draw_set_alpha(1);

	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(COLOR_HUD_PROJECTILE_DESCRIPTION);
	draw_text_ext(
		_tile_x + 16,
		_tile_y + 148,
		_choice.building_description,
		16,
		structure_choice_tile_width - 32
	);

	if (variable_struct_exists(_choice, "construction_costs"))
	{
		var _costs = _choice.construction_costs;
		var _cost_count = array_length(_costs);
		var _cost_icon_size = 18;
		var _cost_gap = 8;
		var _cost_total_width = 0;

		for (var _cost_measure_index = 0; _cost_measure_index < _cost_count; ++_cost_measure_index)
		{
			var _measure_cost = _costs[_cost_measure_index];
			_cost_total_width += _cost_icon_size + 4 + string_width(string(_measure_cost.cost));

			if (_cost_measure_index < _cost_count - 1)
			{
				_cost_total_width += _cost_gap;
			}
		}

		var _cost_draw_x = _tile_x + ((structure_choice_tile_width - _cost_total_width) * 0.5);
		var _cost_y = _tile_y + structure_choice_tile_height - 22;

		draw_set_halign(fa_left);
		draw_set_valign(fa_middle);

		for (var _cost_index = 0; _cost_index < _cost_count; ++_cost_index)
		{
			var _cost_data = _costs[_cost_index];
			var _cost_icon = cursed_point_resource_icon_get(_cost_data.resource);
			var _cost_color = cursed_point_resource_color_get(_cost_data.resource);
			var _cost_text = string(_cost_data.cost);
			var _has_resource = global.resources[_cost_data.resource] >= _cost_data.cost;
			var _cost_item_width = _cost_icon_size + 4 + string_width(_cost_text);

			if (!_has_resource)
			{
				draw_set_alpha(0.6);
				draw_set_color(COLOR_STATUS_NEGATIVE_RED);
				draw_rectangle(
					_cost_draw_x - 4,
					_cost_y - (_cost_icon_size * 0.5) - 3,
					_cost_draw_x + _cost_item_width + 4,
					_cost_y + (_cost_icon_size * 0.5) + 3,
					false
				);
				draw_set_alpha(1);
			}

			if (sprite_exists(_cost_icon))
			{
				draw_sprite_stretched_ext(
					_cost_icon,
					0,
					_cost_draw_x,
					_cost_y - (_cost_icon_size * 0.5),
					_cost_icon_size,
					_cost_icon_size,
					c_white,
					_can_pay_choice ? 1 : 0.55
				);
			}

			_cost_draw_x += _cost_icon_size + 4;
			draw_set_color(_has_resource ? _cost_color : COLOR_HUD_TEXT);
			draw_text(_cost_draw_x, _cost_y, _cost_text);
			_cost_draw_x += string_width(_cost_text) + _cost_gap;
		}
	}
}

// Restore default draw state.
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);
