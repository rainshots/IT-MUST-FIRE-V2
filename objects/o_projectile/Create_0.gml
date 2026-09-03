// Projectile route settings assigned by the firing cannon after creation.
start_x = x;
start_y = y;
target_x = x;
target_y = y;
projectile_type = PROJECTILE_TYPE.DAMAGE;
cultist_payload = noone;
cultist_deploy_units = [];
building_payload = noone;
source_instance = noone;
artillery_direct_target = noone;
artillery_can_damage_units = true;
// Only the primary projectile in a Taint Compost volley creates its chosen enchantment effect.
taint_compost_enchantment = TAINT_COMPOST_ENCHANTMENT.NONE;
taint_compost_enchantment_primary = false;
taint_compost_enchantment_x = x;
taint_compost_enchantment_y = y;
first_aid_meat_enchantment = FIRST_AID_MEAT_ENCHANTMENT.NONE;
hellcow_enchantment = HELLCOW_ENCHANTMENT.NONE;
doom_bell_enchantment = DOOM_BELL_ENCHANTMENT.NONE;

// Explosion and effect settings.
effect_radius = BALANCE_PROJECTILE_EFFECT_RADIUS;
damage_amount = BALANCE_PROJECTILE_DAMAGE_AMOUNT;
damage_faction = UNIT_FACTION.NOONE;
damage_target_count = 0;
damage_targets_hit = 0;
damage_uses_physical_armor = false;
summon_count = BALANCE_PROJECTILE_SKELETON_COUNT;
corruption_amount = 1;
ground_corruption_amount = BALANCE_PROJECTILE_GROUND_CORRUPTION_AMOUNT;
ground_corruption_radius = effect_radius;
cleanse_amount = 1;
saint_amount = 0;
smoke_particle_count = 22;
building_smoke_radius = 150;
building_smoke_particle_count = 44;
particle_layer_name = "Instances";

// Flight settings.
projectile_speed = BALANCE_PROJECTILE_SPEED;
gameplay_time_scale = 1; // Updated from the global simulation scale every Step.
flight_speed_multiplier = BALANCE_PROJECTILE_FLIGHT_SPEED_MULTIPLIER;
minimum_flight_time = BALANCE_PROJECTILE_MIN_FLIGHT_TIME;
maximum_flight_time = BALANCE_PROJECTILE_MAX_FLIGHT_TIME;
launch_delay_timer = 0;
flight_time = minimum_flight_time * room_speed;
flight_timer = 0;
arc_height = 260;
ignore_pause = false;

// Cannon-fired projectiles enable this smoke trail after creation.
smoke_trail_enabled = false;
smoke_trail_interval = max(1, round(BALANCE_CANNON_PROJECTILE_SMOKE_TRAIL_INTERVAL * room_speed));
smoke_trail_timer = smoke_trail_interval;
smoke_trail_jitter_radius = BALANCE_CANNON_PROJECTILE_SMOKE_TRAIL_JITTER_RADIUS;

projectile_smoke_trail_create = function(_trail_x, _trail_y)
{
	var _smoke_direction = random(360);
	var _smoke_distance = sqrt(random(1)) * smoke_trail_jitter_radius;
	var _smoke_x = _trail_x + lengthdir_x(_smoke_distance, _smoke_direction);
	var _smoke_y = _trail_y + lengthdir_y(_smoke_distance, _smoke_direction);

	instance_create_layer(_smoke_x, _smoke_y, particle_layer_name, o_particle_smoke);
};

taint_compost_enchantment_apply = function()
{
	// The center projectile owns the one-per-volley enchantment effect.
	var _center_impact_tolerance = 1;
	var _is_center_impact = taint_compost_enchantment_primary
		|| point_distance(
			target_x,
			target_y,
			taint_compost_enchantment_x,
			taint_compost_enchantment_y
		) <= _center_impact_tolerance;
	var _source_is_cannon = instance_exists(source_instance)
		&& source_instance.object_index == o_cannon;

	if (!_is_center_impact || !_source_is_cannon)
	{
		return false;
	}

	// Resolve against the current match state at impact as a fallback if a projectile snapshot was lost.
	var _enchantment = taint_compost_enchantment;

	if (_enchantment == TAINT_COMPOST_ENCHANTMENT.NONE
		&& variable_global_exists("shell_factory_taint_enchantment"))
	{
		_enchantment = global.shell_factory_taint_enchantment;
	}

	if (_enchantment == TAINT_COMPOST_ENCHANTMENT.NONE)
	{
		return false;
	}

	var _effect_x = taint_compost_enchantment_x;
	var _effect_y = taint_compost_enchantment_y;

	if (_enchantment == TAINT_COMPOST_ENCHANTMENT.EXPLOSIVE_FERTILIZER)
	{
		var _mine_count = BALANCE_TAINT_COMPOST_PUMPKIN_MINE_COUNT;
		var _full_circle_degrees = 360;

		// A readable ring keeps all four mines distinct near the center of the impact area.
		for (var _mine_index = 0; _mine_index < _mine_count; ++_mine_index)
		{
			var _mine_direction = (_mine_index / _mine_count) * _full_circle_degrees;
			var _mine_x = _effect_x + lengthdir_x(BALANCE_TAINT_COMPOST_PUMPKIN_MINE_SPAWN_RADIUS, _mine_direction);
			var _mine_y = _effect_y + lengthdir_y(BALANCE_TAINT_COMPOST_PUMPKIN_MINE_SPAWN_RADIUS, _mine_direction);
			var _mine = instance_create_layer(_mine_x, _mine_y, particle_layer_name, o_pumpkin_mine);

			if (instance_exists(_mine))
			{
				// No Trap Point owns these mines, so they are never restored after destruction.
				_mine.owner_trap_point = noone;
				_mine.trap_point_slot_index = -1;

				// Apply world sorting immediately and make impact-created mines easy to read.
				_mine.depth = -floor(_mine.y);
				_mine.image_xscale = BALANCE_TAINT_COMPOST_PUMPKIN_MINE_VISUAL_SCALE;
				_mine.image_yscale = BALANCE_TAINT_COMPOST_PUMPKIN_MINE_VISUAL_SCALE;
			}
		}

		return true;
	}

	if (_enchantment == TAINT_COMPOST_ENCHANTMENT.SWEET_ROT)
	{
		instance_create_layer(_effect_x, _effect_y, particle_layer_name, o_taint_shell_tumor);
		return true;
	}

	return false;
};

// Visual settings.
projectile_radius = 12;
projectile_visual_scale = 2.5;
projectile_sprite = noone;
projectile_sprite_scale = 0.5;
explosion_preview_frames = 8;
draw_explosion_preview = false;

// Hellcow remains in the projectile instance after landing and becomes a directed charge.
hellcow_charge_direction = 0;
hellcow_charge_active = false;
hellcow_brace_timer = 0;
hellcow_distance_remaining = BALANCE_PROJECTILE_HELLCOW_CHARGE_DISTANCE;
hellcow_trail_timer = 0;
hellcow_start_collision_instances = [];
hellcow_sticky_trail = noone;

hellcow_structure_collision_can_stop = function(_candidate)
{
	if (!instance_exists(_candidate))
	{
		return false;
	}

	// Construction, trap, and habitat points share the map-object parent but are not obstacles.
	var _candidate_object = _candidate.object_index;
	var _is_construction_point = _candidate_object == o_cursed_point
		|| object_is_ancestor(_candidate_object, o_cursed_point);

	return !_is_construction_point;
};

hellcow_start_collisions_cache = function()
{
	hellcow_start_collision_instances = [];
	var _overlap_list = ds_list_create();
	var _overlap_count = collision_circle_list(
		x,
		y,
		BALANCE_PROJECTILE_HELLCOW_COLLISION_RADIUS,
		o_map_objects_parent,
		false,
		true,
		_overlap_list,
		false
	);

	for (var _overlap_index = 0; _overlap_index < _overlap_count; ++_overlap_index)
	{
		var _overlap = _overlap_list[| _overlap_index];

		if (hellcow_structure_collision_can_stop(_overlap))
		{
			array_push(hellcow_start_collision_instances, _overlap);
		}
	}

	ds_list_destroy(_overlap_list);
};

hellcow_new_structure_collision_find = function()
{
	var _collision_list = ds_list_create();
	var _collision_count = collision_circle_list(
		x,
		y,
		BALANCE_PROJECTILE_HELLCOW_COLLISION_RADIUS,
		o_map_objects_parent,
		false,
		true,
		_collision_list,
		false
	);
	var _hit_structure = noone;
	var _ignored_count = array_length(hellcow_start_collision_instances);

	for (var _collision_index = 0; _collision_index < _collision_count; ++_collision_index)
	{
		var _candidate = _collision_list[| _collision_index];

		if (!hellcow_structure_collision_can_stop(_candidate))
		{
			continue;
		}

		var _candidate_is_ignored = false;

		for (var _ignored_index = 0; _ignored_index < _ignored_count; ++_ignored_index)
		{
			if (_candidate == hellcow_start_collision_instances[_ignored_index])
			{
				_candidate_is_ignored = true;
				break;
			}
		}

		if (!_candidate_is_ignored)
		{
			_hit_structure = _candidate;
			break;
		}
	}

	ds_list_destroy(_collision_list);
	return _hit_structure;
};

hellcow_charge_start = function()
{
	x = target_x;
	y = target_y;
	depth = -floor(y);
	hellcow_charge_active = true;
	hellcow_brace_timer = max(1, round(BALANCE_PROJECTILE_HELLCOW_BRACE_TIME * room_speed));
	hellcow_distance_remaining = BALANCE_PROJECTILE_HELLCOW_CHARGE_DISTANCE;
	hellcow_trail_timer = 0;

	// Landing overlaps are not new impacts; let the cow leave them before checking its path.
	hellcow_start_collisions_cache();

	if (hellcow_enchantment == HELLCOW_ENCHANTMENT.STICKY_TRAIL)
	{
		var _trail_layer_id = layer_get_id(particle_layer_name);
		hellcow_sticky_trail = instance_create_layer(x, y, particle_layer_name, o_hellcow_sticky_trail);

		if (instance_exists(hellcow_sticky_trail))
		{
			hellcow_sticky_trail.trail_owner = id;
			hellcow_sticky_trail.hellcow_sticky_trail_corridor_set(x, y, hellcow_charge_direction);

			// Draw above the ground art and below instances on the combat layer.
			if (_trail_layer_id != -1)
			{
				hellcow_sticky_trail.depth = layer_get_depth(_trail_layer_id)
					+ BALANCE_PROJECTILE_HELLCOW_STICKY_TRAIL_GROUND_DEPTH_OFFSET;
			}
		}
	}
};

hellcow_enemies_push = function(_move_distance)
{
	var _direction_x = lengthdir_x(1, hellcow_charge_direction);
	var _direction_y = lengthdir_y(1, hellcow_charge_direction);
	var _side_x = -_direction_y;
	var _side_y = _direction_x;
	var _half_width = BALANCE_PROJECTILE_HELLCOW_CORRIDOR_WIDTH * 0.5;
	var _rear_reach = BALANCE_PROJECTILE_HELLCOW_COLLISION_RADIUS;
	var _front_reach = BALANCE_PROJECTILE_HELLCOW_PUSH_FRONT_DISTANCE;

	with (o_enemy_units)
	{
		if (!variable_instance_exists(id, "hp") || hp > 0)
		{
			var _offset_x = x - other.x;
			var _offset_y = y - other.y;
			var _forward_distance = (_offset_x * _direction_x) + (_offset_y * _direction_y);
			var _side_distance = (_offset_x * _side_x) + (_offset_y * _side_y);
			var _is_inside_push_front = _forward_distance >= -_rear_reach
				&& _forward_distance <= _front_reach
				&& abs(_side_distance) <= _half_width;

			if (_is_inside_push_front)
			{
				// Keep caught enemies ahead without allowing the charge to push them through terrain.
				var _required_push = max(_move_distance, _front_reach - _forward_distance);
				unit_forced_displacement_apply(
					_direction_x * _required_push,
					_direction_y * _required_push
				);
			}
		}
	}
};

hellcow_charge_finish = function()
{
	if (hellcow_enchantment == HELLCOW_ENCHANTMENT.FINAL_MOO)
	{
		// Final Moo is a harmless shockwave whose stun refreshes rather than stacking.
		if (variable_global_exists("explosion_sounds") && variable_global_exists("sound_play_random"))
		{
			global.sound_play_random(global.explosion_sounds);
		}

		var _explosion = instance_create_layer(x, y, particle_layer_name, o_particle_explosion);

		if (instance_exists(_explosion))
		{
			_explosion.end_radius = BALANCE_PROJECTILE_HELLCOW_FINAL_MOO_RADIUS;
		}

		with (o_enemy_units)
		{
			if (hp > 0
				&& point_distance(x, y, other.x, other.y)
					<= BALANCE_PROJECTILE_HELLCOW_FINAL_MOO_RADIUS
				&& variable_instance_exists(id, "stun_apply"))
			{
				stun_apply(BALANCE_PROJECTILE_HELLCOW_FINAL_MOO_STUN_TIME);
			}
		}
	}

	if (instance_exists(hellcow_sticky_trail))
	{
		hellcow_sticky_trail.hellcow_sticky_trail_finish();
	}

	// An unenchanted charge still ends without damage or explosion feedback.
	instance_destroy();
};

hellcow_charge_update = function()
{
	if (!hellcow_charge_active)
	{
		return false;
	}

	if (hellcow_brace_timer > 0)
	{
		hellcow_brace_timer -= gameplay_time_scale;
		return true;
	}

	var _charge_speed = (BALANCE_PROJECTILE_HELLCOW_CHARGE_SPEED / max(1, room_speed))
		* gameplay_time_scale;
	var _move_distance = min(_charge_speed, hellcow_distance_remaining);

	x += lengthdir_x(_move_distance, hellcow_charge_direction);
	y += lengthdir_y(_move_distance, hellcow_charge_direction);
	depth = -floor(y);
	hellcow_distance_remaining -= _move_distance;
	hellcow_enemies_push(_move_distance);

	// Hoof smoke makes the fast charge readable without adding more active objects than needed.
	hellcow_trail_timer += gameplay_time_scale;

	if (hellcow_trail_timer >= BALANCE_PROJECTILE_HELLCOW_TRAIL_INTERVAL)
	{
		hellcow_trail_timer = 0;
		var _trail_x = x + lengthdir_x(BALANCE_PROJECTILE_HELLCOW_COLLISION_RADIUS, hellcow_charge_direction + 180);
		var _trail_y = y + lengthdir_y(BALANCE_PROJECTILE_HELLCOW_COLLISION_RADIUS, hellcow_charge_direction + 180);
		instance_create_layer(_trail_x, _trail_y, particle_layer_name, o_particle_smoke);
	}

	var _hit_structure = hellcow_new_structure_collision_find();
	var _left_room = x < 0 || x > room_width || y < 0 || y > room_height;

	if (hellcow_distance_remaining <= 0 || instance_exists(_hit_structure) || _left_room)
	{
		hellcow_charge_finish();
	}

	return true;
};

projectile_target_is_allied = function(_target)
{
	if (damage_faction == UNIT_FACTION.NOONE || !instance_exists(_target))
	{
		return false;
	}

	if (variable_instance_exists(_target, "unit_faction"))
	{
		return _target.unit_faction == damage_faction;
	}

	if (damage_faction == UNIT_FACTION.ENEMY)
	{
		return _target.object_index == o_holy_tower
			|| _target.object_index == o_shrine
			|| _target.object_index == o_garnizon
			|| _target.object_index == o_house;
	}

	return false;
};

unholy_stunning_arrival_apply = function()
{
	var _has_stunning_arrival = projectile_type == PROJECTILE_TYPE.CULTIST
		&& instance_exists(cultist_payload)
		&& variable_instance_exists(cultist_payload, "squad")
		&& is_struct(cultist_payload.squad)
		&& squad_unholy_trait_get(cultist_payload.squad) == UNHOLY_TRAIT.STUNNING_ARRIVAL;

	if (!_has_stunning_arrival)
	{
		return false;
	}

	// The trait creates its own damaging shockwave while normal squad deployment stays harmless.
	var _enemy_count = instance_number(o_enemy_units);

	for (var _enemy_index = 0; _enemy_index < _enemy_count; ++_enemy_index)
	{
		var _enemy = instance_find(o_enemy_units, _enemy_index);

		if (!instance_exists(_enemy)
			|| !variable_instance_exists(_enemy, "hp")
			|| _enemy.hp <= 0
			|| point_distance(target_x, target_y, _enemy.x, _enemy.y)
				> BALANCE_UNHOLY_SHRINE_STUNNING_ARRIVAL_RADIUS)
		{
			continue;
		}

		if (variable_instance_exists(_enemy, "unit_damage_receive"))
		{
			_enemy.unit_damage_receive(
				BALANCE_UNHOLY_SHRINE_STUNNING_ARRIVAL_DAMAGE,
				UNIT_FACTION.FRIENDLY,
				false,
				true,
				cultist_payload
			);
		}

		if (instance_exists(_enemy)
			&& _enemy.hp > 0
			&& variable_instance_exists(_enemy, "stun_apply"))
		{
			_enemy.stun_apply(BALANCE_UNHOLY_SHRINE_STUNNING_ARRIVAL_STUN_TIME);
		}
	}

	var _shockwave = instance_create_layer(target_x, target_y, particle_layer_name, o_particle_explosion);

	if (instance_exists(_shockwave))
	{
		_shockwave.start_radius = BALANCE_UNHOLY_SHRINE_STUNNING_ARRIVAL_VISUAL_START_RADIUS;
		_shockwave.end_radius = BALANCE_UNHOLY_SHRINE_STUNNING_ARRIVAL_RADIUS;
		_shockwave.inner_color = COLOR_UNHOLY_STUNNING_ARRIVAL;
		_shockwave.outer_color = COLOR_UNHOLY_STUNNING_ARRIVAL;
		_shockwave.start_alpha = BALANCE_UNHOLY_SHRINE_STUNNING_ARRIVAL_VISUAL_ALPHA;
		_shockwave.current_alpha = _shockwave.start_alpha;
	}

	return true;
};
