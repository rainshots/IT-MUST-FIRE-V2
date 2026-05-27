// Popup lifetime and fade settings.
life_time = 0.9 * room_speed;
life_timer = 0;
start_alpha = 1;
current_alpha = start_alpha;

// Popup movement settings.
move_speed_x = random_range(-0.12, 0.12);
move_speed_y = -0.65;

// Popup text values are set by ability_popup_create after creation.
popup_text = "";
popup_color = COLOR_ABILITY_POPUP;
text_offset_y = -42;
text_scale = 1.15;

