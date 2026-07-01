// Initialize shared map object state.
event_inherited();

// Capture state unlocks a daily skeleton spawn.
tower_capture_enabled = true;
is_captured = false;
uncaptured_sprite_index = s_graveyardv3_b;
captured_sprite_index = s_graveyardv3;
sprite_index = uncaptured_sprite_index;
image_speed = 0;

// Morning spawn settings mirror the player Graveyard skeleton type.
morning_unit_object = o_skeleton;
base_morning_unit_count = BALANCE_BONEYARD_MORNING_SKELETON_COUNT;
morning_unit_count = base_morning_unit_count;
morning_spawn_radius = BALANCE_CAPTURED_SPAWN_BUILDING_RADIUS;

// Tooltip lines describe the captured map building behavior.
tooltip_lines = [
	"Captured: spawns 2 Skeletons every morning",
	"Skeletons move to the cannon base"
];

building_has_upgrades = true;
building_tooltip_description = "Improves this Boneyard.";
building_upgrade_levels = [0];
building_upgrade_names = ["More Bones"];
building_upgrade_descriptions = ["+1 Skeleton every morning."];
building_upgrade_resources = [RESOURCES.SOULS];
building_upgrade_costs = [BALANCE_BONEYARD_SKELETON_UPGRADE_SOUL_COST];
building_upgrade_level_maxes = [BALANCE_BONEYARD_SKELETON_UPGRADE_MAX];

map_building_upgrade_effect_apply = function(_upgrade_index)
{
	morning_unit_count = base_morning_unit_count + (building_upgrade_levels[0] * BALANCE_BONEYARD_SKELETON_UPGRADE_BONUS);
};

boneyard_spawn_morning_units = function()
{
	if (!is_captured)
	{
		return;
	}

	for (var _unit_index = 0; _unit_index < morning_unit_count; ++_unit_index)
	{
		var _spawn_direction = random(360);
		var _spawn_distance = random(morning_spawn_radius);
		var _spawn_x = x + lengthdir_x(_spawn_distance, _spawn_direction);
		var _spawn_y = y + lengthdir_y(_spawn_distance, _spawn_direction);
		var _unit = instance_create_layer(_spawn_x, _spawn_y, "Instances", morning_unit_object);

		if (instance_exists(o_game_controller))
		{
			var _game_controller = instance_find(o_game_controller, 0);

			if (variable_instance_exists(_game_controller, "move_spawned_summoned_unit_to_cannon_inner"))
			{
				_game_controller.move_spawned_summoned_unit_to_cannon_inner(_unit);
			}
		}
	}
};
