// Initialize shared map object state.
event_inherited();

// Capture state changes the tower sprite and unlocks combat.
tower_capture_enabled = true;
is_captured = false;
uncaptured_sprite_index = s_damage_tower_b ;
captured_sprite_index = s_damage_tower;
sprite_index = uncaptured_sprite_index;
image_speed = 0;

// Damage tower shoots the nearest enemy inside its radius.
shoot_radius = BALANCE_TOWER_DAMAGE_RADIUS;
damage = BALANCE_TOWER_DAMAGE_AMOUNT;
reload_time = BALANCE_TOWER_DAMAGE_RELOAD_TIME * room_speed;
reload_timer = 0;
target_instance = noone;

// Attack feedback shows the tower shot for a short moment.
attack_feedback_time = BALANCE_TOWER_ATTACK_FEEDBACK_TIME * room_speed;
attack_feedback_timer = 0;
attack_feedback_target = noone;
attack_feedback_target_x = x;
attack_feedback_target_y = y;
attack_feedback_line_width = 2;

// Tooltip lines describe captured tower behavior.
tooltip_lines = [
	"Captured: shoots enemies in a 600px radius",
	"Capture: requires full Taint under the tower",
	"Hover: shows shooting radius"
];
