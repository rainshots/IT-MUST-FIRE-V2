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

// Holy tower combat settings.
shoot_radius = BALANCE_HOLY_TOWER_SHOOT_RADIUS;
damage = BALANCE_HOLY_TOWER_DAMAGE;
reload_time = BALANCE_HOLY_TOWER_RELOAD_TIME * room_speed;
reload_timer = 0;
target_instance = noone;
assist_call_radius = BALANCE_UNIT_ASSIST_CALL_RADIUS;

// Holy ground settings.
holy_radius_in_cells = BALANCE_HOLY_TOWER_HOLY_RADIUS_IN_CELLS;
holy_radius = holy_radius_in_cells * 100;
is_holy_area_active = false;

// Range drawing settings.
radius_line_width = 2;
radius_alpha = 0.32;

// Attack feedback shows the tower shot for a short moment.
attack_feedback_time = BALANCE_HOLY_TOWER_ATTACK_FEEDBACK_TIME * room_speed;
attack_feedback_timer = 0;
attack_feedback_target = noone;
attack_feedback_target_x = x;
attack_feedback_target_y = y;
attack_feedback_line_width = 2;

// Tooltip lines describe tower behavior.
tooltip_lines = [
	"Damage: Takes damage. Taints holy area at 0 HP",
	"Taint: Blocks nearby ground Taint",
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

make_nearby_ground_holy = function()
{
	if (!is_holy_area_active && instance_exists(o_corruption_grid))
	{
		var _corruption_grid = instance_find(o_corruption_grid, 0);
		_corruption_grid.make_circle_holy(x, y, holy_radius);
		is_holy_area_active = true;
	}
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

	if (is_holy_area_active && instance_exists(o_corruption_grid))
	{
		var _corruption_grid = instance_find(o_corruption_grid, 0);
		_corruption_grid.remove_circle_holy(x, y, holy_radius);
		is_holy_area_active = false;
	}

	// The destroyed tower remains as a landmark but no longer blocks or attacks.
	is_destroyed = true;
	hp = 0;
	target_instance = noone;
	attack_feedback_timer = 0;
	sprite_index = s_holy_tower_destroyed;
	image_index = 0;
	image_speed = 0;
};

// Holy tower creates protected holy ground when it appears.
make_nearby_ground_holy();

// Damage projectiles can destroy the holy tower.
on_damage_projectile_hit = function()
{
	if (is_destroyed)
	{
		return;
	}

	hp = max(hp - BALANCE_PROJECTILE_DAMAGE_AMOUNT, 0);
	holy_tower_reinforcement_thresholds_update();

	if (hp <= 0)
	{
		destroy_holy_tower();
	}
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
