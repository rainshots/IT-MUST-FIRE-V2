// Initialize shared enemy unit state.
event_inherited();

// Mage is a ranged magic enemy that checks magic resistance instead of armor.
max_hp = BALANCE_ENEMY_MAGE_HP;
hp = max_hp;
armor = BALANCE_ENEMY_MAGE_ARMOR;
magic_resistance = BALANCE_ENEMY_MAGE_MAGIC_RESISTANCE;
damage = BALANCE_ENEMY_MAGE_DAMAGE;
magic_damage = BALANCE_ENEMY_MAGE_MAGIC_DAMAGE;
reload_time = BALANCE_ENEMY_MAGE_RELOAD_TIME * room_speed;
attack_radius = BALANCE_ENEMY_MAGE_ATTACK_RADIUS;
move_speed = BALANCE_ENEMY_MAGE_MOVE_SPEED;

// Melee damage periodically makes the Mage disengage from its attacker.
unit_damage_received = function(_source_instance, _source_faction, _applied_damage)
{
	ranged_unit_melee_flee_on_damage(_source_instance);
};

// Every attempt rolls a fresh cooldown, including attempts blocked by proximity or terrain.
teleport_cooldown_min = BALANCE_ENEMY_MAGE_TELEPORT_COOLDOWN_MIN * room_speed;
teleport_cooldown_max = BALANCE_ENEMY_MAGE_TELEPORT_COOLDOWN_MAX * room_speed;
teleport_timer = random_range(teleport_cooldown_min, teleport_cooldown_max);
teleport_distance = BALANCE_ENEMY_MAGE_TELEPORT_DISTANCE;
teleport_search_step = BALANCE_ENEMY_MAGE_TELEPORT_SEARCH_STEP;

mage_teleport_try = function()
{
	if (!instance_exists(o_cannon))
	{
		return false;
	}

	var _cannon = instance_find(o_cannon, 0);
	if (point_distance(x, y, _cannon.x, _cannon.y) < teleport_distance)
	{
		return false;
	}

	var _direction = point_direction(x, y, _cannon.x, _cannon.y);
	var _navigation_grid = navigation_grid_get();
	var _maximum_distance = point_distance(0, 0, room_width, room_height);
	var _search_count = max(0, ceil((_maximum_distance - teleport_distance) / teleport_search_step)) + 1;
	var _left_offset = bbox_left - x;
	var _right_offset = bbox_right - x;
	var _top_offset = bbox_top - y;
	var _bottom_offset = bbox_bottom - y;

	// Search beyond the requested landing point without crossing the room boundary.
	for (var _search_index = 0; _search_index < _search_count; ++_search_index)
	{
		var _distance = teleport_distance + (_search_index * teleport_search_step);
		var _landing_x = x + lengthdir_x(_distance, _direction);
		var _landing_y = y + lengthdir_y(_distance, _direction);

		if (_landing_x + _left_offset < 0 || _landing_x + _right_offset >= room_width
			|| _landing_y + _top_offset < 0 || _landing_y + _bottom_offset >= room_height)
		{
			break;
		}

		// Check both navigation obstacles and actual solid-instance collision masks.
		if (!navigation_position_is_safe(_navigation_grid, _landing_x, _landing_y)
			|| !place_free(_landing_x, _landing_y)
			|| place_meeting(_landing_x, _landing_y, o_wall_parent)
			|| place_meeting(_landing_x, _landing_y, o_mountain))
		{
			continue;
		}

		x = _landing_x;
		y = _landing_y;
		navigation_path_state_clear();
		navigation_last_safe_position_store(_navigation_grid);
		visual_attack_offset_x = 0;
		visual_attack_offset_y = 0;
		return true;
	}

	return false;
};

// Shared unit Step calls this only during active, unstunned combat simulation.
unit_special_behavior_update = function()
{
	teleport_timer -= gameplay_time_scale;
	if (teleport_timer <= 0)
	{
		teleport_timer = random_range(teleport_cooldown_min, teleport_cooldown_max);
		if (mage_teleport_try())
		{
			return true;
		}
	}

	return forced_retreat_update() || panic_flee_update();
};