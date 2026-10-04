// Update the camera size when the window changes.
if (instance_exists(game_controller))
{
	if (base_view_width != game_controller.camera_view_width || base_view_height != game_controller.camera_view_height)
	{
		base_view_width = game_controller.camera_view_width;
		base_view_height = game_controller.camera_view_height;
	}
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
if (zoom_level != target_zoom_level || view_width != base_view_width * zoom_level || view_height != base_view_height * zoom_level)
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

// End Step follows the final player position without a one-frame movement delay.
if (!instance_exists(follow_target))
{
	follow_target = instance_find(o_player, 0);
}

if (instance_exists(follow_target))
{
	x = follow_target.x;
	y = follow_target.y;
}

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
