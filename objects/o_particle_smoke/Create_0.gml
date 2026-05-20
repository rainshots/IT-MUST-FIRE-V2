// Smoke lifetime and fade settings.
life_time = 2.2 * room_speed;
life_timer = 0;
start_alpha = 0.45;
current_alpha = start_alpha;

// Smoke movement drifts slowly upward with slight horizontal variation.
move_speed_x = random_range(-0.22, 0.22);
move_speed_y = random_range(-0.75, -0.28);

// Smoke grows slowly while fading out.
start_radius = random_range(16, 34);
end_radius = start_radius * random_range(1.8, 2.6);
current_radius = start_radius;

// Smoke visual color.
smoke_color = COLOR_PARTICLE_SMOKE;
