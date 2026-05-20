// Explosion lifetime and fade settings.
life_time = 0.35 * room_speed;
life_timer = 0;
start_alpha = 0.9;
current_alpha = start_alpha;

// Explosion expands quickly from the impact point.
start_radius = 18;
end_radius = 95;
current_radius = start_radius;

// Explosion visual colors.
inner_color = COLOR_PARTICLE_EXPLOSION_INNER;
outer_color = COLOR_PARTICLE_EXPLOSION_OUTER;
