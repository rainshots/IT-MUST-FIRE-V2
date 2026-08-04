// Initialize shared friendly unit state.
event_inherited();

// Demon Wizard is a non-attacking support unit that follows and buffs allies.
max_hp = BALANCE_DEMON_WIZARD_HP;
hp = max_hp;
armor = BALANCE_DEMON_WIZARD_ARMOR;
magic_resistance = BALANCE_DEMON_WIZARD_MAGIC_RESISTANCE;
damage = BALANCE_DEMON_WIZARD_DAMAGE;
magic_damage = BALANCE_DEMON_WIZARD_MAGIC_DAMAGE;
reload_time = BALANCE_DEMON_WIZARD_RELOAD_TIME * room_speed;
attack_radius = BALANCE_DEMON_WIZARD_ATTACK_RADIUS;
move_speed = BALANCE_DEMON_WIZARD_MOVE_SPEED;
bar_offset_y = -2;

support_buff_cooldown_timer = 0;

demon_wizard_target_has_active_wizard_buff = function(_target)
{
	if (!instance_exists(_target)
		|| !variable_instance_exists(_target, "support_buff_effects"))
	{
		return false;
	}

	for (var _buff_index = 0; _buff_index < array_length(_target.support_buff_effects); ++_buff_index)
	{
		var _buff_source = _target.support_buff_effects[_buff_index].source;

		if (instance_exists(_buff_source) && _buff_source.object_index == o_demon_wizard)
		{
			return true;
		}
	}

	return false;
};

demon_wizard_buff_target_find = function(_max_distance = infinity)
{
	var _nearest_target = noone;
	var _nearest_distance_squared = infinity;
	var _max_distance_squared = _max_distance * _max_distance;
	var _has_assigned_squad = is_struct(squad)
		&& variable_struct_exists(squad, "units");

	// Prefer the nearest unbuffed squad member who is actively attacking.
	if (_has_assigned_squad)
	{
		var _squad_unit_count = array_length(squad.units);

		for (var _unit_index = 0; _unit_index < _squad_unit_count; ++_unit_index)
		{
			var _candidate = squad.units[_unit_index];

			if (!instance_exists(_candidate)
				|| _candidate == id
				|| !variable_instance_exists(_candidate, "hp")
				|| !variable_instance_exists(_candidate, "is_attacking_target")
				|| !variable_instance_exists(_candidate, "support_buff_has_source")
				|| _candidate.hp <= 0
				|| !_candidate.is_attacking_target
				|| demon_wizard_target_has_active_wizard_buff(_candidate))
			{
				continue;
			}

			// Automated arenas are isolated, so never buff a unit from another match.
			if (balance_test_match_id >= 0
				&& (!variable_instance_exists(_candidate, "balance_test_match_id")
					|| _candidate.balance_test_match_id != balance_test_match_id))
			{
				continue;
			}

			var _distance_x = _candidate.x - x;
			var _distance_y = _candidate.y - y;
			var _distance_squared = (_distance_x * _distance_x) + (_distance_y * _distance_y);

			if (_distance_squared <= _max_distance_squared
				&& _distance_squared < _nearest_distance_squared)
			{
				_nearest_target = _candidate;
				_nearest_distance_squared = _distance_squared;
			}
		}
	}

	// Assigned Wizards never buff units outside their squad.
	if (_has_assigned_squad)
	{
		return _nearest_target;
	}

	// Wizards without a squad use the nearest unbuffed player unit who is actively attacking.
	var _friendly_count = instance_number(o_friendly_units);

	for (var _friendly_index = 0; _friendly_index < _friendly_count; ++_friendly_index)
	{
		var _candidate = instance_find(o_friendly_units, _friendly_index);

		if (!instance_exists(_candidate)
			|| _candidate == id
			|| !variable_instance_exists(_candidate, "hp")
			|| !variable_instance_exists(_candidate, "is_attacking_target")
			|| !variable_instance_exists(_candidate, "support_buff_has_source")
			|| _candidate.hp <= 0
			|| !_candidate.is_attacking_target
			|| demon_wizard_target_has_active_wizard_buff(_candidate))
		{
			continue;
		}

		// Automated arenas are isolated, so never buff a unit from another match.
		if (balance_test_match_id >= 0
			&& (!variable_instance_exists(_candidate, "balance_test_match_id")
				|| _candidate.balance_test_match_id != balance_test_match_id))
		{
			continue;
		}

		var _distance_x = _candidate.x - x;
		var _distance_y = _candidate.y - y;
		var _distance_squared = (_distance_x * _distance_x) + (_distance_y * _distance_y);

		if (_distance_squared <= _max_distance_squared
			&& _distance_squared < _nearest_distance_squared)
		{
			_nearest_target = _candidate;
			_nearest_distance_squared = _distance_squared;
		}
	}

	return _nearest_target;
};

demon_wizard_follow_target_find = function(_combat_only = false)
{
	var _nearest_target = noone;
	var _nearest_distance_squared = infinity;

	// Stay with the nearest living member of the assigned squad.
	if (is_struct(squad))
	{
		for (var _unit_index = 0; _unit_index < array_length(squad.units); ++_unit_index)
		{
			var _candidate = squad.units[_unit_index];

			if (!instance_exists(_candidate)
				|| _candidate == id
				|| _candidate.hp <= 0
				|| (_combat_only
					&& (!variable_instance_exists(_candidate, "is_attacking_target")
						|| !_candidate.is_attacking_target)))
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

	// Cheat-spawned Wizards without a squad follow the nearest living player unit.
	var _friendly_count = instance_number(o_friendly_units);

	for (var _friendly_index = 0; _friendly_index < _friendly_count; ++_friendly_index)
	{
		var _candidate = instance_find(o_friendly_units, _friendly_index);

		if (!instance_exists(_candidate)
			|| _candidate == id
			|| _candidate.hp <= 0
			|| (_combat_only
				&& (!variable_instance_exists(_candidate, "is_attacking_target")
					|| !_candidate.is_attacking_target)))
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

demon_wizard_support_behavior_update = function()
{
	target_instance = noone;
	is_attacking_target = false;

	// Approach an active unbuffed fighter, then fall back to following the squad without casting.
	var _follow_target = demon_wizard_buff_target_find(BALANCE_DEMON_WIZARD_BUFF_RADIUS);

	if (!instance_exists(_follow_target))
	{
		_follow_target = demon_wizard_buff_target_find();
	}

	if (!instance_exists(_follow_target))
	{
		_follow_target = demon_wizard_follow_target_find(true);
	}

	if (!instance_exists(_follow_target))
	{
		_follow_target = demon_wizard_follow_target_find();
	}

	if (!instance_exists(_follow_target))
	{
		is_walking = false;
		return true;
	}

	face_world_x(_follow_target.x);

	if (point_distance(x, y, _follow_target.x, _follow_target.y) > BALANCE_DEMON_WIZARD_FOLLOW_DISTANCE)
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
		|| demon_wizard_support_behavior_update();
};
