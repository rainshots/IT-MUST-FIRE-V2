// Pause freezes garnizon spawning.
if (global.pause)
{
	exit;
}

// V13 keeps legacy building wave logic disabled while the cultist prototype is rebuilt.
if (variable_global_exists("legacy_building_logic_enabled") && !global.legacy_building_logic_enabled)
{
	exit;
}

// Destroy dead garnizons and release references held by their prepared troops.
if (hp <= 0)
{
	var _enemy_count = instance_number(o_enemy_units);

	for (var _enemy_index = 0; _enemy_index < _enemy_count; ++_enemy_index)
	{
		var _enemy = instance_find(o_enemy_units, _enemy_index);

		if (instance_exists(_enemy) && _enemy.owner_garnizon == id)
		{
			_enemy.unit_can_attack_cannon = true;
			_enemy.is_night_attack_unit = (global.day_phase == DAY_PHASE.NIGHT);
			_enemy.guard_target = noone;
			_enemy.owner_garnizon = noone;
		}
	}

	instance_destroy();
	exit;
}

// Activate when damaged or when corrupted ground gets close enough.
if (hp < previous_hp)
{
	activate_garnizon();
}

previous_hp = hp;
activation_check_timer++;

if (!is_activated && activation_check_timer >= activation_check_interval)
{
	activation_check_timer = 0;

	if (has_corrupted_cell_nearby())
	{
		activate_garnizon();
	}
}

// Activated garnizons release their prepared troops during the current night.
if (global.day_phase == DAY_PHASE.NIGHT)
{
	if (is_activated && !has_released_current_night)
	{
		release_owned_units();
	}

	exit;
}

has_released_current_night = false;

// Spawn one guard at a fixed interval for the next attack wave.
spawn_timer--;
if (spawn_timer <= 0)
{
	spawn_guard_unit();
	spawn_timer = spawn_interval;
}
