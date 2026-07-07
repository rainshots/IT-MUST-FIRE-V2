// Initialize shared map object state.
event_inherited();

// House durability and ground protection.
max_hp = BALANCE_HOUSE_MAX_HP;
hp = max_hp;
max_corruption = 100;
corruption = 0;
saint_radius = BALANCE_HOUSE_SAINT_RADIUS;
saint_source_registered = false;
is_destroyed = false;

// House guards are stored virtually while the house is outside fog vision.
house_unit_options = [
	o_enemy_peasant,
	o_enemy_archer,
	o_enemy_mage,
	o_enemy_knight
];
house_unit_object = house_unit_options[irandom(array_length(house_unit_options) - 1)];
house_unit_limit = BALANCE_HOUSE_INITIAL_UNIT_LIMIT;
house_alive_unit_count = 0;
house_was_visible = false;
house_guard_radius = BALANCE_HOUSE_GUARD_RADIUS;
house_spawn_radius = BALANCE_HOUSE_SPAWN_RADIUS;
house_guard_assist_radius = BALANCE_HOUSE_GUARD_ASSIST_RADIUS;
house_combat_spawn_radius = BALANCE_HOUSE_COMBAT_SPAWN_RADIUS;
house_combat_spawn_interval = BALANCE_HOUSE_COMBAT_SPAWN_INTERVAL * room_speed;
house_combat_spawn_timer = irandom(max(round(house_combat_spawn_interval) - 1, 0));
house_visibility_check_interval = BALANCE_HOUSE_VISIBILITY_CHECK_INTERVAL;
house_visibility_check_timer = irandom(house_visibility_check_interval - 1);
house_visible_sample_radius = BALANCE_HOUSE_VISIBLE_SAMPLE_RADIUS;
house_guard_active_player_radius = BALANCE_HOUSE_GUARD_ACTIVE_PLAYER_RADIUS;
house_guard_camera_padding = BALANCE_HOUSE_GUARD_CAMERA_PADDING;

// Tooltip lines describe house behavior.
tooltip_lines = [
	"House.",
	"Contains enemy troops. Their numbers grow each day.",
	"Has a chance to drop an Artifact when destroyed.",
	"Spreads Taint around itself when destroyed."
];

house_saint_source_register = function()
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

house_saint_source_unregister = function()
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

house_destroyed_ground_corrupt = function()
{
	if (!instance_exists(o_corruption_grid))
	{
		return;
	}

	var _corruption_grid = instance_find(o_corruption_grid, 0);

	// Remove the house Saint shield before adding Taint in the same radius.
	if (variable_instance_exists(_corruption_grid, "saint_circle_clear"))
	{
		_corruption_grid.saint_circle_clear(x, y, saint_radius);
	}

	if (variable_instance_exists(_corruption_grid, "corrupt_circle"))
	{
		_corruption_grid.corrupt_circle(x, y, saint_radius, 1);
	}
};

house_guard_visible_count_get = function()
{
	var _guard_count = 0;
	var _enemy_count = instance_number(o_enemy_units);

	for (var _enemy_index = 0; _enemy_index < _enemy_count; ++_enemy_index)
	{
		var _enemy = instance_find(o_enemy_units, _enemy_index);

		if (instance_exists(_enemy)
			&& variable_instance_exists(_enemy, "owner_house")
			&& _enemy.owner_house == id
			&& (!variable_instance_exists(_enemy, "hp") || _enemy.hp > 0))
		{
			_guard_count++;
		}
	}

	return _guard_count;
};

house_guards_destroy = function()
{
	var _enemy_count = instance_number(o_enemy_units);

	for (var _enemy_index = _enemy_count - 1; _enemy_index >= 0; --_enemy_index)
	{
		var _enemy = instance_find(o_enemy_units, _enemy_index);

		if (instance_exists(_enemy)
			&& variable_instance_exists(_enemy, "owner_house")
			&& _enemy.owner_house == id)
		{
			instance_destroy(_enemy);
		}
	}
};

house_is_visible_by_fog = function()
{
	if (!variable_global_exists("fog_of_war_visible")
		|| !global.fog_of_war_visible
		|| !instance_exists(o_fog_of_war))
	{
		return true;
	}

	var _fog_of_war = instance_find(o_fog_of_war, 0);

	if (!variable_instance_exists(_fog_of_war, "fog_cell_is_seen"))
	{
		return true;
	}

	if (_fog_of_war.fog_cell_is_seen(x, y))
	{
		return true;
	}

	var _sample_count = 4;

	for (var _sample_index = 0; _sample_index < _sample_count; ++_sample_index)
	{
		var _sample_direction = _sample_index * (360 / _sample_count);
		var _sample_x = x + lengthdir_x(house_visible_sample_radius, _sample_direction);
		var _sample_y = y + lengthdir_y(house_visible_sample_radius, _sample_direction);

		if (_fog_of_war.fog_cell_is_seen(_sample_x, _sample_y))
		{
			return true;
		}
	}

	return false;
};

house_is_inside_camera = function()
{
	if (!instance_exists(o_camera_controller))
	{
		return true;
	}

	var _camera_controller = instance_find(o_camera_controller, 0);
	var _camera_x = camera_get_view_x(_camera_controller.camera_id);
	var _camera_y = camera_get_view_y(_camera_controller.camera_id);
	var _camera_width = camera_get_view_width(_camera_controller.camera_id);
	var _camera_height = camera_get_view_height(_camera_controller.camera_id);
	var _camera_left = _camera_x - house_guard_camera_padding;
	var _camera_top = _camera_y - house_guard_camera_padding;
	var _camera_right = _camera_x + _camera_width + house_guard_camera_padding;
	var _camera_bottom = _camera_y + _camera_height + house_guard_camera_padding;

	return x >= _camera_left
		&& x <= _camera_right
		&& y >= _camera_top
		&& y <= _camera_bottom;
};

house_player_unit_is_near = function()
{
	var _active_radius_squared = house_guard_active_player_radius * house_guard_active_player_radius;
	var _friendly_count = instance_number(o_friendly_units);

	for (var _friendly_index = 0; _friendly_index < _friendly_count; ++_friendly_index)
	{
		var _friendly_unit = instance_find(o_friendly_units, _friendly_index);

		if (!instance_exists(_friendly_unit)
			|| !variable_instance_exists(_friendly_unit, "hp")
			|| _friendly_unit.hp <= 0)
		{
			continue;
		}

		var _friendly_distance_x = _friendly_unit.x - x;
		var _friendly_distance_y = _friendly_unit.y - y;
		var _friendly_distance_squared = (_friendly_distance_x * _friendly_distance_x) + (_friendly_distance_y * _friendly_distance_y);

		if (_friendly_distance_squared <= _active_radius_squared)
		{
			return true;
		}
	}

	if (!variable_global_exists("cultists"))
	{
		return false;
	}

	var _cultist_count = array_length(global.cultists);

	for (var _cultist_index = 0; _cultist_index < _cultist_count; ++_cultist_index)
	{
		var _cultist = global.cultists[_cultist_index];

		if (!instance_exists(_cultist)
			|| !_cultist.visible
			|| !variable_instance_exists(_cultist, "hp")
			|| _cultist.hp <= 0)
		{
			continue;
		}

		var _cultist_distance_x = _cultist.x - x;
		var _cultist_distance_y = _cultist.y - y;
		var _cultist_distance_squared = (_cultist_distance_x * _cultist_distance_x) + (_cultist_distance_y * _cultist_distance_y);

		if (_cultist_distance_squared <= _active_radius_squared)
		{
			return true;
		}
	}

	return false;
};

house_should_keep_guards_active = function()
{
	if (!house_is_visible_by_fog())
	{
		return false;
	}

	return house_is_inside_camera()
		|| house_player_unit_is_near();
};

house_guard_create = function()
{
	var _spawn_direction = random(360);
	var _spawn_distance = random(house_spawn_radius);
	var _spawn_x = x + lengthdir_x(_spawn_distance, _spawn_direction);
	var _spawn_y = y + lengthdir_y(_spawn_distance, _spawn_direction);
	var _unit = instance_create_layer(_spawn_x, _spawn_y, "Instances", house_unit_object);

	if (!instance_exists(_unit))
	{
		return noone;
	}

	_unit.owner_house = id;
	_unit.guard_target = id;
	_unit.guard_radius = house_guard_radius;
	_unit.unit_can_attack_cannon = false;
	_unit.is_night_attack_unit = false;
	_unit.ignored_for_night_end = true;
	_unit.owner_garnizon = noone;

	return _unit;
};

house_destroyed_guard_create = function()
{
	var _spawn_direction = random(360);
	var _spawn_distance = random(house_spawn_radius);
	var _spawn_x = x + lengthdir_x(_spawn_distance, _spawn_direction);
	var _spawn_y = y + lengthdir_y(_spawn_distance, _spawn_direction);
	var _unit = instance_create_layer(_spawn_x, _spawn_y, "Instances", house_unit_object);

	if (!instance_exists(_unit))
	{
		return noone;
	}

	// These guards have no house to return to, so the next morning cleans them up.
	_unit.owner_house = noone;
	_unit.guard_target = noone;
	_unit.unit_can_attack_cannon = false;
	_unit.is_night_attack_unit = true;
	_unit.ignored_for_night_end = false;
	_unit.destroyed_house_unit = true;
	_unit.owner_garnizon = noone;

	return _unit;
};

house_destroyed_guards_spawn = function()
{
	var _spawn_count = floor(floor(house_unit_limit) / 2);

	for (var _spawn_index = 0; _spawn_index < _spawn_count; ++_spawn_index)
	{
		house_destroyed_guard_create();
	}
};

house_artifact_drop_try = function()
{
	if (random(1) >= BALANCE_HOUSE_ARTIFACT_DROP_CHANCE)
	{
		return;
	}

	var _drop_direction = random(360);
	var _drop_distance = random_range(12, 42);
	var _drop_x = x + lengthdir_x(_drop_distance, _drop_direction);
	var _drop_y = y + lengthdir_y(_drop_distance, _drop_direction);

	instance_create_layer(_drop_x, _drop_y, "Instances", o_artifact);
};

house_ruins_create = function()
{
	var _ruins_layer = "Instances";
	var _ruins = instance_create_layer(x, y, _ruins_layer, o_tower_ruins);

	if (!instance_exists(_ruins))
	{
		return;
	}

	// The original house instance is removed, so the ruins keep only the visual shell.
	_ruins.sprite_index = s_house2_destroyed;
	_ruins.image_index = 0;
	_ruins.image_speed = 0;
	_ruins.image_xscale = image_xscale;
	_ruins.image_yscale = image_yscale;
	_ruins.image_angle = image_angle;
	_ruins.image_blend = image_blend;
	_ruins.image_alpha = image_alpha;
	_ruins.y_sort_enabled = false;
	_ruins.depth = depth;
};

house_guard_call_for_help = function(_attacked_unit, _attacker)
{
	if (!instance_exists(_attacked_unit) || !instance_exists(_attacker))
	{
		return;
	}

	if (variable_instance_exists(_attacked_unit, "alert_target"))
	{
		_attacked_unit.alert_target = _attacker;
		_attacked_unit.alert_target_timer = _attacked_unit.alert_target_time;
	}

	var _enemy_count = instance_number(o_enemy_units);
	var _assist_radius_squared = house_guard_assist_radius * house_guard_assist_radius;

	for (var _enemy_index = 0; _enemy_index < _enemy_count; ++_enemy_index)
	{
		var _enemy = instance_find(o_enemy_units, _enemy_index);

		if (!instance_exists(_enemy)
			|| _enemy == _attacked_unit
			|| !variable_instance_exists(_enemy, "hp")
			|| _enemy.hp <= 0)
		{
			continue;
		}

		var _enemy_distance_x = _enemy.x - _attacked_unit.x;
		var _enemy_distance_y = _enemy.y - _attacked_unit.y;
		var _enemy_distance_squared = (_enemy_distance_x * _enemy_distance_x) + (_enemy_distance_y * _enemy_distance_y);

		if (_enemy_distance_squared > _assist_radius_squared)
		{
			continue;
		}

		if (variable_instance_exists(_enemy, "alert_target"))
		{
			_enemy.alert_target = _attacker;
			_enemy.alert_target_timer = _enemy.alert_target_time;
		}
	}
};

house_visible_guards_sync = function(_should_apply_deaths = true)
{
	var _visible_guard_count = house_guard_visible_count_get();

	if (_should_apply_deaths)
	{
		house_alive_unit_count = min(house_alive_unit_count, _visible_guard_count);
	}

	while (_visible_guard_count < house_alive_unit_count)
	{
		if (!instance_exists(house_guard_create()))
		{
			break;
		}

		_visible_guard_count++;
	}
};

house_virtualize_guards = function()
{
	house_alive_unit_count = house_guard_visible_count_get();
	house_guards_destroy();
};

house_morning_spawn_units = function()
{
	if (is_destroyed || hp <= 0)
	{
		return;
	}

	house_unit_limit += BALANCE_HOUSE_DAILY_UNIT_LIMIT_GAIN;

	var _unit_limit = floor(house_unit_limit);
	var _missing_count = max(0, _unit_limit - house_alive_unit_count);
	var _spawn_count = min(irandom_range(BALANCE_HOUSE_MORNING_SPAWN_MIN, BALANCE_HOUSE_MORNING_SPAWN_MAX), _missing_count);
	house_alive_unit_count += _spawn_count;

	if (house_was_visible)
	{
		house_visible_guards_sync(false);
	}
};

house_combat_spawn_trigger_exists = function()
{
	var _friendly_count = instance_number(o_friendly_units);

	for (var _friendly_index = 0; _friendly_index < _friendly_count; ++_friendly_index)
	{
		var _friendly_unit = instance_find(o_friendly_units, _friendly_index);

		if (instance_exists(_friendly_unit)
			&& variable_instance_exists(_friendly_unit, "hp")
			&& _friendly_unit.hp > 0
			&& point_distance(x, y, _friendly_unit.x, _friendly_unit.y) <= house_combat_spawn_radius)
		{
			return true;
		}
	}

	return false;
};

house_combat_spawn_update = function()
{
	if (is_destroyed || hp <= 0)
	{
		return;
	}

	house_combat_spawn_timer--;

	if (house_combat_spawn_timer > 0)
	{
		return;
	}

	house_combat_spawn_timer = house_combat_spawn_interval;

	if (house_was_visible)
	{
		house_alive_unit_count = min(house_alive_unit_count, house_guard_visible_count_get());
	}

	if (house_alive_unit_count >= floor(house_unit_limit)
		|| !house_combat_spawn_trigger_exists())
	{
		return;
	}

	var _unit_limit = floor(house_unit_limit);
	var _missing_count = max(0, _unit_limit - house_alive_unit_count);
	var _combat_spawn_count = max(1, floor(_unit_limit / BALANCE_HOUSE_COMBAT_SPAWN_LIMIT_PER_UNIT));
	house_alive_unit_count += min(_combat_spawn_count, _missing_count);

	if (house_was_visible)
	{
		house_visible_guards_sync(false);
	}
};

house_damage_receive = function(_damage_amount, _is_critical = false)
{
	if (is_destroyed || hp <= 0 || _damage_amount <= 0)
	{
		return 0;
	}

	var _applied_damage = min(_damage_amount, hp);
	hp = max(hp - _damage_amount, 0);
	damage_popup_create(x, y, _applied_damage, UNIT_FACTION.ENEMY, _is_critical);

	if (hp <= 0)
	{
		house_destroy();
	}

	return _applied_damage;
};

unit_damage_receive = function(_damage_amount, _source_faction = UNIT_FACTION.NOONE, _is_critical = false, _can_trigger_soul_chain = true, _source_instance = noone)
{
	return house_damage_receive(_damage_amount, _is_critical);
};

house_destroy = function()
{
	if (is_destroyed)
	{
		return;
	}

	house_saint_source_unregister();
	house_destroyed_ground_corrupt();
	house_guards_destroy();
	house_destroyed_guards_spawn();
	house_artifact_drop_try();

	if (variable_global_exists("construction_sound_play"))
	{
		global.construction_sound_play();
	}

	is_destroyed = true;
	hp = 0;
	house_ruins_create();
	instance_destroy();
};

on_damage_projectile_hit = function()
{
	house_damage_receive(BALANCE_PROJECTILE_DAMAGE_AMOUNT);
};

on_projectile_hit = function(_projectile_type)
{
	if (_projectile_type == PROJECTILE_TYPE.DAMAGE)
	{
		on_damage_projectile_hit();
	}
};

house_saint_source_register();
