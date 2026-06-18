// HUD layout in GUI coordinates.
hud_margin_x = 18;
hud_margin_y = 16;
hud_sidebar_width = 431;
resource_item_width = 150;
resource_item_height = 34;
resource_item_gap = 10;
resource_icon_radius = 8;
resource_icon_size = 22;
resource_icon_text_gap = 12;
resource_text_padding = 20;
resource_sidebar_y = 48;
resource_sidebar_icon_size = 30;
resource_sidebar_first_icon_offset_x = 49;
resource_sidebar_item_gap = 128;
resource_sidebar_value_offset_x = 50;

// Cannon HP follows the wide bottom-bar concept from the HUD design.
cannon_hp_bar_width_share = 0.31875;
cannon_hp_fill_height_share = 0.0236;
cannon_hp_background_height_share = 0.01205;
cannon_hp_bottom_margin_share = 0.0185;
cannon_hp_background_offset_share = 0.006;
cannon_hp_label = "CANNON HP";
cannon_hp_label_scale = 0.5;

// First night prompt nudges the player to select the starting cultist projectile.
first_night_cultist_prompt_text = "PRESS 1";
first_night_cultist_aim_prompt_text = "AIM AND PRESS LMB";
first_night_cultist_prompt_scale = 3;
first_night_cultist_prompt_shadow_offset = 4;

// Day cycle and shrine objective display in the top-right corner.
day_phase_text_offset_x = 85;
day_phase_text_y = 83;
day_phase_bar_offset_x = 47;
day_phase_bar_y = 120;
day_phase_bar_width = 336;
day_phase_bar_height = 35;
day_phase_objective_y = 1027;
shrine_icon_size = 30;
shrine_icon_gap = 8;
shrine_icon_y_offset = 55;

// Compact cultist status cards shown when no focus window is open.
cultist_status_card_width = 334;
cultist_status_card_height = 152;
cultist_status_card_margin_right = 48;
cultist_status_card_y = 126;
cultist_status_card_gap = 18;
cultist_status_card_slot_count = 3;
cultist_status_card_padding_x = 24;
cultist_status_card_portrait_width = 64;
cultist_status_card_portrait_height = 90;
cultist_status_card_portrait_y = 26;
cultist_status_card_level_y = 112;
cultist_status_card_text_x = 110;
cultist_status_card_name_y = 20;
cultist_status_card_name_max_characters = 14;
cultist_status_card_bar_x = 110;
cultist_status_card_bar_y = 55;
cultist_status_card_bar_width = 130;
cultist_status_card_bar_height = 18;
cultist_status_card_bar_gap = 8;
cultist_status_card_label_gap = 7;
cultist_status_card_background_alpha = 0.3;
cultist_status_card_bar_background_color = c_black;
cultist_status_card_hp_color = COLOR_HUD_CULTIST_STATUS_HP;
cultist_status_card_exp_color = COLOR_HUD_CULTIST_STATUS_EXP;
cultist_status_card_stamina_color = COLOR_HUD_CULTIST_STATUS_STAMINA;
cultist_status_card_label_color = COLOR_HUD_TEXT;

// Minimap mirrors the current battle around the cannon in the right HUD sidebar.
minimap_size = 334;
minimap_margin_right = 48;
minimap_y = 683;
minimap_world_radius = 5600;
minimap_base_size = 74;
minimap_enemy_size = 11;
minimap_cultist_width = 24;
minimap_cultist_height = 36;
minimap_cultist_bar_width = 19;
minimap_cultist_bar_height = 7;
minimap_cultist_bar_gap = 2;
minimap_view_alpha = 0.2;
minimap_view_border_width = 4;
minimap_view_min_size = 10;

// Control hints stay visible only during unobstructed gameplay.
control_hints_x = 32;
control_hints_bottom_margin = 118;
control_hints_row_height = 28;
control_hints_row_gap = 8;
control_hints_key_min_width = 112;
control_hints_key_height = 24;
control_hints_key_padding_x = 10;
control_hints_key_text_gap = 12;
control_hints_padding_x = 12;
control_hints_padding_y = 10;
control_hints_background_alpha = 0.52;
control_hints_key_alpha = 0.18;
control_hint_keys = ["SPACE", "WASD", "MOUSE WHEEL"];
control_hint_actions = ["pause", "move camera", "zoom camera"];

// Cannon satiety is filled by hauling corpses to the cannon.
cannon_satiety_width = 460;
cannon_satiety_height = 34;
cannon_satiety_bar_offset_x = 92;
cannon_satiety_bar_width = 156;
cannon_satiety_bar_height = 8;
cannon_satiety_bar_gap = 5;
cannon_satiety_bar_label_gap = 8;
cannon_satiety_reward_icon_gap = 10;
cannon_satiety_reward_icon_radius = 7;
cannon_satiety_reward_group_gap = 18;
cannon_satiety_reward_label_gap = 3;
cannon_satiety_padding_x = 14;
cannon_satiety_label = "SATIETY";

// Wall fallen notice appears when cannon HP reaches zero, without stopping the run.
wall_fallen_notice_width = 420;
wall_fallen_notice_height = 92;
wall_fallen_notice_y = 96;
wall_fallen_notice_padding = 12;
wall_fallen_title = "THE WALL HAS FALLEN";
wall_fallen_description = "You lost, but can keep playing.";

// Objective complete notice appears when enough shrines are tainted.
objective_complete_notice_width = 420;
objective_complete_notice_height = 92;
objective_complete_notice_y = 96;
objective_complete_notice_padding = 12;
objective_complete_title = "TRIALS COMPLETE";
objective_complete_description = "The cannon accepts you as the new Pontiff.";

// Resource display order from left to right in the top-left corner.
resource_order = [
	RESOURCES.FLESH,
	RESOURCES.SOULS,
	RESOURCES.IRON
];

resource_colors = [
	COLOR_HUD_FLESH,
	COLOR_HUD_SOULS,
	COLOR_HUD_IRON
];

resource_icon_sprites = [
	s_flesh_icon,
	s_soul_icon,
	s_iron_icon
];

// Taint display is derived from the ground corruption grid.
corruption_display_name = "TAINT";
corruption_display_value = 0;
corruption_display_decimals = 1;
corruption_update_interval = 0.25 * room_speed;
corruption_update_timer = corruption_update_interval;
corruption_display_color = COLOR_HUD_CORRUPTION;

// Projectile queue display at the bottom center of the HUD.
projectile_queue_margin_bottom = 18;
projectile_slot_width = 86;
projectile_slot_height = 74;
projectile_slot_gap = 8;
projectile_slot_background_height = 64;
projectile_circle_radius = 13;
projectile_current_circle_radius = 17;
projectile_current_scale_padding = 5;
projectile_name_offset_y = 40;
projectile_payload_offset_y = 56;
projectile_payload_icon_size = 14;
projectile_payload_icon_gap = 4;
projectile_payload_count_gap = 2;
projectile_aim_prompt_gap = 6;
projectile_key_prompt_prefix = "Press ";
projectile_day_alpha = 0.45;
projectile_description_width = 330;
projectile_description_height = 58;
projectile_description_gap = 8;
projectile_description_line_separation = 16;

projectile_names = array_create(PROJECTILE_TYPE.COUNT, "");
projectile_names[PROJECTILE_TYPE.DAMAGE] = "DAMAGE";
projectile_names[PROJECTILE_TYPE.CORRUPTION] = "TAINT";
projectile_names[PROJECTILE_TYPE.SUMMON] = "SUMMON";
projectile_names[PROJECTILE_TYPE.RALLY] = "RALLY";
projectile_names[PROJECTILE_TYPE.CULTIST] = "CULTIST";
projectile_names[PROJECTILE_TYPE.FEAST] = "TAINT SHELL";
projectile_names[PROJECTILE_TYPE.HEAL] = "HEAL";
projectile_names[PROJECTILE_TYPE.BOMB] = "BOMB";
projectile_names[PROJECTILE_TYPE.SKELETONS] = "SKELETONS";

projectile_descriptions = array_create(PROJECTILE_TYPE.COUNT, "");
projectile_descriptions[PROJECTILE_TYPE.DAMAGE] = "Damages units and buildings inside the impact area.";
projectile_descriptions[PROJECTILE_TYPE.CORRUPTION] = "Adds Taint to ground cells and triggers Taint reactions.";
projectile_descriptions[PROJECTILE_TYPE.SUMMON] = "Summons friendly forces through valid target reactions.";
projectile_descriptions[PROJECTILE_TYPE.RALLY] = "Sends half of nearby friendly units to the impact point.";
projectile_descriptions[PROJECTILE_TYPE.CULTIST] = "Launches a cultist into battle, dealing impact damage and spawning demon form.";
projectile_descriptions[PROJECTILE_TYPE.FEAST] = "Fires " + string(BALANCE_CANNON_FEAST_PROJECTILE_COUNT) + " Taint Shell impacts over a wide area and heavily damages enemies inside. When you gain a Taint Shell, you also gain 1 random bonus projectile.";
projectile_descriptions[PROJECTILE_TYPE.HEAL] = "Restores " + string(BALANCE_PROJECTILE_HEAL_AMOUNT) + " health to all friendly units inside a " + string(BALANCE_PROJECTILE_HEAL_RADIUS) + " pixel radius. Payload Mastery improves it.";
projectile_descriptions[PROJECTILE_TYPE.BOMB] = "Deals " + string(BALANCE_PROJECTILE_BOMB_DAMAGE_AMOUNT) + " damage to every unit inside a " + string(BALANCE_PROJECTILE_BOMB_RADIUS) + " pixel radius. Payload Mastery improves it.";
projectile_descriptions[PROJECTILE_TYPE.SKELETONS] = "Summons " + string(BALANCE_PROJECTILE_SKELETON_COUNT) + " skeleton inside a " + string(BALANCE_PROJECTILE_SKELETON_RADIUS) + " pixel radius. Payload Mastery improves it.";
