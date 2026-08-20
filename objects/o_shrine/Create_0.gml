// Initialize shared map object state.
event_inherited();

// Shrine objective state is updated by corruption projectiles and infected ground.
is_corrupted = false;
is_attackable = false;
protection_towers = [];
protection_towers_destroyed = 0;
shrine_normal_sprite = s_shrine_normal;
shrine_cursed_sprite = s_shrine_cursed;
corruption_radius = BALANCE_SHRINE_CORRUPTION_RADIUS;
saint_radius = BALANCE_SHRINE_SAINT_RADIUS;
saint_source_registered = false;
saint_projectile_sources = [];
max_hp = 10000;
hp = max_hp;
image_speed = 0;
sprite_index = shrine_normal_sprite;
image_index = 0;
defender_trigger_radius = BALANCE_SHRINE_DEFENDER_TRIGGER_RADIUS;
defender_spawn_interval = max(1, BALANCE_SHRINE_DEFENDER_SPAWN_INTERVAL * room_speed);
defender_spawn_timer = defender_spawn_interval;
night_saint_projectile_count = BALANCE_SHRINE_NIGHT_SAINT_PROJECTILE_COUNT;
night_saint_projectile_radius = BALANCE_SHRINE_NIGHT_SAINT_PROJECTILE_RADIUS;
night_saint_projectile_step = BALANCE_SHRINE_NIGHT_SAINT_PROJECTILE_STEP;
night_saint_projectile_forward_jitter = BALANCE_SHRINE_NIGHT_SAINT_PROJECTILE_FORWARD_JITTER;
night_saint_projectile_side_jitter = BALANCE_SHRINE_NIGHT_SAINT_PROJECTILE_SIDE_JITTER;
night_saint_projectile_launch_time = BALANCE_SHRINE_NIGHT_SAINT_PROJECTILE_LAUNCH_TIME;
night_saint_projectile_spawn_offset_y = -28;
night_saint_projectile_layer_name = "Instances";
night_saint_projectile_draw_depth = BALANCE_PARTICLE_SYSTEM_TOP_DEPTH - 50;
night_saint_front_distance = saint_radius + (night_saint_projectile_radius * 0.6);
night_saint_front_start_distance = night_saint_front_distance;
night_saint_direction_index = 0;
night_saint_direction_max_distance = BALANCE_SHRINE_NIGHT_SAINT_DIRECTION_MAX_DISTANCE;
night_saint_direction_angle_step = BALANCE_SHRINE_NIGHT_SAINT_DIRECTION_ANGLE_STEP;
night_saint_direction_match_angle = BALANCE_SHRINE_NIGHT_SAINT_DIRECTION_MATCH_ANGLE;
day_volley_projectile_count_min = BALANCE_SHRINE_DAY_VOLLEY_PROJECTILE_COUNT_MIN;
day_volley_projectile_count_max = BALANCE_SHRINE_DAY_VOLLEY_PROJECTILE_COUNT_MAX;
day_volley_taint_search_radius = BALANCE_SHRINE_DAY_VOLLEY_TAINT_SEARCH_RADIUS;
day_volley_target_spread_radius = BALANCE_SHRINE_DAY_VOLLEY_TARGET_SPREAD_RADIUS;
day_volley_launch_time = BALANCE_SHRINE_DAY_VOLLEY_LAUNCH_TIME;
day_volley_cleanse_radius = BALANCE_SHRINE_DAY_VOLLEY_CLEANSE_RADIUS;
day_volley_cleanse_amount = BALANCE_SHRINE_DAY_VOLLEY_CLEANSE_AMOUNT;
day_volley_last_day_index = -1;

// Shrine tooltip describes the run objective.
tooltip_lines = [
	"Shrine",
	"Destroy its Holy Towers to make it vulnerable",
	"Then destroy the Shrine",
	"Day: cleanses tainted ground from long range"
];

unit_damage_receive = function(_damage_amount, _source_faction = UNIT_FACTION.NOONE, _is_critical = false, _can_trigger_soul_chain = true, _source_instance = noone)
{
	if (!is_attackable || is_corrupted)
	{
		return 0;
	}

	var _applied_damage = min(_damage_amount, hp);
	hp = max(hp - _damage_amount, 0);

	if (hp <= 0)
	{
		shrine_corrupt();
	}

	return _applied_damage;
};

shrine_protection_tower_add = function(_tower)
{
	if (instance_exists(_tower))
	{
		array_push(protection_towers, _tower);
	}
};

shrine_protection_tower_destroyed = function(_tower)
{
	if (is_attackable)
	{
		return;
	}

	protection_towers_destroyed++;

	if (protection_towers_destroyed >= array_length(protection_towers))
	{
		is_attackable = true;
	}
};

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

	if (variable_global_exists("archdemons"))
	{
		var _cultist_count = array_length(global.archdemons);

		for (var _cultist_index = 0; _cultist_index < _cultist_count; ++_cultist_index)
		{
			var _cultist = global.archdemons[_cultist_index];

			if (shrine_defender_target_is_valid(_cultist))
			{
				return true;
			}
		}
	}

	return false;
};

shrine_defender_crusader_spawn = function()
{
	var _spawn_direction = random(360);
	var _spawn_distance = random_range(
		BALANCE_SHRINE_DEFENDER_SPAWN_RADIUS_MIN,
		BALANCE_SHRINE_DEFENDER_SPAWN_RADIUS_MAX
	);
	var _crusader = instance_create_layer(
		x + lengthdir_x(_spawn_distance, _spawn_direction),
		y + lengthdir_y(_spawn_distance, _spawn_direction),
		"Instances",
		o_crusader
	);

	if (instance_exists(_crusader))
	{
		_crusader.unit_can_attack_cannon = true;
		_crusader.owner_garnizon = noone;
		_crusader.guard_target = noone;

		if (instance_exists(o_game_controller))
		{
			var _game_controller = instance_find(o_game_controller, 0);

			if (variable_instance_exists(_game_controller, "enemy_night_balance_scale_apply"))
			{
				_game_controller.enemy_night_balance_scale_apply(_crusader);
			}
		}
	}
};

shrine_defenders_spawn = function()
{
	for (var _crusader_index = 0; _crusader_index < BALANCE_SHRINE_DEFENDER_CRUSADER_COUNT; ++_crusader_index)
	{
		shrine_defender_crusader_spawn();
	}
};

shrine_defender_spawner_update = function()
{
	if (!shrine_enemy_in_radius_exists())
	{
		defender_spawn_timer = defender_spawn_interval;
		return;
	}

	defender_spawn_timer -= variable_global_exists("gameplay_time_scale")
		? global.gameplay_time_scale
		: 1;

	if (defender_spawn_timer <= 0)
	{
		shrine_defenders_spawn();
		defender_spawn_timer = defender_spawn_interval;
	}
};

shrine_saint_source_register = function()
{
	if (is_corrupted || saint_source_registered || !instance_exists(o_corruption_grid))
	{
		return;
	}

	var _corruption_grid = instance_find(o_corruption_grid, 0);

	if (variable_instance_exists(_corruption_grid, "saint_source_circle_add"))
	{
		_corruption_grid.saint_source_circle_add(x, y, saint_radius);
		saint_source_registered = true;
	}
};

shrine_saint_source_unregister = function()
{
	if (!saint_source_registered || !instance_exists(o_corruption_grid))
	{
		saint_source_registered = false;
		return;
	}

	var _corruption_grid = instance_find(o_corruption_grid, 0);

	if (variable_instance_exists(_corruption_grid, "saint_source_circle_remove"))
	{
		_corruption_grid.saint_source_circle_remove(x, y, saint_radius);
	}

	saint_source_registered = false;
};

shrine_saint_projectile_sources_unregister = function()
{
	if (!instance_exists(o_corruption_grid))
	{
		saint_projectile_sources = [];
		return;
	}

	var _corruption_grid = instance_find(o_corruption_grid, 0);

	if (!variable_instance_exists(_corruption_grid, "saint_source_circle_remove"))
	{
		saint_projectile_sources = [];
		return;
	}

	var _source_count = array_length(saint_projectile_sources);

	for (var _source_index = 0; _source_index < _source_count; ++_source_index)
	{
		var _source = saint_projectile_sources[_source_index];

		_corruption_grid.saint_source_circle_remove(_source.x, _source.y, _source.radius);
	}

	saint_projectile_sources = [];
};

shrine_saint_projectile_source_add = function(_center_x, _center_y, _radius, _saint_amount)
{
	if (is_corrupted || !instance_exists(o_corruption_grid))
	{
		return;
	}

	var _corruption_grid = instance_find(o_corruption_grid, 0);

	if (variable_instance_exists(_corruption_grid, "saint_source_circle_add"))
	{
		_corruption_grid.saint_source_circle_add(_center_x, _center_y, _radius);
		array_push(
			saint_projectile_sources,
			{
				x: _center_x,
				y: _center_y,
				radius: _radius
			}
		);
	}

	if (variable_instance_exists(_corruption_grid, "saint_circle_set"))
	{
		_corruption_grid.saint_circle_set(_center_x, _center_y, _radius, _saint_amount);
	}
};

shrine_saint_projectile_create = function(_target_x, _target_y, _launch_delay_seconds = 0)
{
	var _projectile_x = x;
	var _projectile_y = y + night_saint_projectile_spawn_offset_y;
	var _projectile = instance_create_layer(_projectile_x, _projectile_y, night_saint_projectile_layer_name, o_projectile);
	var _projectile_distance = point_distance(_projectile_x, _projectile_y, _target_x, _target_y);
	var _flight_time_seconds = clamp(
		_projectile_distance / _projectile.projectile_speed,
		_projectile.minimum_flight_time,
		_projectile.maximum_flight_time
	);

	_projectile.start_x = _projectile_x;
	_projectile.start_y = _projectile_y;
	_projectile.target_x = _target_x;
	_projectile.target_y = _target_y;
	_projectile.projectile_type = PROJECTILE_TYPE.CLEANSE;
	_projectile.effect_radius = night_saint_projectile_radius;
	_projectile.cleanse_amount = 1;
	_projectile.saint_amount = 1;
	_projectile.damage_faction = UNIT_FACTION.ENEMY;
	_projectile.source_instance = id;
	_projectile.flight_time = _flight_time_seconds * room_speed;
	_projectile.launch_delay_timer = _launch_delay_seconds * room_speed;
	_projectile.depth = night_saint_projectile_draw_depth;

	return _projectile;
};

shrine_cleanse_projectile_create = function(_target_x, _target_y, _launch_delay_seconds = 0)
{
	var _projectile_x = x;
	var _projectile_y = y + night_saint_projectile_spawn_offset_y;
	var _projectile = instance_create_layer(_projectile_x, _projectile_y, night_saint_projectile_layer_name, o_projectile);
	var _projectile_distance = point_distance(_projectile_x, _projectile_y, _target_x, _target_y);
	var _flight_time_seconds = clamp(
		_projectile_distance / _projectile.projectile_speed,
		_projectile.minimum_flight_time,
		_projectile.maximum_flight_time
	);

	_projectile.start_x = _projectile_x;
	_projectile.start_y = _projectile_y;
	_projectile.target_x = _target_x;
	_projectile.target_y = _target_y;
	_projectile.projectile_type = PROJECTILE_TYPE.CLEANSE;
	_projectile.effect_radius = day_volley_cleanse_radius;
	_projectile.cleanse_amount = day_volley_cleanse_amount;
	_projectile.saint_amount = 0;
	_projectile.damage_faction = UNIT_FACTION.ENEMY;
	_projectile.source_instance = id;
	_projectile.flight_time = _flight_time_seconds * room_speed;
	_projectile.launch_delay_timer = _launch_delay_seconds * room_speed;
	_projectile.depth = night_saint_projectile_draw_depth;

	return _projectile;
};

shrine_taint_target_find = function()
{
	if (!instance_exists(o_corruption_grid))
	{
		return noone;
	}

	var _corruption_grid = instance_find(o_corruption_grid, 0);
	var _cell_size = _corruption_grid.cell_size;
	var _left_cell = clamp(floor((x - day_volley_taint_search_radius) / _cell_size), 0, _corruption_grid.grid_width - 1);
	var _right_cell = clamp(floor((x + day_volley_taint_search_radius) / _cell_size), 0, _corruption_grid.grid_width - 1);
	var _top_cell = clamp(floor((y - day_volley_taint_search_radius) / _cell_size), 0, _corruption_grid.grid_height - 1);
	var _bottom_cell = clamp(floor((y + day_volley_taint_search_radius) / _cell_size), 0, _corruption_grid.grid_height - 1);
	var _targets = [];

	for (var _cell_x = _left_cell; _cell_x <= _right_cell; ++_cell_x)
	{
		for (var _cell_y = _top_cell; _cell_y <= _bottom_cell; ++_cell_y)
		{
			if (variable_instance_exists(_corruption_grid, "saint_grid")
				&& ds_grid_get(_corruption_grid.saint_grid, _cell_x, _cell_y) > 0)
			{
				continue;
			}

			var _corruption = ds_grid_get(_corruption_grid.corruption_grid, _cell_x, _cell_y);

			if (_corruption <= 0)
			{
				continue;
			}

			var _cell_center_x = (_cell_x * _cell_size) + (_cell_size * 0.5);
			var _cell_center_y = (_cell_y * _cell_size) + (_cell_size * 0.5);

			if (point_distance(x, y, _cell_center_x, _cell_center_y) <= day_volley_taint_search_radius)
			{
				array_push(
					_targets,
					{
						x: _cell_center_x,
						y: _cell_center_y
					}
				);
			}
		}
	}

	if (array_length(_targets) <= 0)
	{
		return noone;
	}

	return _targets[irandom(array_length(_targets) - 1)];
};

shrine_day_volley_update = function()
{
	if (global.day_phase != DAY_PHASE.DAY)
	{
		return;
	}

	var _day_index = 0;

	if (instance_exists(o_game_controller))
	{
		var _game_controller = instance_find(o_game_controller, 0);

		if (variable_instance_exists(_game_controller, "night_attack_night_index"))
		{
			_day_index = _game_controller.night_attack_night_index;
		}
	}

	if (day_volley_last_day_index == _day_index)
	{
		return;
	}

	day_volley_last_day_index = _day_index;

	var _taint_target = shrine_taint_target_find();

	if (!is_struct(_taint_target))
	{
		return;
	}

	var _projectile_count = irandom_range(day_volley_projectile_count_min, day_volley_projectile_count_max);

	for (var _projectile_index = 0; _projectile_index < _projectile_count; ++_projectile_index)
	{
		var _spread_direction = random(360);
		var _spread_distance = sqrt(random(1)) * day_volley_target_spread_radius;
		var _target_x = _taint_target.x + lengthdir_x(_spread_distance, _spread_direction);
		var _target_y = _taint_target.y + lengthdir_y(_spread_distance, _spread_direction);
		var _launch_delay_seconds = random(day_volley_launch_time);

		shrine_cleanse_projectile_create(_target_x, _target_y, _launch_delay_seconds);
	}
};

shrine_saint_direction_offset_get = function()
{
	if (night_saint_direction_index <= 0)
	{
		return 0;
	}

	var _angle_multiplier = ceil(night_saint_direction_index / 2);
	var _angle_offset = _angle_multiplier * night_saint_direction_angle_step;
	var _is_clockwise_turn = (night_saint_direction_index mod 2) == 1;

	// GameMaker visual clockwise is negative because Y grows downward.
	return _is_clockwise_turn ? -_angle_offset : _angle_offset;
};

shrine_saint_front_distance_get = function(_shot_direction)
{
	var _front_distance = night_saint_front_distance;
	var _source_count = array_length(saint_projectile_sources);

	for (var _source_index = 0; _source_index < _source_count; ++_source_index)
	{
		var _source = saint_projectile_sources[_source_index];
		var _source_distance = point_distance(x, y, _source.x, _source.y);
		var _source_direction = point_direction(x, y, _source.x, _source.y);
		var _direction_difference = abs(angle_difference(_shot_direction, _source_direction));

		if (_direction_difference <= night_saint_direction_match_angle)
		{
			_front_distance = max(_front_distance, _source_distance + (_source.radius * 0.6));
		}
	}

	return _front_distance;
};

shrine_night_saint_projectiles_fire = function()
{
	if (is_corrupted || !instance_exists(o_cannon))
	{
		return;
	}

	var _cannon = instance_find(o_cannon, 0);
	var _base_direction = point_direction(x, y, _cannon.x, _cannon.y);
	var _shot_direction = _base_direction + shrine_saint_direction_offset_get();
	var _side_direction = _shot_direction + 90;
	var _distance_to_cannon = point_distance(x, y, _cannon.x, _cannon.y);
	var _direction_max_distance = min(
		night_saint_direction_max_distance,
		_distance_to_cannon - (night_saint_projectile_radius * 0.25)
	);
	var _start_distance = shrine_saint_front_distance_get(_shot_direction);
	var _max_forward_distance = max(_start_distance, _direction_max_distance);
	var _furthest_forward_distance = _start_distance;

	for (var _projectile_index = 0; _projectile_index < night_saint_projectile_count; ++_projectile_index)
	{
		var _forward_distance = _start_distance + (night_saint_projectile_step * _projectile_index);
		_forward_distance += random_range(-night_saint_projectile_forward_jitter, night_saint_projectile_forward_jitter);
		_forward_distance = clamp(_forward_distance, _start_distance, _max_forward_distance);

		var _side_offset = random_range(-night_saint_projectile_side_jitter, night_saint_projectile_side_jitter);
		var _target_x = x + lengthdir_x(_forward_distance, _shot_direction) + lengthdir_x(_side_offset, _side_direction);
		var _target_y = y + lengthdir_y(_forward_distance, _shot_direction) + lengthdir_y(_side_offset, _side_direction);
		var _launch_delay_seconds = random(night_saint_projectile_launch_time);

		shrine_saint_projectile_create(_target_x, _target_y, _launch_delay_seconds);
		_furthest_forward_distance = max(_furthest_forward_distance, _forward_distance);
	}

	night_saint_front_distance = min(
		_max_forward_distance,
		_furthest_forward_distance + (night_saint_projectile_radius * 0.6)
	);

	if (night_saint_front_distance >= _max_forward_distance)
	{
		night_saint_direction_index++;
		night_saint_front_distance = night_saint_front_start_distance;
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
	shrine_saint_source_unregister();
	shrine_saint_projectile_sources_unregister();

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

shrine_saint_source_register();

on_projectile_hit = function(_projectile_type)
{
	if (!is_attackable)
	{
		return;
	}

	if (_projectile_type == PROJECTILE_TYPE.DAMAGE)
	{
		unit_damage_receive(BALANCE_PROJECTILE_DAMAGE_AMOUNT, UNIT_FACTION.NOONE);
	}
};
