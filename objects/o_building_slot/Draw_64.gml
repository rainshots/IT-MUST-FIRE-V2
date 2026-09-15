// Keep the activation hint available during aiming or lightweight pause, but not over modals.
if (!visible
	|| (global.focus_window != FOCUS_WINDOW.NOONE && global.focus_window != FOCUS_WINDOW.TARGET_SELECTION)
	|| global.tutorial_popup_active
	|| global.game_completion_popup_active
	|| global.blood_moon_reward_popup_active
	|| global.early_upgrade_popup_active
	|| !instance_exists(o_camera_controller))
{
	exit;
}

// Match the slot's first-day visibility so hidden construction points never show hints.
var _building_slots_visible = day_event_current_day_get() != 1;

if (instance_exists(o_jobs_ui))
{
	var _jobs_ui = instance_find(o_jobs_ui, 0);

	if (variable_instance_exists(_jobs_ui, "jobs_building_slots_are_visible"))
	{
		_building_slots_visible = _jobs_ui.jobs_building_slots_are_visible();
	}
}

if (!_building_slots_visible)
{
	exit;
}

// Convert the GUI cursor to the same world coordinates used by slot interaction.
var _camera_controller = instance_find(o_camera_controller, 0);
var _gui_width = _camera_controller.base_view_width;
var _gui_height = _camera_controller.base_view_height;
var _mouse_gui_x = device_mouse_x_to_gui(0);
var _mouse_gui_y = device_mouse_y_to_gui(0);
var _mouse_world_x = camera_get_view_x(_camera_controller.camera_id)
	+ ((_mouse_gui_x / _gui_width) * camera_get_view_width(_camera_controller.camera_id));
var _mouse_world_y = camera_get_view_y(_camera_controller.camera_id)
	+ ((_mouse_gui_y / _gui_height) * camera_get_view_height(_camera_controller.camera_id));

if (_mouse_world_x < bbox_left || _mouse_world_x > bbox_right
	|| _mouse_world_y < bbox_top || _mouse_world_y > bbox_bottom
	|| building_slot_is_active())
{
	exit;
}

// Use the shared HUD font and palette, wrapping the hint inside the screen edges.
var _previous_font = draw_get_font();

if (variable_global_exists("ui_font") && font_exists(global.ui_font))
{
	draw_set_font(global.ui_font);
}

var _hint_width = min(tooltip_width, _gui_width - (tooltip_padding * 2));
var _text_width = _hint_width - (tooltip_padding * 2);
var _hint_height = string_height_ext(tooltip_text, tooltip_line_height, _text_width)
	+ (tooltip_padding * 2);
var _hint_x = clamp(_mouse_gui_x + tooltip_cursor_offset,
	tooltip_padding, _gui_width - _hint_width - tooltip_padding);
var _hint_y = _mouse_gui_y - _hint_height - tooltip_cursor_offset;

if (_hint_y < tooltip_padding)
{
	_hint_y = _mouse_gui_y + tooltip_cursor_offset;
}

_hint_y = clamp(_hint_y, tooltip_padding, _gui_height - _hint_height - tooltip_padding);

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_alpha(tooltip_background_alpha);
draw_set_color(COLOR_HUD_BACKGROUND);
draw_rectangle(_hint_x, _hint_y, _hint_x + _hint_width, _hint_y + _hint_height, false);
draw_set_alpha(1);
draw_set_color(COLOR_HUD_TEXT);
draw_text_ext(_hint_x + tooltip_padding, _hint_y + tooltip_padding,
	tooltip_text, tooltip_line_height, _text_width);

// Restore shared draw state for the remaining GUI objects.
draw_set_font(_previous_font);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);
