// Inherit the parent event
event_inherited();
faction = FACTION.WILDLINGS;
// Catapults bombard hostile faction buildings with physical artillery projectiles.
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

// Keep the siege-only restriction in the shared validator so attack-move ignores units.
catapult_base_target_can_be_attacked = target_can_be_attacked;
target_can_be_attacked = function(_target)
{
	return faction_building_is_targetable(faction, _target)
		&& catapult_base_target_can_be_attacked(_target);
};

catapult_target_is_in_attack_band = function(_target)
{
	return target_can_be_attacked(_target)
		&& navigation_target_distance_get(_target) <= attack_radius;
};

catapult_target_find = function()
{
	var _nearest_target = noone;
	var _nearest_distance = attack_radius;
	var _building_groups = [o_map_objects_parent, o_v13buildings_parent];
	for (var _group = 0; _group < array_length(_building_groups); ++_group)
	{
		var _count = instance_number(_building_groups[_group]);
		for (var _index = 0; _index < _count; ++_index)
		{
			var _building = instance_find(_building_groups[_group], _index);
			if (!target_can_be_attacked(_building)) continue;
			var _distance = navigation_target_distance_get(_building);
			if (_distance <= _nearest_distance)
			{
				_nearest_target = _building;
				_nearest_distance = _distance;
			}
		}
	}
	return _nearest_target;
};

catapult_projectile_create = function(_target)
{
	if (!catapult_target_is_in_attack_band(_target))
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
	// Damage receivers still accept the legacy enum; allegiance uses the launch snapshot below.
	_projectile.damage_faction = UNIT_FACTION.NOONE;
	_projectile.faction = faction;
	_projectile.favor_source_faction = faction;
	_projectile.corruption_owner_initialized = true;
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
	if (!target_can_be_attacked(target_instance)
		|| catapult_target_search_timer >= target_search_update_interval)
	{
		catapult_target_search_timer = 0;
		var _nearby_building = catapult_target_find();
		if (instance_exists(_nearby_building)) target_instance = _nearby_building;
		else if (!target_can_be_attacked(target_instance)) target_instance = noone;
	}

	// Between encounters, AI siege squads advance toward their shared hostile building objective.
	if (!instance_exists(target_instance) && is_struct(squad) && !squad_is_player_owned(squad)
		&& target_can_be_attacked(squad.ai_target))
	{
		target_instance = squad.ai_target;
	}
	if (faction == global.player_faction && target_can_be_attacked(manual_structure_target))
	{
		target_instance = manual_structure_target;
	}

	is_attacking_target = false;
	is_walking = false;
	if (!target_can_be_attacked(target_instance)) return true;
	if (!catapult_target_is_in_attack_band(target_instance))
	{
		move_towards_target(target_instance, attack_radius);
		return true;
	}

	is_attacking_target = true;
	face_world_x(target_instance.x);
	if (reload_timer > 0)
	{
		reload_timer -= gameplay_time_scale;
		return true;
	}
	if (doom_bell_silence_is_active())
	{
		is_attacking_target = false;
		return true;
	}
	catapult_projectile_create(target_instance);
	reload_timer = reload_time * unit_attack_reload_multiplier_get();
	return true;
};

unit_special_behavior_update = function()
{
	return forced_retreat_update()
		|| panic_flee_update()
		|| catapult_behavior_update();
};
