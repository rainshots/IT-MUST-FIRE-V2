// Initialize shared map object state.
event_inherited();

// Shrine objective state is updated by corruption projectiles and infected ground.
is_corrupted = false;
shrine_normal_sprite = s_shrine_normal;
shrine_cursed_sprite = s_shrine_cursed;
corruption_radius = BALANCE_SHRINE_CORRUPTION_RADIUS;
max_hp = 10000;
hp = max_hp;
image_speed = 0;
sprite_index = shrine_normal_sprite;
image_index = 0;
defender_trigger_radius = BALANCE_SHRINE_DEFENDER_TRIGGER_RADIUS;
defender_spawn_interval = max(1, BALANCE_SHRINE_DEFENDER_SPAWN_INTERVAL * room_speed);
defender_spawn_timer = defender_spawn_interval;

// Shrine tooltip describes the run objective.
tooltip_lines = [
	"Shrine",
	"Spawns soldiers while enemies are within " + string(BALANCE_SHRINE_DEFENDER_TRIGGER_RADIUS) + "px",
	"Every " + string(BALANCE_SHRINE_DEFENDER_SPAWN_INTERVAL) + "s: summons Knights"
];

shrine_defender_target_is_valid = function(_target)
{
	return instance_exists(_target)
		&& (!variable_instance_exists(_target, "hp") || _target.hp > 0)
		&& (!variable_instance_exists(_target, "visible") || _target.visible)
		&& (!variable_instance_exists(_target, "is_being_dragged") || !_target.is_being_dragged)
		&& point_distance(x, y, _target.x, _target.y) <= defender_trigger_radius;
};

shrine_enemy_in_radius_exists = function()
{
	var _friendly_count = instance_number(o_friendly_units);

	for (var _friendly_index = 0; _friendly_index < _friendly_count; ++_friendly_index)
	{
		var _friendly_unit = instance_find(o_friendly_units, _friendly_index);

		if (shrine_defender_target_is_valid(_friendly_unit))
		{
			return true;
		}
	}

	if (variable_global_exists("cultists"))
	{
		var _cultist_count = array_length(global.cultists);

		for (var _cultist_index = 0; _cultist_index < _cultist_count; ++_cultist_index)
		{
			var _cultist = global.cultists[_cultist_index];

			if (shrine_defender_target_is_valid(_cultist))
			{
				return true;
			}
		}
	}

	return false;
};

shrine_defender_knight_spawn = function()
{
	var _spawn_direction = random(360);
	var _spawn_distance = random_range(
		BALANCE_SHRINE_DEFENDER_SPAWN_RADIUS_MIN,
		BALANCE_SHRINE_DEFENDER_SPAWN_RADIUS_MAX
	);
	var _knight = instance_create_layer(
		x + lengthdir_x(_spawn_distance, _spawn_direction),
		y + lengthdir_y(_spawn_distance, _spawn_direction),
		"Instances",
		o_enemy_knight
	);

	if (instance_exists(_knight))
	{
		_knight.unit_can_attack_cannon = true;
		_knight.owner_garnizon = noone;
		_knight.guard_target = noone;
	}
};

shrine_defenders_spawn = function()
{
	for (var _knight_index = 0; _knight_index < BALANCE_SHRINE_DEFENDER_KNIGHT_COUNT; ++_knight_index)
	{
		shrine_defender_knight_spawn();
	}
};

shrine_defender_spawner_update = function()
{
	if (!shrine_enemy_in_radius_exists())
	{
		defender_spawn_timer = defender_spawn_interval;
		return;
	}

	defender_spawn_timer--;

	if (defender_spawn_timer <= 0)
	{
		shrine_defenders_spawn();
		defender_spawn_timer = defender_spawn_interval;
	}
};

shrine_corrupt = function()
{
	if (is_corrupted)
	{
		return;
	}

	is_corrupted = true;
	corruption = max_corruption;

	sprite_index = shrine_cursed_sprite;
	image_index = 0;
	image_speed = 0;

	corrupt_circle(x, y, corruption_radius, 1);

	if (variable_global_exists("day_phase")
		&& global.day_phase == DAY_PHASE.DAY
		&& instance_exists(o_game_controller))
	{
		var _game_controller = instance_find(o_game_controller, 0);

		if (variable_instance_exists(_game_controller, "night_attack_plan_create"))
		{
			_game_controller.night_attack_plan_create();
		}
	}
};

on_projectile_hit = function(_projectile_type)
{
	if (_projectile_type == PROJECTILE_TYPE.CORRUPTION)
	{
		shrine_corrupt();
	}
};
