/// @description Removes a worker from its current building and sends it back to cannon-side idling.
function worker_release(_worker)
{
	if (!instance_exists(_worker)) return;
	var _building = _worker.assigned_building;
	_worker.assigned_building = noone;
	_worker.is_assigned_to_building = false;
	if (instance_exists(_building))
	{
		var _count = array_length(_building.worker_cultists);
		for (var _index = _count - 1; _index >= 0; --_index)
		{
			if (_building.worker_cultists[_index] == _worker) array_delete(_building.worker_cultists, _index, 1);
		}
		_building.worker_positions_update();
	}
	if (instance_exists(o_game_controller)) o_game_controller.worker_idle_wander_target_pick(_worker);
}
