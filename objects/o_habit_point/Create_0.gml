// Reuse Cursed Point capture, construction-menu, and Cultist-job behavior.
event_inherited();

// Use the authored Habitat Point sprites when they are present in the project.
var _disabled_sprite = asset_get_index("s_point_habit_disabled");
var _active_sprite = asset_get_index("s_point_habit_active");

if (!sprite_exists(_disabled_sprite))
{
	_disabled_sprite = s_point_trap_disabled;
}

if (!sprite_exists(_active_sprite))
{
	_active_sprite = s_point_trap_active;
}

uncaptured_sprite_index = _disabled_sprite;
captured_sprite_index = _active_sprite;
sprite_index = is_captured ? captured_sprite_index : uncaptured_sprite_index;
is_attackable = false;
image_index = 0;
image_speed = 0;

// Draw the placement point above the ground but below every gameplay object.
cursed_point_draw_above_tile_layer();

// Habitat-specific world and selection menu text.
summon_button_text = "BUILD HABITAT";
summon_button_night_text = "Available at daytime";
structure_selection_title = "Build Habitat";
structure_selection_subtitle = "Choose a habitat to build";
tooltip_lines = [
	"Taint the ground under this point",
	"to build a unit habitat here."
];

var _habitat_choices = [
	{
		building_object: o_orcs_pit,
		building_sprite: s_orks_hut,
		building_name: "Orcs Pit",
		building_description: "Houses two strong allied Orcs that defend the surrounding area."
	}
];

structure_choice_packs = [_habitat_choices];
structure_choice_options = [];
structure_choice_options_rolled = false;

// Clicking either the active point sprite or its world button opens habitat selection.
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
