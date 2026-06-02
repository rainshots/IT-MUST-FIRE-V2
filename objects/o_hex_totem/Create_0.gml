// Hex Totem curses enemies around itself for a short lifetime.
owner_warlock = noone;
image_speed = 0;
y_sort_enabled = true;

// Totem timing and targeting values are kept in balance for quick tuning.
life_timer = BALANCE_WARLOCK_HEX_TOTEM_DURATION * room_speed;
curse_tick_timer = 0;
meat_check_timer = 0;
effect_radius = BALANCE_WARLOCK_HEX_TOTEM_RADIUS;

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

hex_totem_curse_nearby_enemies = function()
{
	var _selected_enemies = array_create(0);
	var _enemy_count = instance_number(o_enemy_units);

	for (var _target_slot = 0; _target_slot < BALANCE_WARLOCK_HEX_TOTEM_TARGET_COUNT; ++_target_slot)
	{
		var _nearest_enemy = noone;
		var _nearest_distance = effect_radius;

		for (var _enemy_index = 0; _enemy_index < _enemy_count; ++_enemy_index)
		{
			var _enemy = instance_find(o_enemy_units, _enemy_index);

			if (!instance_exists(_enemy)
				|| hex_totem_enemy_already_selected(_selected_enemies, _enemy)
				|| (variable_instance_exists(_enemy, "is_being_dragged") && _enemy.is_being_dragged)
				|| (variable_instance_exists(_enemy, "hp") && _enemy.hp <= 0)
				|| !variable_instance_exists(_enemy, "status_effect_apply"))
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

		_nearest_enemy.status_effect_apply(
			STATUS_EFFECT.CURSE,
			BALANCE_WARLOCK_HEX_TOTEM_CURSE_TIME,
			1,
			0,
			0,
			UNIT_FACTION.FRIENDLY
		);
		array_push(_selected_enemies, _nearest_enemy);
	}
};

hex_totem_nearest_meat_find = function()
{
	if (!instance_exists(o_meat))
	{
		return noone;
	}

	var _nearest_meat = noone;
	var _nearest_distance = BALANCE_WARLOCK_HEX_TOTEM_MEAT_ABSORB_RADIUS;
	var _meat_count = instance_number(o_meat);

	for (var _meat_index = 0; _meat_index < _meat_count; ++_meat_index)
	{
		var _meat = instance_find(o_meat, _meat_index);

		if (!instance_exists(_meat)
			|| (variable_instance_exists(_meat, "is_fading_out") && _meat.is_fading_out))
		{
			continue;
		}

		var _meat_distance = point_distance(x, y, _meat.x, _meat.y);

		if (_meat_distance <= _nearest_distance)
		{
			_nearest_meat = _meat;
			_nearest_distance = _meat_distance;
		}
	}

	return _nearest_meat;
};

hex_totem_meat_absorb_try = function()
{
	var _meat = hex_totem_nearest_meat_find();

	if (!instance_exists(_meat))
	{
		return;
	}

	life_timer += BALANCE_WARLOCK_HEX_TOTEM_MEAT_EXTEND_TIME * room_speed;

	with (_meat)
	{
		instance_destroy();
	}
};
