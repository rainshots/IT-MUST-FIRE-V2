// Configure this habitat before shared initialization spawns its residents.
habitat_sprite = s_pitlings_house;
habitat_unit_object = o_balgor;
habitat_display_name = "Demon Habitat";
habitat_unit_display_name = "Balgors";
habitat_max_hp = BALANCE_HABIT_DEMONS_MAX_HP;
habitat_unit_count = BALANCE_HABIT_DEMONS_UNIT_COUNT;
habitat_home_spacing = BALANCE_HABIT_DEMONS_HOME_SPACING;
habitat_home_offset_y = BALANCE_HABIT_DEMONS_HOME_OFFSET_Y;
habitat_defense_radius = BALANCE_HABIT_DEMONS_DEFENSE_RADIUS;
habitat_return_delay = BALANCE_HABIT_DEMONS_RETURN_DELAY * room_speed;
habitat_return_radius = BALANCE_HABIT_DEMONS_RETURN_RADIUS;

event_inherited();
