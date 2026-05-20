// Cannon target selected by the player.
target_exists = false;
target_x = x;
target_y = y;
target_projectile_type = PROJECTILE_TYPE.DAMAGE;
target_version = -1;

// Shot timing. One shot every 15 seconds while target exists.
shot_interval = 15 * room_speed;
shot_timer = shot_interval;

// Projectile settings passed to created projectile instances.
projectile_effect_radius = 200;
projectile_spawn_offset_y = -20;
projectile_layer_name = "Instances";
