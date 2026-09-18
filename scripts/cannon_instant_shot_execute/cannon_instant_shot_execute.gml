/// @description Resolves an instant shot at confirmation and consumes one charge only on success.
/// @param {PROJECTILE_TYPE} _shot_type Instant shot identity.
/// @param {Real} _world_x Aimed world X.
/// @param {Real} _world_y Aimed world Y.
/// @param {Real} _queue_index Charge entry selected by the aiming UI.
function cannon_instant_shot_execute(_shot_type, _world_x, _world_y, _queue_index)
{
	if (!instance_exists(o_cannon) || !instance_exists(o_game_controller)
		|| cannon_shot_category_get(_shot_type) != CANNON_SHOT_CATEGORY.INSTANT
		|| !cannon_shot_is_available(_shot_type)
		|| _queue_index < 0 || _queue_index >= array_length(global.cannon_projectile_queue)
		|| global.cannon_projectile_queue[_queue_index] != _shot_type
		|| _world_x < 0 || _world_x >= room_width || _world_y < 0 || _world_y >= room_height)
	{
		return false;
	}

	var _controller = instance_find(o_game_controller, 0);
	if (!_controller.cannon_projectile_type_can_fire_in_current_phase(_shot_type))
	{
		return false;
	}

	var _cannon = instance_find(o_cannon, 0);
	// Add further instant effects here; none pass through o_cannon's projectile launch path.
	switch (_shot_type)
	{
		case PROJECTILE_TYPE.LOOK_OVER_THERE:
			if (!_cannon.gaze_enabled)
			{
				return false;
			}
			_cannon.gaze_x = _world_x;
			_cannon.gaze_y = _world_y;
			break;

		default:
			return false;
	}

	// Keep charge and payload queues aligned without starting reload or a launch animation.
	array_delete(global.cannon_projectile_queue, _queue_index, 1);
	if (_queue_index < array_length(global.cannon_projectile_payload_queue))
	{
		array_delete(global.cannon_projectile_payload_queue, _queue_index, 1);
	}
	global.cannon_selected_projectile_index = clamp(_queue_index, 0,
		max(0, array_length(global.cannon_projectile_queue) - 1));
	global.cannon_projectile_gain_timer = 0;
	return true;
}
