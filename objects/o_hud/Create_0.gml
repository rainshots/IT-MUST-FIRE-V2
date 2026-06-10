// HUD layout in GUI coordinates.
hud_margin_x = 18;
hud_margin_y = 16;
resource_item_width = 150;
resource_item_height = 34;
resource_item_gap = 10;
resource_icon_radius = 8;
resource_icon_size = 22;
resource_icon_text_gap = 12;
resource_text_padding = 20;

// Day cycle display in the top-right corner.
day_phase_item_width = 220;
day_phase_item_height = 78;
day_phase_margin_right = 18;
day_phase_text_padding = 14;
day_phase_bar_height = 8;
day_phase_bar_margin_x = 14;
day_phase_bar_margin_bottom = 12;

// Cannon satiety is filled by hauling corpses to the cannon.
cannon_satiety_width = 260;
cannon_satiety_height = 34;
cannon_satiety_bar_width = 156;
cannon_satiety_bar_height = 8;
cannon_satiety_bar_gap = 5;
cannon_satiety_padding_x = 14;
cannon_satiety_label = "SATIETY";

// Wall fallen notice appears when cannon HP reaches zero, without stopping the run.
wall_fallen_notice_width = 420;
wall_fallen_notice_height = 76;
wall_fallen_notice_y = 96;
wall_fallen_notice_padding = 12;
wall_fallen_title = "THE WALL HAS FALLEN";
wall_fallen_description = "You lost, but can keep playing.";

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

// Corruption display is derived from the ground corruption grid.
corruption_display_name = "CORRUPTION";
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
projectile_aim_prompt_text = "Press 1 to aim";
projectile_description_width = 330;
projectile_description_height = 58;
projectile_description_gap = 8;
projectile_description_line_separation = 16;

projectile_names = array_create(PROJECTILE_TYPE.FEAST + 1, "");
projectile_names[PROJECTILE_TYPE.DAMAGE] = "DAMAGE";
projectile_names[PROJECTILE_TYPE.CORRUPTION] = "INFECTION";
projectile_names[PROJECTILE_TYPE.SUMMON] = "SUMMON";
projectile_names[PROJECTILE_TYPE.RALLY] = "RALLY";
projectile_names[PROJECTILE_TYPE.CULTIST] = "CULTIST";
projectile_names[PROJECTILE_TYPE.FEAST] = "FEAST";

projectile_descriptions = array_create(PROJECTILE_TYPE.FEAST + 1, "");
projectile_descriptions[PROJECTILE_TYPE.DAMAGE] = "Damages units and buildings inside the impact area.";
projectile_descriptions[PROJECTILE_TYPE.CORRUPTION] = "Infects ground cells and triggers corruption reactions.";
projectile_descriptions[PROJECTILE_TYPE.SUMMON] = "Summons friendly forces through valid target reactions.";
projectile_descriptions[PROJECTILE_TYPE.RALLY] = "Sends half of nearby friendly units to the impact point.";
projectile_descriptions[PROJECTILE_TYPE.CULTIST] = "Launches a cultist into battle, dealing impact damage and spawning demon form.";
projectile_descriptions[PROJECTILE_TYPE.FEAST] = "Fires 20 infection shells over a wide area and heavily damages enemies inside.";
