if (!instance_exists(o_camera_controller))
{
	exit;
}

// Convert the fixed world impact point into GUI coordinates so the countdown stays readable.
var _camera_controller = instance_find(o_camera_controller, 0);
var _camera_id = _camera_controller.camera_id;
var _camera_x = camera_get_view_x(_camera_id);
var _camera_y = camera_get_view_y(_camera_id);
var _camera_width = camera_get_view_width(_camera_id);
var _camera_height = camera_get_view_height(_camera_id);
var _gui_width = display_get_gui_width();
var _gui_height = display_get_gui_height();
var _gui_scale_x = _gui_width / max(1, _camera_width);
var _gui_scale_y = _gui_height / max(1, _camera_height);
var _radius_scale = min(_gui_scale_x, _gui_scale_y);
var _center_x = (x - _camera_x) * _gui_scale_x;
var _center_y = (y - _camera_y) * _gui_scale_y;
var _draw_radius = effect_radius * _radius_scale;

// Draw the translucent warning area and a clear outer edge.
draw_set_color(effect_color);
draw_set_alpha(warning_fill_alpha);
draw_circle(_center_x, _center_y, _draw_radius, false);
draw_set_alpha(warning_outline_alpha);

for (var _outline_index = 0; _outline_index < warning_outline_width; ++_outline_index)
{
	draw_circle(_center_x, _center_y, max(1, _draw_radius - _outline_index), true);
}

// Show the real remaining time until impact in the center of the circle.
var _remaining_seconds = max(impact_timer / room_speed, 0);
var _timer_text = string_format(_remaining_seconds, 1, 1) + "s";

if (variable_global_exists("ui_heading_font") && font_exists(global.ui_heading_font))
{
	draw_set_font(global.ui_heading_font);
}

draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(COLOR_HUD_TEXT);
draw_set_alpha(1);
draw_text(_center_x, _center_y, _timer_text);

// The shell enters from 1000 world pixels above during the final part of the countdown.
if (impact_timer <= flight_duration)
{
	var _flight_progress = clamp(1 - (impact_timer / max(1, flight_duration)), 0, 1);
	var _projectile_world_y = y - (projectile_spawn_offset_y * (1 - _flight_progress));
	var _projectile_x = _center_x;
	var _projectile_y = (_projectile_world_y - _camera_y) * _gui_scale_y;
	var _projectile_draw_radius = projectile_radius * _radius_scale;
	var _trail_draw_length = projectile_trail_length * _gui_scale_y;

	draw_set_color(effect_color);
	draw_set_alpha(0.55);
	draw_line_width(
		_projectile_x,
		_projectile_y - _trail_draw_length,
		_projectile_x,
		_projectile_y,
		max(2, _projectile_draw_radius * 0.7)
	);
	draw_set_alpha(1);
	draw_circle(_projectile_x, _projectile_y, _projectile_draw_radius, false);
	draw_set_color(COLOR_HUD_TEXT);
	draw_circle(_projectile_x, _projectile_y, _projectile_draw_radius, true);
}

// Restore the project's default GUI draw state.
if (variable_global_exists("ui_font") && font_exists(global.ui_font))
{
	draw_set_font(global.ui_font);
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);
