// Base durability values for map objects.
max_hp = 1000;
hp = max_hp;
max_corruption = 100;
corruption = 0;
y_sort_enabled = true;

// Health and corruption bar visual settings.
bar_width = 72;
bar_height = 6;
bar_gap = 3;
bar_offset_y = 48;
health_bar_visible = true;
corruption_bar_visible = true;

// Tooltip text and visual settings.
tooltip_lines = [
	"Damage: No effect",
	"Taint: No effect",
	"Summon: No effect"
];
tooltip_padding = 10;
tooltip_line_height = 18;
tooltip_width = 390;
tooltip_offset_y = 72;

// Transform target. noone means the object does not transform by default.
transform_object = noone;
building_constructed_by_shell = false;
building_constructed_by_cursed_point = false;

// Cleansed player buildings permanently lose part of their max HP.
player_building_cleansed_max_hp_share = BALANCE_PLAYER_BUILDING_CLEANSED_MAX_HP_SHARE;
player_building_cleansed_hp_penalty_applied = false;
player_building_cleansed_base_max_hp = max_hp;

// Upgrade data is used by shell-built map structures.
building_has_upgrades = false;
building_upgrade_levels = [];
building_upgrade_names = [];
building_upgrade_descriptions = [];
building_upgrade_resources = [];
building_upgrade_costs = [];
building_upgrade_level_maxes = [];
building_tooltip_description = "";
upgrade_prompt_text = "G - UPGRADE";
upgrade_prompt_offset_y = 28;
upgrade_prompt_padding_x = 7;
upgrade_prompt_padding_y = 4;
upgrade_prompt_background_alpha = 0.78;

// Short warnings appear above the object when an upgrade cannot be bought.
building_warning_text = "";
building_warning_color = COLOR_STATUS_NEGATIVE_RED;
building_warning_timer = 0;
building_warning_time = 0.35 * room_speed;
building_warning_offset_y = 82;
building_warning_padding_x = 7;
building_warning_padding_y = 4;
building_warning_background_alpha = 0.84;

// Unit occlusion fades tall map objects when units walk behind their upper sprite area.
unit_fade_check_interval = BALANCE_TREE_UNIT_FADE_CHECK_INTERVAL;
unit_fade_check_timer = irandom(unit_fade_check_interval);
unit_fade_target_alpha = 1;
unit_fade_alpha = 1;

resource_name_get = function(_resource)
{
	if (_resource == RESOURCES.FLESH)
	{
		return "Flesh";
	}

	if (_resource == RESOURCES.SOULS)
	{
		return "Souls";
	}

	if (_resource == RESOURCES.IRON)
	{
		return "Iron";
	}

	if (_resource == RESOURCES.IHOR)
	{
		return "Ihor";
	}

	return "";
};

resource_color_get = function(_resource)
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

resource_icon_get = function(_resource)
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

building_warning_show = function(_text, _color)
{
	building_warning_text = _text;
	building_warning_color = _color;
	building_warning_timer = building_warning_time;
};

map_building_warning_update = function()
{
	if (building_warning_timer > 0)
	{
		building_warning_timer = max(0, building_warning_timer - 1);
	}
};

map_object_unit_occlusion_object_check = function(_object_index, _check_left, _check_top, _check_right, _check_bottom)
{
	var _unit_count = instance_number(_object_index);

	// Only live visible units behind the object origin should make its upper sprite transparent.
	for (var _unit_index = 0; _unit_index < _unit_count; ++_unit_index)
	{
		var _unit = instance_find(_object_index, _unit_index);

		if (instance_exists(_unit)
			&& _unit.visible
			&& variable_instance_exists(_unit, "hp")
			&& _unit.hp > 0
			&& _unit.x >= _check_left
			&& _unit.x <= _check_right
			&& _unit.y >= _check_top
			&& _unit.y <= _check_bottom)
		{
			return true;
		}
	}

	return false;
};

map_object_unit_occlusion_update = function()
{
	unit_fade_check_timer++;

	if (unit_fade_check_timer < unit_fade_check_interval)
	{
		return;
	}

	unit_fade_check_timer = 0;

	var _object_width = bbox_right - bbox_left;
	var _object_height = bbox_bottom - bbox_top;
	var _check_radius = _object_width * BALANCE_TREE_UNIT_FADE_RADIUS_SCALE;
	var _check_height = _object_height * BALANCE_TREE_UNIT_FADE_HEIGHT_SCALE;
	var _check_left = x - _check_radius;
	var _check_right = x + _check_radius;
	var _check_top = y - _check_height;
	var _check_bottom = y;
	var _has_unit_behind_object = map_object_unit_occlusion_object_check(
		o_friendly_units,
		_check_left,
		_check_top,
		_check_right,
		_check_bottom
	);

	if (!_has_unit_behind_object)
	{
		_has_unit_behind_object = map_object_unit_occlusion_object_check(
			o_enemy_units,
			_check_left,
			_check_top,
			_check_right,
			_check_bottom
		);
	}

	if (!_has_unit_behind_object)
	{
		_has_unit_behind_object = map_object_unit_occlusion_object_check(
			o_archdemon,
			_check_left,
			_check_top,
			_check_right,
			_check_bottom
		);
	}

	if (_has_unit_behind_object)
	{
		unit_fade_target_alpha = BALANCE_TREE_UNIT_FADE_ALPHA;
	}
	else
	{
		unit_fade_target_alpha = 1;
	}
};

map_object_unit_fade_update = function()
{
	map_object_unit_occlusion_update();
	unit_fade_alpha = lerp(unit_fade_alpha, unit_fade_target_alpha, BALANCE_TREE_UNIT_FADE_LERP_SPEED);
	image_alpha = unit_fade_alpha;
};

map_building_upgrade_effect_apply = function(_upgrade_index)
{
};

cannon_upgrade_level_max_get = function(_upgrade_index)
{
	if (_upgrade_index >= 0 && _upgrade_index < array_length(building_upgrade_level_maxes))
	{
		return building_upgrade_level_maxes[_upgrade_index];
	}

	return 1;
};

cannon_upgrade_display_level_get = function(_upgrade_index)
{
	return building_upgrade_levels[_upgrade_index];
};

cannon_upgrade_next_display_level_get = function(_upgrade_index)
{
	return min(building_upgrade_levels[_upgrade_index] + 1, cannon_upgrade_level_max_get(_upgrade_index));
};

cannon_upgrade_display_level_max_get = function(_upgrade_index)
{
	return cannon_upgrade_level_max_get(_upgrade_index);
};

cannon_upgrade_resource_get = function(_upgrade_index)
{
	if (_upgrade_index >= 0 && _upgrade_index < array_length(building_upgrade_resources))
	{
		return building_upgrade_resources[_upgrade_index];
	}

	return RESOURCES.IRON;
};

cannon_upgrade_next_cost_get = function(_upgrade_index)
{
	if (_upgrade_index >= 0 && _upgrade_index < array_length(building_upgrade_costs))
	{
		var _upgrade_cost = building_upgrade_costs[_upgrade_index];

		if (is_array(_upgrade_cost))
		{
			var _total_cost = 0;
			var _cost_count = array_length(_upgrade_cost);

			for (var _cost_index = 0; _cost_index < _cost_count; ++_cost_index)
			{
				_total_cost += _upgrade_cost[_cost_index].cost;
			}

			return _total_cost;
		}

		return _upgrade_cost;
	}

	return 0;
};

cannon_upgrade_costs_get = function(_upgrade_index)
{
	if (_upgrade_index < 0 || _upgrade_index >= array_length(building_upgrade_costs))
	{
		return [];
	}

	var _upgrade_cost = building_upgrade_costs[_upgrade_index];

	if (is_array(_upgrade_cost))
	{
		return _upgrade_cost;
	}

	return [
		{
			resource: cannon_upgrade_resource_get(_upgrade_index),
			cost: _upgrade_cost
		}
	];
};

cannon_upgrade_cost_text_get = function(_upgrade_index)
{
	var _costs = cannon_upgrade_costs_get(_upgrade_index);
	var _cost_count = array_length(_costs);
	var _cost_text = "";

	for (var _cost_index = 0; _cost_index < _cost_count; ++_cost_index)
	{
		var _cost_data = _costs[_cost_index];

		if (_cost_text != "")
		{
			_cost_text += " + ";
		}

		_cost_text += string(_cost_data.cost) + " " + resource_name_get(_cost_data.resource);
	}

	return _cost_text;
};

building_upgrade_description_get = function(_upgrade_index)
{
	if (_upgrade_index >= 0 && _upgrade_index < array_length(building_upgrade_descriptions))
	{
		return building_upgrade_descriptions[_upgrade_index];
	}

	return "";
};

building_upgrade_can_buy = function(_upgrade_index)
{
	if (!building_has_upgrades
		|| _upgrade_index < 0
		|| _upgrade_index >= array_length(building_upgrade_levels))
	{
		return false;
	}

	var _upgrade_level = building_upgrade_levels[_upgrade_index];
	var _upgrade_level_max = cannon_upgrade_level_max_get(_upgrade_index);
	var _upgrade_costs = cannon_upgrade_costs_get(_upgrade_index);
	var _cost_count = array_length(_upgrade_costs);

	for (var _cost_index = 0; _cost_index < _cost_count; ++_cost_index)
	{
		var _cost_data = _upgrade_costs[_cost_index];

		if (global.resources[_cost_data.resource] < _cost_data.cost)
		{
			return false;
		}
	}

	return _upgrade_level < _upgrade_level_max;
};

building_upgrade_buy = function(_upgrade_index)
{
	if (!building_upgrade_can_buy(_upgrade_index))
	{
		if (_upgrade_index >= 0 && _upgrade_index < array_length(building_upgrade_levels))
		{
			var _missing_costs = cannon_upgrade_costs_get(_upgrade_index);
			var _missing_cost_count = array_length(_missing_costs);

			for (var _missing_cost_index = 0; _missing_cost_index < _missing_cost_count; ++_missing_cost_index)
			{
				var _missing_cost_data = _missing_costs[_missing_cost_index];

				if (global.resources[_missing_cost_data.resource] < _missing_cost_data.cost)
				{
					building_warning_show(
						"Need " + string(_missing_cost_data.cost) + " " + resource_name_get(_missing_cost_data.resource),
						COLOR_STATUS_NEGATIVE_RED
					);
					break;
				}
			}
		}

		return false;
	}

	var _upgrade_costs = cannon_upgrade_costs_get(_upgrade_index);
	var _cost_count = array_length(_upgrade_costs);
	var _popup_gap = 46;
	var _popup_start_x = x - ((_cost_count - 1) * _popup_gap * 0.5);

	for (var _cost_index = 0; _cost_index < _cost_count; ++_cost_index)
	{
		var _cost_data = _upgrade_costs[_cost_index];
		var _popup_x = _popup_start_x + (_cost_index * _popup_gap);

		global.resources[_cost_data.resource] -= _cost_data.cost;
		resource_popup_create(_popup_x, y - bar_offset_y, _cost_data.resource, -_cost_data.cost);
	}

	building_upgrade_levels[_upgrade_index]++;
	map_building_upgrade_effect_apply(_upgrade_index);

	return true;
};

// Shell-built player structures use the cannon hit sound when enemies damage them.
player_building_damage_sound_play = function()
{
	if (variable_global_exists("cannon_damage_sounds") && variable_global_exists("sound_play_random"))
	{
		global.sound_play_random(global.cannon_damage_sounds);
	}
};

player_building_destroy_effect_create = function()
{
	if (variable_global_exists("construction_sound_play"))
	{
		global.construction_sound_play();
	}

	instance_create_layer(x, y, "Instances", o_particle_explosion);

	var _smoke_radius = 120;
	var _smoke_count = 32;

	for (var _smoke_index = 0; _smoke_index < _smoke_count; ++_smoke_index)
	{
		var _smoke_direction = random(360);
		var _smoke_distance = sqrt(random(1)) * _smoke_radius;
		var _smoke_x = x + lengthdir_x(_smoke_distance, _smoke_direction);
		var _smoke_y = y + lengthdir_y(_smoke_distance, _smoke_direction);

		instance_create_layer(_smoke_x, _smoke_y, "Instances", o_particle_smoke);
	}
};

player_building_restore_point_create = function()
{
	if (!building_constructed_by_cursed_point
		|| !variable_instance_exists(id, "cursed_point_restore_choice")
		|| !is_struct(cursed_point_restore_choice))
	{
		return noone;
	}

	var _restore_point = instance_create_layer(x, y, "Instances", o_cursed_point);

	if (instance_exists(_restore_point))
	{
		_restore_point.depth = -floor(_restore_point.y);
		_restore_point.is_captured = true;
		_restore_point.restore_structure_choice = cursed_point_restore_choice;
		_restore_point.structure_choice_options = [cursed_point_restore_choice];
		_restore_point.structure_choice_options_rolled = true;
		_restore_point.corruption = _restore_point.max_corruption;

		if (_restore_point.captured_sprite_index != noone)
		{
			_restore_point.sprite_index = _restore_point.captured_sprite_index;
			_restore_point.image_index = 0;
			_restore_point.image_speed = 0;
		}
	}

	return _restore_point;
};

player_building_is_owned_by_player = function()
{
	if (object_index == o_cursed_point)
	{
		return false;
	}

	return building_constructed_by_shell
		|| building_constructed_by_cursed_point
		|| (variable_instance_exists(id, "is_captured") && is_captured);
};

player_building_ground_state_update = function()
{
	if (!player_building_is_owned_by_player()
		|| player_building_cleansed_hp_penalty_applied
		|| max_hp <= 1)
	{
		return;
	}

	// Keep the baseline current until the first cleanse penalty is applied.
	player_building_cleansed_base_max_hp = max(player_building_cleansed_base_max_hp, max_hp);

	if (ground_cell_corruption_get(x, y) > 0)
	{
		return;
	}

	var _new_max_hp = max(1, player_building_cleansed_base_max_hp * (1 - player_building_cleansed_max_hp_share));
	max_hp = _new_max_hp;
	hp = min(hp, max_hp);
	player_building_cleansed_hp_penalty_applied = true;
};

// Shared damage receiver keeps player structure damage feedback consistent.
unit_damage_receive = function(_damage_amount, _source_faction = UNIT_FACTION.NOONE, _is_critical = false, _can_trigger_soul_chain = true, _source_instance = noone)
{
	if (hp <= 0 || _damage_amount <= 0)
	{
		return 0;
	}

	var _applied_damage = min(_damage_amount, hp);
	hp = max(hp - _damage_amount, 0);
	var _is_player_structure = building_constructed_by_shell
		|| building_constructed_by_cursed_point
		|| (variable_instance_exists(id, "is_captured") && is_captured && object_index != o_cursed_point);

	if (_applied_damage > 0 && _is_player_structure)
	{
		player_building_damage_sound_play();
	}

	if (_is_player_structure && hp <= 0)
	{
		player_building_destroy_effect_create();
		player_building_restore_point_create();
		instance_destroy();
	}

	return _applied_damage;
};

// Optional tower capture state. Children enable it when they need corruption-based activation.
tower_capture_enabled = false;
is_captured = false;
uncaptured_sprite_index = noone;
captured_sprite_index = noone;
capture_check_interval = BALANCE_TOWER_CAPTURE_CHECK_INTERVAL;
capture_check_timer = irandom(capture_check_interval - 1);
capture_ground_radius = 0;

// Default projectile reactions. Children override these methods.
on_damage_projectile_hit = function()
{
};

on_corruption_projectile_hit = function()
{
};

on_summon_projectile_hit = function()
{
};

on_projectile_hit = function(_projectile_type)
{
	if (variable_global_exists("legacy_building_logic_enabled") && !global.legacy_building_logic_enabled)
	{
		return;
	}

	if (_projectile_type == PROJECTILE_TYPE.DAMAGE)
	{
		on_damage_projectile_hit();
	}
	else if (_projectile_type == PROJECTILE_TYPE.CORRUPTION)
	{
		on_corruption_projectile_hit();
	}
	else if (_projectile_type == PROJECTILE_TYPE.SUMMON)
	{
		on_summon_projectile_hit();
	}
};

transform_into = function(_object_index)
{
	if (_object_index != noone)
	{
		instance_create_layer(x, y, "Instances", _object_index);
	}

	instance_destroy();
};

map_object_is_hovered = function()
{
	if (variable_global_exists("tutorial_popup_active") && global.tutorial_popup_active)
	{
		return false;
	}

	if (!instance_exists(o_camera_controller))
	{
		return false;
	}

	var _camera_controller = instance_find(o_camera_controller, 0);
	var _mouse_gui_x = device_mouse_x_to_gui(0);
	var _mouse_gui_y = device_mouse_y_to_gui(0);
	var _camera_x = camera_get_view_x(_camera_controller.camera_id);
	var _camera_y = camera_get_view_y(_camera_controller.camera_id);
	var _camera_width = camera_get_view_width(_camera_controller.camera_id);
	var _camera_height = camera_get_view_height(_camera_controller.camera_id);
	var _gui_width = _camera_controller.base_view_width;
	var _gui_height = _camera_controller.base_view_height;
	var _mouse_world_x = _camera_x + ((_mouse_gui_x / _gui_width) * _camera_width);
	var _mouse_world_y = _camera_y + ((_mouse_gui_y / _gui_height) * _camera_height);

	return _mouse_world_x >= bbox_left
		&& _mouse_world_x <= bbox_right
		&& _mouse_world_y >= bbox_top
		&& _mouse_world_y <= bbox_bottom;
};

ground_cell_corruption_get = function(_world_x, _world_y)
{
	if (!instance_exists(o_corruption_grid))
	{
		return 0;
	}

	var _corruption_grid_object = instance_find(o_corruption_grid, 0);
	var _cell_x = floor(_world_x / _corruption_grid_object.cell_size);
	var _cell_y = floor(_world_y / _corruption_grid_object.cell_size);
	var _is_inside_grid = _cell_x >= 0
		&& _cell_x < _corruption_grid_object.grid_width
		&& _cell_y >= 0
		&& _cell_y < _corruption_grid_object.grid_height;

	if (!_is_inside_grid)
	{
		return 0;
	}

	if (variable_instance_exists(_corruption_grid_object, "saint_grid")
		&& ds_grid_get(_corruption_grid_object.saint_grid, _cell_x, _cell_y)
			>= _corruption_grid_object.minimum_draw_corruption)
	{
		return 0;
	}

	return ds_grid_get(_corruption_grid_object.corruption_grid, _cell_x, _cell_y);
};

ground_area_is_tainted = function(_world_x, _world_y, _radius = 0)
{
	if (!instance_exists(o_corruption_grid))
	{
		return false;
	}

	var _corruption_grid_object = instance_find(o_corruption_grid, 0);

	if (_radius > 0
		&& variable_instance_exists(_corruption_grid_object, "circle_touches_corruption"))
	{
		return _corruption_grid_object.circle_touches_corruption(_world_x, _world_y, _radius);
	}

	var _corruption = ground_cell_corruption_get(_world_x, _world_y);
	return _corruption >= _corruption_grid_object.minimum_draw_corruption;
};

tower_capture_update = function()
{
	if (!tower_capture_enabled || is_captured)
	{
		return;
	}

	capture_check_timer++;

	if (capture_check_timer < capture_check_interval)
	{
		return;
	}

	capture_check_timer = 0;
	var _ground_is_tainted = ground_area_is_tainted(x, y, capture_ground_radius);
	corruption = _ground_is_tainted ? max_corruption : 0;

	if (!_ground_is_tainted)
	{
		return;
	}

	is_captured = true;
	corruption = max_corruption;

	if (captured_sprite_index != noone)
	{
		sprite_index = captured_sprite_index;
		image_index = 0;
		image_speed = 0;
	}
};

tower_range_draw = function(_radius, _color)
{
	if (!is_captured || !map_object_is_hovered())
	{
		return;
	}

	var _radius_alpha = 0.28;
	var _outline_alpha = 0.85;

	draw_set_alpha(_radius_alpha);
	draw_set_color(_color);
	draw_circle(x, y, _radius, true);

	draw_set_alpha(_radius_alpha * 0.45);
	draw_circle(x, y, _radius, false);

	// A bright outline keeps large hover ranges readable over noisy terrain.
	draw_set_alpha(_outline_alpha);
	draw_set_color(c_white);
	draw_circle(x, y, _radius, true);

	draw_set_color(c_white);
	draw_set_alpha(1);
};
