// Production runs only while at least one valid cultist is assigned.
if (global.pause || production_resource == noone)
{
	exit;
}

// Remove stale worker references before calculating production speed.
var _valid_worker_count = 0;
var _worker_count = array_length(worker_cultists);

for (var _worker_index = 0; _worker_index < _worker_count; ++_worker_index)
{
	var _worker = worker_cultists[_worker_index];

	if (instance_exists(_worker) && _worker.object_index == o_cultist)
	{
		worker_cultists[_valid_worker_count] = _worker;
		_valid_worker_count++;
	}
}

array_resize(worker_cultists, _valid_worker_count);

if (_valid_worker_count <= 0)
{
	production_speed_multiplier = 0;
	exit;
}

recalculate_production_speed_multiplier();

// Use current room_speed so production duration stays stable if speed changes.
var _production_step = production_speed_multiplier / max(1, production_duration * room_speed);
production_progress += _production_step;

if (production_progress >= 1)
{
	production_progress -= 1;
	global.resources[production_resource] += production_amount;
	resource_popup_create(x, y - production_bar_offset_y, production_resource, production_amount);
}
