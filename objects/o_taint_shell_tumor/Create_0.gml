// Initialize shared map object durability, health bar, and hover tooltip behavior.
event_inherited();

// Sweet Rot tumors persist until enemies destroy them and never create a restoration point.
max_hp = BALANCE_TAINT_COMPOST_SWEET_ROT_MAX_HP;
hp = max_hp;
building_constructed_by_shell = true;
corruption_bar_visible = false;
attraction_radius = BALANCE_TAINT_COMPOST_SWEET_ROT_RADIUS;
image_xscale = BALANCE_TAINT_COMPOST_SWEET_ROT_SPRITE_SCALE;
image_yscale = image_xscale;
image_speed = 0;
tooltip_lines = [
	"Sweet Rot",
	"Attracts enemies outside combat within " + string(attraction_radius),
	"Persists until destroyed"
];
