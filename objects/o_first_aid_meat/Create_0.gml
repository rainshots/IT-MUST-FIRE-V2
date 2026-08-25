// Healing pulse settings are assigned from balance and may be overridden by Cannon upgrades.
heal_amount = BALANCE_FIRST_AID_MEAT_HEAL_AMOUNT;
heal_radius = BALANCE_FIRST_AID_MEAT_HEAL_RADIUS;
heal_interval = BALANCE_FIRST_AID_MEAT_HEAL_INTERVAL * room_speed;
heal_timer = 0;

// The meat remains active on the ground for a fixed amount of gameplay time.
life_duration = BALANCE_FIRST_AID_MEAT_LIFETIME * room_speed;
life_timer = 0;
balance_test_match_id = -1;

// Keep the landed shell at the same visual scale it had in flight.
image_speed = 0;
image_xscale = BALANCE_FIRST_AID_MEAT_GROUND_SCALE;
image_yscale = BALANCE_FIRST_AID_MEAT_GROUND_SCALE;
radius_outline_alpha = 0.2;

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

first_aid_meat_target_heal = function(_target)
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

	_target.hp = min(_target.hp + heal_amount, _target.max_hp);

	if (_target.hp > _hp_before_heal)
	{
		heal_feedback_create(_target, _target.hp - _hp_before_heal);
	}
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
