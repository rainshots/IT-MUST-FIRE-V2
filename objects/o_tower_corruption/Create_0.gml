// Initialize shared map object state.
event_inherited();

// Capture state changes the tower sprite and unlocks the passive effect.
tower_capture_enabled = true;
is_captured = false;
uncaptured_sprite_index = s_corruption_tower_b;
captured_sprite_index = s_corruption_tower;
sprite_index = uncaptured_sprite_index;
image_speed = 0;

// Corruption tower gradually infects nearby ground after capture.
effect_radius = BALANCE_TOWER_CORRUPTION_SPREAD_RADIUS;
spread_per_second = BALANCE_TOWER_CORRUPTION_SPREAD_PER_SECOND;
spread_update_interval = BALANCE_TOWER_CORRUPTION_SPREAD_UPDATE_INTERVAL;
spread_update_timer = irandom(spread_update_interval - 1);

// Tooltip lines describe captured tower behavior.
tooltip_lines = [
	"Captured: spreads corruption in a 600px radius",
	"Capture: requires full corruption under the tower",
	"Hover: shows effect radius"
];
