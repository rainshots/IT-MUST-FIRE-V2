// Cultist identity chosen by the player before the first night.
cultist_name = "";
demon_type = DEMON_TYPE.NONE;
demon_ability = DEMON_ABILITY.NONE;

// Core character attributes. These persist through demon form changes.
cultist_points = cultist_points_roll();
current_exp = 0;
current_lvl = 1;

// Visual settings for the day form labels.
bar_width = 36;
bar_height = 4;
bar_offset_y = 24;
name_offset_y = 36;

// Drag state is controlled by o_game_controller during manual cultist repositioning.
is_being_dragged = false;
drag_drop_x = x;
drag_drop_y = y;
