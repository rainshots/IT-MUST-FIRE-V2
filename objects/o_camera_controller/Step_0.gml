// Update the camera size when the window changes.
if (instance_exists(game_controller))
{
	if (base_view_width != game_controller.camera_view_width || base_view_height != game_controller.camera_view_height)
	{
		base_view_width = game_controller.camera_view_width;
		base_view_height = game_controller.camera_view_height;
	}
}

// Assign Duties keeps its composed city view fixed while gameplay continues underneath it.
if (jobs_view_active)
{
	if (!camera_jobs_view_apply())
	{
		camera_jobs_view_close();
	}

	exit;
}

// Cannon target selection keeps camera controls available while other focus windows block them.
var _tutorial_popup_active = variable_global_exists("tutorial_popup_active") && global.tutorial_popup_active;
var _camera_input_allowed = global.focus_window == FOCUS_WINDOW.NOONE
	|| global.focus_window == FOCUS_WINDOW.TARGET_SELECTION;

if (global.pause && (!_camera_input_allowed || _tutorial_popup_active))
{
	velocity_x = 0;
	velocity_y = 0;
	camera_center_clamp_to_room();

	var _paused_camera_x = round(x - half_view_width);
	var _paused_camera_y = round(y - half_view_height);
	var _paused_camera_position = camera_view_position_clamp_to_room(_paused_camera_x, _paused_camera_y);
	_paused_camera_x = _paused_camera_position[0];
	_paused_camera_y = _paused_camera_position[1];

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
	camera_center_clamp_to_room();

	camera_set_view_size(camera_id, view_width, view_height);
}

// Read normalized WASD movement input.
var _input_x = keyboard_check(ord("D")) - keyboard_check(ord("A"));
var _input_y = keyboard_check(ord("S")) - keyboard_check(ord("W"));
var _edge_input_x = 0;
var _edge_input_y = 0;

// Optional edge scroll moves the camera when the cursor touches the viewport edge.
if (variable_global_exists("edge_scroll_enabled")
	&& global.edge_scroll_enabled
	&& window_has_focus()
	&& _camera_input_allowed
	&& !_tutorial_popup_active)
{
	var _mouse_x = device_mouse_x_to_gui(0);
	var _mouse_y = device_mouse_y_to_gui(0);
	var _gui_width = display_get_gui_width();
	var _gui_height = display_get_gui_height();

	if (_mouse_x <= edge_scroll_border_size)
	{
		_edge_input_x = -1;
	}
	else if (_mouse_x >= _gui_width - edge_scroll_border_size)
	{
		_edge_input_x = 1;
	}

	if (_mouse_y <= edge_scroll_border_size)
	{
		_edge_input_y = -1;
	}
	else if (_mouse_y >= _gui_height - edge_scroll_border_size)
	{
		_edge_input_y = 1;
	}
}

// Convert input into target velocity.
var _target_velocity_x = 0;
var _target_velocity_y = 0;
var _input_length = point_distance(0, 0, _input_x, _input_y);
var _edge_input_length = point_distance(0, 0, _edge_input_x, _edge_input_y);
var _zoom_factor = (zoom_level - minimum_zoom_level) / (maximum_zoom_level - minimum_zoom_level);
var _zoom_speed_multiplier = lerp(minimum_zoom_speed_multiplier, maximum_zoom_speed_multiplier, _zoom_factor);
var _camera_speed_value = 0.5;

if (variable_global_exists("camera_speed"))
{
	_camera_speed_value = clamp(global.camera_speed, 0, 1);
}

var _camera_speed_multiplier = lerp(camera_speed_min_multiplier, camera_speed_max_multiplier, _camera_speed_value);
var _base_move_speed = move_speed * _camera_speed_multiplier;

if (_input_length > 0)
{
	var _current_move_speed = _base_move_speed * _zoom_speed_multiplier;

	_target_velocity_x = (_input_x / _input_length) * _current_move_speed;
	_target_velocity_y = (_input_y / _input_length) * _current_move_speed;
}

if (_edge_input_length > 0)
{
	var _edge_scroll_speed_value = 0.5;

	if (variable_global_exists("edge_scroll_speed"))
	{
		_edge_scroll_speed_value = clamp(global.edge_scroll_speed, 0, 1);
	}

	var _edge_speed_multiplier = lerp(edge_scroll_speed_min_multiplier, edge_scroll_speed_max_multiplier, _edge_scroll_speed_value);
	var _edge_move_speed = _base_move_speed * _zoom_speed_multiplier * _edge_speed_multiplier;

	_target_velocity_x += (_edge_input_x / _edge_input_length) * _edge_move_speed;
	_target_velocity_y += (_edge_input_y / _edge_input_length) * _edge_move_speed;
}

// Accelerate while input is active and decelerate when input is released.
var _current_acceleration = move_acceleration * _zoom_speed_multiplier * _camera_speed_multiplier;
var _current_deceleration = move_deceleration * _zoom_speed_multiplier * _camera_speed_multiplier;
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
camera_center_clamp_to_room();

var _camera_x = round(x - half_view_width);
var _camera_y = round(y - half_view_height);

// Add a short randomized offset while screen shake is active.
if (shake_timer > 0)
{
	var _shake_progress = shake_timer / max(1, shake_duration);
	var _current_shake_strength = round(shake_strength * _shake_progress);

	_camera_x += irandom_range(-_current_shake_strength, _current_shake_strength);
	_camera_y += irandom_range(-_current_shake_strength, _current_shake_strength);
	shake_timer--;

	if (shake_timer <= 0)
	{
		shake_strength = 0;
	}
}

var _camera_position = camera_view_position_clamp_to_room(_camera_x, _camera_y);
_camera_x = _camera_position[0];
_camera_y = _camera_position[1];

camera_set_view_pos(camera_id, _camera_x, _camera_y);
