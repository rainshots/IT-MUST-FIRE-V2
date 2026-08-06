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
base_heal_radius = BALANCE_TOWER_HEAL_RADIUS;
base_heal_amount = BALANCE_TOWER_HEAL_AMOUNT;
var _tower_radius_multiplier = variable_global_exists("player_tower_radius_multiplier")
	? global.player_tower_radius_multiplier
	: 1;
var _foundry_radius_bonus = variable_global_exists("foundry_tower_radius_base_bonus")
	? global.foundry_tower_radius_base_bonus
	: 0;
heal_radius = base_heal_radius * (_tower_radius_multiplier + _foundry_radius_bonus);
heal_amount = base_heal_amount;
heal_tick_time = BALANCE_TOWER_HEAL_TICK_TIME * room_speed;
heal_tick_timer = irandom(heal_tick_time - 1);
attack_origin_top_offset = 81;
projectile_layer_name = "Instances";
projectile_effect_radius = BALANCE_TOWER_HEAL_PROJECTILE_EFFECT_RADIUS;
projectile_draw_depth = BALANCE_PARTICLE_SYSTEM_TOP_DEPTH - 50;

// Tooltip lines describe captured tower behavior.
tooltip_lines = [
	"Captured: heals friendly troops in a 600px radius",
	"Capture: requires full Taint under the tower",
	"Hover: shows healing radius"
];

building_has_upgrades = true;
building_tooltip_description = "Improves this Heal Tower.";
building_upgrade_levels = [0, 0];
building_upgrade_names = ["Wider Hymn", "Deeper Mending"];
building_upgrade_descriptions = ["+20% healing radius.", "+15% healing amount."];
building_upgrade_resources = [RESOURCES.SOULS, RESOURCES.SOULS];
building_upgrade_costs = [BALANCE_TOWER_HEAL_RADIUS_UPGRADE_SOUL_COST, BALANCE_TOWER_HEAL_AMOUNT_UPGRADE_SOUL_COST];
building_upgrade_level_maxes = [BALANCE_TOWER_HEAL_RADIUS_UPGRADE_MAX, BALANCE_TOWER_HEAL_AMOUNT_UPGRADE_MAX];

map_building_upgrade_effect_apply = function(_upgrade_index)
{
	var _radius_multiplier = variable_global_exists("player_tower_radius_multiplier")
		? global.player_tower_radius_multiplier
		: 1;
	var _foundry_radius_bonus = variable_global_exists("foundry_tower_radius_base_bonus")
		? global.foundry_tower_radius_base_bonus
		: 0;
	heal_radius = base_heal_radius
		* (((1 + (building_upgrade_levels[0] * BALANCE_TOWER_HEAL_RADIUS_UPGRADE_BONUS))
			* _radius_multiplier)
			+ _foundry_radius_bonus);
	heal_amount = base_heal_amount * (1 + (building_upgrade_levels[1] * BALANCE_TOWER_HEAL_AMOUNT_UPGRADE_BONUS));
};

tower_heal_target_is_valid = function(_target)
{
	if (!instance_exists(_target))
	{
		return false;
	}

	var _target_is_in_same_test = true;

	if (variable_instance_exists(id, "balance_test_match_id"))
	{
		_target_is_in_same_test = variable_instance_exists(_target, "balance_test_match_id")
			&& _target.balance_test_match_id == balance_test_match_id;
	}

	return _target_is_in_same_test
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
	_projectile.projectile_type = PROJECTILE_TYPE.HEAL;
	_projectile.effect_radius = projectile_effect_radius;
	_projectile.damage_amount = heal_amount;
	_projectile.source_instance = id;

	if (variable_instance_exists(id, "balance_test_match_id"))
	{
		_projectile.balance_test_match_id = balance_test_match_id;
	}

	_projectile.flight_time = _flight_time_seconds * room_speed;
	_projectile.depth = projectile_draw_depth;

	return _projectile;
};
