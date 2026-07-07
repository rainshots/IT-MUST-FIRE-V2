// Initialize shared map object state.
event_inherited();

// Holy tower durability.
max_hp = BALANCE_HOLY_TOWER_MAX_HP;
hp = max_hp;
max_corruption = 100;
corruption = 0;
is_destroyed = false;
reinforcement_next_hp_share = 1 - BALANCE_HOLY_TOWER_REINFORCEMENT_HP_STEP_SHARE;
destroy_knights_spawned = false;
owner_shrine = noone;

// Holy tower combat settings.
shoot_radius = BALANCE_HOLY_TOWER_SHOOT_RADIUS;
damage = BALANCE_HOLY_TOWER_DAMAGE;
reload_time = BALANCE_HOLY_TOWER_RELOAD_TIME * room_speed;
reload_timer = 0;
target_instance = noone;
assist_call_radius = BALANCE_UNIT_ASSIST_CALL_RADIUS;
projectile_spawn_offset_y = -20;
projectile_layer_name = "Instances";
projectile_effect_radius = BALANCE_PROJECTILE_EFFECT_RADIUS;
projectile_draw_depth = BALANCE_PARTICLE_SYSTEM_TOP_DEPTH - 50;
night_volley_projectile_count = BALANCE_HOLY_TOWER_NIGHT_VOLLEY_PROJECTILE_COUNT;
night_volley_taint_search_radius = BALANCE_HOLY_TOWER_NIGHT_VOLLEY_TAINT_SEARCH_RADIUS;
night_volley_target_spread_radius = BALANCE_HOLY_TOWER_NIGHT_VOLLEY_TARGET_SPREAD_RADIUS;
night_volley_launch_time = BALANCE_HOLY_TOWER_NIGHT_VOLLEY_LAUNCH_TIME;
night_volley_cleanse_radius = BALANCE_HOLY_TOWER_NIGHT_VOLLEY_CLEANSE_RADIUS;
night_volley_cleanse_amount = BALANCE_HOLY_TOWER_NIGHT_VOLLEY_CLEANSE_AMOUNT;
night_volley_last_night_index = -1;

// Saint source settings.
saint_radius = BALANCE_HOLY_TOWER_TAINT_CLEANSE_RADIUS;
saint_source_registered = false;

// Range drawing settings.
radius_line_width = 2;
radius_alpha = 0.85;

// Attack feedback shows the tower shot for a short moment.
attack_feedback_time = BALANCE_HOLY_TOWER_ATTACK_FEEDBACK_TIME * room_speed;
attack_feedback_timer = 0;
attack_feedback_target = noone;
attack_feedback_target_x = x;
attack_feedback_target_y = y;
attack_feedback_line_width = 2;

// Tooltip lines describe tower behavior.
tooltip_lines = [
	"Damage: Takes damage. Destroy it to expose Shrine",
	"Saint: Nearby ground resists Taint",
	"Summon: No effect yet"
];

holy_tower_enemy_difficulty_get = function(_enemy_object)
{
	if (_enemy_object == o_enemy_archer)
	{
		return BALANCE_ENEMY_ARCHER_DIFFICULTY;
	}
	else if (_enemy_object == o_enemy_knight)
	{
		return BALANCE_ENEMY_KNIGHT_DIFFICULTY;
	}
	else if (_enemy_object == o_enemy_mage)
	{
		return BALANCE_ENEMY_MAGE_DIFFICULTY;
	}

	return 1;
};

holy_tower_enemy_spawn = function(_enemy_object)
{
	var _spawn_direction = random(360);
	var _spawn_distance = random_range(
		BALANCE_HOLY_TOWER_REINFORCEMENT_SPAWN_RADIUS_MIN,
		BALANCE_HOLY_TOWER_REINFORCEMENT_SPAWN_RADIUS_MAX
	);
	var _enemy = instance_create_layer(
		x + lengthdir_x(_spawn_distance, _spawn_direction),
		y + lengthdir_y(_spawn_distance, _spawn_direction),
		"Instances",
		_enemy_object
	);

	if (instance_exists(_enemy))
	{
		_enemy.unit_can_attack_cannon = true;
		_enemy.holy_tower_reinforcement_waits_for_night = (global.day_phase == DAY_PHASE.NIGHT);
		_enemy.owner_garnizon = noone;
		_enemy.guard_target = noone;

		if (instance_exists(o_game_controller))
		{
			var _game_controller = instance_find(o_game_controller, 0);

			if (variable_instance_exists(_game_controller, "enemy_night_hp_scale_apply"))
			{
				_game_controller.enemy_night_hp_scale_apply(_enemy);
			}
		}
	}

	return _enemy;
};

holy_tower_random_reinforcements_spawn = function(_difficulty_budget)
{
	var _enemy_objects = [o_enemy_knight, o_enemy_mage, o_enemy_archer];
	var _minimum_difficulty = BALANCE_ENEMY_ARCHER_DIFFICULTY;
	var _remaining_difficulty = max(0, _difficulty_budget);
	var _spawn_safety_limit = 100;

	for (var _spawn_safety_count = 0; _spawn_safety_count < _spawn_safety_limit; ++_spawn_safety_count)
	{
		if (_remaining_difficulty < _minimum_difficulty)
		{
			break;
		}

		var _eligible_enemy_objects = [];
		var _enemy_count = array_length(_enemy_objects);

		for (var _enemy_index = 0; _enemy_index < _enemy_count; ++_enemy_index)
		{
			var _enemy_object = _enemy_objects[_enemy_index];

			if (holy_tower_enemy_difficulty_get(_enemy_object) <= _remaining_difficulty)
			{
				array_push(_eligible_enemy_objects, _enemy_object);
			}
		}

		if (array_length(_eligible_enemy_objects) <= 0)
		{
			break;
		}

		var _chosen_enemy_object = _eligible_enemy_objects[irandom(array_length(_eligible_enemy_objects) - 1)];
		_remaining_difficulty -= holy_tower_enemy_difficulty_get(_chosen_enemy_object);
		holy_tower_enemy_spawn(_chosen_enemy_object);
	}
};

holy_tower_destroy_knights_spawn = function()
{
	if (destroy_knights_spawned)
	{
		return;
	}

	destroy_knights_spawned = true;

	for (var _knight_index = 0; _knight_index < BALANCE_HOLY_TOWER_DESTROY_KNIGHT_COUNT; ++_knight_index)
	{
		holy_tower_enemy_spawn(o_enemy_knight);
	}
};

holy_tower_reinforcement_thresholds_update = function()
{
	if (is_destroyed)
	{
		return;
	}

	var _hp_share = hp / max(1, max_hp);
	var _step_share = BALANCE_HOLY_TOWER_REINFORCEMENT_HP_STEP_SHARE;
	var _safety_limit = 20;

	for (var _safety_count = 0; _safety_count < _safety_limit; ++_safety_count)
	{
		if (_hp_share > reinforcement_next_hp_share || reinforcement_next_hp_share <= 0)
		{
			break;
		}

		holy_tower_random_reinforcements_spawn(BALANCE_HOLY_TOWER_REINFORCEMENT_DIFFICULTY);
		reinforcement_next_hp_share -= _step_share;
	}
};

holy_tower_saint_source_register = function()
{
	if (saint_source_registered || !instance_exists(o_corruption_grid))
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

holy_tower_saint_source_unregister = function()
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

destroy_holy_tower = function()
{
	if (is_destroyed)
	{
		return;
	}

	if (variable_global_exists("construction_sound_play"))
	{
		global.construction_sound_play();
	}

	holy_tower_destroy_knights_spawn();

	if (instance_exists(owner_shrine)
		&& variable_instance_exists(owner_shrine, "shrine_protection_tower_destroyed"))
	{
		owner_shrine.shrine_protection_tower_destroyed(id);
	}

	// The destroyed tower remains as a landmark but no longer attacks or supports Saint.
	holy_tower_saint_source_unregister();
	is_destroyed = true;
	hp = 0;
	target_instance = noone;
	attack_feedback_timer = 0;
	sprite_index = s_holy_tower_destroyed;
	image_index = 0;
	image_speed = 0;
};

holy_tower_saint_source_register();

holy_tower_damage_receive = function(_damage_amount, _is_critical = false, _show_popup = true)
{
	if (is_destroyed || hp <= 0 || _damage_amount <= 0)
	{
		return 0;
	}

	var _applied_damage = min(_damage_amount, hp);
	hp = max(hp - _damage_amount, 0);

	if (_show_popup)
	{
		damage_popup_create(x, y, _applied_damage, UNIT_FACTION.ENEMY, _is_critical);
	}

	holy_tower_reinforcement_thresholds_update();

	if (hp <= 0)
	{
		destroy_holy_tower();
	}

	return _applied_damage;
};

unit_damage_receive = function(_damage_amount, _source_faction = UNIT_FACTION.NOONE, _is_critical = false, _can_trigger_soul_chain = true, _source_instance = noone)
{
	return holy_tower_damage_receive(_damage_amount, _is_critical, true);
};

// Damage projectiles can destroy the holy tower.
on_damage_projectile_hit = function()
{
	if (is_destroyed)
	{
		return;
	}

	holy_tower_damage_receive(BALANCE_PROJECTILE_DAMAGE_AMOUNT, false, false);
};

on_projectile_hit = function(_projectile_type)
{
	if (_projectile_type == PROJECTILE_TYPE.DAMAGE)
	{
		on_damage_projectile_hit();
	}
};

call_nearby_friendly_units_for_help = function(_attacked_unit)
{
	if (!instance_exists(_attacked_unit))
	{
		return;
	}

	// The attacked unit remembers the tower immediately.
	_attacked_unit.alert_target = id;
	_attacked_unit.alert_target_timer = _attacked_unit.alert_target_time;

	var _nearby_units = ds_list_create();
	var _nearby_unit_count = collision_circle_list(_attacked_unit.x, _attacked_unit.y, assist_call_radius, o_friendly_units, false, true, _nearby_units, false);

	// Nearby friendly units receive the same threat and can help attack the tower.
	for (var _unit_index = 0; _unit_index < _nearby_unit_count; ++_unit_index)
	{
		var _friendly_unit = _nearby_units[| _unit_index];

		if (instance_exists(_friendly_unit))
		{
			_friendly_unit.alert_target = id;
			_friendly_unit.alert_target_timer = _friendly_unit.alert_target_time;
		}
	}

	ds_list_destroy(_nearby_units);
};

holy_tower_projectile_create = function(_target_x, _target_y)
{
	var _projectile_x = x;
	var _projectile_y = y + projectile_spawn_offset_y;
	var _projectile = instance_create_layer(_projectile_x, _projectile_y, projectile_layer_name, o_projectile);
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
	_projectile.projectile_type = PROJECTILE_TYPE.DAMAGE;
	_projectile.effect_radius = projectile_effect_radius;
	_projectile.damage_amount = damage;
	_projectile.damage_faction = UNIT_FACTION.ENEMY;
	_projectile.source_instance = id;
	_projectile.flight_time = _flight_time_seconds * room_speed;
	_projectile.depth = projectile_draw_depth;

	return _projectile;
};

holy_tower_cleanse_projectile_create = function(_target_x, _target_y, _launch_delay_seconds = 0)
{
	var _projectile_x = x;
	var _projectile_y = y + projectile_spawn_offset_y;
	var _projectile = instance_create_layer(_projectile_x, _projectile_y, projectile_layer_name, o_projectile);
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
	_projectile.effect_radius = night_volley_cleanse_radius;
	_projectile.cleanse_amount = night_volley_cleanse_amount;
	_projectile.source_instance = id;
	_projectile.flight_time = _flight_time_seconds * room_speed;
	_projectile.launch_delay_timer = _launch_delay_seconds * room_speed;
	_projectile.depth = projectile_draw_depth;

	return _projectile;
};

holy_tower_is_revealed_by_fog = function()
{
	if (!global.fog_of_war_visible)
	{
		return true;
	}

	if (!instance_exists(o_fog_of_war))
	{
		return false;
	}

	var _fog_of_war = instance_find(o_fog_of_war, 0);

	// Tainted ground is the main player-owned vision source.
	if (instance_exists(o_corruption_grid))
	{
		var _corruption_grid = instance_find(o_corruption_grid, 0);
		var _taint_reveal_radius = _fog_of_war.reveal_radius_in_cells * _fog_of_war.cell_size;

		if (variable_instance_exists(_corruption_grid, "circle_has_full_corruption")
			&& _corruption_grid.circle_has_full_corruption(x, y, _taint_reveal_radius))
		{
			return true;
		}
	}

	// Combat demons reveal a smaller area during the night.
	if (global.day_phase == DAY_PHASE.NIGHT && _fog_of_war.demon_reveal_radius_in_pixels > 0)
	{
		var _friendly_count = instance_number(o_friendly_units);

		for (var _friendly_index = 0; _friendly_index < _friendly_count; ++_friendly_index)
		{
			var _friendly_unit = instance_find(o_friendly_units, _friendly_index);
			var _is_visible_demon = instance_exists(_friendly_unit)
				&& variable_instance_exists(_friendly_unit, "demon_type")
				&& _friendly_unit.demon_type != DEMON_TYPE.NONE
				&& (!variable_instance_exists(_friendly_unit, "hp") || _friendly_unit.hp > 0)
				&& (!variable_instance_exists(_friendly_unit, "is_being_dragged") || !_friendly_unit.is_being_dragged);

			if (_is_visible_demon
				&& point_distance(x, y, _friendly_unit.x, _friendly_unit.y) <= _fog_of_war.demon_reveal_radius_in_pixels)
			{
				return true;
			}
		}
	}

	// Captured vision towers are also player-owned vision.
	if (instance_exists(o_tower_vision))
	{
		var _vision_tower_count = instance_number(o_tower_vision);

		for (var _vision_tower_index = 0; _vision_tower_index < _vision_tower_count; ++_vision_tower_index)
		{
			var _vision_tower = instance_find(o_tower_vision, _vision_tower_index);
			var _tower_radius = BALANCE_TOWER_VISION_RADIUS;
			var _tower_reveals_fog = instance_exists(_vision_tower)
				&& variable_instance_exists(_vision_tower, "is_captured")
				&& _vision_tower.is_captured;

			if (_tower_reveals_fog)
			{
				if (variable_instance_exists(_vision_tower, "vision_radius"))
				{
					_tower_radius = _vision_tower.vision_radius;
				}

				if (point_distance(x, y, _vision_tower.x, _vision_tower.y) <= _tower_radius)
				{
					return true;
				}
			}
		}
	}

	return false;
};

holy_tower_taint_target_find = function()
{
	if (!instance_exists(o_corruption_grid))
	{
		return noone;
	}

	var _corruption_grid = instance_find(o_corruption_grid, 0);
	var _cell_size = _corruption_grid.cell_size;
	var _left_cell = clamp(floor((x - night_volley_taint_search_radius) / _cell_size), 0, _corruption_grid.grid_width - 1);
	var _right_cell = clamp(floor((x + night_volley_taint_search_radius) / _cell_size), 0, _corruption_grid.grid_width - 1);
	var _top_cell = clamp(floor((y - night_volley_taint_search_radius) / _cell_size), 0, _corruption_grid.grid_height - 1);
	var _bottom_cell = clamp(floor((y + night_volley_taint_search_radius) / _cell_size), 0, _corruption_grid.grid_height - 1);
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

			if (point_distance(x, y, _cell_center_x, _cell_center_y) <= night_volley_taint_search_radius)
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

holy_tower_night_volley_update = function()
{
	if (global.day_phase != DAY_PHASE.NIGHT)
	{
		return;
	}

	var _night_index = 0;

	if (instance_exists(o_game_controller))
	{
		var _game_controller = instance_find(o_game_controller, 0);

		if (variable_instance_exists(_game_controller, "night_attack_night_index"))
		{
			_night_index = _game_controller.night_attack_night_index;
		}
	}

	if (night_volley_last_night_index == _night_index)
	{
		return;
	}

	night_volley_last_night_index = _night_index;

	if (!holy_tower_is_revealed_by_fog())
	{
		return;
	}

	var _taint_target = holy_tower_taint_target_find();

	if (!is_struct(_taint_target))
	{
		return;
	}

	for (var _projectile_index = 0; _projectile_index < night_volley_projectile_count; ++_projectile_index)
	{
		var _spread_direction = random(360);
		var _spread_distance = sqrt(random(1)) * night_volley_target_spread_radius;
		var _target_x = _taint_target.x + lengthdir_x(_spread_distance, _spread_direction);
		var _target_y = _taint_target.y + lengthdir_y(_spread_distance, _spread_direction);
		var _launch_delay_seconds = random(night_volley_launch_time);

		holy_tower_cleanse_projectile_create(_target_x, _target_y, _launch_delay_seconds);
	}
};
