// The immovable friendly objective occupies the central 3x3 grid cells.
event_inherited();
grid_columns = BALANCE_HEART_GRID_SLOTS;
grid_rows = BALANCE_HEART_GRID_SLOTS;
placement_size = BALANCE_HEART_GRID_SLOTS * BALANCE_BUILDING_GRID_CELL_SIZE;
// An odd footprint snaps to the nearest central cells of the even-sized grid.
var _position = building_grid_snap(id, BALANCE_BUILDING_GRID_CENTER_X, BALANCE_BUILDING_GRID_CENTER_Y);
x = _position.x;
y = _position.y;
building_label = "The Heart";
building_can_move = false;
building_accepts_workers = false;
worker_max = 0;
is_attackable = true;
unit_faction = UNIT_FACTION.FRIENDLY;
faction = global.player_faction;
max_hp = BALANCE_HEART_MAX_HP;
hp = max_hp;
armor = 100;
magic_resistance = 100;
combat_radius = placement_size * 0.5;
image_speed = 0;
image_xscale = placement_size / max(sprite_get_width(sprite_index), sprite_get_height(sprite_index));
image_yscale = image_xscale;
unit_damage_receive = function(_amount, _source_faction = UNIT_FACTION.NOONE, _critical = false, _chain = true, _source = noone, _favor = FACTION.NONE)
{
	if (hp <= 0 || _amount <= 0 || _source_faction == unit_faction) return 0;
	var _applied = min(hp, _amount);
	hp -= _applied;
	damage_popup_create(x, y, _applied, unit_faction, _critical);
	if (hp <= 0) instance_destroy();
	return _applied;
};
