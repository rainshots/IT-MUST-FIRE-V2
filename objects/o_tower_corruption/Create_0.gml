// Initialize shared map object state.
event_inherited();

// Capture state changes the tower sprite and unlocks the passive effect.
tower_capture_enabled = true;
is_captured = false;
uncaptured_sprite_index = s_corruption_tower_b;
captured_sprite_index = s_corruption_tower;
sprite_index = uncaptured_sprite_index;
image_speed = 0;

// Corruption tower gradually infects nearby ground after capture.
effect_radius = BALANCE_TOWER_CORRUPTION_SPREAD_RADIUS;
spread_update_interval = BALANCE_TOWER_CORRUPTION_SPREAD_UPDATE_INTERVAL;
spread_update_timer = irandom(spread_update_interval - 1);
fire_duration = BALANCE_TOWER_CORRUPTION_FIRE_DURATION * room_speed;
fire_timer = 0;
fire_finished = false;
projectile_spawn_offset_y = -20;
projectile_layer_name = "Instances";
projectile_effect_radius = BALANCE_TOWER_CORRUPTION_PROJECTILE_EFFECT_RADIUS;
projectile_corruption_amount = BALANCE_TOWER_CORRUPTION_PROJECTILE_CORRUPTION_AMOUNT;
projectile_draw_depth = BALANCE_PARTICLE_SYSTEM_TOP_DEPTH - 50;

// Tooltip lines describe captured tower behavior.
tooltip_lines = [
	"Captured: spreads Taint in a 600px radius",
	"Capture: requires full Taint under the tower",
	"Hover: shows effect radius"
];

tower_corruption_projectile_create = function(_target_x, _target_y, _corruption_amount)
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
	_projectile.projectile_type = PROJECTILE_TYPE.CORRUPTION;
	_projectile.effect_radius = projectile_effect_radius;
	_projectile.ground_corruption_amount = _corruption_amount;
	_projectile.source_instance = id;
	_projectile.flight_time = _flight_time_seconds * room_speed;
	_projectile.depth = projectile_draw_depth;

	return _projectile;
};
