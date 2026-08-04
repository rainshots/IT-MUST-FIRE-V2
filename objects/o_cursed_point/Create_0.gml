// Initialize shared map object state and make this point a corruption capture target.
event_inherited();

tower_capture_enabled = true;
is_captured = false;
uncaptured_sprite_index = s_building_slot_empty;
captured_sprite_index = s_building_slot;
sprite_index = uncaptured_sprite_index;
image_speed = 0;

// Cursed points are choice nodes, not combat targets.
max_hp = 1;
hp = max_hp;
corruption = 0;
bar_width = 0;
bar_height = 0;

// World button settings.
summon_button_text = "SUMMON STRUCTURE";
summon_button_night_text = "Available at daytime";
summon_button_width = 188;
summon_button_height = 34;
summon_button_offset_y = 38;
summon_button_pulse_speed = 0.006;
summon_button_pulse_scale = 0.08;
summon_button_hover_scale = 2;
summon_button_hovered = false;
summon_button_hover_key = "";

// Hover tooltip explains the inactive cursed point goal.
tooltip_lines = [
	"When the ground under this pictogram is tainted,",
	"you can summon a structure here."
];
tooltip_width = 360;
tooltip_offset_y = 94;

// Structure choice window settings.
structure_selection_open = false;
structure_selection_previous_pause_state = false;
structure_choice_window_width = 800;
structure_choice_window_height = 360;
structure_choice_tile_width = 220;
structure_choice_tile_height = 214;
structure_choice_tile_gap = 28;
structure_choice_sprite_size = 84;
structure_choice_hover_scale = 2;
structure_choice_options = [];
structure_choice_options_rolled = false;
restore_structure_choice = noone;

// Captured points let the player choose any tower from this roster.
structure_choice_packs = [
	[
		{
			building_object: o_tower_damage,
			building_name: "Damage Tower",
			building_description: "Shoots enemies with exploding projectiles. Physical damage.",
			construction_costs: [
				{
					resource: RESOURCES.IRON,
					cost: BALANCE_TOWER_DAMAGE_BUILD_IRON_COST
				}
			]
		},
		{
			building_object: o_tower_heal,
			building_name: "Heal Tower",
			building_description: "Heals nearby friendly units.",
			construction_costs: [
				{
					resource: RESOURCES.SOULS,
					cost: BALANCE_TOWER_HEAL_BUILD_SOUL_COST
				},
				{
					resource: RESOURCES.IRON,
					cost: BALANCE_TOWER_HEAL_BUILD_IRON_COST
				}
			]
		},
		{
			building_object: o_magic_tower,
			building_name: "Magic Tower",
			building_description: "Strikes enemies with magic in a huge radius."
		}
	]
];

cursed_point_resource_icon_get = function(_resource)
{
	if (_resource == RESOURCES.FLESH)
	{
		return s_flesh_icon;
	}

	if (_resource == RESOURCES.SOULS)
	{
		return s_soul_icon;
	}

	if (_resource == RESOURCES.IRON)
	{
		return s_iron_icon;
	}

	if (_resource == RESOURCES.IHOR)
	{
		return s_ihor_icon;
	}

	return noone;
};

cursed_point_resource_color_get = function(_resource)
{
	if (_resource == RESOURCES.FLESH)
	{
		return COLOR_HUD_FLESH;
	}

	if (_resource == RESOURCES.SOULS)
	{
		return COLOR_HUD_SOULS;
	}

	if (_resource == RESOURCES.IRON)
	{
		return COLOR_HUD_IRON;
	}

	if (_resource == RESOURCES.IHOR)
	{
		return COLOR_HUD_IHOR;
	}

	return c_white;
};

cursed_point_structure_choice_can_pay = function(_choice)
{
	return true;
};

cursed_point_structure_choice_costs_pay = function(_choice)
{
	if (!variable_struct_exists(_choice, "construction_costs"))
	{
		return;
	}

	var _cost_count = array_length(_choice.construction_costs);
	var _popup_gap = 46;
	var _popup_start_x = x - ((_cost_count - 1) * _popup_gap * 0.5);

	for (var _cost_index = 0; _cost_index < _cost_count; ++_cost_index)
	{
		var _cost_data = _choice.construction_costs[_cost_index];
		var _popup_x = _popup_start_x + (_cost_index * _popup_gap);

		global.resources[_cost_data.resource] -= _cost_data.cost;
		resource_popup_create(_popup_x, y - 84, _cost_data.resource, -_cost_data.cost);
	}
};

cursed_point_construction_effect_create = function()
{
	if (variable_global_exists("construction_sound_play"))
	{
		global.construction_sound_play();
	}

	instance_create_layer(x, y, "Instances", o_particle_explosion);

	var _smoke_radius = 150;
	var _smoke_count = 44;

	for (var _smoke_index = 0; _smoke_index < _smoke_count; ++_smoke_index)
	{
		var _smoke_direction = random(360);
		var _smoke_distance = sqrt(random(1)) * _smoke_radius;
		var _smoke_x = x + lengthdir_x(_smoke_distance, _smoke_direction);
		var _smoke_y = y + lengthdir_y(_smoke_distance, _smoke_direction);

		instance_create_layer(_smoke_x, _smoke_y, "Instances", o_particle_smoke);
	}
};

cursed_point_gui_size_get = function()
{
	if (instance_exists(o_game_controller))
	{
		var _game_controller = instance_find(o_game_controller, 0);

		if (variable_instance_exists(_game_controller, "camera_view_width")
			&& variable_instance_exists(_game_controller, "camera_view_height"))
		{
			return [_game_controller.camera_view_width, _game_controller.camera_view_height];
		}
	}

	if (instance_exists(o_camera_controller))
	{
		var _camera_controller = instance_find(o_camera_controller, 0);

		if (variable_instance_exists(_camera_controller, "base_view_width")
			&& variable_instance_exists(_camera_controller, "base_view_height"))
		{
			return [_camera_controller.base_view_width, _camera_controller.base_view_height];
		}
	}

	return [1366, 768];
};

cursed_point_mouse_world_position_get = function()
{
	if (!instance_exists(o_camera_controller))
	{
		return [x, y];
	}

	var _camera_controller = instance_find(o_camera_controller, 0);
	var _mouse_gui_x = device_mouse_x_to_gui(0);
	var _mouse_gui_y = device_mouse_y_to_gui(0);
	var _camera_x = camera_get_view_x(_camera_controller.camera_id);
	var _camera_y = camera_get_view_y(_camera_controller.camera_id);
	var _camera_width = camera_get_view_width(_camera_controller.camera_id);
	var _camera_height = camera_get_view_height(_camera_controller.camera_id);
	var _gui_size = cursed_point_gui_size_get();
	var _mouse_world_x = _camera_x + ((_mouse_gui_x / _gui_size[0]) * _camera_width);
	var _mouse_world_y = _camera_y + ((_mouse_gui_y / _gui_size[1]) * _camera_height);

	return [_mouse_world_x, _mouse_world_y];
};

cursed_point_summon_button_rect_get = function()
{
	var _night_text_width = string_width(summon_button_night_text) + 28;
	var _button_width = max(summon_button_width, _night_text_width);
	var _button_height = summon_button_height;

	if (is_struct(restore_structure_choice))
	{
		_button_width = max(
			summon_button_width,
			string_width("RESTORE " + restore_structure_choice.building_name) + 28
		);
		_button_height = summon_button_height + 16;
	}

	return [
		x - (_button_width * 0.5),
		y - summon_button_offset_y,
		_button_width,
		_button_height
	];
};

cursed_point_rect_expand = function(_rect, _scale)
{
	var _expanded_width = _rect[2] * _scale;
	var _expanded_height = _rect[3] * _scale;
	var _expanded_x = _rect[0] + (_rect[2] * 0.5) - (_expanded_width * 0.5);
	var _expanded_y = _rect[1] + (_rect[3] * 0.5) - (_expanded_height * 0.5);

	return [_expanded_x, _expanded_y, _expanded_width, _expanded_height];
};

cursed_point_summon_button_is_hovered = function()
{
	if (!is_captured
		|| structure_selection_open
		|| (variable_instance_exists(id, "construction_event_pending") && construction_event_pending)
		|| global.day_phase != DAY_PHASE.DAY
		|| global.focus_window != FOCUS_WINDOW.NOONE)
	{
		return false;
	}

	var _mouse_position = cursed_point_mouse_world_position_get();
	var _button_rect = cursed_point_summon_button_rect_get();
	var _hover_rect = cursed_point_rect_expand(_button_rect, summon_button_hover_scale);

	return _mouse_position[0] >= _hover_rect[0]
		&& _mouse_position[0] <= _hover_rect[0] + _hover_rect[2]
		&& _mouse_position[1] >= _hover_rect[1]
		&& _mouse_position[1] <= _hover_rect[1] + _hover_rect[3];
};

cursed_point_structure_options_roll = function()
{
	var _pack = structure_choice_packs[irandom(array_length(structure_choice_packs) - 1)];
	structure_choice_options = [];

	for (var _choice_index = 0; _choice_index < array_length(_pack); ++_choice_index)
	{
		array_push(structure_choice_options, _pack[_choice_index]);
	}

	structure_choice_options_rolled = true;
};

cursed_point_structure_selection_open = function()
{
	if (!is_captured
		|| structure_selection_open
		|| global.day_phase != DAY_PHASE.DAY)
	{
		return;
	}

	if (is_struct(restore_structure_choice))
	{
		cursed_point_structure_restore();
		return;
	}

	if (!structure_choice_options_rolled || array_length(structure_choice_options) <= 0)
	{
		cursed_point_structure_options_roll();
	}

	structure_selection_open = true;
	structure_selection_previous_pause_state = global.pause;
	global.pause = true;
	global.focus_window = FOCUS_WINDOW.CURSED_POINT_STRUCTURE_SELECTION;
	global.cursed_point_structure_selection_source = id;
};

cursed_point_structure_selection_close = function()
{
	structure_selection_open = false;

	if (variable_global_exists("cursed_point_structure_selection_source")
		&& global.cursed_point_structure_selection_source == id)
	{
		global.cursed_point_structure_selection_source = noone;
	}

	global.pause = structure_selection_previous_pause_state;
	global.focus_window = FOCUS_WINDOW.NOONE;
};

cursed_point_deactivate = function()
{
	if (structure_selection_open)
	{
		cursed_point_structure_selection_close();
	}

	is_captured = false;
	corruption = 0;
	summon_button_hovered = false;
	summon_button_hover_key = "";
	structure_choice_options = [];
	structure_choice_options_rolled = false;

	if (uncaptured_sprite_index != noone)
	{
		sprite_index = uncaptured_sprite_index;
		image_index = 0;
		image_speed = 0;
	}
};

cursed_point_ground_state_update = function()
{
	corruption = ground_cell_corruption_get(x, y) * max_corruption;

	if (is_captured && corruption <= 0)
	{
		cursed_point_deactivate();
	}
};

cursed_point_structure_choice_rect_get = function(_choice_index)
{
	var _gui_size = cursed_point_gui_size_get();
	var _panel_x = (_gui_size[0] - structure_choice_window_width) * 0.5;
	var _panel_y = (_gui_size[1] - structure_choice_window_height) * 0.5;
	var _choice_count = max(1, array_length(structure_choice_options));
	var _total_width = (structure_choice_tile_width * _choice_count)
		+ (structure_choice_tile_gap * max(0, _choice_count - 1));
	var _tile_x = _panel_x + ((structure_choice_window_width - _total_width) * 0.5)
		+ ((structure_choice_tile_width + structure_choice_tile_gap) * _choice_index);
	var _tile_y = _panel_y + 104;

	return [_tile_x, _tile_y, structure_choice_tile_width, structure_choice_tile_height];
};

cursed_point_structure_choice_hover_index_get = function(_mouse_x, _mouse_y)
{
	var _choice_count = array_length(structure_choice_options);
	var _hovered_choice = -1;
	var _hovered_choice_distance = infinity;

	for (var _choice_index = 0; _choice_index < _choice_count; ++_choice_index)
	{
		var _choice_rect = cursed_point_structure_choice_rect_get(_choice_index);
		var _hover_rect = cursed_point_rect_expand(_choice_rect, structure_choice_hover_scale);

		if (_mouse_x >= _hover_rect[0]
			&& _mouse_x <= _hover_rect[0] + _hover_rect[2]
			&& _mouse_y >= _hover_rect[1]
			&& _mouse_y <= _hover_rect[1] + _hover_rect[3])
		{
			var _choice_center_x = _choice_rect[0] + (_choice_rect[2] * 0.5);
			var _choice_center_y = _choice_rect[1] + (_choice_rect[3] * 0.5);
			var _choice_distance = point_distance(_mouse_x, _mouse_y, _choice_center_x, _choice_center_y);

			if (_choice_distance < _hovered_choice_distance)
			{
				_hovered_choice = _choice_index;
				_hovered_choice_distance = _choice_distance;
			}
		}
	}

	return _hovered_choice;
};

cursed_point_structure_choice_hover_key_get = function(_mouse_x, _mouse_y)
{
	if (!structure_selection_open)
	{
		return "";
	}

	var _hovered_choice = cursed_point_structure_choice_hover_index_get(_mouse_x, _mouse_y);

	if (_hovered_choice >= 0)
	{
		return "cursed_point_structure_" + string(id) + "_" + string(_hovered_choice);
	}

	return "";
};

cursed_point_structure_build = function(_choice, _close_selection = true)
{
	if (global.day_phase != DAY_PHASE.DAY
		|| !day_event_cursed_point_construction_can_start())
	{
		if (_close_selection)
		{
			cursed_point_structure_selection_close();
		}

		return false;
	}

	if (_close_selection)
	{
		cursed_point_structure_selection_close();
	}

	var _construction_event = day_event_building_construction_create(id, _choice, true);

	if (!is_struct(_construction_event))
	{
		return false;
	}

	if (instance_exists(o_jobs_ui))
	{
		var _jobs_ui = instance_find(o_jobs_ui, 0);

		if (_jobs_ui.jobs_window_open()
			&& variable_instance_exists(_jobs_ui, "jobs_input_block_until_mouse_release"))
		{
			_jobs_ui.jobs_input_block_until_mouse_release();
		}
	}

	return true;
};

cursed_point_structure_restore = function()
{
	if (global.day_phase != DAY_PHASE.DAY
		|| !is_struct(restore_structure_choice))
	{
		return false;
	}

	// Restoration reuses normal Cursed Point construction without reopening structure choice.
	return cursed_point_structure_build(restore_structure_choice, false);
};
