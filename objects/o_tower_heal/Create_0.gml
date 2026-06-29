// Initialize shared map object state.
event_inherited();

// Capture state changes the tower sprite and unlocks healing.
tower_capture_enabled = true;
is_captured = false;
uncaptured_sprite_index = s_heal_tower_b;
captured_sprite_index = s_heal_tower;
sprite_index = uncaptured_sprite_index;
image_speed = 0;

// Heal tower restores allied troops inside its radius.
heal_radius = BALANCE_TOWER_HEAL_RADIUS;
heal_amount = BALANCE_TOWER_HEAL_AMOUNT;
heal_tick_time = BALANCE_TOWER_HEAL_TICK_TIME * room_speed;
heal_tick_timer = irandom(heal_tick_time - 1);
projectile_spawn_offset_y = -20;
projectile_layer_name = "Instances";
projectile_effect_radius = BALANCE_TOWER_HEAL_PROJECTILE_EFFECT_RADIUS;
projectile_draw_depth = BALANCE_PARTICLE_SYSTEM_TOP_DEPTH - 50;

// Tooltip lines describe captured tower behavior.
tooltip_lines = [
	"Captured: heals friendly troops in a 600px radius",
	"Capture: requires full Taint under the tower",
	"Hover: shows healing radius"
];

tower_heal_target_is_valid = function(_target)
{
	return instance_exists(_target)
		&& variable_instance_exists(_target, "hp")
		&& variable_instance_exists(_target, "max_hp")
		&& _target.hp > 0
		&& _target.hp < _target.max_hp
		&& (!variable_instance_exists(_target, "visible") || _target.visible)
		&& point_distance(x, y, _target.x, _target.y) <= heal_radius;
};

tower_heal_projectile_create = function(_target_x, _target_y)
{
	var _projectile_x = x;
	var _projectile_y = y + projectile_spawn_offset_y;
	var _projectile = instance_create_layer(_projectile_x, _projectile_y, projectile_layer_name, o_projectile);
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
	_projectile.projectile_type = PROJECTILE_TYPE.HEAL;
	_projectile.effect_radius = projectile_effect_radius;
	_projectile.damage_amount = heal_amount;
	_projectile.source_instance = id;
	_projectile.flight_time = _flight_time_seconds * room_speed;
	_projectile.depth = projectile_draw_depth;

	return _projectile;
};
