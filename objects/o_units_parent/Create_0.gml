// Base unit combat stats.
unit_faction = UNIT_FACTION.NOONE;
max_hp = 20;
hp = max_hp;
damage = 1;
reload_time = room_speed;
reload_timer = 0;
attack_radius = 32;
cannon_attack_radius = 200;

// Base unit movement and target search settings.
move_speed = 1.2;
target_detection_radius = BALANCE_UNIT_VISION_RADIUS;
vision_radius = BALANCE_UNIT_VISION_RADIUS;
cannon_guard_radius = 460;
target_instance = noone;
alert_target = noone;
alert_target_timer = 0;
alert_target_time = BALANCE_UNIT_ALERT_TARGET_TIME * room_speed;

// Optional guard behavior is used by spawned defenders.
owner_garnizon = noone;
guard_target = noone;
guard_radius = 220;
unit_can_attack_cannon = true;
is_night_attack_unit = false;

// Unit separation keeps units from stacking into one point.
separation_radius = 26;
separation_strength = 0.55;
separation_update_interval = 5;
separation_update_timer = irandom(separation_update_interval - 1);
separation_max_neighbors = 6;
separation_push_x = 0;
separation_push_y = 0;
combat_separation_multiplier = 0.45;
is_attacking_target = false;

// Attack feedback shows who hit whom for a short moment.
attack_feedback_time = 0.16 * room_speed;
attack_feedback_timer = 0;
attack_feedback_target = noone;
attack_feedback_target_x = x;
attack_feedback_target_y = y;
attack_feedback_line_width = 2;

// Health bar visual settings.
bar_width = 34;
bar_height = 4;
bar_offset_y = 28;

find_nearest_target = function(_object_index, _max_distance)
{
	var _nearest_target = instance_nearest(x, y, _object_index);

	if (instance_exists(_nearest_target))
	{
		var _target_distance = point_distance(x, y, _nearest_target.x, _nearest_target.y);

		if (_target_distance <= _max_distance)
		{
			return _nearest_target;
		}
	}

	return noone;
};

find_nearest_cannon_attacker = function()
{
	if (!instance_exists(o_cannon))
	{
		return noone;
	}

	var _cannon = instance_find(o_cannon, 0);
	var _nearby_enemies = ds_list_create();
	var _enemy_count = collision_circle_list(_cannon.x, _cannon.y, cannon_attack_radius, o_enemy_units, false, true, _nearby_enemies, false);
	var _nearest_attacker = noone;
	var _nearest_distance = infinity;

	// Pick the closest enemy that is close enough to attack the cannon.
	for (var _enemy_index = 0; _enemy_index < _enemy_count; ++_enemy_index)
	{
		var _enemy = _nearby_enemies[| _enemy_index];

		if (instance_exists(_enemy) && _enemy.hp > 0)
		{
			var _enemy_distance = point_distance(x, y, _enemy.x, _enemy.y);

			if (_enemy_distance < _nearest_distance)
			{
				_nearest_attacker = _enemy;
				_nearest_distance = _enemy_distance;
			}
		}
	}

	ds_list_destroy(_nearby_enemies);

	return _nearest_attacker;
};

find_nearest_enemy_object = function(_max_distance)
{
	var _nearest_target = noone;
	var _nearest_distance = _max_distance;

	// Holy towers are hostile structures for friendly units.
	if (instance_exists(o_holy_tower))
	{
		var _holy_tower_count = instance_number(o_holy_tower);

		for (var _tower_index = 0; _tower_index < _holy_tower_count; ++_tower_index)
		{
			var _tower = instance_find(o_holy_tower, _tower_index);

			if (instance_exists(_tower) && _tower.hp > 0)
			{
				var _tower_distance = point_distance(x, y, _tower.x, _tower.y);

				if (_tower_distance <= _nearest_distance)
				{
					_nearest_distance = _tower_distance;
					_nearest_target = _tower;
				}
			}
		}
	}

	// Garnizons are hostile structures for friendly units.
	if (instance_exists(o_garnizon))
	{
		var _garnizon_count = instance_number(o_garnizon);

		for (var _garnizon_index = 0; _garnizon_index < _garnizon_count; ++_garnizon_index)
		{
			var _garnizon = instance_find(o_garnizon, _garnizon_index);

			if (instance_exists(_garnizon) && _garnizon.hp > 0)
			{
				var _garnizon_distance = point_distance(x, y, _garnizon.x, _garnizon.y);

				if (_garnizon_distance <= _nearest_distance)
				{
					_nearest_distance = _garnizon_distance;
					_nearest_target = _garnizon;
				}
			}
		}
	}

	return _nearest_target;
};

move_towards_target = function(_target)
{
	if (instance_exists(_target))
	{
		var _target_direction = point_direction(x, y, _target.x, _target.y);

		x += lengthdir_x(move_speed, _target_direction);
		y += lengthdir_y(move_speed, _target_direction);
	}
};

update_separation_push = function()
{
	separation_update_timer++;

	if (separation_update_timer mod separation_update_interval != 0)
	{
		return;
	}

	var _separation_object = o_units_parent;

	if (unit_faction == UNIT_FACTION.ENEMY)
	{
		_separation_object = o_enemy_units;
	}
	else if (unit_faction == UNIT_FACTION.FRIENDLY)
	{
		_separation_object = o_friendly_units;
	}

	var _nearby_units = ds_list_create();
	var _nearby_unit_count = collision_circle_list(x, y, separation_radius, _separation_object, false, true, _nearby_units, false);
	var _checked_unit_count = min(_nearby_unit_count, separation_max_neighbors);
	var _push_x = 0;
	var _push_y = 0;

	// Push away from a few nearby units. This avoids expensive full crowd checks.
	for (var _unit_index = 0; _unit_index < _checked_unit_count; ++_unit_index)
	{
		var _nearby_unit = _nearby_units[| _unit_index];

		if (instance_exists(_nearby_unit) && _nearby_unit != id)
		{
			var _distance_to_unit = point_distance(x, y, _nearby_unit.x, _nearby_unit.y);
			var _push_direction = point_direction(_nearby_unit.x, _nearby_unit.y, x, y);

			if (_distance_to_unit <= 0)
			{
				_distance_to_unit = 1;
				_push_direction = (_unit_index * 47) mod 360;
			}

			var _push_amount = 1 - clamp(_distance_to_unit / separation_radius, 0, 1);

			_push_x += lengthdir_x(_push_amount, _push_direction);
			_push_y += lengthdir_y(_push_amount, _push_direction);
		}
	}

	ds_list_destroy(_nearby_units);

	separation_push_x = clamp(_push_x, -1, 1) * separation_strength;
	separation_push_y = clamp(_push_y, -1, 1) * separation_strength;
};

apply_separation_push = function()
{
	var _separation_multiplier = 1;

	if (is_attacking_target)
	{
		_separation_multiplier = combat_separation_multiplier;
	}

	x += separation_push_x * _separation_multiplier;
	y += separation_push_y * _separation_multiplier;
};

attack_target = function(_target)
{
	if (!instance_exists(_target))
	{
		return;
	}

	if (reload_timer > 0)
	{
		reload_timer--;
		return;
	}

	if (variable_instance_exists(_target, "hp"))
	{
		_target.hp = max(_target.hp - damage, 0);
	}

	// Store attack feedback position even if the target dies immediately after hit.
	attack_feedback_target = _target;
	attack_feedback_target_x = _target.x;
	attack_feedback_target_y = _target.y;
	attack_feedback_timer = attack_feedback_time;

	reload_timer = reload_time;
};
