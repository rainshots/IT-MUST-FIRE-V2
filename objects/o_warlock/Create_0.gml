// Initialize shared friendly combat state.
event_inherited();

// Demon sprites are scaled up for readability.
image_xscale = 1;
image_yscale = 1;

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
passive_choice_options = [];
active_choice_options = [];
active_abilities = [];

// Passive abilities start locked and can be enabled by future progression.
has_warlock_soul_harvester = false;
has_warlock_curseweaver = false;
has_warlock_demonic_infusion = false;

// Demon combat stats are derived from base stats and cultist attributes.
cultist_stats_apply(id);

// Warlock passive state.
curseweaver_attack_count = 0;
curseweaver_circle_timer = 0;
curseweaver_circle_duration = BALANCE_WARLOCK_CURSEWEAVER_CIRCLE_FADE_TIME * room_speed;
curseweaver_circle_x = x;
curseweaver_circle_y = y;
curseweaver_circle_radius = BALANCE_WARLOCK_CURSEWEAVER_RADIUS;
demonic_infusion_radius = BALANCE_WARLOCK_DEMONIC_INFUSION_RADIUS;

// Warlock active abilities keep independent cooldown state for future unlocks.
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
soul_chain_groups = array_create(0);

warlock_curseweaver_smoke_create = function(_burst_x, _burst_y)
{
	if (!variable_global_exists("particle_system_effects")
		|| !variable_global_exists("particle_type_warlock_curseweaver_smoke")
		|| global.particle_system_effects == noone
		|| global.particle_type_warlock_curseweaver_smoke == noone)
	{
		return;
	}

	for (var _particle_index = 0; _particle_index < BALANCE_WARLOCK_CURSEWEAVER_SMOKE_COUNT; ++_particle_index)
	{
		var _particle_distance = sqrt(random(1)) * BALANCE_WARLOCK_CURSEWEAVER_RADIUS;
		var _particle_direction = random(360);
		var _particle_x = _burst_x + lengthdir_x(_particle_distance, _particle_direction);
		var _particle_y = _burst_y + lengthdir_y(_particle_distance, _particle_direction);
		part_particles_create(global.particle_system_effects, _particle_x, _particle_y, global.particle_type_warlock_curseweaver_smoke, 1);
	}
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

warlock_curseweaver_apply = function(_target)
{
	if (!instance_exists(_target))
	{
		return;
	}

	curseweaver_circle_x = _target.x;
	curseweaver_circle_y = _target.y;
	curseweaver_circle_timer = curseweaver_circle_duration;
	warlock_curseweaver_smoke_create(_target.x, _target.y);

	var _enemy_list = ds_list_create();
	var _enemy_count = collision_circle_list(_target.x, _target.y, BALANCE_WARLOCK_CURSEWEAVER_RADIUS, o_enemy_units, false, true, _enemy_list, false);

	for (var _enemy_index = 0; _enemy_index < _enemy_count; ++_enemy_index)
	{
		var _enemy = _enemy_list[| _enemy_index];

		if (target_can_be_attacked(_enemy) && variable_instance_exists(_enemy, "status_effect_apply"))
		{
			_enemy.status_effect_apply(
				STATUS_EFFECT.CURSE,
				BALANCE_WARLOCK_CURSEWEAVER_CURSE_TIME,
				1,
				0,
				0,
				unit_faction
			);
		}
	}

	ds_list_destroy(_enemy_list);
};

warlock_demonic_infusion_update = function()
{
	var _friendly_list = ds_list_create();
	var _friendly_count = collision_circle_list(x, y, demonic_infusion_radius, o_friendly_units, false, true, _friendly_list, false);
	var _reload_multiplier = 1 / (1 + BALANCE_WARLOCK_DEMONIC_INFUSION_ATTACK_SPEED_BONUS);
	var _refresh_time = BALANCE_WARLOCK_DEMONIC_INFUSION_REFRESH_TIME * room_speed;

	for (var _friendly_index = 0; _friendly_index < _friendly_count; ++_friendly_index)
	{
		var _friendly = _friendly_list[| _friendly_index];

		if (instance_exists(_friendly)
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

warlock_nearest_meat_find = function(_search_radius)
{
	if (!instance_exists(o_meat))
	{
		return noone;
	}

	var _nearest_meat = noone;
	var _nearest_distance = _search_radius;
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

warlock_raise_lesser_demon_use = function()
{
	var _meat = warlock_nearest_meat_find(BALANCE_WARLOCK_RAISE_LESSER_DEMON_MEAT_RADIUS);

	if (!instance_exists(_meat))
	{
		return false;
	}

	var _spawn_x = _meat.x;
	var _spawn_y = _meat.y;

	ability_popup_create(x, y, DEMON_ABILITY.WARLOCK_RAISE_LESSER_DEMON);
	raise_lesser_demon_line_x = _spawn_x;
	raise_lesser_demon_line_y = _spawn_y;
	raise_lesser_demon_line_timer = raise_lesser_demon_line_duration;
	var _pitling = instance_create_layer(_spawn_x, _spawn_y, "Instances", o_pitling);

	if (instance_exists(_pitling) && variable_instance_exists(_pitling, "summon_nights_remaining"))
	{
		_pitling.summon_nights_remaining = 1;
	}

	if (variable_global_exists("particle_type_brute_rotten_aura"))
	{
		warlock_smoke_burst_create(
			_spawn_x,
			_spawn_y,
			BALANCE_WARLOCK_RAISE_LESSER_DEMON_SMOKE_RADIUS,
			global.particle_type_brute_rotten_aura,
			BALANCE_WARLOCK_RAISE_LESSER_DEMON_SMOKE_COUNT
		);
	}

	with (_meat)
	{
		instance_destroy();
	}

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

warlock_soul_chain_members_near_get = function(_center_enemy)
{
	var _members = array_create(0);
	var _enemy_count = instance_number(o_enemy_units);

	for (var _member_slot = 0; _member_slot < BALANCE_WARLOCK_SOUL_CHAIN_MAX_TARGETS; ++_member_slot)
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
	var _best_members = array_create(0);
	var _best_count = 0;
	var _best_distance = infinity;
	var _enemy_count = instance_number(o_enemy_units);

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

		if (_best_count >= BALANCE_WARLOCK_SOUL_CHAIN_MAX_TARGETS)
		{
			break;
		}
	}

	if (_best_count < BALANCE_WARLOCK_SOUL_CHAIN_MIN_TARGETS)
	{
		return array_create(0);
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

	// Use a small global counter instead of instance id math to avoid malformed ids.
	if (!variable_global_exists("soul_chain_next_id"))
	{
		global.soul_chain_next_id = 1;
	}

	var _chain_id = global.soul_chain_next_id;
	global.soul_chain_next_id++;
	var _duration_frames = BALANCE_WARLOCK_SOUL_CHAIN_DURATION * room_speed;

	for (var _member_index = 0; _member_index < array_length(_members); ++_member_index)
	{
		var _member = _members[_member_index];
		_member.soul_chain_apply(
			_chain_id,
			_members,
			BALANCE_WARLOCK_SOUL_CHAIN_DURATION,
			BALANCE_WARLOCK_SOUL_CHAIN_DAMAGE_SHARE
		);
	}

	ability_popup_create(x, y, DEMON_ABILITY.WARLOCK_SOUL_CHAIN);
	array_push(soul_chain_groups, {
		chain_id: _chain_id,
		members: _members,
		timer: _duration_frames
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
	var _enemy_candidates = array_create(0);
	var _enemy_count = instance_number(o_enemy_units);

	for (var _enemy_index = 0; _enemy_index < _enemy_count; ++_enemy_index)
	{
		var _enemy = instance_find(o_enemy_units, _enemy_index);

		if (target_can_be_attacked(_enemy)
			&& point_distance(x, y, _enemy.x, _enemy.y) <= BALANCE_WARLOCK_HEX_TOTEM_SEARCH_RADIUS)
		{
			array_push(_enemy_candidates, _enemy);
		}
	}

	if (array_length(_enemy_candidates) <= 0)
	{
		return noone;
	}

	return _enemy_candidates[irandom(array_length(_enemy_candidates) - 1)];
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

	if (instance_exists(_totem))
	{
		_totem.owner_warlock = id;
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
	if (!instance_exists(_target)
		|| (variable_instance_exists(_target, "is_being_dragged") && _target.is_being_dragged)
		|| !variable_instance_exists(_target, "status_effect_apply"))
	{
		return;
	}

	if (has_warlock_soul_harvester)
	{
		_target.status_effect_apply(
			STATUS_EFFECT.SOUL_MARK,
			BALANCE_WARLOCK_SOUL_HARVESTER_MARK_TIME,
			BALANCE_STATUS_SOUL_MARK_DEFAULT_CHANCE,
			0,
			0,
			unit_faction
		);
	}

	if (!has_warlock_curseweaver)
	{
		return;
	}

	curseweaver_attack_count++;

	if (curseweaver_attack_count >= BALANCE_WARLOCK_CURSEWEAVER_ATTACKS_REQUIRED)
	{
		curseweaver_attack_count = 0;
		warlock_curseweaver_apply(_target);
	}
};
