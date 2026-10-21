event_inherited();
worker_max = 1;
worker_uses_speed_multiplier = false;
image_speed = 0;
building_label = "Demolition Bomb";
grid_columns = 1;
grid_rows = 1;
placement_size = BALANCE_BUILDING_GRID_CELL_SIZE;
production_interval = BALANCE_DEMOLITION_BOMB_SECONDS;
custom_work_status = "Preparing demolition";
worker_work_update = function(_seconds)
{
	if (!instance_exists(o_game_controller) || o_game_controller.fight_state != FIGHT_STATE.ACTIVE) return;
	production_seconds += _seconds;
	if (production_seconds + 0.000001 < production_interval) return;
	// Any occupied trash cell in the eight neighboring tiles clears the whole trash object.
	var _bounds = building_bounds_get(id, x, y);
	var _left = _bounds.left - BALANCE_BUILDING_GRID_CELL_SIZE;
	var _right = _bounds.right + BALANCE_BUILDING_GRID_CELL_SIZE;
	var _top = _bounds.top - BALANCE_BUILDING_GRID_CELL_SIZE;
	var _bottom = _bounds.bottom + BALANCE_BUILDING_GRID_CELL_SIZE;
	with (o_grid_trash_parent)
	{
		var _trash = building_bounds_get(id, x, y);
		if (_trash.left < _right && _trash.right > _left && _trash.top < _bottom && _trash.bottom > _top)
		{
			building_smoke_create(id);
			instance_destroy();
		}
	}
	building_smoke_create(id);
	instance_destroy();
};
