// Reuse Cursed Point capture, construction-menu, and Cultist-job behavior.
event_inherited();

// The point switches appearance according to the Taint under it.
uncaptured_sprite_index = s_point_trap_disabled;
captured_sprite_index = s_point_trap_active;
sprite_index = is_captured ? captured_sprite_index : uncaptured_sprite_index;
image_index = 0;
image_speed = 0;

// Draw the placement point above the ground but below every gameplay object.
cursed_point_draw_above_tile_layer();
trap_layer_name = "Instances";

// Trap-specific world and selection menu text.
summon_button_text = "INSTALL TRAP";
summon_button_night_text = "Available at daytime";
structure_selection_title = "Install Trap";
structure_selection_subtitle = "Choose one trap to install";
tooltip_lines = [
	"Taint the ground under this point",
	"to install a trap here."
];

// The selected trap type and formation remain bound to this point for restoration.
trap_formation_count = BALANCE_TRAP_POINT_TRAP_COUNT;
trap_formation_ring_count = trap_formation_count - 1;
trap_formation_radius = BALANCE_TRAP_POINT_FORMATION_RADIUS;
trap_formation_start_angle = -90;
installed_traps = array_create(trap_formation_count, noone);
installed_trap_choice = noone;

var _trap_choices = [
	{
		building_object: o_pumpkin_mine,
		building_sprite: s_pumpkin_mine,
		building_name: "Pumpkin Mine",
		building_description: "Explodes after detecting a group and damages every enemy in its radius."
	},
	{
		building_object: o_steel_trap,
		building_sprite: s_steel_trap,
		building_name: "Steel Trap",
		building_description: "Activates after detecting a group and stuns every enemy in its radius."
	}
];

structure_choice_packs = [_trap_choices];
structure_choice_options = [];
structure_choice_options_rolled = false;

// The installed formation reserves the point even when some traps are consumed.
cursed_point_interaction_is_blocked = function()
{
	var _construction_is_pending = variable_instance_exists(id, "construction_event_pending")
		&& construction_event_pending;

	return _construction_is_pending || is_struct(installed_trap_choice);
};

// Clicking either the active point sprite or its world button opens trap selection.
cursed_point_summon_button_is_hovered = function()
{
	if (!is_captured
		|| structure_selection_open
		|| cursed_point_interaction_is_blocked()
		|| global.day_phase != DAY_PHASE.DAY
		|| global.focus_window != FOCUS_WINDOW.NOONE)
	{
		return false;
	}

	var _mouse_position = cursed_point_mouse_world_position_get();
	var _button_rect = cursed_point_summon_button_rect_get();
	var _hover_rect = cursed_point_rect_expand(_button_rect, summon_button_hover_scale);
	var _point_is_hovered = _mouse_position[0] >= bbox_left
		&& _mouse_position[0] <= bbox_right
		&& _mouse_position[1] >= bbox_top
		&& _mouse_position[1] <= bbox_bottom;
	var _button_is_hovered = _mouse_position[0] >= _hover_rect[0]
		&& _mouse_position[0] <= _hover_rect[0] + _hover_rect[2]
		&& _mouse_position[1] >= _hover_rect[1]
		&& _mouse_position[1] <= _hover_rect[1] + _hover_rect[3];

	return _point_is_hovered || _button_is_hovered;
};

trap_point_slot_position_get = function(_slot_index)
{
	// The first trap occupies the point center.
	if (_slot_index == 0)
	{
		return [x, y];
	}

	// The remaining traps are spaced evenly around the center.
	var _ring_index = _slot_index - 1;
	var _angle_step = 360 / trap_formation_ring_count;
	var _angle = trap_formation_start_angle + (_ring_index * _angle_step);
	var _trap_x = x + lengthdir_x(trap_formation_radius, _angle);
	var _trap_y = y + lengthdir_y(trap_formation_radius, _angle);

	return [_trap_x, _trap_y];
};

trap_point_trap_bind = function(_trap, _slot_index)
{
	if (!instance_exists(_trap)
		|| _slot_index < 0
		|| _slot_index >= trap_formation_count)
	{
		return false;
	}

	installed_traps[_slot_index] = _trap;
	_trap.owner_trap_point = id;
	_trap.trap_point_slot_index = _slot_index;
	_trap.depth = -floor(_trap.y);
	return true;
};

trap_point_trap_create = function(_slot_index)
{
	if (!is_struct(installed_trap_choice)
		|| !variable_struct_exists(installed_trap_choice, "building_object")
		|| _slot_index < 0
		|| _slot_index >= trap_formation_count
		|| instance_exists(installed_traps[_slot_index]))
	{
		return false;
	}

	// Create the missing trap in its assigned formation slot.
	var _trap_position = trap_point_slot_position_get(_slot_index);
	var _trap = instance_create_layer(
		_trap_position[0],
		_trap_position[1],
		trap_layer_name,
		installed_trap_choice.building_object
	);

	return trap_point_trap_bind(_trap, _slot_index);
};

// Persistent construction sites receive the completed object instead of being destroyed.
construction_site_complete = function(_built_object, _choice)
{
	if (!instance_exists(_built_object) || !is_struct(_choice))
	{
		return false;
	}

	installed_trap_choice = _choice;
	construction_event_pending = false;
	installed_traps = array_create(trap_formation_count, noone);

	// The construction result becomes the central trap.
	var _center_was_bound = trap_point_trap_bind(_built_object, 0);

	// Fill the five evenly spaced slots around it.
	for (var _slot_index = 1; _slot_index < trap_formation_count; ++_slot_index)
	{
		trap_point_trap_create(_slot_index);
	}

	// Hide the consumed placement marker while keeping its restoration state alive.
	visible = false;

	return _center_was_bound;
};

trap_point_morning_restore = function()
{
	if (!is_struct(installed_trap_choice)
		|| !variable_struct_exists(installed_trap_choice, "building_object"))
	{
		return false;
	}

	var _restored_any_trap = false;

	// Restore only formation slots whose traps were consumed.
	for (var _slot_index = 0; _slot_index < trap_formation_count; ++_slot_index)
	{
		if (!instance_exists(installed_traps[_slot_index]))
		{
			_restored_any_trap = trap_point_trap_create(_slot_index) || _restored_any_trap;
		}
	}

	return _restored_any_trap;
};
