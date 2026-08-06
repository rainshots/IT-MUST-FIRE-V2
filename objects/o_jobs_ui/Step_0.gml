var _mouse_x = device_mouse_x_to_gui(0);
var _mouse_y = device_mouse_y_to_gui(0);
var _show_hovered_now = false;
var _end_hovered_now = false;
var _confirmation_cancel_hovered_now = false;
var _confirmation_end_hovered_now = false;
var _hovered_empty_slot_key_now = "";
var _hovered_event_action_key_now = "";
jobs_hovered_cultist = noone;

// Consume the mouse press that closed an overlapping modal window.
if (jobs_input_blocked_until_mouse_release)
{
	if (mouse_check_button(mb_left))
	{
		jobs_hovered_event_action_key = "";
		exit;
	}

	jobs_input_blocked_until_mouse_release = false;
}

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

	if (jobs_end_day_is_visible() && jobs_end_day_is_actionable())
	{
		var _hover_end_rect = jobs_end_day_button_rect_get();
		_end_hovered_now = point_in_rectangle(
			_mouse_x,
			_mouse_y,
			_hover_end_rect.x,
			_hover_end_rect.y,
			_hover_end_rect.x + _hover_end_rect.width,
			_hover_end_rect.y + _hover_end_rect.height
		);
	}
}
else if (global.focus_window == FOCUS_WINDOW.END_DAY_CONFIRMATION)
{
	var _confirmation_layout = jobs_end_day_confirmation_layout_get();
	_confirmation_cancel_hovered_now = point_in_rectangle(
		_mouse_x,
		_mouse_y,
		_confirmation_layout.cancel_x,
		_confirmation_layout.cancel_y,
		_confirmation_layout.cancel_x + _confirmation_layout.cancel_width,
		_confirmation_layout.cancel_y + _confirmation_layout.cancel_height
	);
	_confirmation_end_hovered_now = point_in_rectangle(
		_mouse_x,
		_mouse_y,
		_confirmation_layout.end_x,
		_confirmation_layout.end_y,
		_confirmation_layout.end_x + _confirmation_layout.end_width,
		_confirmation_layout.end_y + _confirmation_layout.end_height
	);
}

if ((_show_hovered_now && !jobs_show_hovered)
	|| (_end_hovered_now && !jobs_end_hovered)
	|| (_confirmation_cancel_hovered_now && !jobs_confirmation_cancel_hovered)
	|| (_confirmation_end_hovered_now && !jobs_confirmation_end_hovered))
{
	if (variable_global_exists("sound_play_random")
		&& variable_global_exists("ui_hover_sounds"))
	{
		global.sound_play_random(global.ui_hover_sounds, global.sound_priority_ui);
	}
}

jobs_show_hovered = _show_hovered_now;
jobs_end_hovered = _end_hovered_now;
jobs_confirmation_cancel_hovered = _confirmation_cancel_hovered_now;
jobs_confirmation_end_hovered = _confirmation_end_hovered_now;

if (global.focus_window == FOCUS_WINDOW.END_DAY_CONFIRMATION)
{
	jobs_hovered_event_action_key = "";

	if (mouse_check_button_pressed(mb_left))
	{
		if (_confirmation_cancel_hovered_now)
		{
			if (jobs_end_day_confirmation_close()
				&& variable_global_exists("ui_confirm_sound_play"))
			{
				global.ui_confirm_sound_play();
			}
		}
		else if (_confirmation_end_hovered_now)
		{
			if (jobs_end_day_execute()
				&& variable_global_exists("ui_confirm_sound_play"))
			{
				global.ui_confirm_sound_play();
			}
		}
	}

	exit;
}

if (global.focus_window != FOCUS_WINDOW.JOBS)
{
	jobs_hovered_event_action_key = "";

	if (global.day_phase == DAY_PHASE.DAY
		&& global.focus_window == FOCUS_WINDOW.NOONE
		&& mouse_check_button_pressed(mb_left))
	{
		var _show_rect = jobs_show_button_rect_get();
		var _end_rect = jobs_end_day_button_rect_get();

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
		else if (jobs_end_day_is_visible()
			&& point_in_rectangle(
			_mouse_x,
			_mouse_y,
			_end_rect.x,
			_end_rect.y,
			_end_rect.x + _end_rect.width,
			_end_rect.y + _end_rect.height
		))
		{
			if (jobs_end_day_request() && variable_global_exists("ui_confirm_sound_play"))
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
var _mouse_is_over_event_list = point_in_rectangle(
	_mouse_x,
	_mouse_y,
	_layout.panel_x,
	_event_viewport.y,
	_layout.panel_x + _layout.panel_width,
	_event_viewport.y + _event_viewport.height
);

// Scroll only the event-card list while the cultist pool and actions remain fixed.
if (_mouse_is_over_event_list)
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

// Track the available Reroll and Pin/Unpin actions beside visible building cards.
for (var _event_index = 0; _event_index < array_length(global.day_events); ++_event_index)
{
	var _event = global.day_events[_event_index];

	if (!day_event_building_action_is_available(_event))
	{
		continue;
	}

	var _event_rect = jobs_event_rect_get(_event_index);
	var _event_is_visible = _event_rect.y + _event_rect.height >= _event_viewport.y
		&& _event_rect.y <= _event_viewport.y + _event_viewport.height;

	if (!_event_is_visible)
	{
		continue;
	}

	var _reroll_rect = jobs_event_action_rect_get(_event_index, "reroll");

	if (global.day_event_rerolls_remaining > 0
		&& day_event_reroll_is_available(_event)
		&& point_in_rectangle(
			_mouse_x,
			_mouse_y,
			_reroll_rect.x,
			_reroll_rect.y,
			_reroll_rect.x + _reroll_rect.width,
			_reroll_rect.y + _reroll_rect.height
		))
	{
		day_event_reroll_preview_get(_event);
		_hovered_event_action_key_now = jobs_event_action_key_get(_event, "reroll");
		break;
	}

	var _pin_action = jobs_event_pin_action_get(_event);

	if (_pin_action == "")
	{
		continue;
	}

	var _pin_rect = jobs_event_action_rect_get(_event_index, _pin_action);

	if (point_in_rectangle(
		_mouse_x,
		_mouse_y,
		_pin_rect.x,
		_pin_rect.y,
		_pin_rect.x + _pin_rect.width,
		_pin_rect.y + _pin_rect.height
	))
	{
		_hovered_event_action_key_now = jobs_event_action_key_get(_event, _pin_action);
		break;
	}
}

if (_hovered_event_action_key_now != ""
	&& _hovered_event_action_key_now != jobs_hovered_event_action_key
	&& variable_global_exists("sound_play_random")
	&& variable_global_exists("ui_hover_sounds"))
{
	global.sound_play_random(global.ui_hover_sounds, global.sound_priority_ui);
}

jobs_hovered_event_action_key = _hovered_event_action_key_now;

// Track empty slots and cultists for hover feedback and the jobs cursor.
for (var _event_index = 0; _event_index < array_length(global.day_events); ++_event_index)
{
	var _event = global.day_events[_event_index];
	var _slot_count = _event.cultist_cost * _event.activation_limit;
	var _assigned_count = array_length(_event.assigned_cultists);

	for (var _slot_index = _assigned_count; _slot_index < _slot_count; ++_slot_index)
	{
		var _slot_rect = jobs_event_slot_rect_get(_event_index, _slot_index);

		if (_mouse_is_over_event_viewport
			&& point_in_rectangle(
				_mouse_x,
				_mouse_y,
				_slot_rect.x,
				_slot_rect.y,
				_slot_rect.x + _slot_rect.width,
				_slot_rect.y + _slot_rect.height
			))
		{
			_hovered_empty_slot_key_now = string(_event_index) + ":" + string(_slot_index);
			break;
		}
	}
}

for (var _cultist_index = array_length(global.event_cultists) - 1; _cultist_index >= 0; --_cultist_index)
{
	var _cultist = global.event_cultists[_cultist_index];
	var _cultist_rect = jobs_cultist_rect_get(_cultist);
	var _cultist_is_in_scroll_list = instance_exists(_cultist) && is_struct(_cultist.assigned_event);
	var _cultist_can_be_hovered = !_cultist_is_in_scroll_list || _mouse_is_over_event_viewport;

	if (_cultist_can_be_hovered
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
		jobs_hovered_cultist = _cultist;
		break;
	}
}

if (_hovered_empty_slot_key_now != ""
	&& _hovered_empty_slot_key_now != jobs_hovered_empty_slot_key
	&& variable_global_exists("sound_play_random")
	&& variable_global_exists("ui_hover_sounds"))
{
	global.sound_play_random(global.ui_hover_sounds, global.sound_priority_ui);
}

jobs_hovered_empty_slot_key = _hovered_empty_slot_key_now;

// Right-clicking an occupied event slot returns its cultist to the pool.
if (mouse_check_button_pressed(mb_right))
{
	for (var _event_index = 0; _event_index < array_length(global.day_events); ++_event_index)
	{
		var _event = global.day_events[_event_index];

		for (var _slot_index = 0; _slot_index < array_length(_event.assigned_cultists); ++_slot_index)
		{
			var _slot_rect = jobs_event_slot_rect_get(_event_index, _slot_index);

			if (_mouse_is_over_event_viewport
				&& point_in_rectangle(
					_mouse_x,
					_mouse_y,
					_slot_rect.x,
					_slot_rect.y,
					_slot_rect.x + _slot_rect.width,
					_slot_rect.y + _slot_rect.height
				))
			{
				var _assigned_cultist = _event.assigned_cultists[_slot_index];

				if (_event.cultist_unassign(_assigned_cultist)
					&& variable_global_exists("ui_confirm_sound_play"))
				{
					global.ui_confirm_sound_play();
				}

				exit;
			}
		}
	}
}

if (mouse_check_button_pressed(mb_left))
{
	// Event actions are handled before card slots and selectors.
	for (var _event_index = 0; _event_index < array_length(global.day_events); ++_event_index)
	{
		var _event = global.day_events[_event_index];

		if (!day_event_building_action_is_available(_event))
		{
			continue;
		}

		var _event_rect = jobs_event_rect_get(_event_index);
		var _event_is_visible = _event_rect.y + _event_rect.height >= _event_viewport.y
			&& _event_rect.y <= _event_viewport.y + _event_viewport.height;

		if (!_event_is_visible)
		{
			continue;
		}

		var _reroll_rect = jobs_event_action_rect_get(_event_index, "reroll");

		if (day_event_reroll_is_available(_event)
			&& point_in_rectangle(
				_mouse_x,
				_mouse_y,
				_reroll_rect.x,
				_reroll_rect.y,
				_reroll_rect.x + _reroll_rect.width,
				_reroll_rect.y + _reroll_rect.height
			))
		{
			jobs_squad_selector_event = noone;

			if (day_event_reroll(_event)
				&& variable_global_exists("ui_confirm_sound_play"))
			{
				global.ui_confirm_sound_play();
			}

			exit;
		}

		var _pin_action = jobs_event_pin_action_get(_event);

		if (_pin_action == "")
		{
			continue;
		}

		var _pin_rect = jobs_event_action_rect_get(_event_index, _pin_action);

		if (point_in_rectangle(
			_mouse_x,
			_mouse_y,
			_pin_rect.x,
			_pin_rect.y,
			_pin_rect.x + _pin_rect.width,
			_pin_rect.y + _pin_rect.height
		))
		{
			var _pin_changed = _pin_action == "unpin"
				? day_event_pin_clear(_event)
				: day_event_pin_set(_event);

			jobs_squad_selector_event = noone;

			if (_pin_changed && variable_global_exists("ui_confirm_sound_play"))
			{
				global.ui_confirm_sound_play();
			}

			exit;
		}
	}

	// Unit-specialization Jobs choose their result directly from the three portraits.
	for (var _event_index = 0; _event_index < array_length(global.day_events); ++_event_index)
	{
		var _event = global.day_events[_event_index];

		if (!is_struct(_event)
			|| !variable_struct_exists(_event, "unit_choice_options")
			|| !is_array(_event.unit_choice_options))
		{
			continue;
		}

		var _choice_count = array_length(_event.unit_choice_options);

		for (var _choice_index = 0; _choice_index < _choice_count; ++_choice_index)
		{
			var _choice_rect = jobs_event_unit_choice_icon_rect_get(_event_index, _choice_index);

			if (!_mouse_is_over_event_viewport
				|| !point_in_rectangle(
					_mouse_x,
					_mouse_y,
					_choice_rect.x,
					_choice_rect.y,
					_choice_rect.x + _choice_rect.width,
					_choice_rect.y + _choice_rect.height
				))
			{
				continue;
			}

			_event.selected_unit_choice_index = _choice_index;
			jobs_squad_selector_event = noone;

			if (variable_global_exists("ui_confirm_sound_play"))
			{
				global.ui_confirm_sound_play();
			}

			exit;
		}
	}

	// Resolve an open squad selector before handling the rest of the jobs window.
	if (is_struct(jobs_squad_selector_event))
	{
		var _selector_event_index = -1;
		var _selector_global_event_count = array_length(global.day_events);

		for (var _event_search_index = 0; _event_search_index < _selector_global_event_count; ++_event_search_index)
		{
			if (global.day_events[_event_search_index] == jobs_squad_selector_event)
			{
				_selector_event_index = _event_search_index;
				break;
			}
		}

		if (_selector_event_index >= 0)
		{
			var _eligible_squad_count = array_length(jobs_squad_selector_event.eligible_squads);

			for (var _option_index = 0; _option_index < _eligible_squad_count; ++_option_index)
			{
				var _option_rect = jobs_squad_selector_option_rect_get(_selector_event_index, _option_index);

				if (_mouse_is_over_event_viewport
					&& point_in_rectangle(
						_mouse_x,
						_mouse_y,
						_option_rect.x,
						_option_rect.y,
						_option_rect.x + _option_rect.width,
						_option_rect.y + _option_rect.height
					))
				{
					jobs_squad_selector_event.selected_squad = jobs_squad_selector_event.eligible_squads[_option_index];
					jobs_squad_selector_event = noone;

					if (variable_global_exists("ui_confirm_sound_play"))
					{
						global.ui_confirm_sound_play();
					}

					exit;
				}
			}
		}
	}

	// Clicking a selector button opens all squads allowed for that event.
	var _selector_button_clicked = false;
	var _selector_event_count = array_length(global.day_events);

	for (var _event_index = 0; _event_index < _selector_event_count; ++_event_index)
	{
		var _event = global.day_events[_event_index];

		if (!variable_struct_exists(_event, "requires_squad_selection") || !_event.requires_squad_selection)
		{
			continue;
		}

		var _selector_rect = jobs_squad_selector_rect_get(_event_index);

		if (_mouse_is_over_event_viewport
			&& point_in_rectangle(
				_mouse_x,
				_mouse_y,
				_selector_rect.x,
				_selector_rect.y,
				_selector_rect.x + _selector_rect.width,
				_selector_rect.y + _selector_rect.height
			))
		{
			jobs_squad_selector_event = jobs_squad_selector_event == _event ? noone : _event;
			_selector_button_clicked = true;
			break;
		}
	}

	if (_selector_button_clicked)
	{
		exit;
	}

	jobs_squad_selector_event = noone;

	var _close_clicked = point_in_rectangle(
		_mouse_x,
		_mouse_y,
		_layout.close_x,
		_layout.close_y,
		_layout.close_x + _layout.close_size,
		_layout.close_y + _layout.close_size
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

	// Construction uses the most wounded available Cultist; other events use the healthiest.
	if (jobs_hovered_empty_slot_key != "")
	{
		var _separator_position = string_pos(":", jobs_hovered_empty_slot_key);
		var _event_index_text = string_copy(jobs_hovered_empty_slot_key, 1, _separator_position - 1);
		var _clicked_event_index = real(_event_index_text);

		if (_clicked_event_index >= 0
			&& _clicked_event_index < array_length(global.day_events))
		{
			var _clicked_event = global.day_events[_clicked_event_index];
			var _is_construction_event = is_struct(_clicked_event)
				&& variable_struct_exists(_clicked_event, "construction_site");
			var _auto_assign_cultist = is_struct(_clicked_event)
				? day_event_available_cultist_find(_is_construction_event)
				: noone;

			if (instance_exists(_auto_assign_cultist)
				&& _clicked_event.cultist_assign(_auto_assign_cultist))
			{
				// Clicking a plus uses the same Cultist response as a successful drag release.
				if (variable_global_exists("sound_play_random")
					&& variable_global_exists("release_worker_sounds"))
				{
					global.sound_play_random(global.release_worker_sounds);
				}
			}
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
			jobs_drag_origin_event = is_struct(_cultist.assigned_event)
				? _cultist.assigned_event
				: noone;
			jobs_drag_origin_slot_index = is_struct(jobs_drag_origin_event)
				? jobs_event_cultist_slot_index_get(jobs_drag_origin_event, _cultist)
				: -1;

			if (variable_global_exists("sound_play_random")
				&& variable_global_exists("pick_worker_sounds"))
			{
				global.sound_play_random(global.pick_worker_sounds);
			}

			break;
		}
	}
}

if (instance_exists(jobs_dragged_cultist) && mouse_check_button_released(mb_left))
{
	var _drop_was_handled = false;

	// Dropping directly onto a slot either fills it or swaps its occupant.
	for (var _event_index = 0; _event_index < array_length(global.day_events); ++_event_index)
	{
		var _target_event = global.day_events[_event_index];
		var _target_slot_count = _target_event.cultist_cost * _target_event.activation_limit;

		for (var _target_slot_index = 0; _target_slot_index < _target_slot_count; ++_target_slot_index)
		{
			var _target_slot_rect = jobs_event_slot_rect_get(_event_index, _target_slot_index);

			if (!_mouse_is_over_event_viewport
				|| !point_in_rectangle(
					_mouse_x,
					_mouse_y,
					_target_slot_rect.x,
					_target_slot_rect.y,
					_target_slot_rect.x + _target_slot_rect.width,
					_target_slot_rect.y + _target_slot_rect.height
				))
			{
				continue;
			}

			var _target_is_occupied = _target_slot_index < array_length(_target_event.assigned_cultists);
			var _target_cultist = _target_is_occupied
				? _target_event.assigned_cultists[_target_slot_index]
				: noone;

			if (_target_cultist == jobs_dragged_cultist)
			{
				_drop_was_handled = true;
			}
			else if (instance_exists(_target_cultist))
			{
				// The displaced cultist takes the dragged cultist's former slot or returns to the pool.
				if (is_struct(jobs_drag_origin_event) && jobs_drag_origin_slot_index >= 0)
				{
					jobs_drag_origin_event.assigned_cultists[jobs_drag_origin_slot_index] = _target_cultist;
					_target_cultist.assigned_event = jobs_drag_origin_event;
				}
				else
				{
					_target_cultist.assigned_event = noone;
				}

				_target_event.assigned_cultists[_target_slot_index] = jobs_dragged_cultist;
				jobs_dragged_cultist.assigned_event = _target_event;
				_drop_was_handled = true;
			}
			else
			{
				// Empty slots use the event's regular capacity and availability validation.
				if (is_struct(jobs_drag_origin_event))
				{
					jobs_drag_origin_event.cultist_unassign(jobs_dragged_cultist);
				}

				_drop_was_handled = _target_event.cultist_assign(jobs_dragged_cultist);

				// Restore the original slot if the target rejected the cultist.
				if (!_drop_was_handled && is_struct(jobs_drag_origin_event))
				{
					array_insert(
						jobs_drag_origin_event.assigned_cultists,
						clamp(jobs_drag_origin_slot_index, 0, array_length(jobs_drag_origin_event.assigned_cultists)),
						jobs_dragged_cultist
					);
					jobs_dragged_cultist.assigned_event = jobs_drag_origin_event;
				}
			}

			break;
		}

		if (_drop_was_handled)
		{
			break;
		}
	}

	// Dropping an assigned cultist into the pool explicitly unassigns it.
	var _pool_drop = point_in_rectangle(
		_mouse_x,
		_mouse_y,
		_layout.pool_x,
		_layout.pool_y,
		_layout.pool_x + _layout.pool_width,
		_layout.pool_y + _layout.pool_height
	);

	if (!_drop_was_handled && _pool_drop && is_struct(jobs_drag_origin_event))
	{
		_drop_was_handled = jobs_drag_origin_event.cultist_unassign(jobs_dragged_cultist);
	}

	if (variable_global_exists("sound_play_random")
		&& variable_global_exists("release_worker_sounds"))
	{
		global.sound_play_random(global.release_worker_sounds);
	}

	jobs_dragged_cultist = noone;
	jobs_drag_origin_event = noone;
	jobs_drag_origin_slot_index = -1;
}
