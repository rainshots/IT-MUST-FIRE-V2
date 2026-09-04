// Healing pulse settings are assigned from balance and may be overridden by Cannon upgrades.
heal_amount = BALANCE_FIRST_AID_MEAT_HEAL_AMOUNT;
heal_radius = BALANCE_FIRST_AID_MEAT_HEAL_RADIUS;
heal_interval = BALANCE_FIRST_AID_MEAT_HEAL_INTERVAL * room_speed;
heal_timer = 0;

// Shell Factory enchantments can replace healing with an allied rescue chain.
first_aid_meat_enchantment = FIRST_AID_MEAT_ENCHANTMENT.NONE;
pull_radius = BALANCE_FIRST_AID_MEAT_PULL_RADIUS;
pull_hp_threshold = BALANCE_FIRST_AID_MEAT_PULL_HP_THRESHOLD;
pull_finish_heal = BALANCE_FIRST_AID_MEAT_PULL_FINISH_HEAL;
pull_cooldown = BALANCE_FIRST_AID_MEAT_PULL_COOLDOWN * room_speed;
pull_cooldown_timer = 0;
pull_target = noone;
pull_chain_is_outbound = false;
pull_chain_tip_x = x;
pull_chain_tip_y = y;

// The meat remains active on the ground for a fixed amount of gameplay time.
life_duration = BALANCE_FIRST_AID_MEAT_LIFETIME * room_speed;
life_timer = 0;
balance_test_match_id = -1;

// Keep the landed shell at the same visual scale it had in flight.
image_speed = 0;
image_xscale = BALANCE_FIRST_AID_MEAT_GROUND_SCALE;
image_yscale = BALANCE_FIRST_AID_MEAT_GROUND_SCALE;
radius_outline_alpha = 0.2;
particle_layer_name = "Instances";

first_aid_meat_enchantment_set = function(_enchantment)
{
	first_aid_meat_enchantment = _enchantment;
};

first_aid_meat_target_can_heal = function(_target)
{
	if (!instance_exists(_target)
		|| !variable_instance_exists(_target, "hp")
		|| !variable_instance_exists(_target, "max_hp")
		|| _target.max_hp <= 0)
	{
		return false;
	}

	// Balance-test instances may interact only with units from the same match.
	if (balance_test_match_id >= 0
		&& (!variable_instance_exists(_target, "balance_test_match_id")
			|| _target.balance_test_match_id != balance_test_match_id))
	{
		return false;
	}

	return true;
};

first_aid_meat_target_heal_amount = function(_target, _heal_amount)
{
	if (!first_aid_meat_target_can_heal(_target))
	{
		return;
	}

	var _hp_before_heal = _target.hp;

	// Preserve the previous First Aid behavior by reviving knocked-out friendly units.
	if (variable_instance_exists(_target, "is_knocked_out") && _target.is_knocked_out)
	{
		_target.is_knocked_out = false;
		_target.knockout_timer = 0;
		_target.image_angle = 0;
	}

	_target.hp = min(_target.hp + _heal_amount, _target.max_hp);

	if (_target.hp > _hp_before_heal)
	{
		heal_feedback_create(_target, _target.hp - _hp_before_heal);
	}
};

first_aid_meat_target_heal = function(_target)
{
	first_aid_meat_target_heal_amount(_target, heal_amount);
};

first_aid_meat_heal_nearby_units = function()
{
	// Heal regular friendly units inside the active ground area.
	var _friendly_list = ds_list_create();
	var _friendly_count = collision_circle_list(
		x,
		y,
		heal_radius,
		o_friendly_units,
		false,
		true,
		_friendly_list,
		false
	);

	for (var _friendly_index = 0; _friendly_index < _friendly_count; ++_friendly_index)
	{
		first_aid_meat_target_heal(_friendly_list[| _friendly_index]);
	}

	ds_list_destroy(_friendly_list);

	// Archdemons are player units but do not inherit from o_friendly_units.
	if (!variable_global_exists("archdemons"))
	{
		return;
	}

	var _archdemon_count = array_length(global.archdemons);

	for (var _archdemon_index = 0; _archdemon_index < _archdemon_count; ++_archdemon_index)
	{
		var _archdemon = global.archdemons[_archdemon_index];

		if (!instance_exists(_archdemon)
			|| !_archdemon.visible
			|| point_distance(_archdemon.x, _archdemon.y, x, y) > heal_radius)
		{
			continue;
		}

		first_aid_meat_target_heal(_archdemon);
	}
};

first_aid_meat_pull_target_can_pull = function(_target)
{
	if (!first_aid_meat_target_can_heal(_target)
		|| !_target.visible
		|| _target.hp >= _target.max_hp * pull_hp_threshold
		|| !variable_instance_exists(_target, "unit_forced_displacement_apply"))
	{
		return false;
	}

	if ((variable_instance_exists(_target, "is_being_dragged") && _target.is_being_dragged)
		|| (variable_instance_exists(_target, "is_being_hooked") && _target.is_being_hooked))
	{
		return false;
	}

	return true;
};

first_aid_meat_pull_target_find = function()
{
	var _farthest_target = noone;
	var _farthest_distance_squared = -1;
	var _pull_radius_squared = pull_radius * pull_radius;
	var _release_radius_squared = BALANCE_FIRST_AID_MEAT_PULL_RELEASE_RADIUS
		* BALANCE_FIRST_AID_MEAT_PULL_RELEASE_RADIUS;
	var _friendly_count = instance_number(o_friendly_units);

	// Emergency Pull rescues the farthest eligible regular ally first.
	for (var _friendly_index = 0; _friendly_index < _friendly_count; ++_friendly_index)
	{
		var _friendly = instance_find(o_friendly_units, _friendly_index);

		if (!first_aid_meat_pull_target_can_pull(_friendly))
		{
			continue;
		}

		var _distance_x = _friendly.x - x;
		var _distance_y = _friendly.y - y;
		var _distance_squared = (_distance_x * _distance_x) + (_distance_y * _distance_y);

		if (_distance_squared > _release_radius_squared
			&& _distance_squared <= _pull_radius_squared
			&& _distance_squared > _farthest_distance_squared)
		{
			_farthest_target = _friendly;
			_farthest_distance_squared = _distance_squared;
		}
	}

	if (!variable_global_exists("archdemons"))
	{
		return _farthest_target;
	}

	// Archdemons are allied units but do not inherit from the regular friendly parent.
	var _archdemon_count = array_length(global.archdemons);

	for (var _archdemon_index = 0; _archdemon_index < _archdemon_count; ++_archdemon_index)
	{
		var _archdemon = global.archdemons[_archdemon_index];

		if (!first_aid_meat_pull_target_can_pull(_archdemon))
		{
			continue;
		}

		var _archdemon_distance_x = _archdemon.x - x;
		var _archdemon_distance_y = _archdemon.y - y;
		var _archdemon_distance_squared = (_archdemon_distance_x * _archdemon_distance_x)
			+ (_archdemon_distance_y * _archdemon_distance_y);

		if (_archdemon_distance_squared > _release_radius_squared
			&& _archdemon_distance_squared <= _pull_radius_squared
			&& _archdemon_distance_squared > _farthest_distance_squared)
		{
			_farthest_target = _archdemon;
			_farthest_distance_squared = _archdemon_distance_squared;
		}
	}

	return _farthest_target;
};

first_aid_meat_pull_target_clear = function()
{
	pull_target = noone;
	pull_chain_is_outbound = false;
	pull_chain_tip_x = x;
	pull_chain_tip_y = y;
};

first_aid_meat_pull_start = function()
{
	var _target = first_aid_meat_pull_target_find();

	if (!instance_exists(_target))
	{
		return false;
	}

	pull_target = _target;
	pull_chain_is_outbound = true;
	pull_chain_tip_x = x;
	pull_chain_tip_y = y;
	pull_cooldown_timer = pull_cooldown;
	return true;
};

first_aid_meat_pull_update = function(_time_scale)
{
	pull_cooldown_timer = max(0, pull_cooldown_timer - _time_scale);

	if (!instance_exists(pull_target))
	{
		first_aid_meat_pull_target_clear();

		if (pull_cooldown_timer <= 0)
		{
			first_aid_meat_pull_start();
		}

		return;
	}

	if (!first_aid_meat_target_can_heal(pull_target)
		|| !pull_target.visible
		|| pull_target.hp >= pull_target.max_hp * pull_hp_threshold
		|| !variable_instance_exists(pull_target, "unit_forced_displacement_apply"))
	{
		first_aid_meat_pull_target_clear();
		return;
	}

	if (pull_chain_is_outbound)
	{
		var _line_distance = point_distance(pull_chain_tip_x, pull_chain_tip_y, pull_target.x, pull_target.y);
		var _line_speed = BALANCE_FIRST_AID_MEAT_PULL_LINE_SPEED * _time_scale;
		var _line_move = min(_line_speed, _line_distance);
		var _line_direction = point_direction(pull_chain_tip_x, pull_chain_tip_y, pull_target.x, pull_target.y);
		pull_chain_tip_x += lengthdir_x(_line_move, _line_direction);
		pull_chain_tip_y += lengthdir_y(_line_move, _line_direction);

		if (_line_distance <= _line_speed)
		{
			pull_chain_tip_x = pull_target.x;
			pull_chain_tip_y = pull_target.y;
			pull_chain_is_outbound = false;
		}

		return;
	}

	var _target_distance = point_distance(pull_target.x, pull_target.y, x, y);

	if (_target_distance <= BALANCE_FIRST_AID_MEAT_PULL_RELEASE_RADIUS)
	{
		first_aid_meat_target_heal_amount(pull_target, pull_finish_heal);
		first_aid_meat_pull_target_clear();
		return;
	}

	var _pull_direction = point_direction(pull_target.x, pull_target.y, x, y);
	var _pull_speed = BALANCE_FIRST_AID_MEAT_PULL_SPEED * _time_scale;
	var _pull_distance = min(_pull_speed, _target_distance);
	pull_target.unit_forced_displacement_apply(
		lengthdir_x(_pull_distance, _pull_direction),
		lengthdir_y(_pull_distance, _pull_direction)
	);
};
