// Initialize shared enemy unit state.
event_inherited();

// Crusaders escort a Holy Catapult and fight nearby threats.
max_hp = BALANCE_CRUSADER_HP;
hp = max_hp;
armor = BALANCE_CRUSADER_ARMOR;
magic_resistance = BALANCE_CRUSADER_MAGIC_RESISTANCE;
damage = BALANCE_CRUSADER_DAMAGE;
magic_damage = BALANCE_CRUSADER_MAGIC_DAMAGE;
reload_time = BALANCE_CRUSADER_RELOAD_TIME * room_speed;
attack_radius = BALANCE_CRUSADER_ATTACK_RADIUS;
cannon_attack_radius = BALANCE_CRUSADER_CANNON_ATTACK_RADIUS;
move_speed = BALANCE_CRUSADER_MOVE_SPEED;
target_detection_radius = BALANCE_CRUSADER_DANGER_SEARCH_RADIUS;
vision_radius = BALANCE_CRUSADER_DANGER_SEARCH_RADIUS;
catapult_escort_target = noone;
catapult_escort_angle = random(360);
catapult_escort_radius = BALANCE_CRUSADER_ESCORT_RADIUS;
catapult_escort_arrive_radius = BALANCE_CRUSADER_ESCORT_ARRIVE_RADIUS;
catapult_escort_move_dead_zone = BALANCE_CRUSADER_ESCORT_MOVE_DEAD_ZONE;
catapult_escort_separation_multiplier = BALANCE_CRUSADER_ESCORT_SEPARATION_MULTIPLIER;

crusader_escort_move_towards = function(_target_x, _target_y, _distance_to_target)
{
	var _current_move_speed = move_speed * unit_move_speed_multiplier_get();
	var _move_distance = min(_current_move_speed, max(0, _distance_to_target - catapult_escort_arrive_radius));

	if (_move_distance <= 0)
	{
		is_walking = false;
		return;
	}

	var _target_direction = point_direction(x, y, _target_x, _target_y);

	is_walking = true;
	face_world_x(x + lengthdir_x(1, _target_direction));
	x += lengthdir_x(_move_distance, _target_direction);
	y += lengthdir_y(_move_distance, _target_direction);
};

crusader_behavior_update = function()
{
	separation_push_multiplier = 1;

	if (!instance_exists(catapult_escort_target))
	{
		unit_can_attack_cannon = true;
		return false;
	}

	var _danger_target = find_nearest_target(o_friendly_units, target_detection_radius);

	if (!instance_exists(_danger_target))
	{
		_danger_target = find_nearest_attackable_player_structure(vision_radius);
	}

	if (instance_exists(_danger_target))
	{
		return false;
	}

	var _escort_x = catapult_escort_target.x + lengthdir_x(catapult_escort_radius, catapult_escort_angle);
	var _escort_y = catapult_escort_target.y + lengthdir_y(catapult_escort_radius, catapult_escort_angle);
	var _escort_distance = point_distance(x, y, _escort_x, _escort_y);

	separation_push_multiplier = catapult_escort_separation_multiplier;

	if (_escort_distance > catapult_escort_arrive_radius + catapult_escort_move_dead_zone)
	{
		crusader_escort_move_towards(_escort_x, _escort_y, _escort_distance);
	}
	else
	{
		is_walking = false;
	}

	return true;
};

unit_special_behavior_update = function()
{
	separation_push_multiplier = 1;

	return forced_retreat_update()
		|| panic_flee_update()
		|| crusader_behavior_update();
};
