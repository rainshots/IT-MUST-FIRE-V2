// Start the strategy camera in the center of the room.
x = room_width * 0.5;
y = room_height * 0.5;

// Controller reference used for resolution changes.
game_controller = noone;

if (instance_exists(o_game_controller))
{
	game_controller = instance_find(o_game_controller, 0);
}

if (!variable_global_exists("edge_scroll_enabled"))
{
	global.edge_scroll_enabled = true;
}

if (!variable_global_exists("edge_scroll_speed"))
{
	global.edge_scroll_speed = 0.5;
}

// View size used by the strategy camera.
if (instance_exists(game_controller))
{
	base_view_width = game_controller.camera_view_width;
	base_view_height = game_controller.camera_view_height;
}
else
{
	base_view_width = 1366;
	base_view_height = 768;
}

// Zoom settings controlled by the mouse wheel.
zoom_level = 1;
target_zoom_level = 1;
minimum_zoom_level = 1;
maximum_zoom_level = 3;
zoom_step = 0.2;
zoom_smoothing = 0.18;

// Current camera view size.
view_width = base_view_width * zoom_level;
view_height = base_view_height * zoom_level;

// Movement settings for smooth WASD camera control.
move_speed = 18;
move_acceleration = 1.2;
move_deceleration = 1.0;
minimum_zoom_speed_multiplier = 1;
maximum_zoom_speed_multiplier = 2;
edge_scroll_border_size = 28;
edge_scroll_speed_min_multiplier = 0.35;
edge_scroll_speed_max_multiplier = 1.5;

// Current camera velocity.
velocity_x = 0;
velocity_y = 0;

// Screen shake is triggered by heavy gameplay impacts.
shake_timer = 0;
shake_duration = 0;
shake_strength = 0;

camera_shake_start = function(_duration_seconds, _strength)
{
	shake_duration = max(1, _duration_seconds * room_speed);
	shake_timer = shake_duration;
	shake_strength = max(shake_strength, _strength);
};

camera_center_on_instance = function(_target)
{
	if (!instance_exists(_target))
	{
		return false;
	}

	return camera_center_on_position(_target.x, _target.y);
};

camera_center_on_position = function(_target_x, _target_y)
{
	// Stop keyboard drift so the requested target stays centered immediately.
	x = _target_x;
	y = _target_y;
	camera_center_clamp_to_room();
	velocity_x = 0;
	velocity_y = 0;

	return true;
};

// Camera centering helpers.
half_view_width = view_width * 0.5;
half_view_height = view_height * 0.5;

camera_center_clamp_to_room = function()
{
	var _minimum_center_x = half_view_width;
	var _maximum_center_x = room_width - half_view_width;
	var _minimum_center_y = half_view_height;
	var _maximum_center_y = room_height - half_view_height;

	// Center the view if it ever becomes wider than the room.
	if (_minimum_center_x > _maximum_center_x)
	{
		x = room_width * 0.5;
	}
	else
	{
		x = clamp(x, _minimum_center_x, _maximum_center_x);
	}

	if (_minimum_center_y > _maximum_center_y)
	{
		y = room_height * 0.5;
	}
	else
	{
		y = clamp(y, _minimum_center_y, _maximum_center_y);
	}
};

camera_view_position_clamp_to_room = function(_view_x, _view_y)
{
	var _maximum_view_x = max(0, room_width - view_width);
	var _maximum_view_y = max(0, room_height - view_height);

	return [
		clamp(_view_x, 0, _maximum_view_x),
		clamp(_view_y, 0, _maximum_view_y)
	];
};

camera_center_clamp_to_room();

// Camera creation settings.
camera_angle = 0;
camera_follow_object = noone;
camera_horizontal_border = -1;
camera_vertical_border = -1;
camera_horizontal_speed = -1;
camera_vertical_speed = -1;

// Main room camera assigned to viewport 0.
camera_id = camera_create_view(
	x - half_view_width,
	y - half_view_height,
	view_width,
	view_height,
	camera_angle,
	camera_follow_object,
	camera_horizontal_border,
	camera_vertical_border,
	camera_horizontal_speed,
	camera_vertical_speed
);

// Enable the first viewport for this room.
main_view_index = 0;
view_enabled = true;
view_visible[main_view_index] = true;
view_camera[main_view_index] = camera_id;
