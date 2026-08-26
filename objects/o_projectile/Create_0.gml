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
		array_push(hellcow_start_collision_instances, _overlap_list[| _overlap_index]);
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

hellcow_explode = function()
{
	if (variable_global_exists("explosion_sounds") && variable_global_exists("sound_play_random"))
	{
		global.sound_play_random(global.explosion_sounds);
	}

	instance_create_layer(x, y, particle_layer_name, o_particle_explosion);

	for (var _smoke_index = 0; _smoke_index < smoke_particle_count; ++_smoke_index)
	{
		var _smoke_direction = random(360);
		var _smoke_distance = sqrt(random(1)) * effect_radius;
		var _smoke_x = x + lengthdir_x(_smoke_distance, _smoke_direction);
		var _smoke_y = y + lengthdir_y(_smoke_distance, _smoke_direction);

		instance_create_layer(_smoke_x, _smoke_y, particle_layer_name, o_particle_smoke);
	}

	// The final blast keeps Hellcow's upgradeable damage while the charge itself only displaces.
	with (o_enemy_units)
	{
		if (variable_instance_exists(id, "hp")
			&& hp > 0
			&& point_distance(x, y, other.x, other.y) <= other.effect_radius)
		{
			if (variable_instance_exists(id, "unit_damage_receive"))
			{
				unit_damage_receive(
					other.damage_amount,
					other.damage_faction,
					false,
					true,
					other.source_instance
				);
			}
			else
			{
				hp = max(hp - other.damage_amount, 0);
				damage_popup_create(x, y, other.damage_amount, unit_faction);
			}
		}
	}

	if (instance_exists(o_camera_controller))
	{
		var _camera_controller = instance_find(o_camera_controller, 0);

		if (variable_instance_exists(_camera_controller, "camera_shake_start"))
		{
			_camera_controller.camera_shake_start(
				BALANCE_CANNON_SHOT_SHAKE_TIME,
				BALANCE_CANNON_SHOT_SHAKE_STRENGTH
			);
		}
	}

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
		hellcow_explode();
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
