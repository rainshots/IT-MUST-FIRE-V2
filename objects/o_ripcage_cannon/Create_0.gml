// Initialize shared friendly unit state and squad behavior.
event_inherited();

// Ripcage Cannon is a slow, durable physical artillery unit.
max_hp = BALANCE_RIPCAGE_CANNON_HP;
hp = max_hp;
armor = BALANCE_RIPCAGE_CANNON_ARMOR;
magic_resistance = BALANCE_RIPCAGE_CANNON_MAGIC_RESISTANCE;
damage = BALANCE_RIPCAGE_CANNON_DAMAGE;
magic_damage = 0;
reload_time = BALANCE_RIPCAGE_CANNON_RELOAD_TIME * room_speed;
attack_radius = BALANCE_RIPCAGE_CANNON_ATTACK_RADIUS;
move_speed = BALANCE_RIPCAGE_CANNON_MOVE_SPEED;
target_detection_radius = attack_radius;
vision_radius = attack_radius;

// Projectile settings keep the shot above units while following the shared artillery arc.
aoe_radius = BALANCE_RIPCAGE_CANNON_PROJECTILE_AOE_RADIUS;
ripcage_projectile_spawn_offset_y = -60;
ripcage_projectile_layer_name = "Instances";
ripcage_projectile_draw_depth = BALANCE_PARTICLE_SYSTEM_TOP_DEPTH - 50;
bar_offset_y = -2;
image_speed = 0;

ripcage_projectile_create = function(_target, _damage_amount, _is_critical_hit, _effect_radius)
{
	if (!instance_exists(_target))
	{
		return noone;
	}

	var _target_x = _target.x;
	var _target_y = _target.y;
	var _projectile_x = x;
	var _projectile_y = y + ripcage_projectile_spawn_offset_y;
	var _projectile = instance_create_layer(
		_projectile_x,
		_projectile_y,
		ripcage_projectile_layer_name,
		o_projectile
	);
	var _projectile_distance = point_distance(_projectile_x, _projectile_y, _target_x, _target_y);
	var _flight_time_seconds = clamp(
		_projectile_distance / _projectile.projectile_speed,
		_projectile.minimum_flight_time,
		_projectile.maximum_flight_time
	);

	_projectile.start_x = _projectile_x;
	_projectile.start_y = _projectile_y;
	_projectile.target_x = _target_x;
	_projectile.target_y = _target_y;
	_projectile.projectile_type = PROJECTILE_TYPE.DAMAGE;
	_projectile.effect_radius = _effect_radius;
	_projectile.damage_amount = _damage_amount;
	_projectile.damage_target_count = 0;
	_projectile.damage_uses_physical_armor = true;
	_projectile.damage_is_critical_hit = _is_critical_hit;
	_projectile.damage_units_only = true;
	_projectile.damage_faction = UNIT_FACTION.FRIENDLY;
	_projectile.source_instance = id;
	_projectile.flight_time = _flight_time_seconds * room_speed;
	_projectile.depth = ripcage_projectile_draw_depth;

	if (variable_instance_exists(id, "balance_test_match_id"))
	{
		_projectile.balance_test_match_id = balance_test_match_id;
	}

	return _projectile;
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

	// Dead Silence blocks this ranged attack without stopping reload recovery.
	if (doom_bell_silence_is_active())
	{
		is_attacking_target = false;
		return;
	}

	// Snapshot all squad and relic modifiers into the projectile at launch.
	var _raw_damage = damage * next_attack_damage_multiplier;
	var _effect_radius = aoe_radius * next_attack_radius_multiplier;

	if (variable_instance_exists(id, "unit_damage_modifier_get"))
	{
		_raw_damage *= unit_damage_modifier_get(_target, false);
	}

	var _is_critical_hit = false;
	var _current_crit_chance = unit_crit_chance_get();

	if (_current_crit_chance > 0 && random(1) < _current_crit_chance)
	{
		_raw_damage *= unit_crit_damage_get();
		_is_critical_hit = true;
	}

	var _projectile = ripcage_projectile_create(
		_target,
		_raw_damage,
		_is_critical_hit,
		_effect_radius
	);

	if (!instance_exists(_projectile))
	{
		return;
	}

	next_attack_damage_multiplier = 1;
	next_attack_radius_multiplier = 1;
	reload_timer = reload_time * unit_attack_reload_multiplier_get();
};

// Close-range hits make this ranged unit disengage like other player ranged units.
unit_damage_received = function(_source_instance, _source_faction, _applied_damage)
{
	ranged_unit_melee_flee_on_damage(_source_instance);
};
