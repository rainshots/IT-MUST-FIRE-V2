// Initialize shared map object state.
event_inherited();

// Capture state changes the tower sprite and unlocks the passive effect.
tower_capture_enabled = true;
is_captured = false;
uncaptured_sprite_index = s_corruption_tower_b;
captured_sprite_index = s_corruption_tower;
sprite_index = uncaptured_sprite_index;
image_speed = 0;

// Corruption tower infects nearby ground each morning after capture.
base_effect_radius = BALANCE_TOWER_CORRUPTION_SPREAD_RADIUS;
effect_radius = base_effect_radius;
morning_projectile_count = BALANCE_TOWER_CORRUPTION_MORNING_PROJECTILE_COUNT;
morning_launch_time = BALANCE_TOWER_CORRUPTION_MORNING_LAUNCH_TIME;
projectile_spawn_offset_y = -20;
projectile_layer_name = "Instances";
projectile_effect_radius = BALANCE_TOWER_CORRUPTION_PROJECTILE_EFFECT_RADIUS;
projectile_corruption_amount = BALANCE_TOWER_CORRUPTION_PROJECTILE_CORRUPTION_AMOUNT;
projectile_draw_depth = BALANCE_PARTICLE_SYSTEM_TOP_DEPTH - 50;

// Tooltip lines describe captured tower behavior.
tooltip_lines = [
	"Spreads Taint every morning.",
	"Capture: requires full Taint under the tower",
	"Hover: shows effect radius"
];

building_has_upgrades = true;
building_tooltip_description = "Improves this Taint Tower.";
building_upgrade_levels = [0];
building_upgrade_names = ["Wider Taint"];
building_upgrade_descriptions = ["+25% Taint spread radius."];
building_upgrade_resources = [RESOURCES.FLESH];
building_upgrade_costs = [BALANCE_TOWER_CORRUPTION_RADIUS_UPGRADE_FLESH_COST];
building_upgrade_level_maxes = [BALANCE_TOWER_CORRUPTION_RADIUS_UPGRADE_MAX];

map_building_upgrade_effect_apply = function(_upgrade_index)
{
	effect_radius = base_effect_radius * (1 + (building_upgrade_levels[0] * BALANCE_TOWER_CORRUPTION_RADIUS_UPGRADE_BONUS));
};

tower_corruption_projectile_create = function(_target_x, _target_y, _corruption_amount, _launch_delay_seconds = 0)
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
	_projectile.launch_delay_timer = _launch_delay_seconds * room_speed;
	_projectile.flight_time = _flight_time_seconds * room_speed;
	_projectile.depth = projectile_draw_depth;

	return _projectile;
};

tower_corruption_morning_projectiles_fire = function()
{
	if (!is_captured || !instance_exists(o_corruption_grid))
	{
		return;
	}

	for (var _projectile_index = 0; _projectile_index < morning_projectile_count; ++_projectile_index)
	{
		var _target_direction = random(360);
		var _target_distance = sqrt(random(1)) * effect_radius;
		var _target_x = x + lengthdir_x(_target_distance, _target_direction);
		var _target_y = y + lengthdir_y(_target_distance, _target_direction);
		var _launch_delay_seconds = random(morning_launch_time);

		tower_corruption_projectile_create(_target_x, _target_y, projectile_corruption_amount, _launch_delay_seconds);
	}
};
