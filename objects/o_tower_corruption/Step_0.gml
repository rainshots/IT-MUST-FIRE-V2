// Pause freezes tower capture and spreading.
if (global.pause)
{
	exit;
}

// Check whether the ground under the tower has fully corrupted.
tower_capture_update();

if (!is_captured || fire_finished || !instance_exists(o_corruption_grid))
{
	exit;
}

// The captured tower fires only for a limited lifetime.
fire_timer++;

if (fire_timer >= fire_duration)
{
	fire_finished = true;
	exit;
}

spread_update_timer++;

if (spread_update_timer < spread_update_interval)
{
	exit;
}

spread_update_timer = 0;

// Fire a taint shell into a random point inside the tower effect radius.
var _target_direction = random(360);
var _target_distance = sqrt(random(1)) * effect_radius;
var _target_x = x + lengthdir_x(_target_distance, _target_direction);
var _target_y = y + lengthdir_y(_target_distance, _target_direction);

tower_corruption_projectile_create(_target_x, _target_y, projectile_corruption_amount);
