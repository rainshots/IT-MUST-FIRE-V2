// Cultist identity chosen by the player before the first night.
cultist_name = "";
demon_type = DEMON_TYPE.NONE;
demon_ability = DEMON_ABILITY.NONE;

// Core character attributes. These persist through demon form changes.
cultist_points = cultist_points_roll();
current_exp = 0;
current_lvl = 1;
pending_level_points = 0;
y_sort_enabled = true;

// Day-form health is synced with the chosen demon form after selection.
max_hp = 1;
hp = max_hp;

// Visual settings for the day form labels and shared health bar style.
name_offset_y = 8;
bar_width = 34;
bar_height = 4;
name_health_bar_gap = 8;

// Drag state is controlled by o_game_controller during manual cultist repositioning.
is_being_dragged = false;
drag_drop_x = x;
drag_drop_y = y;

// Building work assignment. The game controller updates these when dropped on a building.
assigned_building = noone;
is_assigned_to_building = false;
