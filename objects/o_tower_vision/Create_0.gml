// Initialize shared map object state.
event_inherited();

// Capture state changes the tower sprite and unlocks fog reveal.
tower_capture_enabled = true;
is_captured = false;
uncaptured_sprite_index = s_watchtower_b;
captured_sprite_index =  s_watchtower;
sprite_index = uncaptured_sprite_index;
image_speed = 0;

// Vision tower reveals fog around itself after capture.
vision_radius = BALANCE_TOWER_VISION_RADIUS;

// Tooltip lines describe captured tower behavior.
tooltip_lines = [
	"Captured: reveals fog in a 1200px radius",
	"Capture: requires full Taint under the tower",
	"Hover: shows vision radius"
];
