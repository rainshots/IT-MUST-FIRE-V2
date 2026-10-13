/// @description Returns the living defense wall for an enemy approaching from the battlefield.
function fight_wall_target_get(_enemy)
{
	if (!instance_exists(_enemy) || !instance_exists(o_game_controller)) return noone;
	var _wall = o_game_controller.fight_wall;
	if (!instance_exists(_wall) || _wall.hp <= 0) return noone;
	if (_enemy.x < _wall.bbox_left) return noone;
	return _wall;
}
