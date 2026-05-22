// HUD layout in GUI coordinates.
hud_margin_x = 18;
hud_margin_y = 16;
resource_item_width = 150;
resource_item_height = 34;
resource_item_gap = 10;
resource_icon_radius = 8;
resource_text_padding = 20;

// Day cycle display in the top-right corner.
day_phase_item_width = 190;
day_phase_item_height = 34;
day_phase_margin_right = 18;
day_phase_text_padding = 14;

// Resource display order from left to right in the top-left corner.
resource_order = [
	RESOURCES.SOULS,
	RESOURCES.IRON,
	RESOURCES.CULTISTS
];

resource_names = [
	"SOULS",
	"IRON",
	"CULTISTS"
];

resource_colors = [
	COLOR_HUD_SOULS,
	COLOR_HUD_IRON,
	COLOR_HUD_CULTISTS
];

// Corruption display is derived from the ground corruption grid.
corruption_display_name = "CORRUPTION";
corruption_display_value = 0;
corruption_display_decimals = 1;
corruption_update_interval = 0.25 * room_speed;
corruption_update_timer = corruption_update_interval;
corruption_display_color = COLOR_HUD_CORRUPTION;

// Projectile queue display in the bottom-left corner.
projectile_queue_margin_x = 18;
projectile_queue_margin_bottom = 18;
projectile_slot_width = 86;
projectile_slot_height = 74;
projectile_slot_gap = 8;
projectile_slot_background_height = 64;
projectile_circle_radius = 13;
projectile_current_circle_radius = 17;
projectile_current_scale_padding = 5;
projectile_name_offset_y = 40;
projectile_description_width = 330;
projectile_description_height = 58;
projectile_description_gap = 8;
projectile_description_line_separation = 16;

projectile_names = array_create(3, "");
projectile_names[PROJECTILE_TYPE.DAMAGE] = "DAMAGE";
projectile_names[PROJECTILE_TYPE.CORRUPTION] = "INFECTION";
projectile_names[PROJECTILE_TYPE.SUMMON] = "SUMMON";

projectile_descriptions = array_create(3, "");
projectile_descriptions[PROJECTILE_TYPE.DAMAGE] = "Damages units and buildings inside the impact area.";
projectile_descriptions[PROJECTILE_TYPE.CORRUPTION] = "Infects ground cells and triggers corruption reactions.";
projectile_descriptions[PROJECTILE_TYPE.SUMMON] = "Summons friendly forces through valid target reactions.";
