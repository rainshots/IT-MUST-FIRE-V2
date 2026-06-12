// Hex Totem attacks nearby enemies for a short lifetime.
owner_warlock = noone;
owner_magic_damage = BALANCE_WARLOCK_MAGIC_DAMAGE;
ability_level = 1;
image_speed = 0;
y_sort_enabled = true;

// Totem timing and targeting values are kept in balance for quick tuning.
life_timer = BALANCE_WARLOCK_HEX_TOTEM_DURATION * room_speed;
beam_timer = 0;
zone_damage_timer = BALANCE_WARLOCK_HEX_TOTEM_ZONE_TICK_TIME * room_speed;
beam_line_timer = 0;
beam_line_time = BALANCE_WARLOCK_HEX_TOTEM_BEAM_LINE_TIME * room_speed;
beam_targets = [];
effect_radius = BALANCE_WARLOCK_HEX_TOTEM_RADIUS;
has_exploded = false;

hex_totem_magic_damage_value_get = function(_multiplier)
{
	return max(1, owner_magic_damage * _multiplier);
};

hex_totem_target_can_be_attacked = function(_target)
{
	return instance_exists(_target)
		&& variable_instance_exists(_target, "hp")
		&& _target.hp > 0
		&& !(variable_instance_exists(_target, "is_being_dragged") && _target.is_being_dragged);
};

hex_totem_magic_damage_apply = function(_target, _damage_amount)
{
	if (!hex_totem_target_can_be_attacked(_target) || _damage_amount <= 0)
	{
		return false;
	}

	var _final_damage = _damage_amount;

	if (variable_instance_exists(_target, "status_effect_magic_damage_multiplier"))
	{
		_final_damage *= _target.status_effect_magic_damage_multiplier();
	}

	if (variable_instance_exists(_target, "unit_damage_receive"))
	{
		_target.unit_damage_receive(_final_damage, UNIT_FACTION.FRIENDLY);
	}
	else if (variable_instance_exists(_target, "hp"))
	{
		_target.hp = max(_target.hp - _final_damage, 0);
		damage_popup_create(_target.x, _target.y, _final_damage, _target.unit_faction);
	}

	return true;
};

hex_totem_enemy_already_selected = function(_selected_enemies, _enemy)
{
	for (var _selected_index = 0; _selected_index < array_length(_selected_enemies); ++_selected_index)
	{
		if (_selected_enemies[_selected_index] == _enemy)
		{
			return true;
		}
	}

	return false;
};

hex_totem_targets_find = function(_target_count)
{
	var _selected_enemies = [];
	var _enemy_count = instance_number(o_enemy_units);

	for (var _target_slot = 0; _target_slot < _target_count; ++_target_slot)
	{
		var _nearest_enemy = noone;
		var _nearest_distance = effect_radius;

		for (var _enemy_index = 0; _enemy_index < _enemy_count; ++_enemy_index)
		{
			var _enemy = instance_find(o_enemy_units, _enemy_index);

			if (!hex_totem_target_can_be_attacked(_enemy) || hex_totem_enemy_already_selected(_selected_enemies, _enemy))
			{
				continue;
			}

			var _enemy_distance = point_distance(x, y, _enemy.x, _enemy.y);

			if (_enemy_distance <= _nearest_distance)
			{
				_nearest_enemy = _enemy;
				_nearest_distance = _enemy_distance;
			}
		}

		if (!instance_exists(_nearest_enemy))
		{
			break;
		}

		array_push(_selected_enemies, _nearest_enemy);
	}

	return _selected_enemies;
};

hex_totem_beam_fire = function()
{
	var _target_count = BALANCE_WARLOCK_HEX_TOTEM_TARGET_COUNT;

	if (ability_level >= 2)
	{
		_target_count = BALANCE_WARLOCK_HEX_TOTEM_TARGET_COUNT_LEVEL_2;
	}

	beam_targets = hex_totem_targets_find(_target_count);

	for (var _target_index = 0; _target_index < array_length(beam_targets); ++_target_index)
	{
		hex_totem_magic_damage_apply(
			beam_targets[_target_index],
			hex_totem_magic_damage_value_get(BALANCE_WARLOCK_HEX_TOTEM_BEAM_DAMAGE_MULTIPLIER)
		);
	}

	if (array_length(beam_targets) > 0)
	{
		beam_line_timer = beam_line_time;
	}
};

hex_totem_zone_damage_apply = function()
{
	if (ability_level < 3)
	{
		return;
	}

	var _enemy_list = ds_list_create();
	var _enemy_count = collision_circle_list(x, y, effect_radius, o_enemy_units, false, true, _enemy_list, false);

	for (var _enemy_index = 0; _enemy_index < _enemy_count; ++_enemy_index)
	{
		var _enemy = _enemy_list[| _enemy_index];

		hex_totem_magic_damage_apply(
			_enemy,
			hex_totem_magic_damage_value_get(BALANCE_WARLOCK_HEX_TOTEM_ZONE_DAMAGE_MULTIPLIER)
		);
	}

	ds_list_destroy(_enemy_list);
};

hex_totem_explode = function()
{
	if (has_exploded || ability_level < 4)
	{
		return;
	}

	has_exploded = true;
	var _enemy_list = ds_list_create();
	var _enemy_count = collision_circle_list(
		x,
		y,
		BALANCE_WARLOCK_HEX_TOTEM_EXPLOSION_RADIUS,
		o_enemy_units,
		false,
		true,
		_enemy_list,
		false
	);

	for (var _enemy_index = 0; _enemy_index < _enemy_count; ++_enemy_index)
	{
		var _enemy = _enemy_list[| _enemy_index];

		hex_totem_magic_damage_apply(
			_enemy,
			hex_totem_magic_damage_value_get(BALANCE_WARLOCK_HEX_TOTEM_EXPLOSION_DAMAGE_MULTIPLIER)
		);
	}

	ds_list_destroy(_enemy_list);
};
