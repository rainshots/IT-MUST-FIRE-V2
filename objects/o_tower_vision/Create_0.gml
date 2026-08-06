// Initialize shared map object state.
event_inherited();

// Capture state changes the tower sprite and unlocks fog reveal.
tower_capture_enabled = true;
is_captured = false;
uncaptured_sprite_index = s_watchtower_b;
captured_sprite_index =  s_watchtower;
sprite_index = uncaptured_sprite_index;
image_speed = 0;

// Vision tower reveals fog around itself after capture.
base_vision_radius = BALANCE_TOWER_VISION_RADIUS;
var _tower_radius_multiplier = variable_global_exists("player_tower_radius_multiplier")
	? global.player_tower_radius_multiplier
	: 1;
var _foundry_radius_bonus = variable_global_exists("foundry_tower_radius_base_bonus")
	? global.foundry_tower_radius_base_bonus
	: 0;
vision_radius = base_vision_radius * (_tower_radius_multiplier + _foundry_radius_bonus);

// Tooltip lines describe captured tower behavior.
tooltip_lines = [
	"Captured: reveals fog in a 1200px radius",
	"Capture: requires full Taint under the tower",
	"Hover: shows vision radius"
];

building_has_upgrades = true;
building_tooltip_description = "Improves this Vision Tower.";
building_upgrade_levels = [0];
building_upgrade_names = ["Clearer Sight"];
building_upgrade_descriptions = ["+25% vision radius."];
building_upgrade_resources = [RESOURCES.SOULS];
building_upgrade_costs = [BALANCE_TOWER_VISION_RADIUS_UPGRADE_SOUL_COST];
building_upgrade_level_maxes = [BALANCE_TOWER_VISION_RADIUS_UPGRADE_MAX];

map_building_upgrade_effect_apply = function(_upgrade_index)
{
	var _radius_multiplier = variable_global_exists("player_tower_radius_multiplier")
		? global.player_tower_radius_multiplier
		: 1;
	var _foundry_radius_bonus = variable_global_exists("foundry_tower_radius_base_bonus")
		? global.foundry_tower_radius_base_bonus
		: 0;
	vision_radius = base_vision_radius
		* (((1 + (building_upgrade_levels[0] * BALANCE_TOWER_VISION_RADIUS_UPGRADE_BONUS))
			* _radius_multiplier)
			+ _foundry_radius_bonus);
};
