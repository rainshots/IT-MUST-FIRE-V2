// Initialize shared friendly combat state.
event_inherited();

// Demon sprites are scaled up for readability.
image_xscale = 1.2;
image_yscale = image_xscale

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
pending_ability_upgrade_choices = 0;
passive_choice_options = [];
active_choice_options = [];
ability_upgrade_choice_options = [];
active_abilities = [];
ability_levels = array_create(DEMON_ABILITY.COUNT, 0);

// Demon combat stats are derived from base stats and cultist attributes.
cultist_stats_apply(id);

// Blood Hunger stores one timer per possible stack.
blood_frenzy_stack_timers = array_create(BALANCE_IMP_BLOOD_FRENZY_MAX_STACKS, 0);
blood_frenzy_particle_timer = 0;
blood_blades_angle = 0;
blood_blades_hit_timer = 0;
blood_blades_speed_bonus_timer = 0;
blood_pool_data = [];
frenzy_echo_attack_count = 0;
frenzy_echo_visual_timer = 0;
frenzy_echo_visual_x = x;
frenzy_echo_visual_y = y;
frenzy_echo_visual_direction = 0;
blood_hunger_frenzy_timer = 0;
frenzy_echo_is_resolving = false;

// Ability damage meter separates direct passive damage from regular attacks.
imp_damage_meter_window_time = 10;
imp_ability_damage_totals = array_create(DEMON_ABILITY.COUNT, 0);
imp_ability_damage_samples = array_create(DEMON_ABILITY.COUNT, []);

for (var _damage_sample_index = 0; _damage_sample_index < DEMON_ABILITY.COUNT; ++_damage_sample_index)
{
	imp_ability_damage_samples[_damage_sample_index] = [];
}

// Imp active abilities keep independent cooldown state for future unlocks.
demon_leap_cooldown = BALANCE_IMP_DEMON_LEAP_COOLDOWN * room_speed;
demon_leap_timer = 0;
demon_leap_retry_timer = 0;
demon_leap_refund_pending = false;
crimson_guillotine_cooldown = BALANCE_IMP_CRIMSON_GUILLOTINE_COOLDOWN * room_speed;
crimson_guillotine_timer = 0;
crimson_guillotine_retry_timer = 0;
crimson_guillotine_strike_timer = 0;
crimson_guillotine_strike_duration = 1;
crimson_guillotine_ascent_duration = 1;
crimson_guillotine_fall_duration = 1;
crimson_guillotine_start_x = x;
crimson_guillotine_start_y = y;
crimson_guillotine_apex_y = y;
crimson_guillotine_target = noone;
crimson_guillotine_repeat_count = 0;
bloody_clone_cooldown = BALANCE_IMP_BLOODY_CLONE_COOLDOWN * room_speed;
bloody_clone_timer = 0;
bloody_clone_retry_timer = 0;

// Demon Leap visuals keep recent dash segments for chained red strike trails.
leap_visual_timer = 0;
leap_visual_duration = BALANCE_IMP_DEMON_LEAP_ANIMATION_TIME * room_speed;
leap_visual_start_x = x;
leap_visual_start_y = y;
leap_visual_end_x = x;
leap_visual_end_y = y;
leap_visual_arc_height = BALANCE_IMP_DEMON_LEAP_ARC_HEIGHT;
leap_visual_segments = [];
demon_leap_is_active = false;
demon_leap_jump_count = 0;
demon_leap_max_jump_count = 0;
demon_leap_home_x = x;
demon_leap_home_y = y;
demon_leap_flight_timer = 0;
demon_leap_flight_duration = max(1, BALANCE_IMP_DEMON_LEAP_ANIMATION_TIME * room_speed);
demon_leap_flight_start_x = x;
demon_leap_flight_start_y = y;
demon_leap_flight_end_x = x;
demon_leap_flight_end_y = y;
demon_leap_target = noone;
demon_leap_is_returning = false;
demon_leap_hit_targets = [];

imp_active_ability_cancel_for_death = function()
{
	// Demon Leap stores an arced visual position, so land on the matching ground point before knockout.
	if (demon_leap_is_active)
	{
		var _flight_progress = 1 - clamp(demon_leap_flight_timer / max(1, demon_leap_flight_duration), 0, 1);
		x = lerp(demon_leap_flight_start_x, demon_leap_flight_end_x, _flight_progress);
		y = lerp(demon_leap_flight_start_y, demon_leap_flight_end_y, _flight_progress);
	}

	demon_leap_is_active = false;
	demon_leap_target = noone;
	demon_leap_is_returning = false;
	demon_leap_flight_timer = 0;
	demon_leap_hit_targets = [];
	crimson_guillotine_strike_timer = 0;
	crimson_guillotine_target = noone;
	crimson_guillotine_repeat_count = 0;
	visual_offset_is_ability_controlled = false;
	visual_attack_offset_x = 0;
	visual_attack_offset_y = 0;
	image_alpha = 1;
};

brute_blood_anvil_active_recharge = function(_recharge_share)
{
	var _recharge_amount = 0;

	if (cultist_active_ability_has(id, DEMON_ABILITY.IMP_DEMON_LEAP))
	{
		_recharge_amount = ability_cooldown_time_get(demon_leap_cooldown) * _recharge_share;
		demon_leap_timer = max(demon_leap_timer - _recharge_amount, 0);
	}

	if (cultist_active_ability_has(id, DEMON_ABILITY.IMP_CRIMSON_GUILLOTINE))
	{
		_recharge_amount = ability_cooldown_time_get(crimson_guillotine_cooldown) * _recharge_share;
		crimson_guillotine_timer = max(crimson_guillotine_timer - _recharge_amount, 0);
	}

	if (cultist_active_ability_has(id, DEMON_ABILITY.IMP_BLOODY_CLONE))
	{
		_recharge_amount = ability_cooldown_time_get(bloody_clone_cooldown) * _recharge_share;
		bloody_clone_timer = max(bloody_clone_timer - _recharge_amount, 0);
	}
};

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

imp_ability_level_get = function(_ability)
{
	return cultist_ability_level_get(id, _ability);
};

imp_ability_damage_meter_tracks = function(_ability)
{
	return _ability == DEMON_ABILITY.IMP_FRENZY_ECHO
		|| _ability == DEMON_ABILITY.IMP_BLOOD_BLADES
		|| _ability == DEMON_ABILITY.IMP_BLOOD_HUNGER;
};

imp_ability_damage_record = function(_ability, _damage_amount)
{
	if (!imp_ability_damage_meter_tracks(_ability) || _damage_amount <= 0)
	{
		return;
	}

	imp_ability_damage_totals[_ability] += _damage_amount;

	var _samples = imp_ability_damage_samples[_ability];
	array_push(_samples, {
		amount: _damage_amount,
		timer: imp_damage_meter_window_time * room_speed
	});
	imp_ability_damage_samples[_ability] = _samples;
};

imp_ability_damage_meter_update = function()
{
	var _tracked_abilities = [
		DEMON_ABILITY.IMP_FRENZY_ECHO,
		DEMON_ABILITY.IMP_BLOOD_BLADES,
		DEMON_ABILITY.IMP_BLOOD_HUNGER
	];

	for (var _ability_index = 0; _ability_index < array_length(_tracked_abilities); ++_ability_index)
	{
		var _ability = _tracked_abilities[_ability_index];
		var _samples = imp_ability_damage_samples[_ability];

		for (var _sample_index = array_length(_samples) - 1; _sample_index >= 0; --_sample_index)
		{
			var _sample = _samples[_sample_index];
			_sample.timer--;

			if (_sample.timer <= 0)
			{
				array_delete(_samples, _sample_index, 1);
			}
			else
			{
				_samples[_sample_index] = _sample;
			}
		}

		imp_ability_damage_samples[_ability] = _samples;
	}
};

imp_ability_damage_recent_get = function(_ability)
{
	if (!imp_ability_damage_meter_tracks(_ability))
	{
		return 0;
	}

	var _recent_damage = 0;
	var _samples = imp_ability_damage_samples[_ability];

	for (var _sample_index = 0; _sample_index < array_length(_samples); ++_sample_index)
	{
		_recent_damage += _samples[_sample_index].amount;
	}

	return _recent_damage;
};

imp_ability_damage_dps_get = function(_ability)
{
	return imp_ability_damage_recent_get(_ability) / max(1, imp_damage_meter_window_time);
};

imp_blood_hunger_level_get = function()
{
	return imp_ability_level_get(DEMON_ABILITY.IMP_BLOOD_HUNGER);
};

imp_blood_blades_level_get = function()
{
	return imp_ability_level_get(DEMON_ABILITY.IMP_BLOOD_BLADES);
};

imp_frenzy_echo_level_get = function()
{
	return imp_ability_level_get(DEMON_ABILITY.IMP_FRENZY_ECHO);
};

imp_blood_hunger_max_stack_count_get = function()
{
	if (imp_blood_hunger_level_get() >= 2)
	{
		return BALANCE_IMP_BLOOD_FRENZY_MAX_STACKS;
	}

	return 1;
};

imp_blood_frenzy_reload_multiplier_get = function()
{
	if (imp_blood_hunger_level_get() <= 0)
	{
		return 1;
	}

	var _stack_count = imp_blood_frenzy_stack_count_get();
	var _attack_speed_multiplier = 1 + (BALANCE_IMP_BLOOD_FRENZY_ATTACK_SPEED_BONUS * _stack_count);

	return 1 / _attack_speed_multiplier;
};

imp_blood_frenzy_move_multiplier_get = function()
{
	return 1;
};

imp_blood_frenzy_crit_bonus_get = function()
{
	return 0;
};

imp_blood_frenzy_stack_add = function()
{
	var _shortest_stack_index = 0;
	var _shortest_stack_timer = blood_frenzy_stack_timers[0];

	var _max_stack_count = imp_blood_hunger_max_stack_count_get();

	for (var _stack_index = 0; _stack_index < _max_stack_count; ++_stack_index)
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

	var _smoke_count = BALANCE_IMP_BLOOD_FRENZY_SMOKE_COUNT * max(1, imp_blood_frenzy_stack_count_get());

	for (var _particle_index = 0; _particle_index < _smoke_count; ++_particle_index)
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
	return 1;
};

imp_active_reload_multiplier_get = function()
{
	return 1;
};

imp_target_is_hidden_by_fog = function(_target)
{
	if (!instance_exists(_target))
	{
		return true;
	}

	if (!instance_exists(o_game_controller))
	{
		return false;
	}

	var _game_controller = instance_find(o_game_controller, 0);

	if (!variable_instance_exists(_game_controller, "world_position_is_revealed_by_fog"))
	{
		return false;
	}

	return !_game_controller.world_position_is_revealed_by_fog(_target.x, _target.y);
};

imp_target_is_in_array = function(_target, _target_array)
{
	for (var _target_index = 0; _target_index < array_length(_target_array); ++_target_index)
	{
		if (_target_array[_target_index] == _target)
		{
			return true;
		}
	}

	return false;
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

imp_find_farthest_enemy_except = function(_search_radius, _excluded_targets)
{
	var _best_target = noone;
	var _best_distance = -1;
	var _enemy_count = instance_number(o_enemy_units);

	for (var _enemy_index = 0; _enemy_index < _enemy_count; ++_enemy_index)
	{
		var _enemy = instance_find(o_enemy_units, _enemy_index);

		if (!target_can_be_attacked(_enemy)
			|| imp_target_is_hidden_by_fog(_enemy)
			|| imp_target_is_in_array(_enemy, _excluded_targets))
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

imp_find_nearest_enemy = function(_origin_x, _origin_y, _search_radius, _excluded_target)
{
	var _best_target = noone;
	var _best_distance = infinity;
	var _enemy_count = instance_number(o_enemy_units);

	for (var _enemy_index = 0; _enemy_index < _enemy_count; ++_enemy_index)
	{
		var _enemy = instance_find(o_enemy_units, _enemy_index);

		if (!target_can_be_attacked(_enemy) || _enemy == _excluded_target)
		{
			continue;
		}

		var _enemy_distance = point_distance(_origin_x, _origin_y, _enemy.x, _enemy.y);

		if (_enemy_distance <= _search_radius && _enemy_distance < _best_distance)
		{
			_best_target = _enemy;
			_best_distance = _enemy_distance;
		}
	}

	return _best_target;
};

imp_find_nearest_enemy_except_two = function(_origin_x, _origin_y, _search_radius, _excluded_target_a, _excluded_target_b)
{
	var _best_target = noone;
	var _best_distance = infinity;
	var _enemy_count = instance_number(o_enemy_units);

	for (var _enemy_index = 0; _enemy_index < _enemy_count; ++_enemy_index)
	{
		var _enemy = instance_find(o_enemy_units, _enemy_index);

		if (!target_can_be_attacked(_enemy)
			|| _enemy == _excluded_target_a
			|| _enemy == _excluded_target_b)
		{
			continue;
		}

		var _enemy_distance = point_distance(_origin_x, _origin_y, _enemy.x, _enemy.y);

		if (_enemy_distance <= _search_radius && _enemy_distance < _best_distance)
		{
			_best_target = _enemy;
			_best_distance = _enemy_distance;
		}
	}

	return _best_target;
};

imp_find_highest_hp_enemy = function(_search_radius)
{
	var _best_target = noone;
	var _best_hp = -1;
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

		if (_enemy.hp > _best_hp)
		{
			_best_target = _enemy;
			_best_hp = _enemy.hp;
		}
	}

	return _best_target;
};

imp_damage_enemies_in_radius = function(_origin_x, _origin_y, _radius, _damage_amount, _excluded_target, _source_ability = DEMON_ABILITY.NONE)
{
	var _enemy_count = instance_number(o_enemy_units);

	for (var _enemy_index = 0; _enemy_index < _enemy_count; ++_enemy_index)
	{
		var _enemy = instance_find(o_enemy_units, _enemy_index);

		if (!target_can_be_attacked(_enemy)
			|| _enemy == _excluded_target
			|| point_distance(_origin_x, _origin_y, _enemy.x, _enemy.y) > _radius)
		{
			continue;
		}

		imp_damage_target(_enemy, _damage_amount, false, _source_ability);
	}
};

imp_damage_enemies_in_sector = function(_origin_x, _origin_y, _direction, _radius, _sector_angle, _damage_amount, _main_target, _source_ability = DEMON_ABILITY.NONE)
{
	var _enemy_count = instance_number(o_enemy_units);

	for (var _enemy_index = 0; _enemy_index < _enemy_count; ++_enemy_index)
	{
		var _enemy = instance_find(o_enemy_units, _enemy_index);

		if (!target_can_be_attacked(_enemy)
			|| _enemy == _main_target
			|| point_distance(_origin_x, _origin_y, _enemy.x, _enemy.y) > _radius)
		{
			continue;
		}

		var _enemy_direction = point_direction(_origin_x, _origin_y, _enemy.x, _enemy.y);
		var _angle_delta = abs(angle_difference(_direction, _enemy_direction));

		if (_angle_delta <= _sector_angle * 0.5)
		{
			imp_damage_target(_enemy, _damage_amount, false, _source_ability);
		}
	}
};

imp_crimson_guillotine_aoe_radius_get = function(_guillotine_level)
{
	var _radius = BALANCE_IMP_CRIMSON_GUILLOTINE_AOE_RADIUS;

	if (_guillotine_level >= 3)
	{
		_radius *= BALANCE_IMP_CRIMSON_GUILLOTINE_AOE_RADIUS_LEVEL_3_MULTIPLIER;
	}

	return _radius;
};

imp_crimson_guillotine_aoe_damage_get = function(_guillotine_level)
{
	var _damage_multiplier = BALANCE_IMP_CRIMSON_GUILLOTINE_AOE_DAMAGE_MULTIPLIER;

	if (_guillotine_level >= 3)
	{
		_damage_multiplier *= BALANCE_IMP_CRIMSON_GUILLOTINE_AOE_LEVEL_3_MULTIPLIER;
	}

	return damage * _damage_multiplier;
};

imp_leap_visual_start = function(_start_x, _start_y, _end_x, _end_y, _arc_height, _draw_slash = true, _trail_duration_multiplier = 2.4)
{
	leap_visual_start_x = _start_x;
	leap_visual_start_y = _start_y;
	leap_visual_end_x = _end_x;
	leap_visual_end_y = _end_y;
	leap_visual_timer = leap_visual_duration;
	leap_visual_arc_height = _arc_height;
	visual_offset_is_ability_controlled = true;
	var _trail_duration = max(1, leap_visual_duration * _trail_duration_multiplier);

	array_push(
		leap_visual_segments,
		{
			start_x: _start_x,
			start_y: _start_y,
			end_x: _end_x,
			end_y: _end_y,
			timer: _trail_duration,
			duration: _trail_duration,
			arc_height: _arc_height,
			draw_slash: _draw_slash
		}
	);
};

imp_damage_target = function(_target, _damage_amount, _force_critical, _source_ability = DEMON_ABILITY.NONE)
{
	if (!target_can_be_attacked(_target) || !variable_instance_exists(_target, "hp"))
	{
		return false;
	}

	var _target_hp_before_hit = _target.hp;
	var _damage_with_modifiers = _damage_amount * unit_damage_modifier_get(_target, false);

	if (_force_critical)
	{
		_damage_with_modifiers *= unit_crit_damage_get();
	}

	var _final_damage = physical_damage_after_armor(_damage_with_modifiers, _target);
	var _applied_damage = 0;

	if (variable_instance_exists(_target, "unit_damage_receive"))
	{
		_applied_damage = _target.unit_damage_receive(_final_damage, unit_faction, _force_critical, true, id);
	}
	else
	{
		_applied_damage = min(_final_damage, _target.hp);
		_target.hp = max(_target.hp - _final_damage, 0);
		damage_popup_create(_target.x, _target.y, _applied_damage, _target.unit_faction, _force_critical);
	}

	imp_ability_damage_record(_source_ability, _applied_damage);

	var _target_was_killed = _target_hp_before_hit > 0 && _target.hp <= 0;
	unit_attack_landed(_target, _force_critical, _target_was_killed);

	return _target_was_killed;
};

imp_crimson_guillotine_aoe_apply = function(_origin_x, _origin_y, _radius, _damage_amount, _main_target, _guillotine_level)
{
	var _enemy_count = instance_number(o_enemy_units);
	var _has_killed_enemy = false;

	for (var _enemy_index = 0; _enemy_index < _enemy_count; ++_enemy_index)
	{
		var _enemy = instance_find(o_enemy_units, _enemy_index);

		if (!target_can_be_attacked(_enemy)
			|| _enemy == _main_target
			|| point_distance(_origin_x, _origin_y, _enemy.x, _enemy.y) > _radius)
		{
			continue;
		}

		// Apply splash damage first so level 2 stun happens after the hit.
		var _enemy_was_killed = imp_damage_target(_enemy, _damage_amount, false);
		_has_killed_enemy = _has_killed_enemy || _enemy_was_killed;

		if (!_enemy_was_killed && _guillotine_level >= 2 && variable_instance_exists(_enemy, "status_effect_apply"))
		{
			_enemy.status_effect_apply(STATUS_EFFECT.STUN, BALANCE_IMP_CRIMSON_GUILLOTINE_STUN_TIME, 0, 0, 1, unit_faction);
		}

		if (!_enemy_was_killed)
		{
			var _knockback_direction = point_direction(_origin_x, _origin_y, _enemy.x, _enemy.y);
			_enemy.x += lengthdir_x(BALANCE_IMP_CRIMSON_GUILLOTINE_KNOCKBACK_DISTANCE, _knockback_direction);
			_enemy.y += lengthdir_y(BALANCE_IMP_CRIMSON_GUILLOTINE_KNOCKBACK_DISTANCE, _knockback_direction);
		}
	}

	return _has_killed_enemy;
};

imp_world_position_is_on_camera = function(_world_x, _world_y)
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

imp_crimson_guillotine_fall_duration_get = function()
{
	var _fall_time = max(
		BALANCE_IMP_CRIMSON_GUILLOTINE_JUMP_TIME - BALANCE_IMP_CRIMSON_GUILLOTINE_ASCENT_TIME,
		0.01
	);
	var _fast_fall_time = _fall_time / BALANCE_IMP_CRIMSON_GUILLOTINE_FALL_SPEED_MULTIPLIER;

	return max(1, _fast_fall_time * room_speed);
};

imp_crimson_guillotine_flight_start = function(_target)
{
	crimson_guillotine_target = _target;
	crimson_guillotine_ascent_duration = max(1, BALANCE_IMP_CRIMSON_GUILLOTINE_ASCENT_TIME * room_speed);
	crimson_guillotine_fall_duration = imp_crimson_guillotine_fall_duration_get();
	crimson_guillotine_strike_duration = crimson_guillotine_ascent_duration + crimson_guillotine_fall_duration;
	crimson_guillotine_strike_timer = crimson_guillotine_strike_duration;
	crimson_guillotine_start_x = x;
	crimson_guillotine_start_y = y;
	crimson_guillotine_apex_y = y - BALANCE_IMP_CRIMSON_GUILLOTINE_FALL_HEIGHT;
	visual_offset_is_ability_controlled = true;
	face_world_x(_target.x);
};

imp_crimson_guillotine_landing_smoke_create = function(_origin_x, _origin_y, _radius)
{
	if (!variable_global_exists("particle_system_effects")
		|| !variable_global_exists("particle_type_brute_grave_slam_smoke")
		|| global.particle_system_effects == noone
		|| global.particle_type_brute_grave_slam_smoke == noone)
	{
		return;
	}

	var _smoke_count = BALANCE_IMP_CRIMSON_GUILLOTINE_LANDING_SMOKE_COUNT;

	for (var _smoke_index = 0; _smoke_index < _smoke_count; ++_smoke_index)
	{
		var _smoke_direction = random(360);
		var _smoke_distance = sqrt(random(1)) * _radius;
		var _smoke_x = _origin_x + lengthdir_x(_smoke_distance, _smoke_direction);
		var _smoke_y = _origin_y + lengthdir_y(_smoke_distance, _smoke_direction);

		part_particles_create(
			global.particle_system_effects,
			_smoke_x,
			_smoke_y,
			global.particle_type_brute_grave_slam_smoke,
			1
		);
	}
};

imp_crimson_guillotine_camera_shake_try = function(_origin_x, _origin_y)
{
	if (!imp_world_position_is_on_camera(_origin_x, _origin_y)
		|| !instance_exists(o_camera_controller))
	{
		return;
	}

	var _camera_controller = instance_find(o_camera_controller, 0);

	if (variable_instance_exists(_camera_controller, "camera_shake_start"))
	{
		_camera_controller.camera_shake_start(
			BALANCE_IMP_CRIMSON_GUILLOTINE_SHAKE_TIME,
			BALANCE_IMP_CRIMSON_GUILLOTINE_SHAKE_STRENGTH
		);
	}
};

imp_blood_blades_count_get = function()
{
	if (imp_blood_blades_level_get() >= 2)
	{
		return 6;
	}

	return 3;
};

imp_blood_blades_radius_get = function()
{
	if (imp_blood_blades_level_get() >= 2)
	{
		return BALANCE_IMP_BLOOD_BLADES_RADIUS_LEVEL_2;
	}

	return BALANCE_IMP_BLOOD_BLADES_RADIUS;
};

imp_blood_blades_update = function()
{
	var _blade_level = imp_blood_blades_level_get();

	if (_blade_level <= 0)
	{
		return;
	}

	var _speed_multiplier = 1;

	if (blood_blades_speed_bonus_timer > 0)
	{
		blood_blades_speed_bonus_timer--;
		_speed_multiplier += BALANCE_IMP_BLOOD_BLADES_SPEED_BONUS;
	}

	blood_blades_angle += BALANCE_IMP_BLOOD_BLADES_SPEED * _speed_multiplier;

	if (blood_blades_hit_timer > 0)
	{
		blood_blades_hit_timer--;
		return;
	}

	var _blade_count = imp_blood_blades_count_get();
	var _blade_radius = imp_blood_blades_radius_get();
	var _blade_hit_radius = BALANCE_IMP_BLOOD_BLADES_HIT_RADIUS;
	var _blade_damage = damage * BALANCE_IMP_BLOOD_BLADES_DAMAGE_SHARE;
	var _enemy_count = instance_number(o_enemy_units);

	for (var _enemy_index = 0; _enemy_index < _enemy_count; ++_enemy_index)
	{
		var _enemy = instance_find(o_enemy_units, _enemy_index);

		if (!target_can_be_attacked(_enemy))
		{
			continue;
		}

		for (var _blade_index = 0; _blade_index < _blade_count; ++_blade_index)
		{
			var _blade_direction = blood_blades_angle + ((360 / _blade_count) * _blade_index);
			var _blade_x = x + lengthdir_x(_blade_radius, _blade_direction);
			var _blade_y = y + lengthdir_y(_blade_radius, _blade_direction);

			if (point_distance(_blade_x, _blade_y, _enemy.x, _enemy.y) <= _blade_hit_radius)
			{
				var _enemy_was_killed = imp_damage_target(_enemy, _blade_damage, false, DEMON_ABILITY.IMP_BLOOD_BLADES);

				if (_blade_level >= 3)
				{
					var _shard_target_count = 2;
					var _previous_shard_target = noone;

					for (var _shard_index = 0; _shard_index < _shard_target_count; ++_shard_index)
					{
						var _shard_target = imp_find_nearest_enemy_except_two(
							_enemy.x,
							_enemy.y,
							BALANCE_IMP_BLOOD_BLADES_SHARD_RADIUS,
							_enemy,
							_previous_shard_target
						);

						if (instance_exists(_shard_target))
						{
							imp_damage_target(_shard_target, damage * BALANCE_IMP_BLOOD_BLADES_SHARD_DAMAGE_SHARE, false, DEMON_ABILITY.IMP_BLOOD_BLADES);
							_previous_shard_target = _shard_target;
						}
					}
				}

				if (_blade_level >= 4 && _enemy_was_killed)
				{
					blood_blades_speed_bonus_timer = BALANCE_IMP_BLOOD_BLADES_SPEED_BONUS_TIME * room_speed;
				}

				break;
			}
		}
	}

	blood_blades_hit_timer = BALANCE_IMP_BLOOD_BLADES_HIT_COOLDOWN * room_speed;
};

imp_blood_pool_add = function(_pool_x, _pool_y)
{
	array_push(
		blood_pool_data,
		{
			x: _pool_x,
			y: _pool_y,
			timer: BALANCE_IMP_DEMON_LEAP_BLOOD_POOL_TIME * room_speed,
			tick_timer: 0
		}
	);
};

imp_blood_pool_update = function()
{
	for (var _pool_index = array_length(blood_pool_data) - 1; _pool_index >= 0; --_pool_index)
	{
		var _pool = blood_pool_data[_pool_index];
		_pool.timer--;
		_pool.tick_timer--;

		if (_pool.tick_timer <= 0)
		{
			imp_damage_enemies_in_radius(
				_pool.x,
				_pool.y,
				BALANCE_IMP_DEMON_LEAP_BLOOD_POOL_RADIUS,
				damage * BALANCE_IMP_DEMON_LEAP_BLOOD_POOL_DAMAGE_SHARE,
				noone
			);
			_pool.tick_timer = BALANCE_IMP_DEMON_LEAP_BLOOD_POOL_TICK_TIME * room_speed;
		}

		if (_pool.timer <= 0)
		{
			array_delete(blood_pool_data, _pool_index, 1);
		}
		else
		{
			blood_pool_data[_pool_index] = _pool;
		}
	}
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

imp_demon_leap_jump_count_get = function(_leap_level)
{
	if (_leap_level >= 4)
	{
		return 7;
	}

	if (_leap_level >= 2)
	{
		return 5;
	}

	return 3;
};

imp_demon_leap_flight_start = function(_end_x, _end_y, _target, _is_returning)
{
	demon_leap_flight_duration = max(1, BALANCE_IMP_DEMON_LEAP_ANIMATION_TIME * room_speed);
	demon_leap_flight_timer = demon_leap_flight_duration;
	demon_leap_flight_start_x = x;
	demon_leap_flight_start_y = y;
	demon_leap_flight_end_x = _end_x;
	demon_leap_flight_end_y = _end_y;
	demon_leap_target = _target;
	demon_leap_is_returning = _is_returning;
	leap_visual_duration = demon_leap_flight_duration;
	imp_leap_visual_start(x, y, _end_x, _end_y, BALANCE_IMP_DEMON_LEAP_ARC_HEIGHT, !_is_returning);
	face_world_x(_end_x);
};

imp_demon_leap_next_flight_start = function()
{
	if (demon_leap_jump_count >= demon_leap_max_jump_count)
	{
		imp_demon_leap_flight_start(demon_leap_home_x, demon_leap_home_y, noone, true);
		return true;
	}

	var _target = imp_find_farthest_enemy_except(BALANCE_IMP_DEMON_LEAP_SEARCH_RADIUS, demon_leap_hit_targets);

	if (instance_exists(_target))
	{
		demon_leap_jump_count++;
		imp_demon_leap_flight_start(_target.x, _target.y, _target, false);
		return true;
	}

	if (demon_leap_jump_count > 0)
	{
		imp_demon_leap_flight_start(demon_leap_home_x, demon_leap_home_y, noone, true);
		return true;
	}

	demon_leap_is_active = false;
	visual_offset_is_ability_controlled = false;
	return false;
};

imp_demon_leap_update = function()
{
	if (!demon_leap_is_active)
	{
		return;
	}

	demon_leap_flight_timer--;
	var _flight_progress = 1 - clamp(demon_leap_flight_timer / max(1, demon_leap_flight_duration), 0, 1);
	var _arc_lift = sin(_flight_progress * pi) * BALANCE_IMP_DEMON_LEAP_ARC_HEIGHT;
	x = lerp(demon_leap_flight_start_x, demon_leap_flight_end_x, _flight_progress);
	y = lerp(demon_leap_flight_start_y, demon_leap_flight_end_y, _flight_progress) - _arc_lift;

	if (demon_leap_flight_timer > 0)
	{
		return;
	}

	x = demon_leap_flight_end_x;
	y = demon_leap_flight_end_y;

	if (demon_leap_is_returning)
	{
		demon_leap_is_active = false;
		demon_leap_target = noone;
		visual_offset_is_ability_controlled = false;
		return;
	}

	if (instance_exists(demon_leap_target))
	{
		imp_damage_target(demon_leap_target, damage, true);
		array_push(demon_leap_hit_targets, demon_leap_target);

		if (imp_ability_level_get(DEMON_ABILITY.IMP_DEMON_LEAP) >= 3)
		{
			imp_blood_pool_add(x, y);
		}
	}

	imp_demon_leap_next_flight_start();
};

imp_demon_leap_use = function()
{
	var _leap_level = max(1, imp_ability_level_get(DEMON_ABILITY.IMP_DEMON_LEAP));
	demon_leap_is_active = true;
	demon_leap_jump_count = 0;
	demon_leap_max_jump_count = imp_demon_leap_jump_count_get(_leap_level);
	demon_leap_home_x = x;
	demon_leap_home_y = y;
	demon_leap_hit_targets = [];

	if (!imp_demon_leap_next_flight_start())
	{
		return false;
	}

	ability_popup_create(x, y, DEMON_ABILITY.IMP_DEMON_LEAP);
	demon_active_ability_used_notify(DEMON_ABILITY.IMP_DEMON_LEAP);
	return true;
};

imp_crimson_guillotine_use = function()
{
	var _target = imp_find_highest_hp_enemy(BALANCE_IMP_CRIMSON_GUILLOTINE_SEARCH_RADIUS);

	if (!instance_exists(_target))
	{
		return false;
	}

	crimson_guillotine_repeat_count = 0;
	imp_crimson_guillotine_flight_start(_target);
	ability_popup_create(x, y, DEMON_ABILITY.IMP_CRIMSON_GUILLOTINE);
	demon_active_ability_used_notify(DEMON_ABILITY.IMP_CRIMSON_GUILLOTINE);

	return true;
};

imp_crimson_guillotine_strike = function()
{
	image_alpha = 1;

	if (!instance_exists(crimson_guillotine_target))
	{
		visual_offset_is_ability_controlled = false;
		return;
	}

	var _guillotine_level = max(1, imp_ability_level_get(DEMON_ABILITY.IMP_CRIMSON_GUILLOTINE));
	var _target = crimson_guillotine_target;
	var _aoe_radius = imp_crimson_guillotine_aoe_radius_get(_guillotine_level);
	var _aoe_damage = imp_crimson_guillotine_aoe_damage_get(_guillotine_level);
	x = _target.x;
	y = _target.y;
	face_world_x(_target.x);
	imp_crimson_guillotine_landing_smoke_create(x, y, _aoe_radius);
	imp_crimson_guillotine_camera_shake_try(x, y);

	var _target_was_killed = imp_damage_target(
		_target,
		damage * BALANCE_IMP_CRIMSON_GUILLOTINE_DAMAGE_MULTIPLIER,
		true
	);

	if (!_target_was_killed && _guillotine_level >= 2 && variable_instance_exists(_target, "status_effect_apply"))
	{
		_target.status_effect_apply(STATUS_EFFECT.STUN, BALANCE_IMP_CRIMSON_GUILLOTINE_STUN_TIME, 0, 0, 1, unit_faction);
	}

	var _aoe_killed_enemy = imp_crimson_guillotine_aoe_apply(
		x,
		y,
		_aoe_radius,
		_aoe_damage,
		_target,
		_guillotine_level
	);

	if (_guillotine_level >= 4
		&& (_target_was_killed || _aoe_killed_enemy)
		&& crimson_guillotine_repeat_count < 1)
	{
		var _repeat_target = imp_find_highest_hp_enemy(BALANCE_IMP_CRIMSON_GUILLOTINE_SEARCH_RADIUS);

		if (instance_exists(_repeat_target))
		{
			crimson_guillotine_repeat_count++;
			imp_crimson_guillotine_flight_start(_repeat_target);
		}
	}
};

imp_clone_stats_copy = function(_clone)
{
	var _clone_level = max(1, imp_ability_level_get(DEMON_ABILITY.IMP_BLOODY_CLONE));
	var _damage_multiplier = BALANCE_IMP_BLOODY_CLONE_DAMAGE_LEVEL_1;
	var _life_time = BALANCE_IMP_BLOODY_CLONE_LIFE_TIME;

	if (_clone_level >= 2)
	{
		_damage_multiplier = BALANCE_IMP_BLOODY_CLONE_DAMAGE_LEVEL_2;
		_life_time = BALANCE_IMP_BLOODY_CLONE_LIFE_TIME_LEVEL_2;
	}

	_clone.max_hp = max_hp;
	_clone.hp = hp;
	_clone.damage = damage * _damage_multiplier;
	_clone.magic_damage = magic_damage;
	_clone.armor = armor;
	_clone.magic_resistance = magic_resistance;
	_clone.crit_chance = crit_chance;
	_clone.crit_damage = crit_damage;
	_clone.reload_time = reload_time;
	_clone.attack_radius = attack_radius;
	_clone.move_speed = move_speed;
	_clone.bar_offset_y = bar_offset_y;
	_clone.life_timer = _life_time * room_speed;
	_clone.clone_max_life_timer = _clone.life_timer;
	_clone.explosion_enabled = _clone_level >= 3;
	_clone.explosion_damage = damage * BALANCE_IMP_BLOODY_CLONE_EXPLOSION_DAMAGE_SHARE;
	_clone.cultist_name = "Clone";
	_clone.clone_owner = id;
};

imp_bloody_clone_use = function()
{
	var _clone_count = 2;
	var _start_x = x;
	var _start_y = y;
	var _spawn_distance = BALANCE_IMP_BLOODY_CLONE_SPAWN_DISTANCE;

	for (var _clone_index = 0; _clone_index < _clone_count; ++_clone_index)
	{
		var _clone_direction = image_xscale >= 0 ? 180 : 0;

		if (_clone_count > 1)
		{
			_clone_direction = 90 + (_clone_index * 180);
		}

		var _clone_x = _start_x + lengthdir_x(_spawn_distance, _clone_direction);
		var _clone_y = _start_y + lengthdir_y(_spawn_distance, _clone_direction);
		var _clone = instance_create_layer(_clone_x, _clone_y, "Instances", o_imp_clone);

		if (instance_exists(_clone))
		{
			imp_clone_stats_copy(_clone);
		}
	}

	ability_popup_create(x, y, DEMON_ABILITY.IMP_BLOODY_CLONE);
	demon_active_ability_used_notify(DEMON_ABILITY.IMP_BLOODY_CLONE);

	return true;
};

imp_frenzy_echo_trigger = function(_source_target)
{
	var _echo_level = imp_frenzy_echo_level_get();

	if (_echo_level <= 0)
	{
		return;
	}

	var _trigger_attack_count = 4;

	if (_echo_level >= 2)
	{
		_trigger_attack_count = 3;
	}

	frenzy_echo_attack_count++;

	if (blood_hunger_frenzy_timer <= 0 && frenzy_echo_attack_count < _trigger_attack_count)
	{
		return;
	}

	frenzy_echo_attack_count = 0;

	var _target = imp_find_nearest_enemy(x, y, BALANCE_IMP_FRENZY_ECHO_SEARCH_RADIUS, noone);

	if (!instance_exists(_target))
	{
		return;
	}

	var _phantom_direction = point_direction(x, y, _target.x, _target.y);
	var _phantom_x = x + lengthdir_x(28, _phantom_direction + 180);
	var _phantom_y = y + lengthdir_y(28, _phantom_direction + 180);
	var _echo_damage = damage * BALANCE_IMP_FRENZY_ECHO_DAMAGE_SHARE;

	frenzy_echo_visual_x = _phantom_x;
	frenzy_echo_visual_y = _phantom_y;
	frenzy_echo_visual_direction = _phantom_direction;
	frenzy_echo_visual_timer = 12;

	frenzy_echo_is_resolving = true;
	imp_damage_target(_target, _echo_damage, false, DEMON_ABILITY.IMP_FRENZY_ECHO);

	if (_echo_level >= 3)
	{
		imp_damage_enemies_in_sector(
			_phantom_x,
			_phantom_y,
			_phantom_direction,
			BALANCE_IMP_FRENZY_ECHO_SECTOR_RADIUS,
			BALANCE_IMP_FRENZY_ECHO_SECTOR_ANGLE,
			_echo_damage,
			_target,
			DEMON_ABILITY.IMP_FRENZY_ECHO
		);
	}

	frenzy_echo_is_resolving = false;
};

unit_attack_landed = function(_target, _is_critical_hit = false, _target_was_killed = false)
{
	if (!instance_exists(_target))
	{
		return;
	}

	if (frenzy_echo_is_resolving)
	{
		return;
	}

	imp_frenzy_echo_trigger(_target);

	if (imp_blood_hunger_level_get() > 0 && _target_was_killed)
	{
		imp_blood_frenzy_stack_add();

		if (imp_blood_hunger_level_get() >= 3
			&& imp_blood_frenzy_stack_count_get() >= imp_blood_hunger_max_stack_count_get())
		{
			var _dash_target = imp_find_nearest_enemy(x, y, 250, _target);

			if (instance_exists(_dash_target))
			{
				var _start_x = x;
				var _start_y = y;
				x = _dash_target.x;
				y = _dash_target.y;
				imp_leap_visual_start(_start_x, _start_y, x, y, BALANCE_IMP_DEMON_LEAP_ARC_HEIGHT * 0.45);
			}
		}

		if (imp_blood_hunger_level_get() >= 4)
		{
			imp_damage_enemies_in_radius(_target.x, _target.y, 100, damage, _target, DEMON_ABILITY.IMP_BLOOD_HUNGER);
		}

		if (imp_frenzy_echo_level_get() >= 4)
		{
			blood_hunger_frenzy_timer = BALANCE_IMP_FRENZY_ECHO_FRENZY_TIME * room_speed;
		}
	}
};
