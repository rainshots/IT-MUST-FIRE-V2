// Strike settings are configured by o_game_controller immediately after creation.
shell_type = HOLY_CANNON_SHELL_TYPE.STUN;
effect_radius = BALANCE_HOLY_CANNON_STUN_RADIUS;
effect_color = COLOR_HOLY_CANNON_STUN;
damage_amount = 0;
heal_amount = 0;
stun_time = BALANCE_HOLY_CANNON_STUN_TIME;

// The countdown includes the final visible projectile flight.
impact_duration = BALANCE_HOLY_CANNON_WARNING_TIME * room_speed;
impact_timer = impact_duration;
flight_duration = (BALANCE_HOLY_CANNON_PROJECTILE_FLIGHT_TIME / BALANCE_PROJECTILE_FLIGHT_SPEED_MULTIPLIER) * room_speed;
projectile_spawn_offset_y = BALANCE_HOLY_CANNON_PROJECTILE_SPAWN_OFFSET_Y;
projectile_radius = BALANCE_HOLY_CANNON_PROJECTILE_RADIUS;
projectile_trail_length = BALANCE_HOLY_CANNON_PROJECTILE_TRAIL_LENGTH;

// Warning and impact visuals remain configurable without changing strike behavior.
warning_fill_alpha = BALANCE_HOLY_CANNON_WARNING_ALPHA;
warning_outline_alpha = BALANCE_HOLY_CANNON_WARNING_OUTLINE_ALPHA;
warning_outline_width = BALANCE_HOLY_CANNON_WARNING_OUTLINE_WIDTH;
smoke_particle_count = BALANCE_HOLY_CANNON_SMOKE_COUNT;
particle_layer_name = "Instances";

holy_cannon_strike_configure = function(_shell_type)
{
	shell_type = _shell_type;
	damage_amount = 0;
	heal_amount = 0;
	stun_time = 0;

	if (shell_type == HOLY_CANNON_SHELL_TYPE.DAMAGE)
	{
		effect_radius = BALANCE_HOLY_CANNON_DAMAGE_RADIUS;
		effect_color = COLOR_HOLY_CANNON_DAMAGE;
		damage_amount = BALANCE_HOLY_CANNON_DAMAGE_AMOUNT;
	}
	else if (shell_type == HOLY_CANNON_SHELL_TYPE.HEAL)
	{
		effect_radius = BALANCE_HOLY_CANNON_HEAL_RADIUS;
		effect_color = COLOR_HOLY_CANNON_HEAL;
		heal_amount = BALANCE_HOLY_CANNON_HEAL_AMOUNT;
	}
	else
	{
		shell_type = HOLY_CANNON_SHELL_TYPE.STUN;
		effect_radius = BALANCE_HOLY_CANNON_STUN_RADIUS;
		effect_color = COLOR_HOLY_CANNON_STUN;
		stun_time = BALANCE_HOLY_CANNON_STUN_TIME;
	}

	impact_timer = impact_duration;
};

holy_cannon_strike_unit_apply = function(_unit)
{
	if (!instance_exists(_unit)
		|| !_unit.visible
		|| !variable_instance_exists(_unit, "hp")
		|| !variable_instance_exists(_unit, "max_hp")
		|| point_distance(x, y, _unit.x, _unit.y) > effect_radius)
	{
		return;
	}

	if (shell_type == HOLY_CANNON_SHELL_TYPE.STUN)
	{
		if (_unit.hp > 0 && variable_instance_exists(_unit, "stun_apply"))
		{
			_unit.stun_apply(stun_time);
		}

		return;
	}

	if (shell_type == HOLY_CANNON_SHELL_TYPE.DAMAGE)
	{
		if (_unit.hp <= 0)
		{
			return;
		}

		// The configured amount is raw physical damage and therefore respects armor.
		var _physical_damage = damage_amount;

		if (variable_instance_exists(_unit, "physical_damage_after_armor"))
		{
			_physical_damage = _unit.physical_damage_after_armor(damage_amount, _unit);
		}

		if (variable_instance_exists(_unit, "unit_damage_receive"))
		{
			var _source_faction = variable_instance_exists(_unit, "ignored_by_enemies")
				&& _unit.ignored_by_enemies
				? UNIT_FACTION.NOONE
				: UNIT_FACTION.ENEMY;
			_unit.unit_damage_receive(
				_physical_damage,
				_source_faction,
				false,
				false,
				noone
			);
		}
		else
		{
			var _hp_before_damage = _unit.hp;
			_unit.hp = max(_unit.hp - _physical_damage, 0);
			damage_popup_create(
				_unit.x,
				_unit.y,
				_hp_before_damage - _unit.hp,
				_unit.unit_faction
			);
		}

		return;
	}

	// Healing restores every living or knocked-out unit regardless of faction.
	var _is_knocked_out = variable_instance_exists(_unit, "is_knocked_out")
		&& _unit.is_knocked_out;

	if (_unit.hp <= 0 && !_is_knocked_out)
	{
		return;
	}

	var _hp_before_heal = _unit.hp;

	if (_is_knocked_out)
	{
		_unit.is_knocked_out = false;
		_unit.knockout_timer = 0;
		_unit.image_angle = 0;
	}

	_unit.hp = min(_unit.hp + heal_amount, _unit.max_hp);

	if (_unit.hp > _hp_before_heal)
	{
		heal_feedback_create(_unit, _unit.hp - _hp_before_heal);
	}
};

holy_cannon_strike_effect_apply = function()
{
	// o_units_parent includes active player and enemy battlefield units through inheritance.
	var _unit_count = instance_number(o_units_parent);

	for (var _unit_index = 0; _unit_index < _unit_count; ++_unit_index)
	{
		holy_cannon_strike_unit_apply(instance_find(o_units_parent, _unit_index));
	}
};

holy_cannon_strike_impact = function()
{
	// Apply gameplay before the instance is destroyed at the end of this impact.
	holy_cannon_strike_effect_apply();

	if (variable_global_exists("explosion_sounds")
		&& variable_global_exists("sound_play_random"))
	{
		global.sound_play_random(global.explosion_sounds);
	}

	instance_create_layer(x, y, particle_layer_name, o_particle_explosion);

	// Spread smoke uniformly across the warning circle and tint every particle to its type.
	for (var _smoke_index = 0; _smoke_index < smoke_particle_count; ++_smoke_index)
	{
		var _smoke_direction = random(360);
		var _smoke_distance = sqrt(random(1)) * effect_radius;
		var _smoke_x = x + lengthdir_x(_smoke_distance, _smoke_direction);
		var _smoke_y = y + lengthdir_y(_smoke_distance, _smoke_direction);
		var _smoke = instance_create_layer(_smoke_x, _smoke_y, particle_layer_name, o_particle_smoke);

		if (instance_exists(_smoke))
		{
			_smoke.smoke_color = effect_color;
		}
	}

	if (instance_exists(o_camera_controller))
	{
		var _camera_controller = instance_find(o_camera_controller, 0);

		if (variable_instance_exists(_camera_controller, "camera_shake_start"))
		{
			_camera_controller.camera_shake_start(
				BALANCE_HOLY_CANNON_CAMERA_SHAKE_TIME,
				BALANCE_HOLY_CANNON_CAMERA_SHAKE_STRENGTH
			);
		}
	}

	instance_destroy();
};
