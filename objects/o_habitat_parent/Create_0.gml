// Initialize shared player map-building state.
event_inherited();
player_map_building_ruins_enabled = true;
player_map_building_destroyed_sprite = s_house2_destroyed;

// Habitat durability and captured appearance.
max_hp = habitat_max_hp;
hp = max_hp;
player_building_cleansed_base_max_hp = max_hp;
tower_capture_enabled = false;
is_captured = true;
uncaptured_sprite_index = habitat_sprite;
captured_sprite_index = habitat_sprite;
sprite_index = captured_sprite_index;
image_index = 0;
image_speed = 0;
corruption_bar_visible = false;

// Resident slots are restored every morning.
owned_units = array_create(habitat_unit_count, noone);

tooltip_lines = [
	habitat_display_name + " houses " + string(habitat_unit_count) + " allied " + habitat_unit_display_name + ".",
	"Residents defend against enemies within " + string(habitat_defense_radius) + "px of this habitat.",
	"Every morning restores their count and HP."
];

habitat_home_position_get = function(_slot_index)
{
	var _centered_index = _slot_index - ((habitat_unit_count - 1) * 0.5);
	var _home_x = x + (_centered_index * habitat_home_spacing);
	var _home_y = y + habitat_home_offset_y;

	return [_home_x, _home_y];
};

habitat_unit_is_bound = function(_unit)
{
	return instance_exists(_unit)
		&& _unit.object_index == habitat_unit_object
		&& variable_instance_exists(_unit, "owner_habitat")
		&& _unit.owner_habitat == id;
};

habitat_unit_create = function(_slot_index)
{
	if (_slot_index < 0 || _slot_index >= habitat_unit_count)
	{
		return noone;
	}

	var _home_position = habitat_home_position_get(_slot_index);
	var _unit = instance_create_layer(_home_position[0], _home_position[1], "Instances", habitat_unit_object);

	if (!instance_exists(_unit))
	{
		return noone;
	}

	with (_unit)
	{
		habitat_unit_initialize();
	}

	_unit.habitat_defense_radius = habitat_defense_radius;
	_unit.vision_radius = habitat_defense_radius;
	_unit.target_detection_radius = habitat_defense_radius;
	_unit.habitat_return_delay = habitat_return_delay;
	_unit.habitat_return_radius = habitat_return_radius;
	_unit.owner_habitat = id;
	_unit.habitat_slot_index = _slot_index;
	_unit.habitat_home_offset_x = _home_position[0] - x;
	_unit.habitat_home_offset_y = _home_position[1] - y;
	_unit.habitat_home_x = _home_position[0];
	_unit.habitat_home_y = _home_position[1];
	owned_units[_slot_index] = _unit;

	return _unit;
};

habitat_owned_units_destroy = function()
{
	var _owned_unit_count = array_length(owned_units);

	for (var _slot_index = 0; _slot_index < _owned_unit_count; ++_slot_index)
	{
		var _unit = owned_units[_slot_index];

		if (habitat_unit_is_bound(_unit))
		{
			instance_destroy(_unit);
		}

		owned_units[_slot_index] = noone;
	}
};

habitat_morning_restore = function()
{
	for (var _slot_index = 0; _slot_index < habitat_unit_count; ++_slot_index)
	{
		var _unit = owned_units[_slot_index];

		if (!habitat_unit_is_bound(_unit))
		{
			_unit = habitat_unit_create(_slot_index);
		}

		if (habitat_unit_is_bound(_unit))
		{
			_unit.hp = _unit.max_hp;
		}
	}
};

// Resident units disappear with the destroyed habitat and return after its morning repair.
player_map_building_ruins_enter = function()
{
	habitat_owned_units_destroy();
};

// A newly constructed habitat starts with its complete healthy population.
habitat_morning_restore();
