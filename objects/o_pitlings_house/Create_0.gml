// Initialize shared map object state.
event_inherited();

// Capture state unlocks a daily Pitling spawn.
tower_capture_enabled = true;
is_captured = false;
uncaptured_sprite_index = s_pitlings_house_b;
captured_sprite_index = s_pitlings_house;
sprite_index = uncaptured_sprite_index;
image_speed = 0;

// Morning spawn settings mirror the player Hell Pit pitling type.
morning_unit_object = o_pitling;
morning_unit_count = BALANCE_PITLINGS_HOUSE_MORNING_PITLING_COUNT;
morning_spawn_radius = BALANCE_CAPTURED_SPAWN_BUILDING_RADIUS;

// Tooltip lines describe the captured map building behavior.
tooltip_lines = [
	"Captured: spawns 1 Pitling every morning",
	"Pitling moves to the cannon base"
];

pitlings_house_spawn_morning_units = function()
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
