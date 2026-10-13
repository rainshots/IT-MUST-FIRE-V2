// Effects share simulation time and stop at the end of a fight.
if (global.pause) exit;
if (!instance_exists(o_game_controller) || o_game_controller.fight_state != FIGHT_STATE.ACTIVE)
{
	instance_destroy();
	exit;
}
var _seconds = min(remaining_seconds, global.gameplay_time_scale / max(1, room_speed));
remaining_seconds = max(0, remaining_seconds - _seconds);
tick_seconds += _seconds;
if (effect_type == CANNONBALL_TYPE.FIRE)
{
	if (!instance_exists(burn_target) || burn_target.hp <= 0)
	{
		instance_destroy();
		exit;
	}
	x = burn_target.x;
	y = burn_target.y;
}
var _ticks = floor((tick_seconds + 0.000001) / BALANCE_CANNON_EFFECT_TICK_SECONDS);
if (_ticks > 0)
{
	tick_seconds = max(0, tick_seconds - _ticks * BALANCE_CANNON_EFFECT_TICK_SECONDS);
	if (effect_type == CANNONBALL_TYPE.FIRE) cannon_damage_apply(burn_target, BALANCE_CANNON_BURN_DAMAGE * _ticks);
	else
	{
		var _targets = [];
		with (o_enemy_units)
		{
			if (hp > 0 && point_distance(x, y, other.x, other.y) <= BALANCE_CANNON_BLAST_RADIUS) array_push(_targets, id);
		}
		for (var _index = 0; _index < array_length(_targets); ++_index)
			cannon_damage_apply(_targets[_index], BALANCE_CANNON_POISON_DAMAGE * _ticks);
	}
}
if (remaining_seconds <= 0.000001) instance_destroy();
