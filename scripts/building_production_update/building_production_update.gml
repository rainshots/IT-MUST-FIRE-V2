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
	if(production_kind==1)
	{
		if(instance_exists(held_shell)) return;
		// An in-progress shell may finish into the building if storage became full meanwhile.
		if(production_seconds<=0 && is_undefined(warehouse_free_get())) return;
	}
	else if(player_unit_count_get()>=o_game_controller.player_unit_cap) return;
	production_seconds+=_seconds;
	if(production_seconds+0.000001<production_interval) return;
	production_seconds=0;
	if(production_kind==1)
	{
		var _shell=instance_create_layer(x,bbox_top-28,"Instances",o_exploding_shell);
		_shell.hell_shell=produces_hell_shell;
		_shell.corruption_shell = produces_corruption_shell;
		if(!warehouse_store(_shell)) { held_shell=_shell;_shell.storage_owner=id; }
	}
	else if(instance_exists(o_cannon) && player_unit_count_get()<o_game_controller.player_unit_cap)
	{
		instance_create_layer(o_cannon.x+random_range(BALANCE_CARGO_IDLE_MIN_X,BALANCE_CARGO_IDLE_MAX_X),
			o_cannon.y+random_range(-BALANCE_CARGO_IDLE_HALF_HEIGHT,BALANCE_CARGO_IDLE_HALF_HEIGHT),"Instances",production_unit);
	}
}
