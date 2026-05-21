// Pause freezes holy tower combat.
if (global.pause)
{
	exit;
}

// Destroy the tower safely if any damage source reduced HP to zero.
if (hp <= 0)
{
	destroy_holy_tower();
	exit;
}

// Update short attack feedback lifetime.
if (attack_feedback_timer > 0)
{
	attack_feedback_timer--;
}

// Find the closest friendly unit inside shooting radius.
target_instance = noone;
var _nearest_distance = shoot_radius;
var _friendly_count = instance_number(o_friendly_units);

for (var _friendly_index = 0; _friendly_index < _friendly_count; ++_friendly_index)
{
	var _friendly_unit = instance_find(o_friendly_units, _friendly_index);

	if (instance_exists(_friendly_unit))
	{
		var _distance_to_unit = point_distance(x, y, _friendly_unit.x, _friendly_unit.y);

		if (_distance_to_unit <= _nearest_distance)
		{
			_nearest_distance = _distance_to_unit;
			target_instance = _friendly_unit;
		}
	}
}

if (!instance_exists(target_instance))
{
	exit;
}

// Shoot the target when reload is ready.
if (reload_timer > 0)
{
	reload_timer--;
	exit;
}

if (variable_instance_exists(target_instance, "hp"))
{
	target_instance.hp = max(target_instance.hp - damage, 0);
	call_nearby_friendly_units_for_help(target_instance);
}

// Store attack feedback position even if the target dies immediately after hit.
attack_feedback_target = target_instance;
attack_feedback_target_x = target_instance.x;
attack_feedback_target_y = target_instance.y;
attack_feedback_timer = attack_feedback_time;

reload_timer = reload_time;
