// Initialize shared player map-building state.
event_inherited();

// Orcs Pit durability and captured appearance.
max_hp = BALANCE_ORCS_PIT_MAX_HP;
hp = max_hp;
player_building_cleansed_base_max_hp = max_hp;
tower_capture_enabled = false;
is_captured = true;
uncaptured_sprite_index = s_orks_hut;
captured_sprite_index = s_orks_hut;
sprite_index = captured_sprite_index;
image_index = 0;
image_speed = 0;
corruption_bar_visible = false;

// Two bound Orc slots are restored by this habitat every morning.
habitat_unit_count = BALANCE_ORCS_PIT_ORC_COUNT;
habitat_home_spacing = BALANCE_ORCS_PIT_ORC_HOME_SPACING;
habitat_home_offset_y = BALANCE_ORCS_PIT_ORC_HOME_OFFSET_Y;
owned_orcs = array_create(habitat_unit_count, noone);

tooltip_lines = [
	"Orcs Pit: houses " + string(habitat_unit_count) + " strong allied Orcs.",
	"Orcs defend enemies within " + string(BALANCE_ORCS_PIT_DEFENSE_RADIUS) + "px of this habitat.",
	"Every morning restores their count and HP."
];

orcs_pit_home_position_get = function(_slot_index)
{
	var _centered_index = _slot_index - ((habitat_unit_count - 1) * 0.5);
	var _home_x = x + (_centered_index * habitat_home_spacing);
	var _home_y = y + habitat_home_offset_y;

	return [_home_x, _home_y];
};

orcs_pit_unit_is_bound = function(_unit)
{
	return instance_exists(_unit)
		&& _unit.object_index == o_orc2
		&& variable_instance_exists(_unit, "owner_habitat")
		&& _unit.owner_habitat == id;
};

orcs_pit_unit_create = function(_slot_index)
{
	if (_slot_index < 0 || _slot_index >= habitat_unit_count)
	{
		return noone;
	}

	var _home_position = orcs_pit_home_position_get(_slot_index);
	var _orc = instance_create_layer(_home_position[0], _home_position[1], "Instances", o_orc2);

	if (!instance_exists(_orc))
	{
		return noone;
	}

	_orc.owner_habitat = id;
	_orc.habitat_slot_index = _slot_index;
	_orc.habitat_home_offset_x = _home_position[0] - x;
	_orc.habitat_home_offset_y = _home_position[1] - y;
	_orc.habitat_home_x = _home_position[0];
	_orc.habitat_home_y = _home_position[1];
	owned_orcs[_slot_index] = _orc;

	return _orc;
};

orcs_pit_morning_restore = function()
{
	for (var _slot_index = 0; _slot_index < habitat_unit_count; ++_slot_index)
	{
		var _orc = owned_orcs[_slot_index];

		if (!orcs_pit_unit_is_bound(_orc))
		{
			_orc = orcs_pit_unit_create(_slot_index);
		}

		if (orcs_pit_unit_is_bound(_orc))
		{
			_orc.hp = _orc.max_hp;
		}
	}
};

// Destroyed habitats restore their own point type instead of a generic Cursed Point.
player_building_restore_point_create = function()
{
	if (!building_constructed_by_cursed_point
		|| !variable_instance_exists(id, "cursed_point_restore_choice")
		|| !is_struct(cursed_point_restore_choice))
	{
		return noone;
	}

	var _restore_point = instance_create_layer(x, y, "Instances", o_habit_point);

	if (!instance_exists(_restore_point))
	{
		return noone;
	}

	var _ground_is_tainted = ground_cell_corruption_get(x, y) > 0;
	_restore_point.is_captured = _ground_is_tainted;
	_restore_point.restore_structure_choice = cursed_point_restore_choice;
	_restore_point.structure_choice_options = [cursed_point_restore_choice];
	_restore_point.structure_choice_options_rolled = true;
	_restore_point.corruption = _ground_is_tainted ? _restore_point.max_corruption : 0;
	_restore_point.sprite_index = _ground_is_tainted
		? _restore_point.captured_sprite_index
		: _restore_point.uncaptured_sprite_index;
	_restore_point.image_index = 0;
	_restore_point.image_speed = 0;

	return _restore_point;
};

// A newly constructed habitat starts with its complete healthy population.
orcs_pit_morning_restore();
