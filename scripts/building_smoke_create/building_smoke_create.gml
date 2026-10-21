/// @description Emits one medium smoke cloud per occupied slot over the displayed building sprite.
function building_smoke_create(_building)
{
	if (!instance_exists(_building)) return;
	var _bounds = building_bounds_get(_building, _building.x, _building.y);
	var _width = _bounds.right - _bounds.left;
	var _height = _bounds.bottom - _bounds.top;
	if (sprite_exists(_building.sprite_index))
	{
		var _sprite = _building.sprite_index;
		var _scale = min(_width / sprite_get_width(_sprite), _height / sprite_get_height(_sprite));
		_width = sprite_get_width(_sprite) * _scale;
		_height = sprite_get_height(_sprite) * _scale;
	}
	var _count = _building.grid_columns * _building.grid_rows;
	for (var _i = 0; _i < _count; ++_i)
	{
		var _smoke = instance_create_layer(_building.x + random_range(-_width * 0.5, _width * 0.5),
			_building.y + random_range(-_height * 0.5, _height * 0.5), "Instances", o_particle_smoke);
		_smoke.start_scale = BALANCE_BUILDING_SMOKE_SIZE / max(1, sprite_get_width(_smoke.sprite_index));
		_smoke.current_scale = _smoke.start_scale;
		_smoke.end_scale = _smoke.start_scale * BALANCE_BUILDING_SMOKE_GROWTH;
		_smoke.ignore_pause = true;
		_smoke.y_sort_enabled = false;
		_smoke.depth = BALANCE_BUILDING_GRID_ACTOR_DEPTH - room_height;
	}
}
