// Event information and actions currently live exclusively in Assign Duties.
if (!WORLD_EVENT_INTERFACE_ENABLED)
{
	world_event_hover_active = false;

	if (variable_global_exists("world_event_hover_building")
		&& global.world_event_hover_building == id)
	{
		global.world_event_hover_building = noone;
	}

	exit;
}

if (variable_global_exists("blood_moon_reward_popup_active")
	&& global.blood_moon_reward_popup_active)
{
	exit;
}

// Draw the current event assignment slots and hover card in screen space.
var _world_selector_active = global.focus_window == FOCUS_WINDOW.WORLD_EVENT_SQUAD_SELECTION
	&& global.world_event_squad_selector_building == id;

if ((global.focus_window != FOCUS_WINDOW.NOONE && !_world_selector_active)
	|| !instance_exists(o_camera_controller)
	|| !variable_global_exists("day_events"))
{
	world_event_hover_active = false;

	if (global.world_event_hover_building == id)
	{
		global.world_event_hover_building = noone;
	}

	exit;
}

var _tutorial_popup_blocks_world_hover = variable_global_exists("tutorial_popup_active")
	&& global.tutorial_popup_active;

if (_tutorial_popup_blocks_world_hover)
{
	world_event_hover_active = false;

	if (global.world_event_hover_building == id)
	{
		global.world_event_hover_building = noone;
	}

	exit;
}

var _current_event = world_event_current_get();

if (!is_struct(_current_event))
{
	world_event_hover_active = false;

	if (global.world_event_hover_building == id)
	{
		global.world_event_hover_building = noone;
	}

	exit;
}

var _layout = world_event_layout_get(_current_event);

if (!is_struct(_layout))
{
	world_event_hover_active = false;

	if (global.world_event_hover_building == id)
	{
		global.world_event_hover_building = noone;
	}

	exit;
}

var _camera_x = _layout.camera_x;
var _camera_y = _layout.camera_y;
var _camera_width = _layout.camera_width;
var _camera_height = _layout.camera_height;
var _gui_width = _layout.gui_width;
var _gui_height = _layout.gui_height;
var _world_to_gui_x = _layout.world_to_gui_x;
var _world_to_gui_y = _layout.world_to_gui_y;
var _slot_count = _current_event.cultist_cost * _current_event.activation_limit;
var _slot_row_width = (_slot_count - 1) * BALANCE_WORLD_EVENT_SLOT_SPACING;
var _slot_start_world_x = x - (_slot_row_width * 0.5);
var _slot_bottom_world_y = bbox_bottom + 12;

if (variable_instance_exists(id, "worker_stand_offset_y"))
{
	_slot_bottom_world_y = bbox_bottom + worker_stand_offset_y;
}

// Daytime slots remain visible without hover so workers can be assigned directly in the world.
if (global.day_phase == DAY_PHASE.DAY)
{
	for (var _slot_index = 0; _slot_index < _slot_count; ++_slot_index)
	{
		var _slot_center_world_x = _slot_start_world_x
			+ (_slot_index * BALANCE_WORLD_EVENT_SLOT_SPACING);
		var _slot_left_world_x = _slot_center_world_x
			- (BALANCE_WORLD_EVENT_SLOT_WIDTH * 0.5);
		var _slot_top_world_y = _slot_bottom_world_y - BALANCE_WORLD_EVENT_SLOT_HEIGHT;
		var _slot_gui_x = (_slot_left_world_x - _camera_x) * _world_to_gui_x;
		var _slot_gui_y = (_slot_top_world_y - _camera_y) * _world_to_gui_y;
		var _slot_gui_width = BALANCE_WORLD_EVENT_SLOT_WIDTH * _world_to_gui_x;
		var _slot_gui_height = BALANCE_WORLD_EVENT_SLOT_HEIGHT * _world_to_gui_y;

		draw_set_alpha(1);
		draw_set_color(COLOR_JOBS_SLOT_BORDER);
		draw_rectangle(
			_slot_gui_x,
			_slot_gui_y,
			_slot_gui_x + _slot_gui_width,
			_slot_gui_y + _slot_gui_height,
			true
		);
	}
}

var _mouse_gui_x = device_mouse_x_to_gui(0);
var _mouse_gui_y = device_mouse_y_to_gui(0);
var _mouse_world_x = _camera_x + ((_mouse_gui_x / _gui_width) * _camera_width);
var _mouse_world_y = _camera_y + ((_mouse_gui_y / _gui_height) * _camera_height);
var _building_contains_mouse = _mouse_world_x >= bbox_left
	&& _mouse_world_x <= bbox_right
	&& _mouse_world_y >= bbox_top
	&& _mouse_world_y <= bbox_bottom;
var _can_start_hover = !instance_exists(global.world_event_hover_building)
	|| global.world_event_hover_building == id;
var _building_is_hovered = _building_contains_mouse && _can_start_hover;
var _selector_area_is_hovered = world_event_hover_active
	&& global.world_event_hover_building == id
	&& _layout.has_selector
	&& world_event_selector_hover_contains(_mouse_world_x, _mouse_world_y);
var _is_hovered = _world_selector_active
	|| _building_is_hovered
	|| _selector_area_is_hovered;

if (_world_selector_active || _building_is_hovered)
{
	global.world_event_hover_building = id;
}

if (variable_global_exists("cultist_assignment_preview_building")
	&& global.cultist_assignment_preview_building == id)
{
	_is_hovered = true;
}

world_event_hover_active = _is_hovered;

if (!_is_hovered)
{
	if (global.world_event_hover_building == id)
	{
		global.world_event_hover_building = noone;
	}
}

var _building_gui_x = _layout.building_center_x;
var _building_top_gui_y = _layout.building_top;
var _event_is_ready = _current_event.activation_ready_count_get() > 0;
var _card_x = _layout.card_x;
var _card_y = _layout.card_y;
var _card_height = _layout.card_height;
var _hovered_result_unit_object = noone;
var _hovered_result_relic = RELIC.NONE;
var _hovered_shell_enchantment_choice = noone;
var _result_stats_font = -1;

if (_is_hovered)
{
	var _jobs_ui = instance_exists(o_jobs_ui)
		? instance_find(o_jobs_ui, 0)
		: noone;

	draw_set_alpha(1);
	draw_set_color(COLOR_JOBS_EVENT_ACTIVE);
	draw_rectangle(
		_card_x,
		_card_y,
		_card_x + BALANCE_WORLD_EVENT_CARD_WIDTH,
		_card_y + _card_height,
		false
	);

	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(COLOR_JOBS_ASSIGN_TEXT);

	if (instance_exists(_jobs_ui) && font_exists(_jobs_ui.jobs_title_font))
	{
		draw_set_font(_jobs_ui.jobs_title_font);
	}

	draw_text(
		_card_x + BALANCE_WORLD_EVENT_CARD_PADDING_X,
		_card_y + BALANCE_WORLD_EVENT_CARD_PADDING_Y,
		_current_event.title
	);

	if (instance_exists(_jobs_ui) && font_exists(_jobs_ui.jobs_description_font))
	{
		draw_set_font(_jobs_ui.jobs_description_font);
	}

	if (instance_exists(_jobs_ui) && font_exists(_jobs_ui.jobs_hp_font))
	{
		_result_stats_font = _jobs_ui.jobs_hp_font;
	}

	var _description_x = _card_x + BALANCE_WORLD_EVENT_CARD_PADDING_X;
	var _description_y = _card_y
		+ BALANCE_WORLD_EVENT_CARD_PADDING_Y
		+ BALANCE_WORLD_EVENT_DESCRIPTION_OFFSET_Y;
	var _description_width = BALANCE_WORLD_EVENT_CARD_WIDTH
		- (BALANCE_WORLD_EVENT_CARD_PADDING_X * 2)
		- (_event_is_ready ? BALANCE_WORLD_EVENT_READY_ICON_WIDTH : 0);
	var _modifier_text = day_event_modifiers_text_get(_current_event);
	draw_text_ext(
		_description_x,
		_description_y,
		_current_event.description,
		BALANCE_WORLD_EVENT_DESCRIPTION_LINE_SEPARATION,
		_description_width
	);

	if (_modifier_text != "")
	{
		var _description_height = string_height_ext(
			_current_event.description,
			BALANCE_WORLD_EVENT_DESCRIPTION_LINE_SEPARATION,
			_description_width
		);
		draw_set_color(COLOR_STATUS_NEGATIVE_RED);
		draw_text_ext(
			_description_x,
			_description_y
				+ _description_height
				+ BALANCE_WORLD_EVENT_DESCRIPTION_LINE_SEPARATION,
			_modifier_text,
			BALANCE_WORLD_EVENT_DESCRIPTION_LINE_SEPARATION,
			_description_width
		);
		draw_set_color(COLOR_JOBS_ASSIGN_TEXT);
	}

	// Choice Jobs expose unit specializations, Relics, or shell enchantments on the building card.
	if (_layout.has_unit_choice)
	{
		var _choice_count = array_length(_current_event.unit_choice_options);
		var _selected_choice_index = variable_struct_exists(_current_event, "selected_unit_choice_index")
			? floor(_current_event.selected_unit_choice_index)
			: 0;

		for (var _choice_index = 0; _choice_index < _choice_count; ++_choice_index)
		{
			var _choice = _current_event.unit_choice_options[_choice_index];

			if (!is_struct(_choice))
			{
				continue;
			}

			var _choice_has_unit = variable_struct_exists(_choice, "target_unit_object");
			var _choice_has_relic = variable_struct_exists(_choice, "relic");
			var _choice_has_shell_enchantment = variable_struct_exists(_choice, "shell_enchantment");

			if (!_choice_has_unit && !_choice_has_relic && !_choice_has_shell_enchantment)
			{
				continue;
			}

			var _choice_rect = world_event_unit_choice_rect_get(_current_event, _layout, _choice_index);
			var _choice_center_x = _choice_rect.x + (_choice_rect.width * 0.5);
			var _choice_center_y = _choice_rect.y + (_choice_rect.height * 0.5);
			var _choice_radius = _choice_rect.width * 0.5;
			var _choice_unit_object = _choice_has_unit ? _choice.target_unit_object : noone;
			var _choice_relic = _choice_has_relic ? _choice.relic : RELIC.NONE;
			var _choice_sprite = variable_struct_exists(_choice, "icon_sprite")
				? _choice.icon_sprite
				: (_choice_has_unit ? object_get_sprite(_choice_unit_object) : noone);
			var _choice_is_hovered = point_in_rectangle(
				_mouse_gui_x,
				_mouse_gui_y,
				_choice_rect.x,
				_choice_rect.y,
				_choice_rect.x + _choice_rect.width,
				_choice_rect.y + _choice_rect.height
			);
			var _choice_is_selected = _choice_index == _selected_choice_index;
			var _choice_alpha = _choice_is_selected
				? BALANCE_EVENT_UNIT_CHOICE_SELECTED_ALPHA
				: BALANCE_EVENT_UNIT_CHOICE_UNSELECTED_ALPHA;

			draw_set_alpha(_choice_alpha);
			draw_set_color(COLOR_JOBS_ASSIGN_BACKGROUND);
			draw_circle(_choice_center_x, _choice_center_y, _choice_radius, false);
			draw_set_color(_choice_is_selected || _choice_is_hovered
				? COLOR_JOBS_EVENT_ACTIVE
				: COLOR_JOBS_SLOT_BORDER);
			draw_circle(_choice_center_x, _choice_center_y, _choice_radius, true);

			if (sprite_exists(_choice_sprite))
			{
				var _choice_sprite_width = max(1, sprite_get_width(_choice_sprite));
				var _choice_sprite_height = max(1, sprite_get_height(_choice_sprite));
				var _choice_available_size = _choice_rect.width * 0.78;
				var _choice_sprite_scale = min(
					_choice_available_size / _choice_sprite_width,
					_choice_available_size / _choice_sprite_height
				);
				var _choice_sprite_x = _choice_center_x
					+ ((sprite_get_xoffset(_choice_sprite) - (_choice_sprite_width * 0.5)) * _choice_sprite_scale);
				var _choice_sprite_y = _choice_center_y
					+ ((sprite_get_yoffset(_choice_sprite) - (_choice_sprite_height * 0.5)) * _choice_sprite_scale);

				draw_sprite_ext(
					_choice_sprite,
					0,
					_choice_sprite_x,
					_choice_sprite_y,
					_choice_sprite_scale,
					_choice_sprite_scale,
					0,
					c_white,
					1
				);
			}

			draw_set_halign(fa_center);
			draw_set_valign(fa_top);

			if (_result_stats_font != -1)
			{
				draw_set_font(_result_stats_font);
			}

			draw_set_color(_choice_is_selected ? COLOR_STATUS_NEGATIVE_RED : COLOR_JOBS_ASSIGN_TEXT);

			if (_choice_has_relic || _choice_has_shell_enchantment)
			{
				var _choice_label_width = (_layout.card_width
					- (BALANCE_WORLD_EVENT_CARD_PADDING_X * 2)) / _choice_count;
				draw_text_ext(
					_choice_center_x,
					_choice_rect.label_y,
					_choice.label,
					12,
					_choice_label_width
				);
			}
			else
			{
				draw_text(_choice_center_x, _choice_rect.label_y, _choice.label);
			}

			draw_set_alpha(1);

			if (_choice_is_hovered)
			{
				if (_choice_has_unit)
				{
					_hovered_result_unit_object = _choice_unit_object;
				}
				else if (_choice_has_relic)
				{
					_hovered_result_relic = _choice_relic;
				}
				else
				{
					_hovered_shell_enchantment_choice = _choice;
				}
			}
		}
	}

	// Squad events expose the same selector used by the Assign Jobs window.
	if (_layout.has_selector)
	{
		var _selector_text = "SELECT SQUAD";

		if (variable_struct_exists(_current_event, "selected_squad")
			&& is_struct(_current_event.selected_squad))
		{
			_selector_text = squad_name_display_get(_current_event.selected_squad.name);
		}

		draw_set_alpha(0.96);
		draw_set_color(COLOR_JOBS_ASSIGN_BACKGROUND);
		draw_rectangle(
			_layout.selector_x,
			_layout.selector_y,
			_layout.selector_x + _layout.selector_width,
			_layout.selector_y + _layout.selector_height,
			false
		);
		draw_set_alpha(1);
		draw_set_color(is_struct(_current_event.selected_squad)
			? COLOR_JOBS_EVENT_ACTIVE
			: COLOR_JOBS_SLOT_BORDER);
		draw_rectangle(
			_layout.selector_x,
			_layout.selector_y,
			_layout.selector_x + _layout.selector_width,
			_layout.selector_y + _layout.selector_height,
			true
		);
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);

		if (instance_exists(_jobs_ui) && font_exists(_jobs_ui.jobs_hp_font))
		{
			draw_set_font(_jobs_ui.jobs_hp_font);
		}

		draw_set_color(COLOR_JOBS_ASSIGN_TEXT);
		draw_text(
			_layout.selector_x + (_layout.selector_width * 0.5),
			_layout.selector_y + (_layout.selector_height * 0.5),
			_selector_text
		);
	}

	// Building-event hotkeys sit directly under the hover card.
	if (day_event_building_action_is_available(_current_event))
	{
		var _action_label_y = _card_y
			+ _card_height
			+ BALANCE_WORLD_EVENT_ACTION_LABEL_GAP;
		var _action_icon_y = _card_y
			+ _card_height
			+ BALANCE_WORLD_EVENT_ACTION_ICON_GAP;
		var _reroll_remaining = global.day_event_rerolls_remaining;
		var _pin_action = "";

		if (day_event_pin_is_event(_current_event))
		{
			_pin_action = "unpin";
		}
		else if (global.day_event_pins_remaining > 0
			&& !day_event_has_funded_activation(_current_event)
			&& !day_event_pin_source_is_active(_current_event.source_building))
		{
			_pin_action = "pin";
		}

		if (instance_exists(_jobs_ui) && font_exists(_jobs_ui.jobs_world_action_font))
		{
			draw_set_font(_jobs_ui.jobs_world_action_font);
		}

		draw_set_valign(fa_top);
		draw_set_color(COLOR_JOBS_EVENT_ACTION);

		if (_reroll_remaining > 0 && day_event_reroll_is_available(_current_event))
		{
			draw_set_halign(fa_left);
			draw_text(
				_card_x,
				_action_label_y,
				"PRESS R TO REROLL (" + string(_reroll_remaining) + ")"
			);

			if (sprite_exists(s_reroll_icon))
			{
				draw_sprite_stretched_ext(
					s_reroll_icon,
					0,
					_card_x + BALANCE_WORLD_EVENT_REROLL_ICON_OFFSET_X,
					_action_icon_y,
					BALANCE_WORLD_EVENT_REROLL_ICON_WIDTH,
					BALANCE_WORLD_EVENT_REROLL_ICON_HEIGHT,
					c_white,
					1
				);
			}
		}

		if (_pin_action != "")
		{
			draw_set_halign(fa_right);
			draw_text(
				_card_x + BALANCE_WORLD_EVENT_CARD_WIDTH,
				_action_label_y,
				_pin_action == "unpin"
					? "PRESS T TO UNPIN"
					: "PRESS T TO PIN (" + string(global.day_event_pins_remaining) + ")"
			);

			if (sprite_exists(s_pin_icon))
			{
				draw_sprite_stretched_ext(
					s_pin_icon,
					0,
					_card_x
						+ BALANCE_WORLD_EVENT_CARD_WIDTH
						- BALANCE_WORLD_EVENT_PIN_ICON_WIDTH
						+ BALANCE_WORLD_EVENT_PIN_ICON_RIGHT_OVERHANG,
					_card_y
						+ _card_height
						+ BALANCE_WORLD_EVENT_PIN_ICON_GAP,
					BALANCE_WORLD_EVENT_PIN_ICON_WIDTH,
					BALANCE_WORLD_EVENT_PIN_ICON_HEIGHT,
					c_white,
					1
				);
			}
		}
	}

	// Draw the open list last so it remains readable over the building and action hints.
	if (_world_selector_active && _layout.has_selector)
	{
		for (var _option_index = 0; _option_index < _layout.option_count; ++_option_index)
		{
			var _option_squad = _current_event.eligible_squads[_option_index];
			var _option_y = _layout.options_y + (_option_index * _layout.option_height);
			var _option_is_hovered = point_in_rectangle(
				_mouse_gui_x,
				_mouse_gui_y,
				_layout.selector_x,
				_option_y,
				_layout.selector_x + _layout.selector_width,
				_option_y + _layout.option_height
			);
			var _option_is_compatible = day_event_squad_is_compatible(_current_event, _option_squad);
			var _option_is_selected = variable_struct_exists(_current_event, "selected_squad")
				&& _current_event.selected_squad == _option_squad;

			draw_set_alpha(_option_is_compatible ? 0.98 : 0.45);
			draw_set_color(_option_is_hovered
				? COLOR_JOBS_EVENT_ACTIVE
				: COLOR_JOBS_WINDOW_BACKGROUND);
			draw_rectangle(
				_layout.selector_x,
				_option_y,
				_layout.selector_x + _layout.selector_width,
				_option_y + _layout.option_height,
				false
			);
			draw_set_alpha(1);
			draw_set_color(_option_is_selected
				? COLOR_JOBS_EVENT_ACTIVE
				: COLOR_JOBS_SLOT_BORDER);
			draw_rectangle(
				_layout.selector_x,
				_option_y,
				_layout.selector_x + _layout.selector_width,
				_option_y + _layout.option_height,
				true
			);
			draw_set_halign(fa_center);
			draw_set_valign(fa_middle);

			if (instance_exists(_jobs_ui) && font_exists(_jobs_ui.jobs_hp_font))
			{
				draw_set_font(_jobs_ui.jobs_hp_font);
			}

			draw_set_color(COLOR_JOBS_ASSIGN_TEXT);
			draw_text(
				_layout.selector_x + (_layout.selector_width * 0.5),
				_option_y + (_layout.option_height * 0.5),
				squad_name_display_get(_option_squad.name)
			);
		}
	}
}

// A ready event keeps its completion icon in both normal and hover states.
if (_event_is_ready && sprite_exists(s_ok_icon))
{
	var _ready_icon_x = _building_gui_x - (BALANCE_WORLD_EVENT_READY_ICON_WIDTH * 0.5);
	var _ready_icon_y = _building_top_gui_y
		- BALANCE_WORLD_EVENT_READY_ICON_HEIGHT
		- BALANCE_WORLD_EVENT_CARD_GAP;

	if (_is_hovered)
	{
		_ready_icon_x = _card_x
			+ BALANCE_WORLD_EVENT_CARD_WIDTH
			- BALANCE_WORLD_EVENT_CARD_PADDING_X
			- BALANCE_WORLD_EVENT_READY_ICON_WIDTH;
		_ready_icon_y = _card_y
			+ ((_layout.card_body_height - BALANCE_WORLD_EVENT_READY_ICON_HEIGHT) * 0.5);
	}

	draw_set_alpha(1);
	draw_set_color(c_white);
	draw_sprite_stretched_ext(
		s_ok_icon,
		0,
		_ready_icon_x,
		_ready_icon_y,
		BALANCE_WORLD_EVENT_READY_ICON_WIDTH,
		BALANCE_WORLD_EVENT_READY_ICON_HEIGHT,
		c_white,
		1
	);
}

if (_hovered_result_unit_object != noone && instance_exists(o_game_controller))
{
	o_game_controller.player_unit_object_stats_card_draw(
		_hovered_result_unit_object,
		18,
		120,
		_result_stats_font
	);
}

// Relic and shell enchantment choices describe their full effect on hover.
if (_hovered_result_relic != RELIC.NONE || is_struct(_hovered_shell_enchantment_choice))
{
	var _tooltip_width = 340;
	var _tooltip_padding = 12;
	var _tooltip_margin = 8;
	var _tooltip_mouse_offset = 14;
	var _tooltip_line_separation = 16;
	var _tooltip_title_gap = 7;
	var _tooltip_title = _hovered_result_relic != RELIC.NONE
		? squad_relic_name_get(_hovered_result_relic)
		: _hovered_shell_enchantment_choice.title;
	var _tooltip_description = _hovered_result_relic != RELIC.NONE
		? squad_relic_description_get(_hovered_result_relic)
		: _hovered_shell_enchantment_choice.description;
	var _tooltip_text_width = _tooltip_width - (_tooltip_padding * 2);
	var _tooltip_title_height = string_height(_tooltip_title);
	var _tooltip_description_height = string_height_ext(
		_tooltip_description,
		_tooltip_line_separation,
		_tooltip_text_width
	);
	var _tooltip_height = (_tooltip_padding * 2)
		+ _tooltip_title_height
		+ _tooltip_title_gap
		+ _tooltip_description_height;
	var _tooltip_x = clamp(
		_mouse_gui_x + _tooltip_mouse_offset,
		_tooltip_margin,
		_gui_width - _tooltip_width - _tooltip_margin
	);
	var _tooltip_y = _mouse_gui_y + _tooltip_mouse_offset;

	if (_tooltip_y + _tooltip_height > _gui_height - _tooltip_margin)
	{
		_tooltip_y = _mouse_gui_y - _tooltip_height - _tooltip_mouse_offset;
	}

	_tooltip_y = clamp(
		_tooltip_y,
		_tooltip_margin,
		_gui_height - _tooltip_height - _tooltip_margin
	);

	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_alpha(0.97);
	draw_set_color(COLOR_JOBS_ASSIGN_BACKGROUND);
	draw_rectangle(
		_tooltip_x,
		_tooltip_y,
		_tooltip_x + _tooltip_width,
		_tooltip_y + _tooltip_height,
		false
	);
	draw_set_alpha(1);
	draw_set_color(COLOR_JOBS_EVENT_ACTIVE);
	draw_rectangle(
		_tooltip_x,
		_tooltip_y,
		_tooltip_x + _tooltip_width,
		_tooltip_y + _tooltip_height,
		true
	);
	draw_text(
		_tooltip_x + _tooltip_padding,
		_tooltip_y + _tooltip_padding,
		_tooltip_title
	);
	draw_set_color(COLOR_JOBS_ASSIGN_TEXT);
	draw_text_ext(
		_tooltip_x + _tooltip_padding,
		_tooltip_y + _tooltip_padding + _tooltip_title_height + _tooltip_title_gap,
		_tooltip_description,
		_tooltip_line_separation,
		_tooltip_text_width
	);
}

// Restore the project draw defaults for later GUI objects.
if (variable_global_exists("ui_font") && font_exists(global.ui_font))
{
	draw_set_font(global.ui_font);
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);
