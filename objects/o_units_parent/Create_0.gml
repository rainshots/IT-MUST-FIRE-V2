// Base unit combat stats.
unit_faction = UNIT_FACTION.NOONE;
max_hp = 20 * BALANCE_COMBAT_VALUE_SCALE;
hp = max_hp;
damage = 1 * BALANCE_COMBAT_VALUE_SCALE;
magic_damage = 0;
reload_time = room_speed;
reload_timer = 0;
attack_radius = 32;
cannon_attack_radius = 200;
y_sort_enabled = true;

// Base unit movement and target search settings.
move_speed = 1.2;
target_detection_radius = BALANCE_UNIT_VISION_RADIUS;
vision_radius = BALANCE_UNIT_VISION_RADIUS;
cannon_guard_radius = 460;
target_instance = noone;
alert_target = noone;
alert_target_timer = 0;
alert_target_time = BALANCE_UNIT_ALERT_TARGET_TIME * room_speed;
forced_attack_target = noone;
forced_attack_target_timer = 0;
is_being_hooked = false;

// Rally command state is assigned by rally projectiles.
rally_group_id = 0;
rally_target_x = x;
rally_target_y = y;
rally_home_x = x;
rally_home_y = y;
rally_arrive_radius = BALANCE_PROJECTILE_RALLY_ARRIVE_RADIUS;
rally_is_active = false;
rally_is_returning = false;
rally_has_arrived = false;

// Cultist projectiles can deliver summoned combat units to the impact area.
cultist_projectile_deploy_assigned = false;
cultist_projectile_deploy_waiting = false;

// Regroup movement sends newly spawned friendly summons toward the cannon day area.
regroup_is_active = false;
regroup_target_x = x;
regroup_target_y = y;
regroup_arrive_radius = BALANCE_PROJECTILE_RALLY_ARRIVE_RADIUS;

// Optional guard behavior is used by spawned defenders.
owner_garnizon = noone;
guard_target = noone;
guard_radius = 220;
unit_can_attack_cannon = true;
is_night_attack_unit = false;

// Unit separation keeps units from stacking into one point.
separation_radius = 26;
separation_strength = 0.55;
separation_update_interval = 5;
separation_update_timer = irandom(separation_update_interval - 1);
separation_max_neighbors = 6;
separation_push_x = 0;
separation_push_y = 0;
combat_separation_multiplier = 0.45;
is_attacking_target = false;

// Attack feedback shows who hit whom for a short moment.
attack_feedback_time = 0.16 * room_speed;
attack_feedback_timer = 0;
attack_feedback_target = noone;
attack_feedback_target_x = x;
attack_feedback_target_y = y;
attack_feedback_line_width = 2;
attack_lunge_distance = 6;
attack_lunge_return_time_multiplier = 0.65;
visual_attack_offset_x = 0;
visual_attack_offset_y = 0;
visual_offset_is_ability_controlled = false;

// Optional combat modifiers used by cultist demon forms and debuffs.
armor = 100;
armor_debuff_multiplier = 1;
armor_debuff_timer = 0;
crit_chance = 0;
aoe_radius = 0;
next_attack_damage_multiplier = 1;
next_attack_radius_multiplier = 1;
demonic_infusion_timer = 0;
demonic_infusion_reload_multiplier = 1;
corpse_armor_bonus = 0;
corpse_armor_timer = 0;
corpse_armor_retaliation_damage = 0;
// Soul Chain links damage between several enemies while the timer is active.
soul_chain_id = noone;
soul_chain_timer = 0;
soul_chain_members = array_create(0);
soul_chain_damage_share = 0;
soul_chain_death_stun_time = 0;
soul_chain_death_damage = 0;
soul_chain_death_flash_timer = 0;
soul_chain_death_flash_time = 0.25 * room_speed;
is_being_dragged = false;
drag_drop_x = x;
drag_drop_y = y;
morning_respawn_pending = false;
corpse_visual_created = false;

// Optional summoned skeleton effects are configured by Warlock.
warlock_skeleton_explosion_enabled = false;
warlock_skeleton_explosion_damage = 0;
warlock_skeleton_respawn_chance = 0;
warlock_skeleton_dies_at_morning = false;

// Building work assignment lets valid friendly units stay at production buildings.
assigned_building = noone;
is_assigned_to_building = false;

// Cannon corpse hauling uses inert corpse snapshots reserved by the game controller.
carried_corpse = noone;
reserved_corpse_id = noone;
cannon_no_corpse_warning_active = false;
cannon_no_corpse_warning_text = "There are no available corpses";
cannon_no_corpse_warning_offset_y = 48;
cannon_no_corpse_warning_padding_x = 6;
cannon_no_corpse_warning_padding_y = 3;
cannon_no_corpse_warning_background_alpha = 0.82;
stun_timer = 0;
stun_duration = 0;
is_stunned = false;
stun_label_offset_y = 58;
stun_label_padding_x = 7;
stun_label_padding_y = 3;
stun_label_background_alpha = 0.82;
stun_bar_width = 44;
stun_bar_height = 4;
stun_bar_gap = 4;

// Status effects store one active slot per status type.
status_effect_timers = array_create(STATUS_EFFECT.COUNT, 0);
status_effect_durations = array_create(STATUS_EFFECT.COUNT, 0);
status_effect_strengths = array_create(STATUS_EFFECT.COUNT, 0);
status_effect_secondary_values = array_create(STATUS_EFFECT.COUNT, 0);
status_effect_tick_timers = array_create(STATUS_EFFECT.COUNT, 0);
status_effect_tick_intervals = array_create(STATUS_EFFECT.COUNT, room_speed);
status_effect_source_factions = array_create(STATUS_EFFECT.COUNT, UNIT_FACTION.NOONE);
status_effect_curse_extended = array_create(STATUS_EFFECT.COUNT, false);
status_effect_particle_timers = array_create(STATUS_EFFECT.COUNT, 0);

// Health bar visual settings.
bar_width = 34;
bar_height = 4;
bar_offset_y = 28;

// Walking sway tilts the sprite a little while the unit is moving.
is_walking = false;
walk_sway_angle = 4;
walk_sway_half_time = 0.16;
walk_sway_timer = random(walk_sway_half_time);
walk_sway_direction = choose(-1, 1);

face_world_x = function(_target_x)
{
	var _facing_dead_zone = 1;
	var _sprite_scale = abs(image_xscale);

	if (abs(_target_x - x) <= _facing_dead_zone)
	{
		return;
	}

	// Unit sprites need a mirrored xscale to face left in-game.
	if (_target_x < x)
	{
		image_xscale = -_sprite_scale;
	}
	else
	{
		image_xscale = _sprite_scale;
	}
};

target_can_be_attacked = function(_target)
{
	if (!instance_exists(_target))
	{
		return false;
	}

	// Carried units are temporarily outside combat targeting and damage.
	if (variable_instance_exists(_target, "is_being_dragged") && _target.is_being_dragged)
	{
		return false;
	}

	if (variable_instance_exists(_target, "hp") && _target.hp <= 0)
	{
		return false;
	}

	return true;
};

status_effect_is_negative = function(_status_type)
{
	return _status_type == STATUS_EFFECT.BLEED
		|| _status_type == STATUS_EFFECT.FEAR
		|| _status_type == STATUS_EFFECT.SOUL_MARK
		|| _status_type == STATUS_EFFECT.CURSE
		|| _status_type == STATUS_EFFECT.STUN;
};

status_effect_has = function(_status_type)
{
	return status_effect_timers[_status_type] > 0;
};

status_effect_apply = function(_status_type, _duration_seconds, _strength = 0, _secondary_value = 0, _tick_interval_seconds = 0, _source_faction = UNIT_FACTION.NOONE)
{
	var _duration_frames = max(1, _duration_seconds * room_speed);
	var _effect_strength = _strength;
	var _effect_secondary_value = _secondary_value;
	var _effect_tick_interval_seconds = _tick_interval_seconds;
	var _is_extended_by_curse = _status_type != STATUS_EFFECT.CURSE
		&& status_effect_is_negative(_status_type)
		&& status_effect_has(STATUS_EFFECT.CURSE);

	if (_status_type == STATUS_EFFECT.BLEED)
	{
		if (_effect_strength <= 0)
		{
			_effect_strength = BALANCE_STATUS_BLEED_DEFAULT_DAMAGE;
		}

		if (_effect_tick_interval_seconds <= 0)
		{
			_effect_tick_interval_seconds = BALANCE_STATUS_BLEED_DEFAULT_TICK_TIME;
		}
	}
	else if (_status_type == STATUS_EFFECT.FEAR)
	{
		if (_effect_strength <= 0)
		{
			_effect_strength = BALANCE_STATUS_FEAR_DEFAULT_MOVE_SLOW;
		}

		if (_effect_secondary_value <= 0)
		{
			_effect_secondary_value = BALANCE_STATUS_FEAR_DEFAULT_ATTACK_SLOW;
		}
	}
	else if (_status_type == STATUS_EFFECT.SOUL_MARK && _effect_strength <= 0)
	{
		_effect_strength = BALANCE_STATUS_SOUL_MARK_DEFAULT_CHANCE;
	}

	if (_is_extended_by_curse)
	{
		_duration_frames *= BALANCE_STATUS_CURSE_NEGATIVE_DURATION_MULTIPLIER;
		status_effect_curse_extended[_status_type] = true;
	}

	// Re-applying the same status keeps the strongest parameters and longest remaining duration.
	status_effect_timers[_status_type] = max(status_effect_timers[_status_type], _duration_frames);
	status_effect_durations[_status_type] = max(status_effect_durations[_status_type], _duration_frames);
	status_effect_strengths[_status_type] = max(status_effect_strengths[_status_type], _effect_strength);
	status_effect_secondary_values[_status_type] = max(status_effect_secondary_values[_status_type], _effect_secondary_value);
	status_effect_source_factions[_status_type] = _source_faction;

	if (_effect_tick_interval_seconds > 0)
	{
		var _tick_interval_frames = max(1, _effect_tick_interval_seconds * room_speed);
		status_effect_tick_intervals[_status_type] = min(status_effect_tick_intervals[_status_type], _tick_interval_frames);

		if (status_effect_tick_timers[_status_type] <= 0)
		{
			status_effect_tick_timers[_status_type] = status_effect_tick_intervals[_status_type];
		}
		else
		{
			status_effect_tick_timers[_status_type] = min(
				status_effect_tick_timers[_status_type],
				status_effect_tick_intervals[_status_type]
			);
		}
	}

	if (_status_type == STATUS_EFFECT.STUN)
	{
		stun_timer = status_effect_timers[STATUS_EFFECT.STUN];
		stun_duration = status_effect_durations[STATUS_EFFECT.STUN];
		is_stunned = true;
		target_instance = noone;
		is_attacking_target = false;
		is_walking = false;
		visual_attack_offset_x = 0;
		visual_attack_offset_y = 0;
	}
	else if (_status_type == STATUS_EFFECT.CURSE)
	{
		for (var _affected_status_type = 0; _affected_status_type < STATUS_EFFECT.COUNT; ++_affected_status_type)
		{
			var _should_extend_status = _affected_status_type != STATUS_EFFECT.CURSE
				&& status_effect_is_negative(_affected_status_type)
				&& status_effect_timers[_affected_status_type] > 0
				&& !status_effect_curse_extended[_affected_status_type];

			if (_should_extend_status)
			{
				status_effect_timers[_affected_status_type] *= BALANCE_STATUS_CURSE_NEGATIVE_DURATION_MULTIPLIER;
				status_effect_durations[_affected_status_type] *= BALANCE_STATUS_CURSE_NEGATIVE_DURATION_MULTIPLIER;
				status_effect_curse_extended[_affected_status_type] = true;
			}
		}
	}
};

status_effect_clear = function(_status_type)
{
	status_effect_timers[_status_type] = 0;
	status_effect_durations[_status_type] = 0;
	status_effect_strengths[_status_type] = 0;
	status_effect_secondary_values[_status_type] = 0;
	status_effect_tick_timers[_status_type] = 0;
	status_effect_tick_intervals[_status_type] = room_speed;
	status_effect_source_factions[_status_type] = UNIT_FACTION.NOONE;
	status_effect_curse_extended[_status_type] = false;
};

status_effect_movement_multiplier = function()
{
	if (!status_effect_has(STATUS_EFFECT.FEAR))
	{
		return 1;
	}

	var _slow_amount = clamp(status_effect_strengths[STATUS_EFFECT.FEAR], 0, 0.95);
	return 1 - _slow_amount;
};

status_effect_attack_reload_multiplier = function()
{
	if (!status_effect_has(STATUS_EFFECT.FEAR))
	{
		return 1;
	}

	var _slow_amount = clamp(status_effect_secondary_values[STATUS_EFFECT.FEAR], 0, 0.95);
	return 1 / max(0.05, 1 - _slow_amount);
};

demonic_infusion_reload_multiplier_get = function()
{
	if (demonic_infusion_timer > 0)
	{
		return demonic_infusion_reload_multiplier;
	}

	return 1;
};

unit_attack_reload_multiplier_get = function()
{
	var _reload_multiplier = status_effect_attack_reload_multiplier()
		* demonic_infusion_reload_multiplier_get();

	if (variable_instance_exists(id, "imp_blood_frenzy_reload_multiplier_get"))
	{
		_reload_multiplier *= imp_blood_frenzy_reload_multiplier_get();
	}

	if (variable_instance_exists(id, "imp_active_reload_multiplier_get"))
	{
		_reload_multiplier *= imp_active_reload_multiplier_get();
	}

	return _reload_multiplier;
};

ability_cooldown_time_get = function(_base_cooldown)
{
	return max(_base_cooldown / max(abilities_cd_spd, 0.01), 1);
};

unit_move_speed_multiplier_get = function()
{
	var _move_multiplier = status_effect_movement_multiplier();

	if (variable_instance_exists(id, "imp_blood_frenzy_move_multiplier_get"))
	{
		_move_multiplier *= imp_blood_frenzy_move_multiplier_get();
	}

	if (unit_faction == UNIT_FACTION.ENEMY && unit_is_hidden_by_fog())
	{
		_move_multiplier *= BALANCE_ENEMY_HIDDEN_MOVE_SPEED_MULTIPLIER;
	}

	return _move_multiplier;
};

unit_is_hidden_by_fog = function()
{
	if (!global.fog_of_war_visible || !instance_exists(o_fog_of_war))
	{
		return false;
	}

	var _fog_of_war = instance_find(o_fog_of_war, 0);

	if (!variable_instance_exists(_fog_of_war, "fog_grid"))
	{
		return false;
	}

	var _cell_x = floor(x / _fog_of_war.cell_size);
	var _cell_y = floor(y / _fog_of_war.cell_size);
	var _is_inside_fog_grid = _cell_x >= 0
		&& _cell_x < _fog_of_war.grid_width
		&& _cell_y >= 0
		&& _cell_y < _fog_of_war.grid_height;

	if (!_is_inside_fog_grid)
	{
		return false;
	}

	var _fog_alpha = ds_grid_get(_fog_of_war.fog_grid, _cell_x, _cell_y);
	return _fog_alpha >= _fog_of_war.hidden_alpha;
};

unit_crit_chance_get = function()
{
	var _crit_chance = crit_chance;

	if (variable_instance_exists(id, "imp_blood_frenzy_crit_bonus_get"))
	{
		_crit_chance += imp_blood_frenzy_crit_bonus_get();
	}

	return clamp(_crit_chance, 0, 1);
};

effective_attack_speed_get = function()
{
	var _effective_reload_time = reload_time
		* unit_attack_reload_multiplier_get();

	return room_speed / max(_effective_reload_time, 1);
};

status_effect_magic_damage_multiplier = function()
{
	if (status_effect_has(STATUS_EFFECT.CURSE))
	{
		return BALANCE_STATUS_CURSE_MAGIC_DAMAGE_MULTIPLIER;
	}

	return 1;
};

status_effect_particle_type_get = function(_status_type)
{
	if (!variable_global_exists("particle_system_effects") || global.particle_system_effects == noone)
	{
		return noone;
	}

	if (_status_type == STATUS_EFFECT.BLEED && variable_global_exists("particle_type_status_bleed"))
	{
		return global.particle_type_status_bleed;
	}
	else if (_status_type == STATUS_EFFECT.FEAR && variable_global_exists("particle_type_status_web_red"))
	{
		return global.particle_type_status_web_red;
	}
	else if (_status_type == STATUS_EFFECT.SOUL_MARK && variable_global_exists("particle_type_status_soul_mark"))
	{
		return global.particle_type_status_soul_mark;
	}
	else if (_status_type == STATUS_EFFECT.CURSE && variable_global_exists("particle_type_status_curse"))
	{
		return global.particle_type_status_curse;
	}
	else if (_status_type == STATUS_EFFECT.STUN && variable_global_exists("particle_type_status_stun"))
	{
		return global.particle_type_status_stun;
	}

	return noone;
};

unit_body_particle_position_get = function()
{
	var _particle_x = random_range(bbox_left, bbox_right);
	var _particle_y = random_range(bbox_top, bbox_bottom);

	if (_particle_x == 0 && _particle_y == 0)
	{
		_particle_x = x;
		_particle_y = y - bar_offset_y;
	}

	return [_particle_x, _particle_y];
};

status_effect_particles_update = function()
{
	// Active statuses emit light sprite particles across the unit body.
	for (var _status_type = 0; _status_type < STATUS_EFFECT.COUNT; ++_status_type)
	{
		if (!status_effect_has(_status_type))
		{
			status_effect_particle_timers[_status_type] = 0;
			continue;
		}

		status_effect_particle_timers[_status_type]--;

		if (status_effect_particle_timers[_status_type] > 0)
		{
			continue;
		}

		var _particle_type = status_effect_particle_type_get(_status_type);

		if (_particle_type != noone)
		{
			var _particle_position = unit_body_particle_position_get();
			part_particles_create(global.particle_system_effects, _particle_position[0], _particle_position[1], _particle_type, BALANCE_STATUS_PARTICLE_COUNT);
		}

		status_effect_particle_timers[_status_type] = BALANCE_STATUS_PARTICLE_INTERVAL;
	}
};

status_effect_bleed_tick = function()
{
	if (!status_effect_has(STATUS_EFFECT.BLEED))
	{
		return;
	}

	status_effect_tick_timers[STATUS_EFFECT.BLEED]--;

	if (status_effect_tick_timers[STATUS_EFFECT.BLEED] > 0)
	{
		return;
	}

	var _raw_bleed_damage = status_effect_strengths[STATUS_EFFECT.BLEED];

	if (_raw_bleed_damage > 0)
	{
		var _bleed_damage = physical_damage_after_armor(_raw_bleed_damage, id);
		unit_damage_receive(_bleed_damage, status_effect_source_factions[STATUS_EFFECT.BLEED]);
	}

	status_effect_tick_timers[STATUS_EFFECT.BLEED] = status_effect_tick_intervals[STATUS_EFFECT.BLEED];
};

status_effect_update = function()
{
	status_effect_particles_update();
	status_effect_bleed_tick();

	for (var _status_type = 0; _status_type < STATUS_EFFECT.COUNT; ++_status_type)
	{
		if (status_effect_timers[_status_type] <= 0)
		{
			continue;
		}

		status_effect_timers[_status_type]--;

		if (status_effect_timers[_status_type] <= 0)
		{
			status_effect_clear(_status_type);
		}
	}

	stun_timer = status_effect_timers[STATUS_EFFECT.STUN];
	stun_duration = status_effect_durations[STATUS_EFFECT.STUN];
	is_stunned = status_effect_has(STATUS_EFFECT.STUN);
};

status_effect_death_rewards_try = function()
{
	if (unit_faction != UNIT_FACTION.ENEMY || !status_effect_has(STATUS_EFFECT.SOUL_MARK))
	{
		return;
	}

	var _soul_chance = clamp(status_effect_strengths[STATUS_EFFECT.SOUL_MARK], 0, 1);

	if (random(1) >= _soul_chance)
	{
		return;
	}

	var _soul_reward = 1;
	global.resources[RESOURCES.SOULS] += _soul_reward;
	resource_popup_create(x, y - bar_offset_y, RESOURCES.SOULS, _soul_reward);
};

soul_chain_clear = function()
{
	soul_chain_id = noone;
	soul_chain_timer = 0;
	soul_chain_members = array_create(0);
	soul_chain_damage_share = 0;
	soul_chain_death_stun_time = 0;
	soul_chain_death_damage = 0;
};

soul_chain_apply = function(_chain_id, _members, _duration_seconds, _damage_share, _death_stun_time = 0, _death_damage = 0)
{
	soul_chain_id = _chain_id;
	soul_chain_timer = max(1, _duration_seconds * room_speed);
	soul_chain_members = _members;
	soul_chain_damage_share = clamp(_damage_share, 0, 1);
	soul_chain_death_stun_time = max(0, _death_stun_time);
	soul_chain_death_damage = max(0, _death_damage);
};

soul_chain_update = function()
{
	if (soul_chain_timer <= 0)
	{
		return;
	}

	soul_chain_timer--;

	if (soul_chain_timer <= 0)
	{
		soul_chain_clear();
	}
};

soul_chain_death_effect_apply = function()
{
	if (soul_chain_id == noone || array_length(soul_chain_members) <= 1)
	{
		return;
	}

	for (var _member_index = 0; _member_index < array_length(soul_chain_members); ++_member_index)
	{
		var _member = soul_chain_members[_member_index];

		if (target_can_be_attacked(_member)
			&& _member != id
			&& variable_instance_exists(_member, "soul_chain_id")
			&& _member.soul_chain_id == soul_chain_id)
		{
			if (soul_chain_death_stun_time > 0 && variable_instance_exists(_member, "stun_apply"))
			{
				_member.stun_apply(soul_chain_death_stun_time);
			}

			if (soul_chain_death_damage > 0 && variable_instance_exists(_member, "unit_damage_receive"))
			{
				_member.unit_damage_receive(soul_chain_death_damage, UNIT_FACTION.FRIENDLY, false, false);
			}

			if (variable_instance_exists(_member, "soul_chain_death_flash_timer"))
			{
				_member.soul_chain_death_flash_timer = _member.soul_chain_death_flash_time;
			}
		}
	}
};

unit_damage_receive = function(_damage_amount, _source_faction = UNIT_FACTION.NOONE, _is_critical = false, _can_trigger_soul_chain = true)
{
	if (hp <= 0 || _damage_amount <= 0)
	{
		return 0;
	}

	if (_is_critical)
	{
		_damage_amount *= brute_rotten_aura_critical_damage_multiplier_get();
	}

	var _applied_damage = min(_damage_amount, hp);
	hp = max(hp - _damage_amount, 0);
	damage_popup_create(x, y, _applied_damage, unit_faction, _is_critical);

	if (!_can_trigger_soul_chain
		|| soul_chain_id == noone
		|| soul_chain_damage_share <= 0
		|| array_length(soul_chain_members) <= 1)
	{
		return _applied_damage;
	}

	var _chain_damage = _applied_damage * soul_chain_damage_share;

	for (var _member_index = 0; _member_index < array_length(soul_chain_members); ++_member_index)
	{
		var _member = soul_chain_members[_member_index];

		if (target_can_be_attacked(_member)
			&& _member != id
			&& variable_instance_exists(_member, "soul_chain_id")
			&& _member.soul_chain_id == soul_chain_id)
		{
			if (variable_instance_exists(_member, "unit_damage_receive"))
			{
				_member.unit_damage_receive(_chain_damage, _source_faction, false, false);
			}
			else if (variable_instance_exists(_member, "hp"))
			{
				_member.hp = max(_member.hp - _chain_damage, 0);
				damage_popup_create(_member.x, _member.y, _chain_damage, _member.unit_faction);
			}
		}
	}

	return _applied_damage;
};

brute_rotten_aura_critical_damage_multiplier_get = function()
{
	if (unit_faction != UNIT_FACTION.ENEMY
		|| !instance_exists(o_brute))
	{
		return 1;
	}

	var _brute_count = instance_number(o_brute);

	for (var _brute_index = 0; _brute_index < _brute_count; ++_brute_index)
	{
		var _brute = instance_find(o_brute, _brute_index);

		if (instance_exists(_brute)
			&& variable_instance_exists(_brute, "hp")
			&& variable_instance_exists(_brute, "has_brute_rotten_aura")
			&& variable_instance_exists(_brute, "brute_ability_level_get")
			&& _brute.hp > 0
			&& _brute.has_brute_rotten_aura
			&& _brute.brute_ability_level_get(DEMON_ABILITY.BRUTE_ROTTEN_AURA) >= 4
			&& point_distance(x, y, _brute.x, _brute.y) <= _brute.brute_rotten_aura_radius_get())
		{
			return BALANCE_BRUTE_ROTTEN_AURA_CRITICAL_DAMAGE_MULTIPLIER;
		}
	}

	return 1;
};

demon_active_ability_used_notify = function(_ability)
{
	if (!is_demon_form_unit() || !instance_exists(o_brute))
	{
		return;
	}

	var _brute_count = instance_number(o_brute);

	for (var _brute_index = 0; _brute_index < _brute_count; ++_brute_index)
	{
		var _brute = instance_find(o_brute, _brute_index);

		if (instance_exists(_brute)
			&& _brute != id
			&& variable_instance_exists(_brute, "brute_blood_anvil_trigger"))
		{
			_brute.brute_blood_anvil_trigger(id);
		}
	}
};

warlock_soul_engine_enemy_death_notify = function()
{
	if (unit_faction != UNIT_FACTION.ENEMY || !instance_exists(o_warlock))
	{
		return;
	}

	var _warlock_count = instance_number(o_warlock);

	for (var _warlock_index = 0; _warlock_index < _warlock_count; ++_warlock_index)
	{
		var _warlock = instance_find(o_warlock, _warlock_index);

		if (instance_exists(_warlock) && variable_instance_exists(_warlock, "warlock_soul_engine_enemy_death_notify"))
		{
			_warlock.warlock_soul_engine_enemy_death_notify(x, y);
		}
	}
};

warlock_skeleton_death_effect_apply = function()
{
	if (object_index != o_skeleton)
	{
		return;
	}

	if (warlock_skeleton_explosion_enabled && warlock_skeleton_explosion_damage > 0)
	{
		var _enemy_list = ds_list_create();
		var _enemy_count = collision_circle_list(
			x,
			y,
			BALANCE_WARLOCK_SUMMON_SKELETONS_EXPLOSION_RADIUS,
			o_enemy_units,
			false,
			true,
			_enemy_list,
			false
		);

		for (var _enemy_index = 0; _enemy_index < _enemy_count; ++_enemy_index)
		{
			var _enemy = _enemy_list[| _enemy_index];

			if (target_can_be_attacked(_enemy) && variable_instance_exists(_enemy, "unit_damage_receive"))
			{
				_enemy.unit_damage_receive(warlock_skeleton_explosion_damage, unit_faction);
			}
		}

		ds_list_destroy(_enemy_list);
	}

	if (warlock_skeleton_respawn_chance > 0 && random(1) < warlock_skeleton_respawn_chance)
	{
		var _spawn_direction = random(360);
		var _spawn_distance = BALANCE_WARLOCK_SUMMON_SKELETONS_SPAWN_DISTANCE * 0.5;
		var _skeleton = instance_create_layer(
			x + lengthdir_x(_spawn_distance, _spawn_direction),
			y + lengthdir_y(_spawn_distance, _spawn_direction),
			"Instances",
			o_skeleton
		);

		if (instance_exists(_skeleton))
		{
			_skeleton.max_hp = max_hp;
			_skeleton.hp = _skeleton.max_hp;
			_skeleton.damage = damage;
			_skeleton.warlock_skeleton_explosion_enabled = warlock_skeleton_explosion_enabled;
			_skeleton.warlock_skeleton_explosion_damage = warlock_skeleton_explosion_damage;
			_skeleton.warlock_skeleton_respawn_chance = warlock_skeleton_respawn_chance;
			_skeleton.warlock_skeleton_dies_at_morning = warlock_skeleton_dies_at_morning;
		}
	}
};

unit_corpse_snapshot_create = function()
{
	if (unit_faction == UNIT_FACTION.ENEMY && random(1) >= BALANCE_ENEMY_CORPSE_DROP_CHANCE)
	{
		corpse_visual_created = true;
		return;
	}

	if (!corpse_visual_created && instance_exists(o_game_controller))
	{
		var _game_controller = instance_find(o_game_controller, 0);

		if (variable_instance_exists(_game_controller, "corpse_snapshot_add"))
		{
			_game_controller.corpse_snapshot_add(id);
			corpse_visual_created = true;
		}
	}
};

unit_death_process = function()
{
	if (instance_exists(o_game_controller))
	{
		var _game_controller = instance_find(o_game_controller, 0);

		if (variable_instance_exists(_game_controller, "cannon_corpse_worker_drop"))
		{
			_game_controller.cannon_corpse_worker_drop(id);
		}
	}

	unit_corpse_snapshot_create();

	if (is_demon_form_unit() || object_index == o_cultist)
	{
		if (!morning_respawn_pending)
		{
			soul_chain_death_effect_apply();
			morning_respawn_pending = true;
			hp = 0;
			visible = false;
			is_being_dragged = false;
			target_instance = noone;
			alert_target = noone;
			forced_attack_target = noone;
			is_attacking_target = false;
			is_walking = false;
			visual_attack_offset_x = 0;
			visual_attack_offset_y = 0;
		}

		return;
	}

	soul_chain_death_effect_apply();
	warlock_soul_engine_enemy_death_notify();
	warlock_skeleton_death_effect_apply();
	status_effect_death_rewards_try();
	meat_drop_try();
	instance_destroy();
};

stun_apply = function(_duration_seconds)
{
	status_effect_apply(
		STATUS_EFFECT.STUN,
		_duration_seconds,
		1,
		0,
		0,
		UNIT_FACTION.NOONE
	);
};

meat_drop_try = function()
{
	if (object_index == o_skeleton)
	{
		return;
	}

	var _drop_chance = BALANCE_MEAT_DROP_CHANCE;

	if (random(1) >= clamp(_drop_chance, 0, 1))
	{
		return;
	}

	instance_create_layer(x, y, "Instances", o_meat);
};

is_demon_form_unit = function()
{
	return variable_instance_exists(id, "demon_type")
		&& demon_type != DEMON_TYPE.NONE
		&& object_index != o_cultist;
};

is_summoned_unit = function()
{
	return variable_instance_exists(id, "summon_nights_remaining");
};

is_wall_blocked_friendly_unit = function()
{
	return is_demon_form_unit()
		|| (is_summoned_unit() && object_index != o_goblin && global.day_phase == DAY_PHASE.NIGHT);
};

is_blocked_by_cannon_wall = function()
{
	return (unit_faction == UNIT_FACTION.ENEMY && global.day_phase == DAY_PHASE.NIGHT)
		|| is_wall_blocked_friendly_unit();
};

cannon_wall_is_active = function()
{
	return instance_exists(o_cannon);
};

clamp_outside_cannon_wall = function()
{
	if (!cannon_wall_is_active() || !is_blocked_by_cannon_wall())
	{
		return;
	}

	var _cannon = instance_find(o_cannon, 0);
	var _distance_to_cannon = point_distance(x, y, _cannon.x, _cannon.y);

	if (_distance_to_cannon >= BALANCE_CANNON_WALL_RADIUS)
	{
		return;
	}

	var _direction_from_cannon = point_direction(_cannon.x, _cannon.y, x, y);

	if (_distance_to_cannon <= 0)
	{
		_direction_from_cannon = 0;
	}

	x = _cannon.x + lengthdir_x(BALANCE_CANNON_WALL_RADIUS, _direction_from_cannon);
	y = _cannon.y + lengthdir_y(BALANCE_CANNON_WALL_RADIUS, _direction_from_cannon);
};

target_is_inside_cannon_wall = function(_target)
{
	if (!cannon_wall_is_active() || !instance_exists(_target))
	{
		return false;
	}

	var _cannon = instance_find(o_cannon, 0);
	return point_distance(_target.x, _target.y, _cannon.x, _cannon.y) < BALANCE_CANNON_WALL_RADIUS;
};

unit_special_behavior_update = function()
{
	return false;
};

unit_attack_landed = function(_target, _is_critical_hit = false, _target_was_killed = false)
{
};

unit_damage_modifier_get = function(_target, _is_magic_damage)
{
	return 1;
};

find_nearest_target = function(_object_index, _max_distance)
{
	var _nearest_target = noone;
	var _nearest_distance = _max_distance;
	var _target_count = instance_number(_object_index);

	// Pick the closest valid target and ignore units currently being carried.
	for (var _target_index = 0; _target_index < _target_count; ++_target_index)
	{
		var _target = instance_find(_object_index, _target_index);

		if (!target_can_be_attacked(_target))
		{
			continue;
		}

		if (unit_faction == UNIT_FACTION.ENEMY
			&& _object_index == o_friendly_units
			&& global.day_phase == DAY_PHASE.NIGHT
			&& target_is_inside_cannon_wall(_target))
		{
			continue;
		}

		var _target_distance = point_distance(x, y, _target.x, _target.y);

		if (_target_distance <= _nearest_distance)
		{
			_nearest_target = _target;
			_nearest_distance = _target_distance;
		}
	}

	return _nearest_target;
};

find_nearest_cannon_attacker = function()
{
	if (!instance_exists(o_cannon))
	{
		return noone;
	}

	var _cannon = instance_find(o_cannon, 0);
	var _nearest_attacker = noone;
	var _nearest_distance = infinity;
	var _enemy_count = instance_number(o_enemy_units);

	// Pick the closest enemy that is actively attacking the cannon wall.
	for (var _enemy_index = 0; _enemy_index < _enemy_count; ++_enemy_index)
	{
		var _enemy = instance_find(o_enemy_units, _enemy_index);

		if (!target_can_be_attacked(_enemy)
			|| !variable_instance_exists(_enemy, "target_instance")
			|| !variable_instance_exists(_enemy, "is_attacking_target")
			|| !_enemy.is_attacking_target
			|| _enemy.target_instance != _cannon)
		{
			continue;
		}

		var _enemy_distance = point_distance(x, y, _enemy.x, _enemy.y);

		if (_enemy_distance < _nearest_distance)
		{
			_nearest_attacker = _enemy;
			_nearest_distance = _enemy_distance;
		}
	}

	return _nearest_attacker;
};

find_nearest_enemy_object = function(_max_distance)
{
	var _nearest_target = noone;
	var _nearest_distance = _max_distance;

	// Holy towers are hostile structures for friendly units.
	if (instance_exists(o_holy_tower))
	{
		var _holy_tower_count = instance_number(o_holy_tower);

		for (var _tower_index = 0; _tower_index < _holy_tower_count; ++_tower_index)
		{
			var _tower = instance_find(o_holy_tower, _tower_index);

			if (instance_exists(_tower) && _tower.hp > 0)
			{
				var _tower_distance = point_distance(x, y, _tower.x, _tower.y);

				if (_tower_distance <= _nearest_distance)
				{
					_nearest_distance = _tower_distance;
					_nearest_target = _tower;
				}
			}
		}
	}

	// Garnizons are hostile structures for friendly units.
	if (instance_exists(o_garnizon))
	{
		var _garnizon_count = instance_number(o_garnizon);

		for (var _garnizon_index = 0; _garnizon_index < _garnizon_count; ++_garnizon_index)
		{
			var _garnizon = instance_find(o_garnizon, _garnizon_index);

			if (instance_exists(_garnizon) && _garnizon.hp > 0)
			{
				var _garnizon_distance = point_distance(x, y, _garnizon.x, _garnizon.y);

				if (_garnizon_distance <= _nearest_distance)
				{
					_nearest_distance = _garnizon_distance;
					_nearest_target = _garnizon;
				}
			}
		}
	}

	return _nearest_target;
};

find_nearest_visible_cultist = function()
{
	var _nearest_cultist = noone;
	var _nearest_distance = infinity;
	var _cultist_count = array_length(global.cultists);

	for (var _cultist_index = 0; _cultist_index < _cultist_count; ++_cultist_index)
	{
		var _cultist = global.cultists[_cultist_index];

		if (!instance_exists(_cultist)
			|| _cultist == id
			|| !_cultist.visible
			|| !variable_instance_exists(_cultist, "hp")
			|| _cultist.hp <= 0)
		{
			continue;
		}

		var _cultist_distance = point_distance(x, y, _cultist.x, _cultist.y);

		if (_cultist_distance < _nearest_distance)
		{
			_nearest_cultist = _cultist;
			_nearest_distance = _cultist_distance;
		}
	}

	return _nearest_cultist;
};

move_towards_target = function(_target)
{
	if (instance_exists(_target))
	{
		var _target_direction = point_direction(x, y, _target.x, _target.y);
		var _current_move_speed = move_speed * unit_move_speed_multiplier_get();

		is_walking = true;
		face_world_x(_target.x);
		x += lengthdir_x(_current_move_speed, _target_direction);
		y += lengthdir_y(_current_move_speed, _target_direction);
	}
};

move_towards_world_point = function(_target_x, _target_y)
{
	var _target_direction = point_direction(x, y, _target_x, _target_y);
	var _current_move_speed = move_speed * unit_move_speed_multiplier_get();

	is_walking = true;
	face_world_x(_target_x);
	x += lengthdir_x(_current_move_speed, _target_direction);
	y += lengthdir_y(_current_move_speed, _target_direction);
};

update_walk_sway = function()
{
	if (!is_walking)
	{
		walk_sway_timer = 0;
		walk_sway_direction = 1;
		image_angle = 0;
		return;
	}

	walk_sway_timer += 1 / max(1, room_speed);

	if (walk_sway_timer >= walk_sway_half_time)
	{
		walk_sway_timer -= walk_sway_half_time;
		walk_sway_direction *= -1;
	}

	image_angle = walk_sway_angle * walk_sway_direction;
};

start_attack_lunge = function(_target)
{
	if (!instance_exists(_target))
	{
		return;
	}

	var _lunge_direction = point_direction(x, y, _target.x, _target.y);

	visual_attack_offset_x = lengthdir_x(attack_lunge_distance, _lunge_direction);
	visual_attack_offset_y = lengthdir_y(attack_lunge_distance, _lunge_direction);
};

update_attack_lunge = function()
{
	if (visual_offset_is_ability_controlled)
	{
		return;
	}

	var _return_time = max(1, reload_time * attack_lunge_return_time_multiplier);
	var _return_amount = attack_lunge_distance / _return_time;
	var _offset_distance = point_distance(0, 0, visual_attack_offset_x, visual_attack_offset_y);

	if (_offset_distance <= 0)
	{
		visual_attack_offset_x = 0;
		visual_attack_offset_y = 0;
		return;
	}

	if (_offset_distance <= _return_amount)
	{
		visual_attack_offset_x = 0;
		visual_attack_offset_y = 0;
		return;
	}

	var _return_direction = point_direction(visual_attack_offset_x, visual_attack_offset_y, 0, 0);

	visual_attack_offset_x += lengthdir_x(_return_amount, _return_direction);
	visual_attack_offset_y += lengthdir_y(_return_amount, _return_direction);
};

rally_group_ready_to_return = function()
{
	var _friendly_count = instance_number(o_friendly_units);

	for (var _friendly_index = 0; _friendly_index < _friendly_count; ++_friendly_index)
	{
		var _friendly_unit = instance_find(o_friendly_units, _friendly_index);

		if (instance_exists(_friendly_unit)
			&& _friendly_unit.rally_is_active
			&& !_friendly_unit.rally_is_returning
			&& _friendly_unit.rally_group_id == rally_group_id)
		{
			if (!_friendly_unit.rally_has_arrived
				|| _friendly_unit.is_attacking_target
				|| instance_exists(_friendly_unit.target_instance))
			{
				return false;
			}
		}
	}

	return true;
};

rally_group_start_returning = function()
{
	var _friendly_count = instance_number(o_friendly_units);

	for (var _friendly_index = 0; _friendly_index < _friendly_count; ++_friendly_index)
	{
		var _friendly_unit = instance_find(o_friendly_units, _friendly_index);

		if (instance_exists(_friendly_unit)
			&& _friendly_unit.rally_is_active
			&& _friendly_unit.rally_group_id == rally_group_id)
		{
			_friendly_unit.rally_is_returning = true;
			_friendly_unit.rally_has_arrived = false;
		}
	}
};

update_separation_push = function()
{
	separation_update_timer++;

	if (separation_update_timer mod separation_update_interval != 0)
	{
		return;
	}

	var _separation_object = o_units_parent;

	if (unit_faction == UNIT_FACTION.ENEMY)
	{
		_separation_object = o_enemy_units;
	}
	else if (unit_faction == UNIT_FACTION.FRIENDLY)
	{
		_separation_object = o_friendly_units;
	}

	var _nearby_units = ds_list_create();
	var _nearby_unit_count = collision_circle_list(x, y, separation_radius, _separation_object, false, true, _nearby_units, false);
	var _checked_unit_count = min(_nearby_unit_count, separation_max_neighbors);
	var _push_x = 0;
	var _push_y = 0;

	// Push away from a few nearby units. This avoids expensive full crowd checks.
	for (var _unit_index = 0; _unit_index < _checked_unit_count; ++_unit_index)
	{
		var _nearby_unit = _nearby_units[| _unit_index];

		if (instance_exists(_nearby_unit) && _nearby_unit != id)
		{
			var _distance_to_unit = point_distance(x, y, _nearby_unit.x, _nearby_unit.y);
			var _push_direction = point_direction(_nearby_unit.x, _nearby_unit.y, x, y);

			if (_distance_to_unit <= 0)
			{
				_distance_to_unit = 1;
				_push_direction = (_unit_index * 47) mod 360;
			}

			var _push_amount = 1 - clamp(_distance_to_unit / separation_radius, 0, 1);

			_push_x += lengthdir_x(_push_amount, _push_direction);
			_push_y += lengthdir_y(_push_amount, _push_direction);
		}
	}

	ds_list_destroy(_nearby_units);

	separation_push_x = clamp(_push_x, -1, 1) * separation_strength;
	separation_push_y = clamp(_push_y, -1, 1) * separation_strength;
};

apply_separation_push = function()
{
	var _separation_multiplier = 1;

	if (is_attacking_target)
	{
		_separation_multiplier = combat_separation_multiplier;
	}

	x += separation_push_x * _separation_multiplier;
	y += separation_push_y * _separation_multiplier;
};

physical_damage_after_armor = function(_raw_damage, _target)
{
	if (!instance_exists(_target) || !variable_instance_exists(_target, "armor"))
	{
		return _raw_damage;
	}

	var _target_armor = _target.armor;

	if (variable_instance_exists(_target, "armor_debuff_multiplier"))
	{
		_target_armor *= _target.armor_debuff_multiplier;
	}

	var _armor_damage_multiplier = max(2 - (min(_target_armor, 190) * 0.01), 0.1);
	return _raw_damage * _armor_damage_multiplier;
};

attack_target = function(_target)
{
	if (!target_can_be_attacked(_target))
	{
		return;
	}

	face_world_x(_target.x);

	if (reload_timer > 0)
	{
		reload_timer--;
		return;
	}

	var _is_magic_damage = magic_damage > 0;
	var _base_attack_damage = damage;

	if (_is_magic_damage)
	{
		_base_attack_damage = magic_damage;
	}

	var _damage_amount = _base_attack_damage * next_attack_damage_multiplier;

	if (variable_instance_exists(id, "unit_damage_modifier_get"))
	{
		_damage_amount *= unit_damage_modifier_get(_target, _is_magic_damage);
	}

	var _is_critical_hit = false;
	var _current_crit_chance = unit_crit_chance_get();

	if (_current_crit_chance > 0 && random(1) < _current_crit_chance)
	{
		_damage_amount *= 2;
		_is_critical_hit = true;
	}

	var _raw_damage_amount = _damage_amount;
	var _target_hp_before_hit = 0;

	if (variable_instance_exists(_target, "hp"))
	{
		_target_hp_before_hit = _target.hp;
	}

	if (!_is_magic_damage)
	{
		_damage_amount = physical_damage_after_armor(_raw_damage_amount, _target);
	}
	else if (variable_instance_exists(_target, "status_effect_magic_damage_multiplier"))
	{
		_damage_amount *= _target.status_effect_magic_damage_multiplier();
	}

	if (variable_instance_exists(_target, "hp"))
	{
		if (variable_instance_exists(_target, "unit_damage_receive"))
		{
			_target.unit_damage_receive(_damage_amount, unit_faction, _is_critical_hit);
		}
		else
		{
			_target.hp = max(_target.hp - _damage_amount, 0);

			if (variable_instance_exists(_target, "unit_faction"))
			{
				damage_popup_create(_target.x, _target.y, _damage_amount, _target.unit_faction, _is_critical_hit);
			}
		}

		start_attack_lunge(_target);

		// Corpse Armor hurts melee attackers while the shield is active.
		if (variable_instance_exists(_target, "corpse_armor_timer")
			&& variable_instance_exists(_target, "corpse_armor_retaliation_damage")
			&& _target.corpse_armor_timer > 0
			&& _target.corpse_armor_retaliation_damage > 0
			&& point_distance(x, y, _target.x, _target.y) <= attack_radius + 12)
		{
			unit_damage_receive(_target.corpse_armor_retaliation_damage, _target.unit_faction);
		}
	}

	if (aoe_radius > 0)
	{
		var _aoe_object = o_enemy_units;

		if (unit_faction == UNIT_FACTION.ENEMY)
		{
			_aoe_object = o_friendly_units;
		}

		var _aoe_list = ds_list_create();
		var _aoe_range = aoe_radius * next_attack_radius_multiplier;
		var _aoe_count = collision_circle_list(_target.x, _target.y, _aoe_range, _aoe_object, false, true, _aoe_list, false);

		for (var _aoe_index = 0; _aoe_index < _aoe_count; ++_aoe_index)
		{
			var _aoe_target = _aoe_list[| _aoe_index];

			if (target_can_be_attacked(_aoe_target) && _aoe_target != _target && variable_instance_exists(_aoe_target, "hp"))
			{
				var _aoe_damage_amount = _raw_damage_amount;

				if (!_is_magic_damage)
				{
					_aoe_damage_amount = physical_damage_after_armor(_raw_damage_amount, _aoe_target);
				}
				else if (variable_instance_exists(_aoe_target, "status_effect_magic_damage_multiplier"))
				{
					_aoe_damage_amount *= _aoe_target.status_effect_magic_damage_multiplier();
				}

				if (variable_instance_exists(_aoe_target, "unit_damage_receive"))
				{
					_aoe_target.unit_damage_receive(_aoe_damage_amount, unit_faction);
				}
				else
				{
					_aoe_target.hp = max(_aoe_target.hp - _aoe_damage_amount, 0);

					if (variable_instance_exists(_aoe_target, "unit_faction"))
					{
						damage_popup_create(_aoe_target.x, _aoe_target.y, _aoe_damage_amount, _aoe_target.unit_faction);
					}
				}
			}
		}

		ds_list_destroy(_aoe_list);
	}

	next_attack_damage_multiplier = 1;
	next_attack_radius_multiplier = 1;

	// Store attack feedback position even if the target dies immediately after hit.
	attack_feedback_target = _target;
	attack_feedback_target_x = _target.x;
	attack_feedback_target_y = _target.y;
	attack_feedback_timer = attack_feedback_time;

	var _target_was_killed = variable_instance_exists(_target, "hp")
		&& _target_hp_before_hit > 0
		&& _target.hp <= 0;

	unit_attack_landed(_target, _is_critical_hit, _target_was_killed);
	reload_timer = reload_time * unit_attack_reload_multiplier_get();
};
