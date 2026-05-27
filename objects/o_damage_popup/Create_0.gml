// Popup lifetime and fade settings.
life_time = 0.8 * room_speed;
life_timer = 0;
start_alpha = 1;
current_alpha = start_alpha;

// Popup movement settings.
move_speed_x = random_range(-0.25, 0.25);
move_speed_y = -0.8;

// Popup text values are set by damage_popup_create after creation.
popup_text = "";
popup_color = c_white;
is_critical = false;
text_offset_y = -22;
