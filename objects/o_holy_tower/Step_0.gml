// Pause freezes holy tower combat.
if (global.pause)
{
	exit;
}

// Destroyed holy towers stay on the map as inert ruins.
if (is_destroyed)
{
	exit;
}

holy_tower_reinforcement_thresholds_update();
holy_tower_night_volley_update();

// Holy towers gradually cleanse taint instead of creating protected ground.
taint_cleanse_update_timer++;

if (taint_cleanse_update_timer >= taint_cleanse_update_interval)
{
	taint_cleanse_update_timer = 0;
	cleanse_nearby_taint();
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

// Holy towers only attack during the night.
if (global.day_phase != DAY_PHASE.NIGHT)
{
	target_instance = noone;
	exit;
}

// Find the closest friendly unit inside shooting radius.
target_instance = noone;
var _nearest_distance = shoot_radius;
var _friendly_count = instance_number(o_friendly_units);

for (var _friendly_index = 0; _friendly_index < _friendly_count; ++_friendly_index)
{
	var _friendly_unit = instance_find(o_friendly_units, _friendly_index);

	if (instance_exists(_friendly_unit)
		&& (!variable_instance_exists(_friendly_unit, "hp") || _friendly_unit.hp > 0)
		&& (!variable_instance_exists(_friendly_unit, "is_being_dragged") || !_friendly_unit.is_being_dragged)
		&& (!variable_instance_exists(_friendly_unit, "ignored_by_enemies") || !_friendly_unit.ignored_by_enemies))
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

if (variable_instance_exists(target_instance, "hp")
	&& (!variable_instance_exists(target_instance, "is_being_dragged") || !target_instance.is_being_dragged))
{
	holy_tower_projectile_create(target_instance.x, target_instance.y);
	call_nearby_friendly_units_for_help(target_instance);
}

reload_timer = reload_time;
