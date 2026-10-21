/// @description Places spaced random houses within each enemy territory.
function fight_living_houses_spawn()
{
	with (o_living_house) instance_destroy();
	if (!instance_exists(o_building_grid)) return;
	var _zones = o_building_grid.enemy_zones;
	var _counts = [BALANCE_ENEMY_ZONE_1_HOUSES, BALANCE_ENEMY_ZONE_2_HOUSES, BALANCE_ENEMY_ZONE_3_HOUSES];
	var _towers = [BALANCE_ENEMY_ZONE_1_TOWERS, BALANCE_ENEMY_ZONE_2_TOWERS, BALANCE_ENEMY_ZONE_3_TOWERS];
	var _margin = BALANCE_ENEMY_ZONE_BUILDING_MARGIN;
	for (var _zone_index = 0; _zone_index < array_length(_zones); ++_zone_index)
	{
		var _zone = _zones[_zone_index];
		for (var _i = 0; _i < _counts[_zone_index] + _towers[_zone_index]; ++_i)
		{
			var _type = _i < _counts[_zone_index] ? o_living_house : o_defense_tower;
			var _house = instance_create_layer(_zone.left, _zone.top, "Instances", _type);
			var _sprite = _house.sprite_index;
			var _left = _zone.left + sprite_get_xoffset(_sprite) + _margin;
			var _right = _zone.right - sprite_get_width(_sprite) + sprite_get_xoffset(_sprite) - _margin;
			var _top = _zone.top + sprite_get_yoffset(_sprite) + _margin;
			var _bottom = _zone.bottom - sprite_get_height(_sprite) + sprite_get_yoffset(_sprite) - _margin;
			var _best_score = -infinity;
			var _best_x = _left;
			var _best_y = _top;
			// Choose the best of several random candidates to avoid clustering.
			for (var _attempt = 0; _attempt < BALANCE_LIVING_HOUSE_PLACEMENT_ATTEMPTS; ++_attempt)
			{
				_house.x = random_range(_left, _right);
				_house.y = random_range(_top, _bottom);
				var _score = infinity;
				with (o_living_house)
				{
					if (id == _house) continue;
					var _gap_x = max(bbox_left - _house.bbox_right, _house.bbox_left - bbox_right);
					var _gap_y = max(bbox_top - _house.bbox_bottom, _house.bbox_top - bbox_bottom);
					_score = min(_score, max(_gap_x, _gap_y));
				}
				with (o_base_tower)
				{
					var _gap_x = max(bbox_left - _house.bbox_right, _house.bbox_left - bbox_right);
					var _gap_y = max(bbox_top - _house.bbox_bottom, _house.bbox_top - bbox_bottom);
					_score = min(_score, max(_gap_x, _gap_y));
				}
				if (_score > _best_score)
				{
					_best_score = _score;
					_best_x = _house.x;
					_best_y = _house.y;
				}
				if (_score >= BALANCE_ENEMY_ZONE_BUILDING_GAP) break;
			}
			_house.x = _best_x;
			_house.y = _best_y;
		}
	}
}
