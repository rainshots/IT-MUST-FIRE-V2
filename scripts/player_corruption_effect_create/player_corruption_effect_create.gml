/// @description Creates purple smoke across newly infected ground and plays one random infection sound.
/// @param {real} left Left edge of the infected cell in world coordinates.
/// @param {real} top Top edge of the infected cell in world coordinates.
/// @param {real} width Infected cell width, clipped to the room.
/// @param {real} height Infected cell height, clipped to the room.
/// @param {Id.Layer} layer_id Instance layer for the smoke particles.
function player_corruption_effect_create(_left, _top, _width, _height, _layer_id)
{
	// Jitter one puff per patch so the burst covers the whole cell instead of clustering at the avatar.
	var _count = max(0, floor(BALANCE_PLAYER_CORRUPTION_SMOKE_COUNT));
	var _columns = max(1, ceil(sqrt(_count)));
	var _rows = max(1, ceil(_count / _columns));
	var _patch_width = _width / _columns;
	var _patch_height = _height / _rows;
	for (var _index = 0; _index < _count; ++_index)
	{
		var _column = _index mod _columns;
		var _row = floor(_index / _columns);
		var _smoke_x = _left + (_column + random(1)) * _patch_width;
		var _smoke_y = _top + (_row + random(1)) * _patch_height;
		var _smoke = instance_create_layer(_smoke_x, _smoke_y, _layer_id, o_particle_smoke);
		if (instance_exists(_smoke))
		{
			_smoke.smoke_color = COLOR_PLAYER_CORRUPTION_SMOKE;
			_smoke.life_time = max(1, BALANCE_PLAYER_CORRUPTION_SMOKE_LIFETIME_SECONDS * room_speed);
		}
	}

	// Use the shared sound helper so the burst respects the player's volume setting.
	if (variable_global_exists("sound_play_random"))
	{
		global.sound_play_random([ui_hover_01, ui_hover_02]);
	}
}
