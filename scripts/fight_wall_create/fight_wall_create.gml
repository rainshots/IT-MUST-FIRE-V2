/// @description Creates the Cannon defense wall at half health; returns the wall instance.
function fight_wall_create()
{
	if (!instance_exists(o_cannon)) return noone;
	var _wall = instance_create_layer(o_cannon.x + BALANCE_FIGHT_WALL_OFFSET_X, o_cannon.y, "Instances", o_wall_ally);
	_wall.image_xscale = BALANCE_FIGHT_WALL_WIDTH / sprite_get_width(_wall.sprite_index);
	_wall.image_yscale = BALANCE_FIGHT_WALL_HEIGHT / sprite_get_height(_wall.sprite_index);
	_wall.hp = _wall.max_hp * BALANCE_FIGHT_WALL_START_HP_SHARE;
	_wall.bar_offset_y = BALANCE_FIGHT_WALL_HEIGHT * 0.5 + _wall.bar_height;
	_wall.wall_navigation_mark_dirty();
	return _wall;
}
