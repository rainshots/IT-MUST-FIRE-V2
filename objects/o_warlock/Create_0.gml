// Initialize shared friendly combat state.
event_inherited();

// Demon sprites are scaled up for readability.
image_xscale = 1.2;
image_yscale = image_xscale;

// Default possession data is replaced by the controller when transformed.
cultist_name = "Warlock";
cultist_points = array_create(CULTIST_STAT.COUNT, 0);
demon_type = DEMON_TYPE.WARLOCK;
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

// Deprecated passive flags are kept only for old transform copy code.
has_warlock_soul_harvester = false;
has_warlock_curseweaver = false;
has_warlock_demonic_infusion = false;

// Demon combat stats are derived from base stats and cultist attributes.
cultist_stats_apply(id);

// Warlock passive state.
demonic_infusion_radius = BALANCE_WARLOCK_DEMONIC_INFUSION_RADIUS;
demonic_infusion_heal_timer = 0;
soul_engine_souls_collected = 0;
soul_engine_souls = [];
soul_engine_skulls = [];
familiar_sprite_index = s_familiar;
familiar_data = [];

// Warlock active abilities keep independent cooldown state.
raise_lesser_demon_cooldown = BALANCE_WARLOCK_RAISE_LESSER_DEMON_COOLDOWN * room_speed;
raise_lesser_demon_timer = 0;
raise_lesser_demon_retry_timer = 0;
soul_chain_cooldown = BALANCE_WARLOCK_SOUL_CHAIN_COOLDOWN * room_speed;
soul_chain_cooldown_timer = 0;
soul_chain_retry_timer = 0;
hex_totem_cooldown = BALANCE_WARLOCK_HEX_TOTEM_COOLDOWN * room_speed;
hex_totem_timer = 0;
hex_totem_retry_timer = 0;
raise_lesser_demon_line_timer = 0;
raise_lesser_demon_line_duration = BALANCE_WARLOCK_RAISE_LESSER_DEMON_LINE_TIME * room_speed;
raise_lesser_demon_line_x = x;
raise_lesser_demon_line_y = y;
hex_totem_line_timer = 0;
hex_totem_line_duration = BALANCE_WARLOCK_HEX_TOTEM_LINE_TIME * room_speed;
hex_totem_line_x = x;
hex_totem_line_y = y;
soul_chain_groups = [];

brute_blood_anvil_active_recharge = function(_recharge_share)
{
	var _recharge_amount = 0;

	if (cultist_active_ability_has(id, DEMON_ABILITY.WARLOCK_RAISE_LESSER_DEMON))
	{
		_recharge_amount = ability_cooldown_time_get(raise_lesser_demon_cooldown) * _recharge_share;
		raise_lesser_demon_timer = max(raise_lesser_demon_timer - _recharge_amount, 0);
	}

	if (cultist_active_ability_has(id, DEMON_ABILITY.WARLOCK_SOUL_CHAIN))
	{
		_recharge_amount = ability_cooldown_time_get(soul_chain_cooldown) * _recharge_share;
		soul_chain_cooldown_timer = max(soul_chain_cooldown_timer - _recharge_amount, 0);
	}

	if (cultist_active_ability_has(id, DEMON_ABILITY.WARLOCK_HEX_TOTEM))
	{
		_recharge_amount = ability_cooldown_time_get(hex_totem_cooldown) * _recharge_share;
		hex_totem_timer = max(hex_totem_timer - _recharge_amount, 0);
	}
};

warlock_ability_level_get = function(_ability)
{
	return cultist_ability_level_get(id, _ability);
};

warlock_magic_damage_value_get = function(_multiplier)
{
	return max(1, magic_damage * _multiplier);
};

warlock_magic_damage_apply = function(_target, _damage_amount)
{
	if (!target_can_be_attacked(_target) || _damage_amount <= 0)
	{
		return false;
	}

	var _final_damage = magic_damage_after_resistance(_damage_amount, _target);

	if (variable_instance_exists(_target, "unit_damage_receive"))
	{
		_target.unit_damage_receive(_final_damage, unit_faction, false, true, id);
	}
	else if (variable_instance_exists(_target, "hp"))
	{
		_target.hp = max(_target.hp - _final_damage, 0);
		damage_popup_create(_target.x, _target.y, _final_damage, _target.unit_faction);
	}

	return true;
};

warlock_enemy_nearest_find = function(_origin_x, _origin_y, _search_radius)
{
	var _nearest_enemy = noone;
	var _nearest_distance = _search_radius;
	var _enemy_count = instance_number(o_enemy_units);

	for (var _enemy_index = 0; _enemy_index < _enemy_count; ++_enemy_index)
	{
		var _enemy = instance_find(o_enemy_units, _enemy_index);

		if (!target_can_be_attacked(_enemy))
		{
			continue;
		}

		var _enemy_distance = point_distance(_origin_x, _origin_y, _enemy.x, _enemy.y);

		if (_enemy_distance <= _nearest_distance)
		{
			_nearest_enemy = _enemy;
			_nearest_distance = _enemy_distance;
		}
	}

	return _nearest_enemy;
};

warlock_smoke_burst_create = function(_burst_x, _burst_y, _burst_radius, _particle_type, _particle_count)
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

warlock_demonic_infusion_update = function()
{
	var _level = warlock_ability_level_get(DEMON_ABILITY.WARLOCK_DEMONIC_INFUSION);

	if (_level <= 0)
	{
		return;
	}

	demonic_infusion_radius = BALANCE_WARLOCK_DEMONIC_INFUSION_RADIUS;

	if (_level >= 2)
	{
		demonic_infusion_radius = BALANCE_WARLOCK_DEMONIC_INFUSION_RADIUS_LEVEL_2;
	}

	demonic_infusion_heal_timer--;

	if (demonic_infusion_heal_timer <= 0)
	{
		demonic_infusion_heal_timer = BALANCE_WARLOCK_DEMONIC_INFUSION_TICK_TIME * room_speed;
	}

	var _should_heal = demonic_infusion_heal_timer == BALANCE_WARLOCK_DEMONIC_INFUSION_TICK_TIME * room_speed;
	var _heal_share = BALANCE_WARLOCK_DEMONIC_INFUSION_HEAL_SHARE;
	var _attack_speed_bonus = BALANCE_WARLOCK_DEMONIC_INFUSION_ATTACK_SPEED_BONUS;

	if (_level >= 4)
	{
		_heal_share = BALANCE_WARLOCK_DEMONIC_INFUSION_HEAL_SHARE_LEVEL_4;
		_attack_speed_bonus = BALANCE_WARLOCK_DEMONIC_INFUSION_ATTACK_SPEED_BONUS_LEVEL_4;
	}

	var _reload_multiplier = 1 / (1 + _attack_speed_bonus);
	var _refresh_time = BALANCE_WARLOCK_DEMONIC_INFUSION_REFRESH_TIME * room_speed;
	var _friendly_list = ds_list_create();
	var _friendly_count = collision_circle_list(x, y, demonic_infusion_radius, o_friendly_units, false, true, _friendly_list, false);

	for (var _friendly_index = 0; _friendly_index < _friendly_count; ++_friendly_index)
	{
		var _friendly = _friendly_list[| _friendly_index];

		if (!instance_exists(_friendly) || !variable_instance_exists(_friendly, "hp") || !variable_instance_exists(_friendly, "max_hp"))
		{
			continue;
		}

		if (_should_heal && _friendly.hp > 0 && _friendly.hp < _friendly.max_hp)
		{
			var _hp_before_heal = _friendly.hp;
			var _heal_cap = BALANCE_WARLOCK_DEMONIC_INFUSION_HEAL_PER_SECOND_MAX * BALANCE_WARLOCK_DEMONIC_INFUSION_TICK_TIME;
			var _heal_amount = min(_friendly.max_hp * _heal_share, _heal_cap);

			_friendly.hp = min(_friendly.hp + _heal_amount, _friendly.max_hp);
			heal_feedback_create(_friendly, _friendly.hp - _hp_before_heal);
		}

		if (_level >= 3
			&& _friendly != id
			&& variable_instance_exists(_friendly, "demonic_infusion_timer")
			&& variable_instance_exists(_friendly, "demonic_infusion_reload_multiplier"))
		{
			_friendly.demonic_infusion_timer = max(_friendly.demonic_infusion_timer, _refresh_time);
			_friendly.demonic_infusion_reload_multiplier = min(_friendly.demonic_infusion_reload_multiplier, _reload_multiplier);

			if (variable_instance_exists(_friendly, "reload_timer") && variable_instance_exists(_friendly, "reload_time"))
			{
				_friendly.reload_timer = min(_friendly.reload_timer, _friendly.reload_time * _reload_multiplier);
			}
		}
	}

	ds_list_destroy(_friendly_list);
};

warlock_soul_engine_required_souls_get = function()
{
	var _level = warlock_ability_level_get(DEMON_ABILITY.WARLOCK_SOUL_ENGINE);

	if (_level >= 4)
	{
		return BALANCE_WARLOCK_SOUL_ENGINE_SOULS_REQUIRED_LEVEL_4;
	}
	else if (_level >= 2)
	{
		return BALANCE_WARLOCK_SOUL_ENGINE_SOULS_REQUIRED_LEVEL_2;
	}

	return BALANCE_WARLOCK_SOUL_ENGINE_SOULS_REQUIRED;
};

warlock_soul_engine_enemy_death_notify = function(_death_x, _death_y)
{
	if (warlock_ability_level_get(DEMON_ABILITY.WARLOCK_SOUL_ENGINE) <= 0
		|| hp <= 0
		|| point_distance(x, y, _death_x, _death_y) > BALANCE_WARLOCK_SOUL_ENGINE_RADIUS)
	{
		return;
	}

	array_push(soul_engine_souls, {
		x: _death_x,
		y: _death_y,
		size: random_range(BALANCE_WARLOCK_PASSIVE_PARTICLE_SIZE_MIN, BALANCE_WARLOCK_PASSIVE_PARTICLE_SIZE_MAX)
	});
};

warlock_soul_engine_skull_fire = function()
{
	var _target = warlock_enemy_nearest_find(x, y, BALANCE_WARLOCK_SOUL_ENGINE_RADIUS);

	if (!instance_exists(_target))
	{
		return false;
	}

	array_push(soul_engine_skulls, {
		x: x,
		y: y - 12,
		target: _target,
		level: warlock_ability_level_get(DEMON_ABILITY.WARLOCK_SOUL_ENGINE)
	});

	return true;
};

warlock_soul_engine_hit_feedback_apply = function(_target, _hit_x, _hit_y)
{
	if (!instance_exists(_target))
	{
		return;
	}

	// Soul Engine impacts leave a small purple smoke burst.
	if (variable_global_exists("particle_type_warlock_curseweaver_smoke"))
	{
		warlock_smoke_burst_create(
			_target.x,
			_target.y,
			BALANCE_WARLOCK_SOUL_ENGINE_SKULL_HIT_SMOKE_RADIUS,
			global.particle_type_warlock_curseweaver_smoke,
			BALANCE_WARLOCK_SOUL_ENGINE_SKULL_HIT_SMOKE_COUNT
		);
	}

	if (!variable_instance_exists(_target, "hp") || _target.hp <= 0)
	{
		return;
	}

	var _knockback_direction = point_direction(_hit_x, _hit_y, _target.x, _target.y);

	if (point_distance(_hit_x, _hit_y, _target.x, _target.y) <= 0)
	{
		_knockback_direction = point_direction(x, y, _target.x, _target.y);
	}

	_target.x += lengthdir_x(BALANCE_WARLOCK_SOUL_ENGINE_SKULL_KNOCKBACK_DISTANCE, _knockback_direction);
	_target.y += lengthdir_y(BALANCE_WARLOCK_SOUL_ENGINE_SKULL_KNOCKBACK_DISTANCE, _knockback_direction);
};

warlock_soul_engine_souls_update = function()
{
	var _write_index = 0;

	for (var _soul_index = 0; _soul_index < array_length(soul_engine_souls); ++_soul_index)
	{
		var _soul = soul_engine_souls[_soul_index];
		var _distance = point_distance(_soul.x, _soul.y, x, y);

		if (_distance <= BALANCE_WARLOCK_SOUL_ENGINE_SOUL_SPEED)
		{
			soul_engine_souls_collected++;

			if (soul_engine_souls_collected >= warlock_soul_engine_required_souls_get())
			{
				if (warlock_soul_engine_skull_fire())
				{
					soul_engine_souls_collected = 0;
				}
			}

			continue;
		}

		var _direction = point_direction(_soul.x, _soul.y, x, y);
		_soul.x += lengthdir_x(BALANCE_WARLOCK_SOUL_ENGINE_SOUL_SPEED, _direction);
		_soul.y += lengthdir_y(BALANCE_WARLOCK_SOUL_ENGINE_SOUL_SPEED, _direction);
		soul_engine_souls[_write_index] = _soul;
		_write_index++;
	}

	array_resize(soul_engine_souls, _write_index);
};

warlock_soul_engine_skulls_update = function()
{
	var _write_index = 0;

	for (var _skull_index = 0; _skull_index < array_length(soul_engine_skulls); ++_skull_index)
	{
		var _skull = soul_engine_skulls[_skull_index];

		if (!target_can_be_attacked(_skull.target))
		{
			_skull.target = warlock_enemy_nearest_find(_skull.x, _skull.y, BALANCE_WARLOCK_SOUL_ENGINE_RADIUS);
		}

		if (!instance_exists(_skull.target))
		{
			continue;
		}

		var _distance = point_distance(_skull.x, _skull.y, _skull.target.x, _skull.target.y);

		if (_distance <= BALANCE_WARLOCK_SOUL_ENGINE_SKULL_HIT_RADIUS)
		{
			var _hit_x = _skull.x;
			var _hit_y = _skull.y;

			warlock_magic_damage_apply(_skull.target, warlock_magic_damage_value_get(BALANCE_WARLOCK_SOUL_ENGINE_SKULL_DAMAGE_MULTIPLIER));
			warlock_soul_engine_hit_feedback_apply(_skull.target, _hit_x, _hit_y);

			if (_skull.level >= 3)
			{
				var _enemy_list = ds_list_create();
				var _enemy_count = collision_circle_list(
					_skull.target.x,
					_skull.target.y,
					BALANCE_WARLOCK_SOUL_ENGINE_SKULL_AOE_RADIUS,
					o_enemy_units,
					false,
					true,
					_enemy_list,
					false
				);

				for (var _enemy_index = 0; _enemy_index < _enemy_count; ++_enemy_index)
				{
					var _enemy = _enemy_list[| _enemy_index];

					if (_enemy != _skull.target)
					{
						warlock_magic_damage_apply(_enemy, warlock_magic_damage_value_get(BALANCE_WARLOCK_SOUL_ENGINE_SKULL_AOE_DAMAGE_MULTIPLIER));
						warlock_soul_engine_hit_feedback_apply(_enemy, _hit_x, _hit_y);
					}
				}

				ds_list_destroy(_enemy_list);
			}

			continue;
		}

		var _direction = point_direction(_skull.x, _skull.y, _skull.target.x, _skull.target.y);
		_skull.x += lengthdir_x(BALANCE_WARLOCK_SOUL_ENGINE_SKULL_SPEED, _direction);
		_skull.y += lengthdir_y(BALANCE_WARLOCK_SOUL_ENGINE_SKULL_SPEED, _direction);
		soul_engine_skulls[_write_index] = _skull;
		_write_index++;
	}

	array_resize(soul_engine_skulls, _write_index);
};

warlock_soul_engine_update = function()
{
	if (warlock_ability_level_get(DEMON_ABILITY.WARLOCK_SOUL_ENGINE) <= 0)
	{
		soul_engine_souls = [];
		soul_engine_skulls = [];
		soul_engine_souls_collected = 0;
		return;
	}

	warlock_soul_engine_souls_update();
	warlock_soul_engine_skulls_update();
};

warlock_familiar_target_find = function(_familiar_x, _familiar_y)
{
	return warlock_enemy_nearest_find(_familiar_x, _familiar_y, BALANCE_WARLOCK_FAMILIAR_ATTACK_RADIUS);
};

warlock_familiar_count_get = function()
{
	var _level = warlock_ability_level_get(DEMON_ABILITY.WARLOCK_FAMILIAR);

	if (_level >= 4)
	{
		return 3;
	}
	else if (_level >= 2)
	{
		return 2;
	}
	else if (_level >= 1)
	{
		return 1;
	}

	return 0;
};

warlock_familiar_update = function()
{
	var _target_count = warlock_familiar_count_get();

	var _familiar_missing_count = _target_count - array_length(familiar_data);

	for (var _missing_index = 0; _missing_index < _familiar_missing_count; ++_missing_index)
	{
		array_push(familiar_data, {
			angle: random(360),
			x: x,
			y: y,
			attack_timer: random(room_speed),
			attack_line_timer: 0,
			attack_line_x: x,
			attack_line_y: y
		});
	}

	if (array_length(familiar_data) > _target_count)
	{
		array_resize(familiar_data, _target_count);
	}

	var _level = warlock_ability_level_get(DEMON_ABILITY.WARLOCK_FAMILIAR);
	var _damage_multiplier = BALANCE_WARLOCK_FAMILIAR_DAMAGE_MULTIPLIER;

	if (_level >= 3)
	{
		_damage_multiplier *= BALANCE_WARLOCK_FAMILIAR_DAMAGE_LEVEL_3_MULTIPLIER;
	}

	for (var _familiar_index = 0; _familiar_index < array_length(familiar_data); ++_familiar_index)
	{
		var _familiar = familiar_data[_familiar_index];
		var _angle_offset = 360 / max(1, _target_count);

		_familiar.angle += BALANCE_WARLOCK_FAMILIAR_ORBIT_SPEED;
		_familiar.x = x + lengthdir_x(BALANCE_WARLOCK_FAMILIAR_ORBIT_RADIUS, _familiar.angle + (_angle_offset * _familiar_index));
		_familiar.y = y + lengthdir_y(BALANCE_WARLOCK_FAMILIAR_ORBIT_RADIUS * 0.65, _familiar.angle + (_angle_offset * _familiar_index));

		if (_familiar.attack_timer > 0)
		{
			_familiar.attack_timer--;
		}

		if (_familiar.attack_line_timer > 0)
		{
			_familiar.attack_line_timer--;
		}

		if (_familiar.attack_timer <= 0)
		{
			var _target = warlock_familiar_target_find(_familiar.x, _familiar.y);

			if (instance_exists(_target))
			{
				warlock_magic_damage_apply(_target, warlock_magic_damage_value_get(_damage_multiplier));
				_familiar.attack_line_x = _target.x;
				_familiar.attack_line_y = _target.y;
				_familiar.attack_line_timer = 0.15 * room_speed;
			}

			_familiar.attack_timer = BALANCE_WARLOCK_FAMILIAR_ATTACK_TIME * room_speed;
		}

		familiar_data[_familiar_index] = _familiar;
	}
};

warlock_skeleton_configure = function(_skeleton, _level)
{
	if (!instance_exists(_skeleton))
	{
		return;
	}

	// Keep regular Graveyard skeleton stats; only add Warlock ability behavior.
	_skeleton.warlock_skeleton_explosion_enabled = _level >= 3;
	_skeleton.warlock_skeleton_explosion_damage = BALANCE_WARLOCK_SUMMON_SKELETONS_EXPLOSION_DAMAGE;
	_skeleton.warlock_skeleton_respawn_chance = 0;
	_skeleton.warlock_skeleton_dies_at_morning = true;

	if (_level >= 4)
	{
		_skeleton.warlock_skeleton_respawn_chance = BALANCE_WARLOCK_SUMMON_SKELETONS_RESPAWN_CHANCE;
	}
};

warlock_raise_lesser_demon_use = function()
{
	if (!instance_exists(o_game_controller))
	{
		return false;
	}

	var _game_controller = instance_find(o_game_controller, 0);

	if (!variable_instance_exists(_game_controller, "corpse_nearest_take"))
	{
		return false;
	}

	var _level = max(1, warlock_ability_level_get(DEMON_ABILITY.WARLOCK_RAISE_LESSER_DEMON));
	var _skeleton_count = BALANCE_WARLOCK_SUMMON_SKELETONS_COUNT;
	var _summoned_count = 0;

	if (_level >= 2)
	{
		_skeleton_count = BALANCE_WARLOCK_SUMMON_SKELETONS_COUNT_LEVEL_2;
	}

	for (var _skeleton_index = 0; _skeleton_index < _skeleton_count; ++_skeleton_index)
	{
		var _corpse = _game_controller.corpse_nearest_take(x, y);

		if (!is_struct(_corpse))
		{
			break;
		}

		var _spawn_x = _corpse.x;
		var _spawn_y = _corpse.y;
		var _skeleton = instance_create_layer(_spawn_x, _spawn_y, "Instances", o_skeleton);

		warlock_skeleton_configure(_skeleton, _level);

		raise_lesser_demon_line_x = _spawn_x;
		raise_lesser_demon_line_y = _spawn_y;
		raise_lesser_demon_line_timer = raise_lesser_demon_line_duration;
		_summoned_count++;

		if (variable_global_exists("particle_type_warlock_summon_skeleton_smoke"))
		{
			warlock_smoke_burst_create(
				_spawn_x,
				_spawn_y,
				BALANCE_WARLOCK_RAISE_LESSER_DEMON_SMOKE_RADIUS,
				global.particle_type_warlock_summon_skeleton_smoke,
				BALANCE_WARLOCK_RAISE_LESSER_DEMON_SMOKE_COUNT
			);
		}
	}

	if (_summoned_count <= 0)
	{
		return false;
	}

	ability_popup_create(x, y, DEMON_ABILITY.WARLOCK_RAISE_LESSER_DEMON);
	demon_active_ability_used_notify(DEMON_ABILITY.WARLOCK_RAISE_LESSER_DEMON);

	return true;
};

warlock_array_contains_instance = function(_array, _instance)
{
	for (var _array_index = 0; _array_index < array_length(_array); ++_array_index)
	{
		if (_array[_array_index] == _instance)
		{
			return true;
		}
	}

	return false;
};

warlock_enemy_can_be_chained = function(_enemy)
{
	return target_can_be_attacked(_enemy)
		&& variable_instance_exists(_enemy, "soul_chain_id")
		&& _enemy.soul_chain_id == noone
		&& variable_instance_exists(_enemy, "soul_chain_apply");
};

warlock_soul_chain_max_targets_get = function()
{
	if (warlock_ability_level_get(DEMON_ABILITY.WARLOCK_SOUL_CHAIN) >= 2)
	{
		return BALANCE_WARLOCK_SOUL_CHAIN_MAX_TARGETS_LEVEL_2;
	}

	return BALANCE_WARLOCK_SOUL_CHAIN_MAX_TARGETS;
};

warlock_soul_chain_members_near_get = function(_center_enemy)
{
	var _members = [];
	var _enemy_count = instance_number(o_enemy_units);
	var _max_targets = warlock_soul_chain_max_targets_get();

	for (var _member_slot = 0; _member_slot < _max_targets; ++_member_slot)
	{
		var _nearest_enemy = noone;
		var _nearest_distance = BALANCE_WARLOCK_SOUL_CHAIN_GROUP_RADIUS;

		for (var _enemy_index = 0; _enemy_index < _enemy_count; ++_enemy_index)
		{
			var _enemy = instance_find(o_enemy_units, _enemy_index);

			if (!warlock_enemy_can_be_chained(_enemy) || warlock_array_contains_instance(_members, _enemy))
			{
				continue;
			}

			var _enemy_distance = point_distance(_center_enemy.x, _center_enemy.y, _enemy.x, _enemy.y);

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

		array_push(_members, _nearest_enemy);
	}

	return _members;
};

warlock_soul_chain_members_find = function()
{
	var _best_members = [];
	var _best_count = 0;
	var _best_distance = infinity;
	var _enemy_count = instance_number(o_enemy_units);
	var _max_targets = warlock_soul_chain_max_targets_get();

	for (var _enemy_index = 0; _enemy_index < _enemy_count; ++_enemy_index)
	{
		var _enemy = instance_find(o_enemy_units, _enemy_index);

		if (!warlock_enemy_can_be_chained(_enemy)
			|| point_distance(x, y, _enemy.x, _enemy.y) > BALANCE_WARLOCK_SOUL_CHAIN_SEARCH_RADIUS)
		{
			continue;
		}

		var _members = warlock_soul_chain_members_near_get(_enemy);
		var _member_count = array_length(_members);
		var _distance_to_warlock = point_distance(x, y, _enemy.x, _enemy.y);
		var _is_better_group = _member_count > _best_count
			|| (_member_count == _best_count && _distance_to_warlock < _best_distance);

		if (_is_better_group)
		{
			_best_members = _members;
			_best_count = _member_count;
			_best_distance = _distance_to_warlock;
		}

		if (_best_count >= _max_targets)
		{
			break;
		}
	}

	if (_best_count < BALANCE_WARLOCK_SOUL_CHAIN_MIN_TARGETS)
	{
		return [];
	}

	return _best_members;
};

warlock_soul_chain_use = function()
{
	var _members = warlock_soul_chain_members_find();

	if (array_length(_members) < BALANCE_WARLOCK_SOUL_CHAIN_MIN_TARGETS)
	{
		return false;
	}

	if (!variable_global_exists("soul_chain_next_id"))
	{
		global.soul_chain_next_id = 1;
	}

	var _level = warlock_ability_level_get(DEMON_ABILITY.WARLOCK_SOUL_CHAIN);
	var _chain_id = global.soul_chain_next_id;
	var _death_stun_time = 0;
	var _death_damage = 0;
	global.soul_chain_next_id++;

	if (_level >= 3)
	{
		_death_stun_time = BALANCE_WARLOCK_SOUL_CHAIN_DEATH_STUN_TIME;
	}

	if (_level >= 4)
	{
		_death_damage = warlock_magic_damage_value_get(BALANCE_WARLOCK_SOUL_CHAIN_DEATH_DAMAGE_MULTIPLIER);
	}

	for (var _member_index = 0; _member_index < array_length(_members); ++_member_index)
	{
		var _member = _members[_member_index];
		_member.soul_chain_apply(
			_chain_id,
			_members,
			BALANCE_WARLOCK_SOUL_CHAIN_DURATION,
			BALANCE_WARLOCK_SOUL_CHAIN_DAMAGE_SHARE,
			_death_stun_time,
			_death_damage
		);
	}

	ability_popup_create(x, y, DEMON_ABILITY.WARLOCK_SOUL_CHAIN);
	demon_active_ability_used_notify(DEMON_ABILITY.WARLOCK_SOUL_CHAIN);
	array_push(soul_chain_groups, {
		chain_id: _chain_id,
		members: _members,
		timer: BALANCE_WARLOCK_SOUL_CHAIN_DURATION * room_speed
	});

	return true;
};

warlock_soul_chain_clear_members = function(_chain)
{
	var _members = _chain.members;

	for (var _member_index = 0; _member_index < array_length(_members); ++_member_index)
	{
		var _member = _members[_member_index];

		if (instance_exists(_member)
			&& variable_instance_exists(_member, "soul_chain_id")
			&& _member.soul_chain_id == _chain.chain_id
			&& variable_instance_exists(_member, "soul_chain_clear"))
		{
			_member.soul_chain_clear();
		}
	}
};

warlock_soul_chain_groups_update = function()
{
	var _write_index = 0;

	for (var _chain_index = 0; _chain_index < array_length(soul_chain_groups); ++_chain_index)
	{
		var _chain = soul_chain_groups[_chain_index];
		var _living_count = 0;
		var _members = _chain.members;

		_chain.timer--;

		for (var _member_index = 0; _member_index < array_length(_members); ++_member_index)
		{
			var _member = _members[_member_index];

			if (target_can_be_attacked(_member)
				&& variable_instance_exists(_member, "soul_chain_id")
				&& _member.soul_chain_id == _chain.chain_id)
			{
				_living_count++;
			}
		}

		if (_chain.timer > 0 && _living_count >= BALANCE_WARLOCK_SOUL_CHAIN_MIN_TARGETS)
		{
			soul_chain_groups[_write_index] = _chain;
			_write_index++;
		}
		else
		{
			warlock_soul_chain_clear_members(_chain);
		}
	}

	array_resize(soul_chain_groups, _write_index);
};

warlock_hex_totem_enemy_find = function()
{
	return warlock_enemy_nearest_find(x, y, BALANCE_WARLOCK_HEX_TOTEM_SEARCH_RADIUS);
};

warlock_hex_totem_use = function()
{
	var _enemy = warlock_hex_totem_enemy_find();

	if (!instance_exists(_enemy))
	{
		return false;
	}

	var _place_direction = random(360);
	var _place_distance = random_range(
		BALANCE_WARLOCK_HEX_TOTEM_PLACE_DISTANCE_MIN,
		BALANCE_WARLOCK_HEX_TOTEM_PLACE_DISTANCE_MAX
	);
	var _totem_x = _enemy.x + lengthdir_x(_place_distance, _place_direction);
	var _totem_y = _enemy.y + lengthdir_y(_place_distance, _place_direction);
	var _totem = instance_create_layer(_totem_x, _totem_y, "Instances", o_hex_totem);

	ability_popup_create(x, y, DEMON_ABILITY.WARLOCK_HEX_TOTEM);
	demon_active_ability_used_notify(DEMON_ABILITY.WARLOCK_HEX_TOTEM);

	if (instance_exists(_totem))
	{
		_totem.owner_warlock = id;
		_totem.owner_magic_damage = magic_damage;
		_totem.ability_level = max(1, warlock_ability_level_get(DEMON_ABILITY.WARLOCK_HEX_TOTEM));
	}

	hex_totem_line_x = _totem_x;
	hex_totem_line_y = _totem_y;
	hex_totem_line_timer = hex_totem_line_duration;

	if (variable_global_exists("particle_type_warlock_curseweaver_smoke"))
	{
		warlock_smoke_burst_create(
			_totem_x,
			_totem_y,
			BALANCE_WARLOCK_HEX_TOTEM_SMOKE_RADIUS,
			global.particle_type_warlock_curseweaver_smoke,
			BALANCE_WARLOCK_HEX_TOTEM_SMOKE_COUNT
		);
	}

	return true;
};

unit_attack_landed = function(_target, _is_critical_hit = false, _target_was_killed = false)
{
	// New Warlock abilities are driven by aura updates and enemy death hooks.
};
