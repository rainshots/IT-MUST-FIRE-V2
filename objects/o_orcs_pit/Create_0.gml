// Configure this habitat before shared initialization spawns its residents.
habitat_sprite = s_orks_hut;
habitat_unit_object = o_orc2;
habitat_display_name = "Orcs Pit";
habitat_unit_display_name = "Orcs";
habitat_max_hp = BALANCE_ORCS_PIT_MAX_HP;
habitat_unit_count = BALANCE_ORCS_PIT_ORC_COUNT;
habitat_home_spacing = BALANCE_ORCS_PIT_ORC_HOME_SPACING;
habitat_home_offset_y = BALANCE_ORCS_PIT_ORC_HOME_OFFSET_Y;
habitat_defense_radius = BALANCE_ORCS_PIT_DEFENSE_RADIUS;
habitat_return_delay = BALANCE_ORCS_PIT_RETURN_DELAY * room_speed;
habitat_return_radius = BALANCE_ORCS_PIT_RETURN_RADIUS;

event_inherited();
