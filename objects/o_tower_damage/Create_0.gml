// Initialize shared map object state.
event_inherited();

// Capture state changes the tower sprite and unlocks combat.
tower_capture_enabled = true;
is_captured = false;
uncaptured_sprite_index = s_damage_tower_b;
captured_sprite_index = s_damage_tower;
sprite_index = uncaptured_sprite_index;
image_speed = 0;

// Damage tower shoots the nearest enemy inside its radius.
base_shoot_radius = BALANCE_TOWER_DAMAGE_RADIUS;
base_damage = BALANCE_TOWER_DAMAGE_AMOUNT;
shoot_radius = base_shoot_radius;
damage = base_damage;
reload_time = BALANCE_TOWER_DAMAGE_RELOAD_TIME * room_speed;
reload_timer = 0;
target_instance = noone;
projectile_spawn_offset_y = -20;
projectile_layer_name = "Instances";
projectile_effect_radius = BALANCE_TOWER_DAMAGE_PROJECTILE_EFFECT_RADIUS;
projectile_draw_depth = BALANCE_PARTICLE_SYSTEM_TOP_DEPTH - 50;

// Attack feedback shows the tower shot for a short moment.
attack_feedback_time = BALANCE_TOWER_ATTACK_FEEDBACK_TIME * room_speed;
attack_feedback_timer = 0;
attack_feedback_target = noone;
attack_feedback_target_x = x;
attack_feedback_target_y = y;
attack_feedback_line_width = 2;

// Tooltip lines describe captured tower behavior.
tooltip_lines = [
	"Captured: shoots enemies in a 600px radius",
	"Capture: requires full Taint under the tower",
	"Hover: shows shooting radius"
];

building_has_upgrades = true;
building_tooltip_description = "Improves this Damage Tower.";
building_upgrade_levels = [0, 0];
building_upgrade_names = ["Longer Barrels", "Sharper Bolts"];
building_upgrade_descriptions = ["+20% shooting radius.", "+25% damage."];
building_upgrade_resources = [RESOURCES.IRON, RESOURCES.IRON];
building_upgrade_costs = [BALANCE_TOWER_DAMAGE_RADIUS_UPGRADE_IRON_COST, BALANCE_TOWER_DAMAGE_DAMAGE_UPGRADE_IRON_COST];
building_upgrade_level_maxes = [BALANCE_TOWER_DAMAGE_RADIUS_UPGRADE_MAX, BALANCE_TOWER_DAMAGE_DAMAGE_UPGRADE_MAX];

map_building_upgrade_effect_apply = function(_upgrade_index)
{
	shoot_radius = base_shoot_radius * (1 + (building_upgrade_levels[0] * BALANCE_TOWER_DAMAGE_RADIUS_UPGRADE_BONUS));
	damage = base_damage * (1 + (building_upgrade_levels[1] * BALANCE_TOWER_DAMAGE_DAMAGE_UPGRADE_BONUS));
};

tower_damage_projectile_create = function(_target_x, _target_y)
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
	_projectile.projectile_type = PROJECTILE_TYPE.DAMAGE;
	_projectile.effect_radius = projectile_effect_radius;
	_projectile.damage_amount = damage;
	_projectile.damage_faction = UNIT_FACTION.FRIENDLY;
	_projectile.source_instance = id;
	_projectile.flight_time = _flight_time_seconds * room_speed;
	_projectile.depth = projectile_draw_depth;

	return _projectile;
};
