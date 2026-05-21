// HUD layout in GUI coordinates.
hud_margin_x = 18;
hud_margin_y = 16;
resource_item_width = 150;
resource_item_height = 34;
resource_item_gap = 10;
resource_icon_radius = 8;
resource_text_padding = 20;

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
