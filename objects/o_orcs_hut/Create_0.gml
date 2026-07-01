// Initialize shared map object state.
event_inherited();

// Capture state changes the hut sprite and unlocks neutral orc workers.
tower_capture_enabled = true;
is_captured = false;
uncaptured_sprite_index = s_orks_hut_b;
captured_sprite_index = s_orks_hut;
sprite_index = uncaptured_sprite_index;
image_speed = 0;

// Orc workers haul corpses only from this radius around the hut.
base_effect_radius = BALANCE_ORCS_HUT_CORPSE_SEARCH_RADIUS;
base_orc_count = BALANCE_ORCS_HUT_ORC_COUNT;
effect_radius = base_effect_radius;
orc_count = base_orc_count;
orc_home_spacing = BALANCE_ORCS_HUT_ORC_HOME_SPACING;
owned_orcs = array_create(0);

// Tooltip lines describe captured hut behavior.
tooltip_lines = [
	"Captured: 2 neutral orcs haul corpses to the cannon during the day",
	"Range: orcs use corpses within 500px of the hut",
	"Night: orcs return home"
];

building_has_upgrades = true;
building_tooltip_description = "Improves this Orcs Hut.";
building_upgrade_levels = [0, 0];
building_upgrade_names = ["Wider Patrol", "Extra Hauler"];
building_upgrade_descriptions = ["+20% corpse search radius.", "+1 neutral orc."];
building_upgrade_resources = [RESOURCES.FLESH, RESOURCES.FLESH];
building_upgrade_costs = [BALANCE_ORCS_HUT_RADIUS_UPGRADE_FLESH_COST, BALANCE_ORCS_HUT_ORC_COUNT_UPGRADE_FLESH_COST];
building_upgrade_level_maxes = [BALANCE_ORCS_HUT_RADIUS_UPGRADE_MAX, BALANCE_ORCS_HUT_ORC_COUNT_UPGRADE_MAX];

map_building_upgrade_effect_apply = function(_upgrade_index)
{
	effect_radius = base_effect_radius * (1 + (building_upgrade_levels[0] * BALANCE_ORCS_HUT_RADIUS_UPGRADE_BONUS));
	orc_count = base_orc_count + (building_upgrade_levels[1] * BALANCE_ORCS_HUT_ORC_COUNT_UPGRADE_BONUS);
	array_resize(owned_orcs, orc_count);

	if (is_captured)
	{
		orcs_hut_spawn_orcs();
		orcs_hut_recall_orcs();
	}
};

orcs_hut_orc_home_position_get = function(_orc_index)
{
	var _offset_x = (_orc_index - ((orc_count - 1) * 0.5)) * orc_home_spacing;
	var _offset_y = 36;

	return [x + _offset_x, y + _offset_y];
};

orcs_hut_spawn_orcs = function()
{
	for (var _orc_index = 0; _orc_index < orc_count; ++_orc_index)
	{
		var _existing_orc = noone;

		if (_orc_index < array_length(owned_orcs))
		{
			_existing_orc = owned_orcs[_orc_index];
		}

		if (instance_exists(_existing_orc))
		{
			continue;
		}

		var _home_position = orcs_hut_orc_home_position_get(_orc_index);
		var _orc = instance_create_layer(_home_position[0], _home_position[1], "Instances", o_orc);

		if (instance_exists(_orc))
		{
			_orc.owner_hut = id;
			_orc.home_offset_x = _home_position[0] - x;
			_orc.home_offset_y = _home_position[1] - y;
			_orc.home_x = _home_position[0];
			_orc.home_y = _home_position[1];
			owned_orcs[_orc_index] = _orc;
		}
	}
};

orcs_hut_recall_orcs = function()
{
	for (var _orc_index = 0; _orc_index < array_length(owned_orcs); ++_orc_index)
	{
		var _orc = owned_orcs[_orc_index];

		if (instance_exists(_orc))
		{
			var _home_position = orcs_hut_orc_home_position_get(_orc_index);

			_orc.home_offset_x = _home_position[0] - x;
			_orc.home_offset_y = _home_position[1] - y;
			_orc.home_x = _home_position[0];
			_orc.home_y = _home_position[1];
		}
	}
};
