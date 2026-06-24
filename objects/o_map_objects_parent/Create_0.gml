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
