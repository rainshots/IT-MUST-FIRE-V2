// Initialize shared friendly unit state.
event_inherited();

// Succubus is a very fast melee hunter of ranged enemies.
max_hp = BALANCE_SUCCUBUS_HP;
hp = max_hp;
armor = BALANCE_SUCCUBUS_ARMOR;
magic_resistance = BALANCE_SUCCUBUS_MAGIC_RESISTANCE;
damage = BALANCE_SUCCUBUS_DAMAGE;
magic_damage = 0;
reload_time = BALANCE_SUCCUBUS_RELOAD_TIME * room_speed;
attack_radius = BALANCE_SUCCUBUS_ATTACK_RADIUS;
move_speed = BALANCE_SUCCUBUS_MOVE_SPEED;

// Use the requested sprite when it is imported into the project.
var _unit_sprite = asset_get_index("s_succubus");

if (_unit_sprite != -1)
{
	sprite_index = _unit_sprite;
}

// Prefer the nearest catapult, archer, or mage inside normal vision.
friendly_priority_target_find = function(_max_distance)
{
	var _preferred_objects = [o_enemy_catapult, o_enemy_archer, o_enemy_mage];
	var _preferred_object_count = array_length(_preferred_objects);
	var _nearest_target = noone;
	var _nearest_distance_squared = _max_distance * _max_distance;

	for (var _object_index = 0; _object_index < _preferred_object_count; ++_object_index)
	{
		var _preferred_object = _preferred_objects[_object_index];
		var _target_count = instance_number(_preferred_object);

		for (var _target_index = 0; _target_index < _target_count; ++_target_index)
		{
			var _target = instance_find(_preferred_object, _target_index);

			if (!target_can_be_attacked(_target))
			{
				continue;
			}

			var _distance_x = _target.x - x;
			var _distance_y = _target.y - y;
			var _distance_squared = (_distance_x * _distance_x) + (_distance_y * _distance_y);

			if (_distance_squared < _nearest_distance_squared)
			{
				_nearest_target = _target;
				_nearest_distance_squared = _distance_squared;
			}
		}
	}

	return _nearest_target;
};
