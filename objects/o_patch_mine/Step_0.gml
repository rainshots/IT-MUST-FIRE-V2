if (global.pause || !instance_exists(o_game_controller) || o_game_controller.fight_state != FIGHT_STATE.ACTIVE) exit;
var _trigger = false;
with (o_enemy_units)
{
	if (hp > 0 && point_distance(x, y, other.x, other.y) <= BALANCE_PUMPKIN_TRIGGER_RADIUS)
	{
		_trigger = true;
		break;
	}
}
if (_trigger)
{
	defense_blast_apply(x, y, BALANCE_PUMPKIN_BLAST_RADIUS, BALANCE_PUMPKIN_DAMAGE);
	instance_destroy();
}
