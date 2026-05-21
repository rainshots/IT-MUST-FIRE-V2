// Global pause state used by gameplay objects.
global.pause = false;
global.focus_window = FOCUS_WINDOW.NOONE;

// Global cannon target selected through the target selection mode.
global.cannon_target_exists = false;
global.cannon_target_x = 0;
global.cannon_target_y = 0;
global.cannon_target_projectile_type = PROJECTILE_TYPE.DAMAGE;
global.cannon_target_version = 0;

// Global resource storage used by HUD and economy systems.
global.resources = array_create(RESOURCES.COUNT, 0);
global.resources[RESOURCES.SOULS] = 0;
global.resources[RESOURCES.IRON] = 0;
global.resources[RESOURCES.CULTISTS] = 0;

// Base window and GUI size for the strategy view.
base_view_width = 1366;
base_view_height = 768;
target_aspect_ratio = base_view_width / base_view_height;

// Camera view keeps fixed proportions to prevent visual stretching.
camera_view_width = base_view_width;
camera_view_height = base_view_height;

// Window and GUI size follow the actual player window.
main_view_index = 0;
current_view_width = base_view_width;
current_view_height = base_view_height;
windowed_view_width = base_view_width;
windowed_view_height = base_view_height;
previous_window_width = base_view_width;
previous_window_height = base_view_height;
application_surface_ready = false;

// Pause menu state.
pause_menu_open = false;
settings_open = false;
fullscreen_enabled = window_get_fullscreen();

// Target selection state.
target_selection_projectile_type = PROJECTILE_TYPE.DAMAGE;
target_selection_radius = BALANCE_PROJECTILE_EFFECT_RADIUS;
target_selection_alpha = 0.35;
target_selection_outline_alpha = 0.85;

// Pause menu button data.
continue_button_index = 0;
settings_button_index = 1;
quit_button_index = 2;
pause_button_labels = ["CONTINUE", "SETTINGS", "QUIT"];
pause_button_count = array_length(pause_button_labels);

// Menu visual settings.
overlay_alpha = 0.45;
button_width = 280;
button_height = 58;
button_gap = 18;
settings_panel_width = 420;
settings_panel_height = 220;
fullscreen_toggle_size = 34;
settings_toggle_right_padding = 82;
settings_toggle_top_padding = 84;
settings_close_bottom_padding = 28;

// Window setup for a non-stretched 16:9 camera.
window_set_size(base_view_width, base_view_height);
display_set_gui_size(camera_view_width, camera_view_height);
application_surface_draw_enable(true);
view_xport[main_view_index] = 0;
view_yport[main_view_index] = 0;
view_wport[main_view_index] = camera_view_width;
view_hport[main_view_index] = camera_view_height;

if (surface_exists(application_surface))
{
	surface_resize(application_surface, camera_view_width, camera_view_height);
	application_surface_ready = true;
}
