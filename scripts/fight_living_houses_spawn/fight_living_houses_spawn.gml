/// @description Creates twenty passive reward buildings in a random disk around the Base Tower.
function fight_living_houses_spawn()
{
	with (o_living_house) instance_destroy();
	if (!instance_exists(o_base_tower)) return;
	var _tower = instance_find(o_base_tower, 0);
	for (var _i = 0; _i < BALANCE_LIVING_HOUSE_COUNT; ++_i)
	{
		var _house = instance_create_layer(_tower.x, _tower.y, "Instances", o_living_house);
		for (var _attempt = 0; _attempt < BALANCE_LIVING_HOUSE_PLACEMENT_ATTEMPTS; ++_attempt)
		{
			var _angle = random(360);
			var _radius = sqrt(random(1)) * BALANCE_LIVING_HOUSE_SPAWN_RADIUS;
			_house.x = _tower.x + lengthdir_x(_radius, _angle);
			_house.y = _tower.y + lengthdir_y(_radius, _angle);
			var _overlap = false;
			with (o_living_house)
			{
				if (id == _house) continue;
				if (bbox_left < _house.bbox_right && bbox_right > _house.bbox_left && bbox_top < _house.bbox_bottom && bbox_bottom > _house.bbox_top) _overlap = true;
			}
			if (_house.bbox_left < _tower.bbox_right && _house.bbox_right > _tower.bbox_left
				&& _house.bbox_top < _tower.bbox_bottom && _house.bbox_bottom > _tower.bbox_top) _overlap = true;
			if (!_overlap) break;
		}
	}
}
