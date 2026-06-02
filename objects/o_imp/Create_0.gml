// Initialize shared friendly combat state.
event_inherited();

// Demon sprites are scaled up for readability.
image_xscale = 1;
image_yscale = 1;

// Default possession data is replaced by the controller when transformed.
cultist_name = "Imp";
cultist_points = array_create(CULTIST_STAT.COUNT, 0);
demon_type = DEMON_TYPE.IMP;
demon_ability = DEMON_ABILITY.NONE;
current_exp = 0;
current_lvl = 1;
pending_level_points = 0;
pending_passive_choices = 0;
pending_active_choices = 0;
passive_choice_options = [];
active_choice_options = [];
active_abilities = [];

// Passive abilities start locked and can be enabled by future progression.
has_imp_blood_frenzy = false;
has_imp_hellbleed = false;
has_imp_taste_of_fear = false;

// Demon combat stats are derived from base stats and cultist attributes.
cultist_stats_apply(id);

// Blood Frenzy stores one timer per possible stack.
blood_frenzy_stack_timers = array_create(BALANCE_IMP_BLOOD_FRENZY_MAX_STACKS, 0);
blood_frenzy_particle_timer = 0;

// Imp active abilities keep independent cooldown state for future unlocks.
demon_leap_cooldown = BALANCE_IMP_DEMON_LEAP_COOLDOWN * room_speed;
demon_leap_timer = 0;
demon_leap_retry_timer = 0;
demon_leap_refund_pending = false;
sacrificial_rush_cooldown = BALANCE_IMP_SACRIFICIAL_RUSH_COOLDOWN * room_speed;
sacrificial_rush_timer = 0;
sacrificial_rush_retry_timer = 0;
sacrificial_rush_active_timer = 0;
sacrificial_rush_hp_spent = 0;
bloody_clone_cooldown = BALANCE_IMP_BLOODY_CLONE_COOLDOWN * room_speed;
bloody_clone_timer = 0;
bloody_clone_retry_timer = 0;
leap_visual_timer = 0;
leap_visual_duration = BALANCE_IMP_DEMON_LEAP_ANIMATION_TIME * room_speed;
leap_visual_start_x = x;
leap_visual_start_y = y;
leap_visual_end_x = x;
leap_visual_end_y = y;
leap_visual_arc_height = BALANCE_IMP_DEMON_LEAP_ARC_HEIGHT;

imp_blood_frenzy_stack_count_get = function()
{
	var _stack_count = 0;

	for (var _stack_index = 0; _stack_index < array_length(blood_frenzy_stack_timers); ++_stack_index)
	{
		if (blood_frenzy_stack_timers[_stack_index] > 0)
		{
			_stack_count++;
		}
	}

	return _stack_count;
};

imp_blood_frenzy_reload_multiplier_get = function()
{
	if (!has_imp_blood_frenzy)
	{
		return 1;
	}

	var _stack_count = imp_blood_frenzy_stack_count_get();
	var _attack_speed_multiplier = 1 + (BALANCE_IMP_BLOOD_FRENZY_ATTACK_SPEED_BONUS * _stack_count);

	return 1 / _attack_speed_multiplier;
};

imp_blood_frenzy_move_multiplier_get = function()
{
	if (!has_imp_blood_frenzy)
	{
		return 1;
	}

	var _stack_count = imp_blood_frenzy_stack_count_get();

	return 1 + (BALANCE_IMP_BLOOD_FRENZY_MOVE_SPEED_BONUS * _stack_count);
};

imp_blood_frenzy_crit_bonus_get = function()
{
	var _stack_count = imp_blood_frenzy_stack_count_get();
	var _crit_bonus = BALANCE_IMP_BLOOD_FRENZY_CRIT_CHANCE_BONUS * _stack_count;

	if (!has_imp_blood_frenzy)
	{
		_crit_bonus = 0;
	}

	if (sacrificial_rush_active_timer > 0)
	{
		_crit_bonus += BALANCE_IMP_SACRIFICIAL_RUSH_CRIT_CHANCE_BONUS;
	}

	return _crit_bonus;
};

imp_blood_frenzy_stack_add = function()
{
	var _shortest_stack_index = 0;
	var _shortest_stack_timer = blood_frenzy_stack_timers[0];

	for (var _stack_index = 0; _stack_index < array_length(blood_frenzy_stack_timers); ++_stack_index)
	{
		if (blood_frenzy_stack_timers[_stack_index] <= 0)
		{
			blood_frenzy_stack_timers[_stack_index] = BALANCE_IMP_BLOOD_FRENZY_DURATION * room_speed;
			return;
		}

		if (blood_frenzy_stack_timers[_stack_index] < _shortest_stack_timer)
		{
			_shortest_stack_index = _stack_index;
			_shortest_stack_timer = blood_frenzy_stack_timers[_stack_index];
		}
	}

	blood_frenzy_stack_timers[_shortest_stack_index] = BALANCE_IMP_BLOOD_FRENZY_DURATION * room_speed;
};

imp_blood_frenzy_particles_create = function()
{
	if (!variable_global_exists("particle_system_effects")
		|| !variable_global_exists("particle_type_imp_blood_frenzy_smoke")
		|| global.particle_system_effects == noone
		|| global.particle_type_imp_blood_frenzy_smoke == noone)
	{
		return;
	}

	for (var _particle_index = 0; _particle_index < BALANCE_IMP_BLOOD_FRENZY_SMOKE_COUNT; ++_particle_index)
	{
		var _particle_position = unit_body_particle_position_get();
		part_particles_create(global.particle_system_effects, _particle_position[0], _particle_position[1], global.particle_type_imp_blood_frenzy_smoke, 1);
	}
};

imp_target_has_fear_taste_status = function(_target)
{
	return instance_exists(_target)
		&& variable_instance_exists(_target, "status_effect_has")
		&& (_target.status_effect_has(STATUS_EFFECT.FEAR)
			|| _target.status_effect_has(STATUS_EFFECT.CURSE)
			|| _target.status_effect_has(STATUS_EFFECT.BLEED)
			|| _target.status_effect_has(STATUS_EFFECT.STUN));
};

unit_damage_modifier_get = function(_target, _is_magic_damage)
{
	if (has_imp_taste_of_fear && imp_target_has_fear_taste_status(_target))
	{
		return BALANCE_IMP_TASTE_OF_FEAR_DAMAGE_MULTIPLIER;
	}

	return 1;
};

imp_active_reload_multiplier_get = function()
{
	if (sacrificial_rush_active_timer > 0)
	{
		return 1 / (1 + BALANCE_IMP_SACRIFICIAL_RUSH_ATTACK_SPEED_BONUS);
	}

	return 1;
};

imp_find_lowest_hp_enemy = function(_search_radius)
{
	var _best_target = noone;
	var _best_hp = infinity;
	var _enemy_count = instance_number(o_enemy_units);

	for (var _enemy_index = 0; _enemy_index < _enemy_count; ++_enemy_index)
	{
		var _enemy = instance_find(o_enemy_units, _enemy_index);

		if (!target_can_be_attacked(_enemy)
			|| !variable_instance_exists(_enemy, "hp")
			|| point_distance(x, y, _enemy.x, _enemy.y) > _search_radius)
		{
			continue;
		}

		if (_enemy.hp < _best_hp)
		{
			_best_target = _enemy;
			_best_hp = _enemy.hp;
		}
	}

	return _best_target;
};

imp_find_farthest_enemy = function(_search_radius)
{
	var _best_target = noone;
	var _best_distance = -1;
	var _enemy_count = instance_number(o_enemy_units);

	for (var _enemy_index = 0; _enemy_index < _enemy_count; ++_enemy_index)
	{
		var _enemy = instance_find(o_enemy_units, _enemy_index);

		if (!target_can_be_attacked(_enemy))
		{
			continue;
		}

		var _enemy_distance = point_distance(x, y, _enemy.x, _enemy.y);

		if (_enemy_distance <= _search_radius && _enemy_distance > _best_distance)
		{
			_best_target = _enemy;
			_best_distance = _enemy_distance;
		}
	}

	return _best_target;
};

imp_leap_visual_start = function(_start_x, _start_y, _end_x, _end_y, _arc_height)
{
	leap_visual_start_x = _start_x;
	leap_visual_start_y = _start_y;
	leap_visual_end_x = _end_x;
	leap_visual_end_y = _end_y;
	leap_visual_timer = leap_visual_duration;
	leap_visual_arc_height = _arc_height;
	visual_offset_is_ability_controlled = true;
};

imp_damage_target = function(_target, _damage_amount, _force_critical)
{
	if (!target_can_be_attacked(_target) || !variable_instance_exists(_target, "hp"))
	{
		return false;
	}

	var _target_hp_before_hit = _target.hp;
	var _damage_with_modifiers = _damage_amount * unit_damage_modifier_get(_target, false);

	if (_force_critical)
	{
		_damage_with_modifiers *= 2;
	}

	var _final_damage = physical_damage_after_armor(_damage_with_modifiers, _target);

	if (variable_instance_exists(_target, "unit_damage_receive"))
	{
		_target.unit_damage_receive(_final_damage, unit_faction, _force_critical);
	}
	else
	{
		_target.hp = max(_target.hp - _final_damage, 0);
		damage_popup_create(_target.x, _target.y, _final_damage, _target.unit_faction, _force_critical);
	}

	var _target_was_killed = _target_hp_before_hit > 0 && _target.hp <= 0;
	unit_attack_landed(_target, _force_critical, _target_was_killed);

	return _target_was_killed;
};

imp_damage_enemies_on_path = function(_start_x, _start_y, _end_x, _end_y)
{
	var _enemy_count = instance_number(o_enemy_units);
	var _path_distance = point_distance(_start_x, _start_y, _end_x, _end_y);
	var _path_distance_squared = _path_distance * _path_distance;

	for (var _enemy_index = 0; _enemy_index < _enemy_count; ++_enemy_index)
	{
		var _enemy = instance_find(o_enemy_units, _enemy_index);

		if (!target_can_be_attacked(_enemy) || !variable_instance_exists(_enemy, "hp"))
		{
			continue;
		}

		var _distance_to_path = point_distance(_enemy.x, _enemy.y, _start_x, _start_y);

		if (_path_distance > 0)
		{
			var _path_progress = clamp(
				(((_enemy.x - _start_x) * (_end_x - _start_x)) + ((_enemy.y - _start_y) * (_end_y - _start_y))) / _path_distance_squared,
				0,
				1
			);
			var _nearest_x = _start_x + ((_end_x - _start_x) * _path_progress);
			var _nearest_y = _start_y + ((_end_y - _start_y) * _path_progress);
			_distance_to_path = point_distance(_enemy.x, _enemy.y, _nearest_x, _nearest_y);
		}

		if (_distance_to_path <= BALANCE_IMP_SACRIFICIAL_RUSH_DASH_WIDTH)
		{
			imp_damage_target(_enemy, damage, false);
		}
	}
};

imp_demon_leap_use = function()
{
	var _target = imp_find_lowest_hp_enemy(BALANCE_IMP_DEMON_LEAP_SEARCH_RADIUS);

	if (!instance_exists(_target))
	{
		return false;
	}

	var _start_x = x;
	var _start_y = y;
	x = _target.x;
	y = _target.y;
	face_world_x(_target.x);
	leap_visual_duration = BALANCE_IMP_DEMON_LEAP_ANIMATION_TIME * room_speed;
	imp_leap_visual_start(_start_x, _start_y, x, y, BALANCE_IMP_DEMON_LEAP_ARC_HEIGHT);
	ability_popup_create(x, y, DEMON_ABILITY.IMP_DEMON_LEAP);

	var _target_was_killed = imp_damage_target(_target, damage, true);

	if (_target_was_killed)
	{
		demon_leap_refund_pending = true;
	}

	return true;
};

imp_sacrificial_rush_use = function()
{
	if (hp <= max_hp * BALANCE_IMP_SACRIFICIAL_RUSH_HP_COST_SHARE)
	{
		return false;
	}

	var _target = imp_find_lowest_hp_enemy(BALANCE_IMP_SACRIFICIAL_RUSH_DASH_RADIUS);
	var _hp_cost = max_hp * BALANCE_IMP_SACRIFICIAL_RUSH_HP_COST_SHARE;
	sacrificial_rush_hp_spent = _hp_cost;
	hp = max(hp - _hp_cost, 1);
	sacrificial_rush_active_timer = BALANCE_IMP_SACRIFICIAL_RUSH_DURATION * room_speed;
	ability_popup_create(x, y, DEMON_ABILITY.IMP_SACRIFICIAL_RUSH);

	if (instance_exists(_target))
	{
		var _start_x = x;
		var _start_y = y;
		x = _target.x;
		y = _target.y;
		leap_visual_duration = BALANCE_IMP_DEMON_LEAP_ANIMATION_TIME * room_speed;
		imp_leap_visual_start(_start_x, _start_y, x, y, BALANCE_IMP_DEMON_LEAP_ARC_HEIGHT * 0.65);
		imp_damage_enemies_on_path(_start_x, _start_y, x, y);
	}

	return true;
};

imp_clone_stats_copy = function(_clone)
{
	_clone.max_hp = max_hp;
	_clone.hp = hp;
	_clone.damage = damage;
	_clone.magic_damage = magic_damage;
	_clone.armor = armor;
	_clone.crit_chance = crit_chance;
	_clone.reload_time = reload_time;
	_clone.attack_radius = attack_radius;
	_clone.move_speed = move_speed;
	_clone.bar_offset_y = bar_offset_y;
	_clone.cultist_name = "Clone";
};

imp_bloody_clone_use = function()
{
	var _target = imp_find_farthest_enemy(BALANCE_IMP_BLOODY_CLONE_SEARCH_RADIUS);

	if (!instance_exists(_target))
	{
		return false;
	}

	var _start_x = x;
	var _start_y = y;
	var _clone = instance_create_layer(_start_x, _start_y, "Instances", o_imp_clone);

	if (instance_exists(_clone))
	{
		imp_clone_stats_copy(_clone);
	}

	x = _target.x;
	y = _target.y;
	face_world_x(_target.x);
	leap_visual_duration = BALANCE_IMP_BLOODY_CLONE_ANIMATION_TIME * room_speed;
	imp_leap_visual_start(_start_x, _start_y, x, y, BALANCE_IMP_BLOODY_CLONE_ARC_HEIGHT);
	ability_popup_create(x, y, DEMON_ABILITY.IMP_BLOODY_CLONE);

	return true;
};

unit_attack_landed = function(_target, _is_critical_hit = false, _target_was_killed = false)
{
	if (!instance_exists(_target))
	{
		return;
	}

	if (has_imp_hellbleed && _is_critical_hit && variable_instance_exists(_target, "status_effect_apply"))
	{
		_target.status_effect_apply(
			STATUS_EFFECT.BLEED,
			BALANCE_IMP_HELLBLEED_DURATION,
			BALANCE_STATUS_BLEED_DEFAULT_DAMAGE,
			0,
			BALANCE_STATUS_BLEED_DEFAULT_TICK_TIME,
			unit_faction
		);
	}

	if (has_imp_blood_frenzy && _target_was_killed)
	{
		imp_blood_frenzy_stack_add();
	}

	if (_target_was_killed && sacrificial_rush_active_timer > 0 && sacrificial_rush_hp_spent > 0)
	{
		var _heal_amount = sacrificial_rush_hp_spent * BALANCE_IMP_SACRIFICIAL_RUSH_KILL_HEAL_SHARE;
		hp = min(hp + _heal_amount, max_hp);
	}
};
