// The balance controller owns every simulation tick so x1 and accelerated runs stay identical.
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

// Pause freezes tower capture and combat.
map_building_warning_update();
map_object_unit_fade_update();

if (global.pause)
{
	exit;
}

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

if (attack_feedback_timer > 0)
{
	attack_feedback_timer--;
}

if (!is_captured)
{
	exit;
}

// Find the closest enemy inside shooting radius.
target_instance = noone;
var _nearest_distance = shoot_radius;
var _enemy_count = instance_number(o_enemy_units);

for (var _enemy_index = 0; _enemy_index < _enemy_count; ++_enemy_index)
{
	var _enemy = instance_find(o_enemy_units, _enemy_index);
	var _matches_balance_test = instance_exists(_enemy)
		&& (!variable_instance_exists(id, "balance_test_match_id")
			|| !variable_instance_exists(_enemy, "balance_test_match_id")
			|| _enemy.balance_test_match_id == balance_test_match_id);
	var _can_attack_enemy = _matches_balance_test
		&& (!variable_instance_exists(_enemy, "hp") || _enemy.hp > 0)
		&& (!variable_instance_exists(_enemy, "is_being_dragged") || !_enemy.is_being_dragged);

	if (_can_attack_enemy)
	{
		var _distance_to_enemy = point_distance(x, y, _enemy.x, _enemy.y);

		if (_distance_to_enemy <= _nearest_distance)
		{
			_nearest_distance = _distance_to_enemy;
			target_instance = _enemy;
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
	tower_damage_projectile_create(target_instance.x, target_instance.y);
}

reload_timer = reload_time;
