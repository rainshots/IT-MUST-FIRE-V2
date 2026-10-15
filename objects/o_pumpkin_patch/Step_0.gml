event_inherited();
if (global.pause || placement_preview || is_being_dragged) exit;
if (!instance_exists(o_game_controller) || o_game_controller.fight_state != FIGHT_STATE.ACTIVE) exit;
// Existing mines stay armed even when the worker leaves.
for (var _i = array_length(mines) - 1; _i >= 0; --_i)
{
	var _mine_x = x + mines[_i].x;
	var _mine_y = y + mines[_i].y;
	var _trigger = false;
	with (o_enemy_units)
	{
		if (hp > 0 && point_distance(x, y, _mine_x, _mine_y) <= BALANCE_PUMPKIN_TRIGGER_RADIUS) _trigger = true;
	}
	if (_trigger)
	{
		defense_blast_apply(_mine_x, _mine_y, BALANCE_PUMPKIN_BLAST_RADIUS, BALANCE_PUMPKIN_DAMAGE);
		array_delete(mines, _i, 1);
	}
}
