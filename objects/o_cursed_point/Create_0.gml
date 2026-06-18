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
structure_choice_window_width = 560;
structure_choice_window_height = 330;
structure_choice_tile_width = 220;
structure_choice_tile_height = 188;
structure_choice_tile_gap = 28;
structure_choice_sprite_size = 84;
structure_choice_hover_scale = 2;
structure_choice_options = [];

// Capture rewards roll from one of these two packs.
structure_choice_packs = [
	[
		{
			building_object: o_tower_corruption,
			building_name: "Taint Tower",
			building_description: "Spreads Taint around itself after capture."
		},
		{
			building_object: o_tower_damage,
			building_name: "Damage Tower",
			building_description: "Attacks nearby enemies after capture."
		},
		{
			building_object: o_tower_heal,
			building_name: "Heal Tower",
			building_description: "Heals nearby friendly units after capture."
		},
		{
			building_object: o_tower_vision,
			building_name: "Vision Tower",
			building_description: "Reveals fog of war in a large area after capture."
		}
	],
	[
		{
			building_object: o_boneyard,
			building_name: "Boneyard",
			building_description: "Spawns 2 Skeletons every morning after capture."
		},
		{
			building_object: o_orcs_hut,
			building_name: "Orcs Hut",
			building_description: "Adds neutral orcs that haul corpses to the cannon."
		},
		{
			building_object: o_pitlings_house,
			building_name: "Pitlings House",
			building_description: "Spawns 1 Pitling every morning after capture."
		}
	]
];

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
	return [
		x - (summon_button_width * 0.5),
		y - summon_button_offset_y,
		summon_button_width,
		summon_button_height
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
	if (!is_captured || structure_selection_open || global.focus_window != FOCUS_WINDOW.NOONE)
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
	var _first_index = irandom(array_length(_pack) - 1);
	var _second_index = irandom(array_length(_pack) - 1);

	for (var _attempt_index = 0; _attempt_index < 8; ++_attempt_index)
	{
		if (_second_index != _first_index)
		{
			break;
		}

		_second_index = irandom(array_length(_pack) - 1);
	}

	if (_second_index == _first_index)
	{
		_second_index = (_first_index + 1) mod array_length(_pack);
	}

	structure_choice_options = [
		_pack[_first_index],
		_pack[_second_index]
	];
};

cursed_point_structure_selection_open = function()
{
	if (!is_captured || structure_selection_open)
	{
		return;
	}

	cursed_point_structure_options_roll();
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

cursed_point_structure_choice_rect_get = function(_choice_index)
{
	var _gui_size = cursed_point_gui_size_get();
	var _panel_x = (_gui_size[0] - structure_choice_window_width) * 0.5;
	var _panel_y = (_gui_size[1] - structure_choice_window_height) * 0.5;
	var _total_width = (structure_choice_tile_width * 2) + structure_choice_tile_gap;
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

cursed_point_structure_build = function(_choice)
{
	var _built_object = instance_create_layer(x, y, "Instances", _choice.building_object);

	if (instance_exists(_built_object))
	{
		_built_object.depth = -floor(_built_object.y);

		if (variable_instance_exists(_built_object, "tower_capture_enabled"))
		{
			_built_object.tower_capture_enabled = true;
		}

		if (variable_instance_exists(_built_object, "is_captured"))
		{
			_built_object.is_captured = true;
		}

		if (variable_instance_exists(_built_object, "max_corruption")
			&& variable_instance_exists(_built_object, "corruption"))
		{
			_built_object.corruption = _built_object.max_corruption;
		}

		if (variable_instance_exists(_built_object, "captured_sprite_index")
			&& _built_object.captured_sprite_index != noone)
		{
			_built_object.sprite_index = _built_object.captured_sprite_index;
			_built_object.image_index = 0;
			_built_object.image_speed = 0;
		}
	}

	if (variable_global_exists("construction_sound_play"))
	{
		global.construction_sound_play();
	}

	cursed_point_structure_selection_close();
	instance_destroy();
};
