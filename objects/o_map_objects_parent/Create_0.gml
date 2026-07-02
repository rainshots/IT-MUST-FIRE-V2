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
		return building_upgrade_costs[_upgrade_index];
	}

	return 0;
};

cannon_upgrade_cost_text_get = function(_upgrade_index)
{
	var _cost = cannon_upgrade_next_cost_get(_upgrade_index);
	var _resource = cannon_upgrade_resource_get(_upgrade_index);
	return string(_cost) + " " + resource_name_get(_resource);
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
	var _upgrade_resource = cannon_upgrade_resource_get(_upgrade_index);
	var _upgrade_cost = cannon_upgrade_next_cost_get(_upgrade_index);

	return _upgrade_level < _upgrade_level_max
		&& global.resources[_upgrade_resource] >= _upgrade_cost;
};

building_upgrade_buy = function(_upgrade_index)
{
	if (!building_upgrade_can_buy(_upgrade_index))
	{
		if (_upgrade_index >= 0 && _upgrade_index < array_length(building_upgrade_levels))
		{
			var _missing_resource = cannon_upgrade_resource_get(_upgrade_index);
			var _missing_cost = cannon_upgrade_next_cost_get(_upgrade_index);
			building_warning_show("Need " + string(_missing_cost) + " " + resource_name_get(_missing_resource), COLOR_STATUS_NEGATIVE_RED);
		}

		return false;
	}

	var _upgrade_resource = cannon_upgrade_resource_get(_upgrade_index);
	var _upgrade_cost = cannon_upgrade_next_cost_get(_upgrade_index);
	global.resources[_upgrade_resource] -= _upgrade_cost;
	resource_popup_create(x, y - bar_offset_y, _upgrade_resource, -_upgrade_cost);
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
unit_damage_receive = function(_damage_amount, _source_faction = UNIT_FACTION.NOONE, _is_critical = false, _can_trigger_soul_chain = true)
{
	if (hp <= 0 || _damage_amount <= 0)
	{
		return 0;
	}

	var _applied_damage = min(_damage_amount, hp);
	hp = max(hp - _damage_amount, 0);
	var _is_player_structure = building_constructed_by_shell
		|| (variable_instance_exists(id, "is_captured") && is_captured && object_index != o_cursed_point);

	if (_applied_damage > 0 && _is_player_structure)
	{
		player_building_damage_sound_play();
	}

	if (_is_player_structure && hp <= 0)
	{
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

	return ds_grid_get(_corruption_grid_object.corruption_grid, _cell_x, _cell_y);
};

ground_cell_has_full_corruption = function(_world_x, _world_y)
{
	if (!instance_exists(o_corruption_grid))
	{
		return false;
	}

	var _corruption_grid_object = instance_find(o_corruption_grid, 0);
	var _corruption = ground_cell_corruption_get(_world_x, _world_y);
	return _corruption >= _corruption_grid_object.full_corruption_value;
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
	corruption = ground_cell_corruption_get(x, y) * max_corruption;

	if (!ground_cell_has_full_corruption(x, y))
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
