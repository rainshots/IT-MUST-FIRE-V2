// Reuse shared friendly-unit combat, navigation, status, and damage behavior.
event_inherited();
image_yscale = 1.5
image_xscale = image_yscale;

// Orc combat stats.
max_hp = BALANCE_ORC2_MAX_HP;
hp = max_hp;
move_speed = BALANCE_ORC2_MOVE_SPEED;
armor = BALANCE_ORC2_ARMOR;
magic_resistance = BALANCE_ORC2_MAGIC_RESISTANCE;
reload_time = BALANCE_ORC2_RELOAD_TIME * room_speed;
reload_timer = 0;
damage = BALANCE_ORC2_PHYSICAL_DAMAGE;
magic_damage = 0;
attack_radius = BALANCE_ORC2_ATTACK_RADIUS;
vision_radius = BALANCE_ORCS_PIT_DEFENSE_RADIUS;
target_detection_radius = vision_radius;

// Habitat ownership keeps this unit outside squads, dragging, Cannon shots, and Rally movement.
owner_habitat = noone;
habitat_bound_unit = true;
habitat_slot_index = -1;
habitat_home_offset_x = 0;
habitat_home_offset_y = 0;
habitat_home_x = x;
habitat_home_y = y;
habitat_defense_radius = BALANCE_ORCS_PIT_DEFENSE_RADIUS;
habitat_return_delay = BALANCE_ORCS_PIT_RETURN_DELAY * room_speed;
habitat_no_enemy_timer = 0;
habitat_return_radius = BALANCE_ORCS_PIT_RETURN_RADIUS;
habitat_target_search_interval = BALANCE_UNIT_TARGET_SEARCH_UPDATE_INTERVAL;
habitat_target_search_timer = habitat_target_search_interval;
habitat_retaliation_target = noone;
friendly_guard_cannon_enabled = false;
regroup_is_active = false;
rally_is_active = false;

habitat_home_position_update = function()
{
	if (!instance_exists(owner_habitat))
	{
		return false;
	}

	habitat_home_x = owner_habitat.x + habitat_home_offset_x;
	habitat_home_y = owner_habitat.y + habitat_home_offset_y;
	return true;
};

habitat_enemy_is_inside_defense_radius = function(_enemy)
{
	if (!instance_exists(owner_habitat) || !target_can_be_attacked(_enemy))
	{
		return false;
	}

	var _distance_x = _enemy.x - owner_habitat.x;
	var _distance_y = _enemy.y - owner_habitat.y;
	var _distance_squared = (_distance_x * _distance_x) + (_distance_y * _distance_y);
	var _radius_squared = habitat_defense_radius * habitat_defense_radius;

	return _distance_squared <= _radius_squared;
};

habitat_enemy_target_find = function()
{
	var _nearest_enemy = noone;
	var _nearest_distance_squared = infinity;
	var _enemy_count = instance_number(o_enemy_units);

	// Select the closest valid enemy whose position remains inside the habitat territory.
	for (var _enemy_index = 0; _enemy_index < _enemy_count; ++_enemy_index)
	{
		var _enemy = instance_find(o_enemy_units, _enemy_index);

		if (!habitat_enemy_is_inside_defense_radius(_enemy))
		{
			continue;
		}

		var _distance_x = _enemy.x - x;
		var _distance_y = _enemy.y - y;
		var _distance_squared = (_distance_x * _distance_x) + (_distance_y * _distance_y);

		if (_distance_squared < _nearest_distance_squared)
		{
			_nearest_enemy = _enemy;
			_nearest_distance_squared = _distance_squared;
		}
	}

	return _nearest_enemy;
};

habitat_retaliation_target_update = function()
{
	// Shared damage alerts let an idle Orc and its nearby ally remember the attacker.
	if (target_can_be_attacked(alert_target))
	{
		habitat_retaliation_target = alert_target;
	}

	if (!target_can_be_attacked(habitat_retaliation_target))
	{
		habitat_retaliation_target = noone;
	}

	return habitat_retaliation_target;
};

habitat_combat_update = function()
{
	if (!habitat_home_position_update())
	{
		instance_destroy();
		return true;
	}

	// Player movement commands never override this habitat-bound behavior.
	regroup_is_active = false;
	rally_is_active = false;
	rally_is_returning = false;
	rally_has_arrived = false;

	var _retaliation_target = habitat_retaliation_target_update();
	var _target_is_valid = false;
	habitat_target_search_timer += gameplay_time_scale;

	// Retaliation takes priority over the normal habitat-radius target search.
	if (instance_exists(_retaliation_target))
	{
		target_instance = _retaliation_target;
		_target_is_valid = true;
	}
	else
	{
		_target_is_valid = habitat_enemy_is_inside_defense_radius(target_instance);

		if (!_target_is_valid || habitat_target_search_timer >= habitat_target_search_interval)
		{
			target_instance = habitat_enemy_target_find();
			habitat_target_search_timer = 0;
			_target_is_valid = instance_exists(target_instance);
		}
	}

	if (_target_is_valid)
	{
		habitat_no_enemy_timer = 0;
		var _target_distance = point_distance(x, y, target_instance.x, target_instance.y);

		if (_target_distance <= attack_radius)
		{
			is_attacking_target = true;
			attack_target(target_instance);
		}
		else
		{
			move_towards_target(target_instance, attack_radius);
		}

		return true;
	}

	// A quiet habitat recalls its Orcs only after morning has arrived.
	target_instance = noone;
	habitat_no_enemy_timer += gameplay_time_scale;

	if (global.day_phase == DAY_PHASE.DAY && habitat_no_enemy_timer >= habitat_return_delay)
	{
		var _home_distance = point_distance(x, y, habitat_home_x, habitat_home_y);

		if (_home_distance > habitat_return_radius)
		{
			move_towards_world_point(habitat_home_x, habitat_home_y);
		}
	}

	return true;
};

unit_special_behavior_update = function()
{
	return forced_retreat_update()
		|| panic_flee_update()
		|| habitat_combat_update();
};
