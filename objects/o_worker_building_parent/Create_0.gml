// Reusable worker container only: no resource production, upgrades, or legacy event behavior.
building_accepts_workers = true;
worker_cultists = [];
worker_max = BALANCE_WORKER_BUILDING_CAPACITY;
worker_drop_radius = BALANCE_WORKER_DROP_RADIUS;
worker_slot_spacing = BALANCE_WORKER_SLOT_SPACING;
worker_slot_offset_y = BALANCE_WORKER_SLOT_OFFSET_Y;
// Fixed-rate buildings can opt out of randomized worker productivity.
worker_uses_speed_multiplier = true;
worker_total_speed = 0;
y_sort_enabled = true;

// Descendants can override this hook in Create after event_inherited().
// The argument is productivity-weighted worker seconds, for this simulation frame.
worker_work_update = function(_worker_seconds)
{
};

worker_positions_update = function()
{
	var _count = array_length(worker_cultists);
	worker_total_speed = 0;
	for (var _index = 0; _index < _count; ++_index)
	{
		var _worker = worker_cultists[_index];
		if (!instance_exists(_worker)) continue;
		_worker.x = x + (_index - (_count - 1) * 0.5) * worker_slot_spacing;
		_worker.y = (sprite_index == -1 ? y : bbox_bottom) + worker_slot_offset_y;
		_worker.drag_drop_x = _worker.x;
		_worker.drag_drop_y = _worker.y;
		worker_total_speed += _worker.worker_speed_multiplier;
	}
};
