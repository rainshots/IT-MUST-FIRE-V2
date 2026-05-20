// Base unit combat stats.
unit_faction = UNIT_FACTION.NOONE;
max_hp = 20;
hp = max_hp;
damage = 1;
reload_time = room_speed;
reload_timer = 0;
attack_radius = 32;

// Base unit movement and target search settings.
move_speed = 1.2;
target_detection_radius = 320;
cannon_guard_radius = 460;
target_instance = noone;

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

move_towards_target = function(_target)
{
	if (instance_exists(_target))
	{
		var _target_direction = point_direction(x, y, _target.x, _target.y);

		x += lengthdir_x(move_speed, _target_direction);
		y += lengthdir_y(move_speed, _target_direction);
	}
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

	reload_timer = reload_time;
};
