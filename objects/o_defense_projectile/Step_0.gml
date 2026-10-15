if (global.pause) exit;
if (!instance_exists(o_game_controller) || o_game_controller.fight_state != FIGHT_STATE.ACTIVE) { instance_destroy(); exit; }
var _seconds = global.gameplay_time_scale / max(1, room_speed);
remaining_seconds -= _seconds;
if (remaining_seconds <= 0) { instance_destroy(); exit; }
if (exploded) exit;
if (instance_exists(target) && target.hp > 0) { target_x = target.x; target_y = target.y; }
var _distance = point_distance(x, y, target_x, target_y);
var _step = BALANCE_DEFENSE_PROJECTILE_SPEED * _seconds;
if (_distance <= _step)
{
	if (blast_radius > 0) defense_blast_apply(target_x, target_y, blast_radius, BALANCE_DEFENSE_TOWER_DAMAGE);
	else if (instance_exists(target)) cannon_damage_apply(target, BALANCE_DEFENSE_TOWER_DAMAGE);
	instance_destroy();
	exit;
}
var _direction = point_direction(x, y, target_x, target_y);
x += lengthdir_x(_step, _direction);
y += lengthdir_y(_step, _direction);
