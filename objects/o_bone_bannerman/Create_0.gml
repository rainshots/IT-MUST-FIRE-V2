// Initialize shared friendly unit state and squad behavior.
event_inherited();

// Bone Bannerman is a non-attacking support unit that follows nearby allies.
max_hp = BALANCE_BONE_BANNERMAN_HP;
hp = max_hp;
armor = BALANCE_BONE_BANNERMAN_ARMOR;
magic_resistance = BALANCE_BONE_BANNERMAN_MAGIC_RESISTANCE;
damage = BALANCE_BONE_BANNERMAN_DAMAGE;
magic_damage = BALANCE_BONE_BANNERMAN_MAGIC_DAMAGE;
reload_time = BALANCE_BONE_BANNERMAN_RELOAD_TIME * room_speed;
attack_radius = BALANCE_BONE_BANNERMAN_ATTACK_RADIUS;
move_speed = BALANCE_BONE_BANNERMAN_MOVE_SPEED;
target_detection_radius = 0;
vision_radius = 0;
bar_offset_y = -2;
image_speed = 0;

bone_bannerman_aura_update_interval = max(
	1,
	round(BALANCE_BONE_BANNERMAN_AURA_UPDATE_TIME * room_speed)
);
bone_bannerman_aura_update_timer = irandom(bone_bannerman_aura_update_interval - 1);

bone_bannerman_follow_target_find = function()
{
	var _nearest_target = noone;
	var _nearest_distance_squared = infinity;
	var _has_assigned_squad = is_struct(squad)
		&& variable_struct_exists(squad, "units");

	// Assigned Bannermen stay with the nearest living member of their own squad.
	if (_has_assigned_squad)
	{
		var _squad_unit_count = array_length(squad.units);

		for (var _unit_index = 0; _unit_index < _squad_unit_count; ++_unit_index)
		{
			var _candidate = squad.units[_unit_index];

			if (!instance_exists(_candidate)
				|| _candidate == id
				|| !variable_instance_exists(_candidate, "hp")
				|| _candidate.hp <= 0)
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
	}

	// Independently spawned Bannermen follow the nearest living player unit.
	var _friendly_count = instance_number(o_friendly_units);

	for (var _friendly_index = 0; _friendly_index < _friendly_count; ++_friendly_index)
	{
		var _candidate = instance_find(o_friendly_units, _friendly_index);

		if (!instance_exists(_candidate)
			|| _candidate == id
			|| !variable_instance_exists(_candidate, "hp")
			|| _candidate.hp <= 0)
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

bone_bannerman_support_behavior_update = function()
{
	target_instance = noone;
	alert_target = noone;
	is_attacking_target = false;

	var _follow_target = bone_bannerman_follow_target_find();

	if (!instance_exists(_follow_target))
	{
		is_walking = false;
		return true;
	}

	face_world_x(_follow_target.x);

	if (point_distance(x, y, _follow_target.x, _follow_target.y) > BALANCE_BONE_BANNERMAN_FOLLOW_DISTANCE)
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
		|| bone_bannerman_support_behavior_update();
};

// Every damaging enemy hit restarts the requested 2.5-second retreat.
unit_damage_received = function(_source_instance, _source_faction, _applied_damage)
{
	if (_applied_damage <= 0
		|| hp <= 0
		|| _source_faction != UNIT_FACTION.ENEMY
		|| !instance_exists(_source_instance))
	{
		return;
	}

	panic_flee_source = _source_instance;
	panic_flee_timer = max(1, BALANCE_BONE_BANNERMAN_FLEE_DURATION * room_speed);
	panic_flee_cooldown_timer = 0;
	panic_flee_speed_multiplier = BALANCE_BONE_BANNERMAN_FLEE_SPEED_MULTIPLIER;
	target_instance = noone;
	alert_target = noone;
	forced_attack_target = noone;
	is_attacking_target = false;
	is_walking = false;
};
