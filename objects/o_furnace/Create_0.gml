// One civilian powers the Cannon; inherited worker management handles staffing and removal.
event_inherited();
worker_max = BALANCE_FURNACE_WORKER_CAPACITY;
worker_uses_speed_multiplier = false;
charge_work_seconds = 0;
image_speed = 0;

// Partial staffed time is retained when workers are exchanged, and reset each fight.
worker_work_update = function(_worker_seconds)
{
	if (!instance_exists(o_game_controller) || !instance_exists(o_cannon) || o_cannon.hp <= 0) return;
	var _controller = instance_find(o_game_controller, 0);
	if (global.pause || _controller.fight_state != FIGHT_STATE.ACTIVE) return;
	charge_work_seconds += _worker_seconds;
	var _charge_ticks = floor((charge_work_seconds + 0.000001) / BALANCE_FURNACE_CHARGE_SECONDS);
	if (_charge_ticks <= 0) return;
	charge_work_seconds = max(0, charge_work_seconds - _charge_ticks * BALANCE_FURNACE_CHARGE_SECONDS);
	_controller.fight_charge = min(BALANCE_FIGHT_CHARGE_MAX, _controller.fight_charge + _charge_ticks);
};
