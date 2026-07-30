// Initialize shared friendly unit state.
event_inherited();

// Skeleton Healer is a non-attacking support unit that follows and heals allies.
max_hp = BALANCE_SKELETON_HEALER_HP;
hp = max_hp;
armor = BALANCE_SKELETON_HEALER_ARMOR;
magic_resistance = BALANCE_SKELETON_HEALER_MAGIC_RESISTANCE;
damage = BALANCE_SKELETON_HEALER_DAMAGE;
magic_damage = BALANCE_SKELETON_HEALER_MAGIC_DAMAGE;
reload_time = BALANCE_SKELETON_HEALER_RELOAD_TIME * room_speed;
attack_radius = BALANCE_SKELETON_HEALER_ATTACK_RADIUS;
move_speed = BALANCE_SKELETON_HEALER_MOVE_SPEED;
bar_offset_y = -2;

support_heal_cooldown_timer = 0;

skeleton_healer_target_find = function(_max_distance = infinity)
{
	var _best_target = noone;
	var _lowest_health_ratio = 1;
	var _nearest_distance_squared = infinity;
	var _max_distance_squared = _max_distance * _max_distance;
	var _heal_candidates = [];

	// Assigned healers support only their squad, including Demon and Archdemon squads.
	if (is_struct(squad) && variable_struct_exists(squad, "units"))
	{
		array_copy(_heal_candidates, 0, squad.units, 0, array_length(squad.units));
	}
	else
	{
		// Independently spawned healers keep supporting all friendly units.
		var _friendly_count = instance_number(o_friendly_units);

		for (var _friendly_index = 0; _friendly_index < _friendly_count; ++_friendly_index)
		{
			array_push(_heal_candidates, instance_find(o_friendly_units, _friendly_index));
		}
	}

	// Select the most wounded living squad member and use distance to break equal-HP ties.
	var _candidate_count = array_length(_heal_candidates);

	for (var _candidate_index = 0; _candidate_index < _candidate_count; ++_candidate_index)
	{
		var _candidate = _heal_candidates[_candidate_index];

		if (!instance_exists(_candidate)
			|| _candidate == id
			|| !variable_instance_exists(_candidate, "hp")
			|| !variable_instance_exists(_candidate, "max_hp")
			|| !variable_instance_exists(_candidate, "support_heal_has_source")
			|| _candidate.max_hp <= 0
			|| _candidate.hp <= 0
			|| _candidate.hp >= _candidate.max_hp
			|| _candidate.support_heal_has_source(id))
		{
			continue;
		}

		// Automated arenas are isolated, so never heal a unit from another match.
		if (balance_test_match_id >= 0
			&& (!variable_instance_exists(_candidate, "balance_test_match_id")
				|| _candidate.balance_test_match_id != balance_test_match_id))
		{
			continue;
		}

		var _health_ratio = _candidate.hp / _candidate.max_hp;
		var _distance_x = _candidate.x - x;
		var _distance_y = _candidate.y - y;
		var _distance_squared = (_distance_x * _distance_x) + (_distance_y * _distance_y);
		var _has_lower_health = _health_ratio < _lowest_health_ratio;
		var _has_equal_health = _health_ratio == _lowest_health_ratio;

		if (_distance_squared <= _max_distance_squared
			&& (_has_lower_health || (_has_equal_health && _distance_squared < _nearest_distance_squared)))
		{
			_best_target = _candidate;
			_lowest_health_ratio = _health_ratio;
			_nearest_distance_squared = _distance_squared;
		}
	}

	return _best_target;
};

skeleton_healer_follow_target_find = function()
{
	var _nearest_target = noone;
	var _nearest_distance_squared = infinity;

	// Stay with the nearest living member of the assigned squad.
	if (is_struct(squad))
	{
		for (var _unit_index = 0; _unit_index < array_length(squad.units); ++_unit_index)
		{
			var _candidate = squad.units[_unit_index];

			if (!instance_exists(_candidate) || _candidate == id || _candidate.hp <= 0)
			{
				continue;
			}

			if (balance_test_match_id >= 0
				&& (!variable_instance_exists(_candidate, "balance_test_match_id")
					|| _candidate.balance_test_match_id != balance_test_match_id))
			{
				continue;
			}

			var _distance_x = _candidate.x - x;
			var _distance_y = _candidate.y - y;
			var _distance_squared = (_distance_x * _distance_x) + (_distance_y * _distance_y);

			if (_distance_squared < _nearest_distance_squared)
			{
				_nearest_target = _candidate;
				_nearest_distance_squared = _distance_squared;
			}
		}
	}

	if (instance_exists(_nearest_target))
	{
		return _nearest_target;
	}

	// Independently spawned healers follow the nearest living player unit.
	var _friendly_count = instance_number(o_friendly_units);

	for (var _friendly_index = 0; _friendly_index < _friendly_count; ++_friendly_index)
	{
		var _candidate = instance_find(o_friendly_units, _friendly_index);

		if (!instance_exists(_candidate) || _candidate == id || _candidate.hp <= 0)
		{
			continue;
		}

		if (balance_test_match_id >= 0
			&& (!variable_instance_exists(_candidate, "balance_test_match_id")
				|| _candidate.balance_test_match_id != balance_test_match_id))
		{
			continue;
		}

		var _distance_x = _candidate.x - x;
		var _distance_y = _candidate.y - y;
		var _distance_squared = (_distance_x * _distance_x) + (_distance_y * _distance_y);

		if (_distance_squared < _nearest_distance_squared)
		{
			_nearest_target = _candidate;
			_nearest_distance_squared = _distance_squared;
		}
	}

	return _nearest_target;
};

skeleton_healer_support_behavior_update = function()
{
	target_instance = noone;
	is_attacking_target = false;

	// Stay with an eligible nearby ally, or approach one when nobody is in range.
	var _follow_target = skeleton_healer_target_find(BALANCE_SKELETON_HEALER_HEAL_RADIUS);

	if (!instance_exists(_follow_target))
	{
		_follow_target = skeleton_healer_target_find();
	}

	if (!instance_exists(_follow_target))
	{
		_follow_target = skeleton_healer_follow_target_find();
	}

	if (!instance_exists(_follow_target))
	{
		is_walking = false;
		return true;
	}

	face_world_x(_follow_target.x);

	if (point_distance(x, y, _follow_target.x, _follow_target.y) > BALANCE_SKELETON_HEALER_FOLLOW_DISTANCE)
	{
		move_towards_target(_follow_target);
	}
	else
	{
		is_walking = false;
	}

	return true;
};

unit_special_behavior_update = function()
{
	return forced_retreat_update()
		|| panic_flee_update()
		|| skeleton_healer_support_behavior_update();
};
