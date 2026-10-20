/// @description Advances the configured healing, shell or unit production of a staffed building.
function building_production_update(_seconds)
{
	if(!instance_exists(o_game_controller) || o_game_controller.fight_state!=FIGHT_STATE.ACTIVE) return;
	if(production_kind==0)
	{
		with(o_friendly_units)
		{
			if(hp>0 && !cannon_loaded && !is_being_dragged && !cargo_launched && !instance_exists(target_instance))
				hp=min(max_hp,hp+other.heal_rate*_seconds);
		}
		return;
	}
	// Shell production is unavailable while the Cannon and Warehouses are removed.
	if (production_kind == 1 || player_unit_count_get() >= o_game_controller.player_unit_cap) return;
	production_seconds += _seconds;
	if (production_seconds + 0.000001 < production_interval) return;
	production_seconds = 0;
	var _grid = building_grid_bounds_get();
	instance_create_layer(_grid.right + BALANCE_BUILDING_GRID_CELL_SIZE,
		BALANCE_BUILDING_GRID_CENTER_Y + random_range(-BALANCE_CARGO_IDLE_HALF_HEIGHT, BALANCE_CARGO_IDLE_HALF_HEIGHT), "Instances", production_unit);
}
