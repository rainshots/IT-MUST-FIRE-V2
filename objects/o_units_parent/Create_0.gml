// Base unit combat stats.
unit_faction = UNIT_FACTION.NOONE;
max_hp = 200;
hp = max_hp;
damage = 10;
magic_damage = 0;
reload_time = room_speed;
reload_timer = reload_time;
initial_attack_reload_pending = true; // First Step applies the unit type's final full reload duration.
attack_radius = 32;
y_sort_enabled = true;

// Base unit movement and target search settings.
move_speed = 1.2;
gameplay_time_scale = 1; // Updated from the global simulation scale every Step.
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

// Wall navigation paths are rebuilt on target changes and retried slowly after failures.
navigation_path = noone;
navigation_target = noone;
navigation_target_position_x = x;
navigation_target_position_y = y;
navigation_goal_x = x;
navigation_goal_y = y;
navigation_grid_version = -1;
navigation_has_path = false;
navigation_has_direct_route = false;
navigation_path_failed = false;
navigation_path_point_index = 0;
navigation_retry_timer = 0;
navigation_retry_interval = max(1, BALANCE_WALL_NAVIGATION_RETRY_TIME * room_speed);
navigation_last_safe_x = x;
navigation_last_safe_y = y;
navigation_has_safe_position = false;
navigation_recovery_check_interval = BALANCE_WALL_NAVIGATION_RECOVERY_CHECK_INTERVAL;
navigation_recovery_check_timer = irandom(navigation_recovery_check_interval - 1);
fog_hidden_check_interval = BALANCE_UNIT_FOG_HIDDEN_CHECK_INTERVAL;
fog_hidden_check_timer = irandom(fog_hidden_check_interval - 1);
cached_is_hidden_by_fog = false;
saint_ground_heal_interval = BALANCE_SAINT_GROUND_ENEMY_HEAL_INTERVAL;
saint_ground_heal_timer = irandom(max(1, saint_ground_heal_interval) - 1);
tainted_ground_check_interval = BALANCE_TAINT_FRIENDLY_GROUND_CHECK_INTERVAL;
tainted_ground_check_timer = tainted_ground_check_interval;
cached_is_on_tainted_ground = false;
tainted_ground_heal_interval = max(1, round(BALANCE_DAY_THREE_TAINTED_GROUND_HEAL_INTERVAL * room_speed));
tainted_ground_heal_timer = irandom(tainted_ground_heal_interval - 1);
forced_attack_target = noone;
forced_attack_target_timer = 0;
manual_structure_target = noone;
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
cannon_loading = false;
cannon_loaded = false;

// Squad membership persists through the squad system and can be replaced after transformations.
squad = noone;
squad_unit_index = -1;

// Unholy Trait state is shared by every squad unit type through this parent object.
unholy_taint_treatment_heal_timer = 0;
unholy_savage_leap_active = false;
unholy_savage_leap_cooldown_timer = 0;
unholy_savage_leap_search_timer = 0;
unholy_savage_leap_flight_timer = 0;
unholy_savage_leap_flight_duration = max(
	1,
	BALANCE_UNHOLY_SHRINE_SAVAGE_LEAP_ANIMATION_TIME * room_speed
);
unholy_savage_leap_start_x = x;
unholy_savage_leap_start_y = y;
unholy_savage_leap_end_x = x;
unholy_savage_leap_end_y = y;
unholy_savage_leap_target = noone;
unholy_abyss_marks = []; // Active Roar marks retain the squad that may deal bonus damage.
unholy_abyss_immortality_timer = 0; // Surviving Roar squad members cannot fall below 1 HP briefly.
unholy_aura_instance = noone;

// Regroup movement sends newly spawned friendly summons toward the cannon day area.
regroup_is_active = false;
regroup_target_x = x;
regroup_target_y = y;
regroup_arrive_radius = BALANCE_PROJECTILE_RALLY_ARRIVE_RADIUS;

// Daytime squad areas give each idle unit a small independent wander target.
squad_point_wander_point = noone;
squad_point_wander_target_x = x;
squad_point_wander_target_y = y;
squad_point_wander_wait_timer = 0;
squad_point_wander_target_valid = false;

// Optional guard behavior is used by spawned defenders.
owner_garnizon = noone;
guard_target = noone;
guard_radius = 220;
unit_can_attack_cannon = true;
// Debug-spawned units use combat deployment rules without joining persistent squads.
debug_combat_spawned = false;
balance_test_match_id = -1;
balance_test_simulation_finished = false;
health_bar_world_draw_forced = false;
is_night_attack_unit = false;
holy_tower_reinforcement_waits_for_night = false;
foundry_permanent_bonuses_pending = true;
// Relic multipliers track what this instance already received from its squad.
relic_health_multiplier_applied = 1;
relic_damage_multiplier_applied = 1;
relic_attack_speed_multiplier_applied = 1;
relic_move_speed_multiplier_applied = 1;
relic_armor_multiplier_applied = 1;
relic_magic_resistance_multiplier_applied = 1;
// Cheat balance UI uses this snapshot marker to keep dead units in the nightly HP total.
balance_player_hp_snapshot_id = 0;

// Night attackers march quickly until they reach player defenses or take damage.
enemy_march_current_multiplier = 1;
enemy_march_combat_reached = false;
enemy_march_fade_frame_count = max(1, BALANCE_ENEMY_MARCH_FADE_TIME * room_speed);
enemy_march_defense_check_interval = BALANCE_ENEMY_MARCH_DEFENSE_CHECK_INTERVAL;
enemy_march_defense_check_timer = irandom(enemy_march_defense_check_interval - 1);

// Unit separation keeps units from stacking into one point.
separation_radius = BALANCE_UNIT_SEPARATION_RADIUS;
separation_strength = BALANCE_UNIT_SEPARATION_STRENGTH;
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

// Damage briefly replaces the unit sprite colors with a white silhouette.
damage_flash_duration = max(1, round(BALANCE_UNIT_DAMAGE_FLASH_TIME * room_speed));
damage_flash_timer = 0;

// Optional combat modifiers used by cultist demon forms and debuffs.
armor = 100;
magic_resistance = 100;
armor_debuff_multiplier = 1;
armor_debuff_timer = 0;
crit_chance = 0;
crit_damage = BALANCE_CULTIST_CRIT_DAMAGE_BASE;
aoe_radius = 0;
attack_target_count = 0; // Zero allows every valid target inside the AOE.
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

// Skeleton projectile summons last only until the next morning.
projectile_skeleton_dies_at_morning = false;

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

// Persistent Doom Bells own stasis and silence through removable source references.
doom_bell_stasis_sources = [];
doom_bell_stasis_active = false;
doom_bell_silence_sources = [];
doom_bell_silence_active = false;

doom_bell_stasis_source_add = function(_source)
{
	if (!instance_exists(_source))
	{
		return false;
	}

	var _source_count = array_length(doom_bell_stasis_sources);

	for (var _source_index = 0; _source_index < _source_count; ++_source_index)
	{
		if (doom_bell_stasis_sources[_source_index] == _source)
		{
			return false;
		}
	}

	array_push(doom_bell_stasis_sources, _source);
	doom_bell_stasis_active = true;
	return true;
};

doom_bell_stasis_source_remove = function(_source)
{
	for (var _source_index = array_length(doom_bell_stasis_sources) - 1; _source_index >= 0; --_source_index)
	{
		if (doom_bell_stasis_sources[_source_index] == _source)
		{
			array_delete(doom_bell_stasis_sources, _source_index, 1);
		}
	}

	doom_bell_stasis_active = array_length(doom_bell_stasis_sources) > 0;
	return doom_bell_stasis_active;
};

doom_bell_stasis_is_active = function()
{
	for (var _source_index = array_length(doom_bell_stasis_sources) - 1; _source_index >= 0; --_source_index)
	{
		if (!instance_exists(doom_bell_stasis_sources[_source_index]))
		{
			array_delete(doom_bell_stasis_sources, _source_index, 1);
		}
	}

	doom_bell_stasis_active = array_length(doom_bell_stasis_sources) > 0;
	return doom_bell_stasis_active;
};

doom_bell_silence_source_add = function(_source)
{
	if (!instance_exists(_source))
	{
		return false;
	}

	var _source_count = array_length(doom_bell_silence_sources);

	for (var _source_index = 0; _source_index < _source_count; ++_source_index)
	{
		if (doom_bell_silence_sources[_source_index] == _source)
		{
			return false;
		}
	}

	array_push(doom_bell_silence_sources, _source);
	doom_bell_silence_active = true;
	return true;
};

doom_bell_silence_source_remove = function(_source)
{
	for (var _source_index = array_length(doom_bell_silence_sources) - 1; _source_index >= 0; --_source_index)
	{
		if (doom_bell_silence_sources[_source_index] == _source)
		{
			array_delete(doom_bell_silence_sources, _source_index, 1);
		}
	}

	doom_bell_silence_active = array_length(doom_bell_silence_sources) > 0;
	return doom_bell_silence_active;
};

doom_bell_silence_is_active = function()
{
	for (var _source_index = array_length(doom_bell_silence_sources) - 1; _source_index >= 0; --_source_index)
	{
		if (!instance_exists(doom_bell_silence_sources[_source_index]))
		{
			array_delete(doom_bell_silence_sources, _source_index, 1);
		}
	}

	doom_bell_silence_active = array_length(doom_bell_silence_sources) > 0;
	return doom_bell_silence_active;
};

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

// Friendly support effects keep separate entries for every caster.
support_buff_effects = [];
support_heal_effects = [];

support_buff_has_source = function(_source)
{
	for (var _effect_index = 0; _effect_index < array_length(support_buff_effects); ++_effect_index)
	{
		if (support_buff_effects[_effect_index].source == _source)
		{
			return true;
		}
	}

	return false;
};

support_heal_has_source = function(_source)
{
	for (var _effect_index = 0; _effect_index < array_length(support_heal_effects); ++_effect_index)
	{
		if (support_heal_effects[_effect_index].source == _source)
		{
			return true;
		}
	}

	return false;
};

support_buff_add = function(_source, _duration, _multiplier)
{
	if (support_buff_has_source(_source))
	{
		return false;
	}

	array_push(support_buff_effects, {
		source: _source,
		timer: max(1, floor(_duration)),
		multiplier: _multiplier
	});

	if (variable_instance_exists(id, "move_speed")) move_speed *= _multiplier;
	if (variable_instance_exists(id, "damage")) damage *= _multiplier;
	if (variable_instance_exists(id, "magic_damage")) magic_damage *= _multiplier;
	return true;
};

support_heal_add = function(_source, _duration, _interval, _heal_amount)
{
	if (support_heal_has_source(_source))
	{
		return false;
	}

	array_push(support_heal_effects, {
		source: _source,
		timer: max(1, floor(_duration)),
		tick_timer: max(1, floor(_interval)),
		tick_interval: max(1, floor(_interval)),
		heal_amount: _heal_amount
	});
	return true;
};

support_effects_update = function()
{
	for (var _effect_index = array_length(support_buff_effects) - 1; _effect_index >= 0; --_effect_index)
	{
		var _buff = support_buff_effects[_effect_index];
		_buff.timer -= gameplay_time_scale;

		if (_buff.timer > 0)
		{
			continue;
		}

		if (variable_instance_exists(id, "move_speed")) move_speed /= _buff.multiplier;
		if (variable_instance_exists(id, "damage")) damage /= _buff.multiplier;
		if (variable_instance_exists(id, "magic_damage")) magic_damage /= _buff.multiplier;
		array_delete(support_buff_effects, _effect_index, 1);
	}

	for (var _effect_index = array_length(support_heal_effects) - 1; _effect_index >= 0; --_effect_index)
	{
		var _heal = support_heal_effects[_effect_index];
		_heal.timer -= gameplay_time_scale;
		_heal.tick_timer -= gameplay_time_scale;

		if (_heal.tick_timer <= 0)
		{
			hp = min(max_hp, hp + _heal.heal_amount);
			_heal.tick_timer = _heal.tick_interval;
		}

		if (_heal.timer <= 0)
		{
			array_delete(support_heal_effects, _effect_index, 1);
		}
	}
};

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

	// Hidden and undeployed units are outside combat targeting.
	if (variable_instance_exists(_target, "unit_faction") && !_target.visible)
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

	// Friendly squads ignore enemies held by a Funeral Pause bell.
	if (unit_faction == UNIT_FACTION.FRIENDLY
		&& variable_instance_exists(_target, "doom_bell_stasis_active")
		&& _target.doom_bell_stasis_active)
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

	// Mountains prevent combat units on opposite sides from seeing or attacking each other.
	var _target_is_combat_unit = _target.object_index == o_archdemon
		|| _target.object_index == o_units_parent
		|| object_is_ancestor(_target.object_index, o_units_parent);

	if (_target_is_combat_unit
		&& instance_number(o_mountain) > 0
		&& collision_line(x, y, _target.x, _target.y, o_mountain, false, true) != noone)
	{
		return false;
	}

	// Automated balance matches are isolated even when their arenas share one room.
	if (balance_test_match_id >= 0)
	{
		if (!variable_instance_exists(_target, "balance_test_match_id")
			|| _target.balance_test_match_id != balance_test_match_id)
		{
			return false;
		}
	}

	return true;
};

status_effect_is_negative = function(_status_type)
{
	return _status_type == STATUS_EFFECT.BLEED
		|| _status_type == STATUS_EFFECT.FEAR
		|| _status_type == STATUS_EFFECT.SOUL_MARK
		|| _status_type == STATUS_EFFECT.CURSE
		|| _status_type == STATUS_EFFECT.STUN
		|| _status_type == STATUS_EFFECT.SLOW;
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

unit_is_on_tainted_ground = function()
{
	tainted_ground_check_timer += gameplay_time_scale;

	if (tainted_ground_check_timer < tainted_ground_check_interval)
	{
		return cached_is_on_tainted_ground;
	}

	tainted_ground_check_timer = 0;

	if (!instance_exists(o_corruption_grid))
	{
		cached_is_on_tainted_ground = false;
		return false;
	}

	var _corruption_grid = instance_find(o_corruption_grid, 0);
	var _cell_x = floor(x / _corruption_grid.cell_size);
	var _cell_y = floor(y / _corruption_grid.cell_size);
	var _is_inside_grid = _cell_x >= 0
		&& _cell_x < _corruption_grid.grid_width
		&& _cell_y >= 0
		&& _cell_y < _corruption_grid.grid_height;

	if (!_is_inside_grid)
	{
		cached_is_on_tainted_ground = false;
		return false;
	}

	var _saint_amount = 0;

	if (variable_instance_exists(_corruption_grid, "saint_grid"))
	{
		_saint_amount = ds_grid_get(_corruption_grid.saint_grid, _cell_x, _cell_y);
	}

	cached_is_on_tainted_ground = _saint_amount <= 0
		&& ds_grid_get(_corruption_grid.corruption_grid, _cell_x, _cell_y) > 0;

	return cached_is_on_tainted_ground;
};

enemy_saint_ground_heal_update = function()
{
	if (unit_faction != UNIT_FACTION.ENEMY
		|| hp <= 0
		|| hp >= max_hp)
	{
		return;
	}

	saint_ground_heal_timer += gameplay_time_scale;

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

friendly_tainted_ground_heal_update = function()
{
	if (unit_faction != UNIT_FACTION.FRIENDLY
		|| !variable_global_exists("player_tainted_ground_healing_active")
		|| !global.player_tainted_ground_healing_active
		|| hp <= 0
		|| hp >= max_hp)
	{
		return;
	}

	tainted_ground_heal_timer += gameplay_time_scale;

	if (tainted_ground_heal_timer < tainted_ground_heal_interval)
	{
		return;
	}

	tainted_ground_heal_timer = 0;

	if (!unit_is_on_tainted_ground())
	{
		return;
	}

	var _heal_amount = BALANCE_DAY_THREE_TAINTED_GROUND_HEAL_PER_SECOND
		* (tainted_ground_heal_interval / max(1, room_speed));
	var _previous_hp = hp;
	hp = min(hp + _heal_amount, max_hp);

	if (hp > _previous_hp)
	{
		heal_feedback_create(id, hp - _previous_hp);
	}
};

unholy_taint_treatment_enemy_is_nearby = function()
{
	var _enemy_count = instance_number(o_enemy_units);
	var _enemy_radius = BALANCE_UNHOLY_SHRINE_TAINT_TREATMENT_ENEMY_RADIUS;
	var _enemy_radius_squared = _enemy_radius * _enemy_radius;

	for (var _enemy_index = 0; _enemy_index < _enemy_count; ++_enemy_index)
	{
		var _enemy = instance_find(o_enemy_units, _enemy_index);

		if (!target_can_be_attacked(_enemy))
		{
			continue;
		}

		var _distance_x = _enemy.x - x;
		var _distance_y = _enemy.y - y;

		if ((_distance_x * _distance_x) + (_distance_y * _distance_y) <= _enemy_radius_squared)
		{
			return true;
		}
	}

	return false;
};

unholy_taint_treatment_update = function()
{
	if (unit_faction != UNIT_FACTION.FRIENDLY
		|| global.day_phase != DAY_PHASE.NIGHT
		|| !is_struct(squad)
		|| squad_unholy_trait_get(squad) != UNHOLY_TRAIT.TAINT_TREATMENT
		|| hp <= 0
		|| hp >= max_hp)
	{
		unholy_taint_treatment_heal_timer = 0;
		return;
	}

	// Healing is applied in short batches while no enemy threatens this unit.
	unholy_taint_treatment_heal_timer += gameplay_time_scale;
	var _heal_interval = max(
		1,
		BALANCE_UNHOLY_SHRINE_TAINT_TREATMENT_HEAL_INTERVAL * room_speed
	);

	if (unholy_taint_treatment_heal_timer < _heal_interval)
	{
		return;
	}

	if (!unit_is_on_tainted_ground() || unholy_taint_treatment_enemy_is_nearby())
	{
		unholy_taint_treatment_heal_timer = 0;
		return;
	}

	unholy_taint_treatment_heal_timer -= _heal_interval;
	var _heal_amount = BALANCE_UNHOLY_SHRINE_TAINT_TREATMENT_HEAL_PER_SECOND
		* (_heal_interval / max(1, room_speed));
	var _previous_hp = hp;
	hp = min(hp + _heal_amount, max_hp);

	if (hp > _previous_hp)
	{
		heal_feedback_create(id, hp - _previous_hp);
	}
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
	var _slow_amount = 0;

	if (status_effect_has(STATUS_EFFECT.FEAR))
	{
		_slow_amount = max(_slow_amount, status_effect_strengths[STATUS_EFFECT.FEAR]);
	}

	if (status_effect_has(STATUS_EFFECT.SLOW))
	{
		// Independent slows use the strongest value instead of multiplying together.
		_slow_amount = max(_slow_amount, status_effect_strengths[STATUS_EFFECT.SLOW]);
	}

	return 1 - clamp(_slow_amount, 0, 0.95);
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

	if (unit_faction == UNIT_FACTION.FRIENDLY && !unit_is_on_tainted_ground())
	{
		_reload_multiplier /= BALANCE_TAINT_FRIENDLY_ATTACK_SPEED_MULTIPLIER;
	}

	if (variable_instance_exists(id, "imp_blood_frenzy_reload_multiplier_get"))
	{
		_reload_multiplier *= imp_blood_frenzy_reload_multiplier_get();
	}

	if (variable_instance_exists(id, "imp_active_reload_multiplier_get"))
	{
		_reload_multiplier *= imp_active_reload_multiplier_get();
	}

	if (global.day_phase == DAY_PHASE.NIGHT
		&& global.ritual_hell_weakest_active
		&& variable_instance_exists(id, "squad")
		&& is_struct(squad)
		&& squad != global.ritual_hell_weakest_squad)
	{
		_reload_multiplier /= BALANCE_RITUAL_HELL_WEAKEST_ATTACK_SPEED_MULTIPLIER;
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

	if (unit_faction == UNIT_FACTION.FRIENDLY && !unit_is_on_tainted_ground())
	{
		_move_multiplier *= BALANCE_TAINT_FRIENDLY_MOVE_SPEED_MULTIPLIER;
	}

	if (variable_instance_exists(id, "imp_blood_frenzy_move_multiplier_get"))
	{
		_move_multiplier *= imp_blood_frenzy_move_multiplier_get();
	}

	// A marching squad runs faster only while its shared proximity check allows it.
	if (is_struct(squad))
	{
		_move_multiplier *= squad_march_speed_multiplier_get(squad);
	}

	// March speed is independent from fog visibility and fades before combat.
	_move_multiplier *= enemy_march_current_multiplier;

	if (global.day_phase == DAY_PHASE.NIGHT && unit_is_on_tainted_ground())
	{
		if (unit_faction == UNIT_FACTION.FRIENDLY && global.ritual_black_pilgrimage_active)
		{
			_move_multiplier *= 1 + BALANCE_RITUAL_BLACK_PILGRIMAGE_MOVE_SPEED_BONUS;
		}
		else if (unit_faction == UNIT_FACTION.ENEMY && global.ritual_grasping_soil_active)
		{
			_move_multiplier *= BALANCE_RITUAL_GRASPING_SOIL_ENEMY_SPEED_MULTIPLIER;
		}
	}

	return _move_multiplier;
};

enemy_march_stop = function()
{
	enemy_march_combat_reached = true;
};

enemy_march_defense_is_near = function()
{
	var _defense_radius = BALANCE_ENEMY_MARCH_DEFENSE_RADIUS;

	// Player combat units end marching before the enemy enters its normal detection radius.
	if (instance_exists(find_nearest_player_unit_target(_defense_radius)))
	{
		return true;
	}

	// Constructed and captured player buildings also mark the start of combat space.
	if (instance_exists(find_nearest_attackable_player_structure(_defense_radius)))
	{
		return true;
	}

	// Ally walls are defenses even when they were placed directly in the room editor.
	if (instance_exists(o_wall_ally))
	{
		var _nearest_wall = instance_nearest(x, y, o_wall_ally);

		if (instance_exists(_nearest_wall)
			&& (!variable_instance_exists(_nearest_wall, "hp") || _nearest_wall.hp > 0))
		{
			var _wall_distance = point_distance(x, y, _nearest_wall.x, _nearest_wall.y);

			if (variable_instance_exists(_nearest_wall, "wall_distance_to_point"))
			{
				_wall_distance = _nearest_wall.wall_distance_to_point(x, y);
			}

			if (_wall_distance <= _defense_radius)
			{
				return true;
			}
		}
	}

	// With no outer defense, slow down shortly before reaching the cannon itself.
	if (instance_exists(o_cannon))
	{
		var _cannon = instance_find(o_cannon, 0);
		var _cannon_approach_radius = attack_radius
			+ BALANCE_ENEMY_MARCH_CANNON_APPROACH_PADDING;

		if (point_distance(x, y, _cannon.x, _cannon.y) <= _cannon_approach_radius)
		{
			return true;
		}
	}

	return false;
};

enemy_march_update = function()
{
	// Keep the march multiplier neutral while the feature is disabled in balance.
	if (!BALANCE_ENEMY_MARCH_ENABLED)
	{
		enemy_march_current_multiplier = 1;
		enemy_march_combat_reached = true;
		return;
	}

	var _can_march = unit_faction == UNIT_FACTION.ENEMY
		&& is_night_attack_unit
		&& unit_can_attack_cannon
		&& global.day_phase == DAY_PHASE.NIGHT
		&& !forced_retreat_active
		&& !enemy_march_combat_reached;

	if (_can_march)
	{
		var _has_defense_target = instance_exists(target_instance)
			&& target_instance.object_index != o_cannon;

		if (_has_defense_target
			|| instance_exists(alert_target)
			|| target_can_be_attacked(forced_attack_target)
			|| is_attacking_target)
		{
			enemy_march_stop();
			_can_march = false;
		}
	}

	if (_can_march)
	{
		enemy_march_defense_check_timer++;

		if (enemy_march_defense_check_timer >= enemy_march_defense_check_interval)
		{
			enemy_march_defense_check_timer = 0;

			if (enemy_march_defense_is_near())
			{
				enemy_march_stop();
				_can_march = false;
			}
		}
	}

	if (_can_march)
	{
		enemy_march_current_multiplier = BALANCE_ENEMY_MARCH_MOVE_SPEED_MULTIPLIER;
		return;
	}

	// Ease from march speed to normal combat speed over the configured duration.
	var _fade_amount = (BALANCE_ENEMY_MARCH_MOVE_SPEED_MULTIPLIER - 1)
		/ enemy_march_fade_frame_count
		* gameplay_time_scale;
	enemy_march_current_multiplier = max(1, enemy_march_current_multiplier - _fade_amount);
};

unit_is_hidden_by_fog = function()
{
	fog_hidden_check_timer += gameplay_time_scale;

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
	else if (_status_type == STATUS_EFFECT.SLOW && variable_global_exists("particle_type_status_slow"))
	{
		return global.particle_type_status_slow;
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

		status_effect_particle_timers[_status_type] -= gameplay_time_scale;

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

	status_effect_tick_timers[STATUS_EFFECT.BLEED] -= gameplay_time_scale;

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

		status_effect_timers[_status_type] -= gameplay_time_scale;

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

	soul_chain_timer -= gameplay_time_scale;

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

	// Funeral Pause stasis blocks all incoming damage until its bell releases this unit.
	if (doom_bell_stasis_is_active())
	{
		return 0;
	}

	// The Roar still allows damage but prevents a surviving squad member from dying.
	var _minimum_hp = 0;

	if (global.day_phase == DAY_PHASE.NIGHT
		&& unit_faction == UNIT_FACTION.FRIENDLY
		&& unholy_abyss_immortality_timer > 0)
	{
		_minimum_hp = min(1, hp);

		if (hp <= _minimum_hp)
		{
			return 0;
		}
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

	// Apply next-night damage bonuses at the shared unit damage entry point.
	var _source_is_unit = instance_exists(_source_instance)
		&& variable_instance_exists(_source_instance, "unit_faction");

	if (global.day_phase == DAY_PHASE.NIGHT
		&& _source_is_unit
		&& global.ritual_blood_night_active)
	{
		_damage_amount *= BALANCE_RITUAL_BLOOD_NIGHT_DAMAGE_MULTIPLIER;
	}

	if (global.day_phase == DAY_PHASE.NIGHT
		&& _source_is_unit
		&& global.ritual_hell_weakest_active
		&& variable_instance_exists(_source_instance, "squad")
		&& is_struct(_source_instance.squad)
		&& _source_instance.squad != global.ritual_hell_weakest_squad)
	{
		_damage_amount *= BALANCE_RITUAL_HELL_WEAKEST_DAMAGE_MULTIPLIER;
	}

	// The Power of Twilight modifies every damage path that identifies its source unit.
	if (_source_is_unit
		&& variable_instance_exists(_source_instance, "squad")
		&& squad_unholy_power_twilight_is_active(_source_instance.squad))
	{
		_damage_amount *= BALANCE_UNHOLY_SHRINE_TWILIGHT_DAMAGE_MULTIPLIER;
	}

	// An Abyss mark accepts bonus damage only from the squad that created that mark.
	if (global.day_phase == DAY_PHASE.NIGHT
		&& _source_is_unit
		&& unit_faction == UNIT_FACTION.ENEMY
		&& variable_instance_exists(_source_instance, "squad")
		&& is_struct(_source_instance.squad)
		&& unholy_abyss_mark_has_squad(_source_instance.squad))
	{
		_damage_amount *= BALANCE_UNHOLY_SHRINE_ROAR_DAMAGE_MULTIPLIER;
	}

	if (global.day_phase == DAY_PHASE.NIGHT
		&& global.ritual_awaken_taint_active
		&& unit_faction == UNIT_FACTION.ENEMY
		&& unit_is_on_tainted_ground())
	{
		_damage_amount *= BALANCE_RITUAL_AWAKEN_TAINT_DAMAGE_TAKEN_MULTIPLIER;
	}

	var _applied_damage = min(_damage_amount, max(0, hp - _minimum_hp));
	hp = max(hp - _damage_amount, _minimum_hp);
	damage_flash_timer = damage_flash_duration;

	// The Roar reacts as soon as the squad's combined HP falls below half.
	if (unit_faction == UNIT_FACTION.FRIENDLY && is_struct(squad))
	{
		squad_unholy_roar_try(squad);
	}

	// Taking damage permanently ends the fast approach for this night attacker.
	if (unit_faction == UNIT_FACTION.ENEMY && is_night_attack_unit)
	{
		enemy_march_stop();
	}

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

	if (_can_trigger_soul_chain)
	{
		// Idle units retaliate against the hostile instance that damaged them.
		var _has_combat_target = target_can_be_attacked(target_instance);
		var _source_has_faction = instance_exists(_source_instance)
			&& variable_instance_exists(_source_instance, "unit_faction");
		var _source_faction_is_hostile = _source_faction != UNIT_FACTION.NOONE
			&& _source_faction != unit_faction;
		var _source_instance_is_hostile = _source_has_faction
			&& _source_instance.unit_faction != unit_faction;
		var _source_is_player_structure = unit_faction == UNIT_FACTION.ENEMY
			&& player_structure_can_be_targeted(_source_instance);
		var _source_is_hostile = instance_exists(_source_instance)
			&& (_source_faction_is_hostile
				|| _source_instance_is_hostile
				|| _source_is_player_structure);

		if (!_has_combat_target
			&& _source_is_hostile
			&& target_can_be_attacked(_source_instance))
		{
			target_instance = _source_instance;
			alert_target = _source_instance;
			alert_target_timer = alert_target_time;
			target_search_update_timer = target_search_update_interval;
		}

		// Share the attacker with nearby idle allies of the damaged unit.
		if (_source_is_hostile && target_can_be_attacked(_source_instance))
		{
			var _damage_alert_radius_squared = sqr(BALANCE_UNIT_DAMAGE_ALERT_RADIUS);
			var _unit_count = instance_number(o_units_parent);

			for (var _unit_index = 0; _unit_index < _unit_count; ++_unit_index)
			{
				var _ally = instance_find(o_units_parent, _unit_index);

				if (!instance_exists(_ally)
					|| _ally == id
					|| !variable_instance_exists(_ally, "unit_faction")
					|| _ally.unit_faction != unit_faction
					|| !variable_instance_exists(_ally, "hp")
					|| _ally.hp <= 0
					|| _ally.target_can_be_attacked(_ally.target_instance))
				{
					continue;
				}

				var _ally_distance_x = _ally.x - x;
				var _ally_distance_y = _ally.y - y;
				var _ally_distance_squared = (_ally_distance_x * _ally_distance_x)
					+ (_ally_distance_y * _ally_distance_y);

				if (_ally_distance_squared > _damage_alert_radius_squared)
				{
					continue;
				}

				_ally.target_instance = _source_instance;
				_ally.alert_target = _source_instance;
				_ally.alert_target_timer = _ally.alert_target_time;
				_ally.target_search_update_timer = _ally.target_search_update_interval;
			}
		}

		unit_damage_received(_source_instance, _source_faction, _applied_damage);
	}

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

unholy_boiling_blood_death_explosion_apply = function()
{
	if (unit_faction != UNIT_FACTION.FRIENDLY
		|| !is_struct(squad)
		|| squad_unholy_trait_get(squad) != UNHOLY_TRAIT.BOILING_BLOOD)
	{
		return;
	}

	var _enemy_list = ds_list_create();
	var _enemy_count = collision_circle_list(
		x,
		y,
		BALANCE_UNHOLY_SHRINE_BOILING_BLOOD_EXPLOSION_RADIUS,
		o_enemy_units,
		false,
		true,
		_enemy_list,
		false
	);

	for (var _enemy_index = 0; _enemy_index < _enemy_count; ++_enemy_index)
	{
		var _enemy = _enemy_list[| _enemy_index];

		if (target_can_be_attacked(_enemy)
			&& variable_instance_exists(_enemy, "unit_damage_receive"))
		{
			_enemy.unit_damage_receive(
				BALANCE_UNHOLY_SHRINE_BOILING_BLOOD_EXPLOSION_DAMAGE,
				UNIT_FACTION.FRIENDLY,
				false,
				true,
				id
			);
		}
	}

	ds_list_destroy(_enemy_list);
	instance_create_layer(x, y, "Instances", o_particle_explosion);
};

unholy_abyss_mark_apply = function(_source_squad, _duration_frames)
{
	if (!is_struct(_source_squad) || _duration_frames <= 0)
	{
		return false;
	}

	// Refresh a mark from the same squad without removing marks from other Roar squads.
	for (var _mark_index = 0; _mark_index < array_length(unholy_abyss_marks); ++_mark_index)
	{
		var _mark = unholy_abyss_marks[_mark_index];

		if (_mark.squad == _source_squad)
		{
			_mark.timer = max(_mark.timer, _duration_frames);
			return true;
		}
	}

	array_push(unholy_abyss_marks, {
		squad: _source_squad,
		timer: _duration_frames
	});
	return true;
};

unholy_abyss_mark_has_squad = function(_source_squad)
{
	if (!is_struct(_source_squad))
	{
		return false;
	}

	for (var _mark_index = 0; _mark_index < array_length(unholy_abyss_marks); ++_mark_index)
	{
		var _mark = unholy_abyss_marks[_mark_index];

		if (_mark.timer > 0 && _mark.squad == _source_squad)
		{
			return true;
		}
	}

	return false;
};

unholy_abyss_effects_update = function()
{
	// Roar effects cannot persist outside the night in which they triggered.
	if (global.day_phase != DAY_PHASE.NIGHT)
	{
		unholy_abyss_immortality_timer = 0;
		unholy_abyss_marks = [];
		return;
	}

	if (unholy_abyss_immortality_timer > 0)
	{
		unholy_abyss_immortality_timer = max(
			0,
			unholy_abyss_immortality_timer - gameplay_time_scale
		);
	}

	for (var _mark_index = array_length(unholy_abyss_marks) - 1; _mark_index >= 0; --_mark_index)
	{
		var _mark = unholy_abyss_marks[_mark_index];
		_mark.timer -= gameplay_time_scale;

		if (_mark.timer <= 0)
		{
			array_delete(unholy_abyss_marks, _mark_index, 1);
		}
	}
};

unholy_trait_aura_update = function()
{
	var _aura_effect = UNHOLY_TRAIT.NONE;
	var _aura_color = c_white;
	var _aura_alpha = 1;
	var _aura_scale = 1;
	var _aura_pulse_amount = 0;
	var _aura_pulse_speed = 0;

	// Marked enemies use a compact purple aura while the squad uses its yellow body overlay.
	if (unit_faction == UNIT_FACTION.ENEMY && hp > 0 && array_length(unholy_abyss_marks) > 0)
	{
		_aura_effect = UNHOLY_TRAIT.ROAR_OF_THE_ABYSS;
		_aura_color = COLOR_UNHOLY_ROAR_OF_THE_ABYSS;
		_aura_alpha = BALANCE_UNHOLY_SHRINE_ROAR_MARK_ALPHA;
		_aura_scale = BALANCE_UNHOLY_SHRINE_ROAR_MARK_SCALE;
		_aura_pulse_amount = BALANCE_UNHOLY_SHRINE_ROAR_AURA_PULSE_AMOUNT;
		_aura_pulse_speed = BALANCE_UNHOLY_SHRINE_ROAR_AURA_PULSE_SPEED;
	}
	else if (unit_faction == UNIT_FACTION.FRIENDLY
		&& hp > 0
		&& is_struct(squad)
		&& squad_unholy_power_twilight_is_active(squad))
	{
		_aura_effect = UNHOLY_TRAIT.POWER_OF_TWILIGHT;
		_aura_color = COLOR_UNHOLY_POWER_OF_TWILIGHT;
		_aura_alpha = BALANCE_UNHOLY_SHRINE_TWILIGHT_AURA_ALPHA;
		_aura_scale = BALANCE_UNHOLY_SHRINE_TWILIGHT_AURA_SCALE;
	}

	if (_aura_effect == UNHOLY_TRAIT.NONE)
	{
		if (instance_exists(unholy_aura_instance))
		{
			with (unholy_aura_instance)
			{
				instance_destroy();
			}
		}

		unholy_aura_instance = noone;
		return;
	}

	if (!instance_exists(unholy_aura_instance))
	{
		var _aura_layer_name = layer_get_id("Instances_1") != -1
			? "Instances_1"
			: "Instances";
		unholy_aura_instance = instance_create_layer(x, y, _aura_layer_name, o_aura);
	}

	if (instance_exists(unholy_aura_instance))
	{
		unholy_aura_instance.aura_owner = id;
		unholy_aura_instance.aura_effect = _aura_effect;
		unholy_aura_instance.aura_color = _aura_color;
		unholy_aura_instance.aura_alpha = _aura_alpha;
		unholy_aura_instance.aura_scale_x = _aura_scale;
		unholy_aura_instance.aura_scale_y = _aura_scale;
		unholy_aura_instance.aura_pulse_amount = _aura_pulse_amount;
		unholy_aura_instance.aura_pulse_speed = _aura_pulse_speed;
	}
};

unholy_savage_leap_target_find = function()
{
	var _nearest_target = noone;
	var _nearest_distance = BALANCE_UNHOLY_SHRINE_SAVAGE_LEAP_MAX_RADIUS;
	var _enemy_count = instance_number(o_enemy_units);

	for (var _enemy_index = 0; _enemy_index < _enemy_count; ++_enemy_index)
	{
		var _enemy = instance_find(o_enemy_units, _enemy_index);

		if (!target_can_be_attacked(_enemy))
		{
			continue;
		}

		var _enemy_distance = point_distance(x, y, _enemy.x, _enemy.y);

		if (_enemy_distance > BALANCE_UNHOLY_SHRINE_SAVAGE_LEAP_MIN_RADIUS
			&& _enemy_distance <= _nearest_distance)
		{
			_nearest_target = _enemy;
			_nearest_distance = _enemy_distance;
		}
	}

	return _nearest_target;
};

unholy_savage_leap_start = function(_target)
{
	if (!instance_exists(_target))
	{
		return false;
	}

	unholy_savage_leap_active = true;
	unholy_savage_leap_flight_timer = 0;
	unholy_savage_leap_start_x = x;
	unholy_savage_leap_start_y = y;
	unholy_savage_leap_end_x = _target.x;
	unholy_savage_leap_end_y = _target.y;
	unholy_savage_leap_target = _target;
	visual_offset_is_ability_controlled = true;
	target_instance = noone;
	is_attacking_target = false;
	is_walking = false;
	face_world_x(_target.x);

	return true;
};

unholy_savage_leap_cancel_for_march = function()
{
	if (!unholy_savage_leap_active)
	{
		return false;
	}

	// A player move order takes priority and leaves the unit at its current ground position.
	unholy_savage_leap_active = false;
	unholy_savage_leap_cooldown_timer = BALANCE_UNHOLY_SHRINE_SAVAGE_LEAP_COOLDOWN
		* room_speed;
	unholy_savage_leap_search_timer = 0;
	unholy_savage_leap_target = noone;
	visual_offset_is_ability_controlled = false;
	visual_attack_offset_x = 0;
	visual_attack_offset_y = 0;
	target_instance = noone;
	is_attacking_target = false;

	return true;
};

unholy_savage_leap_update = function()
{
	if (unholy_savage_leap_active)
	{
		unholy_savage_leap_flight_timer += gameplay_time_scale;
		var _flight_progress = clamp(
			unholy_savage_leap_flight_timer / unholy_savage_leap_flight_duration,
			0,
			1
		);

		x = lerp(unholy_savage_leap_start_x, unholy_savage_leap_end_x, _flight_progress);
		y = lerp(unholy_savage_leap_start_y, unholy_savage_leap_end_y, _flight_progress);
		visual_attack_offset_x = 0;
		visual_attack_offset_y = -sin(_flight_progress * pi)
			* BALANCE_UNHOLY_SHRINE_SAVAGE_LEAP_ARC_HEIGHT;
		is_attacking_target = false;
		is_walking = false;

		if (_flight_progress >= 1)
		{
			unholy_savage_leap_active = false;
			unholy_savage_leap_cooldown_timer = BALANCE_UNHOLY_SHRINE_SAVAGE_LEAP_COOLDOWN
				* room_speed;
			unholy_savage_leap_search_timer = 0;
			visual_offset_is_ability_controlled = false;
			visual_attack_offset_x = 0;
			visual_attack_offset_y = 0;

			if (target_can_be_attacked(unholy_savage_leap_target))
			{
				target_instance = unholy_savage_leap_target;
			}

			unholy_savage_leap_target = noone;
		}

		return true;
	}

	if (unholy_savage_leap_cooldown_timer > 0)
	{
		unholy_savage_leap_cooldown_timer = max(
			0,
			unholy_savage_leap_cooldown_timer - gameplay_time_scale
		);
	}

	var _can_start = unholy_savage_leap_cooldown_timer <= 0
		&& unit_faction == UNIT_FACTION.FRIENDLY
		&& global.day_phase == DAY_PHASE.NIGHT
		&& is_struct(squad)
		&& !squad_is_marching(squad)
		&& squad_unholy_trait_get(squad) == UNHOLY_TRAIT.SAVAGE_LEAP
		&& attack_radius <= BALANCE_UNIT_MELEE_DAMAGE_RADIUS_MAX
		&& !is_stunned
		&& !is_being_dragged
		&& !cultist_projectile_deploy_assigned
		&& !cultist_projectile_deploy_waiting;

	if (!_can_start)
	{
		return false;
	}

	if (unholy_savage_leap_search_timer > 0)
	{
		unholy_savage_leap_search_timer = max(
			0,
			unholy_savage_leap_search_timer - gameplay_time_scale
		);
		return false;
	}

	var _leap_target = unholy_savage_leap_target_find();
	unholy_savage_leap_search_timer = max(
		1,
		BALANCE_UNHOLY_SHRINE_SAVAGE_LEAP_SEARCH_INTERVAL * room_speed
	);

	return unholy_savage_leap_start(_leap_target);
};

player_death_explosion_apply = function()
{
	if (unit_faction != UNIT_FACTION.FRIENDLY
		|| !variable_global_exists("player_death_explosion_active")
		|| !global.player_death_explosion_active)
	{
		return;
	}

	var _explosion_damage = max_hp * BALANCE_DAY_THREE_DEATH_EXPLOSION_MAX_HP_SHARE;
	var _enemy_list = ds_list_create();
	var _enemy_count = collision_circle_list(
		x,
		y,
		BALANCE_DAY_THREE_DEATH_EXPLOSION_RADIUS,
		o_enemy_units,
		false,
		true,
		_enemy_list,
		false
	);

	for (var _enemy_index = 0; _enemy_index < _enemy_count; ++_enemy_index)
	{
		var _enemy = _enemy_list[| _enemy_index];

		if (target_can_be_attacked(_enemy)
			&& variable_instance_exists(_enemy, "unit_damage_receive"))
		{
			_enemy.unit_damage_receive(
				_explosion_damage,
				UNIT_FACTION.FRIENDLY,
				false,
				true,
				id
			);
		}
	}

	ds_list_destroy(_enemy_list);
	instance_create_layer(x, y, "Instances", o_particle_explosion);
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
	// Balance tests only need combat results and skip normal drops and corpse systems.
	if (balance_test_match_id >= 0)
	{
		instance_destroy();
		return;
	}

	if (instance_exists(o_game_controller))
	{
		var _game_controller = instance_find(o_game_controller, 0);

		if (variable_instance_exists(_game_controller, "cannon_corpse_worker_drop"))
		{
			_game_controller.cannon_corpse_worker_drop(id);
		}
	}

	// The Roar checks the squad after this fallen unit has reached zero HP.
	if (unit_faction == UNIT_FACTION.FRIENDLY && is_struct(squad))
	{
		squad_unholy_roar_try(squad);
	}

	if (is_demon_form_unit() || object_index == o_archdemon)
	{
		if (!is_knocked_out)
		{
			unit_death_sound_play();
			unholy_boiling_blood_death_explosion_apply();
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
	unholy_boiling_blood_death_explosion_apply();
	player_death_explosion_apply();
	unit_corpse_snapshot_create();
	soul_chain_death_effect_apply();
	warlock_soul_engine_enemy_death_notify();
	warlock_skeleton_death_effect_apply();
	status_effect_death_rewards_try();
	meat_drop_try();

	// Endless Procession and the daybreak upgrade share one Bonelet replacement roll.
	var _bonelet_resurrection_chance = 0;

	if (unit_faction == UNIT_FACTION.FRIENDLY
		&& is_struct(squad)
		&& squad_unholy_trait_get(squad) == UNHOLY_TRAIT.ENDLESS_PROCESSION)
	{
		_bonelet_resurrection_chance = BALANCE_UNHOLY_SHRINE_ENDLESS_PROCESSION_CHANCE;
	}

	if (unit_faction == UNIT_FACTION.FRIENDLY
		&& variable_global_exists("player_unit_bonelet_resurrection_active")
		&& global.player_unit_bonelet_resurrection_active)
	{
		_bonelet_resurrection_chance = max(
			_bonelet_resurrection_chance,
			BALANCE_EARLY_UPGRADE_BONELET_RESURRECTION_CHANCE
		);
	}

	if (_bonelet_resurrection_chance > 0 && random(1) < _bonelet_resurrection_chance)
	{
		squad_unit_resurrect_as_bonelet(id);
	}

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

	knockout_timer -= gameplay_time_scale;

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
		&& object_index != o_archdemon;
};

is_summoned_unit = function()
{
	return variable_instance_exists(id, "summon_nights_remaining")
		|| (variable_instance_exists(id, "squad")
			&& is_struct(squad)
			&& squad.squad_type != SQUAD_TYPE.ARCHDEMON);
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

ranged_unit_melee_flee_on_damage = function(_source_instance)
{
	if (hp <= 0
		|| !instance_exists(_source_instance)
		|| !variable_instance_exists(_source_instance, "unit_faction")
		|| _source_instance.unit_faction == unit_faction
		|| !variable_instance_exists(_source_instance, "attack_radius")
		|| _source_instance.attack_radius > BALANCE_UNIT_MELEE_DAMAGE_RADIUS_MAX)
	{
		return;
	}

	panic_flee_apply(
		_source_instance,
		BALANCE_RANGED_UNIT_MELEE_FLEE_DURATION,
		BALANCE_RANGED_UNIT_MELEE_FLEE_COOLDOWN,
		BALANCE_RANGED_UNIT_MELEE_FLEE_SPEED_MULTIPLIER
	);
};

panic_flee_update = function()
{
	if (panic_flee_timer <= 0)
	{
		panic_flee_source = noone;
		return false;
	}

	panic_flee_timer -= gameplay_time_scale;

	if (!target_can_be_attacked(panic_flee_source))
	{
		panic_flee_timer = 0;
		panic_flee_source = noone;
		return false;
	}

	var _flee_direction = point_direction(panic_flee_source.x, panic_flee_source.y, x, y);
	var _current_move_speed = move_speed
		* unit_move_speed_multiplier_get()
		* panic_flee_speed_multiplier
		* gameplay_time_scale;

	if (point_distance(x, y, panic_flee_source.x, panic_flee_source.y) <= 0)
	{
		_flee_direction = irandom(359);
	}

	is_walking = true;
	face_world_x(x + lengthdir_x(1, _flee_direction));
	move_with_wall_collision(
		lengthdir_x(_current_move_speed, _flee_direction),
		lengthdir_y(_current_move_speed, _flee_direction)
	);

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
	var _current_move_speed = move_speed
		* unit_move_speed_multiplier_get()
		* forced_retreat_speed_multiplier
		* gameplay_time_scale;

	if (_retreat_distance <= max(_current_move_speed, 8))
	{
		instance_destroy();
		return true;
	}

	var _retreat_direction = point_direction(x, y, forced_retreat_target_x, forced_retreat_target_y);
	var _move_distance = min(_current_move_speed, _retreat_distance);

	is_walking = true;
	face_world_x(forced_retreat_target_x);
	move_with_wall_collision(
		lengthdir_x(_move_distance, _retreat_direction),
		lengthdir_y(_move_distance, _retreat_direction)
	);

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

// Unit subclasses may react after incoming damage has been applied.
unit_damage_received = function(_source_instance, _source_faction, _applied_damage)
{
};

unit_damage_modifier_get = function(_target, _is_magic_damage)
{
	return 1;
};

// Friendly unit subclasses may override this to prefer a specific enemy role.
friendly_priority_target_find = function(_max_distance)
{
	return noone;
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

find_nearest_enemy_unit_target = function(_max_distance)
{
	var _nearest_target = noone;
	var _nearest_distance_squared = _max_distance * _max_distance;
	var _enemy_count = instance_number(o_enemy_units);
	var _use_switch_margin = false;

	// Keep the current enemy-unit target when it is still nearby.
	for (var _enemy_index = 0; _enemy_index < _enemy_count; ++_enemy_index)
	{
		var _enemy = instance_find(o_enemy_units, _enemy_index);

		if (_enemy != target_instance || !target_can_be_attacked(_enemy))
		{
			continue;
		}

		var _current_distance_x = _enemy.x - x;
		var _current_distance_y = _enemy.y - y;
		var _current_distance_squared = (_current_distance_x * _current_distance_x)
			+ (_current_distance_y * _current_distance_y);

		if (_current_distance_squared <= _nearest_distance_squared)
		{
			_nearest_target = _enemy;
			_nearest_distance_squared = _current_distance_squared;
			_use_switch_margin = true;
		}

		break;
	}

	// Switch only when another enemy is clearly closer than the current one.
	for (var _enemy_index = 0; _enemy_index < _enemy_count; ++_enemy_index)
	{
		var _enemy = instance_find(o_enemy_units, _enemy_index);

		if (_enemy == _nearest_target || !target_can_be_attacked(_enemy))
		{
			continue;
		}

		var _enemy_distance_x = _enemy.x - x;
		var _enemy_distance_y = _enemy.y - y;
		var _enemy_distance_squared = (_enemy_distance_x * _enemy_distance_x)
			+ (_enemy_distance_y * _enemy_distance_y);

		if (target_candidate_should_replace(
			_enemy_distance_squared,
			_nearest_distance_squared,
			_use_switch_margin
		))
		{
			_nearest_target = _enemy;
			_nearest_distance_squared = _enemy_distance_squared;
			_use_switch_margin = false;
		}
	}

	return _nearest_target;
};

target_is_player_unit = function(_target)
{
	if (!instance_exists(_target))
	{
		return false;
	}

	if (_target.object_index == o_archdemon)
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

	if (!variable_global_exists("archdemons"))
	{
		return _nearest_target;
	}

	var _cultist_count = array_length(global.archdemons);

	// Cultists are player units but are not children of o_friendly_units.
	for (var _cultist_index = 0; _cultist_index < _cultist_count; ++_cultist_index)
	{
		var _cultist = global.archdemons[_cultist_index];

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

	// Sweet Rot is acquired only through its local attraction rule, not normal route interception.
	if (_structure.object_index == o_taint_shell_tumor)
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

taint_shell_tumor_is_valid = function(_target)
{
	return target_can_be_attacked(_target)
		&& _target.object_index == o_taint_shell_tumor;
};

first_aid_meat_fresh_target_is_valid = function(_target)
{
	if (!target_can_be_attacked(_target)
		|| _target.object_index != o_first_aid_meat
		|| !variable_instance_exists(_target, "first_aid_meat_enchantment")
		|| _target.first_aid_meat_enchantment != FIRST_AID_MEAT_ENCHANTMENT.FRESH_MEAT)
	{
		return false;
	}

	// Deterministic balance matches must not attract enemies from another simulated match.
	if (variable_instance_exists(_target, "balance_test_match_id")
		&& _target.balance_test_match_id >= 0
		&& (!variable_instance_exists(id, "balance_test_match_id")
			|| balance_test_match_id != _target.balance_test_match_id))
	{
		return false;
	}

	return true;
};

first_aid_meat_fresh_target_find = function()
{
	// Once attracted, keep attacking the same meat while it survives.
	if (first_aid_meat_fresh_target_is_valid(target_instance))
	{
		return target_instance;
	}

	var _nearest_meat = noone;
	var _nearest_distance_squared = infinity;
	var _meat_count = instance_number(o_first_aid_meat);

	for (var _meat_index = 0; _meat_index < _meat_count; ++_meat_index)
	{
		var _meat = instance_find(o_first_aid_meat, _meat_index);

		if (!first_aid_meat_fresh_target_is_valid(_meat))
		{
			continue;
		}

		var _distance_x = _meat.x - x;
		var _distance_y = _meat.y - y;
		var _distance_squared = (_distance_x * _distance_x) + (_distance_y * _distance_y);
		var _smell_radius = variable_instance_exists(_meat, "fresh_smell_radius")
			? _meat.fresh_smell_radius
			: BALANCE_FIRST_AID_MEAT_FRESH_SMELL_RADIUS;
		var _smell_radius_squared = _smell_radius * _smell_radius;

		if (_distance_squared <= _smell_radius_squared
			&& _distance_squared < _nearest_distance_squared)
		{
			_nearest_meat = _meat;
			_nearest_distance_squared = _distance_squared;
		}
	}

	return _nearest_meat;
};

taint_shell_tumor_target_find = function()
{
	// Once lured, finish attacking the same tumor while it survives.
	if (taint_shell_tumor_is_valid(target_instance))
	{
		return target_instance;
	}

	var _nearest_tumor = noone;
	var _nearest_distance_squared = infinity;
	var _tumor_count = instance_number(o_taint_shell_tumor);

	for (var _tumor_index = 0; _tumor_index < _tumor_count; ++_tumor_index)
	{
		var _tumor = instance_find(o_taint_shell_tumor, _tumor_index);

		if (!taint_shell_tumor_is_valid(_tumor))
		{
			continue;
		}

		var _distance_x = _tumor.x - x;
		var _distance_y = _tumor.y - y;
		var _distance_squared = (_distance_x * _distance_x) + (_distance_y * _distance_y);
		var _attraction_radius = variable_instance_exists(_tumor, "attraction_radius")
			? _tumor.attraction_radius
			: BALANCE_TAINT_COMPOST_SWEET_ROT_RADIUS;
		var _attraction_radius_squared = _attraction_radius * _attraction_radius;

		if (_distance_squared <= _attraction_radius_squared
			&& _distance_squared < _nearest_distance_squared)
		{
			_nearest_tumor = _tumor;
			_nearest_distance_squared = _distance_squared;
		}
	}

	return _nearest_tumor;
};

player_settlement_building_can_be_targeted = function(_building)
{
	return target_can_be_attacked(_building)
		&& variable_instance_exists(_building, "player_building_distance_to_point");
};

player_structure_can_be_targeted = function(_structure)
{
	return player_map_structure_can_be_targeted(_structure)
		|| player_settlement_building_can_be_targeted(_structure);
};

find_player_building_on_cannon_path = function()
{
	if (!instance_exists(o_cannon))
	{
		return noone;
	}

	var _cannon = instance_find(o_cannon, 0);
	var _nearest_building = noone;
	var _nearest_distance_squared = infinity;
	var _settlement_building_count = instance_number(o_v13buildings_parent);

	// Settlement buildings intercept enemies only when their collision mask crosses the route to the cannon.
	for (var _building_index = 0; _building_index < _settlement_building_count; ++_building_index)
	{
		var _building = instance_find(o_v13buildings_parent, _building_index);

		if (!player_settlement_building_can_be_targeted(_building)
			|| collision_line(x, y, _cannon.x, _cannon.y, _building, false, true) == noone)
		{
			continue;
		}

		var _building_distance_x = _building.x - x;
		var _building_distance_y = _building.y - y;
		var _building_distance_squared = (_building_distance_x * _building_distance_x)
			+ (_building_distance_y * _building_distance_y);

		if (_building_distance_squared < _nearest_distance_squared)
		{
			_nearest_building = _building;
			_nearest_distance_squared = _building_distance_squared;
		}
	}

	var _map_structure_count = instance_number(o_map_objects_parent);

	// Player-owned field structures use the same interception rule.
	for (var _structure_index = 0; _structure_index < _map_structure_count; ++_structure_index)
	{
		var _structure = instance_find(o_map_objects_parent, _structure_index);

		if (!player_map_structure_can_be_targeted(_structure)
			|| collision_line(x, y, _cannon.x, _cannon.y, _structure, false, true) == noone)
		{
			continue;
		}

		var _structure_distance_x = _structure.x - x;
		var _structure_distance_y = _structure.y - y;
		var _structure_distance_squared = (_structure_distance_x * _structure_distance_x)
			+ (_structure_distance_y * _structure_distance_y);

		if (_structure_distance_squared < _nearest_distance_squared)
		{
			_nearest_building = _structure;
			_nearest_distance_squared = _structure_distance_squared;
		}
	}

	return _nearest_building;
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

	var _settlement_building_count = instance_number(o_v13buildings_parent);

	for (var _building_index = 0; _building_index < _settlement_building_count; ++_building_index)
	{
		var _building = instance_find(o_v13buildings_parent, _building_index);

		if (!player_settlement_building_can_be_targeted(_building))
		{
			continue;
		}

		var _building_distance_x = _building.x - x;
		var _building_distance_y = _building.y - y;
		var _building_distance_squared = (_building_distance_x * _building_distance_x)
			+ (_building_distance_y * _building_distance_y);

		if (_building_distance_squared <= _nearest_distance_squared)
		{
			_nearest_target = _building;
			_nearest_distance_squared = _building_distance_squared;
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

	// Pick the closest enemy that is actively attacking the cannon.
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

find_nearest_enemy_object_from_point = function(_origin_x, _origin_y, _max_distance)
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
				var _tower_distance_x = _tower.x - _origin_x;
				var _tower_distance_y = _tower.y - _origin_y;
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
				var _shrine_distance_x = _shrine.x - _origin_x;
				var _shrine_distance_y = _shrine.y - _origin_y;
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
				var _garnizon_distance_x = _garnizon.x - _origin_x;
				var _garnizon_distance_y = _garnizon.y - _origin_y;
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
				var _house_distance_x = _house.x - _origin_x;
				var _house_distance_y = _house.y - _origin_y;
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

find_nearest_enemy_object = function(_max_distance)
{
	return find_nearest_enemy_object_from_point(x, y, _max_distance);
};

find_nearest_visible_cultist = function()
{
	var _nearest_cultist = noone;
	var _nearest_distance_squared = infinity;
	var _cultist_count = array_length(global.archdemons);

	for (var _cultist_index = 0; _cultist_index < _cultist_count; ++_cultist_index)
	{
		var _cultist = global.archdemons[_cultist_index];

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

move_with_wall_collision = function(_move_x, _move_y, _navigation_grid = noone)
{
	if (_move_x == 0 && _move_y == 0)
	{
		return false;
	}

	var _largest_move_component = max(abs(_move_x), abs(_move_y));
	var _move_step_count = max(1, ceil(_largest_move_component / BALANCE_WALL_COLLISION_MOVE_STEP));
	var _move_step_x = _move_x / _move_step_count;
	var _move_step_y = _move_y / _move_step_count;
	var _has_moved = false;

	// Short substeps prevent knockback and accelerated movement from tunneling through walls.
	for (var _move_step_index = 0; _move_step_index < _move_step_count; ++_move_step_index)
	{
		var _next_x = x + _move_step_x;
		var _next_y = y + _move_step_y;
		var _combined_position_is_blocked = _navigation_grid != noone
			? navigation_grid_position_is_blocked(_navigation_grid, _next_x, _next_y)
			: place_meeting(_next_x, _next_y, o_wall_parent);

		if (!_combined_position_is_blocked)
		{
			x = _next_x;
			y = _next_y;
			_has_moved = true;
			continue;
		}

		// Axis checks let units slide along a wall instead of vibrating against it.
		var _horizontal_position_is_blocked = _navigation_grid != noone
			? navigation_grid_position_is_blocked(_navigation_grid, _next_x, y)
			: place_meeting(_next_x, y, o_wall_parent);

		if (_move_step_x != 0
			&& !_horizontal_position_is_blocked)
		{
			x = _next_x;
			_has_moved = true;
		}

		var _vertical_position_is_blocked = _navigation_grid != noone
			? navigation_grid_position_is_blocked(_navigation_grid, x, _next_y)
			: place_meeting(x, _next_y, o_wall_parent);

		if (_move_step_y != 0
			&& !_vertical_position_is_blocked)
		{
			y = _next_y;
			_has_moved = true;
		}
	}

	return _has_moved;
};

navigation_path_resource_get = function()
{
	if (navigation_path == noone)
	{
		navigation_path = path_add();
	}

	return navigation_path;
};

navigation_path_state_clear = function()
{
	if (navigation_path != noone)
	{
		path_clear_points(navigation_path);
	}

	navigation_has_path = false;
	navigation_has_direct_route = false;
	navigation_path_failed = false;
	navigation_path_point_index = 0;
	navigation_retry_timer = 0;
};

navigation_target_distance_get = function(_target)
{
	if (!instance_exists(_target))
	{
		return infinity;
	}

	if (variable_instance_exists(_target, "is_wall")
		&& _target.is_wall
		&& variable_instance_exists(_target, "wall_distance_to_point"))
	{
		return _target.wall_distance_to_point(x, y);
	}

	// The Cannon uses a circular combat footprint instead of its large sprite center.
	if (_target.object_index == o_cannon
		&& variable_instance_exists(_target, "combat_radius"))
	{
		var _center_distance = point_distance(x, y, _target.x, _target.y);
		return max(0, _center_distance - _target.combat_radius);
	}

	// Settlement buildings expose the same edge distance to navigation and attacks.
	if (variable_instance_exists(_target, "player_building_distance_to_point"))
	{
		return _target.player_building_distance_to_point(x, y);
	}

	return point_distance(x, y, _target.x, _target.y);
};

navigation_path_result_store = function(_target, _goal_x, _goal_y, _grid_version, _path_was_built, _has_direct_route = false)
{
	navigation_target = _target;
	navigation_target_position_x = _goal_x;
	navigation_target_position_y = _goal_y;

	if (instance_exists(_target))
	{
		navigation_target_position_x = _target.x;
		navigation_target_position_y = _target.y;
	}

	navigation_goal_x = _goal_x;
	navigation_goal_y = _goal_y;
	navigation_grid_version = _grid_version;
	navigation_has_path = _path_was_built;
	navigation_has_direct_route = _has_direct_route;
	navigation_path_failed = !_path_was_built && !_has_direct_route;
	navigation_path_point_index = 0;
	navigation_retry_timer = navigation_path_failed ? navigation_retry_interval : 0;

	return _path_was_built || _has_direct_route;
};

navigation_grid_get = function()
{
	if (!instance_exists(o_game_controller))
	{
		return noone;
	}

	var _game_controller = instance_find(o_game_controller, 0);

	if (!variable_instance_exists(_game_controller, "wall_navigation_grid_get"))
	{
		return noone;
	}

	return _game_controller.wall_navigation_grid_get();
};

navigation_grid_position_is_blocked = function(_navigation_grid, _position_x, _position_y)
{
	var _cell_x = floor(_position_x / BALANCE_WALL_NAVIGATION_CELL_SIZE);
	var _cell_y = floor(_position_y / BALANCE_WALL_NAVIGATION_CELL_SIZE);

	return mp_grid_get_cell(_navigation_grid, _cell_x, _cell_y) == -1;
};

navigation_grid_line_is_clear = function(_navigation_grid, _start_x, _start_y, _goal_x, _goal_y)
{
	var _line_distance = point_distance(_start_x, _start_y, _goal_x, _goal_y);
	var _sample_step = BALANCE_WALL_NAVIGATION_CELL_SIZE * BALANCE_WALL_NAVIGATION_LINE_SAMPLE_SCALE;
	var _sample_count = max(1, ceil(_line_distance / _sample_step));

	// Half-cell samples prevent a segment from skipping an occupied cell.
	for (var _sample_index = 0; _sample_index <= _sample_count; ++_sample_index)
	{
		var _sample_progress = _sample_index / _sample_count;
		var _sample_x = lerp(_start_x, _goal_x, _sample_progress);
		var _sample_y = lerp(_start_y, _goal_y, _sample_progress);
		if (navigation_grid_position_is_blocked(_navigation_grid, _sample_x, _sample_y))
		{
			return false;
		}
	}

	return true;
};

navigation_grid_free_position_get = function(
	_navigation_grid,
	_position_x,
	_position_y,
	_require_clear_line,
	_search_radius = BALANCE_WALL_NAVIGATION_FREE_CELL_SEARCH_RADIUS
)
{
	var _cell_size = BALANCE_WALL_NAVIGATION_CELL_SIZE;
	var _horizontal_cell_count = ceil(room_width / _cell_size);
	var _vertical_cell_count = ceil(room_height / _cell_size);
	var _origin_cell_x = clamp(floor(_position_x / _cell_size), 0, _horizontal_cell_count - 1);
	var _origin_cell_y = clamp(floor(_position_y / _cell_size), 0, _vertical_cell_count - 1);

	if (mp_grid_get_cell(_navigation_grid, _origin_cell_x, _origin_cell_y) == 0)
	{
		return [true, _position_x, _position_y];
	}

	var _best_x = _position_x;
	var _best_y = _position_y;
	var _best_distance_squared = infinity;
	var _position_was_found = false;

	// Search a bounded square around blocked start or goal cells.
	for (var _radius = 1; _radius <= _search_radius; ++_radius)
	{
		for (var _offset_y = -_radius; _offset_y <= _radius; ++_offset_y)
		{
			for (var _offset_x = -_radius; _offset_x <= _radius; ++_offset_x)
			{
				if (abs(_offset_x) != _radius && abs(_offset_y) != _radius)
				{
					continue;
				}

				var _cell_x = _origin_cell_x + _offset_x;
				var _cell_y = _origin_cell_y + _offset_y;

				if (_cell_x < 0
					|| _cell_x >= _horizontal_cell_count
					|| _cell_y < 0
					|| _cell_y >= _vertical_cell_count
					|| mp_grid_get_cell(_navigation_grid, _cell_x, _cell_y) == -1)
				{
					continue;
				}

				var _candidate_x = min((_cell_x + 0.5) * _cell_size, room_width - 1);
				var _candidate_y = min((_cell_y + 0.5) * _cell_size, room_height - 1);

				if (_require_clear_line
					&& collision_line(
							_position_x,
							_position_y,
							_candidate_x,
							_candidate_y,
							o_wall_parent,
							false,
							true
						) != noone)
				{
					continue;
				}

				var _distance_x = _candidate_x - _position_x;
				var _distance_y = _candidate_y - _position_y;
				var _distance_squared = (_distance_x * _distance_x) + (_distance_y * _distance_y);

				if (_distance_squared < _best_distance_squared)
				{
					_best_x = _candidate_x;
					_best_y = _candidate_y;
					_best_distance_squared = _distance_squared;
					_position_was_found = true;
				}
			}
		}
	}

	return [_position_was_found, _best_x, _best_y];
};

navigation_grid_path_build = function(_navigation_grid, _path, _goal_x, _goal_y)
{
	var _start_position = navigation_grid_free_position_get(_navigation_grid, x, y, true);
	var _goal_position = navigation_grid_free_position_get(_navigation_grid, _goal_x, _goal_y, false);

	if (!_start_position[0] || !_goal_position[0])
	{
		path_clear_points(_path);
		return [false, _goal_x, _goal_y];
	}

	path_clear_points(_path);
	var _path_was_built = mp_grid_path(
		_navigation_grid,
		_path,
		_start_position[1],
		_start_position[2],
		_goal_position[1],
		_goal_position[2],
		true
	);

	return [_path_was_built, _goal_position[1], _goal_position[2]];
};

navigation_position_is_safe = function(_navigation_grid, _position_x, _position_y)
{
	if (_navigation_grid != noone)
	{
		return !navigation_grid_position_is_blocked(_navigation_grid, _position_x, _position_y);
	}

	return !place_meeting(_position_x, _position_y, o_wall_parent);
};

navigation_last_safe_position_store = function(_navigation_grid)
{
	if (!navigation_position_is_safe(_navigation_grid, x, y))
	{
		return false;
	}

	navigation_last_safe_x = x;
	navigation_last_safe_y = y;
	navigation_has_safe_position = true;

	return true;
};

navigation_recover_if_blocked = function(_navigation_grid = noone)
{
	if (_navigation_grid == noone)
	{
		_navigation_grid = navigation_grid_get();
	}

	if (_navigation_grid == noone)
	{
		return false;
	}

	if (navigation_last_safe_position_store(_navigation_grid))
	{
		return false;
	}

	var _recovery_position_found = false;
	var _recovery_x = x;
	var _recovery_y = y;
	var _last_safe_max_distance = BALANCE_WALL_NAVIGATION_RECOVERY_SEARCH_RADIUS
		* BALANCE_WALL_NAVIGATION_CELL_SIZE;

	// Prefer the most recent position that was confirmed by both the grid and collision mask.
	if (navigation_has_safe_position
		&& point_distance(x, y, navigation_last_safe_x, navigation_last_safe_y) <= _last_safe_max_distance
		&& navigation_position_is_safe(
			_navigation_grid,
			navigation_last_safe_x,
			navigation_last_safe_y
		))
	{
		_recovery_position_found = true;
		_recovery_x = navigation_last_safe_x;
		_recovery_y = navigation_last_safe_y;
	}
	else
	{
		var _nearest_free_position = navigation_grid_free_position_get(
			_navigation_grid,
			x,
			y,
			false,
			BALANCE_WALL_NAVIGATION_RECOVERY_SEARCH_RADIUS
		);

		if (_nearest_free_position[0])
		{
			_recovery_position_found = true;
			_recovery_x = _nearest_free_position[1];
			_recovery_y = _nearest_free_position[2];
		}
	}

	if (!_recovery_position_found)
	{
		return false;
	}

	// Recovery is an exceptional snap that restores a valid origin before normal AI resumes.
	x = _recovery_x;
	y = _recovery_y;
	navigation_last_safe_x = x;
	navigation_last_safe_y = y;
	navigation_has_safe_position = true;
	separation_push_x = 0;
	separation_push_y = 0;
	is_walking = false;
	navigation_path_state_clear();
	navigation_grid_version = -1;

	return true;
};

navigation_recovery_update = function()
{
	if (forced_retreat_active || is_being_dragged)
	{
		return false;
	}

	navigation_recovery_check_timer += gameplay_time_scale;

	if (navigation_recovery_check_timer < navigation_recovery_check_interval)
	{
		return false;
	}

	navigation_recovery_check_timer -= navigation_recovery_check_interval;

	var _navigation_grid = navigation_grid_get();

	if (_navigation_grid == noone)
	{
		return false;
	}

	if (navigation_last_safe_position_store(_navigation_grid))
	{
		return false;
	}

	return navigation_recover_if_blocked(_navigation_grid);
};

unit_forced_displacement_apply = function(_move_x, _move_y)
{
	if (_move_x == 0 && _move_y == 0)
	{
		return false;
	}

	var _navigation_grid = navigation_grid_get();

	if (_navigation_grid != noone)
	{
		navigation_recover_if_blocked(_navigation_grid);
		navigation_last_safe_position_store(_navigation_grid);
	}

	// Swept movement stops or slides at occupied cells instead of jumping through them.
	var _has_moved = move_with_wall_collision(_move_x, _move_y, _navigation_grid);

	if (_has_moved)
	{
		navigation_path_state_clear();
		navigation_grid_version = -1;

		if (_navigation_grid != noone)
		{
			navigation_last_safe_position_store(_navigation_grid);
		}
	}

	// This fallback also repairs units displaced by legacy or future direct coordinate writes.
	if (_navigation_grid != noone)
	{
		navigation_recover_if_blocked(_navigation_grid);
	}

	return _has_moved;
};

navigation_target_prepare = function(_target, _attack_radius)
{
	if (!target_can_be_attacked(_target))
	{
		return false;
	}

	// A target already in range does not require a movement route.
	if (navigation_target_distance_get(_target) <= _attack_radius)
	{
		navigation_path_state_clear();
		navigation_target = _target;
		navigation_target_position_x = _target.x;
		navigation_target_position_y = _target.y;
		navigation_goal_x = _target.x;
		navigation_goal_y = _target.y;
		return true;
	}

	if (instance_number(o_wall_parent) <= 0)
	{
		navigation_path_state_clear();
		navigation_target = _target;
		navigation_target_position_x = _target.x;
		navigation_target_position_y = _target.y;
		navigation_goal_x = _target.x;
		navigation_goal_y = _target.y;
		return true;
	}

	if (!instance_exists(o_game_controller))
	{
		return false;
	}

	var _game_controller = instance_find(o_game_controller, 0);

	if (!variable_instance_exists(_game_controller, "wall_navigation_grid_get"))
	{
		return false;
	}

	var _navigation_grid = _game_controller.wall_navigation_grid_get();
	var _grid_version = _game_controller.wall_navigation_grid_version;
	var _target_is_wall = variable_instance_exists(_target, "is_wall") && _target.is_wall;
	var _same_target = navigation_target == _target;
	var _target_move_distance = point_distance(
		navigation_target_position_x,
		navigation_target_position_y,
		_target.x,
		_target.y
	);
	var _cached_path_is_current = _same_target
		&& navigation_grid_version == _grid_version
		&& _target_move_distance <= BALANCE_WALL_NAVIGATION_REBUILD_DISTANCE;
	var _failed_path_is_waiting = _same_target
		&& navigation_grid_version == _grid_version
		&& navigation_path_failed
		&& navigation_retry_timer > 0;

	if (_failed_path_is_waiting)
	{
		return false;
	}

	if (_cached_path_is_current
		&& (navigation_has_path || navigation_has_direct_route))
	{
		return true;
	}

	// Direct movement is allowed only when the same MP grid used for paths is clear.
	if (!_target_is_wall
		&& navigation_grid_line_is_clear(_navigation_grid, x, y, _target.x, _target.y))
	{
		navigation_path_state_clear();
		return navigation_path_result_store(
			_target,
			_target.x,
			_target.y,
			_grid_version,
			false,
			true
		);
	}

	var _path = navigation_path_resource_get();

	if (!_target_is_wall)
	{
		var _path_result = navigation_grid_path_build(_navigation_grid, _path, _target.x, _target.y);
		return navigation_path_result_store(
			_target,
			_path_result[1],
			_path_result[2],
			_grid_version,
			_path_result[0]
		);
	}

	var _goal_candidates = _target.wall_navigation_goal_candidates_get(x, y, _attack_radius);
	var _goal_candidate_count = array_length(_goal_candidates);
	var _goal_candidate_checked = array_create(_goal_candidate_count, false);

	// Try the closest wall side first, then the remaining sides if it is blocked by adjacent walls.
	for (var _goal_attempt = 0; _goal_attempt < _goal_candidate_count; ++_goal_attempt)
	{
		var _nearest_goal_index = -1;
		var _nearest_goal_distance = infinity;

		for (var _goal_index = 0; _goal_index < _goal_candidate_count; ++_goal_index)
		{
			if (_goal_candidate_checked[_goal_index])
			{
				continue;
			}

			var _goal = _goal_candidates[_goal_index];
			var _goal_distance = point_distance(x, y, _goal.x, _goal.y);

			if (_goal_distance < _nearest_goal_distance)
			{
				_nearest_goal_index = _goal_index;
				_nearest_goal_distance = _goal_distance;
			}
		}

		if (_nearest_goal_index < 0)
		{
			break;
		}

		_goal_candidate_checked[_nearest_goal_index] = true;
		var _selected_goal = _goal_candidates[_nearest_goal_index];
		var _path_result = navigation_grid_path_build(
			_navigation_grid,
			_path,
			_selected_goal.x,
			_selected_goal.y
		);

		if (_path_result[0])
		{
			return navigation_path_result_store(
				_target,
				_path_result[1],
				_path_result[2],
				_grid_version,
				true
			);
		}
	}

	path_clear_points(_path);
	return navigation_path_result_store(_target, _target.x, _target.y, _grid_version, false);
};

navigation_world_point_prepare = function(_target_x, _target_y)
{
	if (instance_number(o_wall_parent) <= 0)
	{
		navigation_path_state_clear();
		navigation_target = noone;
		navigation_target_position_x = _target_x;
		navigation_target_position_y = _target_y;
		navigation_goal_x = _target_x;
		navigation_goal_y = _target_y;
		return true;
	}

	if (!instance_exists(o_game_controller))
	{
		return false;
	}

	var _game_controller = instance_find(o_game_controller, 0);

	if (!variable_instance_exists(_game_controller, "wall_navigation_grid_get"))
	{
		return false;
	}

	var _navigation_grid = _game_controller.wall_navigation_grid_get();
	var _grid_version = _game_controller.wall_navigation_grid_version;
	var _target_move_distance = point_distance(
		navigation_target_position_x,
		navigation_target_position_y,
		_target_x,
		_target_y
	);
	var _same_target = navigation_target == noone
		&& _target_move_distance <= BALANCE_WALL_NAVIGATION_REBUILD_DISTANCE;
	var _cached_path_is_current = _same_target
		&& navigation_grid_version == _grid_version;
	var _failed_path_is_waiting = _cached_path_is_current
		&& navigation_path_failed
		&& navigation_retry_timer > 0;

	if (_failed_path_is_waiting)
	{
		return false;
	}

	if (_cached_path_is_current
		&& (navigation_has_path || navigation_has_direct_route))
	{
		return true;
	}

	// Point movement uses the exact same occupied-cell data as generated paths.
	if (navigation_grid_line_is_clear(_navigation_grid, x, y, _target_x, _target_y))
	{
		navigation_path_state_clear();
		return navigation_path_result_store(
			noone,
			_target_x,
			_target_y,
			_grid_version,
			false,
			true
		);
	}

	var _path = navigation_path_resource_get();
	var _path_result = navigation_grid_path_build(_navigation_grid, _path, _target_x, _target_y);

	return navigation_path_result_store(
		noone,
		_path_result[1],
		_path_result[2],
		_grid_version,
		_path_result[0]
	);
};

navigation_path_move = function(_current_move_speed)
{
	if (!navigation_has_path || navigation_path == noone)
	{
		return false;
	}

	var _path_point_count = path_get_number(navigation_path);

	// Skip path points already reached by this unit.
	for (var _path_point_check = navigation_path_point_index; _path_point_check < _path_point_count; ++_path_point_check)
	{
		var _point_x = path_get_point_x(navigation_path, navigation_path_point_index);
		var _point_y = path_get_point_y(navigation_path, navigation_path_point_index);
		var _point_distance = point_distance(x, y, _point_x, _point_y);

		if (_point_distance > max(BALANCE_WALL_NAVIGATION_POINT_ARRIVE_RADIUS, _current_move_speed))
		{
			break;
		}

		navigation_path_point_index++;
	}

	var _move_target_x = navigation_goal_x;
	var _move_target_y = navigation_goal_y;

	if (navigation_path_point_index < _path_point_count)
	{
		_move_target_x = path_get_point_x(navigation_path, navigation_path_point_index);
		_move_target_y = path_get_point_y(navigation_path, navigation_path_point_index);
	}

	var _move_distance = point_distance(x, y, _move_target_x, _move_target_y);

	if (_move_distance <= 0)
	{
		return false;
	}

	var _move_direction = point_direction(x, y, _move_target_x, _move_target_y);
	var _move_amount = min(_current_move_speed, _move_distance);
	var _navigation_grid = navigation_grid_get();
	var _has_moved = move_with_wall_collision(
		lengthdir_x(_move_amount, _move_direction),
		lengthdir_y(_move_amount, _move_direction),
		_navigation_grid
	);

	if (!_has_moved)
	{
		navigation_has_path = false;
		navigation_path_failed = true;
		navigation_retry_timer = navigation_retry_interval;
	}

	return _has_moved;
};

friendly_enemy_structure_can_be_targeted = function(_target)
{
	if (!target_can_be_attacked(_target)
		|| (variable_instance_exists(_target, "is_wall") && _target.is_wall))
	{
		return false;
	}

	return _target.object_index == o_holy_tower
		|| _target.object_index == o_shrine
		|| _target.object_index == o_garnizon
		|| _target.object_index == o_house;
};

find_nearest_reachable_enemy_target = function(_max_distance)
{
	var _candidate_queue = ds_priority_create();
	var _maximum_distance_squared = _max_distance * _max_distance;
	var _enemy_count = instance_number(o_enemy_units);

	for (var _enemy_index = 0; _enemy_index < _enemy_count; ++_enemy_index)
	{
		var _enemy = instance_find(o_enemy_units, _enemy_index);

		if (!target_can_be_attacked(_enemy))
		{
			continue;
		}

		var _enemy_distance_x = _enemy.x - x;
		var _enemy_distance_y = _enemy.y - y;
		var _enemy_distance_squared = (_enemy_distance_x * _enemy_distance_x)
			+ (_enemy_distance_y * _enemy_distance_y);

		if (_enemy_distance_squared <= _maximum_distance_squared)
		{
			ds_priority_add(_candidate_queue, _enemy, _enemy_distance_squared);
		}
	}

	var _structure_count = instance_number(o_map_objects_parent);

	for (var _structure_index = 0; _structure_index < _structure_count; ++_structure_index)
	{
		var _structure = instance_find(o_map_objects_parent, _structure_index);

		if (!friendly_enemy_structure_can_be_targeted(_structure))
		{
			continue;
		}

		var _structure_distance_x = _structure.x - x;
		var _structure_distance_y = _structure.y - y;
		var _structure_distance_squared = (_structure_distance_x * _structure_distance_x)
			+ (_structure_distance_y * _structure_distance_y);

		if (_structure_distance_squared <= _maximum_distance_squared)
		{
			ds_priority_add(_candidate_queue, _structure, _structure_distance_squared);
		}
	}

	var _candidate_count = ds_priority_size(_candidate_queue);

	for (var _candidate_index = 0; _candidate_index < _candidate_count; ++_candidate_index)
	{
		var _candidate = ds_priority_delete_min(_candidate_queue);

		if (navigation_target_prepare(_candidate, attack_radius))
		{
			ds_priority_destroy(_candidate_queue);
			return _candidate;
		}
	}

	ds_priority_destroy(_candidate_queue);
	return noone;
};

find_nearest_reachable_enemy_wall = function(_max_distance)
{
	var _candidate_queue = ds_priority_create();
	var _maximum_distance_squared = _max_distance * _max_distance;
	var _wall_count = instance_number(o_wall_enemy);

	for (var _wall_index = 0; _wall_index < _wall_count; ++_wall_index)
	{
		var _wall = instance_find(o_wall_enemy, _wall_index);

		if (!target_can_be_attacked(_wall))
		{
			continue;
		}

		var _wall_distance_x = _wall.x - x;
		var _wall_distance_y = _wall.y - y;
		var _wall_distance_squared = (_wall_distance_x * _wall_distance_x)
			+ (_wall_distance_y * _wall_distance_y);

		if (_wall_distance_squared <= _maximum_distance_squared)
		{
			ds_priority_add(_candidate_queue, _wall, _wall_distance_squared);
		}
	}

	var _candidate_count = ds_priority_size(_candidate_queue);

	for (var _candidate_index = 0; _candidate_index < _candidate_count; ++_candidate_index)
	{
		var _candidate = ds_priority_delete_min(_candidate_queue);

		if (navigation_target_prepare(_candidate, attack_radius))
		{
			ds_priority_destroy(_candidate_queue);
			return _candidate;
		}
	}

	ds_priority_destroy(_candidate_queue);
	return noone;
};

move_towards_target = function(_target, _navigation_arrive_radius = attack_radius)
{
	if (!instance_exists(_target) || !navigation_target_prepare(_target, _navigation_arrive_radius))
	{
		return;
	}

	var _current_move_speed = move_speed * unit_move_speed_multiplier_get() * gameplay_time_scale;
	var _has_moved = false;

	face_world_x(_target.x);

	if (navigation_has_path)
	{
		_has_moved = navigation_path_move(_current_move_speed);
	}
	else
	{
		var _target_direction = point_direction(x, y, navigation_goal_x, navigation_goal_y);
		var _navigation_grid = navigation_grid_get();
		_has_moved = move_with_wall_collision(
			lengthdir_x(_current_move_speed, _target_direction),
			lengthdir_y(_current_move_speed, _target_direction),
			_navigation_grid
		);
	}

	is_walking = _has_moved;
};

move_towards_world_point = function(_target_x, _target_y)
{
	if (!navigation_world_point_prepare(_target_x, _target_y))
	{
		is_walking = false;
		return;
	}

	var _current_move_speed = move_speed * unit_move_speed_multiplier_get() * gameplay_time_scale;
	var _has_moved = false;

	face_world_x(_target_x);

	if (navigation_has_path)
	{
		_has_moved = navigation_path_move(_current_move_speed);
	}
	else
	{
		var _target_direction = point_direction(x, y, navigation_goal_x, navigation_goal_y);
		var _navigation_grid = navigation_grid_get();
		_has_moved = move_with_wall_collision(
			lengthdir_x(_current_move_speed, _target_direction),
			lengthdir_y(_current_move_speed, _target_direction),
			_navigation_grid
		);
	}

	is_walking = _has_moved;
};

attack_ring_should_use = function(_target, _attack_radius)
{
	if (unit_faction != UNIT_FACTION.ENEMY
		|| !instance_exists(_target)
		|| _target.object_index == o_cannon
		|| _target == guard_target
		|| (variable_instance_exists(_target, "is_wall") && _target.is_wall)
		|| variable_instance_exists(_target, "player_building_distance_to_point")
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

	walk_sway_timer += gameplay_time_scale / max(1, room_speed);

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
	var _return_amount = (attack_lunge_distance / _return_time) * gameplay_time_scale;
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
	separation_update_timer += gameplay_time_scale;

	if (separation_update_timer < separation_update_interval)
	{
		return;
	}

	separation_update_timer -= separation_update_interval;

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

	var _push_x = separation_push_x * _separation_multiplier * gameplay_time_scale;
	var _push_y = separation_push_y * _separation_multiplier * gameplay_time_scale;

	if (_push_x == 0 && _push_y == 0)
	{
		return;
	}

	var _route_target_x = navigation_goal_x;
	var _route_target_y = navigation_goal_y;
	var _has_navigation_route = is_walking && (navigation_has_path || navigation_has_direct_route);

	if (_has_navigation_route
		&& navigation_has_path
		&& navigation_path != noone
		&& navigation_path_point_index < path_get_number(navigation_path))
	{
		_route_target_x = path_get_point_x(navigation_path, navigation_path_point_index);
		_route_target_y = path_get_point_y(navigation_path, navigation_path_point_index);
	}

	// Separation may move sideways, but it must never cancel progress along the route.
	if (_has_navigation_route)
	{
		var _route_x = _route_target_x - x;
		var _route_y = _route_target_y - y;
		var _route_distance = point_distance(x, y, _route_target_x, _route_target_y);

		if (_route_distance > 0)
		{
			var _forward_x = _route_x / _route_distance;
			var _forward_y = _route_y / _route_distance;
			var _forward_push = (_push_x * _forward_x) + (_push_y * _forward_y);

			if (_forward_push < 0)
			{
				_push_x -= _forward_x * _forward_push;
				_push_y -= _forward_y * _forward_push;
			}
		}
	}

	if (_push_x == 0 && _push_y == 0)
	{
		return;
	}

	var _navigation_grid = noone;
	var _start_cell_x = floor(x / BALANCE_WALL_NAVIGATION_CELL_SIZE);
	var _start_cell_y = floor(y / BALANCE_WALL_NAVIGATION_CELL_SIZE);

	if (instance_number(o_wall_parent) > 0 && instance_exists(o_game_controller))
	{
		var _game_controller = instance_find(o_game_controller, 0);

		if (variable_instance_exists(_game_controller, "wall_navigation_grid_get"))
		{
			_navigation_grid = _game_controller.wall_navigation_grid_get();
		}
	}

	if (_navigation_grid != noone)
	{
		// Do not let crowd pressure trap a recovering unit deeper inside an occupied cell.
		if (navigation_grid_position_is_blocked(_navigation_grid, x, y))
		{
			return;
		}

		var _combined_position_is_blocked = navigation_grid_position_is_blocked(
			_navigation_grid,
			x + _push_x,
			y + _push_y
		);

		if (_combined_position_is_blocked)
		{
			var _horizontal_position_is_blocked = navigation_grid_position_is_blocked(
				_navigation_grid,
				x + _push_x,
				y
			);
			var _vertical_position_is_blocked = navigation_grid_position_is_blocked(
				_navigation_grid,
				x,
				y + _push_y
			);

			if (!_horizontal_position_is_blocked && !_vertical_position_is_blocked)
			{
				if (abs(_push_x) >= abs(_push_y))
				{
					_push_y = 0;
				}
				else
				{
					_push_x = 0;
				}
			}
			else if (!_horizontal_position_is_blocked)
			{
				_push_y = 0;
			}
			else if (!_vertical_position_is_blocked)
			{
				_push_x = 0;
			}
			else
			{
				return;
			}
		}
	}

	var _separation_has_moved = move_with_wall_collision(_push_x, _push_y, _navigation_grid);

	if (!_separation_has_moved || _navigation_grid == noone || !_has_navigation_route)
	{
		return;
	}

	var _end_cell_x = floor(x / BALANCE_WALL_NAVIGATION_CELL_SIZE);
	var _end_cell_y = floor(y / BALANCE_WALL_NAVIGATION_CELL_SIZE);

	if (_end_cell_x == _start_cell_x && _end_cell_y == _start_cell_y)
	{
		return;
	}

	// A cell-changing side push can invalidate the cached segment around a wall corner.
	if (!navigation_grid_line_is_clear(_navigation_grid, x, y, _route_target_x, _route_target_y))
	{
		navigation_has_path = false;
		navigation_has_direct_route = false;
		navigation_path_failed = false;
		navigation_grid_version = -1;
		navigation_retry_timer = 0;
	}
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
		reload_timer -= gameplay_time_scale;
		return;
	}

	// Dead Silence prevents ranged attacks while allowing movement and reload recovery.
	if (attack_radius > BALANCE_DOOM_BELL_RANGED_ATTACK_RADIUS_MINIMUM
		&& doom_bell_silence_is_active())
	{
		is_attacking_target = false;
		return;
	}

	// Physical and magic components are calculated independently before being combined.
	var _raw_physical_damage = damage * next_attack_damage_multiplier;
	var _raw_magic_damage = magic_damage * next_attack_damage_multiplier;

	if (variable_instance_exists(id, "unit_damage_modifier_get"))
	{
		_raw_physical_damage *= unit_damage_modifier_get(_target, false);
		_raw_magic_damage *= unit_damage_modifier_get(_target, true);
	}

	var _is_critical_hit = false;
	var _current_crit_chance = unit_crit_chance_get();

	if (_current_crit_chance > 0 && random(1) < _current_crit_chance)
	{
		var _critical_damage_multiplier = unit_crit_damage_get();
		_raw_physical_damage *= _critical_damage_multiplier;
		_raw_magic_damage *= _critical_damage_multiplier;
		_is_critical_hit = true;
	}

	var _damage_amount = physical_damage_after_armor(_raw_physical_damage, _target)
		+ magic_damage_after_resistance(_raw_magic_damage, _target);
	var _target_hp_before_hit = 0;
	var _target_hit_x = _target.x;
	var _target_hit_y = _target.y;

	if (variable_instance_exists(_target, "hp"))
	{
		_target_hp_before_hit = _target.hp;
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
		var _aoe_feedback_enabled = variable_instance_exists(id, "unit_aoe_attack_feedback_show");
		var _aoe_hit_positions = [];

		if (_aoe_feedback_enabled)
		{
			array_push(_aoe_hit_positions, { x: _target_hit_x, y: _target_hit_y });
		}

		if (unit_faction == UNIT_FACTION.ENEMY)
		{
			_aoe_object = o_friendly_units;
		}

		var _aoe_list = ds_list_create();
		var _aoe_range = aoe_radius * next_attack_radius_multiplier;
		var _aoe_count = collision_circle_list(_target_hit_x, _target_hit_y, _aoe_range, _aoe_object, false, true, _aoe_list, true);
		var _attack_targets_hit = 1; // The primary target was already hit.

		for (var _aoe_index = 0; _aoe_index < _aoe_count; ++_aoe_index)
		{
			if (attack_target_count > 0 && _attack_targets_hit >= attack_target_count)
			{
				break;
			}

			var _aoe_target = _aoe_list[| _aoe_index];

			if (target_can_be_attacked(_aoe_target) && _aoe_target != _target && variable_instance_exists(_aoe_target, "hp"))
			{
				var _aoe_target_x = _aoe_target.x;
				var _aoe_target_y = _aoe_target.y;
				var _aoe_damage_amount = physical_damage_after_armor(_raw_physical_damage, _aoe_target)
					+ magic_damage_after_resistance(_raw_magic_damage, _aoe_target);

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

				_attack_targets_hit++;

				if (_aoe_feedback_enabled)
				{
					array_push(_aoe_hit_positions, { x: _aoe_target_x, y: _aoe_target_y });
				}
			}
		}

		ds_list_destroy(_aoe_list);

		if (_aoe_feedback_enabled)
		{
			unit_aoe_attack_feedback_show(_target_hit_x, _target_hit_y, _aoe_range, _aoe_hit_positions);
		}
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
