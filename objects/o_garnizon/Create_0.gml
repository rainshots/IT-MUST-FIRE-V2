// Initialize shared map object state.
event_inherited();

// Garnizon durability.
max_hp = 300;
hp = max_hp;
max_corruption = 300;
corruption = 0;

// Holy troop spawn settings used during the day.
spawn_interval = BALANCE_GARNIZON_SPAWN_INTERVAL * room_speed;
spawn_timer = spawn_interval;
spawn_radius = BALANCE_GARNIZON_SPAWN_RADIUS;
spawn_count = 0;
big_enemy_spawn_step = BALANCE_GARNIZON_BIG_ENEMY_SPAWN_STEP;

// Activation state gates night attacks from this garnizon.
is_activated = false;
has_released_current_night = false;
previous_hp = hp;
activation_corruption_radius = BALANCE_GARNIZON_ACTIVATION_CORRUPTION_RADIUS_IN_CELLS * BALANCE_GRID_CELL_SIZE;
activation_check_interval = BALANCE_GARNIZON_ACTIVATION_CHECK_INTERVAL * room_speed;
activation_check_timer = irandom(max(round(activation_check_interval) - 1, 0));

// Tooltip lines describe projectile reactions for player targeting.
tooltip_lines = [
	"Damage: Takes damage",
	"Corruption: No effect yet",
	"Summon: No effect yet"
];

release_owned_units = function()
{
	has_released_current_night = true;

	var _enemy_count = instance_number(o_enemy_units);

	for (var _enemy_index = 0; _enemy_index < _enemy_count; ++_enemy_index)
	{
		var _enemy = instance_find(o_enemy_units, _enemy_index);

		if (instance_exists(_enemy) && _enemy.owner_garnizon == id)
		{
			_enemy.unit_can_attack_cannon = true;
			_enemy.is_night_attack_unit = true;
			_enemy.guard_target = noone;
			_enemy.owner_garnizon = noone;
		}
	}
};

spawn_guard_unit = function()
{
	spawn_count++;

	var _spawn_object = o_enemy_small;
	if (spawn_count mod big_enemy_spawn_step == 0)
	{
		_spawn_object = o_enemy_big;
	}

	var _spawn_direction = random(360);
	var _spawn_distance = random(spawn_radius);
	var _spawn_x = x + lengthdir_x(_spawn_distance, _spawn_direction);
	var _spawn_y = y + lengthdir_y(_spawn_distance, _spawn_direction);
	var _unit = instance_create_layer(_spawn_x, _spawn_y, "Instances", _spawn_object);

	_unit.owner_garnizon = id;
	_unit.guard_target = id;
	_unit.unit_can_attack_cannon = false;
	_unit.is_night_attack_unit = false;
};

activate_garnizon = function()
{
	is_activated = true;
};

on_damage_projectile_hit = function()
{
	var _damage_amount = BALANCE_PROJECTILE_DAMAGE_AMOUNT;

	hp = max(hp - _damage_amount, 0);
};

has_corrupted_cell_nearby = function()
{
	if (!instance_exists(o_corruption_grid))
	{
		return false;
	}

	var _corruption_grid = instance_find(o_corruption_grid, 0);
	var _safe_radius = max(activation_corruption_radius, 1);
	var _left_cell = clamp(floor((x - _safe_radius) / _corruption_grid.cell_size), 0, _corruption_grid.grid_width - 1);
	var _right_cell = clamp(floor((x + _safe_radius) / _corruption_grid.cell_size), 0, _corruption_grid.grid_width - 1);
	var _top_cell = clamp(floor((y - _safe_radius) / _corruption_grid.cell_size), 0, _corruption_grid.grid_height - 1);
	var _bottom_cell = clamp(floor((y + _safe_radius) / _corruption_grid.cell_size), 0, _corruption_grid.grid_height - 1);

	for (var _cell_x = _left_cell; _cell_x <= _right_cell; ++_cell_x)
	{
		for (var _cell_y = _top_cell; _cell_y <= _bottom_cell; ++_cell_y)
		{
			var _cell_corruption = ds_grid_get(_corruption_grid.corruption_grid, _cell_x, _cell_y);

			if (_cell_corruption > 0)
			{
				var _cell_center_x = (_cell_x * _corruption_grid.cell_size) + (_corruption_grid.cell_size * 0.5);
				var _cell_center_y = (_cell_y * _corruption_grid.cell_size) + (_corruption_grid.cell_size * 0.5);

				if (point_distance(x, y, _cell_center_x, _cell_center_y) <= _safe_radius)
				{
					return true;
				}
			}
		}
	}

	return false;
};

on_projectile_hit = function(_projectile_type)
{
	if (variable_global_exists("legacy_building_logic_enabled") && !global.legacy_building_logic_enabled)
	{
		return;
	}

	activate_garnizon();

	if (_projectile_type == PROJECTILE_TYPE.DAMAGE)
	{
		on_damage_projectile_hit();
	}
	else if (_projectile_type == PROJECTILE_TYPE.CORRUPTION)
	{
		on_corruption_projectile_hit();
	}
	else if (_projectile_type == PROJECTILE_TYPE.SUMMON)
	{
		on_summon_projectile_hit();
	}
};
