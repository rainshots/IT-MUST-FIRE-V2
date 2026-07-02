// Initialize shared enemy unit state.
event_inherited();

// Griffith is a boss enemy with mixed damage, area attacks, summons, and chained leaps.
max_hp = BALANCE_BOSS_GRIFFITH_HP;
hp = max_hp;
armor = BALANCE_BOSS_GRIFFITH_ARMOR;
magic_resistance = BALANCE_BOSS_GRIFFITH_MAGIC_RESISTANCE;
damage = BALANCE_BOSS_GRIFFITH_DAMAGE * 0.5;
magic_damage = BALANCE_BOSS_GRIFFITH_DAMAGE * 0.5;
reload_time = BALANCE_BOSS_GRIFFITH_RELOAD_TIME * room_speed;
attack_radius = BALANCE_BOSS_GRIFFITH_ATTACK_RADIUS;
cannon_attack_radius = BALANCE_BOSS_GRIFFITH_CANNON_ATTACK_RADIUS;
move_speed = BALANCE_BOSS_GRIFFITH_MOVE_SPEED;
aoe_radius = BALANCE_BOSS_GRIFFITH_AOE_RADIUS;
target_detection_radius = BALANCE_UNIT_VISION_RADIUS;
vision_radius = BALANCE_UNIT_VISION_RADIUS;
image_xscale = 1.35;
image_yscale = image_xscale;

// Passive timers.
griffith_ground_cleanse_timer = irandom(max(1, BALANCE_BOSS_GRIFFITH_GROUND_CLEANSE_INTERVAL - 1));
griffith_summon_timer = BALANCE_BOSS_GRIFFITH_SUMMON_INTERVAL * room_speed;

// Chained leap state mirrors Imp's active jump pattern with boss-owned targeting.
griffith_leap_timer = BALANCE_BOSS_GRIFFITH_LEAP_COOLDOWN * room_speed;
griffith_leap_retry_timer = 0;
griffith_leap_is_active = false;
griffith_leap_jump_count = 0;
griffith_leap_max_jump_count = BALANCE_BOSS_GRIFFITH_LEAP_COUNT;
griffith_leap_home_x = x;
griffith_leap_home_y = y;
griffith_leap_flight_timer = 0;
griffith_leap_flight_duration = max(1, BALANCE_BOSS_GRIFFITH_LEAP_ANIMATION_TIME * room_speed);
griffith_leap_flight_start_x = x;
griffith_leap_flight_start_y = y;
griffith_leap_flight_end_x = x;
griffith_leap_flight_end_y = y;
griffith_leap_target = noone;
griffith_leap_is_returning = false;
griffith_leap_hit_targets = [];
griffith_leap_visual_segments = [];

griffith_target_is_in_array = function(_target, _target_array)
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

griffith_ground_cleanse_update = function()
{
	griffith_ground_cleanse_timer--;

	if (griffith_ground_cleanse_timer > 0)
	{
		return;
	}

	griffith_ground_cleanse_timer = BALANCE_BOSS_GRIFFITH_GROUND_CLEANSE_INTERVAL;

	if (!instance_exists(o_corruption_grid))
	{
		return;
	}

	var _corruption_grid = instance_find(o_corruption_grid, 0);
	_corruption_grid.cleanse_circle(
		x,
		y,
		BALANCE_BOSS_GRIFFITH_GROUND_CLEANSE_RADIUS,
		BALANCE_BOSS_GRIFFITH_GROUND_CLEANSE_AMOUNT
	);
};

griffith_spawn_knight = function(_spawn_x, _spawn_y)
{
	var _knight = instance_create_layer(_spawn_x, _spawn_y, "Instances", o_enemy_knight);

	if (!instance_exists(_knight))
	{
		return noone;
	}

	_knight.unit_can_attack_cannon = true;
	_knight.is_night_attack_unit = is_night_attack_unit;
	_knight.owner_garnizon = noone;
	_knight.guard_target = noone;

	if (instance_exists(o_game_controller))
	{
		var _game_controller = instance_find(o_game_controller, 0);

		if (variable_instance_exists(_game_controller, "enemy_night_hp_scale_apply"))
		{
			_game_controller.enemy_night_hp_scale_apply(_knight);
		}
	}

	if (is_night_attack_unit && variable_global_exists("night_attack_unit_count"))
	{
		global.night_attack_unit_count++;
	}

	return _knight;
};

griffith_summon_update = function()
{
	griffith_summon_timer--;

	if (griffith_summon_timer > 0)
	{
		return;
	}

	griffith_summon_timer = BALANCE_BOSS_GRIFFITH_SUMMON_INTERVAL * room_speed;

	for (var _knight_index = 0; _knight_index < BALANCE_BOSS_GRIFFITH_SUMMON_KNIGHT_COUNT; ++_knight_index)
	{
		var _spawn_direction = random(360);
		var _spawn_distance = random_range(
			BALANCE_BOSS_GRIFFITH_SUMMON_RADIUS_MIN,
			BALANCE_BOSS_GRIFFITH_SUMMON_RADIUS_MAX
		);
		var _spawn_x = x + lengthdir_x(_spawn_distance, _spawn_direction);
		var _spawn_y = y + lengthdir_y(_spawn_distance, _spawn_direction);

		griffith_spawn_knight(_spawn_x, _spawn_y);
	}
};

griffith_mixed_damage_target = function(_target, _is_critical_hit)
{
	if (!target_can_be_attacked(_target) || !variable_instance_exists(_target, "hp"))
	{
		return false;
	}

	var _target_hp_before_hit = _target.hp;
	var _physical_damage = damage;
	var _magic_damage = magic_damage;

	if (_is_critical_hit)
	{
		var _crit_damage = unit_crit_damage_get();
		_physical_damage *= _crit_damage;
		_magic_damage *= _crit_damage;
	}

	_physical_damage = physical_damage_after_armor(_physical_damage, _target);
	_magic_damage = magic_damage_after_resistance(_magic_damage, _target);
	var _final_damage = _physical_damage + _magic_damage;

	if (variable_instance_exists(_target, "unit_damage_receive"))
	{
		_target.unit_damage_receive(_final_damage, unit_faction, _is_critical_hit);
	}
	else
	{
		_target.hp = max(_target.hp - _final_damage, 0);

		if (variable_instance_exists(_target, "unit_faction"))
		{
			damage_popup_create(_target.x, _target.y, _final_damage, _target.unit_faction, _is_critical_hit);
		}
	}

	var _target_was_killed = _target_hp_before_hit > 0 && _target.hp <= 0;
	unit_attack_landed(_target, _is_critical_hit, _target_was_killed);
	return _target_was_killed;
};

griffith_yellow_smoke_create = function(_origin_x, _origin_y, _radius)
{
	for (var _smoke_index = 0; _smoke_index < BALANCE_BOSS_GRIFFITH_AOE_SMOKE_COUNT; ++_smoke_index)
	{
		var _smoke_direction = random(360);
		var _smoke_distance = sqrt(random(1)) * _radius;
		var _smoke_x = _origin_x + lengthdir_x(_smoke_distance, _smoke_direction);
		var _smoke_y = _origin_y + lengthdir_y(_smoke_distance, _smoke_direction);
		var _smoke = instance_create_layer(_smoke_x, _smoke_y, "Instances", o_particle_smoke);

		if (instance_exists(_smoke))
		{
			_smoke.smoke_color = COLOR_PROJECTILE_CLEANSE;
		}
	}
};

griffith_damage_targets_in_radius = function(_origin_x, _origin_y, _radius, _excluded_target)
{
	var _friendly_count = instance_number(o_friendly_units);

	for (var _friendly_index = 0; _friendly_index < _friendly_count; ++_friendly_index)
	{
		var _friendly_target = instance_find(o_friendly_units, _friendly_index);

		if (_friendly_target != _excluded_target
			&& point_distance(_origin_x, _origin_y, _friendly_target.x, _friendly_target.y) <= _radius)
		{
			griffith_mixed_damage_target(_friendly_target, false);
		}
	}

	var _structure_count = instance_number(o_map_objects_parent);

	for (var _structure_index = 0; _structure_index < _structure_count; ++_structure_index)
	{
		var _structure_target = instance_find(o_map_objects_parent, _structure_index);

		if (_structure_target != _excluded_target
			&& player_map_structure_can_be_targeted(_structure_target)
			&& point_distance(_origin_x, _origin_y, _structure_target.x, _structure_target.y) <= _radius)
		{
			griffith_mixed_damage_target(_structure_target, false);
		}
	}

	if (instance_exists(o_cannon))
	{
		var _cannon = instance_find(o_cannon, 0);

		if (_cannon != _excluded_target
			&& target_can_be_attacked(_cannon)
			&& point_distance(_origin_x, _origin_y, _cannon.x, _cannon.y) <= _radius)
		{
			griffith_mixed_damage_target(_cannon, false);
		}
	}
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

	var _is_critical_hit = false;
	var _current_crit_chance = unit_crit_chance_get();

	if (_current_crit_chance > 0 && random(1) < _current_crit_chance)
	{
		_is_critical_hit = true;
	}

	griffith_mixed_damage_target(_target, _is_critical_hit);
	start_attack_lunge(_target);
	griffith_yellow_smoke_create(_target.x, _target.y, aoe_radius);
	griffith_damage_targets_in_radius(_target.x, _target.y, aoe_radius, _target);

	attack_feedback_target = _target;
	attack_feedback_target_x = _target.x;
	attack_feedback_target_y = _target.y;
	attack_feedback_timer = attack_feedback_time;
	reload_timer = reload_time * unit_attack_reload_multiplier_get();
};

griffith_find_farthest_leap_target = function()
{
	var _best_target = noone;
	var _best_distance = -1;
	var _friendly_count = instance_number(o_friendly_units);

	for (var _friendly_index = 0; _friendly_index < _friendly_count; ++_friendly_index)
	{
		var _target = instance_find(o_friendly_units, _friendly_index);

		if (!target_can_be_attacked(_target)
			|| griffith_target_is_in_array(_target, griffith_leap_hit_targets))
		{
			continue;
		}

		var _target_distance = point_distance(x, y, _target.x, _target.y);

		if (_target_distance <= BALANCE_BOSS_GRIFFITH_LEAP_SEARCH_RADIUS
			&& _target_distance > _best_distance)
		{
			_best_target = _target;
			_best_distance = _target_distance;
		}
	}

	return _best_target;
};

griffith_leap_visual_start = function(_end_x, _end_y)
{
	var _segment_duration = max(1, griffith_leap_flight_duration * 2.4);

	array_push(
		griffith_leap_visual_segments,
		{
			start_x: x,
			start_y: y,
			end_x: _end_x,
			end_y: _end_y,
			timer: _segment_duration,
			duration: _segment_duration
		}
	);
};

griffith_leap_flight_start = function(_end_x, _end_y, _target, _is_returning)
{
	griffith_leap_flight_duration = max(1, BALANCE_BOSS_GRIFFITH_LEAP_ANIMATION_TIME * room_speed);
	griffith_leap_flight_timer = griffith_leap_flight_duration;
	griffith_leap_flight_start_x = x;
	griffith_leap_flight_start_y = y;
	griffith_leap_flight_end_x = _end_x;
	griffith_leap_flight_end_y = _end_y;
	griffith_leap_target = _target;
	griffith_leap_is_returning = _is_returning;
	visual_offset_is_ability_controlled = true;
	griffith_leap_visual_start(_end_x, _end_y);
	face_world_x(_end_x);
};

griffith_leap_next_flight_start = function()
{
	if (griffith_leap_jump_count >= griffith_leap_max_jump_count)
	{
		griffith_leap_flight_start(griffith_leap_home_x, griffith_leap_home_y, noone, true);
		return true;
	}

	var _target = griffith_find_farthest_leap_target();

	if (instance_exists(_target))
	{
		griffith_leap_jump_count++;
		griffith_leap_flight_start(_target.x, _target.y, _target, false);
		return true;
	}

	if (griffith_leap_jump_count > 0)
	{
		griffith_leap_flight_start(griffith_leap_home_x, griffith_leap_home_y, noone, true);
		return true;
	}

	griffith_leap_is_active = false;
	visual_offset_is_ability_controlled = false;
	return false;
};

griffith_leap_use = function()
{
	griffith_leap_is_active = true;
	griffith_leap_jump_count = 0;
	griffith_leap_max_jump_count = BALANCE_BOSS_GRIFFITH_LEAP_COUNT;
	griffith_leap_home_x = x;
	griffith_leap_home_y = y;
	griffith_leap_hit_targets = [];

	if (!griffith_leap_next_flight_start())
	{
		return false;
	}

	return true;
};

griffith_leap_update = function()
{
	if (!griffith_leap_is_active)
	{
		return;
	}

	griffith_leap_flight_timer--;
	var _flight_progress = 1 - clamp(griffith_leap_flight_timer / max(1, griffith_leap_flight_duration), 0, 1);
	var _arc_lift = sin(_flight_progress * pi) * BALANCE_BOSS_GRIFFITH_LEAP_ARC_HEIGHT;
	x = lerp(griffith_leap_flight_start_x, griffith_leap_flight_end_x, _flight_progress);
	y = lerp(griffith_leap_flight_start_y, griffith_leap_flight_end_y, _flight_progress) - _arc_lift;

	if (griffith_leap_flight_timer > 0)
	{
		return;
	}

	x = griffith_leap_flight_end_x;
	y = griffith_leap_flight_end_y;

	if (griffith_leap_is_returning)
	{
		griffith_leap_is_active = false;
		griffith_leap_target = noone;
		visual_offset_is_ability_controlled = false;
		return;
	}

	if (instance_exists(griffith_leap_target))
	{
		griffith_mixed_damage_target(griffith_leap_target, true);
		griffith_yellow_smoke_create(x, y, aoe_radius);
		griffith_damage_targets_in_radius(x, y, aoe_radius, griffith_leap_target);
		array_push(griffith_leap_hit_targets, griffith_leap_target);
	}

	griffith_leap_next_flight_start();
};
