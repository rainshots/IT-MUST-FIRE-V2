// Start the strategy camera in the center of the room.
x = room_width * 0.5;
y = room_height * 0.5;

// Controller reference used for resolution changes.
game_controller = noone;

if (instance_exists(o_game_controller))
{
	game_controller = instance_find(o_game_controller, 0);
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

// Current camera velocity.
velocity_x = 0;
velocity_y = 0;

// Camera centering helpers.
half_view_width = view_width * 0.5;
half_view_height = view_height * 0.5;

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
