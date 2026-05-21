// Projectile route settings assigned by the firing cannon after creation.
start_x = x;
start_y = y;
target_x = x;
target_y = y;
projectile_type = PROJECTILE_TYPE.DAMAGE;

// Explosion and effect settings.
effect_radius = BALANCE_PROJECTILE_EFFECT_RADIUS;
damage_amount = BALANCE_PROJECTILE_DAMAGE_AMOUNT;
corruption_amount = 1;
ground_corruption_amount = BALANCE_PROJECTILE_GROUND_CORRUPTION_AMOUNT;
smoke_particle_count = 22;
particle_layer_name = "Instances";

// Flight settings.
projectile_speed = BALANCE_PROJECTILE_SPEED;
minimum_flight_time = BALANCE_PROJECTILE_MIN_FLIGHT_TIME;
maximum_flight_time = BALANCE_PROJECTILE_MAX_FLIGHT_TIME;
launch_delay_timer = 0;
flight_time = minimum_flight_time * room_speed;
flight_timer = 0;
arc_height = 260;

// Visual settings.
projectile_radius = 12;
explosion_preview_frames = 8;
draw_explosion_preview = false;
