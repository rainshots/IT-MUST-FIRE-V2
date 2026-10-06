// All encounter state lives here; the persistent world map owns campaign progress.
nodes = []; // Building structs; no per-building Step or collision instances.
armies = []; // Moving groups retain their allegiance even after their source is captured.
shots = []; // Short-lived tower tracers, updated separately from drawing.
scenery = []; // Fixed decorative placements generated once per encounter.
selected_nodes = []; // Indices of player buildings receiving group orders.
hovered_node = -1;
pressed_node = -1;
pointer_start_x = 0;
pointer_start_y = 0;
pointer_down = false;
box_selecting = false;
send_fraction = 0.5; // Number keys 1-4 select 25/50/75/100 percent.
paused = false;
phase = BATTLE_PHASE.BATTLE;
elapsed_seconds = 0;
ai_timer = BALANCE_CONQUEST_AI_OPENING_SECONDS; // Seconds until the next enemy decision.
ai_interval_seconds = BALANCE_CONQUEST_AI_INTERVAL; // Mission-specific delay between enemy decisions.
ai_turn = 0;
feedback = "Drag from your red settlement to another building.";
feedback_timer = 9;
level_title = "Ashen Crossing";
level_index = 0;
campaign_map = instance_find(o_world_map, 0);

// Fixed reference canvas matches the campaign screen and scales with the window.
gui_width = 1920;
gui_height = 1080;
field_top = 90;
field_bottom = 896;
ui_font = font_add("Arial", 17, false, false, 32, 127);
number_font = font_add("Arial", 23, true, false, 32, 127);
heading_font = font_add("Arial", 28, true, false, 32, 127);
display_set_gui_size(gui_width, gui_height);
game_set_speed(BALANCE_GAME_SPEED_NORMAL, gamespeed_fps);
window_set_cursor(cr_default);
conquest_level_prepare(id);
