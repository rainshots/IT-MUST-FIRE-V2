// Draw projectile reaction tooltip while hovering this map object.
if (!map_object_is_hovered())
{
	exit;
}

// Convert object world position back to GUI coordinates for the tooltip.
var _camera_controller = instance_find(o_camera_controller, 0);
var _camera_x = camera_get_view_x(_camera_controller.camera_id);
var _camera_y = camera_get_view_y(_camera_controller.camera_id);
var _camera_width = camera_get_view_width(_camera_controller.camera_id);
var _camera_height = camera_get_view_height(_camera_controller.camera_id);
var _gui_width = _camera_controller.base_view_width;
var _gui_height = _camera_controller.base_view_height;
var _object_gui_x = ((x - _camera_x) / _camera_width) * _gui_width;
var _object_gui_y = ((y - _camera_y) / _camera_height) * _gui_height;

if (object_index == o_holy_tower)
{
	var _tower_tooltip_width = 260;
	var _tower_tooltip_height = 170;
	var _tower_tooltip_padding = 14;
	var _tower_tooltip_x = clamp(_object_gui_x - (_tower_tooltip_width * 0.5), _tower_tooltip_padding, _gui_width - _tower_tooltip_width - _tower_tooltip_padding);
	var _tower_tooltip_y = max(_tower_tooltip_padding, _object_gui_y - tooltip_offset_y - _tower_tooltip_height);
	var _tower_name = "Holy Tower";
	var _tower_attack_speed = room_speed / max(reload_time, 1);
	var _tower_hp_text = "HP: " + string_format(hp, 0, 1) + " / " + string_format(max_hp, 0, 1);

	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_alpha(0.96);
	draw_set_color(COLOR_HUD_BACKGROUND);
	draw_rectangle(_tower_tooltip_x, _tower_tooltip_y, _tower_tooltip_x + _tower_tooltip_width, _tower_tooltip_y + _tower_tooltip_height, false);

	draw_set_alpha(1);
	draw_set_color(COLOR_HOLY_TOWER_RADIUS);
	draw_rectangle(_tower_tooltip_x, _tower_tooltip_y, _tower_tooltip_x + _tower_tooltip_width, _tower_tooltip_y + _tower_tooltip_height, true);

	draw_set_color(COLOR_HUD_TEXT);
	draw_text(_tower_tooltip_x + _tower_tooltip_padding, _tower_tooltip_y + _tower_tooltip_padding, _tower_name);

	var _line_y = 42;

	if (variable_instance_exists(id, "is_destroyed") && is_destroyed)
	{
		draw_text(_tower_tooltip_x + _tower_tooltip_padding, _tower_tooltip_y + _line_y, "Destroyed");
		_line_y += 20;
		draw_text(_tower_tooltip_x + _tower_tooltip_padding, _tower_tooltip_y + _line_y, _tower_hp_text);
	}
	else
	{
		draw_text(_tower_tooltip_x + _tower_tooltip_padding, _tower_tooltip_y + _line_y, _tower_hp_text);
		_line_y += 20;
		draw_text(_tower_tooltip_x + _tower_tooltip_padding, _tower_tooltip_y + _line_y, "Damage: " + string_format(damage, 0, 1));
		_line_y += 20;
		draw_text(_tower_tooltip_x + _tower_tooltip_padding, _tower_tooltip_y + _line_y, "Attack speed: " + string_format(_tower_attack_speed, 0, 2));
		_line_y += 20;
		draw_text(_tower_tooltip_x + _tower_tooltip_padding, _tower_tooltip_y + _line_y, "Attack radius: " + string_format(shoot_radius, 0, 0));
		_line_y += 20;
		draw_text(_tower_tooltip_x + _tower_tooltip_padding, _tower_tooltip_y + _line_y, "Saint radius: " + string_format(saint_radius, 0, 0));
	}

	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
	draw_set_alpha(1);
	exit;
}

var _line_count = array_length(tooltip_lines);
var _tooltip_height = (tooltip_padding * 2) + (tooltip_line_height * _line_count);
var _tooltip_x = clamp(_object_gui_x - (tooltip_width * 0.5), tooltip_padding, _gui_width - tooltip_width - tooltip_padding);
var _tooltip_y = max(tooltip_padding, _object_gui_y - tooltip_offset_y - _tooltip_height);

// Draw tooltip background.
draw_set_alpha(0.86);
draw_set_color(COLOR_HUD_BACKGROUND);
draw_rectangle(_tooltip_x, _tooltip_y, _tooltip_x + tooltip_width, _tooltip_y + _tooltip_height, false);

// Draw tooltip text.
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

// Restore default draw state.
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);
