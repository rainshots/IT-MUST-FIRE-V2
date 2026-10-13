// One civilian generates Mana and charges the Cannon; the worker parent manages staffing and removal.
event_inherited();
worker_max = BALANCE_CAULDRON_WORKER_CAPACITY;
worker_uses_speed_multiplier = false;
mana_work_seconds = 0;
charge_work_seconds = 0;
image_speed = 0;

// Preserve partial staffed time across worker changes, but reset it at each fight start.
worker_work_update = function(_worker_seconds)
{
	if (!instance_exists(o_game_controller) || !instance_exists(o_cannon) || o_cannon.hp <= 0) return;
	if (global.pause || o_game_controller.fight_state != FIGHT_STATE.ACTIVE) return;
	// Charge independently of the slower Mana production timer.
	charge_work_seconds += _worker_seconds;
	var _charge_ticks = floor((charge_work_seconds + 0.000001) / BALANCE_CAULDRON_CHARGE_SECONDS);
	charge_work_seconds = max(0, charge_work_seconds - _charge_ticks * BALANCE_CAULDRON_CHARGE_SECONDS);
	o_game_controller.fight_charge = min(BALANCE_FIGHT_CHARGE_MAX, o_game_controller.fight_charge + _charge_ticks);
	mana_work_seconds += _worker_seconds;
	var _ticks = floor((mana_work_seconds + 0.000001) / BALANCE_CAULDRON_MANA_SECONDS);
	if (_ticks <= 0) return;
	mana_work_seconds = max(0, mana_work_seconds - _ticks * BALANCE_CAULDRON_MANA_SECONDS);
	global.faction_mana[global.player_faction] += _ticks * BALANCE_CAULDRON_MANA_AMOUNT;
};
