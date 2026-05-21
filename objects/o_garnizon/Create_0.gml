// Initialize shared map object state.
event_inherited();

// Garnizon durability.
max_hp = 300;
hp = max_hp;
max_corruption = 300;
corruption = 0;

// Enemy spawn settings.
spawn_interval = 0.5 * room_speed;
spawn_timer = spawn_interval;
spawn_radius = 96;
spawn_count = 0;
big_enemy_spawn_step = 5;
release_unit_count = 15;

// Tooltip lines describe projectile reactions for player targeting.
tooltip_lines = [
	"Damage: No effect yet",
	"Corruption: No effect yet",
	"Summon: No effect yet"
];

count_owned_units = function()
{
	var _owned_unit_count = 0;
	var _enemy_count = instance_number(o_enemy_units);

	for (var _enemy_index = 0; _enemy_index < _enemy_count; ++_enemy_index)
	{
		var _enemy = instance_find(o_enemy_units, _enemy_index);

		if (instance_exists(_enemy) && _enemy.owner_garnizon == id && !_enemy.unit_can_attack_cannon)
		{
			_owned_unit_count++;
		}
	}

	return _owned_unit_count;
};

release_owned_units = function()
{
	var _enemy_count = instance_number(o_enemy_units);

	for (var _enemy_index = 0; _enemy_index < _enemy_count; ++_enemy_index)
	{
		var _enemy = instance_find(o_enemy_units, _enemy_index);

		if (instance_exists(_enemy) && _enemy.owner_garnizon == id)
		{
			_enemy.unit_can_attack_cannon = true;
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
};
