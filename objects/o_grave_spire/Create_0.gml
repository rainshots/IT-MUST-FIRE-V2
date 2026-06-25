// Initialize shared map object state.
event_inherited();

// Grave Spire works only while standing on fully tainted ground.
is_captured = true;
tower_capture_enabled = false;
sprite_index = s_grave_spire;
image_speed = 0;
max_hp = BALANCE_PLAYER_BUILDING_MAX_HP;
hp = max_hp;
effect_radius = BALANCE_GRAVE_SPIRE_RADIUS;
corruption_bar_visible = false;
morning_spawn_radius = BALANCE_CAPTURED_SPAWN_BUILDING_RADIUS;
corruption_check_interval = BALANCE_PLAYER_BUILDING_CORRUPTION_CHECK_INTERVAL;
corruption_check_timer = irandom(corruption_check_interval - 1);
morning_unit_object = o_skeleton;

var _base_skeleton_count_text = string(BALANCE_GRAVE_SPIRE_BASE_SKELETON_COUNT);
var _skeletons_per_grave_text = string(BALANCE_GRAVE_SPIRE_SKELETONS_PER_GRAVE);

tooltip_lines = [
	"Grave Spire: spawns Skeletons every morning",
	"Base: " + _base_skeleton_count_text + " Skeleton. Each nearby Grave adds +" + _skeletons_per_grave_text,
	"Stops working if its ground is cleansed"
];

grave_spire_grave_count_get = function()
{
	var _grave_count = instance_number(o_grave);
	var _owned_grave_count = 0;

	for (var _grave_index = 0; _grave_index < _grave_count; ++_grave_index)
	{
		var _grave = instance_find(o_grave, _grave_index);

		if (!instance_exists(_grave)
			|| point_distance(x, y, _grave.x, _grave.y) > effect_radius)
		{
			continue;
		}

		if (!variable_instance_exists(_grave, "assigned_grave_spire")
			|| !instance_exists(_grave.assigned_grave_spire)
			|| _grave.assigned_grave_spire == id)
		{
			if (!variable_instance_exists(_grave, "assigned_grave_spire")
				|| !instance_exists(_grave.assigned_grave_spire))
			{
				_grave.assigned_grave_spire = id;
			}

			_owned_grave_count++;
		}
	}

	return _owned_grave_count;
};

grave_spire_morning_skeleton_count_get = function()
{
	if (!is_captured)
	{
		return 0;
	}

	return BALANCE_GRAVE_SPIRE_BASE_SKELETON_COUNT
		+ (grave_spire_grave_count_get() * BALANCE_GRAVE_SPIRE_SKELETONS_PER_GRAVE);
};

grave_spire_spawn_morning_units = function()
{
	var _expected_unit_count = grave_spire_morning_skeleton_count_get();
	var _unit_count = floor(_expected_unit_count);
	var _fractional_unit_chance = _expected_unit_count - _unit_count;

	if (random(1) < _fractional_unit_chance)
	{
		_unit_count++;
	}

	for (var _unit_index = 0; _unit_index < _unit_count; ++_unit_index)
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
