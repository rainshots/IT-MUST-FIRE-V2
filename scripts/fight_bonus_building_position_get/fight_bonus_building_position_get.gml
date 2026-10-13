/// @description Finds a free in-room building footprint at least 200px left of the Cannon.
function fight_bonus_building_position_get(_object)
{
	if (!instance_exists(o_cannon)) return undefined;
	var _sprite = object_get_sprite(_object);
	var _width = sprite_get_width(_sprite);
	var _height = sprite_get_height(_sprite);
	var _origin_x = sprite_get_xoffset(_sprite);
	var _origin_y = sprite_get_yoffset(_sprite);
	var _occupied = [];
	// Full sprite bounds prevent visible overlaps, including differently scaled buildings.
	with (all)
	{
		var _building = object_index == o_cannon || object_index == o_base_tower
			|| object_is_ancestor(object_index, o_worker_building_parent)
			|| object_is_ancestor(object_index, o_map_objects_parent)
			|| object_is_ancestor(object_index, o_v13buildings_parent);
		if (_building && sprite_index != -1)
		{
			var _left = x - sprite_get_xoffset(sprite_index) * image_xscale;
			var _top = y - sprite_get_yoffset(sprite_index) * image_yscale;
			array_push(_occupied, {left: min(_left, bbox_left), top: min(_top, bbox_top),
				right: max(_left + sprite_get_width(sprite_index) * image_xscale, bbox_right),
				bottom: max(_top + sprite_get_height(sprite_index) * image_yscale, bbox_bottom) + BALANCE_BONUS_BUILDING_WORKER_SPACE});
		}
	}
	var _step = BALANCE_BONUS_BUILDING_GRID;
	var _columns = ceil(room_width / _step);
	var _rows = ceil(room_height / _step) * 2;
	var _padding = BALANCE_BONUS_BUILDING_PADDING;
	for (var _column = 0; _column < _columns; ++_column)
	{
		var _right = o_cannon.x - BALANCE_BONUS_BUILDING_MIN_DISTANCE - _column * _step;
		var _left = _right - _width;
		if (_left < 0) break;
		for (var _row = 0; _row < _rows; ++_row)
		{
			var _offset = ceil(_row * 0.5) * (_row mod 2 == 0 ? -1 : 1) * _step;
			var _top = o_cannon.y + _offset - _origin_y;
			var _bottom = _top + _height + BALANCE_BONUS_BUILDING_WORKER_SPACE;
			if (_top < 0 || _bottom > room_height) continue;
			var _free = true;
			for (var _index = 0; _index < array_length(_occupied); ++_index)
			{
				var _rect = _occupied[_index];
				if (_left - _padding < _rect.right && _right + _padding > _rect.left
					&& _top - _padding < _rect.bottom && _bottom + _padding > _rect.top)
				{
					_free = false;
					break;
				}
			}
			if (_free) return {x: _left + _origin_x, y: _top + _origin_y};
		}
	}
	return undefined;
}
