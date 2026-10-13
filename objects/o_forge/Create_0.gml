// One worker forges random balls at the configured interval, without speed bonuses.
event_inherited();
worker_max = 1;
worker_uses_speed_multiplier = false;
forge_seconds = 0;
image_speed = 0;
worker_work_update = function(_worker_seconds)
{
	if (!instance_exists(o_game_controller) || global.pause) return;
	var _controller = instance_find(o_game_controller, 0);
	if (_controller.fight_state != FIGHT_STATE.ACTIVE) return;
	if (array_length(_controller.cannon_ammo) >= _controller.cannon_ammo_capacity) return;
	forge_seconds += _worker_seconds;
	var _balls = min(floor((forge_seconds + 0.000001) / BALANCE_FORGE_SECONDS), _controller.cannon_ammo_capacity - array_length(_controller.cannon_ammo));
	for (var _index = 0; _index < _balls; ++_index) array_push(_controller.cannon_ammo, cannonball_random_type_get());
	forge_seconds = max(0, forge_seconds - _balls * BALANCE_FORGE_SECONDS);
	if (array_length(_controller.cannon_ammo) >= _controller.cannon_ammo_capacity) forge_seconds = 0;
};
