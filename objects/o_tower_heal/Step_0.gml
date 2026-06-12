// Pause freezes tower capture and healing.
if (global.pause)
{
	exit;
}

// Check whether the ground under the tower has fully corrupted.
tower_capture_update();

if (!is_captured)
{
	exit;
}

heal_tick_timer++;

if (heal_tick_timer < heal_tick_time)
{
	exit;
}

heal_tick_timer = 0;

// Heal summoned and demon-form friendly units in range.
var _friendly_list = ds_list_create();
var _friendly_count = collision_circle_list(x, y, heal_radius, o_friendly_units, false, true, _friendly_list, false);

for (var _friendly_index = 0; _friendly_index < _friendly_count; ++_friendly_index)
{
	var _friendly_unit = _friendly_list[| _friendly_index];

	if (instance_exists(_friendly_unit)
		&& variable_instance_exists(_friendly_unit, "hp")
		&& variable_instance_exists(_friendly_unit, "max_hp")
		&& _friendly_unit.hp > 0
		&& _friendly_unit.hp < _friendly_unit.max_hp)
	{
		var _friendly_hp_before_heal = _friendly_unit.hp;
		_friendly_unit.hp = min(_friendly_unit.hp + heal_amount, _friendly_unit.max_hp);
		heal_feedback_create(_friendly_unit, _friendly_unit.hp - _friendly_hp_before_heal);
	}
}

ds_list_destroy(_friendly_list);

// Heal visible cultists too because they are player troops but not children of o_friendly_units.
if (variable_global_exists("cultists"))
{
	var _cultist_count = array_length(global.cultists);

	for (var _cultist_index = 0; _cultist_index < _cultist_count; ++_cultist_index)
	{
		var _cultist = global.cultists[_cultist_index];

		if (instance_exists(_cultist)
			&& _cultist.visible
			&& variable_instance_exists(_cultist, "hp")
			&& variable_instance_exists(_cultist, "max_hp")
			&& _cultist.hp > 0
			&& _cultist.hp < _cultist.max_hp
			&& point_distance(x, y, _cultist.x, _cultist.y) <= heal_radius)
		{
			var _cultist_hp_before_heal = _cultist.hp;
			_cultist.hp = min(_cultist.hp + heal_amount, _cultist.max_hp);
			heal_feedback_create(_cultist, _cultist.hp - _cultist_hp_before_heal);
		}
	}
}
