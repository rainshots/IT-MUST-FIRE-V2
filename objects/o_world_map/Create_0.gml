// The persistent map owns campaign progress and the same squad structs used in battles.
if (instance_number(o_world_map) > 1)
{
	instance_destroy();
	exit;
}
persistent = true;
squads = battle_roster_create();
start_level = o_level_01; // The only point available in a new campaign.
captured_levels = []; // Object assets remain valid after leaving a room.
last_captured_level = noone; // Only successors of this point can be attacked.
active_level = noone; // The point whose battle is running.
active_battle_room = -1;
levels = []; // Rebuilt from o_level_parent children when entering the map.
roster_cards = []; // Sorted references shared by input and drawing.

// Hover previews an entry; a click pins it until another click or Escape.
hovered_level = noone;
hovered_squad = noone;
pinned_level = noone;
pinned_squad = noone;
info_level = noone;
info_squad = noone;
info_scroll = 0;
info_scroll_max = 0;
attack_is_hovered = false;

// Reference canvas; point positions are edited directly in the Room Editor.
gui_width = 1920;
gui_height = 1080;

// Gray ground follows the rightmost captured point; its position persists across battles.
taint_boundary_padding = 22; // Ground extends slightly beyond a captured point's sprite.
taint_boundary_speed = 360; // GUI pixels per second while the frontier advances.
taint_boundary_x = -1; // Initialized from the starting point on the first map entry.
taint_boundary_target_x = 0;
taint_layer_name = "Instances_1"; // Ground layer between the Background and decorative instances.
taint_grid_instance = noone; // Rebound to the room's corruption grid on every map entry.
taint_edge_variation_cells = 1; // Small steps keep the frontier uneven but continuous.
taint_edge_min_band_rows = 2;
taint_edge_max_band_rows = 5;
taint_row_offsets = []; // Retained between battles so the edge does not reroll on return.
taint_row_columns = []; // Number of filled cells per row in the current room's grid.
taint_applied_column = -1; // Rebuild cells only when the animated frontier crosses a cell boundary.

point_hover_padding = 8;
point_outline_scale = 1.14;
level_line_thickness_scale = 1.8; // Match the enlarged point sprites placed in the Room Editor.
panel_x = 1431;
panel_y = 74;
panel_width = 456;
panel_height = 856;
panel_padding = 32;
panel_content_y = 192;
panel_content_bottom = 850;
panel_content_surface = -1; // Clips long descriptions and unit lists.
attack_x = 1495;
attack_y = 877;
attack_width = 313;
attack_height = 80;
card_x = 643;
card_y = 887;
card_width = 112;
card_height = 145;
card_gap = 19;
icon_size = 68;
icon_gap = 16;
icon_columns = 4;
scroll_step = 48;

// Map fonts also work before the battle controller creates global UI state.
map_font = font_add("Arial", 16, false, false, 32, 127);
map_heading_font = font_add("Arial", 28, true, false, 32, 127);
map_card_font = font_add("Arial", 14, true, false, 32, 127);
window_set_size(1366, 768);
