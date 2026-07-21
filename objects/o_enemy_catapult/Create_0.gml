// Initialize shared enemy unit state.
event_inherited();

// Catapult attacks player troops with physical AOE projectiles.
max_hp = BALANCE_ENEMY_CATAPULT_HP;
hp = max_hp;
armor = BALANCE_ENEMY_CATAPULT_ARMOR;
magic_resistance = BALANCE_ENEMY_CATAPULT_MAGIC_RESISTANCE;
damage = BALANCE_ENEMY_CATAPULT_DAMAGE;
magic_damage = BALANCE_ENEMY_CATAPULT_MAGIC_DAMAGE;
reload_time = BALANCE_ENEMY_CATAPULT_RELOAD_TIME * room_speed;
attack_radius = BALANCE_ENEMY_CATAPULT_ATTACK_RADIUS;
move_speed = BALANCE_ENEMY_CATAPULT_MOVE_SPEED;
target_detection_radius = attack_radius;
vision_radius = attack_radius;

catapult_minimum_attack_radius = BALANCE_ENEMY_CATAPULT_MINIMUM_ATTACK_RADIUS;
catapult_projectile_aoe_radius = BALANCE_ENEMY_CATAPULT_PROJECTILE_AOE_RADIUS;
catapult_projectile_target_count = BALANCE_ENEMY_CATAPULT_TARGET_COUNT;
catapult_projectile_spawn_offset_y = BALANCE_ENEMY_CATAPULT_PROJECTILE_SPAWN_OFFSET_Y;
catapult_projectile_layer_name = "Instances";
catapult_projectile_draw_depth = BALANCE_PARTICLE_SYSTEM_TOP_DEPTH - 50;
catapult_target_search_timer = target_search_update_interval;

catapult_target_is_in_attack_band = function(_target)
{
	if (!target_can_be_attacked(_target) || !target_is_player_unit(_target))
	{
		return false;
	}

	var _target_distance = point_distance(x, y, _target.x, _target.y);
	return _target_distance >= catapult_minimum_attack_radius
		&& _target_distance <= attack_radius;
};

catapult_target_find = function()
{
	var _nearest_target = noone;
	var _nearest_distance_squared = attack_radius * attack_radius;
	var _minimum_distance_squared = catapult_minimum_attack_radius * catapult_minimum_attack_radius;
	var _friendly_count = instance_number(o_friendly_units);

	// Find the nearest friendly combat unit outside the catapult dead zone.
	for (var _friendly_index = 0; _friendly_index < _friendly_count; ++_friendly_index)
	{
		var _friendly_unit = instance_find(o_friendly_units, _friendly_index);

		if (!target_can_be_attacked(_friendly_unit))
		{
			continue;
		}

		var _distance_x = _friendly_unit.x - x;
		var _distance_y = _friendly_unit.y - y;
		var _distance_squared = (_distance_x * _distance_x) + (_distance_y * _distance_y);

		if (_distance_squared >= _minimum_distance_squared
			&& _distance_squared <= _nearest_distance_squared)
		{
			_nearest_target = _friendly_unit;
			_nearest_distance_squared = _distance_squared;
		}
	}

	if (!variable_global_exists("archdemons"))
	{
		return _nearest_target;
	}

	// Archdemons are player units but do not inherit from o_friendly_units.
	for (var _cultist_index = 0; _cultist_index < array_length(global.archdemons); ++_cultist_index)
	{
		var _cultist = global.archdemons[_cultist_index];

		if (!target_can_be_attacked(_cultist) || !_cultist.visible)
		{
			continue;
		}

		var _cultist_distance_x = _cultist.x - x;
		var _cultist_distance_y = _cultist.y - y;
		var _cultist_distance_squared = (_cultist_distance_x * _cultist_distance_x)
			+ (_cultist_distance_y * _cultist_distance_y);

		if (_cultist_distance_squared >= _minimum_distance_squared
			&& _cultist_distance_squared <= _nearest_distance_squared)
		{
			_nearest_target = _cultist;
			_nearest_distance_squared = _cultist_distance_squared;
		}
	}

	return _nearest_target;
};

catapult_projectile_create = function(_target_x, _target_y)
{
	var _projectile_x = x;
	var _projectile_y = y + catapult_projectile_spawn_offset_y;
	var _projectile = instance_create_layer(_projectile_x, _projectile_y, catapult_projectile_layer_name, o_projectile);
	var _projectile_distance = point_distance(_projectile_x, _projectile_y, _target_x, _target_y);
	var _flight_time_seconds = clamp(
		_projectile_distance / BALANCE_ENEMY_CATAPULT_PROJECTILE_SPEED,
		_projectile.minimum_flight_time,
		_projectile.maximum_flight_time
	);

	_projectile.start_x = _projectile_x;
	_projectile.start_y = _projectile_y;
	_projectile.target_x = _target_x;
	_projectile.target_y = _target_y;
	_projectile.projectile_type = PROJECTILE_TYPE.ARTILLERY;
	_projectile.effect_radius = catapult_projectile_aoe_radius;
	_projectile.damage_amount = damage;
	_projectile.damage_faction = UNIT_FACTION.ENEMY;
	_projectile.damage_target_count = catapult_projectile_target_count;
	_projectile.source_instance = id;
	_projectile.projectile_speed = BALANCE_ENEMY_CATAPULT_PROJECTILE_SPEED;
	_projectile.flight_time = _flight_time_seconds * room_speed;
	_projectile.depth = catapult_projectile_draw_depth;

	return _projectile;
};

catapult_behavior_update = function()
{
	catapult_target_search_timer++;

	if (!catapult_target_is_in_attack_band(target_instance)
		|| catapult_target_search_timer >= target_search_update_interval)
	{
		catapult_target_search_timer = 0;
		target_instance = catapult_target_find();
	}

	if (instance_exists(target_instance))
	{
		is_walking = false;
		face_world_x(target_instance.x);

		if (reload_timer > 0)
		{
			reload_timer--;
			return true;
		}

		catapult_projectile_create(target_instance.x, target_instance.y);
		reload_timer = reload_time * unit_attack_reload_multiplier_get();
		return true;
	}

	// With no valid target, continue advancing toward the player's cannon.
	if (instance_exists(o_cannon))
	{
		move_towards_target(instance_find(o_cannon, 0));
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
		|| catapult_behavior_update();
};
