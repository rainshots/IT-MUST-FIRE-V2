// Trash reserves cells and uses the existing Cultist assignment system.
event_inherited();
is_grid_trash = true;
building_can_move = false;
worker_max = 1;
worker_uses_speed_multiplier = false;
clear_seconds = 1;
image_speed = 0;
// Award only deliberate clearing, never room cleanup or fight initialization.
trash_clear_reward_paid = false;
trash_clear = function()
{
	if (trash_clear_reward_paid) return;
	trash_clear_reward_paid = true;
	global.faction_mana[global.player_faction] += grid_columns * grid_rows * BALANCE_TRASH_CLEAR_MANA_PER_SLOT;
	instance_destroy();
};
worker_work_update = function(_seconds)
{
	if (!instance_exists(o_game_controller) || o_game_controller.fight_state != FIGHT_STATE.ACTIVE) return;
	production_seconds = min(clear_seconds, production_seconds + _seconds);
	if (production_seconds + 0.000001 >= clear_seconds)
	{
		global.sound_play_random(global.release_worker_sounds);
		trash_clear();
	}
};
