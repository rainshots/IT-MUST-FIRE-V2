// Pause freezes unit AI and combat.
if (global.pause)
{
	exit;
}

// Destroy dead units.
if (hp <= 0)
{
	instance_destroy();
	exit;
}

// Update short attack feedback lifetime.
if (attack_feedback_timer > 0)
{
	attack_feedback_timer--;
}

// Choose target by faction.
target_instance = noone;
is_attacking_target = false;

var _is_enemy_unit = (unit_faction == UNIT_FACTION.ENEMY);
var _is_friendly_unit = (unit_faction == UNIT_FACTION.FRIENDLY);

// Update lightweight separation vector before movement.
update_separation_push();

if (_is_enemy_unit)
{
	target_instance = find_nearest_target(o_friendly_units, target_detection_radius);

	if (!instance_exists(target_instance) && !unit_can_attack_cannon && instance_exists(guard_target))
	{
		var _distance_to_guard = point_distance(x, y, guard_target.x, guard_target.y);

		if (_distance_to_guard > guard_radius)
		{
			target_instance = guard_target;
		}
	}

	if (!instance_exists(target_instance) && unit_can_attack_cannon && instance_exists(o_cannon))
	{
		target_instance = instance_find(o_cannon, 0);
	}
}
else if (_is_friendly_unit)
{
	target_instance = find_nearest_target(o_enemy_units, target_detection_radius);

	if (!instance_exists(target_instance))
	{
		target_instance = find_nearest_cannon_attacker();
	}

	if (!instance_exists(target_instance) && instance_exists(o_cannon))
	{
		var _cannon = instance_find(o_cannon, 0);
		var _distance_to_cannon = point_distance(x, y, _cannon.x, _cannon.y);

		if (_distance_to_cannon > cannon_guard_radius)
		{
			target_instance = _cannon;
		}
	}
}

// Move to target or attack it when close enough.
if (instance_exists(target_instance))
{
	var _target_distance = point_distance(x, y, target_instance.x, target_instance.y);
	var _current_attack_radius = attack_radius;

	if (target_instance == guard_target)
	{
		_current_attack_radius = guard_radius;
	}
	else if (_is_enemy_unit && target_instance.object_index == o_cannon)
	{
		_current_attack_radius = cannon_attack_radius;
	}

	if (_target_distance <= _current_attack_radius)
	{
		if (target_instance == guard_target)
		{
			is_attacking_target = true;
		}
		else if (target_instance.object_index != o_cannon || _is_enemy_unit)
		{
			is_attacking_target = true;
			attack_target(target_instance);
		}
	}
	else
	{
		move_towards_target(target_instance);
	}
}

// Apply separation after main AI movement so units do not stack.
apply_separation_push();
