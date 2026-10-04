/// @description In a unit context, attacks or approaches the first destructible wall toward a movement goal; returns whether it handled movement.
/// @param {real} goal_x Movement goal world X.
/// @param {real} goal_y Movement goal world Y.
function unit_path_wall_attack(_goal_x, _goal_y)
{
	if (!instance_exists(o_destructable_wall) || damage + magic_damage <= 0)
	{
		return false;
	}

	// Limit the query to the next movement segment and choose the nearest obstruction.
	var _goal_distance = point_distance(x, y, _goal_x, _goal_y);
	var _query_distance = min(_goal_distance, max(attack_radius, BALANCE_ARMY_UNIT_MARCH_LOOKAHEAD));
	var _direction = point_direction(x, y, _goal_x, _goal_y);
	var _walls = ds_list_create();
	var _wall_count = collision_line_list(x, y,
		x + lengthdir_x(_query_distance, _direction),
		y + lengthdir_y(_query_distance, _direction),
		o_wall_parent, false, true, _walls, false);
	var _blocking_wall = noone;
	var _nearest_distance = _query_distance + 1;
	for (var _wall_index = 0; _wall_index < _wall_count; ++_wall_index)
	{
		var _wall = _walls[| _wall_index];
		if (instance_exists(_wall))
		{
			var _distance = _wall.wall_distance_to_point(x, y);
			if (_distance < _nearest_distance)
			{
				_nearest_distance = _distance;
				_blocking_wall = _wall;
			}
		}
	}
	ds_list_destroy(_walls);

	// Mountains and other permanent obstacles still use ordinary pathfinding.
	if (!instance_exists(_blocking_wall)
		|| _blocking_wall.object_index != o_destructable_wall
		|| !target_can_be_attacked(_blocking_wall))
	{
		return false;
	}

	// Use normal attack timing and damage; retain the original movement goal afterwards.
	is_walking = false;
	is_attacking_target = _nearest_distance <= attack_radius;
	if (is_attacking_target)
	{
		attack_target(_blocking_wall);
	}
	else
	{
		move_towards_target(_blocking_wall);
	}
	return true;
}
