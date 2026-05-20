// Update the camera size when the window changes.
if (instance_exists(game_controller))
{
	if (base_view_width != game_controller.camera_view_width || base_view_height != game_controller.camera_view_height)
	{
		base_view_width = game_controller.camera_view_width;
		base_view_height = game_controller.camera_view_height;
	}
}

// Pause stops camera movement while menu input remains available.
if (global.pause)
{
	velocity_x = 0;
	velocity_y = 0;

	var _paused_camera_x = round(x - half_view_width);
	var _paused_camera_y = round(y - half_view_height);
	camera_set_view_pos(camera_id, _paused_camera_x, _paused_camera_y);
	exit;
}

// Read mouse wheel zoom input.
if (mouse_wheel_up())
{
	target_zoom_level = max(minimum_zoom_level, target_zoom_level - zoom_step);
}

if (mouse_wheel_down())
{
	target_zoom_level = min(maximum_zoom_level, target_zoom_level + zoom_step);
}

// Smoothly apply zoom and keep the camera centered.
if (zoom_level != target_zoom_level)
{
	zoom_level = lerp(zoom_level, target_zoom_level, zoom_smoothing);

	var _minimum_zoom_difference = 0.001;

	if (abs(zoom_level - target_zoom_level) < _minimum_zoom_difference)
	{
		zoom_level = target_zoom_level;
	}

	view_width = base_view_width * zoom_level;
	view_height = base_view_height * zoom_level;
	half_view_width = view_width * 0.5;
	half_view_height = view_height * 0.5;

	camera_set_view_size(camera_id, view_width, view_height);
}

// Read normalized WASD movement input.
var _input_x = keyboard_check(ord("D")) - keyboard_check(ord("A"));
var _input_y = keyboard_check(ord("S")) - keyboard_check(ord("W"));

// Convert input into target velocity.
var _target_velocity_x = 0;
var _target_velocity_y = 0;
var _input_length = point_distance(0, 0, _input_x, _input_y);
var _zoom_factor = (zoom_level - minimum_zoom_level) / (maximum_zoom_level - minimum_zoom_level);
var _zoom_speed_multiplier = lerp(minimum_zoom_speed_multiplier, maximum_zoom_speed_multiplier, _zoom_factor);

if (_input_length > 0)
{
	var _current_move_speed = move_speed * _zoom_speed_multiplier;

	_target_velocity_x = (_input_x / _input_length) * _current_move_speed;
	_target_velocity_y = (_input_y / _input_length) * _current_move_speed;
}

// Accelerate while input is active and decelerate when input is released.
var _current_acceleration = move_acceleration * _zoom_speed_multiplier;
var _current_deceleration = move_deceleration * _zoom_speed_multiplier;
var _rate_x = (_target_velocity_x == 0) ? _current_deceleration : _current_acceleration;
var _rate_y = (_target_velocity_y == 0) ? _current_deceleration : _current_acceleration;

velocity_x = clamp(_target_velocity_x, velocity_x - _rate_x, velocity_x + _rate_x);
velocity_y = clamp(_target_velocity_y, velocity_y - _rate_y, velocity_y + _rate_y);

// Remove tiny velocity leftovers after deceleration.
var _minimum_velocity = 0.01;

if (abs(velocity_x) < _minimum_velocity)
{
	velocity_x = 0;
}

if (abs(velocity_y) < _minimum_velocity)
{
	velocity_y = 0;
}

// Move the controller point and keep the camera centered on it.
x += velocity_x;
y += velocity_y;

var _camera_x = round(x - half_view_width);
var _camera_y = round(y - half_view_height);

camera_set_view_pos(camera_id, _camera_x, _camera_y);
