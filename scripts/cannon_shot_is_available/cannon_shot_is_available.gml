/// @description Checks whether the active Cannon supports a shot, including reward and debug sources.
/// @param {PROJECTILE_TYPE} _shot_type Shot identity to check.
function cannon_shot_is_available(_shot_type)
{
	var _config = cannon_config_get();
	var _shot_count = array_length(_config.allowed_shot_types);
	for (var _shot_index = 0; _shot_index < _shot_count; ++_shot_index)
	{
		if (_config.allowed_shot_types[_shot_index] == _shot_type)
		{
			return true;
		}
	}
	return false;
}
