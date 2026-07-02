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

// Tooltip lines describe house behavior for projectile targeting.
tooltip_lines = [
	"Damage: Takes damage",
	"Saint: Nearby ground resists Taint",
	"Morning: Spawns local guards"
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

	house_alive_unit_count++;

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
	house_guards_destroy();
	is_destroyed = true;
	hp = 0;
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
