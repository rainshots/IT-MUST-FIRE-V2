// End-of-night cleanup cancels unfinished effects without applying their finishing upgrade.
if (global.day_phase != DAY_PHASE.NIGHT)
{
	instance_destroy();
	exit;
}
if (global.pause)
{
	exit;
}

// The effect occupies the current Gaze, including permanent radius growth during its lifetime.
if (instance_exists(source_cannon))
{
	x = source_cannon.gaze_x;
	y = source_cannon.gaze_y;
	effect_radius = source_cannon.gaze_radius;
}
var _time_step = min(life_remaining, global.gameplay_time_scale);
var _finishing = life_remaining <= _time_step;
life_remaining = max(0, life_remaining - _time_step);
swirl_angle += _time_step;
var _enemy_count = instance_number(o_enemy_units);
// Iterate backwards because the finishing upgrade can remove enemy instances.
for (var _enemy_index = _enemy_count - 1; _enemy_index >= 0; --_enemy_index)
{
	var _enemy = instance_find(o_enemy_units, _enemy_index);
	if (!instance_exists(_enemy) || _enemy.hp <= 0 || _enemy.unit_faction != UNIT_FACTION.ENEMY
		|| _enemy.doom_bell_stasis_is_active())
	{
		continue;
	}
	var _distance = point_distance(x, y, _enemy.x, _enemy.y);
	if (_distance > effect_radius)
	{
		continue;
	}

	// Own movement without disabling attack decisions. Overlapping fields do not stack pull speed.
	if (!instance_exists(_enemy.quicksand_source) || _enemy.quicksand_source == id)
	{
		_enemy.quicksand_source = id;
		var _pull = min(_distance, BALANCE_QUICKSAND_PULL_SPEED * _time_step / room_speed);
		var _direction = point_direction(_enemy.x, _enemy.y, x, y);
		_enemy.move_with_wall_collision(lengthdir_x(_pull, _direction), lengthdir_y(_pull, _direction), noone, true);
	}
	if (_finishing)
	{
		quicksand_finish_enemy(_enemy, x, y, effect_radius, upgrade);
	}
}
if (_finishing)
{
	instance_destroy();
}
