// Initialize shared enemy unit state.
event_inherited();

// Catapult exclusively attacks player structures with physical artillery projectiles.
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

catapult_projectile_aoe_radius = BALANCE_ENEMY_CATAPULT_PROJECTILE_AOE_RADIUS;
catapult_projectile_target_count = BALANCE_ENEMY_CATAPULT_TARGET_COUNT;
catapult_projectile_spawn_offset_y = BALANCE_ENEMY_CATAPULT_PROJECTILE_SPAWN_OFFSET_Y;
catapult_projectile_layer_name = "Instances";
catapult_projectile_draw_depth = BALANCE_PARTICLE_SYSTEM_TOP_DEPTH - 50;
catapult_target_search_timer = target_search_update_interval;

catapult_target_is_in_attack_band = function(_target)
{
	if (!target_can_be_attacked(_target))
	{
		return false;
	}

	if (_target.object_index == o_cannon)
	{
		return unit_can_attack_cannon
			&& navigation_target_distance_get(_target) <= attack_radius;
	}

	return player_structure_can_be_targeted(_target)
		&& navigation_target_distance_get(_target) <= attack_radius;
};

catapult_target_find = function()
{
	var _nearest_target = noone;
	var _nearest_target_distance = attack_radius;
	var _map_structure_count = instance_number(o_map_objects_parent);

	// Captured towers and shell-built field structures are valid artillery targets.
	for (var _structure_index = 0; _structure_index < _map_structure_count; ++_structure_index)
	{
		var _structure = instance_find(o_map_objects_parent, _structure_index);

		if (!player_map_structure_can_be_targeted(_structure))
		{
			continue;
		}

		var _structure_distance = navigation_target_distance_get(_structure);

		if (_structure_distance <= _nearest_target_distance)
		{
			_nearest_target = _structure;
			_nearest_target_distance = _structure_distance;
		}
	}

	var _settlement_building_count = instance_number(o_v13buildings_parent);

	// Settlement production buildings use their combat footprint for range checks.
	for (var _building_index = 0; _building_index < _settlement_building_count; ++_building_index)
	{
		var _building = instance_find(o_v13buildings_parent, _building_index);

		if (!player_settlement_building_can_be_targeted(_building))
		{
			continue;
		}

		var _building_distance = navigation_target_distance_get(_building);

		if (_building_distance <= _nearest_target_distance)
		{
			_nearest_target = _building;
			_nearest_target_distance = _building_distance;
		}
	}

	// The cannon participates in the same nearest-structure selection.
	if (unit_can_attack_cannon && instance_exists(o_cannon))
	{
		var _cannon = instance_find(o_cannon, 0);

		if (target_can_be_attacked(_cannon))
		{
			var _cannon_distance = navigation_target_distance_get(_cannon);

			if (_cannon_distance <= _nearest_target_distance)
			{
				_nearest_target = _cannon;
			}
		}
	}

	return _nearest_target;
};

catapult_projectile_create = function(_target)
{
	if (!instance_exists(_target))
	{
		return noone;
	}

	var _target_x = _target.x;
	var _target_y = _target.y;
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
	_projectile.artillery_direct_target = _target;
	_projectile.artillery_can_damage_units = false;
	_projectile.balance_test_match_id = balance_test_match_id;
	_projectile.projectile_speed = BALANCE_ENEMY_CATAPULT_PROJECTILE_SPEED;
	_projectile.flight_time = _flight_time_seconds * room_speed;
	_projectile.depth = catapult_projectile_draw_depth;

	return _projectile;
};

catapult_behavior_update = function()
{
	catapult_target_search_timer += gameplay_time_scale;

	if (!catapult_target_is_in_attack_band(target_instance)
		|| catapult_target_search_timer >= target_search_update_interval)
	{
		catapult_target_search_timer = 0;
		target_instance = catapult_target_find();
	}

	if (instance_exists(target_instance))
	{
		is_walking = false;
		is_attacking_target = true;
		face_world_x(target_instance.x);

		if (reload_timer > 0)
		{
			reload_timer -= gameplay_time_scale;
			return true;
		}

		catapult_projectile_create(target_instance);
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
