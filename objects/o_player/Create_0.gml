// Movement speed in world pixels per second, used by Step.
move_speed = BALANCE_PLAYER_MOVE_SPEED;

// Health and reconstruction state used by blast damage, movement, healing, and the cannon.
max_hp = BALANCE_PLAYER_MAX_HP;
hp = max_hp;
is_disassembled = false;
death_lock_remaining = 0;
body_parts = [];
body_parts_collected = 0;
// Keep the avatar's ground footprint stable when changing between skeleton and skull sprites.
mask_index = s_skeleton;

// Remaining slowdown time in seconds; Step refreshes it when new ground is infected.
corruption_slow_remaining = 0;

// Seconds of uninterrupted movement on existing Taint, excluding infection recovery.
taint_run_elapsed = 0;

// World-space vision radius used by the fog controller.
vision_radius = BALANCE_PLAYER_VISION_RADIUS;

// The skeleton sprite has a single frame.
image_speed = 0;

// Match ordinary units: alternate a small sprite tilt while actually moving in Step.
walk_sway_angle = 4;
walk_sway_half_time = 0.16;
walk_sway_timer = 0;
walk_sway_direction = 1;

// Shared live input query lets the cannon respond without depending on Step event order.
player_taunt_is_active = function()
{
	return !is_disassembled
		&& death_lock_remaining <= 0
		&& !global.pause
		&& global.focus_window == FOCUS_WINDOW.NOONE
		&& window_has_focus()
		&& keyboard_check(vk_space);
};
