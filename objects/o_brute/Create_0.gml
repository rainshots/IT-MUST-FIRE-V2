// Initialize shared friendly combat state.
event_inherited();

// Demon sprites are scaled up for readability.
image_xscale = 1;
image_yscale = 1;

// Default possession data is replaced by the controller when transformed.
cultist_name = "Brute";
cultist_points = array_create(CULTIST_STAT.COUNT, 0);
demon_type = DEMON_TYPE.BRUTE;
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
has_brute_corpse_eater = false;
has_brute_rotten_aura = false;
has_brute_cursed_flesh = false;

// Demon combat stats are derived from base stats and cultist attributes.
cultist_stats_apply(id);

// Corpse Eater makes injured Brutes seek nearby meat and consume it.
corpse_eater_search_radius = BALANCE_BRUTE_CORPSE_EATER_SEARCH_RADIUS;
corpse_eater_eat_radius = BALANCE_BRUTE_CORPSE_EATER_EAT_RADIUS;
corpse_eater_cooldown_timer = 0;

// Rotten Aura applies periodic magic damage around the Brute.
rotten_aura_radius = BALANCE_BRUTE_ROTTEN_AURA_RADIUS;
rotten_aura_tick_timer = irandom(max(1, floor(BALANCE_BRUTE_ROTTEN_AURA_TICK_TIME * room_speed)) - 1);
rotten_aura_particle_timer = irandom(max(1, floor(BALANCE_BRUTE_ROTTEN_AURA_PARTICLE_INTERVAL)) - 1);

// Brute active abilities keep independent cooldown state for future unlocks.
grave_slam_cooldown = BALANCE_BRUTE_GRAVE_SLAM_COOLDOWN * room_speed;
grave_slam_timer = 0;
grave_slam_retry_timer = 0;
meat_hook_cooldown = BALANCE_BRUTE_MEAT_HOOK_COOLDOWN * room_speed;
meat_hook_timer = 0;
meat_hook_retry_timer = 0;
devour_cooldown = BALANCE_BRUTE_DEVOUR_COOLDOWN * room_speed;
devour_timer = 0;
devour_retry_timer = 0;
grave_slam_circle_timer = 0;
grave_slam_circle_duration = BALANCE_BRUTE_GRAVE_SLAM_CIRCLE_FADE_TIME * room_speed;
grave_slam_circle_x = x;
grave_slam_circle_y = y;
grave_slam_circle_radius = BALANCE_BRUTE_GRAVE_SLAM_RADIUS;
meat_explosion_circle_timer = 0;
meat_explosion_circle_duration = BALANCE_BRUTE_GRAVE_SLAM_CIRCLE_FADE_TIME * room_speed;
meat_explosion_circle_x = x;
meat_explosion_circle_y = y;
meat_explosion_circle_radius = BALANCE_BRUTE_MEAT_EXPLOSION_RADIUS;
hook_target = noone;
hook_line_active = false;

brute_heal_particles_create = function()
{
	if (!variable_global_exists("particle_system_effects")
		|| !variable_global_exists("particle_type_brute_heal")
		|| global.particle_system_effects == noone
		|| global.particle_type_brute_heal == noone)
	{
		return;
	}

	for (var _particle_index = 0; _particle_index < BALANCE_BRUTE_CORPSE_EATER_HEAL_PARTICLE_COUNT; ++_particle_index)
	{
		var _particle_position = unit_body_particle_position_get();
		part_particles_create(global.particle_system_effects, _particle_position[0], _particle_position[1], global.particle_type_brute_heal, 1);
	}
};

brute_rotten_aura_particles_update = function()
{
	rotten_aura_particle_timer--;

	if (!BALANCE_BRUTE_ROTTEN_AURA_ENABLED
		|| rotten_aura_particle_timer > 0
		|| !variable_global_exists("particle_system_effects")
		|| !variable_global_exists("particle_type_brute_rotten_aura")
		|| global.particle_system_effects == noone
		|| global.particle_type_brute_rotten_aura == noone)
	{
		return;
	}

	for (var _particle_index = 0; _particle_index < BALANCE_BRUTE_ROTTEN_AURA_PARTICLE_COUNT; ++_particle_index)
	{
		var _particle_distance = sqrt(random(1)) * rotten_aura_radius;
		var _particle_direction = random(360);
		var _particle_x = x + lengthdir_x(_particle_distance, _particle_direction);
		var _particle_y = y + lengthdir_y(_particle_distance, _particle_direction);
		part_particles_create(global.particle_system_effects, _particle_x, _particle_y, global.particle_type_brute_rotten_aura, 1);
	}

	rotten_aura_particle_timer = BALANCE_BRUTE_ROTTEN_AURA_PARTICLE_INTERVAL;
};

brute_smoke_burst_create = function(_burst_x, _burst_y, _burst_radius, _particle_type, _particle_count)
{
	if (!variable_global_exists("particle_system_effects")
		|| global.particle_system_effects == noone
		|| _particle_type == noone)
	{
		return;
	}

	for (var _particle_index = 0; _particle_index < _particle_count; ++_particle_index)
	{
		var _particle_distance = sqrt(random(1)) * _burst_radius;
		var _particle_direction = random(360);
		var _particle_x = _burst_x + lengthdir_x(_particle_distance, _particle_direction);
		var _particle_y = _burst_y + lengthdir_y(_particle_distance, _particle_direction);
		part_particles_create(global.particle_system_effects, _particle_x, _particle_y, _particle_type, 1);
	}
};

brute_aoe_circle_show = function(_circle_x, _circle_y, _circle_radius, _is_meat_explosion)
{
	if (_is_meat_explosion)
	{
		meat_explosion_circle_x = _circle_x;
		meat_explosion_circle_y = _circle_y;
		meat_explosion_circle_radius = _circle_radius;
		meat_explosion_circle_timer = meat_explosion_circle_duration;
		return;
	}

	grave_slam_circle_x = _circle_x;
	grave_slam_circle_y = _circle_y;
	grave_slam_circle_radius = _circle_radius;
	grave_slam_circle_timer = grave_slam_circle_duration;
};

brute_damage_enemy_in_aoe = function(_center_x, _center_y, _radius, _damage_amount, _stun_time)
{
	var _enemy_list = ds_list_create();
	var _enemy_count = collision_circle_list(_center_x, _center_y, _radius, o_enemy_units, false, true, _enemy_list, false);

	for (var _enemy_index = 0; _enemy_index < _enemy_count; ++_enemy_index)
	{
		var _enemy = _enemy_list[| _enemy_index];

		if (!target_can_be_attacked(_enemy) || !variable_instance_exists(_enemy, "hp"))
		{
			continue;
		}

		var _final_damage = physical_damage_after_armor(_damage_amount, _enemy);

		if (variable_instance_exists(_enemy, "unit_damage_receive"))
		{
			_enemy.unit_damage_receive(_final_damage, unit_faction);
		}
		else
		{
			_enemy.hp = max(_enemy.hp - _final_damage, 0);
			damage_popup_create(_enemy.x, _enemy.y, _final_damage, _enemy.unit_faction);
		}

		if (_stun_time > 0 && variable_instance_exists(_enemy, "stun_apply"))
		{
			_enemy.stun_apply(_stun_time);
		}
	}

	ds_list_destroy(_enemy_list);
};

brute_meat_explosion_create = function(_meat)
{
	if (!instance_exists(_meat))
	{
		return;
	}

	var _explosion_x = _meat.x;
	var _explosion_y = _meat.y;
	var _explosion_damage = damage * BALANCE_BRUTE_MEAT_EXPLOSION_DAMAGE_MULTIPLIER;

	brute_damage_enemy_in_aoe(_explosion_x, _explosion_y, BALANCE_BRUTE_MEAT_EXPLOSION_RADIUS, _explosion_damage, 0);
	brute_aoe_circle_show(_explosion_x, _explosion_y, BALANCE_BRUTE_MEAT_EXPLOSION_RADIUS, true);

	if (variable_global_exists("particle_type_brute_meat_explosion_smoke"))
	{
		brute_smoke_burst_create(
			_explosion_x,
			_explosion_y,
			BALANCE_BRUTE_MEAT_EXPLOSION_RADIUS,
			global.particle_type_brute_meat_explosion_smoke,
			BALANCE_BRUTE_MEAT_EXPLOSION_SMOKE_COUNT
		);
	}

	with (_meat)
	{
		instance_destroy();
	}
};

brute_nearest_meat_find = function()
{
	if (!instance_exists(o_meat))
	{
		return noone;
	}

	var _nearest_meat = noone;
	var _nearest_distance = corpse_eater_search_radius;
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

brute_has_grave_slam_target = function()
{
	var _enemy_list = ds_list_create();
	var _enemy_count = collision_circle_list(x, y, BALANCE_BRUTE_GRAVE_SLAM_RADIUS, o_enemy_units, false, true, _enemy_list, false);
	var _has_target = _enemy_count > 0;
	ds_list_destroy(_enemy_list);

	if (_has_target)
	{
		return true;
	}

	var _meat_count = instance_number(o_meat);

	for (var _meat_index = 0; _meat_index < _meat_count; ++_meat_index)
	{
		var _meat = instance_find(o_meat, _meat_index);

		if (instance_exists(_meat)
			&& point_distance(x, y, _meat.x, _meat.y) <= BALANCE_BRUTE_GRAVE_SLAM_RADIUS)
		{
			return true;
		}
	}

	return false;
};

brute_grave_slam_use = function()
{
	if (!brute_has_grave_slam_target())
	{
		return false;
	}

	ability_popup_create(x, y, DEMON_ABILITY.BRUTE_GRAVE_SLAM);
	brute_damage_enemy_in_aoe(
		x,
		y,
		BALANCE_BRUTE_GRAVE_SLAM_RADIUS,
		damage * BALANCE_BRUTE_GRAVE_SLAM_DAMAGE_MULTIPLIER,
		BALANCE_BRUTE_GRAVE_SLAM_STUN_TIME
	);
	brute_aoe_circle_show(x, y, BALANCE_BRUTE_GRAVE_SLAM_RADIUS, false);

	if (variable_global_exists("particle_type_brute_grave_slam_smoke"))
	{
		brute_smoke_burst_create(
			x,
			y,
			BALANCE_BRUTE_GRAVE_SLAM_RADIUS,
			global.particle_type_brute_grave_slam_smoke,
			BALANCE_BRUTE_GRAVE_SLAM_SMOKE_COUNT
		);
	}

	var _meat_count = instance_number(o_meat);

	for (var _meat_index = _meat_count - 1; _meat_index >= 0; --_meat_index)
	{
		var _meat = instance_find(o_meat, _meat_index);

		if (instance_exists(_meat)
			&& point_distance(x, y, _meat.x, _meat.y) <= BALANCE_BRUTE_GRAVE_SLAM_RADIUS)
		{
			brute_meat_explosion_create(_meat);
		}
	}

	return true;
};

brute_hook_target_find = function()
{
	var _best_target = noone;
	var _best_hp = -1;
	var _enemy_count = instance_number(o_enemy_units);

	for (var _enemy_index = 0; _enemy_index < _enemy_count; ++_enemy_index)
	{
		var _enemy = instance_find(o_enemy_units, _enemy_index);

		if (!target_can_be_attacked(_enemy)
			|| !variable_instance_exists(_enemy, "hp")
			|| !variable_instance_exists(_enemy, "max_hp")
			|| (variable_instance_exists(_enemy, "is_being_hooked") && _enemy.is_being_hooked)
			|| point_distance(x, y, _enemy.x, _enemy.y) > BALANCE_BRUTE_MEAT_HOOK_SEARCH_RADIUS)
		{
			continue;
		}

		if (_enemy.hp > _best_hp)
		{
			_best_target = _enemy;
			_best_hp = _enemy.hp;
		}
	}

	return _best_target;
};

brute_hook_start = function()
{
	var _hook_target = brute_hook_target_find();

	if (!instance_exists(_hook_target))
	{
		return false;
	}

	ability_popup_create(x, y, DEMON_ABILITY.BRUTE_MEAT_HOOK);
	hook_target = _hook_target;
	hook_line_active = true;
	hook_target.is_being_hooked = true;
	target_instance = hook_target;

	if (variable_instance_exists(hook_target, "stun_apply"))
	{
		hook_target.stun_apply(BALANCE_BRUTE_MEAT_HOOK_STUN_TIME);
	}

	return true;
};

brute_hook_update = function()
{
	if (!instance_exists(hook_target))
	{
		hook_target = noone;
		hook_line_active = false;
		return;
	}

	if (!target_can_be_attacked(hook_target))
	{
		hook_target.is_being_hooked = false;
		hook_target = noone;
		hook_line_active = false;
		return;
	}

	var _distance_to_brute = point_distance(hook_target.x, hook_target.y, x, y);

	if (_distance_to_brute <= BALANCE_BRUTE_MEAT_HOOK_RELEASE_RADIUS)
	{
		hook_target.is_being_hooked = false;
		hook_target.forced_attack_target = id;
		hook_target.forced_attack_target_timer = BALANCE_BRUTE_MEAT_HOOK_FORCED_ATTACK_TIME * room_speed;
		hook_target.target_instance = id;
		target_instance = hook_target;
		hook_target = noone;
		hook_line_active = false;
		return;
	}

	var _pull_direction = point_direction(hook_target.x, hook_target.y, x, y);
	var _pull_distance = min(BALANCE_BRUTE_MEAT_HOOK_PULL_SPEED, _distance_to_brute);
	hook_target.x += lengthdir_x(_pull_distance, _pull_direction);
	hook_target.y += lengthdir_y(_pull_distance, _pull_direction);
};

brute_devour_target_find = function()
{
	var _best_target = noone;
	var _best_hp = -1;
	var _enemy_count = instance_number(o_enemy_units);

	for (var _enemy_index = 0; _enemy_index < _enemy_count; ++_enemy_index)
	{
		var _enemy = instance_find(o_enemy_units, _enemy_index);

		if (!target_can_be_attacked(_enemy)
			|| !variable_instance_exists(_enemy, "hp")
			|| !variable_instance_exists(_enemy, "max_hp")
			|| _enemy.hp >= _enemy.max_hp * BALANCE_BRUTE_DEVOUR_HP_THRESHOLD
			|| point_distance(x, y, _enemy.x, _enemy.y) > BALANCE_BRUTE_DEVOUR_RADIUS)
		{
			continue;
		}

		if (_enemy.hp > _best_hp)
		{
			_best_target = _enemy;
			_best_hp = _enemy.hp;
		}
	}

	return _best_target;
};

brute_devour_use = function()
{
	var _devour_target = brute_devour_target_find();

	if (!instance_exists(_devour_target))
	{
		return false;
	}

	ability_popup_create(x, y, DEMON_ABILITY.BRUTE_DEVOUR);
	instance_create_layer(_devour_target.x, _devour_target.y, "Instances", o_meat);

	with (_devour_target)
	{
		instance_destroy();
	}

	return true;
};

brute_corpse_eater_update = function()
{
	if (!has_brute_corpse_eater || !BALANCE_BRUTE_CORPSE_EATER_ENABLED)
	{
		return false;
	}

	if (corpse_eater_cooldown_timer > 0)
	{
		corpse_eater_cooldown_timer--;
	}

	if (corpse_eater_cooldown_timer > 0 || hp >= max_hp)
	{
		return false;
	}

	var _meat = brute_nearest_meat_find();

	if (!instance_exists(_meat))
	{
		return false;
	}

	target_instance = noone;
	is_attacking_target = false;

	var _meat_distance = point_distance(x, y, _meat.x, _meat.y);

	if (_meat_distance > corpse_eater_eat_radius)
	{
		move_towards_target(_meat);
		return true;
	}

	var _heal_amount = max_hp * BALANCE_BRUTE_CORPSE_EATER_HEAL_MAX_HP_SHARE;
	hp = min(hp + _heal_amount, max_hp);
	brute_heal_particles_create();

	with (_meat)
	{
		instance_destroy();
	}

	corpse_eater_cooldown_timer = BALANCE_BRUTE_CORPSE_EATER_COOLDOWN * room_speed;
	is_walking = false;

	return true;
};

unit_special_behavior_update = function()
{
	return brute_corpse_eater_update();
};
