// Prune unavailable workers and accumulate uninterrupted staffed time.
if (global.pause || is_being_dragged || placement_preview) exit;
if (instance_exists(held_shell))
{
	if (!held_shell.is_being_dragged)
	{
		held_shell.x = x;
		held_shell.y = (sprite_index == -1 ? y : bbox_top) - 28;
		warehouse_store(held_shell);
	}
}
var _seconds = global.gameplay_time_scale / max(1, room_speed);
var _work_seconds = 0;
var _count = array_length(worker_cultists);
for (var _index = _count - 1; _index >= 0; --_index)
{
	var _worker = worker_cultists[_index];
	if (!instance_exists(_worker) || _worker.assigned_building != id)
	{
		array_delete(worker_cultists, _index, 1);
		continue;
	}
	if (!building_accepts_workers || _worker.hp <= 0 || _worker.is_being_dragged)
	{
		worker_release(_worker);
		continue;
	}
	_work_seconds += _seconds * (worker_uses_speed_multiplier ? _worker.worker_speed_multiplier : 1);
}
worker_positions_update();
if (_work_seconds > 0) worker_work_update(_work_seconds);
