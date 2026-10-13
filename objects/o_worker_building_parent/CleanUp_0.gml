// Workers survive removal of their workplace and return to the Cannon.
var _workers = worker_cultists;
worker_cultists = [];
var _count = array_length(_workers);
for (var _index = 0; _index < _count; ++_index)
{
	var _worker = _workers[_index];
	if (instance_exists(_worker) && _worker.assigned_building == id) worker_release(_worker);
}
