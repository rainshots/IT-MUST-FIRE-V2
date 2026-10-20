/// @description Creates the three initial civilians once; controller context.
function worker_starting_spawn()
{
	if (workers_initialized) return;
	workers_initialized = true;
	for (var _index = 0; _index < BALANCE_WORKER_START_COUNT; ++_index)
	{
		var _angle = random_range(BALANCE_IDLE_WORKER_WANDER_DIRECTION_MIN, BALANCE_IDLE_WORKER_WANDER_DIRECTION_MAX);
		var _distance = random(BALANCE_IDLE_WORKER_WANDER_RADIUS);
		var _x = BALANCE_BUILDING_GRID_CENTER_X + lengthdir_x(_distance, _angle);
		var _y = BALANCE_BUILDING_GRID_CENTER_Y + BALANCE_DAY_CANNON_REGROUP_OFFSET_Y + lengthdir_y(_distance, _angle);
		instance_create_layer(_x, _y, "Instances", o_cultist);
	}
}
