// A map-placed spreader activates once when corruption reaches its cell.
is_activated = false;
corruption_spread_radius = BALANCE_TAINT_SPREADER_RADIUS;
corruption_check_interval = max(round(BALANCE_TAINT_SPREADER_CHECK_TIME * room_speed), 1);
corruption_check_timer = irandom(corruption_check_interval);
activation_effect_duration = max(round(BALANCE_TAINT_SPREADER_EXPLOSION_TIME * room_speed), 1);
activation_effect_timer = 0;
smoke_particle_count = BALANCE_TAINT_SPREADER_SMOKE_COUNT;
particle_layer_name = "Instances";
display_name = "Taint spreader";
y_sort_enabled = true;
image_speed = 0;

taint_spreader_is_hovered = function()
{
	if (is_activated
		|| (variable_global_exists("tutorial_popup_active") && global.tutorial_popup_active)
		|| (variable_global_exists("focus_window") && global.focus_window != FOCUS_WINDOW.NOONE)
		|| !instance_exists(o_camera_controller))
	{
		return false;
	}

	// Convert the GUI pointer to world coordinates for scaled camera views.
	var _camera_controller = instance_find(o_camera_controller, 0);
	var _mouse_gui_x = device_mouse_x_to_gui(0);
	var _mouse_gui_y = device_mouse_y_to_gui(0);
	var _camera_x = camera_get_view_x(_camera_controller.camera_id);
	var _camera_y = camera_get_view_y(_camera_controller.camera_id);
	var _camera_width = camera_get_view_width(_camera_controller.camera_id);
	var _camera_height = camera_get_view_height(_camera_controller.camera_id);
	var _gui_width = max(display_get_gui_width(), 1);
	var _gui_height = max(display_get_gui_height(), 1);
	var _mouse_world_x = _camera_x + ((_mouse_gui_x / _gui_width) * _camera_width);
	var _mouse_world_y = _camera_y + ((_mouse_gui_y / _gui_height) * _camera_height);

	return _mouse_world_x >= bbox_left
		&& _mouse_world_x <= bbox_right
		&& _mouse_world_y >= bbox_top
		&& _mouse_world_y <= bbox_bottom;
};

taint_spreader_activation_effect_create = function()
{
	// The expanding flash makes the complete gameplay radius readable.
	var _explosion = instance_create_layer(x, y, particle_layer_name, o_particle_explosion);

	if (instance_exists(_explosion))
	{
		_explosion.life_time = activation_effect_duration;
		_explosion.end_radius = corruption_spread_radius;
		_explosion.inner_color = COLOR_TAINT_SPREADER_RADIUS;
		_explosion.outer_color = COLOR_TAINT_SPREADER_RADIUS;
	}

	// Distribute red smoke uniformly across the full affected circle.
	for (var _smoke_index = 0; _smoke_index < smoke_particle_count; ++_smoke_index)
	{
		var _smoke_direction = random(360);
		var _smoke_distance = sqrt(random(1)) * corruption_spread_radius;
		var _smoke_x = x + lengthdir_x(_smoke_distance, _smoke_direction);
		var _smoke_y = y + lengthdir_y(_smoke_distance, _smoke_direction);
		var _smoke = instance_create_layer(_smoke_x, _smoke_y, particle_layer_name, o_particle_smoke);

		if (instance_exists(_smoke))
		{
			_smoke.smoke_color = COLOR_TAINT_SPREADER_SMOKE;
		}
	}
};

taint_spreader_corruption_update = function()
{
	if (is_activated || !instance_exists(o_corruption_grid))
	{
		return false;
	}

	// Convert the spreader's position to a valid corruption-grid cell.
	var _corruption_grid_object = instance_find(o_corruption_grid, 0);
	var _cell_x = floor(x / _corruption_grid_object.cell_size);
	var _cell_y = floor(y / _corruption_grid_object.cell_size);
	var _is_inside_grid = _cell_x >= 0
		&& _cell_x < _corruption_grid_object.grid_width
		&& _cell_y >= 0
		&& _cell_y < _corruption_grid_object.grid_height;

	if (!_is_inside_grid)
	{
		return false;
	}

	// Any amount of corruption beneath the object permanently activates it.
	var _corruption = ds_grid_get(_corruption_grid_object.corruption_grid, _cell_x, _cell_y);

	if (_corruption <= 0)
	{
		return false;
	}

	is_activated = true;
	activation_effect_timer = activation_effect_duration;
	corrupt_circle(x, y, corruption_spread_radius, _corruption_grid_object.full_corruption_value);
	taint_spreader_activation_effect_create();
	return true;
};
