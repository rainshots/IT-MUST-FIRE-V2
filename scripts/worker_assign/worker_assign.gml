/// @description Assigns a worker to an available worker-building descendant.
function worker_assign(_worker, _building)
{
	if (!instance_exists(_worker) || !instance_exists(_building) || _worker.object_index != o_cultist) return false;
	if (_building.object_index != o_worker_building_parent
		&& !object_is_ancestor(_building.object_index, o_worker_building_parent)) return false;
	if (_worker.assigned_building == _building) return true;
	if (!_building.building_accepts_workers || _worker.hp <= 0
		|| array_length(_building.worker_cultists) >= _building.worker_max) return false;
	worker_release(_worker);
	array_push(_building.worker_cultists, _worker);
	_worker.assigned_building = _building;
	_worker.is_assigned_to_building = true;
	_worker.is_being_dragged = false;
	_building.worker_positions_update();
	return true;
}
