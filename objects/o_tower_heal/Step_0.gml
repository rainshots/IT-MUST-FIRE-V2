// Balance tests execute explicit ticks so x1 and accelerated runs use identical logic.
if (variable_global_exists("balance_test_active")
	&& global.balance_test_active
	&& (!variable_global_exists("balance_test_manual_tick_active")
		|| !global.balance_test_manual_tick_active))
{
	exit;
}

if (variable_instance_exists(id, "balance_test_simulation_finished")
	&& balance_test_simulation_finished)
{
	exit;
}

// Pause freezes tower capture and healing.
map_building_warning_update();
map_object_unit_fade_update();

if (global.pause)
{
	exit;
}

var _time_scale = variable_global_exists("gameplay_time_scale") ? global.gameplay_time_scale : 1;

// Check whether the ground under the tower has fully corrupted.
tower_capture_update();

if (variable_instance_exists(id, "building_constructed_by_shell") && building_constructed_by_shell)
{
	corruption = ground_cell_corruption_get(x, y) * max_corruption;
	is_captured = corruption > 0;

	if (is_captured)
	{
		sprite_index = captured_sprite_index;
	}
	else
	{
		sprite_index = uncaptured_sprite_index;
	}
}

if (!is_captured)
{
	exit;
}

heal_tick_timer += _time_scale;

if (heal_tick_timer < heal_tick_time)
{
	exit;
}

heal_tick_timer = 0;

// Shoot at the nearest wounded summoned or demon-form friendly unit.
var _target_instance = noone;
var _nearest_distance = heal_radius;
var _friendly_count = instance_number(o_friendly_units);

for (var _friendly_index = 0; _friendly_index < _friendly_count; ++_friendly_index)
{
	var _friendly_unit = instance_find(o_friendly_units, _friendly_index);

	if (tower_heal_target_is_valid(_friendly_unit))
	{
		var _distance_to_friendly = point_distance(x, y, _friendly_unit.x, _friendly_unit.y);

		if (_distance_to_friendly <= _nearest_distance)
		{
			_nearest_distance = _distance_to_friendly;
			_target_instance = _friendly_unit;
		}
	}
}

// Visible cultists are player troops but not children of o_friendly_units.
if (variable_global_exists("archdemons"))
{
	var _cultist_count = array_length(global.archdemons);

	for (var _cultist_index = 0; _cultist_index < _cultist_count; ++_cultist_index)
	{
		var _cultist = global.archdemons[_cultist_index];

		if (tower_heal_target_is_valid(_cultist))
		{
			var _distance_to_archdemon = point_distance(x, y, _cultist.x, _cultist.y);

			if (_distance_to_archdemon <= _nearest_distance)
			{
				_nearest_distance = _distance_to_archdemon;
				_target_instance = _cultist;
			}
		}
	}
}

if (instance_exists(_target_instance))
{
	tower_heal_projectile_create(_target_instance.x, _target_instance.y);
}
