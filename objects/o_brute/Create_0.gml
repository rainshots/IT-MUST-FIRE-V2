// Initialize shared friendly combat state.
event_inherited();

// Demon sprites are scaled up for readability.
image_xscale = 1.15;
image_yscale = 1.15;

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
pending_ability_upgrade_choices = 0;
passive_choice_options = [];
active_choice_options = [];
ability_upgrade_choice_options = [];
active_abilities = [];
ability_levels = array_create(DEMON_ABILITY.COUNT, 0);

// Passive abilities start locked and are enabled by cultist progression.
has_brute_corpse_eater = false;
has_brute_rotten_aura = false;
has_brute_blood_anvil = false;

// Demon combat stats are derived from base stats and cultist attributes.
cultist_stats_apply(id);

// Corpse Eater seeks non-skeleton corpse snapshots and consumes them for healing.
corpse_eater_search_radius = BALANCE_BRUTE_CORPSE_EATER_SEARCH_RADIUS;
corpse_eater_eat_radius = BALANCE_BRUTE_CORPSE_EATER_EAT_RADIUS;
corpse_eater_cooldown_timer = 0;
corpse_eater_target_corpse_id = noone;

// Rotten Aura applies periodic magic damage and later Fear around the Brute.
rotten_aura_tick_timer = irandom(max(1, floor(BALANCE_BRUTE_ROTTEN_AURA_TICK_TIME * room_speed)) - 1);
rotten_aura_particle_timer = irandom(max(1, floor(BALANCE_BRUTE_ROTTEN_AURA_PARTICLE_INTERVAL)) - 1);

// Brute active abilities keep independent cooldown state.
grave_slam_cooldown = BALANCE_BRUTE_GRAVE_SLAM_COOLDOWN * room_speed;
grave_slam_timer = 0;
grave_slam_retry_timer = 0;
butcher_chains_cooldown = BALANCE_BRUTE_BUTCHER_CHAINS_COOLDOWN * room_speed;
butcher_chains_timer = 0;
butcher_chains_retry_timer = 0;
corpse_armor_cooldown = BALANCE_BRUTE_CORPSE_ARMOR_COOLDOWN * room_speed;
corpse_armor_ability_timer = 0;
corpse_armor_retry_timer = 0;

// Normal attacks show their true AOE and mark every unit that received damage.
attack_aoe_circle_timer = 0;
attack_aoe_circle_duration = max(1, BALANCE_BRUTE_ATTACK_AOE_CIRCLE_TIME * room_speed);
attack_aoe_circle_x = x;
attack_aoe_circle_y = y;
attack_aoe_circle_radius = aoe_radius;
attack_aoe_hit_positions = [];

// Ability visuals use fading circles and one hook line per pulled target.
grave_slam_circle_timer = 0;
grave_slam_circle_duration = BALANCE_BRUTE_GRAVE_SLAM_CIRCLE_FADE_TIME * room_speed;
grave_slam_circle_x = x;
grave_slam_circle_y = y;
grave_slam_circle_radius = BALANCE_BRUTE_GRAVE_SLAM_RADIUS;
grave_slam_spike_visuals = [];
meat_explosion_circle_timer = 0;
meat_explosion_circle_duration = BALANCE_BRUTE_GRAVE_SLAM_CIRCLE_FADE_TIME * room_speed;
meat_explosion_circle_x = x;
meat_explosion_circle_y = y;
meat_explosion_circle_radius = BALANCE_BRUTE_MEAT_EXPLOSION_RADIUS;
hook_targets = [];
hook_chain_visuals = [];
hook_chain_state_outbound = 0;
hook_chain_state_returning = 1;
hook_line_active = false;
butcher_chains_second_wave_pending = false;

unit_aoe_attack_feedback_show = function(_hit_x, _hit_y, _radius, _hit_positions)
{
	attack_aoe_circle_x = _hit_x;
	attack_aoe_circle_y = _hit_y;
	attack_aoe_circle_radius = _radius;
	attack_aoe_hit_positions = _hit_positions;
	attack_aoe_circle_timer = attack_aoe_circle_duration;
};

brute_ability_level_get = function(_ability)
{
	return cultist_ability_level_get(id, _ability);
};

brute_rotten_aura_radius_get = function()
{
	if (brute_ability_level_get(DEMON_ABILITY.BRUTE_ROTTEN_AURA) >= 2)
	{
		return BALANCE_BRUTE_ROTTEN_AURA_RADIUS_LEVEL_2;
	}

	return BALANCE_BRUTE_ROTTEN_AURA_RADIUS;
};

brute_grave_slam_radius_get = function()
{
	var _radius = BALANCE_BRUTE_GRAVE_SLAM_RADIUS;

	if (brute_ability_level_get(DEMON_ABILITY.BRUTE_GRAVE_SLAM) >= 2)
	{
		_radius *= BALANCE_BRUTE_GRAVE_SLAM_RADIUS_LEVEL_2_MULTIPLIER;
	}

	return _radius;
};

brute_chains_search_radius_get = function()
{
	if (brute_ability_level_get(DEMON_ABILITY.BRUTE_BUTCHER_CHAINS) >= 2)
	{
		return BALANCE_BRUTE_BUTCHER_CHAINS_SEARCH_RADIUS_LEVEL_2;
	}

	return BALANCE_BRUTE_BUTCHER_CHAINS_SEARCH_RADIUS;
};

brute_chains_target_count_get = function()
{
	if (brute_ability_level_get(DEMON_ABILITY.BRUTE_BUTCHER_CHAINS) >= 3)
	{
		return BALANCE_BRUTE_BUTCHER_CHAINS_TARGET_COUNT_LEVEL_3;
	}

	return BALANCE_BRUTE_BUTCHER_CHAINS_TARGET_COUNT;
};

brute_corpse_armor_duration_get = function()
{
	if (brute_ability_level_get(DEMON_ABILITY.BRUTE_CORPSE_ARMOR) >= 2)
	{
		return BALANCE_BRUTE_CORPSE_ARMOR_DURATION_LEVEL_2;
	}

	return BALANCE_BRUTE_CORPSE_ARMOR_DURATION;
};

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
	rotten_aura_particle_timer -= gameplay_time_scale;

	if (!BALANCE_BRUTE_ROTTEN_AURA_ENABLED
		|| rotten_aura_particle_timer > 0
		|| !variable_global_exists("particle_system_effects")
		|| !variable_global_exists("particle_type_brute_rotten_aura")
		|| global.particle_system_effects == noone
		|| global.particle_type_brute_rotten_aura == noone)
	{
		return;
	}

	var _aura_radius = brute_rotten_aura_radius_get();

	for (var _particle_index = 0; _particle_index < BALANCE_BRUTE_ROTTEN_AURA_PARTICLE_COUNT; ++_particle_index)
	{
		var _particle_distance = sqrt(random(1)) * _aura_radius;
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

brute_grave_slam_spikes_create = function(_center_x, _center_y, _radius)
{
	if (!sprite_exists(s_spike))
	{
		return;
	}

	for (var _spike_index = 0; _spike_index < BALANCE_BRUTE_GRAVE_SLAM_SPIKE_VISUAL_COUNT; ++_spike_index)
	{
		var _spike_distance = sqrt(random(1)) * _radius;
		var _spike_direction = random(360);
		var _spike_x = _center_x + lengthdir_x(_spike_distance, _spike_direction);
		var _spike_y = _center_y + lengthdir_y(_spike_distance, _spike_direction);
		var _spike_scale = random_range(
			BALANCE_BRUTE_GRAVE_SLAM_SPIKE_VISUAL_SCALE_MIN,
			BALANCE_BRUTE_GRAVE_SLAM_SPIKE_VISUAL_SCALE_MAX
		);

		array_push(
			grave_slam_spike_visuals,
			{
				x: _spike_x,
				y: _spike_y,
				angle: _spike_direction + 90,
				scale: _spike_scale,
				timer: BALANCE_BRUTE_GRAVE_SLAM_SPIKE_VISUAL_TIME * room_speed,
				duration: BALANCE_BRUTE_GRAVE_SLAM_SPIKE_VISUAL_TIME * room_speed
			}
		);
	}
};

brute_damage_enemy = function(_enemy, _damage_amount, _stun_time, _knockback_x, _knockback_y)
{
	if (!target_can_be_attacked(_enemy) || !variable_instance_exists(_enemy, "hp"))
	{
		return false;
	}

	var _enemy_hp_before_hit = _enemy.hp;
	var _final_damage = physical_damage_after_armor(_damage_amount, _enemy);

	if (variable_instance_exists(_enemy, "unit_damage_receive"))
	{
		_enemy.unit_damage_receive(_final_damage, unit_faction, false, true, id);
	}
	else
	{
		_enemy.hp = max(_enemy.hp - _final_damage, 0);
		damage_popup_create(_enemy.x, _enemy.y, _final_damage, _enemy.unit_faction);
	}

	var _enemy_was_killed = _enemy_hp_before_hit > 0 && _enemy.hp <= 0;

	if (!_enemy_was_killed && _stun_time > 0 && variable_instance_exists(_enemy, "stun_apply"))
	{
		_enemy.stun_apply(_stun_time);
	}

	if (!_enemy_was_killed && (_knockback_x != 0 || _knockback_y != 0))
	{
		_enemy.x += _knockback_x;
		_enemy.y += _knockback_y;
	}

	return _enemy_was_killed;
};

brute_damage_enemy_in_aoe = function(_center_x, _center_y, _radius, _damage_amount, _stun_time, _knockback_distance)
{
	var _enemy_list = ds_list_create();
	var _enemy_count = collision_circle_list(_center_x, _center_y, _radius, o_enemy_units, false, true, _enemy_list, false);
	var _killed_positions = [];

	for (var _enemy_index = 0; _enemy_index < _enemy_count; ++_enemy_index)
	{
		var _enemy = _enemy_list[| _enemy_index];
		var _knockback_x = 0;
		var _knockback_y = 0;

		if (_knockback_distance > 0 && instance_exists(_enemy))
		{
			var _knockback_direction = point_direction(_center_x, _center_y, _enemy.x, _enemy.y);
			_knockback_x = lengthdir_x(_knockback_distance, _knockback_direction);
			_knockback_y = lengthdir_y(_knockback_distance, _knockback_direction);
		}

		if (brute_damage_enemy(_enemy, _damage_amount, _stun_time, _knockback_x, _knockback_y))
		{
			array_push(_killed_positions, [_enemy.x, _enemy.y]);
		}
	}

	ds_list_destroy(_enemy_list);
	return _killed_positions;
};

brute_meat_explosion_create = function(_explosion_x, _explosion_y)
{
	var _explosion_damage = damage * BALANCE_BRUTE_MEAT_EXPLOSION_DAMAGE_MULTIPLIER;

	brute_damage_enemy_in_aoe(_explosion_x, _explosion_y, BALANCE_BRUTE_MEAT_EXPLOSION_RADIUS, _explosion_damage, 0, 0);
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
};

brute_nearest_corpse_find = function()
{
	if (!instance_exists(o_game_controller))
	{
		return noone;
	}

	var _game_controller = instance_find(o_game_controller, 0);

	if (!variable_instance_exists(_game_controller, "corpse_draw_data"))
	{
		return noone;
	}

	var _corpse_count = array_length(_game_controller.corpse_draw_data);
	var _nearest_corpse = noone;
	var _nearest_distance = corpse_eater_search_radius;

	for (var _corpse_index = 0; _corpse_index < _corpse_count; ++_corpse_index)
	{
		var _corpse = _game_controller.corpse_draw_data[_corpse_index];
		var _corpse_is_skeleton = variable_struct_exists(_corpse, "source_object_index")
			&& _corpse.source_object_index == o_skeleton;
		var _corpse_is_reserved = variable_struct_exists(_corpse, "reserved_by")
			&& instance_exists(_corpse.reserved_by);

		if (_corpse_is_skeleton || _corpse_is_reserved)
		{
			continue;
		}

		var _corpse_distance = point_distance(x, y, _corpse.x, _corpse.y);

		if (_corpse_distance <= _nearest_distance)
		{
			_nearest_corpse = _corpse;
			_nearest_distance = _corpse_distance;
		}
	}

	return _nearest_corpse;
};

brute_corpse_consume = function(_corpse)
{
	if (!is_struct(_corpse) || !instance_exists(o_game_controller))
	{
		return false;
	}

	var _game_controller = instance_find(o_game_controller, 0);

	if (!variable_instance_exists(_game_controller, "corpse_reserved_take"))
	{
		return false;
	}

	var _consumed_corpse = _game_controller.corpse_reserved_take(_corpse.corpse_id, id);

	if (!is_struct(_consumed_corpse))
	{
		return false;
	}

	// Leave an eaten corpse behind as a skeleton corpse so it cannot be eaten again.
	_consumed_corpse.source_object_index = o_skeleton;
	_consumed_corpse.reserved_by = noone;

	if (sprite_exists(s_skeleton))
	{
		_consumed_corpse.sprite_index = s_skeleton;
		_consumed_corpse.image_index = 0;
		_consumed_corpse.image_blend = c_white;
		_consumed_corpse.image_alpha = 1;
	}

	if (variable_instance_exists(_game_controller, "corpse_draw_data"))
	{
		array_push(_game_controller.corpse_draw_data, _consumed_corpse);
	}

	var _corpse_eater_level = brute_ability_level_get(DEMON_ABILITY.BRUTE_CORPSE_EATER);
	var _heal_share = BALANCE_BRUTE_CORPSE_EATER_HEAL_MAX_HP_SHARE;

	if (_corpse_eater_level >= 2)
	{
		_heal_share = BALANCE_BRUTE_CORPSE_EATER_HEAL_MAX_HP_SHARE_LEVEL_2;
	}

	var _hp_before_heal = hp;
	hp = min(hp + (max_hp * _heal_share), max_hp);
	heal_feedback_create(id, hp - _hp_before_heal);
	brute_heal_particles_create();

	if (_corpse_eater_level >= 4)
	{
		var _ally_count = instance_number(o_friendly_units);

		for (var _ally_index = 0; _ally_index < _ally_count; ++_ally_index)
		{
			var _ally = instance_find(o_friendly_units, _ally_index);

			if (instance_exists(_ally)
				&& _ally != id
				&& variable_instance_exists(_ally, "demon_type")
				&& _ally.demon_type != DEMON_TYPE.NONE
				&& variable_instance_exists(_ally, "hp")
				&& variable_instance_exists(_ally, "max_hp")
				&& point_distance(x, y, _ally.x, _ally.y) <= BALANCE_BRUTE_CORPSE_EATER_ALLY_RADIUS)
			{
				var _ally_hp_before_heal = _ally.hp;
				_ally.hp = min(_ally.hp + (_ally.max_hp * BALANCE_BRUTE_CORPSE_EATER_ALLY_HEAL_MAX_HP_SHARE), _ally.max_hp);
				heal_feedback_create(_ally, _ally.hp - _ally_hp_before_heal);
			}
		}
	}

	var _cooldown_seconds = BALANCE_BRUTE_CORPSE_EATER_COOLDOWN;

	if (_corpse_eater_level >= 3)
	{
		_cooldown_seconds = BALANCE_BRUTE_CORPSE_EATER_COOLDOWN_LEVEL_3;
	}

	corpse_eater_cooldown_timer = _cooldown_seconds * room_speed;
	is_walking = false;

	return true;
};

brute_has_grave_slam_target = function()
{
	var _radius = brute_grave_slam_radius_get();
	var _enemy_list = ds_list_create();
	var _enemy_count = collision_circle_list(x, y, _radius, o_enemy_units, false, true, _enemy_list, false);
	var _has_target = _enemy_count > 0;
	ds_list_destroy(_enemy_list);

	return _has_target;
};

brute_world_position_is_on_camera = function(_world_x, _world_y)
{
	if (!instance_exists(o_camera_controller))
	{
		return false;
	}

	var _camera_controller = instance_find(o_camera_controller, 0);
	var _camera_margin = 64;
	var _camera_left = _camera_controller.x - _camera_controller.half_view_width - _camera_margin;
	var _camera_right = _camera_controller.x + _camera_controller.half_view_width + _camera_margin;
	var _camera_top = _camera_controller.y - _camera_controller.half_view_height - _camera_margin;
	var _camera_bottom = _camera_controller.y + _camera_controller.half_view_height + _camera_margin;

	return _world_x >= _camera_left
		&& _world_x <= _camera_right
		&& _world_y >= _camera_top
		&& _world_y <= _camera_bottom;
};

brute_grave_slam_camera_shake_try = function(_origin_x, _origin_y)
{
	if (!brute_world_position_is_on_camera(_origin_x, _origin_y)
		|| !instance_exists(o_camera_controller))
	{
		return;
	}

	var _camera_controller = instance_find(o_camera_controller, 0);

	if (variable_instance_exists(_camera_controller, "camera_shake_start"))
	{
		_camera_controller.camera_shake_start(
			BALANCE_BRUTE_GRAVE_SLAM_SHAKE_TIME,
			BALANCE_BRUTE_GRAVE_SLAM_SHAKE_STRENGTH
		);
	}
};

brute_grave_slam_use = function()
{
	if (!brute_has_grave_slam_target())
	{
		return false;
	}

	var _grave_slam_level = max(1, brute_ability_level_get(DEMON_ABILITY.BRUTE_GRAVE_SLAM));
	var _slam_radius = brute_grave_slam_radius_get();
	var _slam_damage = damage * BALANCE_BRUTE_GRAVE_SLAM_DAMAGE_MULTIPLIER;

	if (_grave_slam_level >= 3)
	{
		_slam_damage += damage * BALANCE_BRUTE_GRAVE_SLAM_SPIKE_DAMAGE_MULTIPLIER;
	}

	ability_popup_create(x, y, DEMON_ABILITY.BRUTE_GRAVE_SLAM);
	demon_active_ability_used_notify(DEMON_ABILITY.BRUTE_GRAVE_SLAM);

	var _killed_positions = brute_damage_enemy_in_aoe(
		x,
		y,
		_slam_radius,
		_slam_damage,
		BALANCE_BRUTE_GRAVE_SLAM_STUN_TIME,
		BALANCE_BRUTE_GRAVE_SLAM_KNOCKBACK_DISTANCE
	);

	brute_aoe_circle_show(x, y, _slam_radius, false);
	brute_grave_slam_camera_shake_try(x, y);

	if (variable_global_exists("explosion_sounds") && variable_global_exists("sound_play_random"))
	{
		global.sound_play_random(global.explosion_sounds);
	}

	if (variable_global_exists("particle_type_brute_grave_slam_smoke"))
	{
		brute_smoke_burst_create(
			x,
			y,
			_slam_radius,
			global.particle_type_brute_grave_slam_smoke,
			BALANCE_BRUTE_GRAVE_SLAM_SMOKE_COUNT
		);
	}

	var _meat_count = instance_number(o_meat);

	for (var _meat_index = _meat_count - 1; _meat_index >= 0; --_meat_index)
	{
		var _meat = instance_find(o_meat, _meat_index);

		if (instance_exists(_meat)
			&& point_distance(x, y, _meat.x, _meat.y) <= _slam_radius)
		{
			brute_meat_explosion_create(_meat.x, _meat.y);

			with (_meat)
			{
				instance_destroy();
			}
		}
	}

	if (_grave_slam_level >= 3)
	{
		brute_grave_slam_spikes_create(x, y, _slam_radius);
	}

	if (_grave_slam_level >= 4)
	{
		for (var _kill_index = 0; _kill_index < array_length(_killed_positions); ++_kill_index)
		{
			brute_meat_explosion_create(_killed_positions[_kill_index][0], _killed_positions[_kill_index][1]);
		}
	}

	return true;
};

brute_chains_target_was_selected = function(_target, _selected_targets)
{
	for (var _target_index = 0; _target_index < array_length(_selected_targets); ++_target_index)
	{
		if (_selected_targets[_target_index] == _target)
		{
			return true;
		}
	}

	return false;
};

brute_chains_targets_find = function()
{
	var _selected_targets = [];
	var _search_radius = brute_chains_search_radius_get();
	var _target_count = brute_chains_target_count_get();

	for (var _selection_index = 0; _selection_index < _target_count; ++_selection_index)
	{
		var _best_target = noone;
		var _best_distance = -1;
		var _enemy_count = instance_number(o_enemy_units);

		for (var _enemy_index = 0; _enemy_index < _enemy_count; ++_enemy_index)
		{
			var _enemy = instance_find(o_enemy_units, _enemy_index);

			if (!target_can_be_attacked(_enemy)
				|| (variable_instance_exists(_enemy, "is_being_hooked") && _enemy.is_being_hooked)
				|| brute_chains_target_was_selected(_enemy, _selected_targets))
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

		if (!instance_exists(_best_target))
		{
			break;
		}

		array_push(_selected_targets, _best_target);
	}

	return _selected_targets;
};

brute_chains_start_damage_apply = function(_target)
{
	return brute_damage_enemy(
		_target,
		damage * BALANCE_BRUTE_BUTCHER_CHAINS_DAMAGE_MULTIPLIER,
		BALANCE_BRUTE_BUTCHER_CHAINS_STUN_TIME,
		0,
		0
	);
};

brute_chain_visual_add = function(_target, _is_second_wave)
{
	array_push(
		hook_chain_visuals,
		{
			target: _target,
			state: hook_chain_state_outbound,
			is_second_wave: _is_second_wave,
			tip_x: x,
			tip_y: y,
			origin_x: x,
			origin_y: y,
			target_x: _target.x,
			target_y: _target.y
		}
	);
};

brute_chains_wave_start = function(_is_second_wave)
{
	var _targets = brute_chains_targets_find();

	if (array_length(_targets) <= 0)
	{
		return false;
	}

	ability_popup_create(x, y, DEMON_ABILITY.BRUTE_BUTCHER_CHAINS);

	if (!_is_second_wave)
	{
		demon_active_ability_used_notify(DEMON_ABILITY.BRUTE_BUTCHER_CHAINS);
	}

	hook_targets = [];
	hook_line_active = true;

	for (var _target_index = 0; _target_index < array_length(_targets); ++_target_index)
	{
		var _target = _targets[_target_index];

		if (!instance_exists(_target))
		{
			continue;
		}

		brute_chain_visual_add(_target, _is_second_wave);
	}

	return true;
};

brute_chain_visuals_update = function()
{
	var _write_index = 0;

	for (var _chain_index = 0; _chain_index < array_length(hook_chain_visuals); ++_chain_index)
	{
		var _chain = hook_chain_visuals[_chain_index];

		if (_chain.state == hook_chain_state_outbound)
		{
			if (target_can_be_attacked(_chain.target))
			{
				_chain.target_x = _chain.target.x;
				_chain.target_y = _chain.target.y;
			}

			var _target_distance = point_distance(_chain.tip_x, _chain.tip_y, _chain.target_x, _chain.target_y);
			var _flight_speed = BALANCE_BRUTE_BUTCHER_CHAINS_LINE_SPEED * gameplay_time_scale;
			var _flight_distance = min(_flight_speed, _target_distance);
			var _flight_direction = point_direction(_chain.tip_x, _chain.tip_y, _chain.target_x, _chain.target_y);
			_chain.tip_x += lengthdir_x(_flight_distance, _flight_direction);
			_chain.tip_y += lengthdir_y(_flight_distance, _flight_direction);

			if (_target_distance <= _flight_speed)
			{
				if (target_can_be_attacked(_chain.target))
				{
					var _target_was_killed = brute_chains_start_damage_apply(_chain.target);

					if (!_target_was_killed)
					{
						_chain.target.is_being_hooked = true;
						_chain.target.target_instance = id;
						array_push(hook_targets, _chain.target);
						continue;
					}

					if (!_chain.is_second_wave && brute_ability_level_get(DEMON_ABILITY.BRUTE_BUTCHER_CHAINS) >= 4)
					{
						butcher_chains_second_wave_pending = true;
					}
				}

				_chain.state = hook_chain_state_returning;
				_chain.tip_x = _chain.target_x;
				_chain.tip_y = _chain.target_y;
			}
		}
		else
		{
			var _return_distance_to_brute = point_distance(_chain.tip_x, _chain.tip_y, x, y);
			var _return_speed = BALANCE_BRUTE_BUTCHER_CHAINS_LINE_RETURN_SPEED * gameplay_time_scale;
			var _return_distance = min(_return_speed, _return_distance_to_brute);
			var _return_direction = point_direction(_chain.tip_x, _chain.tip_y, x, y);
			_chain.tip_x += lengthdir_x(_return_distance, _return_direction);
			_chain.tip_y += lengthdir_y(_return_distance, _return_direction);

			if (_return_distance_to_brute <= _return_speed)
			{
				continue;
			}
		}

		hook_chain_visuals[_write_index] = _chain;
		_write_index++;
	}

	array_resize(hook_chain_visuals, _write_index);
};

brute_hook_update = function()
{
	brute_chain_visuals_update();

	if (array_length(hook_targets) <= 0 && array_length(hook_chain_visuals) <= 0)
	{
		hook_line_active = false;

		if (butcher_chains_second_wave_pending)
		{
			butcher_chains_second_wave_pending = false;
			brute_chains_wave_start(true);
		}

		return;
	}

	hook_line_active = true;

	var _write_index = 0;

	for (var _target_index = 0; _target_index < array_length(hook_targets); ++_target_index)
	{
		var _target = hook_targets[_target_index];

		if (!target_can_be_attacked(_target))
		{
			continue;
		}

		var _distance_to_brute = point_distance(_target.x, _target.y, x, y);

		if (_distance_to_brute <= BALANCE_BRUTE_BUTCHER_CHAINS_RELEASE_RADIUS)
		{
			_target.is_being_hooked = false;
			_target.forced_attack_target = id;
			_target.forced_attack_target_timer = BALANCE_BRUTE_BUTCHER_CHAINS_FORCED_ATTACK_TIME * room_speed;
			_target.target_instance = id;
			continue;
		}

		var _pull_direction = point_direction(_target.x, _target.y, x, y);
		var _pull_speed = BALANCE_BRUTE_BUTCHER_CHAINS_PULL_SPEED * gameplay_time_scale;
		var _pull_distance = min(_pull_speed, _distance_to_brute);
		_target.x += lengthdir_x(_pull_distance, _pull_direction);
		_target.y += lengthdir_y(_pull_distance, _pull_direction);
		hook_targets[_write_index] = _target;
		_write_index++;
	}

	array_resize(hook_targets, _write_index);
	hook_line_active = _write_index > 0;
};

brute_corpse_armor_apply = function(_target, _duration_seconds, _armor_bonus, _retaliation_damage)
{
	if (!instance_exists(_target)
		|| !variable_instance_exists(_target, "armor")
		|| !variable_instance_exists(_target, "corpse_armor_timer"))
	{
		return;
	}

	if (_target.corpse_armor_timer > 0)
	{
		_target.armor -= _target.corpse_armor_bonus;
	}

	_target.corpse_armor_bonus = _armor_bonus;
	_target.corpse_armor_timer = _duration_seconds * room_speed;
	_target.corpse_armor_retaliation_damage = _retaliation_damage;
	_target.armor += _armor_bonus;
};

brute_corpse_armor_use = function()
{
	if (corpse_armor_timer > 0)
	{
		return false;
	}

	var _corpse_armor_level = max(1, brute_ability_level_get(DEMON_ABILITY.BRUTE_CORPSE_ARMOR));
	var _retaliation_damage = 0;

	if (_corpse_armor_level >= 3)
	{
		_retaliation_damage = damage * BALANCE_BRUTE_CORPSE_ARMOR_RETALIATION_DAMAGE_MULTIPLIER;
	}

	brute_corpse_armor_apply(
		id,
		brute_corpse_armor_duration_get(),
		BALANCE_BRUTE_CORPSE_ARMOR_BONUS,
		_retaliation_damage
	);

	if (_corpse_armor_level >= 4)
	{
		var _ally_count = instance_number(o_friendly_units);

		for (var _ally_index = 0; _ally_index < _ally_count; ++_ally_index)
		{
			var _ally = instance_find(o_friendly_units, _ally_index);

			if (instance_exists(_ally)
				&& _ally != id
				&& variable_instance_exists(_ally, "demon_type")
				&& _ally.demon_type != DEMON_TYPE.NONE
				&& point_distance(x, y, _ally.x, _ally.y) <= BALANCE_BRUTE_CORPSE_ARMOR_ALLY_RADIUS)
			{
				brute_corpse_armor_apply(
					_ally,
					BALANCE_BRUTE_CORPSE_ARMOR_ALLY_DURATION,
					BALANCE_BRUTE_CORPSE_ARMOR_ALLY_BONUS,
					0
				);
			}
		}
	}

	if (variable_global_exists("particle_type_brute_meat_explosion_smoke"))
	{
		brute_smoke_burst_create(x, y, 40, global.particle_type_brute_meat_explosion_smoke, 10);
	}

	ability_popup_create(x, y, DEMON_ABILITY.BRUTE_CORPSE_ARMOR);
	demon_active_ability_used_notify(DEMON_ABILITY.BRUTE_CORPSE_ARMOR);

	return true;
};

brute_blood_anvil_active_recharge = function(_recharge_share)
{
	var _recharge_amount = 0;

	if (cultist_active_ability_has(id, DEMON_ABILITY.BRUTE_GRAVE_SLAM))
	{
		_recharge_amount = ability_cooldown_time_get(grave_slam_cooldown) * _recharge_share;
		grave_slam_timer = max(grave_slam_timer - _recharge_amount, 0);
	}

	if (cultist_active_ability_has(id, DEMON_ABILITY.BRUTE_BUTCHER_CHAINS))
	{
		_recharge_amount = ability_cooldown_time_get(butcher_chains_cooldown) * _recharge_share;
		butcher_chains_timer = max(butcher_chains_timer - _recharge_amount, 0);
	}

	if (cultist_active_ability_has(id, DEMON_ABILITY.BRUTE_CORPSE_ARMOR))
	{
		_recharge_amount = ability_cooldown_time_get(corpse_armor_cooldown) * _recharge_share;
		corpse_armor_ability_timer = max(corpse_armor_ability_timer - _recharge_amount, 0);
	}
};

brute_blood_anvil_trigger = function(_source_demon)
{
	var _blood_anvil_level = brute_ability_level_get(DEMON_ABILITY.BRUTE_BLOOD_ANVIL);

	if (_blood_anvil_level <= 0 || !instance_exists(_source_demon))
	{
		return;
	}

	var _trigger_radius = BALANCE_BRUTE_BLOOD_ANVIL_RADIUS;
	var _recharge_share = BALANCE_BRUTE_BLOOD_ANVIL_RECHARGE_SHARE;

	if (_blood_anvil_level >= 2)
	{
		_recharge_share = BALANCE_BRUTE_BLOOD_ANVIL_RECHARGE_SHARE_LEVEL_2;
	}

	if (_blood_anvil_level >= 3)
	{
		_trigger_radius = BALANCE_BRUTE_BLOOD_ANVIL_RADIUS_LEVEL_3;
	}

	if (point_distance(x, y, _source_demon.x, _source_demon.y) > _trigger_radius)
	{
		return;
	}

	brute_blood_anvil_active_recharge(_recharge_share);

	if (_blood_anvil_level >= 4)
	{
		var _ally_count = instance_number(o_friendly_units);

		for (var _ally_index = 0; _ally_index < _ally_count; ++_ally_index)
		{
			var _ally = instance_find(o_friendly_units, _ally_index);

			if (instance_exists(_ally)
				&& _ally != id
				&& variable_instance_exists(_ally, "demon_type")
				&& _ally.demon_type != DEMON_TYPE.NONE
				&& point_distance(x, y, _ally.x, _ally.y) <= BALANCE_BRUTE_BLOOD_ANVIL_RADIUS_LEVEL_3
				&& variable_instance_exists(_ally, "brute_blood_anvil_active_recharge"))
			{
				_ally.brute_blood_anvil_active_recharge(BALANCE_BRUTE_BLOOD_ANVIL_ALLY_RECHARGE_SHARE);
			}
		}
	}
};

brute_corpse_eater_update = function()
{
	if (!has_brute_corpse_eater || !BALANCE_BRUTE_CORPSE_EATER_ENABLED)
	{
		return false;
	}

	if (corpse_eater_cooldown_timer > 0)
	{
		corpse_eater_cooldown_timer -= gameplay_time_scale;
	}

	if (corpse_eater_cooldown_timer > 0 || hp >= max_hp)
	{
		return false;
	}

	var _corpse = brute_nearest_corpse_find();

	if (!is_struct(_corpse))
	{
		return false;
	}

	target_instance = noone;
	is_attacking_target = false;

	var _corpse_distance = point_distance(x, y, _corpse.x, _corpse.y);

	if (_corpse_distance > corpse_eater_eat_radius)
	{
		move_towards_world_point(_corpse.x, _corpse.y);
		return true;
	}

	return brute_corpse_consume(_corpse);
};

unit_special_behavior_update = function()
{
	return brute_corpse_eater_update();
};
