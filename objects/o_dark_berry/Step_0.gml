// Garden entities exist only during the night; timers use scaled, unpaused gameplay time.
if (global.day_phase != DAY_PHASE.NIGHT)
{
	instance_destroy();
	exit;
}
if (global.pause)
{
	exit;
}

// Query collision bounds so a berry triggers as soon as an enemy touches it.
var _enemies = ds_list_create();
var _count = collision_circle_list(x, y, trigger_radius, o_enemy_units, false, true, _enemies, false);
var _triggered = false;
for (var _index = 0; _index < _count; ++_index)
{
	var _enemy = _enemies[| _index];
	if (!instance_exists(_enemy) || _enemy.hp <= 0 || !_enemy.visible
		|| _enemy.is_being_dragged || _enemy.unit_faction != UNIT_FACTION.ENEMY
		|| _enemy.doom_bell_stasis_is_active())
	{
		continue;
	}
	_enemy.stun_apply(BALANCE_DARK_GARDEN_STUN_TIME);
	_triggered = true;
	break;
}
ds_list_destroy(_enemies);
if (_triggered)
{
	instance_destroy();
}
