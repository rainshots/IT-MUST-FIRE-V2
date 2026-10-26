/// @description Advances staffed tower reload or mine production; defense building context.
function defense_work_update(_seconds)
{
	if (!instance_exists(o_game_controller) || o_game_controller.fight_state != FIGHT_STATE.ACTIVE) return;
	if (object_index == o_pumpkin_patch)
	{
		if (instance_number(o_patch_mine) >= BALANCE_PUMPKIN_MAX_MINES) return;
		production_seconds = min(production_interval, production_seconds + _seconds);
		if (production_seconds >= production_interval && instance_exists(pumpkin_mine_spawn(id)))
			production_seconds = 0;
		return;
	}
	// Reload only while staffed; retain a ready shot until an enemy is in range.
	production_seconds = min(production_interval, production_seconds + _seconds);
	if (production_seconds < production_interval) return;
	var _target = noone;
	var _distance = BALANCE_DEFENSE_TOWER_RANGE;
	with (o_enemy_units)
	{
		if (hp <= 0) continue;
		var _candidate_distance = point_distance(x, y, other.x, other.y);
		if (_candidate_distance <= _distance) { _target = id; _distance = _candidate_distance; }
	}
	if (!instance_exists(_target)) return;
	var _shot = instance_create_layer(x, y, "Instances", o_defense_projectile);
	_shot.target = _target;
	_shot.target_x = _target.x;
	_shot.target_y = _target.y;
	_shot.blast_radius = object_index == o_bomb_tower ? BALANCE_DEFENSE_BOMB_RADIUS : 0;
	production_seconds = 0;
}
