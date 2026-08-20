if (global.day_phase != DAY_PHASE.NIGHT)
{
	instance_destroy();
	exit;
}

if (global.pause)
{
	exit;
}

var _time_scale = variable_global_exists("gameplay_time_scale") ? global.gameplay_time_scale : 1;
spawn_timer -= _time_scale;

if (spawn_timer > 0)
{
	exit;
}

spawn_timer = spawn_interval;
var _spawn_direction = irandom(359);
var _spawn_distance = random(spawn_radius);
var _spawn_x = x + lengthdir_x(_spawn_distance, _spawn_direction);
var _spawn_y = y + lengthdir_y(_spawn_distance, _spawn_direction);
var _unit_object = spawn_unit_objects[irandom(array_length(spawn_unit_objects) - 1)];
var _unit = instance_create_layer(_spawn_x, _spawn_y, "Instances", _unit_object);

if (instance_exists(_unit))
{
	_unit.summon_nights_remaining = 1;
	_unit.regroup_is_active = false;
	_unit.rally_is_active = false;
	_unit.target_instance = noone;
}
