// Initialize shared map object state.
event_inherited();

// Capture state changes the tower sprite and unlocks healing.
tower_capture_enabled = true;
is_captured = false;
uncaptured_sprite_index = s_heal_tower_b;
captured_sprite_index = s_heal_tower;
sprite_index = uncaptured_sprite_index;
image_speed = 0;

// Heal tower restores allied troops inside its radius.
heal_radius = BALANCE_TOWER_HEAL_RADIUS;
heal_amount = BALANCE_TOWER_HEAL_AMOUNT;
heal_tick_time = BALANCE_TOWER_HEAL_TICK_TIME * room_speed;
heal_tick_timer = irandom(heal_tick_time - 1);

// Tooltip lines describe captured tower behavior.
tooltip_lines = [
	"Captured: heals friendly troops in a 600px radius",
	"Capture: requires full Taint under the tower",
	"Hover: shows healing radius"
];
