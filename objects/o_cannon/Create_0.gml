// Cannon target selected by the player.
max_hp = 300;
hp = max_hp;

// Cannon health bar visual settings.
bar_width = 84;
bar_height = 7;
bar_offset_y = 58;

target_exists = false;
target_x = x;
target_y = y;
target_projectile_type = PROJECTILE_TYPE.DAMAGE;
target_version = -1;

// Projectile settings passed to created projectile instances.
projectile_effect_radius = BALANCE_PROJECTILE_EFFECT_RADIUS;
volley_projectile_count = BALANCE_CANNON_VOLLEY_PROJECTILE_COUNT;
volley_spread_radius = BALANCE_CANNON_VOLLEY_SPREAD_RADIUS;
volley_launch_delay_min = BALANCE_CANNON_VOLLEY_LAUNCH_DELAY_MIN;
volley_launch_delay_max = BALANCE_CANNON_VOLLEY_LAUNCH_DELAY_MAX;
projectile_spawn_offset_y = -20;
projectile_layer_name = "Instances";

// Cannon starts with corrupted ground around it.
starting_corruption_radius_in_cells = 6;
starting_corruption_radius = starting_corruption_radius_in_cells * 100;
starting_corruption_amount = 1;

corrupt_circle(x, y, starting_corruption_radius, starting_corruption_amount);
