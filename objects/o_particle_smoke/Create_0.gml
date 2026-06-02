// Smoke lifetime and fade settings.
life_time = 2.2 * room_speed;
life_timer = 0;
start_alpha = random_range(0.32, 0.55);
current_alpha = start_alpha;

// Smoke movement drifts slowly upward with slight horizontal variation.
move_speed_x = random_range(-0.35, 0.35);
move_speed_y = random_range(-0.85, -0.25);

// Smoke sprite grows slowly while fading out.
sprite_index = s_smoke_small_particle;
image_speed = 0;
image_angle = random(360);
start_scale = random_range(2.5, 3);
end_scale = start_scale * random_range(1.8, 2.5);
current_scale = start_scale;

// Smoke visual color.
smoke_color = COLOR_PARTICLE_SMOKE;
y_sort_enabled = true;
