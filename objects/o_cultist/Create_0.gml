// Cultist identity chosen by the player before the first night.
cultist_name = "";
demon_type = DEMON_TYPE.NONE;
demon_ability = DEMON_ABILITY.NONE;

// Core character attributes. These persist through demon form changes.
cultist_points = cultist_points_roll();
current_exp = 0;
current_lvl = 1;
y_sort_enabled = true;

// Visual settings for the day form labels.
name_offset_y = 20;

// Drag state is controlled by o_game_controller during manual cultist repositioning.
is_being_dragged = false;
drag_drop_x = x;
drag_drop_y = y;

// Building work assignment. The game controller updates these when dropped on a building.
assigned_building = noone;
is_assigned_to_building = false;
