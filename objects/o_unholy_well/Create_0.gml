event_inherited();
worker_max = 1;
worker_uses_speed_multiplier = false;
image_speed = 0;
building_label = "Unholy Well";
grid_columns = BALANCE_WELL_GRID_SLOTS;
grid_rows = BALANCE_WELL_GRID_SLOTS;
placement_size = grid_columns * BALANCE_BUILDING_GRID_CELL_SIZE;
upgrade_object = o_witch_well;
production_interval = BALANCE_UNHOLY_WELL_SECONDS;
custom_work_status = "Generating Mana";
worker_work_update = function(_seconds)
{
	if (!instance_exists(o_game_controller) || o_game_controller.fight_state != FIGHT_STATE.ACTIVE) return;
	production_seconds += _seconds;
	var _cycles = floor((production_seconds + 0.000001) / production_interval);
	if (_cycles > 0)
	{
		production_seconds = max(0, production_seconds - _cycles * production_interval);
		global.faction_mana[global.player_faction] += _cycles * BALANCE_WELL_MANA_PER_CYCLE;
	}
};
