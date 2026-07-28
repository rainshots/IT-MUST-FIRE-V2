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
var _daily_limit_reached = !day_event_building_construction_can_start();

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

draw_set_color(_daily_limit_reached ? COLOR_STATUS_NEGATIVE_RED : COLOR_HUD_PROJECTILE_DESCRIPTION);
draw_text(
	_panel_x + (structure_choice_window_width * 0.5),
	_panel_y + 68,
	_daily_limit_reached ? "MAX 1 BUILDING PER DAY" : "Choose one captured structure"
);

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
	draw_set_color(_daily_limit_reached ? COLOR_PROJECTILE_DAMAGE : (_is_hovered ? COLOR_PROJECTILE_SUMMON : c_white));
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
			_daily_limit_reached ? 0.35 : 1
		);
	}

	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_set_alpha(_can_pay_choice && !_daily_limit_reached ? 1 : 0.5);
	draw_set_color(_daily_limit_reached ? COLOR_PROJECTILE_DAMAGE : COLOR_HUD_TEXT);
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

	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_set_color(COLOR_HUD_TEXT);
	draw_text(
		_tile_x + (structure_choice_tile_width * 0.5),
		_tile_y + structure_choice_tile_height - 22,
		"2 Cultists"
	);
}

// Restore default draw state.
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);
