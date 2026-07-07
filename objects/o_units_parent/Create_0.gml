// Base unit combat stats.
unit_faction = UNIT_FACTION.NOONE;
max_hp = 200;
hp = max_hp;
damage = 10;
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
friendly_guard_cannon_enabled = true;
target_instance = noone;
target_search_update_interval = BALANCE_UNIT_TARGET_SEARCH_UPDATE_INTERVAL;
target_search_update_timer = irandom(target_search_update_interval - 1);
target_switch_distance_margin = BALANCE_UNIT_TARGET_SWITCH_DISTANCE_MARGIN;
cached_follow_target = noone;
alert_target = noone;
alert_target_timer = 0;
alert_target_time = BALANCE_UNIT_ALERT_TARGET_TIME * room_speed;
fog_hidden_check_interval = BALANCE_UNIT_FOG_HIDDEN_CHECK_INTERVAL;
fog_hidden_check_timer = irandom(fog_hidden_check_interval - 1);
cached_is_hidden_by_fog = false;
saint_ground_heal_interval = BALANCE_SAINT_GROUND_ENEMY_HEAL_INTERVAL;
saint_ground_heal_timer = irandom(max(1, saint_ground_heal_interval) - 1);
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
holy_tower_reinforcement_waits_for_night = false;

// Unit separation keeps units from stacking into one point.
separation_radius = 26;
separation_strength = 0.55;
separation_update_interval = 5;
separation_update_timer = irandom(separation_update_interval - 1);
separation_max_neighbors = 6;
separation_push_x = 0;
separation_push_y = 0;
separation_push_multiplier = 1;
combat_separation_multiplier = 0.45;
is_attacking_target = false;
attack_ring_slot_seed = irandom(999999);

// Panic flee makes fragile enemies briefly run away from a specific attacker.
panic_flee_source = noone;
panic_flee_timer = 0;
panic_flee_cooldown_timer = 0;
panic_flee_speed_multiplier = 1;

// Forced retreat makes remaining enemies leave the battlefield after the night limit.
forced_retreat_active = false;
forced_retreat_target_x = x;
forced_retreat_target_y = y;
forced_retreat_speed_multiplier = 1;

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
magic_resistance = 100;
armor_debuff_multiplier = 1;
armor_debuff_timer = 0;
crit_chance = 0;
crit_damage = BALANCE_CULTIST_CRIT_DAMAGE_BASE;
aoe_radius = 0;
next_attack_damage_multiplier = 1;
next_attack_radius_multiplier = 1;
demonic_infusion_timer = 0;
demonic_infusion_reload_multiplier = 1;
heal_feedback_pending_amount = 0;
heal_feedback_next_popup_time = 0;
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

// Knockout keeps defeated cultists visible until they recover.
is_knocked_out = false;
knockout_timer = 0;
knockout_duration = BALANCE_CULTIST_KNOCKOUT_TIME * room_speed;
knockout_recovery_hp_share = BALANCE_CULTIST_KNOCKOUT_RECOVERY_HP_SHARE;
knockout_label_text = "Knocked out";
knockout_label_offset_y = 58;
knockout_label_padding_x = 7;
knockout_label_padding_y = 3;
knockout_label_background_alpha = 0.82;
knockout_bar_width = 54;
knockout_bar_height = 5;
knockout_bar_gap = 4;

// Warlock-raised skeletons use regular skeleton stats with extra ability effects.
warlock_skeleton_explosion_enabled = false;
warlock_skeleton_explosion_damage = 0;
warlock_skeleton_respawn_chance = 0;
warlock_skeleton_dies_at_morning = false;

// Building work assignment lets valid friendly units stay at production buildings.
assigned_building = noone;
is_assigned_to_building = false;
idle_work_label_text = "NO WORK";
idle_work_label_offset_y = 34;
idle_work_label_padding_x = 6;
idle_work_label_padding_y = 3;
idle_work_label_background_alpha = 0.82;

// Worker whip temporarily improves day productivity at the cost of health.
whip_timer = 0;
whip_duration = 0;
whip_work_multiplier = 1;

// Cannon corpse hauling uses inert corpse snapshots reserved by the game controller.
carried_corpse = noone;
carried_corpses = [];
corpse_carry_capacity = BALANCE_CANNON_CORPSE_CARRY_CAPACITY;
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

	if (unit_faction == UNIT_FACTION.ENEMY
		&& variable_instance_exists(_target, "ignored_by_enemies")
		&& _target.ignored_by_enemies)
	{
		return false;
	}

	if (variable_instance_exists(_target, "is_attackable") && !_target.is_attackable)
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

ground_cell_saint_amount_get = function(_world_x, _world_y)
{
	if (!instance_exists(o_corruption_grid))
	{
		return 0;
	}

	var _corruption_grid = instance_find(o_corruption_grid, 0);
	var _cell_x = floor(_world_x / _corruption_grid.cell_size);
	var _cell_y = floor(_world_y / _corruption_grid.cell_size);
	var _is_inside_grid = _cell_x >= 0
		&& _cell_x < _corruption_grid.grid_width
		&& _cell_y >= 0
		&& _cell_y < _corruption_grid.grid_height;

	if (!_is_inside_grid
		|| !variable_instance_exists(_corruption_grid, "saint_grid"))
	{
		return 0;
	}

	return ds_grid_get(_corruption_grid.saint_grid, _cell_x, _cell_y);
};

enemy_saint_ground_heal_update = function()
{
	if (unit_faction != UNIT_FACTION.ENEMY
		|| hp <= 0
		|| hp >= max_hp)
	{
		return;
	}

	saint_ground_heal_timer++;

	if (saint_ground_heal_timer < saint_ground_heal_interval)
	{
		return;
	}

	saint_ground_heal_timer = 0;

	var _saint_amount = ground_cell_saint_amount_get(x, y);

	if (_saint_amount <= 0)
	{
		return;
	}

	var _heal_share = BALANCE_SAINT_GROUND_ENEMY_HEAL_MAX_HP_PER_SECOND
		* (saint_ground_heal_interval / max(1, room_speed));
	var _heal_amount = max_hp * _heal_share * clamp(_saint_amount, 0, 1);

	hp = min(hp + _heal_amount, max_hp);
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
	fog_hidden_check_timer++;

	if (fog_hidden_check_timer < fog_hidden_check_interval)
	{
		return cached_is_hidden_by_fog;
	}

	fog_hidden_check_timer = 0;

	if (!global.fog_of_war_visible || !instance_exists(o_fog_of_war))
	{
		cached_is_hidden_by_fog = false;
		return false;
	}

	var _fog_of_war = instance_find(o_fog_of_war, 0);

	if (!variable_instance_exists(_fog_of_war, "fog_grid"))
	{
		cached_is_hidden_by_fog = false;
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
		cached_is_hidden_by_fog = false;
		return false;
	}

	var _fog_alpha = ds_grid_get(_fog_of_war.fog_grid, _cell_x, _cell_y);
	cached_is_hidden_by_fog = _fog_alpha >= _fog_of_war.hidden_alpha;
	return cached_is_hidden_by_fog;
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

unit_crit_damage_get = function()
{
	if (variable_instance_exists(id, "crit_damage"))
	{
		return max(crit_damage, 1);
	}

	return BALANCE_CULTIST_CRIT_DAMAGE_BASE;
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
				var _death_damage = magic_damage_after_resistance(soul_chain_death_damage, _member);

				_member.unit_damage_receive(_death_damage, UNIT_FACTION.FRIENDLY, false, false);
			}

			if (variable_instance_exists(_member, "soul_chain_death_flash_timer"))
			{
				_member.soul_chain_death_flash_timer = _member.soul_chain_death_flash_time;
			}
		}
	}
};

unit_damage_receive = function(_damage_amount, _source_faction = UNIT_FACTION.NOONE, _is_critical = false, _can_trigger_soul_chain = true, _source_instance = noone)
{
	if (hp <= 0 || _damage_amount <= 0)
	{
		return 0;
	}

	if (_source_faction == UNIT_FACTION.ENEMY
		&& variable_instance_exists(id, "ignored_by_enemies")
		&& ignored_by_enemies)
	{
		return 0;
	}

	if (_is_critical)
	{
		_damage_amount *= brute_rotten_aura_critical_damage_multiplier_get();
	}

	var _applied_damage = min(_damage_amount, hp);
	hp = max(hp - _damage_amount, 0);

	if (variable_global_exists("day_phase")
		&& global.day_phase == DAY_PHASE.NIGHT
		&& _source_faction == UNIT_FACTION.ENEMY
		&& variable_instance_exists(id, "adaptive_night_hp_start"))
	{
		if (!variable_instance_exists(id, "adaptive_night_damage_taken"))
		{
			adaptive_night_damage_taken = 0;
		}

		adaptive_night_damage_taken += _applied_damage;
	}

	damage_popup_create(x, y, _applied_damage, unit_faction, _is_critical);

	if (variable_instance_exists(id, "owner_house")
		&& instance_exists(owner_house)
		&& instance_exists(_source_instance)
		&& _source_faction != UNIT_FACTION.ENEMY)
	{
		owner_house.house_guard_call_for_help(id, _source_instance);
	}

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
				_member.unit_damage_receive(_chain_damage, _source_faction, false, false, _source_instance);
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
			_skeleton.warlock_skeleton_explosion_enabled = warlock_skeleton_explosion_enabled;
			_skeleton.warlock_skeleton_explosion_damage = warlock_skeleton_explosion_damage;
			_skeleton.warlock_skeleton_respawn_chance = warlock_skeleton_respawn_chance;
			_skeleton.warlock_skeleton_dies_at_morning = warlock_skeleton_dies_at_morning;
		}
	}
};

unit_corpse_snapshot_create = function()
{
	var _game_controller = noone;

	if (instance_exists(o_game_controller))
	{
		_game_controller = instance_find(o_game_controller, 0);
	}

	if (unit_faction == UNIT_FACTION.ENEMY)
	{
		var _corpse_drop_chance = BALANCE_ENEMY_CORPSE_DROP_CHANCE;

		// Reduce new enemy corpse clutter when too many corpses already exist.
		if (instance_exists(_game_controller)
			&& variable_instance_exists(_game_controller, "corpse_draw_data"))
		{
			var _corpse_count = array_length(_game_controller.corpse_draw_data);
			var _corpse_drop_divisor = 1;

			if (_corpse_count > BALANCE_ENEMY_CORPSE_DROP_HARD_COUNT)
			{
				_corpse_drop_divisor = BALANCE_ENEMY_CORPSE_DROP_HARD_DIVISOR;
			}
			else if (_corpse_count > BALANCE_ENEMY_CORPSE_DROP_MEDIUM_COUNT)
			{
				_corpse_drop_divisor = BALANCE_ENEMY_CORPSE_DROP_MEDIUM_DIVISOR;
			}
			else if (_corpse_count > BALANCE_ENEMY_CORPSE_DROP_SOFT_COUNT)
			{
				_corpse_drop_divisor = BALANCE_ENEMY_CORPSE_DROP_SOFT_DIVISOR;
			}

			_corpse_drop_chance /= _corpse_drop_divisor;
		}

		if (random(1) >= _corpse_drop_chance)
		{
			corpse_visual_created = true;
			return;
		}
	}

	if (!corpse_visual_created && instance_exists(_game_controller))
	{
		if (variable_instance_exists(_game_controller, "corpse_snapshot_add"))
		{
			_game_controller.corpse_snapshot_add(id);
			corpse_visual_created = true;
		}
	}
};

unit_death_sound_play = function()
{
	if (variable_global_exists("death_sounds") && variable_global_exists("sound_play_random"))
	{
		global.sound_play_random(global.death_sounds);
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

	if (is_demon_form_unit() || object_index == o_cultist)
	{
		if (!is_knocked_out)
		{
			unit_death_sound_play();
			soul_chain_death_effect_apply();

			if (global.day_phase == DAY_PHASE.NIGHT && instance_exists(o_game_controller))
			{
				var _game_controller = instance_find(o_game_controller, 0);
				_game_controller.adaptive_night_cultist_knocked_out = true;
			}

			is_knocked_out = true;
			knockout_duration = max(1, BALANCE_CULTIST_KNOCKOUT_TIME * room_speed);
			knockout_timer = knockout_duration;
			hp = 0;
			visible = true;
			image_angle = 90;
			is_being_dragged = false;
			target_instance = noone;
			alert_target = noone;
			forced_attack_target = noone;
			is_attacking_target = false;
			is_walking = false;
			attack_feedback_timer = 0;
			visual_attack_offset_x = 0;
			visual_attack_offset_y = 0;
		}

		return;
	}

	unit_death_sound_play();
	unit_corpse_snapshot_create();
	soul_chain_death_effect_apply();
	warlock_soul_engine_enemy_death_notify();
	warlock_skeleton_death_effect_apply();
	status_effect_death_rewards_try();
	meat_drop_try();
	instance_destroy();
};

knockout_update = function()
{
	if (!is_knocked_out)
	{
		return false;
	}

	target_instance = noone;
	alert_target = noone;
	forced_attack_target = noone;
	is_attacking_target = false;
	is_walking = false;
	is_stunned = false;
	attack_feedback_timer = 0;
	visual_attack_offset_x = 0;
	visual_attack_offset_y = 0;
	image_angle = 90;

	knockout_timer--;

	if (knockout_timer <= 0)
	{
		var _recovered_hp = max(1, max_hp * knockout_recovery_hp_share);

		hp = min(_recovered_hp, max_hp);
		is_knocked_out = false;
		knockout_timer = 0;
		image_angle = 0;
		corpse_visual_created = false;
		morning_respawn_pending = false;
	}

	return is_knocked_out;
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

cannon_wall_attack_radius_get = function()
{
	return BALANCE_CANNON_WALL_RADIUS + cannon_attack_radius;
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

panic_flee_apply = function(_source, _duration_seconds, _cooldown_seconds, _speed_multiplier)
{
	if (!instance_exists(_source) || panic_flee_cooldown_timer > 0)
	{
		return false;
	}

	panic_flee_source = _source;
	panic_flee_timer = max(1, _duration_seconds * room_speed);
	panic_flee_cooldown_timer = max(1, _cooldown_seconds * room_speed);
	panic_flee_speed_multiplier = max(0, _speed_multiplier);
	target_instance = noone;
	is_attacking_target = false;
	is_walking = false;

	return true;
};

panic_flee_update = function()
{
	if (panic_flee_timer <= 0)
	{
		panic_flee_source = noone;
		return false;
	}

	panic_flee_timer--;

	if (!target_can_be_attacked(panic_flee_source))
	{
		panic_flee_timer = 0;
		panic_flee_source = noone;
		return false;
	}

	var _flee_direction = point_direction(panic_flee_source.x, panic_flee_source.y, x, y);
	var _current_move_speed = move_speed * unit_move_speed_multiplier_get() * panic_flee_speed_multiplier;

	if (point_distance(x, y, panic_flee_source.x, panic_flee_source.y) <= 0)
	{
		_flee_direction = irandom(359);
	}

	is_walking = true;
	face_world_x(x + lengthdir_x(1, _flee_direction));
	x += lengthdir_x(_current_move_speed, _flee_direction);
	y += lengthdir_y(_current_move_speed, _flee_direction);

	return true;
};

forced_retreat_start = function(_target_x, _target_y, _speed_multiplier)
{
	forced_retreat_active = true;
	forced_retreat_target_x = _target_x;
	forced_retreat_target_y = _target_y;
	forced_retreat_speed_multiplier = max(0, _speed_multiplier);
	target_instance = noone;
	alert_target = noone;
	forced_attack_target = noone;
	forced_attack_target_timer = 0;
	panic_flee_timer = 0;
	panic_flee_source = noone;
	is_attacking_target = false;
	is_walking = false;
};

forced_retreat_update = function()
{
	if (!forced_retreat_active)
	{
		return false;
	}

	if (unit_is_hidden_by_fog())
	{
		instance_destroy();
		return true;
	}

	var _retreat_distance = point_distance(x, y, forced_retreat_target_x, forced_retreat_target_y);
	var _current_move_speed = move_speed * unit_move_speed_multiplier_get() * forced_retreat_speed_multiplier;

	if (_retreat_distance <= max(_current_move_speed, 8))
	{
		instance_destroy();
		return true;
	}

	var _retreat_direction = point_direction(x, y, forced_retreat_target_x, forced_retreat_target_y);
	var _move_distance = min(_current_move_speed, _retreat_distance);

	is_walking = true;
	face_world_x(forced_retreat_target_x);
	x += lengthdir_x(_move_distance, _retreat_direction);
	y += lengthdir_y(_move_distance, _retreat_direction);

	return true;
};

unit_special_behavior_update = function()
{
	return forced_retreat_update()
		|| panic_flee_update();
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
	var _nearest_distance_squared = _max_distance * _max_distance;
	var _target_count = instance_number(_object_index);

	// Pick the closest valid target and ignore units currently being carried.
	for (var _target_index = 0; _target_index < _target_count; ++_target_index)
	{
		var _target = instance_find(_object_index, _target_index);

		if (!target_can_be_attacked(_target))
		{
			continue;
		}

		var _target_distance_x = _target.x - x;
		var _target_distance_y = _target.y - y;
		var _target_distance_squared = (_target_distance_x * _target_distance_x) + (_target_distance_y * _target_distance_y);

		if (_target_distance_squared < _nearest_distance_squared)
		{
			_nearest_target = _target;
			_nearest_distance_squared = _target_distance_squared;
		}
	}

	return _nearest_target;
};

target_candidate_should_replace = function(_candidate_distance_squared, _nearest_distance_squared, _use_switch_margin)
{
	if (!_use_switch_margin)
	{
		return _candidate_distance_squared < _nearest_distance_squared;
	}

	var _nearest_distance = sqrt(_nearest_distance_squared);
	var _required_distance = max(0, _nearest_distance - target_switch_distance_margin);

	return _candidate_distance_squared < _required_distance * _required_distance;
};

target_is_player_unit = function(_target)
{
	if (!instance_exists(_target))
	{
		return false;
	}

	if (_target.object_index == o_cultist)
	{
		return _target.visible;
	}

	return variable_instance_exists(_target, "unit_faction")
		&& _target.unit_faction == UNIT_FACTION.FRIENDLY;
};

find_nearest_player_unit_target = function(_max_distance)
{
	var _nearest_distance_squared = _max_distance * _max_distance;
	var _nearest_target = noone;
	var _use_switch_margin = false;

	// Keep the current player-unit target unless another target is clearly closer.
	if (target_can_be_attacked(target_instance) && target_is_player_unit(target_instance))
	{
		var _current_target_distance_x = target_instance.x - x;
		var _current_target_distance_y = target_instance.y - y;
		var _current_target_distance_squared = (_current_target_distance_x * _current_target_distance_x) + (_current_target_distance_y * _current_target_distance_y);

		if (_current_target_distance_squared <= _nearest_distance_squared)
		{
			_nearest_target = target_instance;
			_nearest_distance_squared = _current_target_distance_squared;
			_use_switch_margin = true;
		}
	}

	var _friendly_count = instance_number(o_friendly_units);

	for (var _friendly_index = 0; _friendly_index < _friendly_count; ++_friendly_index)
	{
		var _friendly_unit = instance_find(o_friendly_units, _friendly_index);

		if (!target_can_be_attacked(_friendly_unit))
		{
			continue;
		}

		var _friendly_distance_x = _friendly_unit.x - x;
		var _friendly_distance_y = _friendly_unit.y - y;
		var _friendly_distance_squared = (_friendly_distance_x * _friendly_distance_x) + (_friendly_distance_y * _friendly_distance_y);

		if (target_candidate_should_replace(_friendly_distance_squared, _nearest_distance_squared, _use_switch_margin))
		{
			_nearest_target = _friendly_unit;
			_nearest_distance_squared = _friendly_distance_squared;
			_use_switch_margin = false;
		}
	}

	if (!variable_global_exists("cultists"))
	{
		return _nearest_target;
	}

	var _cultist_count = array_length(global.cultists);

	// Cultists are player units but are not children of o_friendly_units.
	for (var _cultist_index = 0; _cultist_index < _cultist_count; ++_cultist_index)
	{
		var _cultist = global.cultists[_cultist_index];

		if (!target_can_be_attacked(_cultist))
		{
			continue;
		}

		if (!_cultist.visible)
		{
			continue;
		}

		var _cultist_distance_x = _cultist.x - x;
		var _cultist_distance_y = _cultist.y - y;
		var _cultist_distance_squared = (_cultist_distance_x * _cultist_distance_x) + (_cultist_distance_y * _cultist_distance_y);

		if (target_candidate_should_replace(_cultist_distance_squared, _nearest_distance_squared, _use_switch_margin))
		{
			_nearest_target = _cultist;
			_nearest_distance_squared = _cultist_distance_squared;
			_use_switch_margin = false;
		}
	}

	return _nearest_target;
};

player_map_structure_can_be_targeted = function(_structure)
{
	if (!target_can_be_attacked(_structure)
		|| !variable_instance_exists(_structure, "hp"))
	{
		return false;
	}

	if (variable_instance_exists(_structure, "building_constructed_by_shell")
		&& _structure.building_constructed_by_shell)
	{
		return true;
	}

	if (variable_instance_exists(_structure, "is_captured")
		&& _structure.is_captured
		&& _structure.object_index != o_cursed_point)
	{
		return true;
	}

	return false;
};

find_nearest_attackable_player_structure = function(_max_distance)
{
	var _nearest_target = noone;
	var _nearest_distance_squared = _max_distance * _max_distance;
	var _map_structure_count = instance_number(o_map_objects_parent);

	for (var _structure_index = 0; _structure_index < _map_structure_count; ++_structure_index)
	{
		var _structure = instance_find(o_map_objects_parent, _structure_index);

		if (!player_map_structure_can_be_targeted(_structure))
		{
			continue;
		}

		var _structure_distance_x = _structure.x - x;
		var _structure_distance_y = _structure.y - y;
		var _structure_distance_squared = (_structure_distance_x * _structure_distance_x) + (_structure_distance_y * _structure_distance_y);

		if (_structure_distance_squared <= _nearest_distance_squared)
		{
			_nearest_target = _structure;
			_nearest_distance_squared = _structure_distance_squared;
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
	var _nearest_distance_squared = infinity;
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

		var _enemy_distance_x = _enemy.x - x;
		var _enemy_distance_y = _enemy.y - y;
		var _enemy_distance_squared = (_enemy_distance_x * _enemy_distance_x) + (_enemy_distance_y * _enemy_distance_y);

		if (_enemy_distance_squared < _nearest_distance_squared)
		{
			_nearest_attacker = _enemy;
			_nearest_distance_squared = _enemy_distance_squared;
		}
	}

	return _nearest_attacker;
};

find_nearest_enemy_object = function(_max_distance)
{
	var _nearest_target = noone;
	var _nearest_distance_squared = _max_distance * _max_distance;

	// Holy towers are hostile structures for friendly units.
	if (instance_exists(o_holy_tower))
	{
		var _holy_tower_count = instance_number(o_holy_tower);

		for (var _tower_index = 0; _tower_index < _holy_tower_count; ++_tower_index)
		{
			var _tower = instance_find(o_holy_tower, _tower_index);

			if (instance_exists(_tower) && _tower.hp > 0)
			{
				var _tower_distance_x = _tower.x - x;
				var _tower_distance_y = _tower.y - y;
				var _tower_distance_squared = (_tower_distance_x * _tower_distance_x) + (_tower_distance_y * _tower_distance_y);

				if (_tower_distance_squared <= _nearest_distance_squared)
				{
					_nearest_distance_squared = _tower_distance_squared;
					_nearest_target = _tower;
				}
			}
		}
	}

	// Shrines become hostile objectives only after their protective towers fall.
	if (instance_exists(o_shrine))
	{
		var _shrine_count = instance_number(o_shrine);

		for (var _shrine_index = 0; _shrine_index < _shrine_count; ++_shrine_index)
		{
			var _shrine = instance_find(o_shrine, _shrine_index);

			if (target_can_be_attacked(_shrine))
			{
				var _shrine_distance_x = _shrine.x - x;
				var _shrine_distance_y = _shrine.y - y;
				var _shrine_distance_squared = (_shrine_distance_x * _shrine_distance_x) + (_shrine_distance_y * _shrine_distance_y);

				if (_shrine_distance_squared <= _nearest_distance_squared)
				{
					_nearest_distance_squared = _shrine_distance_squared;
					_nearest_target = _shrine;
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
				var _garnizon_distance_x = _garnizon.x - x;
				var _garnizon_distance_y = _garnizon.y - y;
				var _garnizon_distance_squared = (_garnizon_distance_x * _garnizon_distance_x) + (_garnizon_distance_y * _garnizon_distance_y);

				if (_garnizon_distance_squared <= _nearest_distance_squared)
				{
					_nearest_distance_squared = _garnizon_distance_squared;
					_nearest_target = _garnizon;
				}
			}
		}
	}

	// Houses are hostile structures that maintain local guards.
	if (instance_exists(o_house))
	{
		var _house_count = instance_number(o_house);

		for (var _house_index = 0; _house_index < _house_count; ++_house_index)
		{
			var _house = instance_find(o_house, _house_index);

			if (instance_exists(_house) && _house.hp > 0)
			{
				var _house_distance_x = _house.x - x;
				var _house_distance_y = _house.y - y;
				var _house_distance_squared = (_house_distance_x * _house_distance_x) + (_house_distance_y * _house_distance_y);

				if (_house_distance_squared <= _nearest_distance_squared)
				{
					_nearest_distance_squared = _house_distance_squared;
					_nearest_target = _house;
				}
			}
		}
	}

	return _nearest_target;
};

find_nearest_visible_cultist = function()
{
	var _nearest_cultist = noone;
	var _nearest_distance_squared = infinity;
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

		var _cultist_distance_x = _cultist.x - x;
		var _cultist_distance_y = _cultist.y - y;
		var _cultist_distance_squared = (_cultist_distance_x * _cultist_distance_x) + (_cultist_distance_y * _cultist_distance_y);

		if (_cultist_distance_squared < _nearest_distance_squared)
		{
			_nearest_cultist = _cultist;
			_nearest_distance_squared = _cultist_distance_squared;
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

attack_ring_should_use = function(_target, _attack_radius)
{
	if (unit_faction != UNIT_FACTION.ENEMY
		|| !instance_exists(_target)
		|| _target.object_index == o_cannon
		|| _target == guard_target
		|| _attack_radius > BALANCE_UNIT_ATTACK_RING_MELEE_RADIUS_MAX)
	{
		return false;
	}

	if (variable_instance_exists(_target, "unit_faction"))
	{
		return _target.unit_faction == UNIT_FACTION.FRIENDLY;
	}

	return false;
};

attack_ring_point_get = function(_target, _attack_radius)
{
	var _slot_count = max(1, BALANCE_UNIT_ATTACK_RING_SLOT_COUNT);
	var _slot_angle_size = 360 / _slot_count;
	var _direction_from_target = point_direction(_target.x, _target.y, x, y);
	var _base_slot_index = round(_direction_from_target / _slot_angle_size);
	var _nearby_slot_spread = 3; // Previous, current, and next nearest slots.
	var _slot_offset = (attack_ring_slot_seed mod _nearby_slot_spread) - 1;
	var _slot_index = (_base_slot_index + _slot_offset) mod _slot_count;
	var _ring_radius = min(BALANCE_UNIT_ATTACK_RING_MAX_RADIUS, max(0, _attack_radius - BALANCE_UNIT_ATTACK_RING_ATTACK_PADDING));

	if (_slot_index < 0)
	{
		_slot_index += _slot_count;
	}

	// Use a nearby slot so moving melee targets do not make enemies run to the far side.
	var _slot_angle = _slot_angle_size * _slot_index;

	return [
		_target.x + lengthdir_x(_ring_radius, _slot_angle),
		_target.y + lengthdir_y(_ring_radius, _slot_angle)
	];
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
	var _separation_multiplier = separation_push_multiplier;

	if (is_attacking_target)
	{
		_separation_multiplier *= combat_separation_multiplier;
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

magic_damage_after_resistance = function(_raw_damage, _target)
{
	var _final_damage = _raw_damage;

	if (instance_exists(_target) && variable_instance_exists(_target, "magic_resistance"))
	{
		var _target_magic_resistance = _target.magic_resistance;
		var _resistance_damage_multiplier = max(2 - (min(_target_magic_resistance, 190) * 0.01), 0.1);

		_final_damage *= _resistance_damage_multiplier;
	}

	if (instance_exists(_target) && variable_instance_exists(_target, "status_effect_magic_damage_multiplier"))
	{
		_final_damage *= _target.status_effect_magic_damage_multiplier();
	}

	return _final_damage;
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
		_damage_amount *= unit_crit_damage_get();
		_is_critical_hit = true;
	}

	var _raw_damage_amount = _damage_amount;
	var _target_hp_before_hit = 0;
	var _target_hit_x = _target.x;
	var _target_hit_y = _target.y;

	if (variable_instance_exists(_target, "hp"))
	{
		_target_hp_before_hit = _target.hp;
	}

	if (!_is_magic_damage)
	{
		_damage_amount = physical_damage_after_armor(_raw_damage_amount, _target);
	}
	else
	{
		_damage_amount = magic_damage_after_resistance(_raw_damage_amount, _target);
	}

	if (variable_instance_exists(_target, "hp"))
	{
		if (variable_instance_exists(_target, "unit_damage_receive"))
		{
			_target.unit_damage_receive(_damage_amount, unit_faction, _is_critical_hit, true, id);
		}
		else
		{
			_target.hp = max(_target.hp - _damage_amount, 0);

			if (variable_instance_exists(_target, "unit_faction"))
			{
				damage_popup_create(_target.x, _target.y, _damage_amount, _target.unit_faction, _is_critical_hit);
			}

			if (variable_instance_exists(_target, "building_constructed_by_shell")
				&& _target.building_constructed_by_shell
				&& _target.hp <= 0)
			{
				with (_target)
				{
					instance_destroy();
				}
			}
		}

		if (instance_exists(_target))
		{
			start_attack_lunge(_target);
		}

		// Corpse Armor hurts melee attackers while the shield is active.
		if (instance_exists(_target)
			&& variable_instance_exists(_target, "corpse_armor_timer")
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
		var _aoe_count = collision_circle_list(_target_hit_x, _target_hit_y, _aoe_range, _aoe_object, false, true, _aoe_list, false);

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
				else
				{
					_aoe_damage_amount = magic_damage_after_resistance(_raw_damage_amount, _aoe_target);
				}

				if (variable_instance_exists(_aoe_target, "unit_damage_receive"))
				{
					_aoe_target.unit_damage_receive(_aoe_damage_amount, unit_faction, false, true, id);
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
	attack_feedback_target = noone;
	attack_feedback_target_x = _target_hit_x;
	attack_feedback_target_y = _target_hit_y;
	attack_feedback_timer = attack_feedback_time;

	var _target_exists_after_hit = instance_exists(_target);
	var _target_was_killed = _target_hp_before_hit > 0
		&& (!_target_exists_after_hit
			|| (variable_instance_exists(_target, "hp") && _target.hp <= 0));

	unit_attack_landed(_target, _is_critical_hit, _target_was_killed);
	reload_timer = reload_time * unit_attack_reload_multiplier_get();
};
