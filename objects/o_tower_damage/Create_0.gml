// Initialize shared map object state.
event_inherited();

// Capture state changes the tower sprite and unlocks combat.
tower_capture_enabled = true;
is_captured = false;
uncaptured_sprite_index = s_damage_tower_b;
captured_sprite_index = s_damage_tower;
sprite_index = uncaptured_sprite_index;
image_speed = 0;

// Durability follows the tower balance table.
max_hp = BALANCE_TOWER_DAMAGE_MAX_HP;
hp = max_hp;
armor = BALANCE_TOWER_DAMAGE_ARMOR;
magic_resistance = BALANCE_TOWER_DAMAGE_MAGIC_RESISTANCE;
player_building_cleansed_base_max_hp = max_hp;

// Damage tower shoots the nearest enemy inside its radius.
base_shoot_radius = BALANCE_TOWER_DAMAGE_RADIUS;
base_damage = BALANCE_TOWER_DAMAGE_AMOUNT;
var _tower_radius_multiplier = variable_global_exists("player_tower_radius_multiplier")
	? global.player_tower_radius_multiplier
	: 1;
var _foundry_radius_bonus = variable_global_exists("foundry_tower_radius_base_bonus")
	? global.foundry_tower_radius_base_bonus
	: 0;
var _foundry_damage_bonus = variable_global_exists("foundry_tower_damage_base_bonus")
	? global.foundry_tower_damage_base_bonus
	: 0;
shoot_radius = base_shoot_radius * (_tower_radius_multiplier + _foundry_radius_bonus);
damage = base_damage * (1 + _foundry_damage_bonus);
reload_time = BALANCE_TOWER_DAMAGE_RELOAD_TIME * room_speed;
reload_timer = 0;
target_instance = noone;
attack_origin_top_offset = 81;
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
	var _radius_multiplier = variable_global_exists("player_tower_radius_multiplier")
		? global.player_tower_radius_multiplier
		: 1;
	var _foundry_radius_bonus = variable_global_exists("foundry_tower_radius_base_bonus")
		? global.foundry_tower_radius_base_bonus
		: 0;
	var _foundry_damage_bonus = variable_global_exists("foundry_tower_damage_base_bonus")
		? global.foundry_tower_damage_base_bonus
		: 0;
	shoot_radius = base_shoot_radius
		* (((1 + (building_upgrade_levels[0] * BALANCE_TOWER_DAMAGE_RADIUS_UPGRADE_BONUS))
			* _radius_multiplier)
			+ _foundry_radius_bonus);
	damage = base_damage
		* (1
			+ _foundry_damage_bonus
			+ (building_upgrade_levels[1] * BALANCE_TOWER_DAMAGE_DAMAGE_UPGRADE_BONUS));
};

tower_damage_projectile_create = function(_target_x, _target_y)
{
	var _projectile_x = x;
	var _projectile_y = y - sprite_get_height(sprite_index) + attack_origin_top_offset;
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
	_projectile.damage_target_count = BALANCE_TOWER_DAMAGE_TARGET_COUNT;
	_projectile.damage_uses_physical_armor = true;
	_projectile.damage_faction = UNIT_FACTION.FRIENDLY;
	_projectile.source_instance = id;
	_projectile.flight_time = _flight_time_seconds * room_speed;
	_projectile.depth = projectile_draw_depth;

	if (variable_instance_exists(id, "balance_test_match_id"))
	{
		_projectile.balance_test_match_id = balance_test_match_id;
	}

	return _projectile;
};
