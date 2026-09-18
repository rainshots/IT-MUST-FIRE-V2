/// @description Applies CANNON_2 Gaze once per completed night; returns newly corrupted cell count.
/// @param {Id.Instance} _cannon Cannon that owns the Gaze.
/// @param {Real} _night_index Completed night identifier from o_game_controller.
function cannon_gaze_night_end(_cannon, _night_index)
{
	if (!instance_exists(_cannon)
		|| !_cannon.gaze_enabled
		|| _cannon.gaze_last_completed_night == _night_index
		|| !instance_exists(o_corruption_grid))
	{
		return 0;
	}

	// Consume this night's growth even if no connected clean ground remains.
	_cannon.gaze_last_completed_night = _night_index;
	return corruption_connected_circle_apply(
		_cannon.gaze_x,
		_cannon.gaze_y,
		_cannon.gaze_radius,
		_cannon.gaze_night_corruption_share
	);
}
