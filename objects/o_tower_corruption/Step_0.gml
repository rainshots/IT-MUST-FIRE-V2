// Pause freezes tower capture and spreading.
if (global.pause)
{
	exit;
}

// Check whether the ground under the tower has fully corrupted.
tower_capture_update();

if (!is_captured || !instance_exists(o_corruption_grid))
{
	exit;
}

spread_update_timer++;

if (spread_update_timer < spread_update_interval)
{
	exit;
}

spread_update_timer = 0;

// Apply a small corruption step so the tower spreads infection gradually.
var _corruption_grid_object = instance_find(o_corruption_grid, 0);
var _corruption_amount = spread_per_second * (spread_update_interval / room_speed);
_corruption_grid_object.corrupt_circle(x, y, effect_radius, _corruption_amount);
