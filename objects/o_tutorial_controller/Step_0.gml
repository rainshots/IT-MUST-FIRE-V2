// Keep lower UI from receiving clicks while a tutorial popup is open.
if (popup_active)
{
	var _gui_width = display_get_gui_width();
	var _gui_height = display_get_gui_height();
	var _popup_x = (_gui_width - popup_width) * 0.5;
	var _popup_y = (_gui_height - popup_height) * 0.5;
	var _button_x = _popup_x + ((popup_width - popup_button_width) * 0.5);
	var _button_y = _popup_y + popup_height - popup_button_margin_bottom - popup_button_height;
	var _mouse_x = device_mouse_x_to_gui(0);
	var _mouse_y = device_mouse_y_to_gui(0);
	var _button_hovered = _mouse_x >= _button_x
		&& _mouse_x <= _button_x + popup_button_width
		&& _mouse_y >= _button_y
		&& _mouse_y <= _button_y + popup_button_height;

	if (_button_hovered
		&& !close_button_was_hovered
		&& variable_global_exists("sound_play_random")
		&& variable_global_exists("ui_hover_sounds"))
	{
		global.sound_play_random(global.ui_hover_sounds);
	}

	close_button_was_hovered = _button_hovered;

	if (_button_hovered && mouse_check_button_pressed(mb_left))
	{
		if (variable_global_exists("ui_confirm_sound") && variable_global_exists("sound_priority_ui"))
		{
			audio_play_sound(global.ui_confirm_sound, global.sound_priority_ui, false);
		}

		tutorial_close();
	}

	exit;
}

// Delay the welcome popup until the first world and fog updates have run.
if (!global.tutorial_welcome_closed && !tutorial_seen_has("welcome"))
{
	tutorial_start_delay_timer--;

	if (tutorial_start_delay_timer <= 0)
	{
		tutorial_trigger("welcome");
	}

	exit;
}

if (!global.tutorial_welcome_closed)
{
	exit;
}

// Opening the construction window for the first time explains building types.
var _construction_window_open = global.focus_window == FOCUS_WINDOW.BUILDING_CONSTRUCTION;
var _current_day = tutorial_current_day_get();

if (_construction_window_open && !construction_window_was_open)
{
	tutorial_trigger("buildings");

	if (_current_day == 2 && !instance_exists(o_meat_bath))
	{
		tutorial_trigger("meat_bath_needed");
	}
}

construction_window_was_open = _construction_window_open;

var _current_day_phase = global.day_phase;

// Phase-start tutorials.
if (_current_day_phase == DAY_PHASE.NIGHT && previous_day_phase != DAY_PHASE.NIGHT && _current_day == 1)
{
	tutorial_trigger("night");
}
else if (_current_day_phase == DAY_PHASE.DAY && previous_day_phase == DAY_PHASE.NIGHT && _current_day == 2)
{
	tutorial_trigger("day_after_night");
}

previous_day_phase = _current_day_phase;

// Timed day tutorials.
if (_current_day_phase == DAY_PHASE.DAY)
{
	var _day_duration_frames = max(1, global.day_duration * room_speed);
	var _day_elapsed_frames = _day_duration_frames - global.day_timer;

	if (_current_day == 2 && _day_elapsed_frames >= _day_duration_frames * 0.5)
	{
		tutorial_trigger("production_bonus");
	}

	if (_current_day == 3 && _day_elapsed_frames >= 5 * room_speed)
	{
		tutorial_trigger("infection");
	}

	if (_current_day == 3 && _day_elapsed_frames >= _day_duration_frames * 0.5)
	{
		tutorial_trigger("building_upgrades");
	}

	if (_current_day == 4 && _day_elapsed_frames >= _day_duration_frames * 0.5)
	{
		tutorial_trigger("cannon_workers");
	}
}
else if (_current_day_phase == DAY_PHASE.NIGHT)
{
	var _night_duration_frames = max(1, global.night_duration * room_speed);
	var _night_elapsed_frames = _night_duration_frames - global.day_timer;

	if (_current_day == 3 && _night_elapsed_frames >= 3 * room_speed)
	{
		tutorial_trigger("cursed_buildings");
	}

	if (_current_day == 1 && _night_elapsed_frames >= 10 * room_speed)
	{
		tutorial_trigger("damage_types");
	}
}
