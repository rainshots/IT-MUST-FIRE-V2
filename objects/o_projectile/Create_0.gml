// Projectile route settings assigned by the firing cannon after creation.
start_x = x;
start_y = y;
target_x = x;
target_y = y;
projectile_type = PROJECTILE_TYPE.DAMAGE;

// Explosion and effect settings.
effect_radius = 200;
damage_amount = 10;
corruption_amount = 1;
ground_corruption_amount = 0.34;
smoke_particle_count = 22;
particle_layer_name = "Instances";

// Flight settings.
flight_time = 1.4 * room_speed;
flight_timer = 0;
arc_height = 260;

// Visual settings.
projectile_radius = 12;
explosion_preview_frames = 8;
draw_explosion_preview = false;
