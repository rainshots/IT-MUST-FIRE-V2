/// @description Updates friendly unit assault or Heart defense; unit context.
function cargo_unit_update()
{
	gameplay_time_scale = global.gameplay_time_scale;
	is_walking = false;
	is_attacking_target = false;
	if (cannon_loaded || is_being_dragged) return;
	cargo_launched = instance_exists(o_game_controller)
		&& o_game_controller.player_unit_mode == PLAYER_UNIT_MODE.ATTACK;
	var _home_x = BALANCE_BUILDING_GRID_CENTER_X;
	var _home_y = BALANCE_BUILDING_GRID_CENTER_Y;
	if (instance_exists(o_heart)) { _home_x = o_heart.x; _home_y = o_heart.y; }
	var _grid = building_grid_bounds_get();
	var _idle_x = _grid.right + BALANCE_BUILDING_GRID_CELL_SIZE;
	var _idle_y = _home_y + cargo_idle_offset_y;
	target_instance = noone;

	// A latched return prevents enemies from repeatedly interrupting the trip home.
	if (cargo_launched) defense_returning = false;
	else
	{
		var _home_distance = point_distance(x, y, _home_x, _home_y);
		if (_home_distance > BALANCE_UNIT_DEFENSE_LEASH) defense_returning = true;
		if (defense_returning && point_distance(x, y, _idle_x, _idle_y) <= BALANCE_UNIT_IDLE_STOP_DISTANCE) defense_returning = false;
		if (defense_returning)
		{
			alert_target = noone;
			alert_target_timer = 0;
			move_towards_world_point(_idle_x, _idle_y);
			update_walk_sway();
			return;
		}
	}

	// Attack nearby enemies en route; defenders only engage threats inside the Heart perimeter.
	var _nearest = infinity;
	var _count = instance_number(o_enemy_units);
	for (var _i = 0; _i < _count; ++_i)
	{
		var _candidate = instance_find(o_enemy_units, _i);
		if (!target_can_be_attacked(_candidate)) continue;
		var _distance = point_distance(x, y, _candidate.x, _candidate.y);
		var _eligible = cargo_launched ? _distance <= vision_radius
			: point_distance(_home_x, _home_y, _candidate.x, _candidate.y) <= BALANCE_CARGO_DEFENSE_RADIUS;
		if (_eligible && _distance < _nearest)
		{
			target_instance = _candidate;
			_nearest = _distance;
		}
	}
	// Retaliate against ranged attackers outside the normal defense perimeter.
	// The latched return above still takes priority when a unit strays too far.
	if (!cargo_launched && target_can_be_attacked(alert_target))
		target_instance = alert_target;
	if (cargo_launched)
	{
		with (o_living_house)
		{
			if (!other.target_can_be_attacked(id)) continue;
			var _distance = point_distance(other.x, other.y, x, y);
			if (_distance <= other.vision_radius && _distance < _nearest)
			{
				other.target_instance = id;
				_nearest = _distance;
			}
		}
		// The objective wins when closest, including ties, and remains the fallback destination.
		if (instance_exists(o_base_tower))
		{
			var _tower = instance_nearest(x, y, o_base_tower);
			if (target_can_be_attacked(_tower)
				&& point_distance(x, y, _tower.x, _tower.y) <= _nearest) target_instance = _tower;
		}
	}
	if (instance_exists(target_instance))
	{
		if (point_distance(x, y, target_instance.x, target_instance.y) <= attack_radius)
		{
			is_attacking_target = true;
			attack_target(target_instance);
		}
		else move_towards_target(target_instance);
	}
	else if (!cargo_launched && point_distance(x, y, _idle_x, _idle_y) > BALANCE_UNIT_IDLE_STOP_DISTANCE)
	{
		move_towards_world_point(_idle_x, _idle_y);
	}
	update_walk_sway();
}
