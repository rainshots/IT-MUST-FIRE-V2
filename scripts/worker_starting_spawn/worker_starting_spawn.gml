/// @description Creates the three initial civilians once; controller context.
function worker_starting_spawn()
{
	if (workers_initialized || !instance_exists(o_cannon)) return;
	workers_initialized = true;
	for (var _index = 0; _index < BALANCE_WORKER_START_COUNT; ++_index)
	{
		var _angle = random_range(BALANCE_IDLE_WORKER_WANDER_DIRECTION_MIN, BALANCE_IDLE_WORKER_WANDER_DIRECTION_MAX);
		var _distance = random(BALANCE_IDLE_WORKER_WANDER_RADIUS);
		var _x = o_cannon.x + lengthdir_x(_distance, _angle);
		var _y = o_cannon.y + BALANCE_DAY_CANNON_REGROUP_OFFSET_Y + lengthdir_y(_distance, _angle);
		instance_create_layer(_x, _y, "Instances", o_cultist);
	}
}
