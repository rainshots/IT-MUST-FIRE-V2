var _mouse_x = device_mouse_x_to_gui(0);
var _mouse_y = device_mouse_y_to_gui(0);
var _show_hovered_now = false;
var _end_hovered_now = false;

if (global.day_phase == DAY_PHASE.DAY && global.focus_window == FOCUS_WINDOW.NOONE)
{
	var _hover_show_rect = jobs_show_button_rect_get();
	_show_hovered_now = point_in_rectangle(
		_mouse_x,
		_mouse_y,
		_hover_show_rect.x,
		_hover_show_rect.y,
		_hover_show_rect.x + _hover_show_rect.width,
		_hover_show_rect.y + _hover_show_rect.height
	);
}
else if (global.focus_window == FOCUS_WINDOW.JOBS)
{
	var _hover_layout = jobs_layout_get();
	var _hover_gui_width = display_get_gui_width();
	var _hover_end_x = (_hover_gui_width - _hover_layout.end_width) * 0.5;
	_end_hovered_now = point_in_rectangle(
		_mouse_x,
		_mouse_y,
		_hover_end_x,
		_hover_layout.end_y,
		_hover_end_x + _hover_layout.end_width,
		_hover_layout.end_y + _hover_layout.end_height
	);
}

if ((_show_hovered_now && !jobs_show_hovered)
	|| (_end_hovered_now && !jobs_end_hovered))
{
	if (variable_global_exists("sound_play_random")
		&& variable_global_exists("ui_hover_sounds"))
	{
		global.sound_play_random(global.ui_hover_sounds, global.sound_priority_ui);
	}
}

jobs_show_hovered = _show_hovered_now;
jobs_end_hovered = _end_hovered_now;

if (global.focus_window != FOCUS_WINDOW.JOBS)
{
	if (global.day_phase == DAY_PHASE.DAY
		&& global.focus_window == FOCUS_WINDOW.NOONE
		&& mouse_check_button_pressed(mb_left))
	{
		var _show_rect = jobs_show_button_rect_get();

		if (point_in_rectangle(
			_mouse_x,
			_mouse_y,
			_show_rect.x,
			_show_rect.y,
			_show_rect.x + _show_rect.width,
			_show_rect.y + _show_rect.height
		))
		{
			if (jobs_window_open() && variable_global_exists("ui_confirm_sound_play"))
			{
				global.ui_confirm_sound_play();
			}
		}
	}

	exit;
}

var _layout = jobs_layout_get();
var _event_viewport = jobs_event_viewport_get();
var _mouse_is_over_event_viewport = point_in_rectangle(
	_mouse_x,
	_mouse_y,
	_event_viewport.x,
	_event_viewport.y,
	_event_viewport.x + _event_viewport.width,
	_event_viewport.y + _event_viewport.height
);

// Scroll only the event-card list while the cultist pool and actions remain fixed.
if (_mouse_is_over_event_viewport)
{
	if (mouse_wheel_down())
	{
		jobs_scroll_offset += jobs_scroll_step;
	}
	else if (mouse_wheel_up())
	{
		jobs_scroll_offset -= jobs_scroll_step;
	}
}

jobs_scroll_clamp();

if (mouse_check_button_pressed(mb_left))
{
	var _close_clicked = point_in_rectangle(
		_mouse_x,
		_mouse_y,
		_layout.close_x,
		_layout.close_y,
		_layout.close_x + _layout.close_size,
		_layout.close_y + _layout.close_size
	);
	var _gui_width = display_get_gui_width();
	var _end_x = (_gui_width - _layout.end_width) * 0.5;
	var _end_clicked = point_in_rectangle(
		_mouse_x,
		_mouse_y,
		_end_x,
		_layout.end_y,
		_end_x + _layout.end_width,
		_layout.end_y + _layout.end_height
	);

	if (_close_clicked)
	{
		if (variable_global_exists("ui_confirm_sound_play"))
		{
			global.ui_confirm_sound_play();
		}

		jobs_window_close();
		exit;
	}

	if (_end_clicked)
	{
		if (variable_global_exists("ui_confirm_sound_play"))
		{
			global.ui_confirm_sound_play();
		}

		day_event_finish_day();
		jobs_window_close();

		if (instance_exists(o_game_controller))
		{
			var _game_controller = instance_find(o_game_controller, 0);
			_game_controller.start_night_phase();
		}

		exit;
	}

	for (var _cultist_index = array_length(global.event_cultists) - 1; _cultist_index >= 0; --_cultist_index)
	{
		var _cultist = global.event_cultists[_cultist_index];
		var _cultist_rect = jobs_cultist_rect_get(_cultist);
		var _cultist_is_in_scroll_list = instance_exists(_cultist) && is_struct(_cultist.assigned_event);
		var _cultist_can_be_clicked = !_cultist_is_in_scroll_list || _mouse_is_over_event_viewport;

		if (_cultist_can_be_clicked
			&& is_struct(_cultist_rect)
			&& point_in_rectangle(
				_mouse_x,
				_mouse_y,
				_cultist_rect.x,
				_cultist_rect.y,
				_cultist_rect.x + _cultist_rect.width,
				_cultist_rect.y + _cultist_rect.height
			))
		{
			jobs_dragged_cultist = _cultist;

			if (variable_global_exists("sound_play_random")
				&& variable_global_exists("pick_worker_sounds"))
			{
				global.sound_play_random(global.pick_worker_sounds);
			}

			if (is_struct(_cultist.assigned_event))
			{
				_cultist.assigned_event.cultist_unassign(_cultist);
			}

			break;
		}
	}
}

if (instance_exists(jobs_dragged_cultist) && mouse_check_button_released(mb_left))
{
	for (var _event_index = 0; _event_index < array_length(global.day_events); ++_event_index)
	{
		var _event_rect = jobs_event_rect_get(_event_index);

		if (_mouse_is_over_event_viewport
			&& point_in_rectangle(
			_mouse_x,
			_mouse_y,
			_event_rect.x,
			_event_rect.y,
			_event_rect.x + _event_rect.width,
			_event_rect.y + _event_rect.height
		))
		{
			global.day_events[_event_index].cultist_assign(jobs_dragged_cultist);
			break;
		}
	}

	if (variable_global_exists("sound_play_random")
		&& variable_global_exists("release_worker_sounds"))
	{
		global.sound_play_random(global.release_worker_sounds);
	}

	jobs_dragged_cultist = noone;
}
