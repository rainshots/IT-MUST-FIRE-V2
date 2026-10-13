// One worker repairs the defense wall; destroyed walls accumulate rebuilding work.
event_inherited();
worker_max = BALANCE_FIGHT_FOUNDRY_WORKERS;
worker_uses_speed_multiplier = false;
rebuild_hp = 0;
image_speed = 0;
image_xscale = BALANCE_FIGHT_FOUNDRY_SCALE;
image_yscale = BALANCE_FIGHT_FOUNDRY_SCALE;
worker_work_update = function(_worker_seconds)
{
	if (!instance_exists(o_game_controller) || !instance_exists(o_cannon) || o_cannon.hp <= 0) return;
	var _controller = instance_find(o_game_controller, 0);
	if (global.pause || _controller.fight_state != FIGHT_STATE.ACTIVE) return;
	var _wall = _controller.fight_wall;
	if (instance_exists(_wall) && _wall.hp > 0)
	{
		rebuild_hp = 0;
		_wall.hp = min(_wall.max_hp, _wall.hp + _wall.max_hp * BALANCE_FIGHT_FOUNDRY_REPAIR_SHARE_PER_SECOND * _worker_seconds);
		return;
	}
	// Rebuilding costs exactly as much staffed time as repairing half of maximum health.
	rebuild_hp += BALANCE_WALL_MAX_HP * BALANCE_FIGHT_FOUNDRY_REPAIR_SHARE_PER_SECOND * _worker_seconds;
	if (rebuild_hp + 0.000001 >= BALANCE_WALL_MAX_HP * BALANCE_FIGHT_WALL_START_HP_SHARE)
	{
		if (instance_exists(_wall)) instance_destroy(_wall);
		_controller.fight_wall = fight_wall_create();
		rebuild_hp = 0;
	}
};
